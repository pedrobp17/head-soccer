
extends movimiento_jugador
class_name jugador2


func get_posicion_inicial():
	return Vector2(591, -148)

func get_salto():
	return "p2_jump"
	
func get_izquierda():
	return "p2_left"
	
func get_derecha():
	return "p2_right"
	
func get_patada():
	return "p2_kick"
