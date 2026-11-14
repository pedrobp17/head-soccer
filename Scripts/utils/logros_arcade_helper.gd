extends Node
class_name LogrosArcadeHelper

enum Ids {GANA_PARTIDO, PORTERIA, DIFERENCIA, SIN_PODER, TIEMPO_EXTRA, GOL_PATADA, GOL_CABEZAZO, GOL_PATADA_CABEZAZO, IR_PERDIENDO, GOL_TIEMPO, GOL_PRIMERO, VENTAJA, GOL, PODER}

const MAPA_MISIONES_JUGADORES: Dictionary = {
	"MarkEvans": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.PORTERIA, "objetivo": true},
			{"id": Ids.GOL_PATADA, "objetivo": 1}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.DIFERENCIA, "objetivo": 2},
			{"id": Ids.GOL_CABEZAZO, "objetivo": 1}
		]
	},
	"AxelBlaze": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.SIN_PODER, "objetivo": true},
			{"id": Ids.GOL_PATADA, "objetivo": 1}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.PORTERIA, "objetivo": true},
			{"id": Ids.GOL_PATADA_CABEZAZO, "objetivo": 1}
		]
	},
	"XavierFoster": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.DIFERENCIA, "objetivo": 2},
			{"id": Ids.GOL_CABEZAZO, "objetivo": 1}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.TIEMPO_EXTRA, "objetivo": true},
			{"id": Ids.GOL_PATADA_CABEZAZO, "objetivo": 1}
		]
	},
	"HarleyKane": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.PORTERIA, "objetivo": true},
			{"id": Ids.GOL_PATADA, "objetivo": 2}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.DIFERENCIA, "objetivo": 2},
			{"id": Ids.GOL_PATADA, "objetivo": 3}
		]
	},
	"JohanTassman": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.SIN_PODER, "objetivo": true},
			{"id": Ids.IR_PERDIENDO, "objetivo": 1}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.DIFERENCIA, "objetivo": 2},
			{"id": Ids.IR_PERDIENDO, "objetivo": 2}
		]
	},
	"NathanJones": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.PORTERIA, "objetivo": true},
			{"id": Ids.GOL_TIEMPO, "objetivo": 20}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.TIEMPO_EXTRA, "objetivo": true},
			{"id": Ids.IR_PERDIENDO, "objetivo": 2}
		]
	},
	"JudeSharp": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.SIN_PODER, "objetivo": true},
			{"id": Ids.GOL_PRIMERO, "objetivo": true}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.PORTERIA, "objetivo": true},
			{"id": Ids.VENTAJA, "objetivo": 15}
		]
	},
	"CalebStonewall": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.DIFERENCIA, "objetivo": 2},
			{"id": Ids.GOL_PRIMERO, "objetivo": true}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.TIEMPO_EXTRA, "objetivo": true},
			{"id": Ids.GOL, "objetivo": 3}
		]
	},
	"GaryLancaster": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.PORTERIA, "objetivo": true},
			{"id": Ids.GOL_CABEZAZO, "objetivo": 1}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.DIFERENCIA, "objetivo": 2},
			{"id": Ids.GOL_CABEZAZO, "objetivo": 2}
		]
	},
	"AdrianSpeed": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.SIN_PODER, "objetivo": true},
			{"id": Ids.GOL_CABEZAZO, "objetivo": 1}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.PORTERIA, "objetivo": true},
			{"id": Ids.GOL_CABEZAZO, "objetivo": 2}
		]
	},
	"SteveEagle": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.DIFERENCIA, "objetivo": 2},
			{"id": Ids.GOL_CABEZAZO, "objetivo": 2}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.TIEMPO_EXTRA, "objetivo": true},
			{"id": Ids.GOL_CABEZAZO, "objetivo": 3}
		]
	},
	"ThomasFeldt": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.PORTERIA, "objetivo": true},
			{"id": Ids.SIN_PODER, "objetivo": true}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.DIFERENCIA, "objetivo": 2},
			{"id": Ids.PODER, "objetivo": 2}
		]
	},
	"ByronLove": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.SIN_PODER, "objetivo": true},
			{"id": Ids.GOL, "objetivo": 3}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.PORTERIA, "objetivo": true},
			{"id": Ids.GOL, "objetivo": 4}
		]
	},
	"ArtieMishman": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.DIFERENCIA, "objetivo": 2},
			{"id": Ids.GOL, "objetivo": 3}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.TIEMPO_EXTRA, "objetivo": true},
			{"id": Ids.GOL, "objetivo": 4}
		]
	},
	"JonasDemetrius": {
		0: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.PORTERIA, "objetivo": true},
			{"id": Ids.GOL, "objetivo": 4}
		],
		
		1: [
			{"id": Ids.GANA_PARTIDO, "objetivo": true},
			{"id": Ids.DIFERENCIA, "objetivo": 3},
			{"id": Ids.GOL, "objetivo": 5}
		]
	},
	"WilburWatkins": {
		0: [ {"id": Ids.GANA_PARTIDO, "objetivo": true}, {"id": Ids.PORTERIA, "objetivo": true}, {"id": Ids.GOL_PATADA_CABEZAZO, "objetivo": 1}],
		1: [ {"id": Ids.GANA_PARTIDO, "objetivo": true}, {"id": Ids.DIFERENCIA, "objetivo": 3}, {"id": Ids.GOL_PATADA_CABEZAZO, "objetivo": 1}],
	},
	"NelsonRockwell": {
		0: [ {"id": Ids.GANA_PARTIDO, "objetivo": true}, {"id": Ids.SIN_PODER, "objetivo": true}, {"id": Ids.GOL_PATADA_CABEZAZO, "objetivo": 1}],
		1: [ {"id": Ids.GANA_PARTIDO, "objetivo": true}, {"id": Ids.TIEMPO_EXTRA, "objetivo": true}, {"id": Ids.GOL_PATADA_CABEZAZO, "objetivo": 1}],
	},
	"KatieBrown": {
		0: [ {"id": Ids.GANA_PARTIDO, "objetivo": true}, {"id": Ids.DIFERENCIA, "objetivo": 2}, {"id": Ids.GOL_PATADA_CABEZAZO, "objetivo": 1}],
		1: [ {"id": Ids.GANA_PARTIDO, "objetivo": true}, {"id": Ids.PORTERIA, "objetivo": true}, {"id": Ids.PODER, "objetivo": 1}],
	},
}

const TEXTO_MISIONES: Dictionary = {
 	Ids.GANA_PARTIDO: ["gana el partido"],
	Ids.PORTERIA: ["gana sin encajar ningun gol "],
	Ids.DIFERENCIA: ["gana con una diferencia de ", " goles"],
	Ids.SIN_PODER: ["gana sin usar tu poder"],
	Ids.TIEMPO_EXTRA: ["gana en tiempo extra"],
	Ids.GOL_PATADA: ["gana metiendo ", " goles de disparo"],
	Ids.GOL_CABEZAZO: ["gana metiendo ", " goles de cabeza"],
	Ids.GOL_PATADA_CABEZAZO: ["gana metiendo ", " goles de cabeza y disparo"],
	Ids.IR_PERDIENDO: ["gana despues de ir perdiendo por ", " goles"],
	Ids.GOL_TIEMPO: ["gana despues de haber marcado tras haber pasado ", " segundos"],
	Ids.GOL_PRIMERO: ["gana metiendo el primer gol"],
	Ids.VENTAJA: ["gana manteniendo una ventaja de al menos 1 gol durante los últimos ", " segundos"],
	Ids.GOL: ["gana marcando ", " goles y sin ir perdiendo nunca"],
	Ids.PODER: ["gana metiendo ", " goles de poder"]

}

static func get_logros_jugador(jugador: String, poder: int) -> Array:
	assert(MAPA_MISIONES_JUGADORES.has(jugador), "El jugador '%s' no existe en MAPA_MISIONES_JUGADORES." % jugador)
	assert(MAPA_MISIONES_JUGADORES[jugador].has(poder), "El jugador '%s' no tiene definido el poder %d." % [jugador, poder])
	return MAPA_MISIONES_JUGADORES[jugador][poder]

static func get_texto_logro(jugador: String, poder: int) -> Array[String]:
	var array_texto: Array[String] = []
	assert(MAPA_MISIONES_JUGADORES.has(jugador), "El jugador '%s' no existe en MAPA_MISIONES_JUGADORES." % jugador)
	assert(MAPA_MISIONES_JUGADORES[jugador].has(poder), "El jugador '%s' no tiene definido el poder %d." % [jugador, poder])
	
	for logro: Dictionary in get_logros_jugador(jugador, poder):
		var id: int = logro["id"]
		var valor: Variant = logro["objetivo"]
		var partes: Array = TEXTO_MISIONES[id]
		if partes.size() > 1:
			array_texto.append(partes[0] + str(valor) + partes[1])
		else:
			array_texto.append(partes[0])
	
	return array_texto