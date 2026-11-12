extends EstadoJuego
class_name EstadoJuegoTiempoExtra

func _enter_tree() -> void:
	EventBus.gol.connect(on_gol)
	EventBus.en_tiempo_extra.emit()
	
func gol_valido() -> bool:
	return true

func on_gol(es_visitante: bool) -> void:
	if controlador.estado_actual != self:
		return
	controlador.incrementar_marcador(es_visitante)
	cambiar_estado(ControladorPartido.Estado.FIN, DatosEstadoJuego.build().set_tiempo_extra(true))
	
func uso_poder() -> bool:
	return false
