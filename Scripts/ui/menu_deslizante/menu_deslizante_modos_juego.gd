extends MenuDeslizante
class_name MenuDeslizanteModosJuego

enum Modos {VERSUS, SURVIVAL, ONLINE, ARCADE, TORNEO, LIGA, MUNDIAL, PELEA}

@export var modes : Array[DatosModoJuego]

@onready var personaje_seleccion: Sprite2D = %PersonajeSeleccion

var pantalla_modo : Dictionary = {
	Modos.VERSUS : HeadSoccer.Pantalla.DEFAULT,
	Modos.SURVIVAL : HeadSoccer.Pantalla.DEFAULT,
	Modos.ONLINE : HeadSoccer.Pantalla.DEFAULT,
	Modos.ARCADE : HeadSoccer.Pantalla.JUGANDO,
	Modos.TORNEO : HeadSoccer.Pantalla.TORNEO,
	Modos.LIGA : HeadSoccer.Pantalla.DEFAULT,
	Modos.MUNDIAL : HeadSoccer.Pantalla.DEFAULT,
	Modos.PELEA : HeadSoccer.Pantalla.DEFAULT,
}
func _ready():
	card_scene = preload("res://Escenas/ui/Cartas/CartasModoJuego.tscn")
	EventBus.item_selected_personajes.connect(on_item_selected_personajes)
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

func on_item_selected_personajes( datos : Variant) -> void:
		personaje_seleccion.texture = ImagenJugadorEnteroHelper.get_icono(datos.name)
	
func select_current() -> void:
	EventBus.item_selected_modos.emit(get_current_item())

func get_pantalla_asociada(modo : Modos) -> HeadSoccer.Pantalla:
	assert(pantalla_modo.has(modo), "modo de juego no detectado")
	return pantalla_modo[modo]
