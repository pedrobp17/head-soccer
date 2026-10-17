extends MenuDeslizante
class_name MenuDeslizanteModosJuego

const Modos = ProgresoGlobal.Modos

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

func on_item_selected_personajes(datos : Variant) -> void:
	personaje_seleccion.texture = ImagenJugadorEnteroHelper.get_icono(ProgresoPartida.progreso_general.get_jugador_seleccionado())	
	
func select_current() -> void:
	var nombre_modo: String = get_current_item().name.to_upper()
	assert(Modos.has(nombre_modo), "El modo '%s' no existe en el enum Modos" % nombre_modo)
	ProgresoPartida.progreso_general.set_modo_jugado(Modos[nombre_modo])
	EventBus.item_selected_modos.emit()
	
func get_pantalla_asociada(modo : Modos) -> HeadSoccer.Pantalla:
	assert(pantalla_modo.has(modo), "modo de juego no detectado")
	return pantalla_modo[modo]
