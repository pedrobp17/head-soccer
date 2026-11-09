extends RefCounted
class_name  CreadorEstadosResultados

var estados : Dictionary ={
	ProgresoGlobal.Modos.ARCADE : EstadoResultadoPartidoArcade,
	ProgresoGlobal.Modos.TORNEO : EstadoResultadoPartidoTorneo,
}

func get_fresh_state(estado : ProgresoGlobal.Modos) -> EstadoResultadoPartido:
	assert(estados.has(estado), "error al encontrar estado")
	return estados.get(estado, EstadoResultadoPartido).new()
