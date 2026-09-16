extends EstadoPelota
class_name EstadoPelotaReinicio

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	pelota.estaFuera = true
	peticion_transmision_estado.emit(Pelota.Estado.NORMAL)
