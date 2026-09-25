extends TextureProgressBar
class_name BarraPoder

const VALOR_INICIAL = 0.0
const SEGUNDOS_LLENADO = 20

var tasa_llenado 

func set_poder(delta : float) -> void:
	value = min(value + (tasa_llenado * delta), max_value)
	
func inicializar_poder(poder_jugador : float) -> void:
	max_value = poder_jugador
	value = VALOR_INICIAL
	tasa_llenado = poder_jugador / SEGUNDOS_LLENADO
	step = 0
func es_maximo() -> bool:
	return value >= max_value

func reset_poder() -> void: 
	value = VALOR_INICIAL

func incremento_gol() -> void:
	value = min( value + (1.0/4.0) * max_value, max_value)
