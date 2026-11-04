extends Node
class_name CreadorEstadoArcade

var estados : Dictionary ={
	PantallaArcade.Estado.ISLA : EstadoArcadeIsla,
	PantallaArcade.Estado.AREA : EstadoArcadeArea	
}

func get_fresh_state(estado : PantallaArcade.Estado) -> EstadoArcade:
	assert(estados.has(estado), "error al encontrar estado")
	return estados.get(estado).new()
