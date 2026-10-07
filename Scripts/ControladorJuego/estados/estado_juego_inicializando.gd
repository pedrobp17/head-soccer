extends EstadoJuego
class_name EstadoJuegoInicializando

func _exit_tree() -> void:
	EventBus.mostrar_personajes.emit()
