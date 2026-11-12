class_name DatosEstadoJuego

var es_visitante: bool

static func build() -> DatosEstadoJuego:
	return DatosEstadoJuego.new()
	
func set_es_visitante( visitante: bool) -> DatosEstadoJuego:
	es_visitante = visitante
	return self
	
