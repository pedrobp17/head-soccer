extends EstadoJuego
class_name EstadoJuegoFin

func _enter_tree() -> void:
	var jugador_ganador := controlador.ganador_partido()
	EventBus.fin_partido.emit(jugador_ganador, ControladorPartido.marcador)
