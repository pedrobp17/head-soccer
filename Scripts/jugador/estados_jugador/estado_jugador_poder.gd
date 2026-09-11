extends EstadoJugador
class_name EstadoJugadorPoder

func _entre_tree() -> void:
	jugador.poder.ejecutar()
	peticion_transmision_estado.emit(Jugador.Estado.JUGANDO)
