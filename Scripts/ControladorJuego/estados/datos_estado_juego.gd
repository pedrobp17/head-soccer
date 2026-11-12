class_name DatosEstadoJuego

var es_visitante: bool
var tiempo_extra: bool = false

static func build() -> DatosEstadoJuego:
	return DatosEstadoJuego.new()
	
func set_es_visitante(visitante: bool) -> DatosEstadoJuego:
	es_visitante = visitante
	return self
	
func set_tiempo_extra(tiempo: bool) -> DatosEstadoJuego:
	tiempo_extra = tiempo
	return self