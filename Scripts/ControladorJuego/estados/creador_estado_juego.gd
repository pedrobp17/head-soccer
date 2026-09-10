extends Node
class_name CreadorEstadoJuego

var estados : Dictionary ={
	ControladorPartido.Estado.JUGANDO : EstadoJuegoJugando,
	ControladorPartido.Estado.FIN : EstadoJuegoFin,
	ControladorPartido.Estado.TIEMPO_EXTRA : EstadoJuegoTiempoExtra,
	ControladorPartido.Estado.GOL : EstadoJuegoGol,
	ControladorPartido.Estado.RESETEO : EstadoJuegoReseteo,
	
}

func get_fresh_state(estado : ControladorPartido.Estado) -> EstadoJuego:
	assert(estados.has(estado), "error al encontrar estado")
	return estados.get(estado).new()
