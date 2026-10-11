class_name ProgresoPersonajes
extends Resource

var nombre: String = ""
var desbloqueado: bool = false
var partidos_ganados: int = 0
var partidos_perdidos: int = 0
var torneos_ganados: int = 0
var mundiales_ganados: int = 0
var ligas_ganadas: int = 0
var peleas_ganadas: int = 0
var goles_metidos: int = 0
var ronda_maxima_survival: int = 0
var usos_poder: int = 0


func inicializar(datos: Dictionary) -> void:
	nombre = datos.get("nombre", "")
	desbloqueado = datos.get("desbloqueado", false)
	partidos_ganados = datos.get("partidos_ganados", 0)
	partidos_perdidos = datos.get("partidos_perdidos", 0)
	torneos_ganados = datos.get("torneos_ganados", 0)
	mundiales_ganados = datos.get("mundiales_ganados", 0)
	ligas_ganadas = datos.get("ligas_ganadas", 0)
	peleas_ganadas = datos.get("peleas_ganadas", 0)
	goles_metidos = datos.get("goles_metidos", 0)
	ronda_maxima_survival = datos.get("ronda_maxima_survival", 0)
	usos_poder = datos.get("usos_poder", 0)


func a_diccionario() -> Dictionary:
	return {
		"desbloqueado": desbloqueado,
		"partidos_ganados": partidos_ganados,
		"partidos_perdidos": partidos_perdidos,
		"torneos_ganados": torneos_ganados,
		"mundiales_ganados": mundiales_ganados,
		"ligas_ganadas": ligas_ganadas,
		"peleas_ganadas": peleas_ganadas,
		"goles_metidos": goles_metidos,
		"ronda_maxima_survival": ronda_maxima_survival,
		"usos_poder": usos_poder
	}
