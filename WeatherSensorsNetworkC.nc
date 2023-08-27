#include "Timer.h"
#include "WeatherSensorsNetwork.h"
#include "printf.h"
#include <stdlib.h>

typedef struct messageSent_s{
  uint16_t message_id;
  uint16_t destination; //for the sensor node that has more gateway
	uint16_t value;
  uint16_t unit_measure;
  struct messageSent_s*next;
}messageSent_t;

module WeatherSensorsNetworkC @safe() {
  uses {
    /****** INTERFACES *****/
    interface Boot;
    interface Timer<TMilli> as TimerMeasure;
    interface Timer<TMilli> as Timer1;
    interface Timer<TMilli> as Timer2;
    interface SplitControl as AMControl;
    interface AMSend;
    interface Receive;
    interface Packet;
    interface NetworkServer;
    interface SensorNode;
  }
}

implementation{
  bool locked;
  message_t packet;

  //Sensor Nodes
  uint16_t message_id = 1; //initialized to 1
  uint16_t value;
  uint16_t unit_measure;
  messageSent_t* messageSent = NULL;
  uint16_t message_idSent1; //timer 1
  uint16_t destinationSent1;
  uint16_t message_idSent2; //timer 2
  uint16_t destinationSent2;
  bool coin = FALSE; //for node 2 and 4

  void send(uint16_t valueSending, uint16_t unit_measureSending, uint16_t message_idSending, uint16_t sender, uint16_t destinationSending, uint16_t gateway);

  /**************************************************************************************/
  
  /** BOOT **/
  event void Boot.booted() { call AMControl.start(); }

  /** AMCONTROL **/
  event void AMControl.startDone(error_t err) {
    if(err == SUCCESS){
      if(TOS_NODE_ID == 1 || TOS_NODE_ID == 2 || TOS_NODE_ID == 3 || TOS_NODE_ID == 4 || TOS_NODE_ID == 5) //Sensor Node
        call TimerMeasure.startPeriodic(10000);  //10 seconds
    }else{ call AMControl.start(); }
  }

  /**
  * TIMER MEASURE
  * Chooses the unit measure and the correspondent value, than sends it and initializes the timeout for the ack
  **/
  event void TimerMeasure.fired(){
    unit_measure = call SensorNode.getUnitMeasure();
    value = call SensorNode.getValue(unit_measure);

    if(TOS_NODE_ID == 1 || TOS_NODE_ID == 2 || TOS_NODE_ID == 4){ 
      send(value,unit_measure,message_id,TOS_NODE_ID,8,6);
      coin = TRUE;
      messageSent = call SensorNode.appendMessageSent(messageSent,message_id,6,value,unit_measure); //store the message in the list of messages sent
      destinationSent1 = 6;
    } 
    if(TOS_NODE_ID == 3 || TOS_NODE_ID == 5){ 
      send(value,unit_measure,message_id,TOS_NODE_ID,8,7);
      messageSent = call SensorNode.appendMessageSent(messageSent,message_id,7,value,unit_measure); //store the message in the list of messages sent
    }
    message_idSent1 = message_id;
    if(TOS_NODE_ID == 2 || TOS_NODE_ID == 3 || TOS_NODE_ID == 4 || TOS_NODE_ID == 5){
      if(TOS_NODE_ID == 3 || TOS_NODE_ID == 5) { destinationSent1 = 7; }
      else if(TOS_NODE_ID == 2 || TOS_NODE_ID == 4){ 
        message_idSent2 = message_id;
        destinationSent2 = 7;
      }
    }

    call Timer1.startOneShot(1000); //wait the ack for 1 second
  }

  /**
  * TIMER 1, Node 1,2,3,4 and 5
  * Search in the list of messages sent if the message is still there (so if the ack is not received): if yes send it again
  **/
  event void Timer1.fired(){
    messageSent_t*msg = call SensorNode.findMsg(messageSent,message_idSent1,destinationSent1);  //search the message in the list of messages sent
    if(msg){  //if the ack is not received
      printf("Timeout1, resend message_id %u to %u\n",message_idSent1,destinationSent1); 
      printfflush();
      send(msg->value,msg->unit_measure,message_idSent1,TOS_NODE_ID,8,destinationSent1);  //send again the message
      call Timer1.startOneShot(1000); //wait the ack for 1 second
    }
  }

  /**
  * TIMER 2, Node 2 and 4
  * Search in the list of messages sent if the message is still there (so if the ack is not received): if yes send it again
  **/
  event void Timer2.fired(){ 
    messageSent_t*msg = call SensorNode.findMsg(messageSent,message_idSent2,destinationSent2);  //search the message in the list of messages sent
    if(msg){  //if the ack is not received
      printf("Timeout2, resend message_id %u to %u\n",message_idSent2,destinationSent2); 
      printfflush();
      send(msg->value,msg->unit_measure,message_idSent2,TOS_NODE_ID,8,destinationSent2);  //send again the message 
      call Timer2.startOneShot(1000);  //wait the ack for 1 second
    } 
  }

  /**
  * Sends the packet
  **/
  void send(uint16_t valueSending, uint16_t unit_measureSending, uint16_t message_idSending, uint16_t sender, uint16_t destinationSending, uint16_t gateway){
    if(locked){ return; }
    else{
      uint16_t direction; //where to send
      weather_msg_t* msg = (weather_msg_t*)(call Packet.getPayload(&packet, sizeof(weather_msg_t)));

      msg->sender = sender;
      msg->destination = destinationSending;
      msg->gateway = gateway;
      msg->message_id = message_idSending;
      //Sensor Nodes
      if(TOS_NODE_ID == 1 || TOS_NODE_ID == 2 || TOS_NODE_ID == 3 || TOS_NODE_ID == 4 || TOS_NODE_ID == 5){
        msg->type = 0;
        msg->value = valueSending;
        msg->unit_measure = unit_measureSending;
        direction = gateway;
      }
      //Gateways
      else if(TOS_NODE_ID == 6 || TOS_NODE_ID == 7){
        direction = destinationSending;
        if(destinationSending == 8){ //to network server
          msg->type = 0;
          msg->value = valueSending;
          msg->unit_measure = unit_measureSending;
        }else //to sensor node
          msg->type = 1;
      }
      //Network Server
      else if(TOS_NODE_ID == 8){
        msg->type = 1;
        direction = gateway;
      }

      if(call AMSend.send(direction,&packet,sizeof(weather_msg_t)) == SUCCESS){
        locked = TRUE;
        if(msg->type == 0 && TOS_NODE_ID != 6 && TOS_NODE_ID != 7){ //Sensor Nodes
          printf("Sending a content message with message_id %u\n",message_idSending); 
          printfflush();
        }else if(TOS_NODE_ID == 6 || TOS_NODE_ID == 7){ //Gateways
          if(sender == TOS_NODE_ID){
            printf("Forwarding a message of 8 to %u\n",destinationSending);
            printfflush();
          }else{
            printf("Forwarding a message of %u\n",sender); 
            printfflush();
          }
        }
      }
    }
  }

  /** AMSEND **/
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if(&packet == bufPtr && error == SUCCESS){ 
      locked = FALSE;
      if(coin && (TOS_NODE_ID == 2 || TOS_NODE_ID == 4)){ //send the second packet
        send(value,unit_measure,message_id,TOS_NODE_ID,8,destinationSent2);
        messageSent = call SensorNode.appendMessageSent(messageSent,message_id,7,value,unit_measure);
        call Timer2.startOneShot(1000);   //wait the ack for 1 second
        coin = FALSE;
      }
    }
  }

  /** RECEIVE **/
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    if (len != sizeof(weather_msg_t)) { return bufPtr; }
    else{
      weather_msg_t* pkt = (weather_msg_t*) payload;

      //Sensor Nodes
      if(TOS_NODE_ID == 1 || TOS_NODE_ID == 2 || TOS_NODE_ID == 3 || TOS_NODE_ID == 4 || TOS_NODE_ID == 5){
        if(pkt->type == 1){
          messageSent = call SensorNode.delete(messageSent,pkt->message_id,pkt->sender); //sender is the gateway which the sensor node sends the msg. Remove the message from the list of messages sent
          printf("ACK %u received\n",pkt->message_id);
          printfflush();
          if(pkt->message_id == message_id){ message_id++; }
        }
      }
      //Gateways
      else if(TOS_NODE_ID == 6 || TOS_NODE_ID == 7){
        if(pkt->destination == 8)
          send(pkt->value,pkt->unit_measure,pkt->message_id,pkt->sender,pkt->destination,TOS_NODE_ID); //send to the network server
        else
          send(0,0,pkt->message_id,TOS_NODE_ID,pkt->destination,TOS_NODE_ID);  //send to the sensor node
      }
      //Network Server
      else if(TOS_NODE_ID == 8){
        send(0,0,pkt->message_id,TOS_NODE_ID,pkt->sender,pkt->gateway); //send the ACK
        if(call NetworkServer.check(pkt->message_id,pkt->sender)){ 
          printf("%u,%u\n",pkt->value,pkt->unit_measure); //in this way cooja will send to node-red by tcp the value with its unit measure
          printfflush();
        }
      }
    }
    return bufPtr;
  }

  /** AMCONTROL **/
  event void AMControl.stopDone(error_t err) {}
}