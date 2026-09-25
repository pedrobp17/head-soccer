class_name CreadorEstadoJugador

var estados : Dictionary

func _init() -> void:
	estados = {
		Jugador.Estado.JUGANDO: EstadoJugadorMoviendo,
		Jugador.Estado.ATURDIDO: EstadoJugadorAturdido,
		Jugador.Estado.PODER: EstadoJugadorPoder,
		Jugador.Estado.ESPERANDO_PODER: EstadoJugadorEsperandoPoder,
		Jugador.Estado.GOL: EstadoJugadorGol,
		Jugador.Estado.REINICIO : EstadoJugadorReinicio,
	}

func get_fresh_state( estado : Jugador.Estado ) -> EstadoJugador:
	assert(estados.has(estado), "estado no encontrado")
	return estados.get(estado).new()
	
