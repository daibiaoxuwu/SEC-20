interface ChaseFlood {
  command error_t init_flood(message_t* pkt, uint8_t len, uint8_t* payload);
  event message_t* pkt_reced(message_t* pkt, uint8_t len, uint8_t* payload);
}
