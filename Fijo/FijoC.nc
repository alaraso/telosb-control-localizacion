

#include <Timer.h>
#include "Fijo.h"

module FijoC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Timer<TMilli> as Timer1;
  uses interface Timer<TMilli> as Timer2;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface CC2420Packet;
}
implementation {

typedef nx_struct entrada {
    nx_uint16_t destino;
    nx_uint16_t sig_salto;
    nx_am_addr_t direccion_sig_salto;
    nx_uint8_t coste;
    nx_uint8_t tiempo;
  } entrada;

  
  message_t pkt;
  bool busy = FALSE;
  uint16_t origen;
  uint16_t destino;
  uint16_t sig_salto;
  uint8_t coste;
  uint8_t tamano_tabla = 0;
  bool resultado = FALSE;
  entrada tabla[TAM_MAX];
  entrada null_entry;

  uint8_t rssi1; 
  int16_t rssi2;


//Funcion para encender los leds 
  void setLeds(uint16_t val1,uint16_t val2, uint16_t val3) {
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

    call Timer2.startOneShot(100);
  }



  //***FUNCION PARA ACTUALIZAR LA TABLA DE ENCAMINAMIENTO***

  bool actualizar_tabla(uint16_t id_destino, uint16_t siguiente_salto, am_addr_t direccion, uint8_t metrica){
      uint8_t i;
      for( i = 0; i < tamano_tabla; i++){
         if(tabla[i].destino == id_destino){
            if(tabla[i].coste  > metrica){
		tabla[i].coste = metrica;
                tabla[i].sig_salto = siguiente_salto;
                tabla[i].direccion_sig_salto = direccion;
		tabla[i].tiempo = 0;
		return TRUE;
            }
            return FALSE;		//esto pasa cuando ya hay una entrada pero el coste es peor
         }
      }
					//busco una entrada vacía en la tabla 
      if(tamano_tabla < TAM_MAX){
	for(i=0; i<=TAM_MAX; i++){
            if(tabla[i].destino==0){
    	         tabla[i].destino = id_destino;
          	 tabla[i].sig_salto = siguiente_salto;
                 tabla[i].direccion_sig_salto = direccion;
         	 tabla[i].coste = metrica;
	  	 tabla[i].tiempo= 0;
          	 tamano_tabla++;
          	 return TRUE;
	    }
	}
      }
	return FALSE;
  }

//***FUNCION QUE DEVUELVE UNA ENTRADA DE LA TABLA PARA UN DESTINO***

  entrada get_entrada(uint16_t dest_id){
     uint8_t i;
     for(i = 0; i < tamano_tabla; i++){
         //si el nodo está en la tabla, devuelve esa entrada
         if(tabla[i].destino == dest_id){
            return tabla[i];
         }		
     }
     
     //si el nodo no está en la tabla, devuelve una entrada nula
     null_entry.destino = AM_BROADCAST_ADDR;
     null_entry.sig_salto = AM_BROADCAST_ADDR;
     null_entry.direccion_sig_salto = AM_BROADCAST_ADDR;
     null_entry.coste = 255;
     return null_entry;
  }


//***Funcion para inicializar la tabla todo a 0

  void inicializar_tabla(){
     uint8_t i;
	for (i=0;i<TAM_MAX;i++){
		tabla[i].destino = 0;
		tabla[i].sig_salto = 0;
		tabla[i].direccion_sig_salto = 0;
		tabla[i].coste = 255;
		tabla[i].tiempo = 0;

	}
  }

 
 //***FUNCION PARA OBTENER MEDIDA DE RSSI***
  uint16_t getRssi(message_t *msg){
     return (uint16_t) call CC2420Packet.getRssi(msg);
  }


  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      
      inicializar_tabla();
      call Timer0.startPeriodic(1000);
      call Timer1.startPeriodic(10000);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }



//  ***Timer que incrementa el tiempo que una entrada ha estado en la tabla, si la entrada llega a 100 segundo se elimina la entrada de la tabla
//
//	Para borrar las entradas de la tabla se ponen a 0 con el coste al máximo

  event void Timer0.fired() {
	uint8_t i;
	uint8_t f=0;
        for(i = 0; i < tamano_tabla; i++){
           tabla[i].tiempo += 1;	
	   if(tabla[i].tiempo == 100){			
	       tabla[i].destino = 0;
	       tabla[i].sig_salto=0;
	       tabla[i].direccion_sig_salto= 0;
	       tabla[i].coste = 255;	
		f=f+1;	
	   }		
	}
	tamano_tabla=tamano_tabla-f;
  }



//Periodicamente se envía un mensaje a la BS para mantener las tablas de enrutamiento vivas 
  event void Timer1.fired(){
      if (!busy) {
         FijoMsg* fijopkt = (FijoMsg*)(call Packet.getPayload(&pkt, sizeof(FijoMsg)));
      
         if (fijopkt == NULL) {
	   return;
         }
         fijopkt->nodeid_origen = TOS_NODE_ID;
         fijopkt->nodeid_origen_msg = TOS_NODE_ID;
         fijopkt->nodeid_d = TOS_NODE_ID;				//destino basestation
         fijopkt->coste = 0;
         fijopkt->type = 4;
         fijopkt->datos = 0;
         fijopkt-> num_sec = 0;
         if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(FijoMsg)) == SUCCESS) {
           setLeds(0,1,0);
      
           busy = TRUE;
         }
      }
  }
  
//Para apagar los leds cuando se encienden 
  event void Timer2.fired(){
     setLeds(0,0,0);
  }



  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
	FijoMsg* inpkt = (FijoMsg*)payload;
	FijoMsg* outpkt = (FijoMsg*)(call Packet.getPayload(&pkt, sizeof(FijoMsg)));

    //Tipo mensaje entre el nodo móvil y nodo fijo
    if(inpkt->type == 3){
	if(inpkt->datos ==0){

	if(inpkt->type==3){setLeds(1,0,1);}


	//MENSAJE QUE LLEGA DEL NODO MOVIL PARA LA COMUNICACION MOVIL-FIJO 
	origen = inpkt->nodeid_origen;
	outpkt->nodeid_d = origen;
	outpkt->nodeid_origen = TOS_NODE_ID;

	//Obtenemos rssi como un entero sin signo.
	rssi1 = getRssi(msg);
	if(rssi1>=128){	rssi2 = rssi1 - 45 - 256;          }
	else {  rssi2 = rssi1 - 45;          }

	outpkt->num_sec = inpkt->num_sec;
	outpkt->datos = rssi2;
	outpkt->nodeid_d_msg=origen;
	outpkt->type=3;

         //HAY QUE COMPROBAR LA DIRECCION CON LA QUE LLEGA EL MENSAJE Y ENVIARLO A ESA MISMA (MENSAJE DIRIGIDO)
          if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(FijoMsg)) == SUCCESS) {
             busy = TRUE;
          }   
	}
     }

	//MENSAJE QUE LLLEGA CON UNA MEDIDA DESDE EL NODO MOVIL PARA LA ESTACION BASE
	//HAY QUE AVERIGUAR LA DIRECCION DEL NODO SIGUIENTE SALTO AL QUE SE ENVIA EL MENSAJE
     if(inpkt->type == 1){	
		if(inpkt->nodeid_d_msg == TOS_NODE_ID){
		entrada entry=get_entrada(destino);
		destino = inpkt->nodeid_d;
		outpkt->nodeid_d_msg = entry.sig_salto;
		setLeds(1,1,1);

		outpkt->nodeid_origen = inpkt->nodeid_origen;
		outpkt->nodeid_origen_msg = TOS_NODE_ID;
		outpkt->nodeid_d = inpkt->nodeid_d;
		outpkt->datos = inpkt->datos;
		outpkt->type= inpkt->type;
		outpkt->coord_x = inpkt->coord_x;
		outpkt->coord_y = inpkt->coord_y;
		outpkt->humedad=inpkt->humedad;		
		


			if(entry.sig_salto != AM_BROADCAST_ADDR){
				if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(FijoMsg)) == SUCCESS) {
					busy = TRUE;
					
				}
			}
		}
	}


     if(inpkt->type == 2){
	if(inpkt->datos > 0){
         //MENSAJE QUE LLEGA DE ALARMA, ENVIAR FLOODING
		entrada entry=get_entrada(destino);

	if(inpkt->nodeid_d_msg == TOS_NODE_ID ){
		
		destino = inpkt->nodeid_d;
		outpkt->nodeid_d_msg = entry.sig_salto;
		outpkt->nodeid_d = inpkt->nodeid_d;
		}
	else{
		outpkt->nodeid_d=0;
		outpkt->nodeid_d_msg=0;

		}
		setLeds(1,1,1);

		outpkt->nodeid_origen = inpkt->nodeid_origen;
		outpkt->nodeid_origen_msg = TOS_NODE_ID;		
		outpkt->datos = inpkt->datos - 1; 	//al ttl le quitamos un salto y si llega a 0 se muere
		outpkt->type= inpkt->type;
		outpkt->coord_x = inpkt->coord_x;
		outpkt->coord_y = inpkt->coord_y;
		outpkt->humedad=inpkt->humedad;		
		
			
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(FijoMsg)) == SUCCESS) {
				busy = TRUE;

			}
		}
	     
	}

    
   
     if(inpkt->type == 4){
	    

	 am_addr_t direccion_sig = call AMPacket.source(msg);
	//setLeds(1,0,0);        
         destino = inpkt->nodeid_d;
         sig_salto = inpkt->nodeid_origen_msg;
         coste = inpkt->coste + 1;
         
         resultado = actualizar_tabla(destino, sig_salto, direccion_sig, coste);
         
	if(resultado==TRUE){
		setLeds(1,0,0);}

         //si se ha actualizado la tabla, reenviamos la informacion que se ha actualizado al resto de nodos
         if(resultado){
                     
             outpkt->nodeid_origen_msg = TOS_NODE_ID;
             outpkt->type = 4;  
             outpkt->coste = coste;  
	             
		
             if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(FijoMsg)) == SUCCESS) {
                busy = TRUE;
		setLeds(0,0,1);             
		}
         }


     }
   return msg;
  }
}
