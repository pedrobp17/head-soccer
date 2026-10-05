extends EstadoJuego
class_name EstadoJuegoFin

func _ready() -> void:
	print("estado fin")
	var jugador_ganador := controlador.ganador_partido()
	EventBus.fin_partido.emit()
