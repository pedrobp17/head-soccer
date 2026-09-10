extends StaticBody2D
class_name Porteria

@onready var red : Area2D = %Red

var jugador := ""
 
func _ready() -> void:
	pass

func inicializar( _jugador: String ) -> void:
	jugador = _jugador


func _on_red_body_entered(body: Node2D) -> void:
	EventBus.gol.emit( jugador )
	print("gol:" + jugador)
