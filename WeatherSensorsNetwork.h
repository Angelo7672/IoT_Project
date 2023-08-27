#ifndef WEATHER_SENSORS_NETWORK_H
#define WEATHER_SENSORS_NETWORK_H

typedef nx_struct weather_msg {
	nx_uint8_t type;    //0-->content message, 1-->ACK
	nx_uint16_t sender;
	nx_uint16_t destination;
  nx_uint16_t gateway;  //gateway that manages the message (6 or 7)
  nx_uint16_t message_id;
	nx_uint16_t value;
  nx_uint16_t unit_measure;   //0-->'Temperature [°C]', 1-->'Humidity [%]',
                              //2-->'Wind [km/h]', 3-->'Air Quality PM2.5 [ug/m^3]'
} weather_msg_t;

enum {
  AM_MY_MSG = 10,
};

#endif
