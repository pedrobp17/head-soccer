extends Node2D

const PREFAB_JUGADOR := preload("res://Escenas/jugador/jugador.tscn")

@export var porteria_local : Porteria
@export var porteria_visitante : Porteria

@onready var pelota : Pelota = $Pelota
@onready var aparicion : Node2D = %Apariciones

var jugador_local : Jugador = null
var jugador_visitante : Jugador = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	jugador_local = aparecer_jugador(ControladorPartido.enfrentamiento.jugador_local, Jugador.BANDO[false], ControladorPartido.enfrentamiento.poder_local)
	porteria_local.inicializar(ControladorPartido.enfrentamiento.jugador_visitante)
	jugador_visitante = aparecer_jugador(ControladorPartido.enfrentamiento.jugador_visitante, Jugador.BANDO[true], ControladorPartido.enfrentamiento.poder_visitante)
	porteria_visitante.inicializar(ControladorPartido.enfrentamiento.jugador_local)
	set_controladores_personajes()
	
func aparecer_jugador( jugador : String, identificador_bando : int, poder : String) -> Jugador:
	var datos_jugador := DatosJugadores.get_jugador(jugador)
	var posicion_jugador := aparicion.get_child(0).global_position as Vector2
	var instancia_jugador := crear_jugador(posicion_jugador, datos_jugador, identificador_bando, poder)
	add_child(instancia_jugador)
	return instancia_jugador
	
func crear_jugador(posicion_jugador : Vector2, datos_jugadores : RecursosJugador, identificador_bando : int, poder : String) -> Jugador:
	var jugador := PREFAB_JUGADOR.instantiate()
	jugador.inicializar(posicion_jugador, datos_jugadores, pelota, identificador_bando, poder )
	return jugador

func set_controladores_personajes() -> void:
	if ControladorPartido.jugando_solitario():
		jugador_local.esquema_control = Jugador.ControlScheme.P1
		jugador_visitante.esquema_control = Jugador.ControlScheme.IA
	else:
		jugador_local.esquema_control = Jugador.ControlScheme.P1
		jugador_visitante.esquema_control = Jugador.ControlScheme.P2
	
	
