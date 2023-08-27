generic module SensorNodeP(){
    provides interface SensorNode;

    uses interface Random;
}

implementation {
    /**
    * Generate a number from 0 to 3
    **/
    command uint16_t SensorNode.getUnitMeasure(){ return call Random.rand16() % 4; }

    /**
    * Generate a value according to the unit_measure
    **/
    command uint16_t SensorNode.getValue(uint16_t unit_measure){
        if(unit_measure == 0){ return call Random.rand16() % 11 + 20; }   //Temperature range [20-30]
        else if(unit_measure == 1){ return call Random.rand16() % 101; }  //Humidity range [0-100] 
        else if(unit_measure == 2){ return call Random.rand16() % 21; }  //Wind range [0-20]
        else if(unit_measure == 3){ return call Random.rand16() % 41; }  //Air quality PM2.5 range [0-40]
        return 0;
    }

    /**
    * Append message to the list message sent
    **/
    command messageSent_t*SensorNode.appendMessageSent(messageSent_t*messageSent, uint16_t message_id, uint16_t destination, uint16_t value, uint16_t unit_measure) {	
        messageSent_t*n;
        messageSent_t*p;
        
        n = malloc(sizeof(messageSent_t));							
        if(n != NULL){
            n->message_id = message_id;
            n->destination = destination;										
            n->value = value;
            n->unit_measure = unit_measure;
            n->next = NULL;										
            if(messageSent != NULL){
                for(p = messageSent; p->next != NULL; p = p->next);
                p->next = n;									
            }else{ messageSent = n; }
        }
        return messageSent;
    }

    /**
    * Return the message with these message_id and destination from the list message sent
    **/
    command messageSent_t*SensorNode.findMsg(messageSent_t*messageSent, uint16_t message_id, uint16_t destination){
        messageSent_t*p;
        
        for(p = messageSent; p ; p = p->next)
            if(p->message_id == message_id && p->destination == destination){ return p; }
        return NULL;
    }

    /**
    * Delete a message from the message list
    **/
    command messageSent_t*SensorNode.delete(messageSent_t*head, uint16_t message_id, uint16_t destination){
        messageSent_t*it,*next,*prev;
            
        for(it=head,prev=NULL;it;it=next){
            next=it->next;
            if(it->message_id == message_id && it->destination == destination){
                if(prev)
                    prev->next=next;
                else
                    head=next;
                free(it);
            }else
                prev=it;
        }
        return head;
    }
}