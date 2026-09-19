extends ProgressBar
class_name BarraVida

@onready var tiempo = %Timer
@onready var barra_daño = %"BarraDaño"

var vida = 0 : set = set_vida

func set_vida(nueva_vida : int) -> void:
	var vida_previa = vida
	vida = min(max_value, nueva_vida)
	value = vida
		
	if vida <= 0:
		queue_free()
	
	if vida < vida_previa:
		tiempo.start()
	else:
		barra_daño.value = vida
		
		
func inicializar_vida(vida_jugador : int) -> void:
	vida = vida_jugador
	max_value = vida
	value = vida
	barra_daño.max_value = vida
	barra_daño.value = vida
	

func _on_timer_timeout() -> void:
	barra_daño.value = vida
