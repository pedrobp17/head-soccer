class_name DatosEstadoJuego

var jugador_anotador : String

static func build() -> DatosEstadoJuego:
	return DatosEstadoJuego.new()
	
func set_jugador_anotador( jugador : String) -> DatosEstadoJuego:
	jugador_anotador = jugador
	return self
	
