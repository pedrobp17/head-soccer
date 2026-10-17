extends Node
class_name InfoGeneral


const RUTA_PLANTILLA :="res://Scripts/ProgresoPartida/ProgresoModosJuego/progreso_general.json" 


const RUTA_JSON := "user://progreso_general.json"

var datos_generales: Dictionary = {}
var tipos_datos : Dictionary = {
	"global" : ProgresoGlobal,
	"torneo" : Torneo
}

func _ready() -> void:
	crear_progreso_inicial()
	cargar_progreso()
	
func crear_progreso_inicial() -> void:
	if FileAccess.file_exists(RUTA_JSON):
		return

	if not FileAccess.file_exists(RUTA_PLANTILLA):
		push_error("No existe la plantilla de progreso: " + RUTA_PLANTILLA)
		return

	var contenido := FileAccess.get_file_as_string(RUTA_PLANTILLA)

	var archivo := FileAccess.open(RUTA_JSON, FileAccess.WRITE)
	if archivo == null:
		push_error("No se ha podido crear el JSON de progreso en user://.")
		return

	archivo.store_string(contenido)
	archivo.close()


# CARGA LOS DATOS DEL JSON.

func cargar_progreso() -> void:
	if not FileAccess.file_exists(RUTA_JSON):
		push_warning("No existe el archivo de progreso: " + RUTA_JSON)
		return

	var archivo := FileAccess.open(RUTA_JSON, FileAccess.READ)
	if archivo == null:
		push_error("No se ha podido abrir el JSON de progreso.")
		return

	var datos = JSON.parse_string(archivo.get_as_text())
	archivo.close()

	if not datos is Dictionary:
		push_error("El JSON de progreso no contiene un diccionario válido.")
		return

	datos_generales.clear()
	
	for dato in datos:
		assert( tipos_datos[dato].has_method("deserialize"), "no hay metodo para deserializar")
		datos_generales[dato] = tipos_datos[dato].deserialize(datos[dato])
	

func hay_torneo() -> bool:
	return datos_generales["torneo"] != null


func guardar_torneo(torneo: Torneo) -> void:
	datos_generales["torneo"] = torneo
	set_modo_jugado(ProgresoGlobal.Modos.TORNEO)
	guardar_progreso()


func cargar_torneo() -> Torneo:
	if not hay_torneo():
		return null
	return datos_generales["torneo"]


func terminar_torneo() -> void:
	datos_generales["torneo"] = null
	guardar_progreso()


func guardar_progreso() -> void:
	var datos_guardar: Dictionary = {}

	for dato in datos_generales:
		if datos_generales[dato] == null:
			datos_guardar[dato] = {}
		else:
			datos_guardar[dato] = datos_generales[dato].serialize()

	var archivo := FileAccess.open(RUTA_JSON, FileAccess.WRITE)
	if archivo == null:
		push_error("No se ha podido guardar el JSON de progreso.")
		return

	archivo.store_string(JSON.stringify(datos_guardar, "\t"))
	archivo.close()


func get_jugador_seleccionado() -> String:
	return datos_generales["global"].ultimo_jugador_seleccionado

func set_jugador_seleccionado(valor: String) -> void:
	datos_generales["global"].ultimo_jugador_seleccionado = valor

func get_modo_jugado() -> ProgresoGlobal.Modos:
	return datos_generales["global"].ultimo_modo_jugado

func set_modo_jugado(valor: ProgresoGlobal.Modos) -> void:
	datos_generales["global"].ultimo_modo_jugado = valor

func get_poder_seleccionado() -> String:
	return datos_generales["global"].ultimo_poder_jugador_seleccionado

func set_poder_seleccionado(valor: String) -> void:
	datos_generales["global"].ultimo_poder_jugador_seleccionado = valor

# BORRA LA PARTIDA GUARDADA Y VUELVE AL PROGRESO INICIAL (PARTIDA NUEVA).

func reiniciar_progreso() -> void:
	if FileAccess.file_exists(RUTA_JSON):
		var error := DirAccess.remove_absolute(RUTA_JSON)
		if error != OK:
			push_error("No se ha podido borrar el JSON de progreso. Error: " + str(error))
			return
	
	datos_generales.clear()
	crear_progreso_inicial()
	cargar_progreso()
