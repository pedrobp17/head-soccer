extends AnimacionPantalla
class_name Nubes

@onready var nubes: AnimationPlayer = %AnimationPlayer

func entrada() -> void:
	nubes.show()
	nubes.play("nubes_entrada")
	await nubes.animation_finished

func salida() -> void:
	nubes.play("nubes_salida")
	await nubes.animation_finished
	nubes.hide()
