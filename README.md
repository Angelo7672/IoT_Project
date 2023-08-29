# Internet of Things Final Project
Implement and showcase a network architecture similar to LoraWAN in
TinyOS. The requirements of this project are:
1. Create a topology with 5 sensor nodes, 2 gateway nodes and one network
server node, as illustrated in Figure.
2. Each sensor node periodically transmits (random) data, which is received
by one or more gateways. Gateways just forward the received
data to the network server.
3. Network server keeps track of the data received by gateways, taking
care of removing duplicates. An ACK message is sent back to the
forwarding gateway, which in turn transmits it to the nodes. If a node
does not receive an ACK within a 1-second window, the message is
re-transmitted.
4. The network server node should be connected to Node-RED, and periodically
transmit data from sensor nodes to Thingspeak through MQTT.
5. Thingspeak must show at least three charts on a public channel.

![Screenshot 2023-08-29 164603](https://github.com/Angelo7672/IoT_Project/assets/100519177/9eac42ce-105c-4f12-a7ef-1c3694aa78cd)

## How to use:
Open in a terminal the folder of the project, then insert the command:
* `make telosb`
* `node-red`

Go to the URL http://localhost:1880, import the flow from the *node-red* folder's *node-red-source* file, and then deploy.

Open Cooja and arrange the eight Sky motes in a manner similar to the network simulation shown in Figure. Afterward, open a Serial Socket (SERVER) on port 60008 on localhost on the mote of Network Server. You can also use my saved simulation that is located in the cooja folder, but you will need to update all of the Contiki firmware with the right location of your *main.exe* file. Go to *File > Open Simulation > Open and Reconfigure > Browse* and select the file from the folder *cooja > my_simulation.csc*. Next, select SkyMoteType as the mote type and contiki firmware from the folder *build > telosb > main.exe* for each mote.

Open the Thingspeak channel page at https://thingspeak.com/channels/2111175.

Finally start the simulation on Cooja.
