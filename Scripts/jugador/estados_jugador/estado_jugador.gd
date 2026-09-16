extends Node
class_name EstadoJugador

signal peticion_transmision_estado( nuevo_estado: Jugador.Estado, datos : DatosEstadoJugador)

var animacion_jugador : AnimationPlayer = null
var jugador : Jugador = null
var comportamiento_ia : ComportamientoIA = null 
var datos_juego : DatosEstadoJugador = null

func setup( jugador_entrada : Jugador, animacion_entrada : AnimationPlayer, _comportamiento_ia : ComportamientoIA, _datos : DatosEstadoJugador) -> void:
	jugador = jugador_entrada
	animacion_jugador = animacion_entrada
	comportamiento_ia = _comportamiento_ia
	datos_juego = _datos
	
func cambiar_estado(nuevo_estado : Jugador.Estado, datos : DatosEstadoJugador = DatosEstadoJugador.new()) -> void:
	peticion_transmision_estado.emit(nuevo_estado, datos_juego)
