extends Node
class_name InfoPersonajes

# Plantilla con el progreso inicial (solo lectura, va dentro del juego).
const RUTA_PLANTILLA := "res://Scripts/ProgresoPartida/ItemDesbloqueados/progreso_personajes.json"

# Partida real del jugador (editable, también en el juego exportado).
const RUTA_JSON := "user://progreso_personajes.json"

var personajes: Dictionary[String, ProgresoPersonajes] = {}

# Nombres de todos los personajes, en el orden del JSON. Se rellena al cargar.
var nombres_personajes: Array[String] = []


func _ready() -> void:
	reiniciar_progreso()
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

	personajes.clear()
	nombres_personajes.clear()

	for nombre in datos:
		var datos_personaje: Dictionary = datos[nombre]

		# El nombre está en la clave del JSON.
		datos_personaje["nombre"] = nombre

		var progreso := ProgresoPersonajes.new()
		progreso.inicializar(datos_personaje)

		personajes[nombre] = progreso
		nombres_personajes.append(nombre)


# OBTIENE EL PROGRESO DE UN PERSONAJE POR NOMBRE O POR POSICIÓN.

func get_personaje_nombre(nombre: String) -> ProgresoPersonajes:
	return personajes.get(nombre, null)


func get_personaje_indice(indice: int) -> ProgresoPersonajes:
	if indice < 0 or indice >= nombres_personajes.size():
		push_warning("Índice de personaje fuera de rango: " + str(indice))
		return null
	return personajes[nombres_personajes[indice]]


# DEVUELVE UNA COPIA DEL ARRAY CON LOS NOMBRES DE TODOS LOS PERSONAJES.
# Es una copia: modificarla no afecta al array interno.

func get_nombres_personajes() -> Array[String]:
	return nombres_personajes.duplicate()


# GUARDA TODOS LOS DATOS EN EL JSON.

func guardar_progreso() -> void:
	var datos: Dictionary = {}

	for nombre in personajes:
		datos[nombre] = personajes[nombre].a_diccionario()

	var archivo := FileAccess.open(RUTA_JSON, FileAccess.WRITE)
	if archivo == null:
		push_error("No se ha podido guardar el JSON de progreso.")
		return

	archivo.store_string(JSON.stringify(datos, "\t"))
	archivo.close()


# BORRA LA PARTIDA GUARDADA Y VUELVE AL PROGRESO INICIAL (PARTIDA NUEVA).

func reiniciar_progreso() -> void:
	if FileAccess.file_exists(RUTA_JSON):
		var error := DirAccess.remove_absolute(RUTA_JSON)
		if error != OK:
			push_error("No se ha podido borrar el JSON de progreso. Error: " + str(error))
			return

	personajes.clear()
	nombres_personajes.clear()
	crear_progreso_inicial()
	cargar_progreso()


# AUXILIAR: obtiene el personaje y avisa si no existe.

func _obtener(nombre: String) -> ProgresoPersonajes:
	var personaje := get_personaje_nombre(nombre)
	if personaje == null:
		push_warning("No existe el personaje: " + nombre)
	return personaje


# GETTERS
func get_desbloqueado(nombre: String) -> bool:
	var personaje := _obtener(nombre)
	return personaje.desbloqueado if personaje else false

func get_partidos_ganados(nombre: String) -> int:
	var personaje := _obtener(nombre)
	return personaje.partidos_ganados if personaje else 0

func get_partidos_perdidos(nombre: String) -> int:
	var personaje := _obtener(nombre)
	return personaje.partidos_perdidos if personaje else 0

func get_torneos_ganados(nombre: String) -> int:
	var personaje := _obtener(nombre)
	return personaje.torneos_ganados if personaje else 0

func get_mundiales_ganados(nombre: String) -> int:
	var personaje := _obtener(nombre)
	return personaje.mundiales_ganados if personaje else 0

func get_ligas_ganadas(nombre: String) -> int:
	var personaje := _obtener(nombre)
	return personaje.ligas_ganadas if personaje else 0

func get_peleas_ganadas(nombre: String) -> int:
	var personaje := _obtener(nombre)
	return personaje.peleas_ganadas if personaje else 0

func get_goles_metidos(nombre: String) -> int:
	var personaje := _obtener(nombre)
	return personaje.goles_metidos if personaje else 0

func get_ronda_maxima_survival(nombre: String) -> int:
	var personaje := _obtener(nombre)
	return personaje.ronda_maxima_survival if personaje else 0

func get_usos_poder(nombre: String) -> int:
	var personaje := _obtener(nombre)
	return personaje.usos_poder if personaje else 0

func get_poder1(nombre: String) -> bool:
	var personaje := _obtener(nombre)
	return personaje.poder1 if personaje else false

func get_poder2(nombre: String) -> bool:
	var personaje := _obtener(nombre)
	return personaje.poder2 if personaje else false

func get_descripcion(nombre: String) -> String:
	var personaje := _obtener(nombre)
	return personaje.descripcion if personaje else ""

func get_descripcion_poder1(nombre: String) -> String:
	var personaje := _obtener(nombre)
	return personaje.descripcion_poder1 if personaje else ""

func get_descripcion_poder2(nombre: String) -> String:
	var personaje := _obtener(nombre)
	return personaje.descripcion_poder2 if personaje else ""

# Acceso genérico: numero_poder = 1 o 2.
func get_descripcion_poder(nombre: String, numero_poder: int) -> String:
	match numero_poder:
		1: return get_descripcion_poder1(nombre)
		2: return get_descripcion_poder2(nombre)
		_:
			push_warning("Número de poder no válido: " + str(numero_poder))
			return ""

# Acceso genérico: numero_poder = 1 o 2.
func get_poder_desbloqueado(nombre: String, numero_poder: int) -> bool:
	match numero_poder:
		1: return get_poder1(nombre)
		2: return get_poder2(nombre)
		_:
			push_warning("Número de poder no válido: " + str(numero_poder))
			return false


# SETTERS ACUMULATIVOS
func set_partidos_ganados(nombre: String, cantidad: int = 1) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.partidos_ganados += cantidad

func set_partidos_perdidos(nombre: String, cantidad: int = 1) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.partidos_perdidos += cantidad

func set_torneos_ganados(nombre: String, cantidad: int = 1) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.torneos_ganados += cantidad

func set_mundiales_ganados(nombre: String, cantidad: int = 1) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.mundiales_ganados += cantidad

func set_ligas_ganadas(nombre: String, cantidad: int = 1) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.ligas_ganadas += cantidad

func set_peleas_ganadas(nombre: String, cantidad: int = 1) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.peleas_ganadas += cantidad

func set_goles_metidos(nombre: String, cantidad: int = 1) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.goles_metidos += cantidad

func set_ronda_maxima_survival(nombre: String, cantidad: int = 1) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.ronda_maxima_survival += cantidad

func set_usos_poder(nombre: String, cantidad: int = 1) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.usos_poder += cantidad

func set_desbloqueado(nombre: String, valor: bool = true) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.desbloqueado = valor

func set_poder1(nombre: String, valor: bool = true) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.poder1 = valor

func set_poder2(nombre: String, valor: bool = true) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.poder2 = valor

# Acceso genérico: numero_poder = 1 o 2.
func set_poder_desbloqueado(nombre: String, numero_poder: int, valor: bool = true) -> void:
	match numero_poder:
		1: set_poder1(nombre, valor)
		2: set_poder2(nombre, valor)
		_: push_warning("Número de poder no válido: " + str(numero_poder))

func set_descripcion(nombre: String, texto: String) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.descripcion = texto

func set_descripcion_poder1(nombre: String, texto: String) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.descripcion_poder1 = texto

func set_descripcion_poder2(nombre: String, texto: String) -> void:
	var personaje := _obtener(nombre)
	if personaje:
		personaje.descripcion_poder2 = texto
