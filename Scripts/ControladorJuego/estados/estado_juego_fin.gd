extends EstadoJuego
class_name EstadoJuegoFin

func _ready() -> void:
	var jugador_ganador := controlador.ganador_partido()
	EventBus.fin_partido.emit()
