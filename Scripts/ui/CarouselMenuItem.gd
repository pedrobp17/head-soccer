extends PanelContainer
class_name CarouselMenuItem

@export var identifier = 0
@export var animation_duration = 0.5
@export var modo_juego : String
@export var textura_modo_juego : Texture2D

var is_current = false

@onready var nBackground_NotCurrent = $Background/NotCurrent
@onready var nBackground_Current = $Background/Current
@onready var nCurrentLayer = $CurrentLayer
@onready var nombre = %Label
@onready var texture_rect : TextureRect = %TextureRect

func _ready() -> void:
	set_is_current(is_current)
	nombre.text = modo_juego
	if textura_modo_juego and texture_rect:
		texture_rect.texture = textura_modo_juego
		
func set_is_current(p_is_current: bool) -> void:
	is_current = p_is_current
	
	if not is_visible_in_tree():
		return
	
	var tween = get_tree().create_tween()
	
	tween.parallel().tween_property(nBackground_NotCurrent, "modulate:a", int(not p_is_current), animation_duration * 2)
	tween.parallel().tween_property(nBackground_Current, "modulate:a", int(p_is_current), animation_duration * 2)
	tween.parallel().tween_property(nCurrentLayer, "modulate:a", int(p_is_current), animation_duration * 2)
