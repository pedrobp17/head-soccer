extends Node
class_name EstadoJugador

signal peticion_transmision_estado( nuevo_estado: Jugador.Estado)


var jugador : Jugador = null
	
func setup( _jugador: Jugador) -> void:
	jugador = _jugador
	
