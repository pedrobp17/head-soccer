extends MenuDeslizante
class_name MenuDeslizanteSeleccionPersonajes

@export var modes : Array[DatosSeleccionPersonajes]

var indice_carta_seleccionada := -1

func _ready():
	card_scene = preload("res://Escenas/ui/Cartas/CartasSeleccionPersonaje.tscn")

	use_scaling = false
	use_fade = false
	use_rotation = false
	
	super()

	set_items(modes)
	EventBus.item_selected_personajes.connect(_al_confirmar_personaje)

func get_center_slot() -> int:
	return visible_slots / 2


func configure_card(card: Control, data: Variant, is_selected: bool, animar_seleccion: bool = false) -> void:
	
	var es_el_personaje_elegido = (items.find(data) == indice_carta_seleccionada)
	
	card.set_mode(
		data,
		is_selected,
		animar_seleccion,
		es_el_personaje_elegido
	)
	

func _al_confirmar_personaje(data_personaje: Variant) -> void:
	if items.is_empty() or animating:
		return
		
	var nuevo_indice = items.find(data_personaje)
	
	if nuevo_indice != -1:
		indice_carta_seleccionada = nuevo_indice
		refresh() 
	
