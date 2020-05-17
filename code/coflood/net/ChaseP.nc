// @Copyright : Zhichao Cao
// @Modify Date : Mar 1, 2017

// ContikiMAC based Duty Cycling, Optional Phase-Lock, Chase Flood

#include "cc2420_x_spi.h"
#include "cc2420_x_control.h"
#include "Chase.h"
#include "pr.h"

#define PREAMBLE_FACTOR 2
// 100 / reced - 5
#define LONG_LINK_THRE  10
#define SHORTCUT_PATH_THRE 256

module ChaseP{
  provides {
    interface ChaseFlood;
    interface ChaseListen;
    interface ChaseControl;
    interface ChasePacket;
    interface ChaseDelay;
    interface ChaseEnergy;
    interface Init;
  }
  uses {
    // function interfaces
    interface SetChase as RxSet;
    interface SetChase as TxSet;
    interface Receive as subReceive;
    interface CC2420Transmit as subSend;
    interface SplitControl as RadioControl;
    interface DisableRx;
    interface ReceiveIndicator as PacketIndicator;
    interface ReceiveIndicator as EnergyIndicator;
    interface GeneralIO as FIFO;
    interface ArbiterInfo;
    interface Timer<TMilli> as delayTimer;
    interface Timer<TMilli> as sleepTimer;
    interface Timer<TMilli> as randTimer;
    interface Random;
    // flooding tree information
    interface TreeInfo;
    // measurement and debug interfaces
    interface LocalTime<TMilli>;
    interface Leds;
#ifdef CHASE_TAIL_TEST
    // serial TAIL message
    interface AMSend as TailSend;
    interface Packet as TailPacket;
#endif
  }
} implementation {
/**
 * duty cycle control
 **/
  bool dc_start_done;
  bool fast_reboot_after_fail;
  uint16_t sleep_interval;
  uint16_t listen_tail;
  uint16_t fixed_ippi_interval;
  uint16_t random_ippi_interval;
  uint16_t max_cca_checks;
  uint8_t min_samples_required;
  // avoid no receive event after FIFOP when bad packe is received
  uint16_t watch_dog_time;
  // rssi sampling finished
  bool rssi_mark;
/**
 * duty cycle state
 **/
  norace chase_radio_state_t radio_state;
/**
 * flood control
 **/
  bool buf_reced_or_snd;
  bool send_done;
  bool concurrent_broadcast;
  uint16_t current_seq_no;
  uint16_t pre_src_id;
  uint16_t pre_seq_no;
/**
 * flood memory pool
 **/
  bool buf_pending;
  message_t* buf;
  uint8_t len;
  int rssi_seq[RSSI_SAMPLES_NUM];
/**
 * debug and measurement
 **/
  uint32_t debug_time;
  uint32_t time_count;
  uint32_t radio_on_time;
  chase_delay_t delay;
  message_t tail_pkt;
  bool serial_enable;
  bool tail_send_lock;
  uint32_t tail_time_h;
  uint32_t tail_time_l;
/**
 * signal detection and classification
 **/
  task void signal_detect();
  task void signal_classify();
/**
 * pkt send and receive
 **/
  task void pkt_send_init();
  task void pkt_send();
  task void pkt_resend();
  task void cc2420_begin_rec();
  task void start_rand_ippi();

  static inline void set_pkt_header();
  static inline void set_start_time(chase_header_t* hdr);
  static inline void set_fwd_time(chase_header_t* hdr);
  static inline void set_local_delay(chase_header_t* hdr);
  static inline void detect_concurrent_broadcast();
  static inline bool long_link_oppo(chase_header_t* hdr);
  static inline bool shortcut_path_oppo(chase_header_t* hdr);
/**
 * radio operation
 **/
  task void radio_start();
  task void radio_stop();
/**
 * implementation of events and commands
 **/
/**
 * initialize Chase parameter when device boots up
 **/
  command error_t Init.init() {
    radio_state = DUTY_CYCLE_OFF;
    dc_start_done = FALSE;
    fast_reboot_after_fail = FALSE;
    sleep_interval = 512;
    listen_tail = 20;
    max_cca_checks = 3072;
    min_samples_required = 3;
    fixed_ippi_interval = 2;
    random_ippi_interval = 10;
    watch_dog_time = 22;
    // set pending buffer as NULL
    buf = NULL;
    buf_pending = FALSE;
    // set receive status
    buf_reced_or_snd = FALSE;
    // classification results
    concurrent_broadcast = FALSE;
    // flooding sequence number
    current_seq_no = 0;
    // measurement parameter
    radio_on_time = 0;
    return SUCCESS;
  }
/**
 * upper layer start radio duty cycling
 **/
  command void ChaseControl.dc_start() {
    radio_state = DUTY_CYCLE_IDL;
    call RxSet.set();
    call TxSet.set();
    post radio_start();
  }
/**
 * radio is opened, then either signal detect or packet send, signal upper layer
 **/
  event void RadioControl.startDone(error_t err) {
    if (radio_state == DUTY_CYCLE_OFF) { return; }

    // int debug_i = 0;
    if (err == SUCCESS) {
      call Leds.led0On();
      time_count = call LocalTime.get();
      if (radio_state == DUTY_CYCLE_IDL) {
        radio_state = DUTY_CYCLE_DET;
/**
 * debug
 **
        cc2420_spi_init();
        pr("rssi: ");
        while (debug_i < 10) {
          if (call EnergyIndicator.isReceiving()) {
            int rssi_now = cc2420_get_rssi();
            pr("%d ", rssi_now);
          }
          debug_i++;
        }
        pr("\n");

        post radio_stop();
*/
        post signal_detect();
      } else if (radio_state == DUTY_CYCLE_SND) {
        post pkt_send_init();
      }
    } else {
      call RadioControl.start();
    }
    // signal upper layer duty cycle mode is started after the first radio init
    if (!dc_start_done) {
      if (err == SUCCESS) {
        dc_start_done = TRUE;
      }
      signal ChaseControl.dc_started(err);
    }
  }

  event void RadioControl.stopDone(error_t err) {
    if (radio_state == DUTY_CYCLE_OFF) { return; }

    if (err == SUCCESS) {
      if (!fast_reboot_after_fail) {
      #ifdef CHASE_TAIL_TEST
        uint32_t time_now = call LocalTime.get();
        uint16_t time_h = time_now >> 16;
        uint16_t time_l = time_now & 0xFFFF;

        pr("radio %u %u\n", time_h, time_l);
      #ifndef ENABLE_PR
        if (serial_enable) {
          chase_tail_msg_t* p = (chase_tail_msg_t*)call TailPacket.getPayload(&tail_pkt, sizeof(chase_tail_msg_t));
          if (tail_send_lock) {
            return;
          }
          p->nodeid = TOS_NODE_ID;
          p->seq_no = pre_seq_no;
          p->tail_time_h = tail_time_h;
          p->tail_time_l = tail_time_l;
          if (call TailSend.send(AM_BROADCAST_ADDR, &tail_pkt, sizeof(chase_tail_msg_t)) == SUCCESS) {
            tail_send_lock=TRUE;
          }
        }
      #endif
      #endif
        call Leds.led0Off();
        radio_on_time += call LocalTime.get() - time_count;
        // pr("radio_on_time: %u\n", radio_on_time);
        call sleepTimer.startOneShot(sleep_interval);
      } else {
        fast_reboot_after_fail = FALSE;
        call RadioControl.start();
      }
    } else {
      post radio_stop();
    }
  }
/**
 * upper layer initialize a flood process, set the pending buffer as the packet
 **/
  command error_t ChaseFlood.init_flood(message_t* pkt, uint8_t pkt_len, uint8_t* payload) {
    if (radio_state == DUTY_CYCLE_IDL) {
      radio_state = DUTY_CYCLE_SND;
      post radio_start();
    } else if ((radio_state == DUTY_CYCLE_DET) || (radio_state == DUTY_CYCLE_LIS)) {
      radio_state = DUTY_CYCLE_SND;
      call delayTimer.stop();
      post pkt_send_init();
    } else {
      return EBUSY;
    }
    // assign the memory buffer and payload len
    buf = pkt;
    len = pkt_len;
    buf_pending = TRUE;
    return SUCCESS;
  }
/**
 * packet payload pointer
 **/
  command uint8_t* ChasePacket.getPayload(message_t* pkt, uint8_t pkt_len) {
    if (TOSH_DATA_LENGTH - CC2420_SIZE - sizeof(chase_header_t) < pkt_len) {
      return NULL;
    }
    return ((uint8_t*)pkt->data)+sizeof(chase_header_t);
  }
/**
 * delay measurement
 **/
  command uint32_t ChaseDelay.getTime() {
    uint32_t time_now = call LocalTime.get();
    return time_now;
  }
/**
 * energy (i.e., duty cycle) measurement
 **/
  command uint32_t ChaseEnergy.getRadioOnTime() {
    return radio_on_time;
  }
/**
 * receive a flooding packet, check duplicate and set the pending buffer
 **/
  event message_t* subReceive.receive(message_t* pkt, void* payload, uint8_t pkt_len) {
    chase_header_t* pkt_hdr = (chase_header_t*)payload;

    bool tree_sender = FALSE;
    bool shortcut_sender = FALSE;
    bool long_link_sender = FALSE;

    if (radio_state == DUTY_CYCLE_OFF) {
        pr("pkt reced!\n");
        return pkt;
    }

    // stop watch dog timer
    call delayTimer.stop();
    call Leds.led2Off();

    if ((radio_state == DUTY_CYCLE_DET) || (radio_state == DUTY_CYCLE_LIS)) {
      radio_state = DUTY_CYCLE_REC;
      call DisableRx.disableRx();
      CC2420_FIFOP_DISABLE();
    } else if (radio_state != DUTY_CYCLE_REC) {
      return pkt;
    }

    if (buf_reced_or_snd) {
      if ( (pre_src_id == pkt_hdr->src_id) && (!(pre_seq_no < pkt_hdr->seq_no)) ) {
        // duplicate flooding packet, drop and go back to sleep
        if (buf_pending) {
          radio_state = DUTY_CYCLE_SND;
          post pkt_send();
        } else {
          post radio_stop();
        }
        return pkt;
      }
    }

    buf_reced_or_snd = TRUE;
    serial_enable = TRUE;

    pre_src_id = pkt_hdr->src_id;
    pre_seq_no = pkt_hdr->seq_no;

    delay.src_id = pkt_hdr->src_id;
    delay.seq_no = pkt_hdr->seq_no;
    delay.last_hop_id = pkt_hdr->fwd_id;
    delay.per_hop_delay_h = pkt_hdr->fwd_time_h;
    delay.per_hop_delay_l = pkt_hdr->fwd_time_l;

    if (long_link_oppo(pkt_hdr)) {
      long_link_sender = TRUE;
      delay.long_link_sender = 1;
    } else {
      delay.long_link_sender = 0;
    }

    if (shortcut_path_oppo(pkt_hdr)) {
      shortcut_sender = TRUE;
      delay.shortcut_sender = 1;
    } else {
      delay.shortcut_sender = 0;
    }

    if (call TreeInfo.isSender()) {
      tree_sender = TRUE;
      delay.tree_sender = 1;
    } else {
      delay.tree_sender = 0;
    }

    signal ChaseDelay.getDelay(&delay);

    // COFlood code, set the senders: half, quarter and one-eighth
    /* 50 senders */
    // if ( (TOS_NODE_ID % 6 == 0) && (TOS_NODE_ID != 66) && (TOS_NODE_ID != 120) && (TOS_NODE_ID != 12) && (TOS_NODE_ID != 78) ) {
    /* 40 senders */
    // if ( ((TOS_NODE_ID % 4 == 0) && (TOS_NODE_ID != 120) && (TOS_NODE_ID != 56) && (TOS_NODE_ID != 20) && (TOS_NODE_ID != 40) && (TOS_NODE_ID != 64) && (TOS_NODE_ID != 80) && (TOS_NODE_ID != 8)) || (TOS_NODE_ID == 123) || (TOS_NODE_ID == 127) || (TOS_NODE_ID == 53) || (TOS_NODE_ID == 71) ) {
    /* 30 senders */
    // if ( ((TOS_NODE_ID % 4 == 0) || (TOS_NODE_ID % 3 == 0)) && (TOS_NODE_ID != 120) && (TOS_NODE_ID != 63) && (TOS_NODE_ID != 66) && (TOS_NODE_ID != 69) && (TOS_NODE_ID != 129) && (TOS_NODE_ID != 20) && (TOS_NODE_ID != 40) && (TOS_NODE_ID != 56) && (TOS_NODE_ID != 64) && (TOS_NODE_ID != 80) && (TOS_NODE_ID != 8) ) {
    /* 20 senders */
    /* if (
         (TOS_NODE_ID != 8) &&
         (TOS_NODE_ID != 10) &&
         (TOS_NODE_ID != 11) &&
         (TOS_NODE_ID != 13) &&
         (TOS_NODE_ID != 20) &&
         (TOS_NODE_ID != 37) &&
         (TOS_NODE_ID != 40) &&
         (TOS_NODE_ID != 41) &&
         (TOS_NODE_ID != 43) &&
         (TOS_NODE_ID != 50) &&
         (TOS_NODE_ID != 56) &&
         (TOS_NODE_ID != 63) &&
         (TOS_NODE_ID != 64) &&
         (TOS_NODE_ID != 66) &&
         (TOS_NODE_ID != 69) &&
         (TOS_NODE_ID != 70) &&
         (TOS_NODE_ID != 77) &&
         (TOS_NODE_ID != 80) &&
         (TOS_NODE_ID != 119) &&
         (TOS_NODE_ID != 120) &&
         (TOS_NODE_ID != 122) &&
         (TOS_NODE_ID != 129)
       ) { */
    if ( !(
    // Long Link
         long_link_sender ||
    // Shortcut Path
         // shortcut_sender ||
    // Flooding Tree
         tree_sender
         )
       ) {
      if (buf_pending) {
        radio_state = DUTY_CYCLE_SND;
        post pkt_send();
      } else {
        post radio_stop();
      }
      return pkt;
    }

    buf = pkt;
    pkt_hdr->fwd_id = TOS_NODE_ID;
    set_start_time(pkt_hdr);
    set_fwd_time(pkt_hdr);
    set_local_delay(pkt_hdr);
    len = pkt_len - sizeof(chase_header_t);
    buf_pending = TRUE;

    radio_state = DUTY_CYCLE_SND;
    send_done = FALSE;
#ifdef LONG_PREAMBLE
    call delayTimer.startOneShot(sleep_interval*PREAMBLE_FACTOR + 20);
#else
    if (call TreeInfo.getWeight() == 10) {
      call delayTimer.startOneShot(sleep_interval + 20);
    } else {
      call delayTimer.startOneShot(2*sleep_interval + 20);
    }
#endif
    post pkt_send();

    // for debug, directly terminate the radio
    // post radio_stop();

    return (signal ChaseFlood.pkt_reced(pkt, len, ((uint8_t*)payload)+sizeof(chase_header_t)));
  }
/**
 * a preamble packet is done
 **/
  async event void subSend.sendDone(message_t* pkt, error_t err) {
    if (radio_state == DUTY_CYCLE_OFF) { return; }

    // return to RxOn state, need disable Rx again
    call DisableRx.disableRx();
    CC2420_FIFOP_DISABLE();

    if (err != SUCCESS) {
      if (!send_done) {
        post pkt_send();
      } else {
        buf = NULL;
        buf_pending = FALSE;

        radio_state = DUTY_CYCLE_LIS;
        signal ChaseListen.reboot_rec();
        CC2420_FIFOP_ENABLE();
        call DisableRx.enableRx();
        concurrent_broadcast = FALSE;
        call delayTimer.startOneShot(listen_tail);
      }
      return;
    }

    if (!send_done) {
      post start_rand_ippi();
    } else {
      call Leds.led1Off();

      buf = NULL;
      buf_pending = FALSE;

      radio_state = DUTY_CYCLE_LIS;
      signal ChaseListen.reboot_rec();
      CC2420_FIFOP_ENABLE();
      call DisableRx.enableRx();
      call delayTimer.startOneShot(listen_tail);
      concurrent_broadcast = FALSE;

      // snd_time = call LocalTime.get() - snd_time;
      // pr("send time %u!\n", snd_time);
    }
  }
/**
 * sleep ends, start signal detect
 **/
  event void sleepTimer.fired() {
    if ( radio_state == DUTY_CYCLE_IDL )
      post radio_start();
  }
/**
 * listen ends, turn off radio
 **/
  event void delayTimer.fired() {
    atomic {
      if ( radio_state == DUTY_CYCLE_LIS ) {
        if (rssi_mark) {
        #ifdef DEBUG_PR
          pr("rssi mark error\n");
        #endif
        #ifdef CHASE_TAIL_TEST
          // pr("rssi mark error\n");
        #endif
          // something bad happened here
          post radio_stop();
          return;
        }
        if (concurrent_broadcast) {
        #ifdef DEBUG_PR
          pr("tail extend\n");
        #endif
          call delayTimer.startOneShot(listen_tail);
          concurrent_broadcast = FALSE;
          post signal_classify();
        } else {
          post radio_stop();
        }
      } else if ( radio_state == DUTY_CYCLE_SND ) {
      #ifdef DEBUG_PR
        pr("end of preamble\n");
      #endif
        send_done = TRUE;
      } else if ( radio_state == DUTY_CYCLE_REC ) {
        call Leds.led2On();
      #ifdef DEBUG_PR
        pr("start channel sampling\n");
      #endif
        // sth bad happen, no packet received within watch_dog_time, restart listen and reboot rec
        radio_state = DUTY_CYCLE_LIS;
        signal ChaseListen.reboot_rec();
        call DisableRx.enableRx();
        CC2420_FIFOP_ENABLE();
        call delayTimer.startOneShot(listen_tail);
        concurrent_broadcast = FALSE;
        post signal_classify();
      }
    }
  }
/**
 * start to resend preamble packet
 **/
  event void randTimer.fired() {
    if (radio_state == DUTY_CYCLE_SND) {
      post pkt_resend();
    }
  }
/**
 * implementation tasks
 **/
  task void radio_start() {
    serial_enable = FALSE;
    #ifdef CHASE_TAIL_TEST
    if (!fast_reboot_after_fail) {
      uint32_t time_now = call LocalTime.get();
      uint16_t time_h = time_now >> 16;
      uint16_t time_l = time_now & 0xFFFF;

      pr("radio %u %u\n", time_h, time_l);
    #ifndef ENABLE_PR
    /*
      {
        chase_tail_msg_t* p = (chase_tail_msg_t*)call TailPacket.getPayload(&tail_pkt, sizeof(chase_tail_msg_t));
        if (tail_send_lock) {
          return;
        }
        p->nodeid = TOS_NODE_ID;
        p->tail_time_h = time_h;
        p->tail_time_l = time_l;
        if (call TailSend.send(AM_BROADCAST_ADDR, &tail_pkt, sizeof(chase_tail_msg_t)) == SUCCESS) {
          tail_send_lock=TRUE;
        }
      }
    */
      tail_time_h = time_h;
      tail_time_l = time_l;
    #endif
    }
    #endif
    atomic {
      fast_reboot_after_fail = FALSE;
      call RadioControl.start();
    }
  }

  task void radio_stop() {
    atomic {
      // if any packet is still left, finish the buffer swapping first
      if (call PacketIndicator.isReceiving()) {
        radio_state = DUTY_CYCLE_REC;
        call DisableRx.disableRx();
        CC2420_FIFOP_DISABLE();
        call delayTimer.startOneShot(watch_dog_time);
        return;
      }
      // set radio as idle, stop timers and enable FIFOP
      radio_state = DUTY_CYCLE_IDL;
      signal ChaseListen.reboot_rec();
      CC2420_FIFOP_ENABLE();
      call delayTimer.stop();
      call randTimer.stop();
      call RadioControl.stop();
    }
  }

  task void signal_detect() {
    atomic {
      uint16_t signal_detected = 1;
      uint16_t i = 0;

      if (radio_state != DUTY_CYCLE_DET) {
        post radio_stop();
        return;
      }

      if (call PacketIndicator.isReceiving()) {
        radio_state = DUTY_CYCLE_REC;
        call DisableRx.disableRx();
        CC2420_FIFOP_DISABLE();
        call delayTimer.startOneShot(watch_dog_time);
        return;
      }

      for ( ; i < max_cca_checks; i++) {
        if (call EnergyIndicator.isReceiving()) {
          signal_detected++;
          if (signal_detected > min_samples_required) {
            if ((P1IFG & (1 << 0)) && call FIFO.get()) {
              radio_state = DUTY_CYCLE_REC;
              call DisableRx.disableRx();
              CC2420_FIFOP_DISABLE();
              call delayTimer.startOneShot(watch_dog_time);
              post cc2420_begin_rec();
              return;
            } else {
            #ifdef DEBUG_PR
              pr("signal is detected\n");
            #endif
              radio_state = DUTY_CYCLE_LIS;
              call delayTimer.startOneShot(listen_tail);
              concurrent_broadcast = FALSE;
              post signal_classify();
            }
            return;
          }
        }
      }

      /**
       * debug
       **
      radio_state = DUTY_CYCLE_LIS;
      concurrent_broadcast = FALSE;
      call delayTimer.startOneShot(listen_tail);
      post signal_classify();
      // debug end */

      post radio_stop();
    }
  }

  task void signal_classify() {
    atomic {
      uint16_t i;
      uint16_t invalid_counter = 0;

      debug_time = call LocalTime.get();

      if (radio_state != DUTY_CYCLE_LIS) {
      #ifdef DEBUG_PR
        pr("lis state error\n");
      #endif
        // something smell bad here, radio stop
        post radio_stop();
        return;
      }

      if (call PacketIndicator.isReceiving() || call ArbiterInfo.inUse()) {
      #ifdef DEBUG_PR
        pr("packet is reced\n");
      #endif
        radio_state = DUTY_CYCLE_REC;
        call DisableRx.disableRx();
        CC2420_FIFOP_DISABLE();
        call delayTimer.startOneShot(watch_dog_time);
        return;
      }

      // continously RSSI reading
      cc2420_spi_init();
      // wait valid rssi sampling
      while ((strobe(CC2420_SNOP) & CC2420_STATUS_RSSI_VALID) == 0) {
        invalid_counter++;
        if (invalid_counter > 22) {
        #ifdef DEBUG_PR
          pr("invalid rssi\n");
        #endif
        #ifdef CHASE_TAIL_TEST
          // pr("invalid rssi\n");
        #endif
          fast_reboot_after_fail = TRUE;
          return;
        }
      }

      rssi_mark = TRUE;
    #ifdef DEBUG_PR
      pr("start sample rssi\n");
    #endif

      for (i = 0 ; i < RSSI_SAMPLES_NUM; i++) {
        if ((P1IFG & (1 << 0)) && call FIFO.get()) {
          rssi_mark = FALSE;
          radio_state = DUTY_CYCLE_REC;
          call DisableRx.disableRx();
          CC2420_FIFOP_DISABLE();
          call delayTimer.startOneShot(watch_dog_time);
          post cc2420_begin_rec();
          return;
        }
        rssi_seq[i] = cc2420_get_rssi();
      }

      rssi_mark = FALSE;

      detect_concurrent_broadcast();

      debug_time = call LocalTime.get() - debug_time;
    #ifdef DEBUG_PR
      pr("classify time: %u\n", debug_time);
    #endif
    }
  }

  task void pkt_send_init() {
    atomic {
      if (call PacketIndicator.isReceiving()) {
        radio_state = DUTY_CYCLE_REC;
        call DisableRx.disableRx();
        CC2420_FIFOP_DISABLE();
        call delayTimer.startOneShot(watch_dog_time);
        return;
      }

      if (!buf_pending) { return; }

      call DisableRx.disableRx();
      CC2420_FIFOP_DISABLE();

      set_pkt_header();

      send_done = FALSE;
#ifdef LONG_PREAMBLE
      call delayTimer.startOneShot(sleep_interval*PREAMBLE_FACTOR + 20);
#else
      if (call TreeInfo.getWeight() == 10) {
        call delayTimer.startOneShot(sleep_interval + 20);
      } else {
        call delayTimer.startOneShot(2*sleep_interval + 20);
      }
#endif
      // snd_time = call LocalTime.get();

      post pkt_send();
    }
  }

  task void pkt_send() {
    call Leds.led1On();
    if (!call delayTimer.isRunning()) {
      call Leds.led2On();
#ifdef LONG_PREAMBLE
      call delayTimer.startOneShot(sleep_interval*PREAMBLE_FACTOR + 20);
#else
      if (call TreeInfo.getWeight() == 10) {
        call delayTimer.startOneShot(sleep_interval + 20);
      } else {
        call delayTimer.startOneShot(2*sleep_interval + 20);
      }
#endif
      post pkt_send();
    } else if (call subSend.send(buf, FALSE) != SUCCESS) {
      post pkt_send();
    }
  }

  task void pkt_resend() {
    atomic {
      chase_header_t* pkt_hdr = (chase_header_t*)buf->data;
      set_fwd_time(pkt_hdr);
      if (!call ArbiterInfo.inUse()) {
        cc2420_spi_init();
        write_ram(CC2420_RAM_TXFIFO, sizeof(cc2420_header_t)+sizeof(chase_header_t)-4, ((uint8_t*)pkt_hdr)+sizeof(chase_header_t)-4, 4);
      }
    }
    if (call subSend.resend(FALSE) != SUCCESS) {
      post pkt_resend();
    }
  }

  task void cc2420_begin_rec() {
    signal ChaseListen.begin_rec();
  }

  task void start_rand_ippi() {
    uint16_t ippi_interval = fixed_ippi_interval + (call Random.rand16() % random_ippi_interval);
    call randTimer.startOneShot(ippi_interval);
  }

  static inline void set_pkt_header() {
    cc2420_header_t* cc2420_hdr = (cc2420_header_t*)(((uint8_t*)buf->data) - sizeof(cc2420_header_t));
    chase_header_t* pkt_hdr = (chase_header_t*)buf->data;
    uint8_t pkt_len = CC2420_SIZE + sizeof(chase_header_t) + len;

    cc2420_hdr->length = pkt_len;
    cc2420_hdr->type = 0x22;
    cc2420_hdr->src = TOS_NODE_ID;
    cc2420_hdr->dest = 0xFFFF;
    cc2420_hdr->fcf = ( 1 << IEEE154_FCF_INTRAPAN ) |
                  ( IEEE154_TYPE_DATA << IEEE154_FCF_FRAME_TYPE ) |
                  ( IEEE154_ADDR_SHORT << IEEE154_FCF_DEST_ADDR_MODE ) |
                  ( IEEE154_ADDR_SHORT << IEEE154_FCF_SRC_ADDR_MODE );

    pkt_hdr->src_id = TOS_NODE_ID;
    pkt_hdr->seq_no = current_seq_no++;
    pkt_hdr->fwd_id = TOS_NODE_ID;
    set_start_time(pkt_hdr);
    set_fwd_time(pkt_hdr);
    set_local_delay(pkt_hdr);

    pre_src_id = TOS_NODE_ID;
    pre_seq_no = current_seq_no;
    buf_reced_or_snd = TRUE;
  }

  static inline void set_start_time(chase_header_t* hdr) {
    uint32_t start_time = call LocalTime.get();
    hdr->start_time_h = start_time >> 16;
    hdr->start_time_l = start_time;
  }

  static inline void set_fwd_time(chase_header_t* hdr) {
    uint32_t fwd_time = call LocalTime.get();
    hdr->fwd_time_h = fwd_time >> 16;
    hdr->fwd_time_l = fwd_time;
  }

  static inline void set_local_delay(chase_header_t* hdr) {
    hdr->local_delay = call TreeInfo.getDelay();
  }

  static inline void detect_concurrent_broadcast() {
    int noisy_floor = 127;
    uint16_t i = 0;
    uint16_t min_on_air_time = 255;
    uint16_t max_on_air_time = 0;
    uint16_t tmp_on_air_time = 0;
    uint16_t high_rssi_counter = 0;
    bool detect_raising_edge = TRUE;
    bool front_high = FALSE;

    for ( ; i < RSSI_SAMPLES_NUM; i++) {
      if (rssi_seq[i] < noisy_floor) {
        noisy_floor = rssi_seq[i];
      }
      if (rssi_seq[i] > -85) {
        high_rssi_counter++;
      }
    }

    if (noisy_floor > 0) {
    #ifdef DEBUG_PR
      pr("noisy floor error %d\n", noisy_floor);
    #endif
      // something smell bad, exceed the maximum tx power
      return;
    }

    if (noisy_floor > -85 || high_rssi_counter > 22) {
    #ifdef DEBUG_PR
      pr("high noisy floor %d\n", noisy_floor);
    #endif
      concurrent_broadcast = TRUE;
      return;
    }

    // if (ABS_VLAUE(noisy_floor, rssi_seq[0]) > 3) { }

    for (i = 0; i < RSSI_SAMPLES_NUM; i++) {
      if (ABS_VALUE(noisy_floor, rssi_seq[i]) > 3) {
        if (detect_raising_edge) {
          detect_raising_edge = FALSE;
          tmp_on_air_time = 1;
          front_high = TRUE;
        } else if (front_high) {
          tmp_on_air_time++;
        }
      } else {
        if (!detect_raising_edge) {
          detect_raising_edge = TRUE;
          front_high = FALSE;
          // minimum on-air time is 608us, filter invalid packet
          if (tmp_on_air_time > 7) {
            if (tmp_on_air_time > max_on_air_time) {
              max_on_air_time = tmp_on_air_time;
            }
            if (tmp_on_air_time < min_on_air_time) {
              min_on_air_time = tmp_on_air_time;
            }
          }
        }
      }
    }

    if (max_on_air_time > min_on_air_time + 2) {
    #ifdef DEBUG_PR
      pr("max diff on-air time %d %d\n", max_on_air_time, min_on_air_time);
    #endif
      concurrent_broadcast = TRUE;
    }

    if ((P1IFG & (1 << 0)) && call FIFO.get()) {
      radio_state = DUTY_CYCLE_REC;
      call DisableRx.disableRx();
      CC2420_FIFOP_DISABLE();
      call delayTimer.startOneShot(watch_dog_time);
      post cc2420_begin_rec();
    }
  }

static inline bool long_link_oppo(chase_header_t* hdr) {
  bool snd = FALSE;

  uint16_t local_delay = call TreeInfo.getDelay();

  if (local_delay > hdr->local_delay) {
    uint16_t delta = local_delay - hdr->local_delay;
    if (delta > LONG_LINK_THRE) {
      snd = TRUE;
    }
    delay.parent_ETD = hdr->local_delay;
    delay.local_ETD = call TreeInfo.getDelay();
    delay.delta_ETD = delta;
  } else {
    delay.parent_ETD = hdr->local_delay;
    delay.local_ETD = call TreeInfo.getDelay();
    delay.delta_ETD = 0xFFFF;
  }

  return snd;
}

static inline bool shortcut_path_oppo(chase_header_t* hdr) {
  bool snd = FALSE;
  uint32_t start_time = hdr->start_time_h;
  uint32_t fwd_time = hdr->fwd_time_h;

  start_time = (start_time << 16) + hdr->start_time_l;
  fwd_time = (fwd_time << 16) + hdr->fwd_time_l;

  if (fwd_time > start_time) {
    uint16_t delta = (uint16_t)(fwd_time - start_time);
    if (delta < SHORTCUT_PATH_THRE) {
      uint16_t rnd = SHORTCUT_PATH_THRE - (call Random.rand16() % SHORTCUT_PATH_THRE);
      if (delta < rnd) {
        snd = TRUE;
      }
    }
    delay.MPD = delta;
  } else {
    delay.MPD = 0xFFFF;
  }

  return snd;
}

/**
 * Tail time serial sendDone
 **/
#ifdef CHASE_TAIL_TEST
  event void TailSend.sendDone(message_t* pkt, error_t error) {
    if (&tail_pkt == pkt) {
      tail_send_lock = FALSE;
    }
  }
#endif
/**
 * default event handler
 **/
  default event message_t* ChaseFlood.pkt_reced(message_t* msg, uint8_t pkt_len, uint8_t* payload) { }
  default event void ChaseListen.begin_rec() { }
  default event void ChaseControl.dc_started(error_t err) {}
}
