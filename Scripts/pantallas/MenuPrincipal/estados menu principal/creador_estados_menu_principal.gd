class_name CreadorEstadoMenuPrincipal

var estados : Dictionary

func _init() -> void:
	estados = {
		MenuPrincipal.Estado.MENU: EstadoMenuPrincipalMenu,
		MenuPrincipal.Estado.SKIN: Logros,
		MenuPrincipal.Estado.LOGROS: ManejadorMenuPersonajes,
		#MenuPrincipal.Estado.AJUSTES: EstadoMenuPrincipalAjustes,
	}

func get_fresh_state( estado : MenuPrincipal.Estado ) -> EstadoMenuPrincipal:
	assert(estados.has(estado), "estado no encontrado")
	return estados.get(estado).new()
