extends Node
class_name CargadorDatos

static func cargar(ruta: String) -> Variant:
	var archivo_json := FileAccess.open(ruta, FileAccess.READ)
	
	if archivo_json == null:
		printerr("no se ha podido leer el archivo .json: ", ruta)
		return null
		
	var texto_json := archivo_json.get_as_text()
	archivo_json.close()
	
	var json := JSON.new()
	
	if json.parse(texto_json) != OK:
		printerr("error al parsear los datos del .json: ", ruta)
		return null
	
	return json.data
	
