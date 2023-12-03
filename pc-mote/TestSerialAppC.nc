

#include "TestSerial.h"

configuration TestSerialAppC {}
implementation {
  components TestSerialC as App, LedsC, MainC;
  components SerialActiveMessageC as AM;
  components new TimerMilliC() as Timer0;
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;
  components CC2420ActiveMessageC;

// SerialC---------SerialAppC
  App.Boot -> MainC.Boot;
  App.SerialControl -> AM;
  App.SerialReceive -> AM.Receive[AM_TEST_SERIAL_MSG];
  App.SerialSend -> AM.AMSend[AM_TEST_SERIAL_MSG];
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Timer1->Timer1;
  App.Timer2->Timer2;
  App.SerialPacket -> AM;

//Comunicación radio
  components ActiveMessageC as AM_radio;

  components new AMSenderC(AM_MOVIL);
  components new AMReceiverC(AM_MOVIL);
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.RadioControl -> AM_radio;
  App.RadioSend -> AMSenderC;
  App.RadioReceive -> AMReceiverC;
  App -> CC2420ActiveMessageC.CC2420Packet;

}


