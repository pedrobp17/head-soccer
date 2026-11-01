extends Node
class_name HeadSoccer

enum Pantalla {MENU_PRINCIPAL, TORNEO, ARCADE, JUGANDO, DEFAULT} 

var pantalla_actual : Pantallas = null
var fabrica_pantalla := FabricaPantallas.new()
var fabrica_animaciones := CreadorAnimacionesPantallas.new()
var transicionando := false

func _ready() -> void:
	_cargar_pantalla(Pantalla.MENU_PRINCIPAL, DatosPantallas.new())


func cambiar_pantalla(pantalla : Pantalla, datos : DatosPantallas = DatosPantallas.new()) -> void:
	if transicionando:
		return
		
	transicionando = true
	var transicion = fabrica_animaciones.get_fresh_state(pantalla)
	
	if pantalla_actual != null:
		pantalla_actual.process_mode = Node.PROCESS_MODE_DISABLED
	
	await transicion.entrada()

	_cargar_pantalla(pantalla, datos)
	await get_tree().process_frame

	await transicion.salida()
	transicionando = false


func _cargar_pantalla(pantalla : Pantalla, datos : DatosPantallas) -> void:
	if pantalla_actual != null:
		pantalla_actual.queue_free()
	pantalla_actual = fabrica_pantalla.get_fresh_screen(pantalla)
	pantalla_actual.setup(self, datos)
	pantalla_actual.peticion_transicion_pantalla.connect(cambiar_pantalla)
	add_child(pantalla_actual)
