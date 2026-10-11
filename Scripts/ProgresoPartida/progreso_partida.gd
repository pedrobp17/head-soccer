extends Node

var personajes_desbloqueados : InfoPersonajes = null

func _ready() -> void:
	personajes_desbloqueados = InfoPersonajes.new()
	add_child(personajes_desbloqueados)
