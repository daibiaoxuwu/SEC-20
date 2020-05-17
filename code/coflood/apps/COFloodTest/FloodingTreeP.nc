#include "pr.h"
#include "COFloodTest.h"

#define NODE_NUMBER 150
#define BEACON_INTERVAL 22
#define LINK_QUALITY_THRESHOLD 7
#define EBW_THRESHOLD 0

module FloodingTreeP {
    provides {
        interface Init;
        interface TreeInit;
        interface TreeInfo;
    }
    uses {
        interface AMSend as Speak;
        interface Receive as Listen;
        interface AMSend as TreeTx;
        interface Receive as TreeRx;
        interface Timer<TMilli> as ControlTimer;
        interface Timer<TMilli> as TxTimer;
        interface Timer<TMilli> as TopoTimer;
        interface Timer<TMilli> as TreeInitTimer;
        interface Packet as LinkPkt;
        interface Packet as TreePkt;

        interface AMSend as SerialTx;
        interface Packet as SerialPkt;

        interface Random;

        interface Leds;
    }
} implementation {
    message_t pkt;
    uint16_t delay_counter;
    uint8_t tx_counter;
    uint8_t beacon_counter;
    uint8_t rand_time;
    uint8_t tail_time_remaining;

    neighbor_table_t table;
    // local broadcast / neighbor number * 100
    uint16_t my_ebw;
    // path ebw
    uint16_t my_path_ebw;
    // parent node id
    uint16_t my_elder_id;
    // path delay
    uint16_t my_delay;
    uint16_t my_children_num;
    // local weight
    uint16_t my_weight;

    uint16_t root_id;
    bool is_sender;

  task void probe_broadcast();
  task void beacon_broadcast();
  task void neighbor_table_update();

  command uint16_t TreeInfo.getEBW() {
      return my_ebw;
  }

  command uint16_t TreeInfo.getPathEBW() {
      return my_path_ebw;
  }

  command uint16_t TreeInfo.getElderID() {
      return my_elder_id;
  }

  command uint16_t TreeInfo.getDelay() {
      return my_delay;
  }

  command uint16_t TreeInfo.getWeight() {
      return my_weight;
  }

  command uint16_t TreeInfo.getChildrenNum() {
      if (table.neighbor_num == 0) {
          return 0;
      } else {
          uint8_t i;
          my_children_num = 0;
          for (i = 0; i < table.neighbor_num; i++) {
              if ((table.entries[i]).elder_id == TOS_NODE_ID) {
                  my_children_num++;
              }
          }
      }
      return my_children_num;
  }

  command error_t Init.init() {
      delay_counter = TOS_NODE_ID;
      tx_counter = 10;
      beacon_counter = 20;
      table.neighbor_num = 0;
      my_path_ebw = 0xFFFF;
      // my_ebw = EBW_THRESHOLD + 1;
      my_ebw = 1000;
      is_sender = FALSE;
      root_id = 3;
      return SUCCESS;
  }

  command void TreeInit.start() {
      rand_time = (call Random.rand16()) % BEACON_INTERVAL;
      tail_time_remaining = BEACON_INTERVAL - rand_time;

      call ControlTimer.startOneShot(20*1024UL);
      call TopoTimer.startOneShot((NODE_NUMBER+40)*1024UL);
  }

  command bool TreeInfo.isSender() {
      return is_sender;
  }

  event void ControlTimer.fired() {
      if (delay_counter == 0) {
          post probe_broadcast();
      } else {
          delay_counter--;
          call ControlTimer.startOneShot(1024);
      }
  }

  event void TxTimer.fired() {
      post probe_broadcast();
  }

  event void TopoTimer.fired() {
      neighbor_msg_t* ptr = (neighbor_msg_t*)call SerialPkt.getPayload(&pkt, sizeof(neighbor_msg_t));
      uint8_t i;

      // for (i = 0; i < 22; i++) {
      //     ptr->id[i] = 0;
      //     ptr->reced[i] = 0;
      // }

      if (table.neighbor_num > 0) {
          // for (i = 0; i < table.neighbor_num; i++) {
          //     ptr->id[i] = (table.entries[i]).id;
          //     ptr->reced[i] = (table.entries[i]).reced;
          // }

          ptr->neighbor_num = table.neighbor_num;
          ptr->addr = TOS_NODE_ID;

          ptr->neighbor0 = (table.entries[0]).id;
          ptr->neighbor1 = (table.entries[1]).id;
          ptr->neighbor2 = (table.entries[2]).id;
          ptr->neighbor3 = (table.entries[3]).id;
          ptr->neighbor4 = (table.entries[4]).id;
          ptr->neighbor5 = (table.entries[5]).id;
          ptr->neighbor6 = (table.entries[6]).id;
          ptr->neighbor7 = (table.entries[7]).id;
          ptr->neighbor8 = (table.entries[8]).id;
          ptr->neighbor9 = (table.entries[9]).id;
          ptr->neighbor10 = (table.entries[10]).id;
          ptr->neighbor11 = (table.entries[11]).id;
          ptr->neighbor12 = (table.entries[12]).id;
          ptr->neighbor13 = (table.entries[13]).id;

          ptr->reced0 = (table.entries[0]).reced;
          ptr->reced1 = (table.entries[1]).reced;
          ptr->reced2 = (table.entries[2]).reced;
          ptr->reced3 = (table.entries[3]).reced;
          ptr->reced4 = (table.entries[4]).reced;
          ptr->reced5 = (table.entries[5]).reced;
          ptr->reced6 = (table.entries[6]).reced;
          ptr->reced7 = (table.entries[7]).reced;
          ptr->reced8 = (table.entries[8]).reced;
          ptr->reced9 = (table.entries[9]).reced;
          ptr->reced10 = (table.entries[10]).reced;
          ptr->reced11 = (table.entries[11]).reced;
          ptr->reced12 = (table.entries[12]).reced;
          ptr->reced13 = (table.entries[13]).reced;

          call SerialTx.send(AM_BROADCAST_ADDR, &pkt, sizeof(neighbor_msg_t));
      }
  }

  event void TreeInitTimer.fired() {
      if (beacon_counter == 0) {
          uint8_t i;
          for (i = 0; i < table.neighbor_num; i++) {
              if ((table.entries[i]).elder_id == TOS_NODE_ID) {
                  is_sender = TRUE;
                  break;
              }
          }

          signal TreeInit.startDone();
          return;
      }
      post beacon_broadcast();
  }

  event message_t* Listen.receive(message_t* buf, void* payload, uint8_t len) {
      tree_beacon_msg_t* ptr = (tree_beacon_msg_t*)payload;
      uint8_t i;

      for (i = 0; i < table.neighbor_num; i++) {
          if ((table.entries[i]).id == ptr->id) {
              (table.entries[i]).reced++;
              // pr("id %d reced %d\n", ptr->id, (table.entries[i]).reced);
              return buf;
          }
      }

      if (i == table.neighbor_num) {
          table.neighbor_num++;
          (table.entries[i]).id = ptr->id;
          (table.entries[i]).path_ebw = ptr->path_ebw;
          (table.entries[i]).ebw = 0;
          (table.entries[i]).reced = 1;
      }

      // pr("id %d neighbor# %d\n", ptr->id, table.neighbor_num);

      return buf;
  }

  event message_t* TreeRx.receive(message_t* buf, void* payload, uint8_t len) {
      tree_beacon_msg_t* ptr = (tree_beacon_msg_t*)payload;
      uint8_t i;

      for (i = 0; i < table.neighbor_num; i++) {
          if ((table.entries[i]).id == ptr->id) {
              (table.entries[i]).ebw = ptr->ebw;
              (table.entries[i]).path_ebw = ptr->path_ebw;
              (table.entries[i]).elder_id = ptr->elder_id;
              (table.entries[i]).delay = ptr->delay;
              break;
          }
      }
/*
      if (i == table.neighbor_num) {
          (table.entries[i]).id = ptr->id;
          (table.entries[i]).ebw = ptr->ebw;
          (table.entries[i]).path_ebw = ptr->path_ebw;
          (table.entries[i]).elder_id = ptr->elder_id;
          (table.entries[i]).delay = ptr->delay;

          table.neighbor_num++;
      }
*/
      if (i == table.neighbor_num) { return buf; }

      if (TOS_NODE_ID != root_id) {
          post neighbor_table_update();
      }
      return buf;
  }

  event void Speak.sendDone(message_t* buf, error_t err) {
      if (tx_counter != 1) {
          call TxTimer.startOneShot(52);
          tx_counter--;
      }
  }

  event void TreeTx.sendDone(message_t* buf, error_t err) {
      rand_time = (call Random.rand16()) % BEACON_INTERVAL;
      call TreeInitTimer.startOneShot((rand_time + tail_time_remaining) * 1024UL);
      tail_time_remaining = BEACON_INTERVAL - rand_time;
      beacon_counter--;
  }

  event void SerialTx.sendDone(message_t* buf, error_t err) {
      call TreeInitTimer.startOneShot(rand_time * 1024UL);
  }

  task void probe_broadcast() {
      tree_beacon_msg_t* ptr = (tree_beacon_msg_t*)call LinkPkt.getPayload(&pkt, sizeof(tree_beacon_msg_t));
      if (ptr == NULL) { return; }

      // pr("probe broadcast!\n");

      ptr->id = TOS_NODE_ID;
      ptr->path_ebw = my_path_ebw;

      call Speak.send(AM_BROADCAST_ADDR, &pkt, sizeof(tree_beacon_msg_t));
  }

  task void beacon_broadcast() {
      tree_beacon_msg_t* ptr = (tree_beacon_msg_t*)call TreePkt.getPayload(&pkt, sizeof(tree_beacon_msg_t));
      if (ptr == NULL) { return; }

      if (TOS_NODE_ID == root_id) {
        if (my_path_ebw == 0xFFFF) {
          uint16_t min_reced = 100;
          uint8_t i;
          uint8_t children = 0;

          for (i = 0; i < table.neighbor_num; i++) {
              if ((table.entries[i]).reced < LINK_QUALITY_THRESHOLD) { continue; }
              children++;
              if (min_reced > (table.entries[i]).reced) {
                  min_reced = (table.entries[i]).reced;
              }
          }

          if (children != 0) {
              my_ebw = 1000 / (min_reced * children);
              my_weight = 100 / min_reced;
              my_path_ebw = 0;
              my_elder_id = root_id;
              my_delay = 0;
          } else {
              return;
          }
        }
      } else {
        if (my_path_ebw == 0xFFFF) {
          call TreeInitTimer.startOneShot( BEACON_INTERVAL * 1024UL );
          return;
        } else {
          uint16_t min_reced = 100;
          uint8_t i;
          uint8_t children = 0;

          for (i = 0; i < table.neighbor_num; i++) {
              if ((table.entries[i]).reced < LINK_QUALITY_THRESHOLD) { continue; }
              if (my_path_ebw < (table.entries[i]).path_ebw) {
                  uint16_t delta_ebw = (table.entries[i]).path_ebw - my_path_ebw;
                  if (delta_ebw > EBW_THRESHOLD) {
                    children++;
                    if (min_reced > (table.entries[i]).reced) {
                        min_reced = (table.entries[i]).reced;
                    }
                  }
              }
          }

          if (children != 0) {
              my_ebw = 1000 / (min_reced * children);
              my_weight = 100 / min_reced;
          } else {
              my_ebw = 1000;
          }
        }
      }

      ptr->id = TOS_NODE_ID;
      ptr->ebw = my_ebw;
      ptr->path_ebw = my_path_ebw;
      ptr->elder_id = my_elder_id;
      ptr->delay = my_delay;
      call TreeTx.send(AM_BROADCAST_ADDR, &pkt, sizeof(tree_beacon_msg_t));
  }

  task void neighbor_table_update() {
      uint8_t i;
      uint16_t min_path_ebw = 0xFFFF;
      uint8_t elder_index = table.neighbor_num;

      for (i = 0; i < table.neighbor_num; i++) {
          uint16_t temp_path_ebw = (table.entries[i]).path_ebw + (table.entries[i]).ebw;

          if ((table.entries[i]).reced < LINK_QUALITY_THRESHOLD) { continue; }

          if (temp_path_ebw < min_path_ebw) {
              elder_index = i;
              min_path_ebw = temp_path_ebw;
          } else if ( (temp_path_ebw == min_path_ebw) && ((table.entries[i]).reced > (table.entries[elder_index]).reced) ) {
              elder_index = i;
              min_path_ebw = temp_path_ebw;
          }
      }

      if (elder_index == table.neighbor_num) { return; }

      my_path_ebw = min_path_ebw;
      my_elder_id = (table.entries[elder_index]).id;
      // my_delay = (table.entries[elder_index]).delay + 100 / (table.entries[elder_index]).reced;
      my_delay = (table.entries[elder_index]).delay + 100 / (table.entries[elder_index]).reced - 5;
  }
}
