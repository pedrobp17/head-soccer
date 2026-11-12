extends EstadoJuego
class_name EstadoJuegoJugando

func _enter_tree() -> void:
	EventBus.gol.connect(on_gol)

func _process(delta: float) -> void:
	controlador.tiempo_restante -= delta
	if controlador.fin_partido():
		if controlador.enfrentamiento.empate():
			peticion_transmitir_estado.emit(ControladorPartido.Estado.TIEMPO_EXTRA)
		else:
			peticion_transmitir_estado.emit(ControladorPartido.Estado.FIN)


func on_gol(es_visitante: bool) -> void:
	if controlador.estado_actual != self:
		return
	cambiar_estado(ControladorPartido.Estado.GOL, DatosEstadoJuego.build().set_es_visitante(es_visitante))


func gol_valido() -> bool:
	return true

func cargar_poder() -> bool:
	return true

func uso_poder() -> bool:
	return true
