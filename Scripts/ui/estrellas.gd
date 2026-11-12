extends Control
class_name Estrellas

@onready var conseguida: TextureRect = %conseguida
@onready var no_conseguida: TextureRect = %no_conseguida

func inicializar(desbloqueada: bool = false) -> void:
	if desbloqueada:
		mostrar_conseguida()
	else:
		mostrar_no_conseguida()
		
func mostrar_no_conseguida() -> void:
	conseguida.hide()
	no_conseguida.show()
	
func mostrar_conseguida() -> void:
	conseguida.show()
	no_conseguida.hide()
