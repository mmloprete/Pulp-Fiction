% personaje(Personaje, Profesion).
personaje(pumkin, ladron([licorerias, estacionesDeServicio])).
personaje(honeyBunny, ladron([licorerias, estacionesDeServicio])).
personaje(vincent, mafioso(maton)).
personaje(jules, mafioso(maton)).
personaje(marsellus, mafioso(capo)).
personaje(winston, mafioso(resuelveProblemas)).
personaje(mia, actriz([foxForceFive])).
personaje(butch, boxeador).

% pareja(Persona, OtraPersona)
pareja(marsellus, mia).
pareja(pumkin, honeyBunny).

%trabajaPara(Empleador, Empleado)
trabajaPara(marsellus, vincent).
trabajaPara(marsellus, jules).
trabajaPara(marsellus, winston).

/*
1. esPeligroso/1. Nos dice si un personaje es peligroso. Eso ocurre cuando:
    - realiza alguna actividad peligrosa: ser matón, o robar licorerías. 
    - tiene empleados peligrosos
*/

esPeligroso(Personaje):-
    personaje(Personaje, mafioso(maton)).

esPeligroso(Personaje):-
    personaje(Personaje, ladron(Lugares)),
    member(licorerias, Lugares).

esPeligroso(Personaje):-
    trabajaPara(Personaje, Empleado),
    esPeligroso(Empleado).

/*
2. duoTemible/2 que relaciona dos personajes cuando son peligrosos y además son pareja o amigos.
Considerar que Tarantino también nos dió los siguientes hechos:
    amigo(vincent, jules).
    amigo(jules, jimmie).
    amigo(vincent, elVendedor).
*/

amigo(vincent, jules).
amigo(jules, jimmie).
amigo(vincent, elVendedor).

duoTemible(Personaje, OtroPersonaje):-
    esPeligroso(Personaje),
    esPeligroso(OtroPersonaje),
    pareja(Personaje, OtroPersonaje).

duoTemible(Personaje, OtroPersonaje):-
    esPeligroso(Personaje),
    esPeligroso(OtroPersonaje),
    amigo(Personaje, OtroPersonaje).

/*
3.  estaEnProblemas/1: un personaje está en problemas cuando 
    el jefe es peligroso y le encarga que cuide a su pareja o bien, tiene que ir a buscar a un boxeador. 
    Además butch siempre está en problemas. 
*/

%encargo(Solicitante, Encargado, Tarea). 
%las tareas pueden ser cuidar(Protegido), ayudar(Ayudado), buscar(Buscado, Lugar)

encargo(marsellus, vincent,   cuidar(mia)).
encargo(vincent,  elVendedor, cuidar(mia)).
encargo(marsellus, winston, ayudar(jules)).
encargo(marsellus, winston, ayudar(vincent)).
encargo(marsellus, vincent, buscar(butch, losAngeles)).

estaEnProblemas(butch).

estaEnProblemas(Personaje):-
    trabajaPara(Jefe, Personaje),
    pareja(Jefe, Pareja),
    encargo(Jefe, Personaje, cuidar(Pareja)).

estaEnProblemas(Personaje):-
    trabajaPara(Jefe, Personaje),
    personaje(Boxeador, boxeador),
    encargo(Jefe, Personaje, buscar(Boxeador, _)).

/*
4.  sanCayetano/1:  es quien a todos los que tiene cerca les da trabajo (algún encargo). 
Alguien tiene cerca a otro personaje si es su amigo o empleado. 
*/

sanCayetano(Personaje):-
    tieneCerca(Personaje, _),
    forall(tieneCerca(Personaje, OtroPersonaje), encargo(Personaje, OtroPersonaje, _)).

tieneCerca(Personaje, OtroPersonaje):-
    trabajaPara(Personaje, OtroPersonaje).

tieneCerca(Personaje, OtroPersonaje):-
    pareja(Personaje, OtroPersonaje).

/*
5. masAtareado/1. Es el más atareado aquel que tenga más encargos que cualquier otro personaje.
*/

masAtareado(Personaje):-
    cantidadDeEncargos(Personaje, Cantidad),
    forall((cantidadDeEncargos(OtroPersonaje, OtraCantidad), Personaje \= OtroPersonaje), Cantidad >= OtraCantidad).

cantidadDeEncargos(Personaje, Cantidad):-
    personaje(Personaje, _),
    findall(1, encargo(_, Personaje, _), Encargos),
    sumlist(Encargos, Cantidad).
    
/*
6. personajesRespetables/1: genera la lista de todos los personajes respetables. Es respetable
cuando su actividad tiene un nivel de respeto mayor a 9. Se sabe que:
● Las actrices tienen un nivel de respeto de la décima parte de su cantidad de peliculas.
● Los mafiosos que resuelven problemas tienen un nivel de 10 de respeto, los matones 1 y los capos
20.
● Al resto no se les debe ningún nivel de respeto.
*/

actividad(actriz(Peliculas), Respeto):-
    length(Peliculas, CantidadPelis),
    Respeto is CantidadPelis / 10.

actividad(mafioso(resuelveProblemas), 10).
actividad(mafioso(maton), 1).
actividad(mafioso(capo), 20).
actividad(_, 0).

respetable(Personaje):-
    personaje(Personaje, Profesion), 
    actividad(Profesion, Respeto),
    Respeto > 9.

personajesRespetables(Respetables):-
    findall(personaje(Personaje), respetable(Personaje), Respetables).

/*
7. hartoDe/2: un personaje está harto de otro, cuando todas las tareas asignadas al primero requieren interactuar con el segundo 
(cuidar, buscar o ayudar) o un amigo del segundo. Ejemplo:

? hartoDe(winston, vincent).
true 
% winston tiene que ayudar a vincent, y a jules, que es amigo de vincent. 

*/

hartoDe(Personaje, Otro):-
    personaje(Personaje, _),
    personaje(Otro, _),
    forall(encargo(_, Personaje, _), interactuar(Personaje, Otro)).


interactuar(Personaje, Otro):-
    encargo(_, Personaje, cuidar(Otro)).

interactuar(Personaje, Otro):-
    encargo(_, Personaje, ayudar(Otro)).

interactuar(Personaje, Otro):-
    encargo(_, Personaje, buscar(Otro, _)).

interactuar(Personaje, Otro):-
    amigo(Otro, Tercero),
    encargo(_, Personaje, cuidar(Tercero)).

interactuar(Personaje, Otro):-
    amigo(Otro, Tercero),
    encargo(_, Personaje, ayudar(Tercero)).

interactuar(Personaje, Otro):-
    amigo(Otro, Tercero),
    encargo(_, Personaje, buscar(Tercero, _)).

/*
8. Ah, algo más: nuestros personajes tienen características. Lo cual es bueno, porque nos ayuda a diferenciarlos cuando están de a dos. 
Por ejemplo:
*/
caracteristicas(vincent,  [negro, muchoPelo, tieneCabeza]).
caracteristicas(jules,    [tieneCabeza, muchoPelo]).
caracteristicas(marvin,   [negro]).
/*    
Desarrollar duoDiferenciable/2, que relaciona a un dúo (dos amigos o una pareja) en el que uno tiene al menos una característica que el otro no. 
*/ 

duo(Personaje, OtroPersonaje):-
    pareja(Personaje, OtroPersonaje).

duo(Personaje, OtroPersonaje):-
    amigo(Personaje, OtroPersonaje).

duoDiferenciable(Personaje, OtroPersonaje):-
    duo(Personaje, OtroPersonaje),
    caracteristicas(Personaje, Caracteristicas),
    caracteristicas(OtroPersonaje, OtrasCaracteristicas),
    comparacionListas(Caracteristicas, OtrasCaracteristicas),
    comparacionListas(OtrasCaracteristicas, Caracteristicas).

comparacionListas(Lista, OtraLista):-
    member(Elemento, Lista),
    not(member(Elemento, OtraLista)).