extends Control
class_name IndicadorArea

@export var indice_nivel : int
@export var amplitud := 5.0        
@export var duracion := 1.1 

@onready var no_seleccionado: TextureRect = %no_seleccionado
@onready var seleccionado: TextureRect = %seleccionado
@onready var panel: Control = $panel
@onready var estrellas : Array[Estrellas] = [ %estrellas1,%estrellas2,%estrellas3 ]
@onready var indice_nivel_area: Label = %indice_isla
@onready var bloqueado: TextureRect = %bloqueado


var base_y := 0.0
var tween: Tween


func _ready() -> void:
	indice_nivel_area.text = str(indice_nivel)
	
func inicializar(posicion : Vector2, desbloqueada : bool, estrellas_conseguidas : int = 0 ) -> void:
	base_y = panel.position.y
	self.global_position = posicion
	set_estrellas(estrellas_conseguidas)
	set_estado_nivel(desbloqueada)
	
func set_actual() -> void:
	no_seleccionado.hide()
	seleccionado.show()
	bloqueado.hide()
	iniciar_animacion()

func set_estado_nivel( desbloqueada : bool) -> void:
	if desbloqueada:
		set_desbloqueado()
	else:
		set_bloqueado()
		
func set_desbloqueado(era_actual : bool = false) -> void:
	no_seleccionado.show()
	seleccionado.hide()
	bloqueado.hide()
	indice_nivel_area.show()
	for estrella in estrellas:
		estrella.show()
	if era_actual:
		finalizar_animacion()
		
func set_bloqueado() -> void:
	no_seleccionado.hide()
	seleccionado.hide()
	bloqueado.show()
	indice_nivel_area.hide()
	for estrella in estrellas:
		estrella.hide()
	
func set_estrellas(estrellas_conseguidas : int ) -> void:
	for i in estrellas.size():
		var conseguida = true if (i + 1) <= estrellas_conseguidas else false 
		estrellas[i].inicializar(conseguida)

func iniciar_animacion() -> void:
	_matar_tween()
	panel.position.y = base_y

	tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(panel, "position:y", base_y - amplitud, duracion)
	tween.tween_property(panel, "position:y", base_y, duracion)

func finalizar_animacion(suave := true) -> void:
	_matar_tween()
	if suave:
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(panel, "position:y", base_y, 0.25)
	else:
		panel.position.y = base_y


func _matar_tween() -> void:
	if tween != null and tween.is_valid():
		tween.kill()
	tween = null

func set_logros(logros: Array[bool]) -> void:
	for i in estrellas.size():
		estrellas[i].inicializar(logros[i] if i < logros.size() else false)
