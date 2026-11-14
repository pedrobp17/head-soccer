extends EstadoMenuPrincipal
class_name EstadoMenuPrincipalLogros

func mostrar_escena() -> void:
	menu_principal.logros.show()
	menu_principal.logros.cambiar_estado(Logros.Estado.ELIGIENDO, DatosEstadoLogros.build().set_indice_personaje(0))
	menu_principal.logros.cambiar_estado_foco(false)

func esconder_escena() -> void:
	menu_principal.logros.cambiar_estado_foco(false)
	menu_principal.logros.hide()

func animar() -> void:
	pass

func reposicionar() -> void:
	pass

func cambiar_foco( tiene_foco : bool ) -> void:
	menu_principal.logros.cambiar_estado_foco(tiene_foco)

func puede_subir_barra_superior() -> bool:
	return menu_principal.logros.puedo_subir_menu_principal()

func input_barra_superior( event : InputEvent ) -> void:
	if event.is_action_pressed("ui_left"):
		get_viewport().set_input_as_handled()
		cambiar_estado(MenuPrincipal.Estado.SKIN)
	elif event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
		cambiar_estado(MenuPrincipal.Estado.AJUSTES)
