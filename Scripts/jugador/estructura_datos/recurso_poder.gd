class_name RecursosPoder
extends Resource

const DEFENSIVO = 0

@export var nombre : String
@export var tipo : bool
@export var fuerza : int
@export var velocidad : int

func _init( poder_nombre : String, poder_tipo : int, poder_fuerza: int, poder_velocidad : int) -> void:
	nombre = poder_nombre
	tipo = (poder_tipo!=DEFENSIVO) 
	fuerza = poder_fuerza
	velocidad = poder_velocidad 
