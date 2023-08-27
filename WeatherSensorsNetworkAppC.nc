#include "WeatherSensorsNetwork.h"
#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration WeatherSensorsNetworkAppC {}
implementation {
  /****** COMPONENTS *****/
  components MainC, WeatherSensorsNetworkC as App;
  components new TimerMilliC() as TimerMeasure, new TimerMilliC() as Timer1, new TimerMilliC() as Timer2;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components ActiveMessageC;
  components new NetworkServerC(), new SensorNodeC();
  components SerialPrintfC;
  components SerialStartC;
  
  
  /****** INTERFACES *****/
  App.Boot -> MainC.Boot;

  App.TimerMeasure -> TimerMeasure;
  App.Timer1 -> Timer1;
  App.Timer2 -> Timer2;

  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Packet -> AMSenderC;

  App.NetworkServer -> NetworkServerC.NetworkServer;

  App.SensorNode -> SensorNodeC.SensorNode;
}