extends RefCounted
class_name ProgresoArcade

const NIVELES_POR_JUGADOR = 2

var progreso_por_jugador : Dictionary = {}
var necesita_guardar_migracion: bool = false


static func deserialize(datos : Dictionary) -> ProgresoArcade:
	var progreso := ProgresoArcade.new()
	progreso.progreso_por_jugador = datos.duplicate(true)
	progreso.migrar_indices_globales()
	# Migra niveles antiguos (booleanos) y completa el array en guardados previos.
	for jugador in progreso.progreso_por_jugador:
		for isla in progreso.progreso_por_jugador[jugador]:
			var niveles: Dictionary = progreso.progreso_por_jugador[jugador][isla]["jugadores"]
			for clave in niveles:
				niveles[clave] = normalizar_nivel(niveles[clave])
	for jugador in progreso.progreso_por_jugador.keys():
		progreso.asegurar_jugador(jugador)
	return progreso

func serialize() -> Dictionary:
	return progreso_por_jugador


func asegurar_jugador(jugador: String) -> void:
	var plantilla: Dictionary = crear_progreso_jugador()
	if not progreso_por_jugador.has(jugador):
		progreso_por_jugador[jugador] = plantilla
		return
	var actual: Dictionary = progreso_por_jugador[jugador]
	for isla in plantilla:
		if not actual.has(isla):
			actual[isla] = plantilla[isla]
		else:
			var datos_isla: Dictionary = actual[isla]
			# El formato anterior creaba todas las islas desbloqueadas y no
			# tenia una version que permitiera distinguir progreso real. Esta
			# migracion se aplica una sola vez; a partir de la version 1 se
			# conservan siempre los desbloqueos guardados.
			if datos_isla.get("version_desbloqueo", 0) < 1:
				datos_isla["desbloqueada"] = isla == nombre_isla(PantallaArcade.Islas.RAIMON)
				datos_isla["version_desbloqueo"] = 1
				necesita_guardar_migracion = true
			var niveles: Dictionary = datos_isla["jugadores"]
			for clave in plantilla[isla]["jugadores"]:
				if not niveles.has(clave):
					niveles[clave] = normalizar_nivel(false)
	# Conserva entradas antiguas, pero los recuentos solo consideran el catalogo actual.

static func crear_progreso_jugador() -> Dictionary:
	var progreso := {}
	for isla in PantallaArcade.jugadores_islas:
		var jugadores := {}
		var rivales: Array = PantallaArcade.jugadores_islas[isla]
		for rival in rivales:
			for nivel in NIVELES_POR_JUGADOR:
				jugadores[clave_nivel(rival, nivel)] = normalizar_nivel(false)
		progreso[nombre_isla(isla)] = {
			# Una partida nueva comienza exclusivamente en Raimon. Las demas
			# islas conservan sus niveles, pero no se pueden seleccionar hasta
			# que el sistema de progreso las desbloquee.
			"desbloqueada": isla == PantallaArcade.Islas.RAIMON,
			"version_desbloqueo": 1,
			"version_niveles": 2,
			"jugadores": jugadores
		}
	return progreso

static func get_nivel_rival(isla: PantallaArcade.Islas, indice_mapa: int) -> int:
	var cantidad: int = PantallaArcade.jugadores_islas[isla].size()
	assert(indice_mapa >= 0 and indice_mapa < cantidad * NIVELES_POR_JUGADOR)
	return floori(float(indice_mapa) / cantidad)

func migrar_indices_globales() -> void:
	for personaje in progreso_por_jugador:
		var islas: Dictionary = progreso_por_jugador[personaje]
		for isla in PantallaArcade.jugadores_islas:
			var nombre: String = nombre_isla(isla)
			if not islas.has(nombre):
				continue
			var datos_isla: Dictionary = islas[nombre]
			if datos_isla.get("version_niveles", 0) == 2:
				continue
			var antiguos: Dictionary = datos_isla["jugadores"]
			var nuevos: Dictionary = crear_progreso_jugador()[nombre]["jugadores"]
			# Conserva las entradas locales existentes y fusiona las globales sin perder true.
			for clave in nuevos:
				if antiguos.has(clave):
					nuevos[clave] = normalizar_nivel(antiguos[clave])
			var rivales: Array = PantallaArcade.jugadores_islas[isla]
			var contiene_globales: bool = false
			for clave in antiguos:
				if str(clave).get_slice("_", 1).to_int() >= NIVELES_POR_JUGADOR:
					contiene_globales = true
			if contiene_globales:
				for indice in rivales.size() * NIVELES_POR_JUGADOR:
					var rival: String = rivales[indice % rivales.size()]
					var origen: String = clave_nivel(rival, indice)
					var destino: String = clave_nivel(rival, get_nivel_rival(isla, indice))
					if antiguos.has(origen):
						var dato: Dictionary = normalizar_nivel(antiguos[origen])
						nuevos[destino]["vencido"] = nuevos[destino]["vencido"] or dato["vencido"]
						for i in 3:
							nuevos[destino]["logros_arcade"][i] = nuevos[destino]["logros_arcade"][i] or dato["logros_arcade"][i]
			datos_isla["jugadores"] = nuevos
			datos_isla["version_niveles"] = 2
			necesita_guardar_migracion = true

static func clave_nivel(rival : String, nivel : int) -> String:
	return "%s_%d" % [rival, nivel]

static func nombre_isla(isla : PantallaArcade.Islas) -> String:
	return PantallaArcade.Islas.keys()[isla]


func get_islas_desbloqueadas(jugador : String) -> Array[PantallaArcade.Islas]:
	asegurar_jugador(jugador)
	var resultado : Array[PantallaArcade.Islas] = []
	for isla in PantallaArcade.jugadores_islas:
		if progreso_por_jugador[jugador][nombre_isla(isla)]["desbloqueada"]:
			resultado.append(isla)
	return resultado

func desbloquear_isla(jugador : String, isla : PantallaArcade.Islas) -> void:
	asegurar_jugador(jugador)
	progreso_por_jugador[jugador][nombre_isla(isla)]["desbloqueada"] = true

func esta_nivel_desbloqueado(jugador: String, isla: PantallaArcade.Islas, indice_mapa: int) -> bool:
	asegurar_jugador(jugador)
	if not progreso_por_jugador[jugador][nombre_isla(isla)]["desbloqueada"]:
		return false
	if indice_mapa == 0:
		return true
	if indice_mapa < 0 or indice_mapa >= get_niveles_totales(isla):
		return false

	var indice_anterior := indice_mapa - 1
	var rival_anterior: String = PantallaArcade.jugadores_islas[isla][indice_anterior % PantallaArcade.jugadores_islas[isla].size()]
	var nivel_anterior := get_nivel_rival(isla, indice_anterior)
	return esta_vencido(jugador, isla, rival_anterior, nivel_anterior)

static func normalizar_nivel(datos: Variant) -> Dictionary:
	var resultado: Dictionary = datos.duplicate(true) if datos is Dictionary else {"vencido": datos == true}
	resultado["vencido"] = resultado.get("vencido", false) == true
	var logros: Array[bool] = [false, false, false]
	var anteriores: Variant = resultado.get("logros_arcade", [])
	if anteriores is Array:
		for i in mini(anteriores.size(), logros.size()):
			logros[i] = anteriores[i] == true
	resultado["logros_arcade"] = logros
	return resultado

func get_logros_arcade(jugador: String, isla: PantallaArcade.Islas, rival: String, nivel: int) -> Array[bool]:
	if nivel < 0 or nivel >= NIVELES_POR_JUGADOR:
		push_error("El nivel del rival debe ser 0 o 1.")
		return [false, false, false]
	asegurar_jugador(jugador)
	var niveles: Dictionary = progreso_por_jugador[jugador][nombre_isla(isla)]["jugadores"]
	var datos: Dictionary = niveles.get(clave_nivel(rival, nivel), normalizar_nivel(false))
	# Devuelve una copia: consultar no permite modificar accidentalmente el progreso.
	var logros: Array[bool] = []
	logros.assign(datos["logros_arcade"])
	return logros

func set_logros_arcade(jugador: String, isla: PantallaArcade.Islas, rival: String, nivel: int, logros: Array[bool]) -> bool:
	if nivel < 0 or nivel >= NIVELES_POR_JUGADOR:
		push_error("El nivel del rival debe ser 0 o 1.")
		return false
	asegurar_jugador(jugador)
	var niveles: Dictionary = progreso_por_jugador[jugador][nombre_isla(isla)]["jugadores"]
	var clave: String = clave_nivel(rival, nivel)
	if not niveles.has(clave):
		niveles[clave] = normalizar_nivel(false)
	var datos: Dictionary = normalizar_nivel(niveles[clave])
	var guardados: Array[bool] = datos["logros_arcade"]
	var hay_nuevos: bool = false
	for i in mini(logros.size(), guardados.size()):
		# Los logros obtenidos no se pierden al repetir el nivel.
		if logros[i] and not guardados[i]:
			guardados[i] = true
			hay_nuevos = true
	datos["logros_arcade"] = guardados
	niveles[clave] = datos
	return hay_nuevos

func esta_vencido(jugador : String, isla : PantallaArcade.Islas, rival : String, nivel : int) -> bool:
	if nivel < 0 or nivel >= NIVELES_POR_JUGADOR:
		push_error("El nivel del rival debe ser 0 o 1.")
		return false
	asegurar_jugador(jugador)
	return progreso_por_jugador[jugador][nombre_isla(isla)]["jugadores"].get(clave_nivel(rival, nivel), normalizar_nivel(false))["vencido"]

func set_vencido(jugador : String, isla : PantallaArcade.Islas, rival : String, nivel : int, valor : bool = true) -> void:
	if nivel < 0 or nivel >= NIVELES_POR_JUGADOR:
		push_error("El nivel del rival debe ser 0 o 1.")
		return
	asegurar_jugador(jugador)
	var niveles: Dictionary = progreso_por_jugador[jugador][nombre_isla(isla)]["jugadores"]
	var clave: String = clave_nivel(rival, nivel)
	if not niveles.has(clave):
		niveles[clave] = normalizar_nivel(false)
	niveles[clave]["vencido"] = valor

func isla_completada(jugador : String, isla : PantallaArcade.Islas) -> bool:
	asegurar_jugador(jugador)
	for clave in crear_progreso_jugador()[nombre_isla(isla)]["jugadores"]:
		var datos: Dictionary = progreso_por_jugador[jugador][nombre_isla(isla)]["jugadores"][clave]
		if not datos["vencido"]:
			return false
	return true

func get_niveles_vencidos(jugador : String, isla : PantallaArcade.Islas) -> int:
	asegurar_jugador(jugador)
	var total: int = 0
	for clave in crear_progreso_jugador()[nombre_isla(isla)]["jugadores"]:
		var datos: Dictionary = progreso_por_jugador[jugador][nombre_isla(isla)]["jugadores"][clave]
		if datos["vencido"]:
			total += 1
	return total

func get_niveles_totales(isla : PantallaArcade.Islas) -> int:
	return PantallaArcade.jugadores_islas[isla].size() * NIVELES_POR_JUGADOR

