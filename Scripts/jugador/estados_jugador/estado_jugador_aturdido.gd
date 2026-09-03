class_name EstadoJugadorAturdido
extends EstadoJugador

const DURACION_ATURDIMIENTO := 2000
const DISTANCIA_KNOCK_BACK := 400
const FUERZA_KNOCK_BACK := -250
var tiempo_inicio_aturdimiento := Time.get_ticks_msec()

func _enter_tree() -> void:
	#animacion_jugador.play("aturdimiento")
	knockback()
	tiempo_inicio_aturdimiento = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if Time.get_ticks_msec() - tiempo_inicio_aturdimiento > DURACION_ATURDIMIENTO:
		jugador.estadisticas.reset_estadistica("vida")
		peticion_transmision_estado.emit(Jugador.Estado.JUGANDO)

func knockback() -> void:
	if not jugador.is_on_floor():
		jugador.velocity += jugador.get_gravity() * delta
