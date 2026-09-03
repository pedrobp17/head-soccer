class_name EstadoJugadorAturdido
extends EstadoJugador

const DURACION_ATURDIMIENTO := 2000
const DISTANCIA_KNOCK_BACK := 400
const FUERZA_KNOCK_BACK := Vector2(-2500.0,0)
var tiempo_inicio_aturdimiento := Time.get_ticks_msec()

func _enter_tree() -> void:
	#animacion_jugador.play("aturdimiento")
	knockback()
	tiempo_inicio_aturdimiento = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if not jugador.is_on_floor():
		jugador.velocity += jugador.get_gravity() * delta
		
	jugador.velocity.x = move_toward(jugador.velocity.x, 0, jugador.estadisticas.get_estadistica("velocidad"))
	jugador.move_and_slide()
	
	if Time.get_ticks_msec() - tiempo_inicio_aturdimiento > DURACION_ATURDIMIENTO:
		jugador.estadisticas.reset_estadistica("vida")
		peticion_transmision_estado.emit(Jugador.Estado.JUGANDO)

func knockback() -> void:
	jugador.velocity = FUERZA_KNOCK_BACK * Jugador.BANDO[jugador.es_visitante]
