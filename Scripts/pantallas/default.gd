extends Pantallas

func _process(delta: float) -> void:
	if KeyUtils.is_action_just_pressed(Jugador.ControlScheme.P1, KeyUtils.Accion.BACK):
		transicion_pantallas(HeadSoccer.Pantalla.MENU_PRINCIPAL)
