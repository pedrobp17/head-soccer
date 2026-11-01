extends Node
class_name CreadorAnimacionesPantallas

var animaciones : Dictionary ={
	HeadSoccer.Pantalla.JUGANDO : AnimacionPantalla,
	HeadSoccer.Pantalla.DEFAULT : AnimacionPantalla,
	HeadSoccer.Pantalla.TORNEO : AnimacionPantalla,
	HeadSoccer.Pantalla.MENU_PRINCIPAL : AnimacionPantalla,
	HeadSoccer.Pantalla.ARCADE : Nubes,
}

func get_fresh_state(pantalla : HeadSoccer.Pantalla) -> AnimacionPantalla:
	assert(animaciones.has(pantalla), "error al encontrar estado")
	return animaciones.get(pantalla).new()
