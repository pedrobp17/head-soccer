extends EstadoArcade
class_name EstadoArcadeArea

const DESFASE_ANIMACION := 0.4

var nivel_actual := 0

func mostrar_escena() -> void:
	arcade.cambiar_visibilidad_identificadores(false)
	arcade.zoom_a_isla()
	await get_tree().create_timer(DESFASE_ANIMACION).timeout
	set_niveles_de_isla()
	
func _input(event: InputEvent) -> void:	
	if event.is_action_pressed("p1_back"):
		arcade.niveles[nivel_actual].finalizar_animacion()
		arcade.refresh_niveles()
		cambiar_estado(PantallaArcade.Estado.ISLA)
		
	if event is InputEventKey and event.pressed:
		var direccion_vecino = event.keycode
		if nivel_actual > 0 and arcade.direcciones_opuestas[arcade.movimiento_areas[arcade.isla_actual][nivel_actual - 1]] == direccion_vecino:
			set_nivel_actual(-1, nivel_actual)
		
		elif nivel_actual < ProgresoPartida.progreso_general.get_progreso_arcade().get_niveles_totales(arcade.isla_actual) - 1 and  arcade.movimiento_areas[arcade.isla_actual][nivel_actual] == direccion_vecino:
			set_nivel_actual(1, nivel_actual)
	
	if event.is_action_pressed("ui_accept"):
		ControladorPartido.enfrentamiento.set_jugador_local(
			ProgresoPartida.progreso_general.get_jugador_seleccionado(),
			ProgresoPartida.progreso_general.get_poder_seleccionado())
		var jugador_visitante= arcade.get_jugador_nivel(nivel_actual)
		ControladorPartido.enfrentamiento.set_jugador_visitante(jugador_visitante, "mano_magica")
		var datos := DatosPantallas.build().set_contexto_arcade(arcade.isla_actual, nivel_actual)
		arcade.transicion_pantallas(HeadSoccer.Pantalla.JUGANDO, datos)
		
func set_niveles_de_isla() -> void:
	
	var contenedor_posiciones = arcade.indicadores[arcade.isla_actual].get_node("posicion_niveles")
	var array_posiciones = contenedor_posiciones.get_children()
	var niveles_disponibles = ProgresoPartida.progreso_general.get_progreso_arcade().get_niveles_totales(arcade.isla_actual)
	var niveles_vencidos = ProgresoPartida.progreso_general.get_niveles_vencidos_arcade(arcade.isla_actual)
	assert(array_posiciones.size() == niveles_disponibles, "no coincide los niveles definidos en la pantalla arcade con los del json")
	
	for i in range(niveles_disponibles):
		var posicion = array_posiciones[i] as Node2D
		var desbloqueado = i <= niveles_vencidos
		arcade.niveles[i].inicializar(posicion.global_position, desbloqueado)
		arcade.niveles[i].show()
	set_nivel_actual(0)
	arcade.info_nivel.mostrar()
func set_nivel_actual(indicador_siguiente_nivel : int, nivel_anterior : int = -1) -> void:
	if nivel_anterior != -1:
		arcade.niveles[nivel_anterior].set_desbloqueado(true)
	nivel_actual = nivel_actual + indicador_siguiente_nivel
	arcade.niveles[nivel_actual].set_actual()
	arcade.info_nivel.refresh_nivel(nivel_actual, arcade.get_jugador_nivel(nivel_actual), arcade.isla_actual)
	
func _exit_tree() -> void:
	if is_instance_valid(arcade) and is_instance_valid(arcade.info_nivel):
		arcade.info_nivel.ocultar()
