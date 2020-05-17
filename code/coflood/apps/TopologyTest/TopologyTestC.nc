configuration TopologyTestC {
} implementation {
    components TopologyTestP;

    components MainC;
    TopologyTestP.Boot -> MainC;

    components ActiveMessageC;
    TopologyTestP.RadioControl -> ActiveMessageC;

    components SerialActiveMessageC;
    TopologyTestP.SerialControl -> SerialActiveMessageC;

    components new AMSenderC(AM_TOPOLOGY_MSG) as Speak;
    components new AMReceiverC(AM_TOPOLOGY_MSG) as Listen;
    TopologyTestP.Speak -> Speak;
    TopologyTestP.Listen -> Listen;

    components new SerialAMSenderC(AM_TOPOLOGY_MSG) as SerialSend;
    TopologyTestP.SerialSend -> SerialSend;

    components new TimerMilliC() as ControlTimer;
    components new TimerMilliC() as TxTimer;
    components new TimerMilliC() as ReportTimer;
    TopologyTestP.ControlTimer -> ControlTimer;
    TopologyTestP.TxTimer -> TxTimer;
    TopologyTestP.ReportTimer -> ReportTimer;

    TopologyTestP.Packet -> Speak;
    TopologyTestP.ReportPkt -> SerialSend;

    components CC2420ActiveMessageC;
    TopologyTestP.CC2420Packet -> CC2420ActiveMessageC;

    components LedsC;
    TopologyTestP.Leds -> LedsC;

    components PrintfC;
    components SerialStartC;
}
