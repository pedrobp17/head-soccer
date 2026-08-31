extends Node

const ESPIRITU = 1

var jugadores: Dictionary[String, RecursosJugador] = {}
var ruta := "res://Scripts/jugador/base_datos/jugadores.json"

func _ready() -> void:

	var datos = CargadorDatos.cargar(ruta)

	if datos == null:
		return

	for jugador in datos["jugadores"]:
		var nombre := jugador["nombre"] as String
		var espiritu := jugador["espiritu"] as int
		var poderes := jugador["poderes"] as Array
		var estadisticas : Dictionary = jugador["estadisticas"] 
		var equipo := jugador["equipo"] as String
		
		var recurso_jugador := RecursosJugador.new(nombre, espiritu, poderes, estadisticas, equipo)
		jugadores.set(nombre, recurso_jugador)
	
func get_jugador(jugador: String) -> RecursosJugador:
	if jugadores.has(jugador):
		return jugadores[jugador]
	return null
