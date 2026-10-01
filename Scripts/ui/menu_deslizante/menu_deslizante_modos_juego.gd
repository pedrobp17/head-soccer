extends MenuDeslizante
class_name MenuDeslizanteModosJuego

@export var modes : Array[DatosModoJuego]

@onready var personaje_seleccion: Sprite2D = %PersonajeSeleccion

func _ready():
	card_scene = preload("res://Escenas/ui/Cartas/CartasModoJuego.tscn")
	EventBus.item_selected.connect(on_item_selected)
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

func on_item_selected( datos : Variant) -> void:
	personaje_seleccion.texture = ImagenJugadorEnteroHelper.get_icono(datos.name)
	
