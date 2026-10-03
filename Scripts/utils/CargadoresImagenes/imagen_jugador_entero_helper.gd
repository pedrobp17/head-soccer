class_name ImagenJugadorEnteroHelper

static var jugador_sin_bloqueo : Dictionary[String, Texture2D] = {}
static var jugador_con_bloqueo : Dictionary[String, Texture2D] = {}

static func get_icono( _jugador : String ) -> Texture2D:
	if not ProgresoPartida.is_personaje_desbloqueado(_jugador):
		if not jugador_con_bloqueo.has(_jugador):
			jugador_con_bloqueo.set(_jugador, load("res://Sprites/jugadores/personajesBloq/%s.png" % _jugador))
		return jugador_con_bloqueo[_jugador]
	else:
		if not jugador_sin_bloqueo.has(_jugador):
			jugador_sin_bloqueo.set(_jugador, load("res://Sprites/jugadores/personajesNoBloq/%s.png"% _jugador))
		return jugador_sin_bloqueo[_jugador]
	return null
