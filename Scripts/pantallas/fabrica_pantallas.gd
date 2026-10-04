class_name FabricaPantallas

var pantallas : Dictionary

func _init() -> void:
	pantallas = {
		HeadSoccer.Pantalla.MENU_PRINCIPAL : preload("res://Escenas/pantallas/MenuPrincipal.tscn"),
		HeadSoccer.Pantalla.TORNEO : preload("res://Escenas/pantallas/ModoTorneo.tscn"),
		HeadSoccer.Pantalla.JUGANDO : preload("res://Escenas/pantallas/campo.tscn"),
		HeadSoccer.Pantalla.DEFAULT : preload("res://Escenas/pantallas/Default.tscn")
		
	}

func get_fresh_screen( pantalla : HeadSoccer.Pantalla) -> Pantallas:
	assert( pantallas.has(pantalla), "pantalla no registrada")
	return pantallas.get(pantalla).instantiate()
