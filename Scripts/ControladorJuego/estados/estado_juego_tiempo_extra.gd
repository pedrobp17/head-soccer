extends EstadoJuego
class_name  EstadoJuegoTiempoExtra

func _enter_tree() -> void:
	EventBus.gol.connect(on_gol)
	EventBus.en_tiempo_extra.emit()
	
func gol_valido() -> bool:
	return true

func on_gol( es_visitante: bool ) -> void:
	controlador.incrementar_marcador(es_visitante)
	cambiar_estado(ControladorPartido.Estado.FIN)
	
func uso_poder() -> bool:
	return false
