extends EstadoJuego
class_name EstadoJuegoGol

const DURACION_CELEBRACION_GOL := 3 * 1000

var tiempo := Time.get_ticks_msec()

func _enter_tree() -> void:
	var indice_jugador_anotador := 1 if datos_juego.jugador_anotador == controlador.jugadores[0] else 0
	controlador.marcador[indice_jugador_anotador] += 1
	tiempo = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - tiempo > DURACION_CELEBRACION_GOL:
		peticion_transmitir_estado.emit(ControladorPartido.Estado.RESETEO)
