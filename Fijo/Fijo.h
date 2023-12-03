// $Id: Fijo.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef FIJO_H
#define FIJO_H

enum {
  AM_FIJO = 6,
  TIMER_PERIOD_MILLI = 1000, //1 segundo
  TAM_MAX = 20
};


typedef nx_struct FijoMsg {
  nx_uint16_t nodeid_origen;		//Este es el 1 que envia 
  nx_uint16_t nodeid_origen_msg;	//Este es el que me acaba de enviar el msg
  nx_uint16_t nodeid_d;
  nx_uint16_t nodeid_d_msg;
  nx_uint8_t coste;
  nx_uint8_t type;			//tipo de mensaje 
  nx_int16_t datos;
  nx_int16_t humedad;
  nx_int8_t coord_x;
  nx_int8_t coord_y;			
  nx_uint8_t num_sec;			//Numero de secuencia para msg rssi
} FijoMsg;




#endif
