class_name RecursosJugador
extends Resource

const ESPIRITU = 1

@export var nombre : String
@export var espiritu : bool
@export var poderes : Array = []
@export var velocidad : int
@export var salto : int
@export var poder : int
@export var golpe : int
@export var equipo : String

func _init( jugador_nombre : String, jugador_espiritu : int, jugador_poderes : Array, jugador_velocidad : int, jugador_salto : int, jugador_poder : int, jugador_golpe : int, jugador_equipo : String) -> void:
	 
	nombre = jugador_nombre
	espiritu = (jugador_espiritu == ESPIRITU)
	poderes = jugador_poderes 
	velocidad = jugador_velocidad 
	salto =  jugador_salto
	poder = jugador_poder
	golpe = jugador_golpe 
	equipo = jugador_equipo 
