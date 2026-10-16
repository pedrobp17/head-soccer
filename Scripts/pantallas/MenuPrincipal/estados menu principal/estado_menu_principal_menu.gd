extends EstadoMenuPrincipal
class_name EstadoMenuPrincipalMenu

func mostrar_escena() -> void:
	menu_principal.menu_deslizante.show()

func esconder_escena() -> void:
	menu_principal.menu_deslizante.hide()

func cambiar_foco( tiene_foco : bool ) -> void:
	menu_principal.menu_deslizante.cambiar_estado_foco(tiene_foco)

func puede_subir_barra_superior() -> bool:
	return true

func input_barra_superior( event : InputEvent ) -> void:
	if event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
		cambiar_estado(MenuPrincipal.Estado.SKIN)
