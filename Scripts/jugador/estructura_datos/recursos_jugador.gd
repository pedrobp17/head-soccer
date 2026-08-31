class_name RecursosJugador
extends Resource

const ESPIRITU = 1

@export var nombre : String
@export var espiritu : bool
@export var poderes : Array = []
@export var estadisticas : Dictionary = {}
@export var equipo : String 

func _init( jugador_nombre : String, jugador_espiritu : int, jugador_poderes : Array, jugador_estadisticas : Dictionary, jugador_equipo : String) -> void:
	 
	nombre = jugador_nombre
	espiritu = (jugador_espiritu == ESPIRITU)
	poderes = jugador_poderes 
	estadisticas = jugador_estadisticas 
	equipo = jugador_equipo 
