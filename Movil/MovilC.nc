// $Id: MovilC.nc,v 1.6 2010/06/29 22:07:40 scipio Exp $


#include <Timer.h>
#include "Movil.h"

module MovilC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Timer<TMilli> as Timer1;
  uses interface Timer<TMilli> as Timer2;
  uses interface Timer<TMilli> as Timer3;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface Read<uint16_t> as Temperature;
  uses interface Read<uint16_t> as Humidity;
}
implementation {

  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;
  int16_t rssi_anterior;
  uint16_t temperatura;
  uint16_t direccion_fijo=0;
  uint8_t num_secuencia;
  int16_t medida;
  int i;

  //Las variables siguientes son para el calculo de la localización.
  float rssi=250;
  float rssi_t[4];
  float dist[4];
  float w[4];
  float W;
  float indice = 0;
  bool calcula;

  //Estas variables indican la posición de los nodos fijos.
  float f1[2][1];
  float f2[2][1];
  float f3[2][1];
  float f4[2][1];
  float M[2];
  float M_s[2][1];

  //(0,0) es esquina inferior izquierda
  //(100,0) es esquina inferior derecha
  //(0,100) es esquina superior izquierda
  //(100,100) es esquina superior derecha

	uint8_t count = 0;
	bool ledsOn = TRUE;


  void iniciatabla(){
    f1[0][0] = 0;
    f1[1][0] = 0;

    f2[0][0] = 100;
    f2[1][0] = 0;

    f3[0][0] = 100;
    f3[1][0] = 100;

    f4[0][0] = 0;
    f4[1][0] = 100;
  }
  void setLeds(uint16_t val1, uint16_t val2, uint16_t val3) {
    if (val1 == 1)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (val2 == 1)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (val3 == 1)
      call Leds.led2On();
    else
      call Leds.led2Off();
    
    call Timer2.startOneShot(500);
  }



event void Timer3.fired() {
  
    
    if (ledsOn) {
      // Apaga los LEDs
      //call Leds.led0Off();
      call Leds.led1Off();
      call Leds.led2Off();
      
      ledsOn = FALSE;
    } else {
      // Enciende los LEDs
      //call Leds.led0On();
      call Leds.led1On();
      call Leds.led2On();
      
      ledsOn = TRUE;
      count++;
    }
    
    if (count >= 10) {
      // Detiene el temporizador después de 10 repeticiones
      call Timer3.stop();
	count = 0;
    } else {
      // Espera medio segundo para la siguiente iteración
      call Timer3.startOneShot(500);
    }
}





  event void Temperature.readDone(error_t result, uint16_t val){
       temperatura = -39.6 + 0.01 * val;
	if(temperatura > 30)
		setLeds(1,0,0);
  }

  event void Humidity.readDone(error_t result, uint16_t val){
	medida= -2.0468 + 0.0367*val+(-0.0000015955*val*val);

}


  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      iniciatabla();
      call Timer0.startPeriodic(5000);
      call Timer1.startPeriodic(1000);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

   event void Timer2.fired(){
       setLeds(0,0,0);
  }


//ENVIA MENSAJE A LA BASE STATION
  event void Timer1.fired(){
    MovilMsg* movilpkt = (MovilMsg*)(call Packet.getPayload(&pkt, sizeof(MovilMsg)));
    //setLeds(0,0,1);	

    call Humidity.read();
    call Temperature.read();
    movilpkt->nodeid_origen = TOS_NODE_ID;
    movilpkt->nodeid_origen_msg = TOS_NODE_ID;
    movilpkt->coste=0;
    movilpkt->nodeid_d = 1; 	//ID DE LA BASE STATION. SIEMPRE SERA EL 1
    movilpkt->type = 1;
    movilpkt->coord_x = (int8_t)M_s[0][0];
    movilpkt->coord_y = (int8_t)M_s[1][0];
    movilpkt->datos = temperatura;
    movilpkt->nodeid_d_msg=direccion_fijo;
    movilpkt->humedad = medida;
    
    //HAY QUE MANDAR EL MENSAJE AL NODO FIJO CON MEJOR RSSI. VARIABLE GLOBAL DE DIRECCION
    if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(MovilMsg)) == SUCCESS) {
	//direccion_fijo
        busy = TRUE;
        
       
    }
  }

//ENVIA MENSAJE BROADCAST PARA VER QUE NODOS FIJOS LO ESCUCHAN

  event void Timer0.fired() {
    if (!busy) {
      MovilMsg* movilpkt = (MovilMsg*)(call Packet.getPayload(&pkt, sizeof(MovilMsg)));
      if (movilpkt == NULL) {
	return;
      }

      movilpkt->nodeid_origen = TOS_NODE_ID;
      movilpkt->nodeid_origen_msg = TOS_NODE_ID;
      movilpkt->coste=0;
      movilpkt->nodeid_d = 0;
      movilpkt->type = 3;
      movilpkt->datos = 0;
      num_secuencia=rand();
      movilpkt->num_sec=num_secuencia;	
     //setLeds(1,0,0);	
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(MovilMsg)) == SUCCESS) {
        
        busy = TRUE;
      }
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    	MovilMsg* inpkt = (MovilMsg*)payload;
	MovilMsg* outpkt = (MovilMsg*)(call Packet.getPayload(&pkt, sizeof(MovilMsg)));
    
	


	
    //solo acepta mensajes de tipo 3: comunicación entre nodos móviles y nodos fijos
    if(inpkt->type == 3){  
	
       if(inpkt->datos != 0){      //MENSAJE QUE VIENE DE UN NODO FIJO CON MEDIDA DE RSSI. SI DATOS ES 0 ES PQ VIENE 					DE UN NODO MOVIL (NO CONTESTAR)

	 
	if(inpkt->nodeid_d_msg == TOS_NODE_ID){
	 
	  
	  if(rssi>= inpkt->datos){
         	rssi = inpkt->datos;
		direccion_fijo = inpkt->nodeid_origen_msg;
		setLeds(0,1,0);
	  }

         
	  if(inpkt->num_sec == num_secuencia){
            if(indice < 4) {
		
		
                rssi_t[inpkt->nodeid_origen-20] = inpkt->datos;
                indice ++;
            } 
            else {
               uint8_t f;
               for (f = 0; f < indice ; f++) {
                   dist[f] = powf(10,(rssi_t[f] + 1.6)/(-10.302));
                   w[f] = 1/(powf(dist[f],1));		//powf(dist[f],4)
                }
                indice = 0;
                calcula = TRUE;
            }
          
          }
    
          //M_s[0][0] es la coordenada x de la posicion del nodo movil
          //M_s[1][0] es la coordenada y de la posicion del nodo movil
          //Luego vamos calculando la coordenada 'x' e 'y' por separado y lo añadimos a la matriz que contiene la posicion.
          //M[0] es el calculo de la coordenada x (En este caso es el sumatorio de wij*Lj) donde wij son los pesos
          //y Lj es la posicion del nodo fijo (como esta indicado antes es f[0][0] etc etc (que no es mas que la coordenada x e y)
          //Finalmente M[1] es el calculo del sumatorio wij*Lj para las coordenadas y.

          if(calcula) {
              M[0] = w[0]*f1[0][0] + w[1]*f2[0][0] + w[2]*f3[0][0] +w[3]*f4[0][0];
              M[1] = w[0]*f1[1][0] + w[1]*f2[1][0] + w[2]*f3[1][0] +w[3]*f4[1][0];
              W = w[0] + w[1] + w[2] + w[3];

              M_s[0][0] = M[0]/W;
              M_s[1][0] = M[1]/W;
		calcula = FALSE;
   	  }
       }
     }

  
    }


	//dos posibilidades si me llega mi id el msg es para mi
	// si me llega destino cero es una alerta global 

    if(inpkt->type == 2){
      if(inpkt->nodeid_d == TOS_NODE_ID || inpkt->nodeid_d == 0){
      	call Timer3.startOneShot(500);
      }	
    }
    
    return msg;
  }
}
