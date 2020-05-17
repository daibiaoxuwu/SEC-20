#include "pr.h"
#include "TopologyTest.h"

#define NODE_NUMBER 150

module TopologyTestP {
    uses {
        interface Boot;
        interface SplitControl as RadioControl;
        interface SplitControl as SerialControl;
        interface AMSend as Speak;
        interface AMSend as SerialSend;
        interface Receive as Listen;
        interface Timer<TMilli> as ControlTimer;
        interface Timer<TMilli> as TxTimer;
        interface Timer<TMilli> as ReportTimer;
        interface Packet;
        interface Packet as ReportPkt;
        interface CC2420Packet;
        interface Leds;
    }
} implementation {
    message_t pkt;
    uint16_t delay_counter;
    uint8_t tx_counter;
    uint16_t neighbor[1000];
    uint8_t rssi[1000];
    uint16_t num;
    uint16_t pr_counter;

  task void probe_broadcast();

  event void Boot.booted() {
      delay_counter = TOS_NODE_ID;
      tx_counter = 10;
      num = 0;
      pr_counter = 0;
      call SerialControl.start();
  }

  event void SerialControl.startDone(error_t err) {
      if (err == SUCCESS) {
          call RadioControl.start();
      } else {
          call SerialControl.start();
      }
  }

  event void SerialControl.stopDone(error_t err) {
  }

  event void RadioControl.startDone(error_t err) {
      if (err == SUCCESS) {
          call ControlTimer.startOneShot(20*1024UL);
          call ReportTimer.startOneShot((NODE_NUMBER+40)*1024UL);
      } else {
          call RadioControl.start();
      }
  }

  event void RadioControl.stopDone(error_t err) {
  }

  event void ControlTimer.fired() {
      if (delay_counter == 0) {
          call Leds.led0On();
          post probe_broadcast();
      } else {
          delay_counter--;
          call ControlTimer.startOneShot(1024);
      }
  }

  event void TxTimer.fired() {
      call Leds.led1Toggle();
      post probe_broadcast();
  }

  event void ReportTimer.fired() {
#ifndef ENABLE_PR
      if (pr_counter < num) {
          topology_msg_t* ptr = (topology_msg_t*)call ReportPkt.getPayload(&pkt, sizeof(topology_msg_t));
          ptr->id = neighbor[pr_counter];
          ptr->rssi = rssi[pr_counter];
          ptr->src = TOS_NODE_ID;

          call SerialSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(topology_msg_t));
      }
#else
      if (pr_counter < num) {
          pr("%d %d %d\n", pr_counter, neighbor[pr_counter], rssi[pr_counter]);
          pr_counter++;
          call ReportTimer.startOneShot(7);
      }
#endif
  }

  event message_t* Listen.receive(message_t* buf, void* payload, uint8_t len) {
      topology_msg_t* ptr = (topology_msg_t*)payload;
      rssi[num] = call CC2420Packet.getRssi(buf);
      neighbor[num] = ptr->id;
      num++;

      return buf;
  }

  event void Speak.sendDone(message_t* buf, error_t err) {
      if (tx_counter != 1) {
          call TxTimer.startOneShot(52);
          tx_counter--;
      }
  }

  event void SerialSend.sendDone(message_t* buf, error_t err) {
      pr_counter++;
      call ReportTimer.startOneShot(7);
  }

  task void probe_broadcast() {
      topology_msg_t* ptr = (topology_msg_t*)call Packet.getPayload(&pkt, sizeof(topology_msg_t));
      if (ptr == NULL) { return; }

      ptr->id = TOS_NODE_ID;
      call Speak.send(AM_BROADCAST_ADDR, &pkt, sizeof(topology_msg_t));
  }
}
