extends EstadoMenuPrincipal
class_name EstadoMenuPrincipalSkin

func mostrar_escena() -> void:
	menu_principal.selector_personajes.show()
	menu_principal.selector_personajes.selector_personajes._al_confirmar_personaje()

func esconder_escena() -> void:
	menu_principal.selector_personajes.hide()

func cambiar_foco( tiene_foco : bool ) -> void:
	menu_principal.selector_personajes.cambiar_estado_foco(tiene_foco)

func puede_subir_barra_superior() -> bool:
	return menu_principal.selector_personajes.puedo_subir_menu_principal()

func input_barra_superior( event : InputEvent ) -> void:
	if event.is_action_pressed("ui_left"):
		get_viewport().set_input_as_handled()
		cambiar_estado(MenuPrincipal.Estado.MENU)
	elif event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
		cambiar_estado(MenuPrincipal.Estado.LOGROS)
