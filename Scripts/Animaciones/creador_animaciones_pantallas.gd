extends Node
class_name CreadorAnimacionesPantallas

var animaciones : Dictionary ={
	HeadSoccer.Pantalla.JUGANDO : "",
	HeadSoccer.Pantalla.DEFAULT : "",
	HeadSoccer.Pantalla.TORNEO : "",
	HeadSoccer.Pantalla.MENU_PRINCIPAL : "",
	HeadSoccer.Pantalla.ARCADE : "nubes",
}

func get_fresh_animacion(pantalla : HeadSoccer.Pantalla) -> String:
	assert(animaciones.has(pantalla), "error al encontrar estado")
	return animaciones.get(pantalla)
