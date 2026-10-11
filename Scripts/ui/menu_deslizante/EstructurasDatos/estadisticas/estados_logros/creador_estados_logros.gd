class_name CreadorEstadoLogros
 
var estados : Dictionary
 
func _init() -> void:
	estados = {
		Logros.Estado.ELIGIENDO: EstadoLogrosEligiendo,
		Logros.Estado.VIENDO: EstadoLogrosViendo,
	}
 
func get_fresh_state( estado : Logros.Estado ) -> EstadoLogros:
	assert(estados.has(estado), "estado no encontrado")
	return estados.get(estado).new()
 
