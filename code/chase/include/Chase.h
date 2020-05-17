#ifndef CHASE_H_
#define CHASE_H_

#include "CC2420.h"

#define RSSI_SAMPLES_NUM 128

#define CC2420_FIFOP_DISABLE()\
                              do {\
                                P1IFG &= ~(1 << 0); \
                                P1IE &= ~(1 << 0);  \
                              } while(0)

#define CC2420_FIFOP_ENABLE() \
                              do { \
                                P1IFG &= ~(1 << 0); \
                                P1IE |= (1 << 0);   \
                              } while(0)

#define ABS_VALUE(a, b) ( (a > b) ? a-b : b-a )

typedef enum {
  DUTY_CYCLE_IDL,
  DUTY_CYCLE_DET,
  DUTY_CYCLE_LIS,
  DUTY_CYCLE_REC,
  DUTY_CYCLE_SND,
  DUTY_CYCLE_OFF,
} chase_radio_state_t;

typedef nx_struct {
  nx_uint16_t src_id;
  nx_uint16_t seq_no;
  nx_uint16_t fwd_id;
  nx_uint16_t fwd_time_h;
  nx_uint16_t fwd_time_l;
} chase_header_t;

typedef struct {
  uint16_t src_id;
  uint16_t seq_no;
  uint16_t last_hop_id;
  uint16_t per_hop_delay_h;
  uint16_t per_hop_delay_l;
} chase_delay_t;

typedef nx_struct chase_tail_msg {
  nx_uint16_t nodeid;
  nx_uint16_t seq_no;
  nx_uint16_t tail_time_h;
  nx_uint16_t tail_time_l;
} chase_tail_msg_t;

enum {
  AM_CHASE_TAIL_MSG = 99,
};

#endif
