extends Node
class_name InfoGeneral


const RUTA_PLANTILLA := "res://Scripts/ProgresoPartida/ProgresoModosJuego/progreso_general.json"


const RUTA_JSON := "user://progreso_general.json"

var datos_generales: Dictionary = {}
var tipos_datos: Dictionary = {
	"global": ProgresoGlobal,
	"torneo": Torneo,
	"arcade": ProgresoArcade
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
		if not tipos_datos.has(dato):
			push_warning("Sección desconocida en el JSON de progreso: " + dato)
			continue
		assert(tipos_datos[dato].has_method("deserialize"), "no hay metodo para deserializar")
		datos_generales[dato] = tipos_datos[dato].deserialize(datos[dato])
	
	var arcade: ProgresoArcade = datos_generales.get("arcade")
	if arcade != null and arcade.necesita_guardar_migracion:
		# Conserva el JSON original antes de corregir sus claves en disco.
		var ruta_copia: String = RUTA_JSON + ".antes_niveles_locales.bak"
		if not FileAccess.file_exists(ruta_copia):
			var copia := FileAccess.open(ruta_copia, FileAccess.WRITE)
			if copia == null:
				push_error("No se pudo crear la copia del progreso; migracion solo en memoria.")
				return
			copia.store_string(FileAccess.get_file_as_string(RUTA_JSON))
			copia.close()
		guardar_progreso()
		arcade.necesita_guardar_migracion = false

#TORNEO

func get_jugador_torneo_actual() -> String:
	return datos_generales["torneo"].configuracion_jugador_seleccionado.jugador
	
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


#ARCADE

func get_progreso_arcade() -> ProgresoArcade:
	return datos_generales["arcade"]

func get_islas_desbloqueadas_arcade() -> Array[PantallaArcade.Islas]:
	return get_progreso_arcade().get_islas_desbloqueadas(get_jugador_seleccionado())

func esta_nivel_arcade_vencido(isla: PantallaArcade.Islas, rival: String, nivel: int) -> bool:
	return get_progreso_arcade().esta_vencido(get_jugador_seleccionado(), isla, rival, nivel)

func get_logros_arcade(isla: PantallaArcade.Islas, rival: String, nivel: int) -> Array[bool]:
	return get_progreso_arcade().get_logros_arcade(get_jugador_seleccionado(), isla, rival, nivel)

func set_logros_arcade(isla: PantallaArcade.Islas, rival: String, nivel: int, logros: Array[bool], jugador: String = "") -> void:
	var personaje: String = get_jugador_seleccionado() if jugador.is_empty() else jugador
	if get_progreso_arcade().set_logros_arcade(personaje, isla, rival, nivel, logros):
		guardar_progreso()

func esta_isla_arcade_completada(isla: PantallaArcade.Islas) -> bool:
	return get_progreso_arcade().isla_completada(get_jugador_seleccionado(), isla)
	
func get_niveles_vencidos_arcade(isla: PantallaArcade.Islas) -> int:
	return get_progreso_arcade().get_niveles_vencidos(get_jugador_seleccionado(), isla)

func completar_nivel_arcade(isla: PantallaArcade.Islas, rival: String, nivel: int) -> void:
	var progreso := get_progreso_arcade()
	var jugador := get_jugador_seleccionado()
	progreso.set_vencido(jugador, isla, rival, nivel)
	guardar_progreso()

func desbloquear_isla_arcade(isla: PantallaArcade.Islas) -> bool:
	var progreso := get_progreso_arcade()
	var jugador := get_jugador_seleccionado()
	if isla in progreso.get_islas_desbloqueadas(jugador):
		return false
	progreso.desbloquear_isla(jugador, isla)
	guardar_progreso()
	return true
	
	
#GUARDADO

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


#GLOBAL

func get_jugador_seleccionado() -> String:
	return datos_generales["global"].ultimo_jugador_seleccionado

func set_jugador_seleccionado(valor: String) -> void:
	datos_generales["global"].ultimo_jugador_seleccionado = valor

func get_indice_jugador_seleccionado() -> int:
	return datos_generales["global"].indice_ultimo_jugador_seleccionado

func set_indice_jugador_seleccionado(valor: int) -> void:
	datos_generales["global"].indice_ultimo_jugador_seleccionado = valor
		
func get_modo_jugado() -> ProgresoGlobal.Modos:
	return datos_generales["global"].ultimo_modo_jugado

func set_modo_jugado(valor: ProgresoGlobal.Modos) -> void:
	datos_generales["global"].ultimo_modo_jugado = valor

func get_poder_seleccionado() -> String:
	return datos_generales["global"].ultimo_poder_jugador_seleccionado

func set_poder_seleccionado(valor: String) -> void:
	datos_generales["global"].ultimo_poder_jugador_seleccionado = valor

#AUXILIAR

func puedo_jugar() -> bool:
	var modo := get_modo_jugado()
	var nombre: String = ProgresoGlobal.Modos.keys()[modo].to_lower()
	if datos_generales[nombre] == null or modo == ProgresoGlobal.Modos.ARCADE:
		return true
	var jugador_guardado: ConfiguracionJugadorPartido = datos_generales[nombre].configuracion_jugador_seleccionado
	return jugador_guardado.jugador == get_jugador_seleccionado()
	
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
