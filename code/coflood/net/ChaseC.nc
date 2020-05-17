// Copyright : Zhichao Cao
// Modify Data : Mar 1, 2017

#include "Chase.h"

configuration ChaseC {
  provides {
    interface ChaseFlood;
    interface ChaseListen;
    interface ChaseControl;
    interface ChasePacket;
    interface ChaseDelay;
    interface ChaseEnergy;
  }
} implementation {
  components MainC;
  components CC2420CsmaC;
  components CC2420TransmitC;
  components CC2420ReceiveC;
  components Msp430UsartShare0P;
  components HplCC2420PinsC;
  components RandomC;

  components new TimerMilliC() as sleepTimer;
  components new TimerMilliC() as delayTimer;
  components new TimerMilliC() as randTimer;

  components HilTimerMilliC;
  components LedsC;

  components FloodingTreeC;

  components ChaseP;

  ChaseFlood = ChaseP;
  ChaseListen = ChaseP;
  ChaseControl = ChaseP;
  ChasePacket = ChaseP;
  ChaseDelay = ChaseP;
  ChaseEnergy = ChaseP;
  MainC.SoftwareInit -> ChaseP.Init;

  ChaseP.RxSet -> CC2420ReceiveC;
  ChaseP.TxSet -> CC2420CsmaC;
  ChaseP.RadioControl -> CC2420CsmaC;
  ChaseP.subReceive -> CC2420ReceiveC.ChaseReceive;
  ChaseP.subSend -> CC2420TransmitC;
  ChaseP.DisableRx -> CC2420TransmitC;
  ChaseP.PacketIndicator -> CC2420ReceiveC.PacketIndicator;
  ChaseP.EnergyIndicator -> CC2420TransmitC.EnergyIndicator;
  ChaseP.FIFO -> HplCC2420PinsC.FIFO;
  ChaseP.ArbiterInfo -> Msp430UsartShare0P;
  ChaseP.delayTimer -> delayTimer;
  ChaseP.sleepTimer -> sleepTimer;
  ChaseP.randTimer -> randTimer;
  ChaseP.Random -> RandomC;

  ChaseP.LocalTime -> HilTimerMilliC;
  ChaseP.Leds -> LedsC;

  ChaseP.TreeInfo -> FloodingTreeC;

#ifndef ENABLE_PR
  components new SerialAMSenderC(AM_CHASE_TAIL_MSG) as TailSend;
  ChaseP.TailSend -> TailSend;
  ChaseP.TailPacket -> TailSend;
#endif
}
