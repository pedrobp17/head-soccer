extends MenuDeslizante
class_name MenuDeslizanteModosJuego

@export var modes : Array[DatosModoJuego]

@onready var personaje_seleccion: Sprite2D = %PersonajeSeleccion

var pantalla_modo : Dictionary = {
	"1vs1" : HeadSoccer.Pantalla.DEFAULT,
	"Survival" : HeadSoccer.Pantalla.DEFAULT,
	"Online" : HeadSoccer.Pantalla.DEFAULT,
	"Arcade" : HeadSoccer.Pantalla.DEFAULT,
	"Torneo" : HeadSoccer.Pantalla.TORNEO,
	"Liga" : HeadSoccer.Pantalla.DEFAULT,
	"Mundial" : HeadSoccer.Pantalla.DEFAULT,
	"Pelea" : HeadSoccer.Pantalla.DEFAULT,
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
	print("elemento seleccionado")
	EventBus.item_selected_modos.emit(get_current_item())

func get_pantalla_asociada(modo : String) -> HeadSoccer.Pantalla:
	print(modo)
	assert(pantalla_modo.has(modo), "modo de juego no detectado")
	return pantalla_modo[modo]
