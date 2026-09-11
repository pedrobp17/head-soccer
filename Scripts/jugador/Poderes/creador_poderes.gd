extends Node
class_name CreadorPoderes

var poderes : Dictionary

func _init() -> void:
	poderes = {
		"mano_magica" : PoderManoMagica,
	}

func get_script_poder( nombre : String) -> Poder:
	assert(poderes.has(nombre), "poder no creado")
	return poderes.get(nombre).new()
