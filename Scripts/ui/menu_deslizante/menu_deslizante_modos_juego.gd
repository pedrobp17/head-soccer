extends MenuDeslizante
class_name MenuDeslizanteModosJuego

@export var modes : Array[DatosModoJuego]


func _ready():
	card_scene = preload("res://Escenas/ui/Cartas/CartasModoJuego.tscn")

	use_scaling = true
	use_fade = true
	use_rotation = false

	super()

	set_items(modes)


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
