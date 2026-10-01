extends Node
class_name  ManejadorMenuPersonajes

enum Interactuables {SUPERIOR, PERSONAJES, PODERES, BOTON}

@onready var selector_personajes: MenuDeslizanteSeleccionPersonajes = $SelectorPersonajes
@onready var estadisticas_personaje_seleccionado: EstadisticasPersonajeSeleccionado = %EstadisticasPersonajeSeleccionado
@onready var boton: BotonSeleccionPersonaje = %Boton

var estado_actual := Interactuables.SUPERIOR

func cambiar_estado_foco( foco : bool) -> void:
	estado_actual = Interactuables.BOTON if foco else Interactuables.SUPERIOR
	boton.cambiar_estado_foco(foco)
	
func puedo_subir_menu_principal() -> bool:
	return estado_actual == Interactuables.BOTON



func _input(event):


	#TRANSICION: boton -> personajes
	if event.is_action_pressed("ui_left") and estado_actual == Interactuables.BOTON:
		estado_actual = Interactuables.PERSONAJES
		boton.cambiar_estado_foco(false)
		selector_personajes.cambiar_estado_foco(true)
		return
	
	#TRANSICION: personajes ->  boton 
	if event.is_action_pressed("ui_right") and estado_actual == Interactuables.PERSONAJES:
		estado_actual = Interactuables.BOTON
		selector_personajes.cambiar_estado_foco(false)
		boton.cambiar_estado_foco(true)
		return
			
	#TRANSICION: boton -> poderes
	if event.is_action_pressed("ui_right") and estado_actual == Interactuables.BOTON:
		estado_actual = Interactuables.PODERES
		boton.cambiar_estado_foco(false)
		estadisticas_personaje_seleccionado.cambiar_estado_foco(true)
		return
	
	#TRANSICION: personajes ->  boton 
	if event.is_action_pressed("ui_left") and estado_actual == Interactuables.PODERES:
		estado_actual = Interactuables.BOTON
		estadisticas_personaje_seleccionado.cambiar_estado_foco(false)
		boton.cambiar_estado_foco(true)
		return
	
func set_item_central( indice : int) -> void:
	selector_personajes.set_elemento_central(indice)
