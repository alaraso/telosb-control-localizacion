

#include "Timer.h"
#include "TestSerial.h"

module TestSerialC {
  uses {
    interface SplitControl as SerialControl;
    interface Leds;
    interface Boot;
    interface Receive as SerialReceive;
    interface AMSend as SerialSend ;
    interface Timer<TMilli> as Timer0;
    interface Timer<TMilli> as Timer1;
    interface Timer<TMilli> as Timer2;
    interface Packet as SerialPacket;
  }

  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend as RadioSend;
  uses interface Receive as RadioReceive;
  uses interface SplitControl as RadioControl;
  uses interface CC2420Packet;

}
implementation {

//Definimos el tipo que almacenaremos en la tabla de encaminamiento
typedef nx_struct entrada {
    nx_uint16_t destino;
    nx_uint16_t sig_salto;
    nx_am_addr_t direccion_sig_salto;
    nx_uint8_t coste;
    nx_uint8_t tiempo;
  } entrada;


  message_t packet;
  message_t pkt;

  bool locked = FALSE;
  bool busy = FALSE;
  int estado;
  uint16_t nodo=0;
  
  
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





  event void Boot.booted() {
    call Timer0.startPeriodic(1000);
    call Timer1.startPeriodic(3000);
    call SerialControl.start();
    call RadioControl.start();
  }
  
//Funcion para los leds:
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

//Para apagar los leds cuando se encienden 
  event void Timer2.fired(){
     setLeds(0,0,0);
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

         if (call RadioSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(FijoMsg)) == SUCCESS) {
			
              busy = TRUE;
         }
      }

  }





//*********Función para actualizar la tabla de encaminamiento

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
	for(i=0; i<TAM_MAX; i++){
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



//  ***Timer que incrementa el tiempo que una entrada ha estado en la tabla, si la entrada llega a 100 segundo se elimina la entrada de la tabla
//
//	Para borrar las entradas de la tabla se ponen a 0 con el coste al máximo

  event void Timer0.fired() {
	uint8_t i;
        for(i = 0; i < tamano_tabla; i++){
           tabla[i].tiempo += 1;	
	   if(tabla[i].tiempo == 100){			
	       tabla[i].destino = 0;
	       tabla[i].sig_salto=0;
	       tabla[i].direccion_sig_salto= 0;
	       tabla[i].coste = 255;		
	   }		
	}

  }






//Envío mensaje de alerta al nodo o todos los nodos 
// 	por terminar****************
void alerta(uint8_t nodo_alarma){
	if (!busy) {
		FijoMsg* fijopkt = (FijoMsg*)(call Packet.getPayload(&pkt, sizeof(FijoMsg)));

		if (fijopkt == NULL) {
			return;
		}
		fijopkt->nodeid_origen = TOS_NODE_ID;
		fijopkt->nodeid_origen_msg = TOS_NODE_ID;
		fijopkt->nodeid_d = nodo_alarma;
		fijopkt->nodeid_d_msg=0;
		fijopkt->coste = 0;
		fijopkt->type = 2;
		fijopkt->datos = 20;	//usamos el campo datos del tipo dos para el ttl(time to live)
		fijopkt-> num_sec = 0;
		if (call RadioSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(FijoMsg)) == SUCCESS) {
			setLeds(0,0,0);
			busy = TRUE;
		}
	}
}






//Recivo un mensaje por radio
//si recibo un mensaje de una bs he de responder como un ack 

event message_t* RadioReceive.receive(message_t* msg, void* payload, uint8_t len){
	FijoMsg* inpkt = (FijoMsg*)payload;
	FijoMsg* outpkt = (FijoMsg*)(call Packet.getPayload(&pkt, sizeof(FijoMsg)));
	am_addr_t destino_movil=call AMPacket.source(msg);

	origen = inpkt->nodeid_origen;
	
	
		

		
     switch(inpkt->type){


	case 3:

		if(!busy){
		if(inpkt->datos ==0){
		outpkt->nodeid_d = origen;
		outpkt->nodeid_d_msg = origen;
		outpkt->nodeid_origen = TOS_NODE_ID;
		setLeds(1,0,0);
		//Obtenemos rssi como un entero sin signo.
		rssi1 = getRssi(msg);
		if(rssi1>=128){
			rssi2 = rssi1 - 45 - 256;
		}
		else {
			rssi2 = rssi1 - 45;
		}
		outpkt->datos = rssi2;
		outpkt->type=3;
		//HAY QUE COMPROBAR LA DIRECCION CON LA QUE LLEGA EL MENSAJE Y ENVIARLO A ESA MISMA (MENSAJE DIRIGIDO)
		
		if (call RadioSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(FijoMsg)) == SUCCESS) {
			busy = TRUE;
		}   
	}
}
	break;



			//mensaje de tipo 4 llega con datos de los nodos móviles y los enviamos al pc segun el estado
	case 1:
		if(inpkt->nodeid_d_msg ==1 && inpkt->nodeid_d ==1){		
		if ((estado == 2) || (estado == 1 && nodo==origen)){

		destino = inpkt->nodeid_d;
		sig_salto = inpkt->nodeid_origen_msg;
		coste = inpkt->coste + 1;
		setLeds(0,1,0);
		resultado = actualizar_tabla(destino, sig_salto, destino_movil, coste);
		//actualizamos la tabla y enviamos los datos que nos llegan al pc

		if (locked) {
			break;
		}
		else {
			
			
			test_serial_msg_t* rcm = (test_serial_msg_t*)call SerialPacket.getPayload(&packet, sizeof(test_serial_msg_t));
			if (rcm == NULL) {break;}
			if (call SerialPacket.maxPayloadLength() < sizeof(test_serial_msg_t)) {
				break;
			}
			rcm->tipo=1;
			rcm->nodeid=inpkt->nodeid_origen;	
			rcm->dato = inpkt->datos;   //nodeid_d_msg ;
			rcm->humedad = inpkt->humedad;
			rcm->cord_x = inpkt ->coord_x;
			rcm->cord_y = inpkt ->coord_y;
			if (call SerialSend.send(AM_BROADCAST_ADDR, &packet, sizeof(test_serial_msg_t)) == SUCCESS) {
				locked = TRUE;
			}
		    }
		}
	}
		
	break;



	}



	return msg;
}


 

//Recivo un mensaje  por el puerto serie 
  event message_t* SerialReceive.receive(message_t* bufPtr, void* payload, uint8_t len) {

    if (len != sizeof(test_serial_msg_t)) 
	{return bufPtr;}
    else {
      test_serial_msg_t* rcm = (test_serial_msg_t*)payload;

     
	setLeds(0,1,0);

	estado = rcm->tipo;
        nodo = rcm->nodeid;

	//En función del tipo que recibo del pc hago una cosa u otra
	switch (rcm->tipo) {
	    case 1:
		
		break;
	    case 2:
		
		break;
	    case 4:
		//se llama a una función que envíe una alerata
		alerta(nodo);
		break;

	    default:
	
		break;
	}
      
	
      return bufPtr;
    }
  }










//Mensaje enviado por Radio
  event void RadioSend.sendDone(message_t* bufPtr, error_t error){
	if(&pkt == bufPtr){
	 
	busy = FALSE;
	}
}


//Mensaje enviado por el puerto serie completado
  event void SerialSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }


//Se enciend la radio
event void RadioControl.startDone(error_t err){
	if (err == SUCCESS) {	
	}
	else {
	call RadioControl.start();
	}
}


  event void SerialControl.startDone(error_t err) {
	if (err == SUCCESS) {	
	}
	else {
	call SerialControl.start();
	}
}




  event void SerialControl.stopDone(error_t err) {}
  event void RadioControl.stopDone(error_t err){}
}




