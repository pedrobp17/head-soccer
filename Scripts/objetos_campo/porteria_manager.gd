extends Area2D
class_name controlador_porteria

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body is Pelota:
		EventBus.gol.emit( get_enemigo() )

func get_enemigo():
	pass
