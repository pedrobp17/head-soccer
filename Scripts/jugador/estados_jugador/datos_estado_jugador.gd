class_name DatosEstadoJugador

var es_visitante: bool
var nombre : Jugador.Estado

static func build() -> DatosEstadoJugador:
	return DatosEstadoJugador.new()
	
func set_es_visitante( visitante: bool) -> DatosEstadoJugador:
	es_visitante = visitante
	return self
	
func set_nombre_estado( estado : Jugador.Estado) -> DatosEstadoJugador:
	nombre = estado
	return self
	
