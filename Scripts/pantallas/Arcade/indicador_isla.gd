extends Control
class_name IndicadorIsla

@export var nombre_equipo_isla : String
@export var indice_equipo_isla : int
@export var amplitud := 5.0        
@export var duracion := 1.1 

@onready var indicador_completados: Label = %indicadorCompletados
@onready var indice_isla: Label = %indiceIsla
@onready var nombre: Label = %nombre
@onready var no_seleccionado: TextureRect = %no_seleccionado
@onready var seleccionado: TextureRect = %seleccionado
@onready var bloqueado: TextureRect = %bloqueado

var base_y := 0.0
var tween: Tween


func _ready() -> void:
	nombre.text = nombre_equipo_isla
	indice_isla.text = str(indice_equipo_isla)
	set_bloqueado()
	base_y = self.position.y

func set_niveles_ganados(niveles_ganados : int, niveles_totales : int) -> void:
	indicador_completados.text = str(niveles_ganados) + "/" + str(niveles_totales)
func set_actual() -> void:
	no_seleccionado.hide()
	seleccionado.show()
	indicador_completados.show()
	bloqueado.hide()
	iniciar_animacion()

func set_desbloqueado(era_actual : bool = false) -> void:
	no_seleccionado.show()
	seleccionado.hide()
	indicador_completados.show()
	bloqueado.hide()
	if era_actual:
		finalizar_animacion()
		
func set_bloqueado() -> void:
	no_seleccionado.hide()
	seleccionado.hide()
	indicador_completados.hide()
	bloqueado.show()


func iniciar_animacion() -> void:
	_matar_tween()
	self.position.y = base_y

	tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", base_y - amplitud, duracion)
	tween.tween_property(self, "position:y", base_y, duracion)

func finalizar_animacion(suave := true) -> void:
	_matar_tween()
	if suave:
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:y", base_y, 0.25)
	else:
		self.position.y = base_y


func _matar_tween() -> void:
	if tween != null and tween.is_valid():
		tween.kill()
	tween = null
