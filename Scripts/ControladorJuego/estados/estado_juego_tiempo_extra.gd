extends EstadoJuego
class_name  EstadoJuegoTiempoExtra

func _enter_tree() -> void:
	EventBus.gol.connect(on_gol)

func gol_valido() -> bool:
	return true

func on_gol( jugador_anotador : String ) -> void:
	controlador.incrementar_marcador(jugador_anotador)
	cambiar_estado(ControladorPartido.Estado.FIN)
