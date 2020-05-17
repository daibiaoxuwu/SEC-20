interface ChasePacket {
  command uint8_t* getPayload(message_t* pkt, uint8_t len);
}
