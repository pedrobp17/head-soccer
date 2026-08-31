extends StaticBody2D
class_name controlador_porteria

@onready var red : Area2D = %Red

func _ready() -> void:
	red.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body is Pelota:
		EventBus.gol.emit( get_enemigo() )

func get_enemigo():
	pass
