extends EstadoJuego
class_name EstadoJuegoJugando

func _enter_tree() -> void:
	EventBus.gol.connect(on_juegador_marcado.bind())

func _process(delta: float) -> void:
	controlador.tiempo_restante -= delta
	if controlador.tiempo_restante <= 0:
		if controlador.marcador[0] == controlador.marcador[1]:
			peticion_transmitir_estado.emit(ControladorPartido.Estado.TIEMPO_EXTRA)
		else:
			peticion_transmitir_estado.emit(ControladorPartido.Estado.FIN)


func on_juegador_marcado ( jugador : String) -> void:
	cambiar_estado(ControladorPartido.Estado.GOL,  DatosEstadoJuego.build().set_jugador_anotador(jugador))
