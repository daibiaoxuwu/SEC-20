#ifndef COFLOOD_H_
#define COFLOOD_H_

typedef nx_struct tree_beacon_msg {
    nx_uint16_t id;
    nx_uint16_t ebw;
    nx_uint16_t path_ebw;
    nx_uint16_t elder_id;
    nx_uint16_t delay;
    nx_uint16_t children_num;
    nx_uint16_t is_sender;
} tree_beacon_msg_t;

typedef struct neighbor_table_entry {
    uint16_t id;
    uint16_t reced;
    uint16_t ebw;
    uint16_t path_ebw;
    uint16_t elder_id;
    uint16_t delay;
} neighbor_table_entry_t;

typedef struct neighbor_table {
    uint16_t neighbor_num;
    neighbor_table_entry_t entries[52];
} neighbor_table_t;

typedef nx_struct neighbor_msg {
    nx_uint16_t addr;
    nx_uint16_t neighbor_num;
    nx_uint16_t neighbor0;
    nx_uint16_t neighbor1;
    nx_uint16_t neighbor2;
    nx_uint16_t neighbor3;
    nx_uint16_t neighbor4;
    nx_uint16_t neighbor5;
    nx_uint16_t neighbor6;
    nx_uint16_t neighbor7;
    nx_uint16_t neighbor8;
    nx_uint16_t neighbor9;
    nx_uint16_t neighbor10;
    nx_uint16_t neighbor11;
    nx_uint16_t neighbor12;
    nx_uint16_t neighbor13;
    // nx_uint16_t id[22];
    nx_uint16_t reced0;
    nx_uint16_t reced1;
    nx_uint16_t reced2;
    nx_uint16_t reced3;
    nx_uint16_t reced4;
    nx_uint16_t reced5;
    nx_uint16_t reced6;
    nx_uint16_t reced7;
    nx_uint16_t reced8;
    nx_uint16_t reced9;
    nx_uint16_t reced10;
    nx_uint16_t reced11;
    nx_uint16_t reced12;
    nx_uint16_t reced13;
    // nx_uint16_t reced[22];
} neighbor_msg_t;

enum {
    AM_TOPOLOGY_MSG = 0x22,
    AM_NEIGHBOR_MSG = 0x66,
    AM_TREE_BEACON_MSG = 0x44,
};

#endif
