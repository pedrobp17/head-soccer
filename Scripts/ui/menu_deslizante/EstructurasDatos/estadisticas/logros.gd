extends Node
class_name Logros

const DURACION_ANIMACION := 0.2
const NUMERO_COLUMNAS := 5
const POSICION_INICIAL := Vector2(128.0, 192.0)
const DIRECCIONES : Dictionary ={
	"izquierda" : Vector2.LEFT,
	"derecha" : Vector2.RIGHT,
	"subir" : Vector2.UP,
	"bajar" : Vector2.DOWN
}

enum Estado {ELIGIENDO, VIENDO}

@onready var barra: CeldasSeleccionPersonajes = %Barra
@onready var marco_seleccion: Panel = %MarcoSeleccion
@onready var eleccion_personaje: Control = %EleccionPersonaje
@onready var estadisticas_personaje: Control = %EstadisticasPersonaje
@onready var numeros_logros : Dictionary[String, Label] = {
	"partidos_ganados" : $FondoPantallaCentral/EstadisticasPersonaje/Datos/Estadisticas/PartidosJugados/valor,
	"victorias" : $FondoPantallaCentral/EstadisticasPersonaje/Datos/Estadisticas/Victorias/valor,
	"perdidos" : $FondoPantallaCentral/EstadisticasPersonaje/Datos/Estadisticas/Perdidos/valor,
	"winrate" : $FondoPantallaCentral/EstadisticasPersonaje/Datos/Estadisticas/WinRate/valor,
	"goles" :  $FondoPantallaCentral/EstadisticasPersonaje/Datos/Estadisticas/Goles/valor,
	"poderes_usados" : $FondoPantallaCentral/EstadisticasPersonaje/Datos/Estadisticas/Poderes/valor
}
@onready var cuerpo_entero: TextureRect = %CuerpoEntero
@onready var texto: Label = %Texto
@onready var equipo: TextureRect = %equipo
@onready var imagen: TextureRect = %imagen
@onready var poderes : Array = [ $FondoPantallaCentral/EstadisticasPersonaje/Poderes/lista/primero/Panel/TextureRect, $FondoPantallaCentral/EstadisticasPersonaje/Poderes/lista/segundo/Panel/TextureRect]

var tiene_foco : bool = true
var numero_personajes : int
var coordenadas_casilla_actual := Vector2(0,0)
var coordenadas_casillas_visibles := Vector2(0,0)
var animacion : bool = false
var filas_visibles : Array = [0,1]

var creador_estados := CreadorEstadoLogros.new()
var estado_actual : EstadoLogros = null


func _ready() -> void:
	numero_personajes = barra.numero_elementos
	cambiar_estado(Estado.ELIGIENDO)


# Único punto por donde se cambia de estado.
# El estado actual se retira y se crea uno nuevo como hijo.
func cambiar_estado( nuevo_estado : Estado, datos : DatosEstadoLogros = DatosEstadoLogros.new() ) -> void:
	if estado_actual:
		remove_child(estado_actual)
		estado_actual.queue_free()

	estado_actual = creador_estados.get_fresh_state(nuevo_estado)
	estado_actual.setup(self, datos)
	estado_actual.peticion_transmision_estado.connect(cambiar_estado)
	add_child(estado_actual)


func cambiar_estado_foco( foco : bool) -> void:
	tiene_foco = foco
	if tiene_foco:
		marco_seleccion.show()
	else:
		marco_seleccion.hide()

func puedo_subir_menu_principal( ) -> bool:
	return coordenadas_casilla_actual == Vector2.ZERO

func nueva_celda_seleccionada( direccion : Vector2) -> void:
	var nueva_celda = coordenadas_casilla_actual + direccion

	if es_posicion_valida(nueva_celda):
		coordenadas_casilla_actual = nueva_celda

		if coordenadas_casilla_actual.y < filas_visibles[0]:
			actualizar_filas_visibles("resta")
			barra.subir_fila()

		elif coordenadas_casilla_actual.y > filas_visibles[1]:
			actualizar_filas_visibles("suma")
			barra.bajar_fila()

		else:
			animacion = true
			coordenadas_casillas_visibles += direccion
			transicion_marco_seleccion(get_coordenadas_celda_objetivo(coordenadas_casillas_visibles))

func es_posicion_valida(nueva_posicion : Vector2) -> bool:
	if nueva_posicion.x >= NUMERO_COLUMNAS || nueva_posicion.x < 0 || nueva_posicion.y < 0:
		return false

	var elemento = get_indice_jugador(nueva_posicion)
	return elemento < numero_personajes

func get_indice_jugador(nueva_posicion : Vector2) -> int:
	return int(nueva_posicion.y * NUMERO_COLUMNAS + nueva_posicion.x)

func transicion_marco_seleccion( nueva_posicion : Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(marco_seleccion, "global_position", nueva_posicion, DURACION_ANIMACION )
	await tween.finished
	animacion = false

func get_coordenadas_celda_objetivo( nueva_celda : Vector2) -> Vector2:
	return nueva_celda * Vector2(barra.DISTANCIA_ENTRE_CELDAS, barra.DISTANCIA_ENTRE_CELDAS) + POSICION_INICIAL

func actualizar_filas_visibles( operacion : String) -> void:
	var valor_suma = 1 if operacion == "suma" else -1
	for i in filas_visibles.size():
		filas_visibles[i] += valor_suma

func mostrar_eleccion_personajes() -> void:
	eleccion_personaje.show()
	estadisticas_personaje.hide()

func mostrar_estadisticas_personajes() -> void:
	eleccion_personaje.hide()
	estadisticas_personaje.show()

func set_pantalla_estadisticas_personaje(indice : int) -> void:
	var logros_jugador = ProgresoPartida.personajes_desbloqueados.get_personaje_indice(indice)
	var info_personaje = DatosJugadores.get_jugador(logros_jugador.nombre)

	var partidos_totales : int = logros_jugador.partidos_ganados + logros_jugador.partidos_perdidos

	numeros_logros["partidos_ganados"].text = str(partidos_totales)
	numeros_logros["victorias"].text = str(logros_jugador.partidos_ganados)
	numeros_logros["perdidos"].text = str(logros_jugador.partidos_perdidos)
	numeros_logros["winrate"].text = "0" if partidos_totales == 0 else str(roundi(float(logros_jugador.partidos_ganados) / partidos_totales * 100.0))
	numeros_logros["goles"].text = str(logros_jugador.goles_metidos)
	numeros_logros["poderes_usados"].text = str(logros_jugador.usos_poder)
	texto.text = NombresPersonajesHelper.get_nombre_normal_to_separacion_espacio( logros_jugador.nombre )
	cuerpo_entero.texture = ImagenJugadorEnteroHelper.get_icono(logros_jugador.nombre)
	imagen.texture = CabezasHelper.get_cabeza(logros_jugador.nombre)
	equipo.texture = BanderasHelper.get_sprite(info_personaje.equipo)

	var array_texturas_poderes = PoderesHelper.get_icono(info_personaje.nombre, info_personaje.poderes)
	for i in mini(poderes.size(), array_texturas_poderes.size()):
		poderes[i].texture = array_texturas_poderes[i]
