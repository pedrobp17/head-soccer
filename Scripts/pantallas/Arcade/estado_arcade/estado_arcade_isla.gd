extends EstadoArcade
class_name EstadoArcadeIsla

func mostrar_escena() -> void:
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
		var vecino = arcade.get_vecino(event.keycode)
		if vecino == PantallaArcade.Islas.NONE or !arcade.es_valido(vecino):
			return
		arcade.set_seleccionado(vecino, arcade.isla_actual)

func on_fin_animacion_zoom_reset() -> void:
	arcade.cambiar_visibilidad_identificadores(true, arcade.DURACION_ANIMACION_TRANSPARENCIA/2.0)
