extends ProgressBar
class_name BarraVida

@onready var tiempo = %Timer
@onready var barra_daño = %"BarraDaño"

var vida = 0.0 : set = set_vida

func set_vida(nueva_vida : float) -> void:
	var vida_previa = vida
	vida = max(nueva_vida, 0)
	value = vida
	
	if vida < vida_previa:
		tiempo.start()
	else:
		barra_daño.value = vida
		
		
func inicializar_vida(vida_jugador : float) -> void:
	vida = vida_jugador
	max_value = vida
	value = vida
	barra_daño.max_value = vida
	barra_daño.value = vida
	

func _on_timer_timeout() -> void:
	barra_daño.value = vida

func get_texto_vida_restante() -> String:
	return str(int(value)) + "/" + str(int(max_value))
