#include "Chase.h"

interface ChaseDelay {
  command uint32_t getTime();
  event void getDelay(chase_delay_t* lay);
}
