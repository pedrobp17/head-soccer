extends Control

const mapa_escenas : Dictionary ={
	"menu" : preload("res://Escenas/pantallas/Menu.tscn"),
	"personajes" : preload("res://Escenas/pantallas/SelectorPersonajes.tscn")
}
	
const mapa_seleccion : Dictionary ={
	"neutro" : -1,
	"menu" : 0,
	"personajes" : 1
}

@onready var menu_sel = $MenuSeleccionado_Personajes
@onready var personajes_sel = $Menu_PersonajesSeleccionado
@onready var menu_neutral = $Menu_Personajes
@onready var contenido = $Contenido

var escena_actual : Node
var en_menu_superior := false
var seleccion_superior := mapa_seleccion["menu"] 

func _ready():
	actualizar_selector(mapa_seleccion["neutro"])
	cambiar_escena(mapa_escenas["menu"], true)


func _input(event):

	# Cambiar el foco entre arriba y abajo.
	if event.is_action_pressed("ui_up") and !en_menu_superior:
		en_menu_superior = true
		cambiar_foco_escena(false)
		actualizar_selector(seleccion_superior)
		return
		
	if event.is_action_pressed("ui_down") and en_menu_superior:
		en_menu_superior = false
		cambiar_foco_escena(true)
		actualizar_selector(mapa_seleccion["neutro"])
		return
	
	if !en_menu_superior:
		return
	
	if event.is_action_pressed("ui_left") and seleccion_superior != mapa_seleccion["menu"] :
		seleccion_superior = mapa_seleccion["menu"]
		actualizar_selector(seleccion_superior)
		cambiar_escena(mapa_escenas["menu"], false)
		
	elif event.is_action_pressed("ui_right") and seleccion_superior != mapa_seleccion["personajes"] :
		seleccion_superior = mapa_seleccion["personajes"]
		actualizar_selector(seleccion_superior)
		cambiar_escena(mapa_escenas["personajes"], false)
		
func cambiar_escena(escena : PackedScene, dar_foco : bool):

	if escena_actual:
		escena_actual.queue_free()

	escena_actual = escena.instantiate()
	contenido.add_child(escena_actual)
	cambiar_foco_escena(dar_foco)
	
func cambiar_foco_escena(tiene_foco: bool) -> void:
	print("cambiando foco")
	if escena_actual and escena_actual.has_method("cambiar_estado_foco"):
		print("tiene metodo")
		escena_actual.cambiar_estado_foco(tiene_foco)

func actualizar_selector(id : int):

	if id == mapa_seleccion["menu"]:
		menu_sel.show()
		personajes_sel.hide()
		menu_neutral.hide()
	elif id == mapa_seleccion["personajes"]:
		menu_sel.hide()
		personajes_sel.show()
		menu_neutral.hide()
	else: 
		menu_neutral.show()
		personajes_sel.hide()
		menu_sel.hide()
