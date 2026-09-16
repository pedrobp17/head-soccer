extends EstadoJuego
class_name EstadoJuegoReseteo


func _enter_tree() -> void:
	EventBus.reposicionar.emit(datos_juego.jugador_anotador)
	peticion_transmitir_estado.emit(ControladorPartido.Estado.JUGANDO)
