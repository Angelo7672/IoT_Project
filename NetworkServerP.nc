generic module NetworkServerP(){
  provides interface NetworkServer; 
}

implementation{
  uint16_t message_id1 = 0; //initialized to 0
  uint16_t message_id2 = 0; //initialized to 0
  uint16_t message_id3 = 0; //initialized to 0
  uint16_t message_id4 = 0; //initialized to 0
  uint16_t message_id5 = 0; //initialized to 0


  /**
  * Check if the message is a duplicate
  **/
  command bool NetworkServer.check(uint16_t message_id, uint16_t sender){
    if(sender == 1){
      if(message_id1 < message_id){ 
        message_id1++;
        return TRUE; 
      }
    }else if(sender == 2){
      if(message_id2 < message_id){ 
        message_id2++;
        return TRUE; 
      } 
    }else if(sender == 3){
      if(message_id3 < message_id){ 
        message_id3++;
        return TRUE; 
      }
    }else if(sender == 4){
      if(message_id4 < message_id){ 
        message_id4++;
        return TRUE; 
      }
    }else if(sender == 5){
      if(message_id5 < message_id){ 
        message_id5++;
        return TRUE; 
      }
    }
    return FALSE; 
  }
}





  
  
  
  
  