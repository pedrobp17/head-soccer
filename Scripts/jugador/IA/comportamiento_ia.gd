extends Node
class_name ComportamientoIA

const REACCION_IA := 200
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
	print( name + "moviendo")
	
func configurar_decision_ia() -> void:
	pass
