extends EstadoArcade
class_name EstadoArcadeArea

const COLOR_CAMINO_DESBLOQUEADO = Color("244055")
const COLOR_CAMINO_nLOQUEADO = Color("a3ae9d")


func mostrar_escena() -> void:
	arcade.cambiar_visibilidad_identificadores(false)
	await arcade.zoom_a_isla()
	arcade.set_niveles_de_isla()
	
func _input(event: InputEvent) -> void:	
	if event.is_action_pressed("p1_back"):
		arcade.refresh_niveles()
		cambiar_estado(PantallaArcade.Estado.ISLA)
		
