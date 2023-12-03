// $Id: MovilC.nc,v 1.5 2010/06/29 22:07:40 scipio Exp $


#include <Timer.h>
#include "Movil.h"

configuration MovilAppC {
}
implementation {
  components MainC;
  components LedsC;
  components MovilC as App;
  components new TimerMilliC() as Timer0;
  components new TimerMilliC() as Timer1;
  components new TimerMilliC() as Timer2;
  components new TimerMilliC() as Timer3;
  components ActiveMessageC;
  components new AMSenderC(AM_MOVIL);
  components new AMReceiverC(AM_MOVIL);
  components new SensirionSht11C() as Sht11;
 

  App.Boot -> MainC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0;
  App.Timer1 -> Timer1;
  App.Timer2 -> Timer2;
  App.Timer3-> Timer3;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
  App.Temperature -> Sht11.Temperature;
  App.Humidity -> Sht11.Humidity;
}
