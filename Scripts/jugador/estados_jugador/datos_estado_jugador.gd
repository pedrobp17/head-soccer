class_name DatosEstadoJugador

var jugador_anotador : String

static func build() -> DatosEstadoJugador:
	return DatosEstadoJugador.new()
	
func set_jugador_anotador( jugador : String) -> DatosEstadoJugador:
	jugador_anotador = jugador
	return self
	
