extends Node2D

const PREFAB_JUGADOR := preload("res://Escenas/jugador/jugador.tscn")

@export var local : String
@export var visitante : String

@onready var aparicion : Node2D = %Apariciones

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	aparecer_jugador(local, Jugador.BANDO["local"])
	aparecer_jugador(visitante, Jugador.BANDO["visitante"])
	var jugador : Jugador = get_children().filter(func (p): return p is Jugador)[0]
	jugador.esquema_control = Jugador.ControlScheme.P1
	jugador.set_imagen_personaje()

func aparecer_jugador( jugador : String, identificador_bando : int) -> void:
	var datos_jugador := DatosJugadores.get_jugador(jugador)
	var posicion_jugador := aparicion.get_child(0).global_position as Vector2
	var instancia_jugador := crear_jugador(posicion_jugador, datos_jugador, identificador_bando)
	add_child(instancia_jugador)
	
func crear_jugador(posicion_jugador : Vector2, datos_jugadores : RecursosJugador, identificador_bando : int) -> Jugador:
	var jugador := PREFAB_JUGADOR.instantiate()
	jugador.inicializar(posicion_jugador, datos_jugadores, identificador_bando )
	return jugador
