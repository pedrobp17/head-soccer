extends Area2D

const DAÑO_VIDA := 10.0

@onready var detector_daño : Area2D = %"DetectorDaño"

var golpeando = false
var fuerza := 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	detector_daño.body_entered.connect(_on_body_entered_detector_daño)
#Make the action of rotation of the foot
func golpear():
	if golpeando: 
		return
	
	var tween = create_tween()
	golpeando = true
	detector_daño.monitoring = true
	
	tween.tween_property(self, "rotation", deg_to_rad(scale.x * 90),  0.12)
	tween.tween_property(self, "rotation", deg_to_rad(0),  0.18)
	
	golpeando = false
	await tween.finished
	detector_daño.monitoring = false

#Transmit the contact signal
func _on_body_entered(body: Node2D) -> void:
	if body is Pelota:
		var normal = (body.global_position - global_position).normalized()
		EventBus.golpear_pelota.emit(normal, true, fuerza)

func _on_body_entered_detector_daño(body : Node2D) -> void:
	if body is Jugador:
		body.tomar_daño(DAÑO_VIDA)
		
func set_sprite( es_visitante : int) -> void:
	scale.x = es_visitante

func setup(_fuerza : float, capa_enemigo : int): 
	fuerza = _fuerza
	detector_daño.set_collision_mask_value(capa_enemigo, true) 
