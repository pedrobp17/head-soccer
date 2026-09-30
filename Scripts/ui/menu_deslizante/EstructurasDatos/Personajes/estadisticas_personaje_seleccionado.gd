extends Control
class_name EstadisticasPersonajeSeleccionado

const CUERPO_PREDEFINIDO = preload("res://Sprites/jugadores/personajes/MarkEvans.png")
const ESCUDO_PREDEFINIDO = preload("res://Sprites/banderas/bandera-raimon.png")
const PODERES_PREDEFINIDO = preload("res://Sprites/poderes/Poder.png")
const ESTADISTICA_PREDEFINIDA = 5

@onready var selector_personajes: MenuDeslizanteSeleccionPersonajes = $"../SelectorPersonajes"
@onready var cuerpo_entero: TextureRect = %CuerpoEntero
@onready var estadisticas: Array[BarraEstadisticas] = []
@onready var poderes: Array[TextureRect] = []
@onready var nombre: Label = %Nombre
@onready var escudo: TextureRect = %Escudo

var tiene_foco := false

func _ready() -> void:
	inicializar_estadisticas()
	inicializar_poderes()
	selector_personajes.item_changed.connect(on_item_changed)
	
func on_item_changed(index: int, data: Variant) -> void:
	var datos_personaje = DatosJugadores.get_jugador(data.name)
	if datos_personaje == null:
		set_personaje_default()
		return
	
	nombre.text = NombresPersonajesHelper.get_nombre(datos_personaje.nombre)
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
	
func cambiar_estado_foco( foco : bool) -> void:
	tiene_foco = foco
	
func inicializar_estadisticas() -> void:
	for hijo in %Estadisticas.get_children():
			if hijo is BarraEstadisticas:
				estadisticas.append(hijo)
		
func inicializar_poderes() -> void:
	for hijo in %Poderes.get_children():
			if hijo is TextureRect:
				poderes.append(hijo)
