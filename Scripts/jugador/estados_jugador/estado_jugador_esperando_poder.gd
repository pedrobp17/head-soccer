extends EstadoJugador
class_name EstadoJugadorEsperandoPoder


func _enter_tree() -> void:
	jugador.pie.set_monitoring_detector_poder(true)
	EventBus.pie_contacto_pelota_en_poder.connect(on_pie_contacto_pelota_en_poder)
	jugador.set_animacion("poder")
	nombre_estado = Jugador.Estado.ESPERANDO_PODER
	
func _physics_process(delta: float) -> void:
	if jugador.esquema_control == Jugador.ControlScheme.IA:
		#comportamiento_ia.process_ia()
		pass
	else:
		movimiento_player(delta)

func movimiento_player(delta : float) -> void:
	movimiento_general(delta)
		
	if KeyUtils.is_action_just_pressed( jugador.esquema_control, KeyUtils.Accion.PATADA ):
		jugador.pie.golpear()
		
	
	if jugador.estadisticas.get_estadistica("vida") <= 0:
		cambiar_estado(Jugador.Estado.ATURDIDO)
		return
		
	if KeyUtils.is_action_just_pressed(jugador.esquema_control, KeyUtils.Accion.PODER) and jugador.poder_listo:
		EventBus.gastar_poder.emit(jugador.es_visitante)
			
	jugador.move_and_slide()
	if jugador.comprobar_colisiones(true) and ControladorPartido.estado_actual.uso_poder():
		peticion_transmision_estado.emit(Jugador.Estado.PODER)
	
func puede_recibir_daño() -> bool:
	return true


func on_pie_contacto_pelota_en_poder() -> void:
	if ControladorPartido.estado_actual.uso_poder():
		peticion_transmision_estado.emit(Jugador.Estado.PODER)
	
func _exit_tree() -> void:
	jugador.pie.set_monitoring_detector_poder(false)
