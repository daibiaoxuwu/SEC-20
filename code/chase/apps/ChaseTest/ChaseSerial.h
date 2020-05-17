#ifndef CHASE_SERIAL_H_
#define CHASE_SERIAL_H_

typedef nx_struct chase_flood_msg {
  nx_uint16_t seq_no;
  nx_uint16_t time_flood_h;
  nx_uint16_t time_flood_l;
} chase_flood_msg_t;

typedef nx_struct chase_delay_msg {
  nx_uint16_t nodeid;
  nx_uint16_t seq_no;
  nx_uint16_t src_id;
  nx_uint16_t rec_time_h;
  nx_uint16_t rec_time_l;
  nx_uint16_t hop_delay_h;
  nx_uint16_t hop_delay_l;
} chase_delay_msg_t;

typedef nx_struct chase_energy_msg {
  nx_uint16_t nodeid;
  nx_uint16_t clock_time_h;
  nx_uint16_t clock_time_l;
  nx_uint16_t dc_time_h;
  nx_uint16_t dc_time_l;
} chase_energy_msg_t;

enum {
  AM_CHASE_FLOOD_MSG = 22,
  AM_CHASE_DELAY_MSG = 44,
  AM_CHASE_ENERGY_MSG = 77,
};

#endif
