extends Node
class_name EstadoMenuPrincipal

signal peticion_transmision_estado( nuevo_estado : MenuPrincipal.Estado )

var menu_principal : MenuPrincipal = null

func setup( menu_entrada : MenuPrincipal ) -> void:
	menu_principal = menu_entrada

func cambiar_estado( nuevo_estado : MenuPrincipal.Estado ) -> void:
	peticion_transmision_estado.emit(nuevo_estado)


func mostrar_escena() -> void:
	pass

func esconder_escena() -> void:
	pass
	
func cambiar_foco( _tiene_foco : bool ) -> void:
	pass

func puede_subir_barra_superior() -> bool:
	return false

func puede_bajar_barra_superior() -> bool:
	return true

# Flechas izquierda / derecha con el foco en la barra superior
func input_barra_superior( _event : InputEvent ) -> void:
	pass

func _enter_tree() -> void:
	mostrar_escena()
	cambiar_foco(not menu_principal.en_menu_superior)

func _input( event : InputEvent ) -> void:
	#TRANSICION: contenido -> panel_superior
	if event.is_action_pressed("ui_up") and !menu_principal.en_menu_superior and puede_subir_barra_superior():
		menu_principal.cambiar_foco_barra_superior(true)
		get_viewport().set_input_as_handled()
		return

	#TRANSICION: panel_superior -> contenido
	if event.is_action_pressed("ui_down") and menu_principal.en_menu_superior and puede_bajar_barra_superior():
		menu_principal.cambiar_foco_barra_superior(false)
		get_viewport().set_input_as_handled()
		return

	#NO ES TURNO PANEL SUPERIOR
	if !menu_principal.en_menu_superior:
		return

	# En la barra superior, izquierda/derecha son exclusivas del estado actual:
	# se marca como manejado ANTES de delegar para que ningún widget reciba el evento.
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()

	input_barra_superior(event)

func _exit_tree() -> void:
	esconder_escena()
