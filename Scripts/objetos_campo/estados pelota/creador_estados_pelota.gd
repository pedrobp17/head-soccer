class_name CreadorEstadoPelota

var estados : Dictionary

func _init() -> void:
	estados = {
		Pelota.Estado.NORMAL: EstadoPelotaNormal,
		Pelota.Estado.PODER: EstadoPelotaPoder,
		Pelota.Estado.REINICIO : EstadoPelotaReinicio,
	}

func get_fresh_state( estado : Pelota.Estado ) -> EstadoPelota:
	assert(estados.has(estado), "estado no encontrado")
	return estados.get(estado).new()
	
