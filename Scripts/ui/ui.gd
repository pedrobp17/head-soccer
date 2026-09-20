extends CanvasLayer
class_name UI

@onready var barras_vida : Array[BarraVida] = [%BarraVida, %BarraVida2]
@onready var marcador : Array[Label] = [%marcador1, %marcador2]
@onready var nombres_personajes : Array[Label] = [%Nombre1, %Nombre2]
@onready var porcentaje_vida : Array[Label] = [%Vida1, %Vida2]
@onready var imagenes_personajes : Array[TextureRect] = [%jugador1, %jugador2]
@onready var temporizador : Reloj = %Tiempo
@onready var animacion_gol : AnimadorGol = %AnimacionGol

var estadisticas_jugadores : Array[GestorEstadisticas] = [GestorEstadisticas.new(), GestorEstadisticas.new()]

func _ready() -> void:
	animacion_gol.animar()
	actualizar_marcador()
	actualizar_nombres_personajes()
	actualizar_estadisticas_jugadores()
	actualizar_barras_vida()
	actualizar_porcentaje_vida()
	actualizar_imagenes_personajes()
	actualizar_reloj()
	EventBus.cambiar_barra_vida.connect(set_barra_vida)
	EventBus.gol.connect(on_gol)
	#EventBus.reposicionar.connect(on_reposicionar)
	
func _process(delta: float) -> void:
	actualizar_reloj()

func actualizar_marcador() -> void:
	for i in marcador.size():
		marcador[i].text = str(ControladorPartido.marcador[i])

func actualizar_nombres_personajes() -> void:
	for i in nombres_personajes.size():
		nombres_personajes[i].text = ControladorPartido.jugadores[i]
	
func actualizar_estadisticas_jugadores() -> void: 
	for i in nombres_personajes.size():
		estadisticas_jugadores[i].inicializar( DatosJugadores.get_jugador(nombres_personajes[i].text).estadisticas)
	
func actualizar_barras_vida() -> void:
	pass
	
func actualizar_porcentaje_vida() -> void:
	pass

func actualizar_imagenes_personajes() -> void:
	for i in imagenes_personajes.size():
		imagenes_personajes[i].texture = ImagenesJugadoresHelper.get_icono(ControladorPartido.jugadores[i])

func actualizar_reloj() -> void:
	temporizador.set_valor( ControladorPartido.tiempo_restante)
		
func set_barra_vida(valor : float, es_visitante : bool ) -> void:
	var indice_jugador = 0 if !es_visitante else 1
	barras_vida[indice_jugador].set_vida(valor)
	
func on_gol():
	pass
