interface ChaseControl {
  command void dc_start();
  // command void dc_sleep_interval_set(uint8_t time);
  // command uint8_t dc_sleep_interval_get();
  // command void dc_wake_duration_set(uint8_t time);
  // command uint8_t dc_wake_duration_get();
  event void dc_started(error_t err);
}
