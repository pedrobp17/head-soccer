extends EstadoPelota
class_name EstadoPelotaReinicio

func _enter_tree() -> void:
	pelota.reset()
	cambiar_estado(Pelota.Estado.NORMAL)
