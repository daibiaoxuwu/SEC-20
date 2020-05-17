#include "pr.h"
#include "ChaseTest.h"
#include "ChaseSerial.h"

module ChaseTestC {
  uses {
    interface ChaseFlood;
    interface ChaseControl;
    interface ChasePacket;
    interface Random;
    interface Timer<TMilli> as floodTimer;
    interface Boot;
    interface SplitControl as SerialControl;

    interface Timer<TMilli> as dcTimer;
    interface ChaseEnergy;
    interface ChaseDelay;

    interface Leds;
#ifndef ENABLE_PR
    interface AMSend as floodSerialSend;
    interface AMSend as delaySerialSend;
    interface AMSend as energySerialSend;
    interface Packet as floodSerialPkt;
    interface Packet as delaySerialPkt;
    interface Packet as energySerialPkt;
#endif
  }
} implementation {
  message_t flood_pkt;
  uint16_t seq_no = 0;

#ifndef ENABLE_PR
  message_t flood_serial_pkt;
  bool flood_send_lock = FALSE;
  message_t delay_serial_pkt;
  bool delay_send_lock = FALSE;
  message_t energy_serial_pkt;
  bool energy_send_lock = FALSE;
#endif

  event void Boot.booted() {
    call SerialControl.start();
  }

  event void SerialControl.startDone(error_t err) {
    pr("ChaseTest\n");
    if (err == SUCCESS) {
      call ChaseControl.dc_start();
    } else {
      call SerialControl.start();
    }
  }

  event void SerialControl.stopDone(error_t err) { }

  event void ChaseControl.dc_started(error_t err) {
    if (err == SUCCESS) {
      // choose sink node
      if (TOS_NODE_ID == 3)
        call floodTimer.startPeriodic(20480);
      call dcTimer.startPeriodic(61440UL);
    } else {
      call ChaseControl.dc_start();
    }
  }

  event void floodTimer.fired() {
    flood_payload_t* payload = (flood_payload_t*)call ChasePacket.getPayload(&flood_pkt, sizeof(flood_payload_t));

    if (payload == NULL) {
      pr("payload is null!\n");
      return;
    }

    memset((uint8_t*)payload, 0x77, sizeof(flood_payload_t));

    if (call ChaseFlood.init_flood(&flood_pkt, sizeof(flood_payload_t), (uint8_t*)payload) == SUCCESS) {
      uint32_t time_flood = call ChaseDelay.getTime();
      uint16_t time_flood_h = time_flood >> 16;
      uint16_t time_flood_l = time_flood & 0xFFFF;
      pr("flood %u %u %u\n", seq_no, time_flood_h, time_flood_l);
#ifndef ENABLE_PR
      {
          chase_flood_msg_t* p = (chase_flood_msg_t*)call floodSerialPkt.getPayload(&flood_serial_pkt, sizeof(chase_flood_msg_t));
          if (flood_send_lock) {
              return;
          }
          p->seq_no = seq_no;
          p->time_flood_h = time_flood_h;
          p->time_flood_l = time_flood_l;
          if (call floodSerialSend.send(AM_BROADCAST_ADDR, &flood_serial_pkt, sizeof(chase_flood_msg_t)) == SUCCESS) {
              flood_send_lock=TRUE;
          }
      }
#endif
      seq_no++;
    }
  }

  event message_t* ChaseFlood.pkt_reced(message_t* pkt, uint8_t len, uint8_t* payload) {
    // call Leds.led0Toggle();
    // pr("a flood packet is received!\n");
    return pkt;
  }

  event void ChaseDelay.getDelay(chase_delay_t* lay) {
    uint32_t time_rec = call ChaseDelay.getTime();
    uint16_t time_rec_h = time_rec >> 16;
    uint16_t time_rec_l = time_rec & 0xFFFF;
    uint16_t delay_h = lay->per_hop_delay_h;
    uint16_t delay_l = lay->per_hop_delay_l;

    pr("delay %u %u %u %u %u %u\n", lay->seq_no, lay->last_hop_id, time_rec_h, time_rec_l, delay_h, delay_l);
#ifndef ENABLE_PR
      {
          chase_delay_msg_t* p = (chase_delay_msg_t*)call delaySerialPkt.getPayload(&delay_serial_pkt, sizeof(chase_delay_msg_t));
          if (delay_send_lock) {
              return;
          }
          p->nodeid = TOS_NODE_ID;
          p->seq_no = lay->seq_no;
          p->src_id = lay->last_hop_id;
          p->rec_time_h = time_rec_h;
          p->rec_time_l = time_rec_l;
          p->hop_delay_h = delay_h;
          p->hop_delay_l = delay_l;
          if (call delaySerialSend.send(AM_BROADCAST_ADDR, &delay_serial_pkt, sizeof(chase_delay_msg_t)) == SUCCESS) {
              delay_send_lock=TRUE;
          }
      }
#endif
  }

  event void dcTimer.fired() {
    uint32_t time_now = call ChaseDelay.getTime();
    uint16_t time_now_h = time_now >> 16;
    uint16_t time_now_l = time_now & 0xFFFF;
    uint32_t radio_on_time = call ChaseEnergy.getRadioOnTime();
    uint16_t radio_on_time_h = radio_on_time >> 16;
    uint16_t radio_on_time_l = radio_on_time & 0xFFFF;

    pr("energy %u %u %u %u\n", time_now_h, time_now_l, radio_on_time_h, radio_on_time_l);
#ifndef ENABLE_PR
      {
          chase_energy_msg_t* p = (chase_energy_msg_t*)call floodSerialPkt.getPayload(&energy_serial_pkt, sizeof(chase_energy_msg_t));
          if (energy_send_lock) {
              return;
          }
          p->nodeid = TOS_NODE_ID;
          p->clock_time_h = time_now_h;
          p->clock_time_l = time_now_l;
          p->dc_time_h = radio_on_time_h;
          p->dc_time_l = radio_on_time_l;
          if (call energySerialSend.send(AM_BROADCAST_ADDR, &energy_serial_pkt, sizeof(chase_energy_msg_t)) == SUCCESS) {
              energy_send_lock=TRUE;
          }
      }
#endif
  }

#ifndef ENABLE_PR
  event void floodSerialSend.sendDone(message_t* pkt, error_t error) {
    if (&flood_serial_pkt == pkt) {
      flood_send_lock = FALSE;
    }
  }

  event void delaySerialSend.sendDone(message_t* pkt, error_t error) {
    if (&delay_serial_pkt == pkt) {
      delay_send_lock = FALSE;
    }
  }

  event void energySerialSend.sendDone(message_t* pkt, error_t error) {
    if (&energy_serial_pkt == pkt) {
      energy_send_lock = FALSE;
    }
  }
#endif
}
