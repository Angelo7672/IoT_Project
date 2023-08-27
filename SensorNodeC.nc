generic configuration SensorNodeC(){
    provides interface SensorNode;
} 

implementation {
    /****** COMPONENTS *****/
    components MainC;
    components new SensorNodeP();
    components RandomC;

    /****** INTERFACES *****/
    SensorNode = SensorNodeP.SensorNode;

    SensorNodeP.Random -> RandomC.Random;
}