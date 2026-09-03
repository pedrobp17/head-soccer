extends Node
class_name ComportamientoIA

const REACCION_IA := 300
const FUERZA_SEGUIMIENTO_PELOTA := 20

var pelota : Pelota = null
var jugador : Jugador = null
var tiempo_ultima_decision := Time.get_ticks_msec()

func setup(_jugador : Jugador, _pelota : Pelota) -> void:
	jugador = _jugador
	pelota = _pelota
	
func process_ia() -> void:
	if Time.get_ticks_msec() - tiempo_ultima_decision > REACCION_IA:
		tiempo_ultima_decision = Time.get_ticks_msec()
		configurar_movimiento_ia()
		configurar_decision_ia()
		
func configurar_movimiento_ia() -> void:
	var direccion_fuerza := Vector2.ZERO
	direccion_fuerza += get_direccion_seguimiento()
	direccion_fuerza = direccion_fuerza.limit_length(1.0)
	jugador.velocity.x = direccion_fuerza.x * jugador.estadisticas.get_estadistica("velocidad")
	
func configurar_decision_ia() -> void:
	pass

func get_direccion_seguimiento() -> Vector2:
	return jugador.position.direction_to(pelota.position) 
