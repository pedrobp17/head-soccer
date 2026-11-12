class_name EstadoJugadorMoviendo
extends EstadoJugador


func _enter_tree() -> void:
	jugador.estadisticas.reset_estadistica("vida")
	EventBus.cambiar_barra_vida.emit( jugador.estadisticas.get_estadistica("vida"), jugador.es_visitante)
	nombre_estado = Jugador.Estado.JUGANDO
	
# Called when the node enters the scene tree for the first time.
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
		peticion_transmision_estado.emit(Jugador.Estado.ESPERANDO_PODER)
		EventBus.gastar_poder.emit(jugador.es_visitante)
		
	jugador.move_and_slide()
	jugador.comprobar_colisiones(false)
	jugador.set_animacion("idle")
	
func puede_recibir_daño() -> bool:
	return true

	
func get_animacion() -> String:
	return "idle"
