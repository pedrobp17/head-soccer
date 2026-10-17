extends EstadoJuego
class_name EstadoJuegoFin

func _ready() -> void:
	EventBus.fin_partido.emit()
