extends Node
class_name HeadSoccer

enum Pantalla {MENU_PRINCIPAL, TORNEO, ARCADE, JUGANDO, DEFAULT} 

@onready var animaciones: AnimationPlayer = %animaciones

var pantalla_actual : Pantallas = null
var pantalla_cargada : Pantalla = Pantalla.MENU_PRINCIPAL
var fabrica_pantalla := FabricaPantallas.new()
var fabrica_animaciones := CreadorAnimacionesPantallas.new()
var transicionando := false

func _ready() -> void:
	_cargar_pantalla(Pantalla.MENU_PRINCIPAL, DatosPantallas.new())


func cambiar_pantalla(pantalla : Pantalla, datos : DatosPantallas = DatosPantallas.new()) -> void:
	if transicionando:
		return

	# pantalla_cargada aun es la pantalla de ORIGEN (se actualiza al cargar la nueva)
	var transicion = fabrica_animaciones.get_fresh_animacion(pantalla_cargada, pantalla)

	if pantalla_actual != null:
		pantalla_actual.process_mode = Node.PROCESS_MODE_DISABLED

	await entrada(transicion)

	_cargar_pantalla(pantalla, datos)
	await get_tree().process_frame

	await salida(transicion)


func _cargar_pantalla(pantalla : Pantalla, datos : DatosPantallas) -> void:
	pantalla_cargada = pantalla
	if pantalla_actual != null:
		pantalla_actual.queue_free()
	pantalla_actual = fabrica_pantalla.get_fresh_screen(pantalla)
	pantalla_actual.setup(self, datos)
	pantalla_actual.peticion_transicion_pantalla.connect(cambiar_pantalla)
	add_child(pantalla_actual)

func entrada(transicion : String) -> void:
	if transicion.is_empty():
		return
	transicionando = true
	$sprite.show()
	animaciones.play(transicion + "_entrada")
	await animaciones.animation_finished

func salida(transicion : String ) -> void:
	if transicion.is_empty():
		return
	animaciones.play(transicion + "_salida")
	await animaciones.animation_finished
	$sprite.hide()
	transicionando = false
