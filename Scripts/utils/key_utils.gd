extends Node


enum Accion {DERECHA, IZQUIERDA, SALTO, PATADA}

const MAPA_ACCIONES : Dictionary = {
	Jugador.ControlScheme.P1: {
		Accion.DERECHA: "p1_right",
		Accion.IZQUIERDA: "p1_left",
		Accion.SALTO: "p1_jump",
		Accion.PATADA: "p1_kick",
	},
	Jugador.ControlScheme.P2: {
		Accion.DERECHA: "p2_right",
		Accion.IZQUIERDA: "p2_left",
		Accion.SALTO: "p2_jump",
		Accion.PATADA: "p2_kick",
	},
}

func get_input_vector( esquema: Jugador.ControlScheme) -> float:
	var mapa : Dictionary = MAPA_ACCIONES[esquema]
	return Input.get_axis(mapa[Accion.IZQUIERDA], mapa[Accion.DERECHA] )
	
func is_action_pressed(esquema: Jugador.ControlScheme, accion: Accion) -> bool:
	return Input.is_action_pressed(MAPA_ACCIONES[esquema][accion])

func is_action_just_pressed(esquema: Jugador.ControlScheme, accion: Accion) -> bool:
	return Input.is_action_just_pressed(MAPA_ACCIONES[esquema][accion])

func is_action_just_released(esquema: Jugador.ControlScheme, accion: Accion) -> bool:
	return Input.is_action_just_released(MAPA_ACCIONES[esquema][accion])
