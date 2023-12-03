
/**
 * Java-side application for testing serial port communication.
 * 
 *
 * @author Phil Levis <pal@cs.berkeley.edu>
 * @date August 12 2005
 *
 * ejemplo de uso: java TestSerial -comm serial@/dev/ttyUSB0:telosb
 *
 */

import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

import java.util.*;

public class TestSerial implements MessageListener {

  private MoteIF moteIF;
  private int contador;	
  private String estado;
   
  

  public TestSerial(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new TestSerialMsg(), this);
  }

//Función leer por la entrada estandar:
  public static int leer() {
    int escrito=0;   
    Scanner scanner = new Scanner(System.in);
    // System.out.print("Ingrese un parámetro: ");
    String parametro = scanner.nextLine();
    // System.out.println("El parámetro ingresado es: " + parametro);
     

    try {
        escrito = Integer.parseInt(parametro);
    } catch (NumberFormatException e) {
        // Handle exception
	System.out.println("Error: Ingresar un número \n");
 	escrito = -1;
    }
	
	return escrito;
  }



//Función para enviar paquetes 
  public void sendPackets(int tipo, int nodo ) {
  
    TestSerialMsg payload = new TestSerialMsg();
    
    try {

	System.out.println("Sending packet " + tipo);
	payload.set_tipo((short)tipo);
	payload.set_nodeid((short)nodo);
	payload.set_dato(100);
	moteIF.send(0, payload);

	try {Thread.sleep(1000);}
	catch (InterruptedException exception) {}
      
    }
    catch (IOException exception) {
      System.err.println("Exception thrown when sending packets. Exiting.");
      System.err.println(exception);
    }
  }

//EL mensaje recibido se imprime por pantalla 
  public void messageReceived(int to, Message message) {
    TestSerialMsg msg = (TestSerialMsg)message;

    //System.out.println("Received packet sequence number " + msg.get_dato());

	switch (msg.get_tipo()) {
	    case 1:
		System.out.println("Temperatura del nodo "+msg.get_nodeid() +": "+ msg.get_dato()+"ºC");
		System.out.println("Humedad del nodo "+msg.get_nodeid()+": "+ msg.get_humedad()+"%");
		System.out.println("Localización del nodo "+msg.get_nodeid()+" : " + msg.get_cord_x()+"x"+msg.get_cord_y() +"\n");
		break;
	    case 2:
		System.out.println("Temperatura del nodo "+msg.get_nodeid() +": "+ msg.get_dato()+"ºC");
		System.out.println("Humedad del nodo "+msg.get_nodeid()+": "+ msg.get_humedad()+"%");
		System.out.println("Localización del nodo "+msg.get_nodeid()+" : " + msg.get_cord_x()+"x"+msg.get_cord_y() +"\n");

		break;

	    case 3:
		System.out.println("Humedad en el nodo "+msg.get_nodeid()+": " + msg.get_dato());

		break;
	    case 4:
		System.out.println("Localización del nodo"+msg.get_nodeid()+": " + msg.get_dato());


	    default:
	
		break;
	}


  }
  
//Funcionamiento 
  private static void usage() {
    System.err.println("usage: TestSerial [-comm <source>]");
  }
  

//MAIN
  public static void main(String[] args) throws Exception {
    String source = null;
	int opcion=0;
	int nodo=0;
	boolean status=true;



//Comprobamos que los parámetros son correctos 
    if (args.length == 2) {
      if (!args[0].equals("-comm")) {
	usage();
	System.exit(1);
      }
      source = args[1];
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }

    PhoenixSource phoenix;
    
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }

    MoteIF mif = new MoteIF(phoenix);
    TestSerial serial = new TestSerial(mif);


    //while(true){		

	// serial.sendPackets(leer());
//}

	try {Thread.sleep(100);}
	catch (InterruptedException exception) {}

	while (status) {

	if(opcion==0 || opcion==3|| opcion==4||opcion==5){
		System.out.println("Elija una opción:");
		System.out.println("1. Seleccionar un nodo");
		System.out.println("2. Ver todos los nodos");
		System.out.println("3. Enviar alerta a un nodo");
		System.out.println("4. Enviar alerta global");
		System.out.println("5. Salir");
		System.out.print("Opción elegida: ");
	}
        
	opcion = leer();
            

	if(opcion == 1 || opcion ==3){
		System.out.println("Elija el nodo: ");
		nodo = leer();
}	   

		//nodo 0 == Todos los nodos 






            switch (opcion) {
		case 0:
                    System.out.println("Pausar envío de datos ");
		    serial.sendPackets(3,0);
		break;

                case 1:
                    System.out.println("Ha elegido la opción 1");
			System.out.println("***************************\n");
			System.out.println("Para pausar introduzca un: 0\n");
			System.out.println("***************************");
			serial.sendPackets(1,nodo);
                    break;

                case 2:
                    System.out.println("Ha elegido la opción 2");
			System.out.println("***************************\n");
			System.out.println("Para pausar introduzca un: 0\n");
			System.out.println("***************************");
			serial.sendPackets(2,0);
                    break;

               case 3:
			System.out.println("***************************\n");
			System.out.println("Enviando alerta al nodo: "+nodo+"\n");
			System.out.println("***************************");
			serial.sendPackets(4,nodo);
                    break;

		case 4:
			System.out.println("***************************\n");
			System.out.println("Enviando alerta global\n");
			System.out.println("***************************");
			serial.sendPackets(4,0);
		    break;

		case 5:
			status=false;
			break;

                default:
                    System.out.println("Opción inválida. Intente de nuevo.");
			
            }


   	}

	System.exit(0);
  }


}
