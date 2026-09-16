extends EstadoJugador
class_name EstadoJugadorReinicio


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	jugador.velocity = Vector2.ZERO
	jugador.position = jugador.posicion_aparicion
	EventBus.reposicionar_pelota.emit(datos_juego.jugador_anotador)
	peticion_transmision_estado.emit(Jugador.Estado.JUGANDO)
	
