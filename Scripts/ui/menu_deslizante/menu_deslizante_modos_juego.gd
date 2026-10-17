extends MenuDeslizante
class_name MenuDeslizanteModosJuego

const Modos = ProgresoGlobal.Modos

@export var modes : Array[DatosModoJuego]
@onready var error: ErrorModosJuego = $FondoError

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
	error.boton_pulsado.connect(on_boton_pulsado)
	use_scaling = true
	use_fade = true
	use_rotation = false
	actualizar_imagen()
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
	
func actualizar_imagen() -> void:
	personaje_seleccion.texture = ImagenJugadorEnteroHelper.get_icono(ProgresoPartida.progreso_general.get_jugador_seleccionado())	

func on_item_selected_personajes() -> void:
	actualizar_imagen()
	
func set_datos_pantalla_seleccionada() -> DatosPantallas:
	match ProgresoPartida.progreso_general.get_modo_jugado():
		Modos.VERSUS:
			return DatosPantallas.new()
		Modos.SURVIVAL:
			return DatosPantallas.new()
		Modos.ONLINE:
			return DatosPantallas.new()
		Modos.ARCADE:
			ControladorPartido.enfrentamiento.set_jugador_visitante("AdrianSpeed", "mano_magica")
			return DatosPantallas.new()
		Modos.TORNEO:
			var torneo = ProgresoPartida.progreso_general.cargar_torneo()
			if torneo == null:
				torneo = Torneo.new(ControladorPartido.enfrentamiento.config_jugador_local)
			return DatosPantallas.build().set_config_jugador(ControladorPartido.enfrentamiento.config_jugador_local).set_torneo(torneo)
		Modos.LIGA:
			return DatosPantallas.new()
		Modos.MUNDIAL:
			return DatosPantallas.new()
		Modos.PELEA:
			return DatosPantallas.new()
		_:
			return DatosPantallas.new() 
	
	
func select_current() -> void:
	var nombre_modo: String = get_current_item().name.to_upper()
	assert(Modos.has(nombre_modo), "El modo '%s' no existe en el enum Modos" % nombre_modo)
	ProgresoPartida.progreso_general.set_modo_jugado(Modos[nombre_modo])
	EventBus.item_selected_modos.emit()
	
func get_pantalla_asociada(modo : Modos) -> HeadSoccer.Pantalla:
	assert(pantalla_modo.has(modo), "modo de juego no detectado")
	return pantalla_modo[modo]

func mostrar_error() -> void:
	cambiar_estado_foco(false)
	get_viewport().set_input_as_handled()
	error.mostrar()

func on_boton_pulsado():
	cambiar_estado_foco(true)
	get_viewport().set_input_as_handled()
	
	if error.indice_boton_actual == 1:
		ProgresoPartida.progreso_general.terminar_torneo()
		EventBus.item_selected_modos.emit()
