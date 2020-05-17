#ifndef _CC2420_X_CONTROL_H_
#define _CC2420_X_CONTROL_H_

#include "CC2420.h"
#include "cc2420_x_spi.h"

// RSSI and CCA Status and Control Register
static inline int cc2420_get_rssi() {
  int rssi = ( 0xff & get_register(CC2420_RSSI) );
  if (rssi > 128) {
    rssi = rssi - 256 - 45;
  } else {
    rssi = rssi - 45;
  }
  return rssi;
}

#endif
