configuration ChaseTestAppC {

} implementation {
  components MainC;
  components SerialActiveMessageC;
  components new TimerMilliC() as floodTimer;
  components new TimerMilliC() as dcTimer;
  components RandomC;
  components ChaseC;

  components ChaseTestC;

  ChaseTestC.Boot -> MainC.Boot;
  ChaseTestC.SerialControl -> SerialActiveMessageC;
  ChaseTestC.floodTimer -> floodTimer;
  ChaseTestC.Random -> RandomC;
  ChaseTestC.ChaseFlood -> ChaseC;
  ChaseTestC.ChaseControl -> ChaseC;
  ChaseTestC.ChasePacket -> ChaseC;
  ChaseTestC.ChaseDelay -> ChaseC;
  ChaseTestC.ChaseEnergy -> ChaseC;
  ChaseTestC.dcTimer -> dcTimer;

  components LedsC;
  ChaseTestC.Leds -> LedsC;

  components PrintfC;
  components SerialStartC;

#ifndef ENABLE_PR
  components new SerialAMSenderC(AM_CHASE_FLOOD_MSG) as floodSerialSend;
  components new SerialAMSenderC(AM_CHASE_DELAY_MSG) as delaySerialSend;
  components new SerialAMSenderC(AM_CHASE_ENERGY_MSG) as energySerialSend;

  ChaseTestC.floodSerialSend -> floodSerialSend;
  ChaseTestC.floodSerialPkt -> floodSerialSend;
  ChaseTestC.delaySerialSend -> delaySerialSend;
  ChaseTestC.delaySerialPkt -> delaySerialSend;
  ChaseTestC.energySerialSend -> energySerialSend;
  ChaseTestC.energySerialPkt -> energySerialSend;
#endif
}
