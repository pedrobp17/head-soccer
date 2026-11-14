extends Control
class_name EstadisticasPersonajeSeleccionado

const CUERPO_PREDEFINIDO = preload("res://Sprites/jugadores/personajesNoBloq/MarkEvans.png")
const ESCUDO_PREDEFINIDO = preload("res://Sprites/banderas/bandera-raimon.png")
const PODERES_PREDEFINIDO = preload("res://Sprites/poderes/Poder.png")
const ESTADISTICA_PREDEFINIDA = 5
const OFFSET_INDIVIDUAL_POSICION_ESTADISTICAS_X = 4
const OFFSET_POSICION_ESTADISTICAS_X = 320
const POSICION_INICIAL_GENERAL_X = 840

@onready var selector_personajes: MenuDeslizanteSeleccionPersonajes = $"../SelectorPersonajes"
@onready var cuerpo_entero: TextureRect = %CuerpoEntero
@onready var estadisticas: Array[BarraEstadisticas] = []
@onready var poderes: Array[TextureRect] = []
@onready var nombre: Label = %Nombre
@onready var escudo: TextureRect = %Escudo

var tiene_foco := false
var tween_entrada: Tween

func _ready() -> void:
	inicializar_estadisticas()
	inicializar_poderes()
	inicializar_imagenes()
	selector_personajes.item_changed.connect(on_item_changed)
	
func on_item_changed(index: int, data: Variant) -> void:
	var datos_personaje = DatosJugadores.get_jugador(data.name)
	if datos_personaje == null:
		set_personaje_default()
		return
	
	nombre.text = NombresPersonajesHelper.get_nombre_normal_to_salto_linea(datos_personaje.nombre)
	escudo.texture = BanderasHelper.get_sprite(datos_personaje.equipo)
	cuerpo_entero.texture = ImagenJugadorEnteroHelper.get_icono(datos_personaje.nombre)
	
	var mapa_estadisticas_normalizadas := GestorEstadisticas.new()
	mapa_estadisticas_normalizadas.inicializar(datos_personaje.estadisticas)
	var matriz_estadisticas = mapa_estadisticas_normalizadas.get_estadisticas_normalizadas_con_nombre()
	for i in estadisticas.size():
		estadisticas[i].inicializar(matriz_estadisticas[i][1], matriz_estadisticas[i][0])
	
	var texturas_poderes = PoderesHelper.get_icono(datos_personaje.nombre, datos_personaje.poderes)
	for i in poderes.size():
		poderes[i].texture = texturas_poderes[i]
		
func set_personaje_default() -> void:
	nombre.text = "?"
	escudo.texture = ESCUDO_PREDEFINIDO
	cuerpo_entero.texture = CUERPO_PREDEFINIDO
	for i in estadisticas.size():
		estadisticas[i].inicializar(ESTADISTICA_PREDEFINIDA, "?")
	for i in poderes.size():
		poderes[i].texture = PODERES_PREDEFINIDO
	
func cambiar_estado_foco(foco: bool) -> void:
	tiene_foco = foco
	
func inicializar_estadisticas() -> void:
	var todas_estadisticas: VBoxContainer = %Estadisticas
	for i in todas_estadisticas.get_child_count():
		var estadistica = todas_estadisticas.get_child(i).get_child(0)
		estadistica.global_position.x = POSICION_INICIAL_GENERAL_X + OFFSET_POSICION_ESTADISTICAS_X + OFFSET_INDIVIDUAL_POSICION_ESTADISTICAS_X * i
		if estadistica is BarraEstadisticas:
			estadisticas.append(estadistica)
		
func inicializar_poderes() -> void:
	for hijo in %Poderes.get_children():
			if hijo is TextureRect:
				poderes.append(hijo)

func animar() -> Tween:
	if tween_entrada != null and tween_entrada.is_valid():
		tween_entrada.kill()

	tween_entrada = create_tween()
	tween_entrada.set_parallel(true)
	tween_entrada.tween_property(cuerpo_entero, "modulate:a", 1.0, ManejadorMenuPersonajes.ANIMACION_TIEMPO)
	tween_entrada.tween_property(nombre, "modulate:a", 1.0, ManejadorMenuPersonajes.ANIMACION_TIEMPO)
	tween_entrada.tween_property(escudo, "modulate:a", 1.0, ManejadorMenuPersonajes.ANIMACION_TIEMPO)
	
	for i in estadisticas.size():
		tween_entrada.tween_property(estadisticas[i], "global_position:x", POSICION_INICIAL_GENERAL_X - OFFSET_INDIVIDUAL_POSICION_ESTADISTICAS_X * i, ManejadorMenuPersonajes.ANIMACION_TIEMPO)
	return tween_entrada

func preparar_animacion() -> void:
	reposicionar()

func reposicionar() -> void:
	if tween_entrada != null and tween_entrada.is_valid():
		tween_entrada.kill()
	tween_entrada = null
	for i in estadisticas.size():
		estadisticas[i].global_position.x = POSICION_INICIAL_GENERAL_X + OFFSET_POSICION_ESTADISTICAS_X + OFFSET_INDIVIDUAL_POSICION_ESTADISTICAS_X * i
	inicializar_imagenes()

func inicializar_imagenes() -> void:
	nombre.modulate.a = 0.0
	escudo.modulate.a = 0.0
	cuerpo_entero.modulate.a = 0.0
