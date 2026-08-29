extends Area2D

var golpeando = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
#Make the action of rotation of the foot
func golpear():
	if golpeando: 
		return
	
	var tween = create_tween()
	golpeando = true

	tween.tween_property(self, "rotation", deg_to_rad(90),  0.12)
	tween.tween_property(self, "rotation", deg_to_rad(0),  0.18)
	
	golpeando = false


#Transmit the contact signal
func _on_body_entered(body: Node2D) -> void:
	if body is Pelota:
		var normal = (body.global_position - global_position).normalized()
		EventBus.golpear_pelota.emit(normal, true)
