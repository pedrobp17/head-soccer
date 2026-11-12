extends Node
class_name LogrosArcadeHelper

enum LogrosAreas {
	RAIMON,
	MARYTIMES,
	OCCULT,
	ROYALACADEMY,
	WILD,
	BRAIN,
	ZEUS,
	GENESIS,
	NONE
}
enum LogrosGenerales {
	GANAR_SIN_TIEMPO_EXTRA = 100,
	METER_5_GOLES = 101
}

const DICCIONARIO_LOGROS_GENERALES: Dictionary = {
	LogrosGenerales.GANAR_SIN_TIEMPO_EXTRA: preload("res://Scripts/Logros/Recursos/GanarSinTiempoExtra.tres"),
	LogrosGenerales.METER_5_GOLES: preload("res://Scripts/Logros/Recursos/Meter5Goles.tres")
}

const DICCIONARIO_LOGROS_AREAS: Dictionary = {
	LogrosAreas.RAIMON: preload("res://Scripts/Logros/Recursos/Raimon.tres"),
	LogrosAreas.MARYTIMES: preload("res://Scripts/Logros/Recursos/MaryTimes.tres"),
	LogrosAreas.OCCULT: preload("res://Scripts/Logros/Recursos/Occult.tres"),
	LogrosAreas.ROYALACADEMY: preload("res://Scripts/Logros/Recursos/RoyalAcademy.tres"),
	LogrosAreas.WILD: preload("res://Scripts/Logros/Recursos/Wild.tres"),
	LogrosAreas.BRAIN: preload("res://Scripts/Logros/Recursos/Brain.tres"),
	LogrosAreas.ZEUS: preload("res://Scripts/Logros/Recursos/Zeus.tres"),
	LogrosAreas.GENESIS: preload("res://Scripts/Logros/Recursos/Genesis.tres"),
}

const MISIONES_GLOBALES := [
	"Gana el partido sin llegar a tiempo extra",
	"Marca al menos 5 goles en un partido",
]
const MISIONES_ISLA: Dictionary = {
	PantallaArcade.Islas.RAIMON: "mision de RAIMON",
	PantallaArcade.Islas.MARYTIMES: "mision de MARYTIMES",
	PantallaArcade.Islas.OCCULT: "mision de OCCULT",
	PantallaArcade.Islas.ROYALACADEMY: "mision de ROYALACADEMY",
	PantallaArcade.Islas.WILD: "mision de WILD",
	PantallaArcade.Islas.BRAIN: "mision de BRAIN",
	PantallaArcade.Islas.ZEUS: "mision de ZEUS",
	PantallaArcade.Islas.GENESIS: "mision de GENESIS",
}

const LOGROS_POR_ISLA: Dictionary = {
	PantallaArcade.Islas.RAIMON: LogrosAreas.RAIMON,
	PantallaArcade.Islas.MARYTIMES: LogrosAreas.MARYTIMES,
	PantallaArcade.Islas.OCCULT: LogrosAreas.OCCULT,
	PantallaArcade.Islas.ROYALACADEMY: LogrosAreas.ROYALACADEMY,
	PantallaArcade.Islas.WILD: LogrosAreas.WILD,
	PantallaArcade.Islas.BRAIN: LogrosAreas.BRAIN,
	PantallaArcade.Islas.ZEUS: LogrosAreas.ZEUS,
	PantallaArcade.Islas.GENESIS: LogrosAreas.GENESIS,
}

static func get_logro_area_desde_isla(isla: PantallaArcade.Islas) -> LogrosAreas:
	return LOGROS_POR_ISLA.get(isla, LogrosAreas.NONE)

static func get_logro_area(isla: PantallaArcade.Islas) -> Array[LogroArcade]:
	var logros: Array[LogroArcade] = []
	logros.append(DICCIONARIO_LOGROS_GENERALES[LogrosGenerales.GANAR_SIN_TIEMPO_EXTRA])
	logros.append(DICCIONARIO_LOGROS_GENERALES[LogrosGenerales.METER_5_GOLES])
	var area: LogrosAreas = get_logro_area_desde_isla(isla)
	if DICCIONARIO_LOGROS_AREAS.has(area):
		logros.append(DICCIONARIO_LOGROS_AREAS[area])
	return logros

static func get_texto_logro(isla: PantallaArcade.Islas) -> Array[String]:
	if MISIONES_ISLA.has(isla):
		return [MISIONES_GLOBALES[0], MISIONES_GLOBALES[1], MISIONES_ISLA[isla]]
	else:
		push_warning("El recurso no es un LogroArcade.")
		return ["error", "error", "error"]
