extends Area2D

const DAÑO_VIDA := 10.0

@onready var detector_daño: Area2D = %DetectorDaño
@onready var detector_poder: Area2D = %DetectorPoder

var golpeando = false
var fuerza := 0.0
var es_visitante: bool

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	detector_daño.body_entered.connect(_on_body_entered_detector_daño)
	detector_poder.body_entered.connect(on_pie_contacto_pelota_en_poder)
	
func golpear():
	if golpeando:
		return
	
	var tween = create_tween()
	golpeando = true
	detector_daño.monitoring = true
	
	tween.tween_property(self, "rotation", deg_to_rad(scale.x * 90), 0.12)
	tween.tween_property(self, "rotation", deg_to_rad(0), 0.18)
	
	golpeando = false
	await tween.finished
	detector_daño.monitoring = false

#Transmit the contact signal
func _on_body_entered(body: Node2D) -> void:
	if body is Pelota and not detector_poder.monitoring:
		var normal = (body.global_position - global_position).normalized()
		EventBus.golpear_pelota.emit(normal, true, fuerza, es_visitante)

func _on_body_entered_detector_daño(body: Node2D) -> void:
	if body is Jugador:
		body.tomar_daño(DAÑO_VIDA)
		
func set_sprite(_es_visitante: int) -> void:
	scale.x = _es_visitante

func setup(_fuerza: float, capa_enemigo: int, _es_visitante: bool) -> void:
	fuerza = _fuerza
	detector_daño.set_collision_mask_value(capa_enemigo, true)
	es_visitante = _es_visitante
	
func set_monitoring_detector_poder(modo: bool) -> void:
	detector_poder.monitoring = modo

func on_pie_contacto_pelota_en_poder() -> void:
	EventBus.pie_contacto_pelota_en_poder.emit()
