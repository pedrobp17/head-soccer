class_name DatosEstadoJugador

var jugador_anotador : String
var nombre : Jugador.Estado

static func build() -> DatosEstadoJugador:
	return DatosEstadoJugador.new()
	
func set_jugador_anotador( jugador : String) -> DatosEstadoJugador:
	jugador_anotador = jugador
	return self
	
func set_nombre_estado( estado : Jugador.Estado) -> DatosEstadoJugador:
	nombre = estado
	return self
	
