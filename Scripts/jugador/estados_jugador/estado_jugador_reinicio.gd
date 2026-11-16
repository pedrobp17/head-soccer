extends EstadoJugador
class_name EstadoJugadorReinicio


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	jugador.velocity = Vector2.ZERO
	jugador.position = jugador.posicion_aparicion
	comportamiento_ia.reiniciar()
	EventBus.reposicionar_pelota.emit(datos_juego.es_visitante)
	cambiar_estado(datos_juego.nombre)
	
