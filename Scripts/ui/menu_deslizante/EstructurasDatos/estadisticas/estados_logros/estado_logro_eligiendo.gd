class_name EstadoLogrosEligiendo
extends EstadoLogros
 
 
func _enter_tree() -> void:
	nombre_estado = Logros.Estado.ELIGIENDO
	logros.mostrar_eleccion_personajes()
 
 
func _input(event: InputEvent) -> void:
	if not puede_recibir_input():
		return
 
	if event.is_action_pressed("ui_left"):
		logros.nueva_celda_seleccionada(Logros.DIRECCIONES["izquierda"])
 
	elif event.is_action_pressed("ui_right"):
		logros.nueva_celda_seleccionada(Logros.DIRECCIONES["derecha"])
 
	elif event.is_action_pressed("ui_up"):
		logros.nueva_celda_seleccionada(Logros.DIRECCIONES["subir"])
 
	elif event.is_action_pressed("ui_down"):
		logros.nueva_celda_seleccionada(Logros.DIRECCIONES["bajar"])
 
	elif event.is_action_pressed("ui_accept"):
		var indice := logros.get_indice_jugador(logros.coordenadas_casilla_actual)
		cambiar_estado(Logros.Estado.VIENDO, DatosEstadoLogros.build().set_indice_personaje(indice))
