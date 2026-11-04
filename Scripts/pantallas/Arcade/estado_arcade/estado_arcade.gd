extends Node
class_name EstadoArcade

signal peticion_transmision_estado( nuevo_estado : PantallaArcade.Estado )

var arcade : PantallaArcade = null

func setup( _arcade : PantallaArcade ) -> void:
	arcade = _arcade

func cambiar_estado( nuevo_estado : PantallaArcade.Estado ) -> void:
	peticion_transmision_estado.emit(nuevo_estado)

func mostrar_escena() -> void:
	pass
	
func _enter_tree() -> void:
	await mostrar_escena()
