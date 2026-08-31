extends Node
class_name EstadoJugador

signal peticion_transmision_estado( nuevo_estado: Jugador.Estado)

var animacion_jugador : AnimationPlayer = null
var jugador : Jugador = null
	
func setup( jugador_entrada : Jugador, animacion_entrada : AnimationPlayer) -> void:
	jugador = jugador_entrada
	animacion_jugador = animacion_entrada
	
