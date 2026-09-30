extends MenuDeslizante
class_name MenuDeslizanteSeleccionPersonajes

@export var modes : Array[DatosSeleccionPersonajes]


func _ready():
	card_scene = preload("res://Escenas/ui/Cartas/CartasSeleccionPersonaje.tscn")

	use_scaling = false
	use_fade = false
	use_rotation = false

	super()

	set_items(modes)


func get_center_slot() -> int:
	return visible_slots / 2


func configure_card(
	card: Control,
	data: Variant,
	is_selected: bool,
	animar_seleccion: bool = false
) -> void:
	card.set_mode(
		data,
		is_selected,
		animar_seleccion
	)
