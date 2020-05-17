#ifndef TOPOLOGYTEST_H_
#define TOPOLOGYTEST_H_

typedef nx_struct topology_msg {
    nx_uint16_t id;
    nx_uint16_t src;
    nx_uint8_t rssi;
} topology_msg_t;

typedef nx_struct tree_beacon {
    nx_uint16_t id;
    nx_uint16_t ebw;
    nx_uint16_t elder_id;
} tree_beacon_t;

enum {
    AM_TOPOLOGY_MSG = 0x22,
};

#endif
