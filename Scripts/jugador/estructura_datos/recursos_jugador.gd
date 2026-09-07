class_name RecursosJugador
extends Resource

const ESPIRITU = 1

@export var nombre : String
@export var espiritu : bool
@export var poderes : Array = []
@export var estadisticas : Dictionary = {}
@export var equipo : String 
@export var configuracion_pie : Dictionary = {}
@export var configuracion_capsula : Dictionary = {}

func _init( jugador_nombre : String, jugador_espiritu : int, jugador_poderes : Array, jugador_estadisticas : Dictionary, jugador_equipo : String, jugador_configuracion_pie : Dictionary, jugador_configuracion_capsula : Dictionary ) -> void:
	 
	nombre = jugador_nombre
	espiritu = (jugador_espiritu == ESPIRITU)
	poderes = jugador_poderes 
	estadisticas = jugador_estadisticas 
	equipo = jugador_equipo 
	configuracion_capsula = jugador_configuracion_capsula 
	configuracion_pie = jugador_configuracion_pie
