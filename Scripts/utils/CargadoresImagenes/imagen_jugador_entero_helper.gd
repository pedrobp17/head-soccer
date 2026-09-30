class_name ImagenJugadorEnteroHelper

static var jugador : Dictionary[String, Texture2D] = {}

static func get_icono( _jugador : String ) -> Texture2D:
	if not jugador.has(_jugador):
		jugador.set(_jugador, load("res://Sprites/jugadores/personajes/%s.png" % _jugador))
	return jugador[_jugador]
