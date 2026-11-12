extends StaticBody2D
class_name Porteria

const MAX_PELOTA_SOBRE_LARGUERO = 1000

@onready var red : Area2D = %Red
@onready var larguero : Area2D = %AreaLarguero

var es_visitante := false
var tiempo_pelota_sobre_larguero = 0.0 
var pelota_sobre_larguero: Pelota = null

func _ready() -> void:
	larguero.body_entered.connect( _on_area_larguero_body_entered )
	larguero.body_exited.connect(_on_area_larguero_body_exited)
	
func inicializar( _es_visitante: bool ) -> void:
	es_visitante = _es_visitante

func _process(_delta: float) -> void:
	if tiempo_pelota_sobre_larguero != 0.0 && Time.get_ticks_msec() - tiempo_pelota_sobre_larguero > MAX_PELOTA_SOBRE_LARGUERO:
		var direccion = Vector2.LEFT
		if es_visitante:
			direccion = Vector2.RIGHT
		if is_instance_valid(pelota_sobre_larguero):
			pelota_sobre_larguero.empujar_desde_porteria(direccion)
		
func _on_red_body_entered(_body: Node2D) -> void:
	if ControladorPartido.estado_actual.gol_valido():
		EventBus.gol.emit(es_visitante)
	
func _on_area_larguero_body_entered(body: Node2D) -> void:
	if body is Pelota:
		pelota_sobre_larguero = body
		tiempo_pelota_sobre_larguero = Time.get_ticks_msec()


func _on_area_larguero_body_exited(_body: Node2D) -> void:
	tiempo_pelota_sobre_larguero = 0.0
	pelota_sobre_larguero = null
