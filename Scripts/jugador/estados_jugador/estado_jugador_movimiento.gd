class_name EstadoJugadorMoviendo
extends EstadoJugador

var barra_poder_maximo = false

func _enter_tree() -> void:
	jugador.estadisticas.reset_estadistica("vida")
	EventBus.cambiar_barra_vida.emit( jugador.estadisticas.get_estadistica("vida"), jugador.es_visitante)
	EventBus.poder_cargado.connect(on_poder_cargado)
# Called when the node enters the scene tree for the first time.
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
		peticion_transmision_estado.emit(Jugador.Estado.ESPERANDO_PODER)
		EventBus.gastar_poder.emit(jugador.es_visitante)
		
	jugador.move_and_slide()
	jugador.comprobar_colisiones(false)
	
func puede_recibir_daño() -> bool:
	return true

func on_poder_cargado() -> void:
	barra_poder_maximo = true
	
