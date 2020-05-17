interface TreeInfo {
    command uint16_t getEBW();
    command uint16_t getPathEBW();
    command uint16_t getElderID();
    command uint16_t getDelay();
    command uint16_t getWeight();
    command uint16_t getChildrenNum();
    command bool isSender();
}
