generic configuration NetworkServerC(){
    provides interface NetworkServer;
} implementation {
    /****** COMPONENTS *****/
    components MainC;
    components new NetworkServerP();

    /****** INTERFACES *****/
    NetworkServer = NetworkServerP.NetworkServer;
}