
Trabajo Redes de sensores y sistemas automáticos: Control y localización de bomberos 





Para introducir cualquier módulo en un nodo debemos situarse en el directorio correspondiente y ejecutar:

	make telosb install,[node-id]

sustituyendo [node-id] por el número de identeficiación que queremos asignar al nodo. Cabe destacar que el nodo 1 
está reservado para la estación base. 



Para ejecutar el programa de la estacion base situarse, en el directorio pc-mote y ejectar:

	java -comm serial@/dev/ttyUSB0:telosb	




Este programa explora las capacidades de los sensores telosb en un caso de uso para control y localización de bomberos en un incendio. En él donde suponemos unos sesnores fijos situdados previamente en el edificio, donde conocemos su situación ya mapeada a la estación base. Tenemos una estación base que estaría fuera del edificio conectada a algún sensor fijo para tener comunicación con los sensores móviles y mostrar la información que estos generan. Los nodos móviles, que llevarian los bomberos, miden periodicamente parámetros como la temperatura, humedad y localización(la localización se calcula midiendo la distancia entre el nodo móvil y los 4 nódos fijos más cercanos) y la envían al nodo fijo más cercano, desde aqui la información se encamina hacia el nodo fijo. El encaminamiento se realiza mediante tablas de encaminamiento, donde el nodo fijo va inundando la red indicando hacia donde se tiene que enviar la información y los nodos fijos aprenden para cuando tengan que enviar información de nodos móviles. Además este encaminamiento se va actualizando, por lo que si algun nodo fijo se desconecta las tablas de encamientamiento se actualizarian y la comuniación seguiría activa. Desde la estación base se puede visualizar la información recibida por los nodos móviles (localización, temperatura y humedad) y además se puede enviar una alerta a los nodos móviles que encendería un led rojo en el nodo móvil. 


El programa está escrito en nesC, es una extensión de c, lenguaje basado en eventos para construir aplicaciones para sistemas TinyOS.

Pruebas realizadas con éxito usando telosb MTM-CM5000-MSP