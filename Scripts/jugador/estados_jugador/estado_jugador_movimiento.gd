class_name EstadoJugadorMoviendo
extends EstadoJugador


# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	if jugador.esquema_control == Jugador.ControlScheme.IA:
		comportamiento_ia.process_ia()
	else:
		movimiento_player(delta)
	jugador.animacion()

func movimiento_player(delta : float) -> void:
	# Add the gravity.
	if not jugador.is_on_floor():
		jugador.velocity += jugador.get_gravity() * delta

	# Handle jump.
	if KeyUtils.is_action_just_pressed( jugador.esquema_control, KeyUtils.Accion.SALTO ) and jugador.is_on_floor():
		jugador.velocity.y = jugador.estadisticas.get_estadistica("salto")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direccion :=  KeyUtils.get_input_vector(jugador.esquema_control)
	if direccion:
		jugador.velocity.x = direccion * jugador.estadisticas.get_estadistica("velocidad")
	else:
		jugador.velocity.x = move_toward(jugador.velocity.x, 0, jugador.estadisticas.get_estadistica("velocidad"))
		
	if KeyUtils.is_action_just_pressed( jugador.esquema_control, KeyUtils.Accion.PATADA ):
		jugador.pie.golpear()
	
	#if jugador.estadisticas.get_estadistica("vida") == 0:
	#	EventBus.peticion_transmision_estado(Jugador.Estado.ATURDIDO)
