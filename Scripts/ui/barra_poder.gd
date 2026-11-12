extends TextureProgressBar
class_name BarraPoder

const VALOR_INICIAL = 0.0
const CAPACIDAD: float = 100.0

var tasa_llenado: float = 0.0

func set_poder(delta : float) -> void:
	value = min(value + (tasa_llenado * delta), max_value)
	
func inicializar_poder(segundos_recarga: float) -> void:
	max_value = CAPACIDAD
	value = VALOR_INICIAL
	tasa_llenado = CAPACIDAD / maxf(segundos_recarga, 0.001)
	step = 0
func es_maximo() -> bool:
	return value >= max_value

func reset_poder() -> void: 
	value = VALOR_INICIAL

func incremento_gol() -> void:
	value = min( value + (1.0/4.0) * max_value, max_value)
