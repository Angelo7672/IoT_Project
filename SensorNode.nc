interface SensorNode{
    command uint16_t getUnitMeasure();
    command uint16_t getValue(uint16_t unit_measure);
    command messageSent_t*appendMessageSent(messageSent_t*messageSent, uint16_t message_id, uint16_t destination, uint16_t value, uint16_t unit_measure);
    command messageSent_t*findMsg(messageSent_t*messageSent, uint16_t message_id, uint16_t destination);
    command messageSent_t*delete(messageSent_t*head, uint16_t message_id, uint16_t destination);
}