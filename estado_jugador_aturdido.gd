class_name EstadoJugadorAturdido
extends EstadoJugador

const DURACION_ATURDIMIENTO := 2000

var tiempo_inicio_aturdimiento := Time.get_ticks_msec()

func _enter_tree() -> void:
	#animacion_jugador.play("aturdimiento")
	tiempo_inicio_aturdimiento = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - tiempo_inicio_aturdimiento > DURACION_ATURDIMIENTO:
		EventBus.peticion_transmision_estado.emit(Jugador.Estado.JUGANDO)
