extends EstadoJugador
class_name EstadoJugadorEsperandoPoder

var barra_poder_maximo = false

func _enter_tree() -> void:
	jugador.pie.set_monitoring_detector_poder(true)
	EventBus.pie_contacto_pelota_en_poder.connect(on_pie_contacto_pelota_en_poder)
	jugador.animacion("poder")
	EventBus.poder_cargado.connect(on_poder_cargado)

func _process(delta: float) -> void:
	if jugador.esquema_control == Jugador.ControlScheme.IA:
		#comportamiento_ia.process_ia()
		pass
	else:
		movimiento_player(delta)

func movimiento_player(delta : float) -> void:
	movimiento_general(delta)
		
	if KeyUtils.is_action_just_pressed( jugador.esquema_control, KeyUtils.Accion.PATADA ):
		jugador.pie.golpear()
		
	jugador.velocity.y = maxf(jugador.velocity.y, jugador.velocidad_maxima_subida)
	
	if jugador.estadisticas.get_estadistica("vida") <= 0:
		peticion_transmision_estado.emit(Jugador.Estado.ATURDIDO)
		
	if KeyUtils.is_action_just_pressed(jugador.esquema_control, KeyUtils.Accion.PODER) and barra_poder_maximo:
		EventBus.gastar_poder.emit(jugador.es_visitante)
			
	jugador.move_and_slide()
	if jugador.comprobar_colisiones(true):
		peticion_transmision_estado.emit(Jugador.Estado.PODER)
	
func puede_recibir_daño() -> bool:
	return true

func on_poder_cargado() -> void:
	barra_poder_maximo = true

func on_pie_contacto_pelota_en_poder() -> void:
	peticion_transmision_estado.emit(Jugador.Estado.PODER)
	
func _exit_tree() -> void:
	jugador.pie.set_monitoring_detector_poder(false)
