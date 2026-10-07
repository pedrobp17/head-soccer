class_name CabezasHelper

static var cabezas_jugadores : Dictionary[String, Texture2D] = {}

static func get_cabeza( jugador : String ) -> Texture2D:
	if not cabezas_jugadores.has(jugador):
		cabezas_jugadores.set(jugador, load("res://Sprites/jugadores/cabezas/%s_C.png" % jugador))
	return cabezas_jugadores[jugador]
