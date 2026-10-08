extends Node
class_name HeadSoccer

enum Pantalla {MENU_PRINCIPAL, TORNEO, JUGANDO, DEFAULT} 

var pantalla_actual : Pantallas = null
var fabrica_pantalla := FabricaPantallas.new()


func _init() -> void:
	cambiar_pantalla(Pantalla.MENU_PRINCIPAL)


func cambiar_pantalla( pantalla : Pantalla, datos : DatosPantallas = DatosPantallas.new()) -> void:
	if pantalla_actual != null:
		pantalla_actual.queue_free()
	pantalla_actual = fabrica_pantalla.get_fresh_screen(pantalla)
	pantalla_actual.setup(self, datos)
	pantalla_actual.peticion_transicion_pantalla.connect(cambiar_pantalla.bind())
	call_deferred("add_child", pantalla_actual)
 
