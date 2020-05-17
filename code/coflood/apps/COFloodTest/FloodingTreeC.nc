configuration FloodingTreeC {
    provides interface TreeInit;
    provides interface TreeInfo;
}
implementation {
    components FloodingTreeP;
    TreeInit = FloodingTreeP;
    TreeInfo = FloodingTreeP;

    components MainC;
    MainC.SoftwareInit -> FloodingTreeP.Init;

    components new AMSenderC(AM_TOPOLOGY_MSG) as Speak;
    components new AMReceiverC(AM_TOPOLOGY_MSG) as Listen;
    FloodingTreeP.Speak -> Speak;
    FloodingTreeP.Listen -> Listen;

    components new AMSenderC(AM_TREE_BEACON_MSG) as TreeTx;
    components new AMReceiverC(AM_TREE_BEACON_MSG) as TreeRx;
    FloodingTreeP.TreeTx -> TreeTx;
    FloodingTreeP.TreeRx -> TreeRx;

    components new TimerMilliC() as ControlTimer;
    components new TimerMilliC() as TxTimer;
    components new TimerMilliC() as TopoTimer;
    components new TimerMilliC() as TreeInitTimer;
    FloodingTreeP.ControlTimer -> ControlTimer;
    FloodingTreeP.TxTimer -> TxTimer;
    FloodingTreeP.TopoTimer -> TopoTimer;
    FloodingTreeP.TreeInitTimer -> TreeInitTimer;

    FloodingTreeP.LinkPkt -> Speak;
    FloodingTreeP.TreePkt -> TreeTx;

    components new SerialAMSenderC(AM_NEIGHBOR_MSG) as SerialTx;
    FloodingTreeP.SerialTx -> SerialTx;
    FloodingTreeP.SerialPkt -> SerialTx;

    components RandomC;
    FloodingTreeP.Random -> RandomC;

    components LedsC;
    FloodingTreeP.Leds -> LedsC;
}
