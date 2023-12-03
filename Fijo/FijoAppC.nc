// $Id: FijoAppC.nc,v 1.5 2010/06/29 22:07:40 scipio Exp $


#include <Timer.h>
#include "Fijo.h"

configuration FijoAppC {
}
implementation {
  components MainC;
  components LedsC;
  components FijoC as App;
  components new TimerMilliC() as Timer0;
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;
  components ActiveMessageC;
  components new AMSenderC(AM_FIJO);
  components new AMReceiverC(AM_FIJO);
  components CC2420ActiveMessageC;

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Timer1 -> Timer1;
  App.Timer2 -> Timer2;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App -> CC2420ActiveMessageC.CC2420Packet;
}
