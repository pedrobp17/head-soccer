class_name ImagenesJugadoresHelper

static var iconos_jugadores : Dictionary[String, Texture2D] = {}

static func get_icono( jugador : String ) -> Texture2D:
	if not iconos_jugadores.has(jugador):
		iconos_jugadores.set(jugador, load("res://Sprites/jugadores/icono_marcador/%s.png" % jugador))
	return iconos_jugadores[jugador]
