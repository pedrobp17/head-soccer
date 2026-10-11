class_name ImagenesJugadoresHelper

static var iconos_jugadores_marcador : Dictionary[String, Texture2D] = {}
static var iconos_jugadores : Dictionary[String, Texture2D] = {}

static func get_icono( jugador : String, marcador : bool = true ) -> Texture2D:
	if not marcador:
		if not iconos_jugadores.has(jugador):
			iconos_jugadores.set(jugador, load("res://Sprites/jugadores/iconos/%s.png" % jugador))
		return iconos_jugadores[jugador]
	
	if not iconos_jugadores_marcador.has(jugador):
		iconos_jugadores_marcador.set(jugador, load("res://Sprites/jugadores/icono_marcador/%s.png" % jugador))
	return iconos_jugadores_marcador[jugador]
		
