extends Node
class_name CreadorAnimacionesPantallas

# destino -> { origen -> animacion }. Sin entrada para el origen: sin animacion.
var animaciones : Dictionary ={
	HeadSoccer.Pantalla.JUGANDO : {},
	HeadSoccer.Pantalla.DEFAULT : {},
	HeadSoccer.Pantalla.TORNEO : {},
	HeadSoccer.Pantalla.MENU_PRINCIPAL : {},
	HeadSoccer.Pantalla.ARCADE : { HeadSoccer.Pantalla.MENU_PRINCIPAL : "nubes" },
}

func get_fresh_animacion(origen : HeadSoccer.Pantalla, destino : HeadSoccer.Pantalla) -> String:
	assert(animaciones.has(destino), "error al encontrar animacion")
	var destinos : Dictionary = animaciones[destino]
	return destinos.get(origen, "")
