
#ifndef TEST_SERIAL_H
#define TEST_SERIAL_H

enum {
	AM_MOVIL=6,
	TIMER_PERIOD_MILLI=250,	
	TAM_MAX=20,
	AM_TEST_SERIAL_MSG = 0x89
};

typedef nx_struct test_serial_msg {
  
  nx_uint8_t  tipo;		//Tipo de mensaje o tipo de dato 
  nx_uint16_t  nodeid;		//Nodo al que se hace referencia
  nx_uint16_t dato;		//Dato que se transmite	
  nx_uint16_t humedad;
  nx_int8_t cord_x;
  nx_int8_t cord_y;
  
} test_serial_msg_t;



typedef nx_struct FijoMsg {
  nx_uint16_t nodeid_origen;		//Este es el 1 que envia 
  nx_uint16_t nodeid_origen_msg;	//Este es el que me acaba de enviar el msg
  nx_uint16_t nodeid_d;			//destino final
  nx_uint16_t nodeid_d_msg;		//destino msg
  nx_uint8_t coste;
  nx_uint8_t type;			//tipo de mensaje 
  nx_int16_t datos;
  nx_int16_t humedad;
  nx_int8_t coord_x;
  nx_int8_t coord_y;			
  nx_uint8_t num_sec;			//Numero de secuencia para msg rssi
} FijoMsg;



#endif
