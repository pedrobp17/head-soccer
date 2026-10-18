class_name ImagenesPersonajesTorneo

static var iconos_jugadores_torneo : Dictionary[String, Texture2D] = {}

static func get_imagen( jugador : String) -> Texture2D:
	if not iconos_jugadores_torneo.has(jugador):
		iconos_jugadores_torneo.set(jugador, load("res://Sprites/jugadores/iconos_torneos/%s.png" % jugador))
	return iconos_jugadores_torneo[jugador]
		
