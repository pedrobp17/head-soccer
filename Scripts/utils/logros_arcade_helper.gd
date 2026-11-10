extends Node
class_name LogrosArcadeHelper

enum LogrosGenerales {GANAR_SIN_TIEMPO_EXTRA, METER_5_GOLES}
enum LogrosAreas {RAIMON, WILD, ROYALACADEMY, ZEUS, GENESIS, MARYTIMES, OCCULT, BRAIN}

const DICCIONARIO_LOGROS_AREAS: Dictionary = {
	PantallaArcade.Islas.RAIMON: LogrosAreas.RAIMON,
	PantallaArcade.Islas.MARYTIMES: LogrosAreas.RAIMON,
	PantallaArcade.Islas.OCCULT: LogrosAreas.OCCULT,
	PantallaArcade.Islas.ROYALACADEMY: LogrosAreas.ROYALACADEMY,
	PantallaArcade.Islas.WILD: LogrosAreas.WILD,
	PantallaArcade.Islas.BRAIN: LogrosAreas.BRAIN,
	PantallaArcade.Islas.ZEUS: LogrosAreas.ZEUS,
	PantallaArcade.Islas.GENESIS: LogrosAreas.GENESIS,
}
const MISIONES_GLOBALES := [
	"gana el partido sin encajar goles",
	"gana el partido sin llegar a tiempo extra",
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