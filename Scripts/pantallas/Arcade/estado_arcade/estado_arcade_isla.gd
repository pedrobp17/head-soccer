extends EstadoArcade
class_name EstadoArcadeIsla

func mostrar_escena() -> void:
	set_seleccionado(arcade.isla_actual, PantallaArcade.Islas.NONE)
	await arcade.zoom_a_centro()
	
func _ready() -> void:
	EventBus.fin_animacion_zoom_reset.connect(on_fin_animacion_zoom_reset)
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		cambiar_estado(PantallaArcade.Estado.AREA)
	
	if event.is_action_pressed("p1_back"):
		ControladorPartido.enfrentamiento = Enfrentamientos.new()
		arcade.transicion_pantallas(HeadSoccer.Pantalla.MENU_PRINCIPAL)
		
	if event is InputEventKey and event.pressed:
		var vecino = get_vecino(event.keycode)
		if vecino == PantallaArcade.Islas.NONE or !es_valido(vecino):
			return
		set_seleccionado(vecino, arcade.isla_actual)

func on_fin_animacion_zoom_reset() -> void:
	arcade.cambiar_visibilidad_identificadores(true, arcade.DURACION_ANIMACION_TRANSPARENCIA/2.0)

func es_valido( isla : PantallaArcade.Islas ) -> bool:
	return isla in arcade.islas_desbloqueadas
	
func get_vecino( _direccion : Key ) -> PantallaArcade.Islas:
	if arcade.mapa_direcciones.has(_direccion):
		return arcade.vecinos_isla[arcade.isla_actual][arcade.mapa_direcciones[_direccion]]
	return PantallaArcade.Islas.NONE
		
func set_seleccionado(isla_seleccionada : PantallaArcade.Islas, isla_anterior : PantallaArcade.Islas) -> void:
	if isla_anterior != PantallaArcade.Islas.NONE:
		arcade.indicadores[isla_anterior].set_desbloqueado(true)
	arcade.isla_actual = isla_seleccionada
	arcade.indicadores[isla_seleccionada].set_actual()
	
