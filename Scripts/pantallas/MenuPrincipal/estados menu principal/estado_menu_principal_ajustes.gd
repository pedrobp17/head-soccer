extends EstadoMenuPrincipal
class_name EstadoMenuPrincipalAjustes

func mostrar_escena() -> void:
	menu_principal.ajustes.show()

func esconder_escena() -> void:
	menu_principal.ajustes.hide()

func puede_subir_barra_superior() -> bool:
	return true

func input_barra_superior( event : InputEvent ) -> void:
	if event.is_action_pressed("ui_left"):
		get_viewport().set_input_as_handled()
		cambiar_estado(MenuPrincipal.Estado.LOGROS)
