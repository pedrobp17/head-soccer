class_name EstadoLogrosViendo
extends EstadoLogros


func _enter_tree() -> void:
	nombre_estado = Logros.Estado.VIENDO
	logros.set_pantalla_estadisticas_personaje(datos_juego.indice_personaje)
	logros.mostrar_estadisticas_personajes()


func _input(event: InputEvent) -> void:
	if not puede_recibir_input():
		return
		
	if event.is_action_pressed("ui_left"):
		datos_juego.indice_personaje = posmod(datos_juego.indice_personaje - 1, logros.numero_personajes)
		logros.set_pantalla_estadisticas_personaje(datos_juego.indice_personaje)
	
	if event.is_action_pressed("ui_right"):
		
		datos_juego.indice_personaje = posmod(datos_juego.indice_personaje + 1, logros.numero_personajes)
		logros.set_pantalla_estadisticas_personaje(datos_juego.indice_personaje)
		
	if event.is_action_pressed("p1_back"):
		get_viewport().set_input_as_handled()
		cambiar_estado(Logros.Estado.ELIGIENDO)
