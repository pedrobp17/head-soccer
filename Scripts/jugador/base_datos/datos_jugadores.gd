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
		var velocidad := jugador["estadisticas"]["velocidad"] as int
		var salto := jugador["estadisticas"]["salto"] as int
		var poder := jugador["estadisticas"]["power"] as int
		var golpe := jugador["estadisticas"]["golpe"] as int
		var equipo := jugador["equipo"] as String
		var recurso_jugador := RecursosJugador.new(nombre, espiritu, poderes, velocidad, salto, poder, golpe,  equipo)
		jugadores.set(nombre, recurso_jugador)
	
func get_jugador(jugador: String) -> RecursosJugador:
	if jugadores.has(jugador):
		return jugadores[jugador]
	return null
