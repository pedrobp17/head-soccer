extends EstadoJuego
class_name EstadoJuegoReseteo


func _enter_tree() -> void:
	EventBus.reposicionar.emit(datos_juego.es_visitante)
	peticion_transmitir_estado.emit(ControladorPartido.Estado.JUGANDO)
