class_name NombresPersonajesHelper

static func get_nombre_normal_to_salto_linea( jugador : String) -> String:
	var regex := RegEx.create_from_string("([A-Z])")
	var texto_con_espacios := regex.sub(jugador, " $1", true).strip_edges()
	var array_con_nombre := texto_con_espacios.split(" ")
	return array_con_nombre[0] + "\n" + array_con_nombre[1]

static func get_nombre_salto_linea_to_normal( jugador : String) -> String:
	var texto_unido = jugador.replace("\n", "").replace(" ", "")
	return texto_unido
