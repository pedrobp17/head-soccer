class_name NombresPersonajesHelper

static func get_nombre( jugador : String) -> String:
	var regex := RegEx.create_from_string("([A-Z])")
	var texto_con_espacios := regex.sub(jugador, " $1", true).strip_edges()
	var array_con_nombre := texto_con_espacios.split(" ")
	return array_con_nombre[0] + "\n" + array_con_nombre[1]
