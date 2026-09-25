extends CanvasLayer
class_name UI

const NUM_JUGADORES = 2
@onready var barras_vida : Array[BarraVida] = [%BarraVida, %BarraVida2]
@onready var barras_poder : Array[BarraPoder] = [%poder1, %poder2]
@onready var marcador : Array[Label] = [%marcador1, %marcador2]
@onready var nombres_personajes : Array[Label] = [%Nombre1, %Nombre2]
@onready var porcentaje_vida : Array[Label] = [%Vida1, %Vida2]
@onready var imagenes_personajes : Array[TextureRect] = [%jugador1, %jugador2]
@onready var temporizador : Reloj = %Tiempo
@onready var animacion_gol : AnimadorGol = %AnimacionGol
@onready var texto_fin : Label = %Fin
@onready var texto_tiempo_extra : Label = %TiempoExtra

var estadisticas_jugadores : Array[GestorEstadisticas] = [GestorEstadisticas.new(), GestorEstadisticas.new()]
var poder_listo : Array[bool] = [false, false]

func _ready() -> void:
	actualizar_marcador()
	actualizar_nombres_personajes()
	actualizar_estadisticas_jugadores()
	actualizar_vida()
	actualizar_poder()
	actualizar_imagenes_personajes()
	actualizar_reloj()
	texto_fin.hide()
	texto_tiempo_extra.hide()
	EventBus.cambiar_barra_vida.connect(set_barra_vida)
	EventBus.gol.connect(on_gol)
	EventBus.cambio_marcador.connect(on_cambio_marcador)
	EventBus.fin_partido.connect(on_fin_partido)
	EventBus.en_tiempo_extra.connect(on_tiempo_extra)
	EventBus.gastar_poder.connect(on_gastar_poder)
	
func _process(delta: float) -> void:
	actualizar_reloj()
	incrementar_poder(delta)
	
func actualizar_marcador() -> void:
	for i in NUM_JUGADORES:
		marcador[i].text = str(ControladorPartido.marcador[i])

func actualizar_nombres_personajes() -> void:
	for i in NUM_JUGADORES:
		nombres_personajes[i].text = ControladorPartido.jugadores[i]
	
func actualizar_estadisticas_jugadores() -> void: 
	for i in NUM_JUGADORES:
		estadisticas_jugadores[i].inicializar( DatosJugadores.get_jugador(nombres_personajes[i].text).estadisticas)
	
func actualizar_vida() -> void:
	for i in NUM_JUGADORES:
		var vida = estadisticas_jugadores[i].get_estadistica("vida")
		barras_vida[i].inicializar_vida(vida)
		porcentaje_vida[i].text = barras_vida[i].get_texto_vida_restante()

func actualizar_poder() -> void: 
	for i in NUM_JUGADORES:
		barras_poder[i].inicializar_poder(estadisticas_jugadores[i].get_estadistica("power"))
		
func actualizar_imagenes_personajes() -> void:
	for i in NUM_JUGADORES:
		imagenes_personajes[i].texture = ImagenesJugadoresHelper.get_icono(ControladorPartido.jugadores[i])

func actualizar_reloj() -> void:
	temporizador.set_valor( ControladorPartido.tiempo_restante)

func incrementar_poder(delta : float) -> void:
	for i in NUM_JUGADORES:
		if ControladorPartido.estado_actual.cargar_poder():
			if not barras_poder[i].es_maximo(): 
				barras_poder[i].set_poder(delta)
			elif not poder_listo[i]:
				poder_listo[i] = true
				EventBus.poder_cargado.emit()
	
func set_barra_vida(valor : float, es_visitante : bool ) -> void:
	var indice_jugador = 0 if !es_visitante else 1
	barras_vida[indice_jugador].set_vida(valor)
	porcentaje_vida[indice_jugador].text = barras_vida[indice_jugador].get_texto_vida_restante()
	
func on_gol(_jugador_anotador : String) -> void:
	if not ControladorPartido.fin_partido():
		animacion_gol.animar()
	
func on_cambio_marcador( indice_jugador_anotador : int) -> void:
	marcador[indice_jugador_anotador].text = str(ControladorPartido.marcador[indice_jugador_anotador])
	barras_poder[posmod(indice_jugador_anotador + 1, NUM_JUGADORES)].incremento_gol()
	
func on_fin_partido(jugador, array) -> void:
	texto_fin.show()
	
func on_tiempo_extra() -> void:
	texto_tiempo_extra.show()
	 
func on_gastar_poder( es_visitante : bool) -> void:
	var indice_jugador = 1 if es_visitante else 0
	barras_poder[indice_jugador].reset_poder()
	poder_listo[indice_jugador] = false
