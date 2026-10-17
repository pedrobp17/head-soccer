extends Node

var personajes_desbloqueados : InfoPersonajes = null
var progreso_general : InfoGeneral = null

func _ready() -> void:
	personajes_desbloqueados = InfoPersonajes.new()
	add_child(personajes_desbloqueados)
	
	progreso_general = InfoGeneral.new()
	add_child(progreso_general)
