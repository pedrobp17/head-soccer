extends Node

var poderes: Dictionary[String, RecursosPoder] = {}
var ruta := "res://Scripts/poderes/base_datos/poderes.json"

func _ready() -> void:
	var datos = CargadorDatos.cargar(ruta)
	if datos == null:
		return
	for poder in datos["poderes"]:
		var nombre := poder["nombre"] as String
		var tipo := poder["tipo"] as int
		var fuerza := poder["fuerza"] as int
		var velocidad := poder["velocidad"] as int
		var recurso_poder := RecursosPoder.new(nombre, tipo, fuerza, velocidad)
		poderes.set(nombre, recurso_poder)

func get_poder(poder: String) -> RecursosPoder:
	if poderes.has(poder):
		return poderes[poder]
	return null
