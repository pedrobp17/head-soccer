extends movimiento_jugador
class_name jugador1


func get_posicion_inicial():
	return Vector2(-591, -148)

func get_salto():
	return "p1_jump"
	
func get_izquierda():
	return "p1_left"
	
func get_derecha():
	return "p1_right"
	
func get_patada():
	return "p1_kick"
