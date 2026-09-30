extends Control
class_name MenuDeslizante

@export_group("Carousel")
@export var visible_slots: int = 7
@export var circular: bool = true
@export var animation_time: float = 0.22
@export var transition: Tween.TransitionType = Tween.TRANS_SINE
@export var ease: Tween.EaseType = Tween.EASE_OUT

@export_group("Input")
@export var left : String = "ui_left"
@export var right : String = "ui_right"
@export var accept : String = "ui_accept"

@export_group("Animación")
@export var use_scaling: bool = true
@export var use_fade: bool = true
@export var use_rotation: bool = false
@export var use_depth: bool = true

@export_group("Tarjetas")
@export var card_scene: PackedScene

signal item_changed(index: int, data: Variant)
signal item_selected(index: int, data: Variant)
signal animation_finished(index: int)

@onready var placeholder_container: Control = $PlaceholderContainer
@onready var card_container: Control = $CardContainer

var items: Array = []
var placeholders: Array[Control] = []
var cards: Array[Control] = []

var current_index: int = 0
var animating: bool = false
var is_foco: bool = false


func _ready() -> void:
	placeholders.clear()

	var container: Control = placeholder_container

	if container == null and has_node("%Placeholders"):
		container = get_node("%Placeholders") as Control

	if container != null:
		for child in container.get_children():
			if child is Control:
				placeholders.append(child as Control)

	assert(placeholders.size() == visible_slots, "El número de placeholders debe coincidir con visible_slots")

	await get_tree().process_frame

	_create_card_pool()
	refresh()


func get_center_slot() -> int:
	return visible_slots / 2


func _input(event: InputEvent) -> void:
	if not is_foco:
		return

	if event.is_action_pressed(right):
		move_right()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(left):
		move_left()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(accept):
		select_current()
		get_viewport().set_input_as_handled()


func set_items(new_items: Array) -> void:
	items = new_items
	current_index = 0

	if not is_node_ready():
		await ready

	await get_tree().process_frame
	refresh()


func cambiar_estado_foco(tiene_foco: bool) -> void:
	if is_foco == tiene_foco:
		return

	is_foco = tiene_foco
	refresh()


func move_right() -> void:
	if !is_foco or animating or items.is_empty():
		return

	var old_idx := current_index
	current_index = _wrap(current_index + 1)
	_animate(old_idx)


func move_left() -> void:
	if !is_foco or animating or items.is_empty():
		return

	var old_idx := current_index
	current_index = _wrap(current_index - 1)
	_animate(old_idx)


func go_to(index: int) -> void:
	if !is_foco or animating or items.is_empty():
		return

	var old_idx := current_index
	current_index = _wrap(index)
	_animate(old_idx)


func select_current() -> void:
	if !is_foco or animating or items.is_empty():
		return

	item_selected.emit(current_index, items[current_index])


func _create_card_pool() -> void:
	var container: Control = card_container

	if container == null and has_node("%Items"):
		container = get_node("%Items") as Control

	if container != null:
		for child in container.get_children():
			child.queue_free()

	cards.clear()

	if card_scene == null or container == null:
		return

	for i in range(visible_slots):
		var card := card_scene.instantiate() as Control
		container.add_child(card)
		cards.append(card)


func refresh() -> void:
	if items.is_empty() or placeholders.is_empty() or cards.size() != visible_slots:
		return

	var center := get_center_slot()

	for slot in range(visible_slots):
		var item_index := _wrap(current_index + slot - center)
		var is_current := slot == center and is_foco

		var card := cards[slot]
		var ph := placeholders[slot]

		configure_card(card, items[item_index], is_current, false)
		_apply_placeholder(card, ph)

	item_changed.emit(current_index, items[current_index])


func _animate(old_index: int) -> void:
	if items.is_empty() or placeholders.is_empty() or card_scene == null:
		return

	animating = true

	var center := get_center_slot()
	var delta := current_index - old_index

	if circular and items.size() > 0:
		var total := items.size()

		if delta > total / 2:
			delta -= total
		elif delta < -total / 2:
			delta += total

	var container: Control = card_container

	if container == null and has_node("%Items"):
		container = get_node("%Items") as Control

	var old_cards := cards.duplicate()
	cards.clear()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(transition)
	tween.set_ease(ease)

	var old_cards_to_free: Array[Control] = []

	for s in range(old_cards.size()):
		var old_card := old_cards[s] as Control

		if not is_instance_valid(old_card):
			continue

		var dest_slot := s - delta

		if dest_slot < 0 or dest_slot >= visible_slots:
			old_cards_to_free.append(old_card)

			if use_fade:
				tween.parallel().tween_property(
					old_card,
					"modulate:a",
					0.0,
					animation_time
				)

			var edge_ph := placeholders[0] if dest_slot < 0 else placeholders[visible_slots - 1]

			tween.parallel().tween_property(
				old_card,
				"global_position",
				edge_ph.global_position,
				animation_time
			)
		else:
			old_card.queue_free()

	for slot in range(visible_slots):
		var item_index := _wrap(current_index + slot - center)
		var is_current := slot == center and is_foco

		var card := card_scene.instantiate() as Control
		container.add_child(card)
		cards.append(card)

		configure_card(card, items[item_index], is_current, false)

		var source_slot := slot + delta
		var target_ph := placeholders[slot]

		if source_slot >= 0 and source_slot < visible_slots:
			var source_ph := placeholders[source_slot]
			_apply_placeholder(card, source_ph)
		else:
			var edge_slot := visible_slots - 1 if delta > 0 else 0
			var edge_ph := placeholders[edge_slot]
			_apply_placeholder(card, edge_ph)

		if use_fade:
			card.modulate.a = 0.0

		_animar_tarjeta_a_placeholder(tween, card, target_ph)

	await tween.finished

	for old_card in old_cards_to_free:
		if is_instance_valid(old_card):
			old_card.queue_free()

	animating = false

	item_changed.emit(current_index, items[current_index])
	animation_finished.emit(current_index)


func _apply_placeholder(card: Control, ph: Control) -> void:
	card.pivot_offset = ph.pivot_offset
	card.global_position = ph.global_position

	if use_scaling:
		card.scale = ph.scale
	else:
		card.scale = Vector2.ONE

	if use_rotation:
		card.rotation = ph.rotation
	else:
		card.rotation = 0.0

	if use_fade:
		card.modulate.a = ph.modulate.a
	else:
		card.modulate.a = 1.0

	if use_depth:
		card.z_index = ph.z_index


func _animar_tarjeta_a_placeholder(tween: Tween, card: Control, ph: Control) -> void:
	tween.parallel().tween_property(
		card,
		"pivot_offset",
		ph.pivot_offset,
		animation_time
	)

	tween.parallel().tween_property(
		card,
		"global_position",
		ph.global_position,
		animation_time
	)

	if use_scaling:
		tween.parallel().tween_property(
			card,
			"scale",
			ph.scale,
			animation_time
		)
	else:
		tween.parallel().tween_property(
			card,
			"scale",
			Vector2.ONE,
			animation_time
		)

	if use_rotation:
		tween.parallel().tween_property(
			card,
			"rotation",
			ph.rotation,
			animation_time
		)
	else:
		tween.parallel().tween_property(
			card,
			"rotation",
			0.0,
			animation_time
		)

	if use_fade:
		tween.parallel().tween_property(
			card,
			"modulate:a",
			ph.modulate.a,
			animation_time
		)
	else:
		tween.parallel().tween_property(
			card,
			"modulate:a",
			1.0,
			animation_time
		)

	if use_depth:
		card.z_index = ph.z_index


func _wrap(index: int) -> int:
	if items.is_empty():
		return 0

	return posmod(index, items.size())


func configure_card(
	card: Control,
	data: Variant,
	is_current: bool,
	animar_seleccion: bool = false
) -> void:
	if card.has_method("establecer_es_actual"):
		card.call(
			"establecer_es_actual",
			is_current,
			animar_seleccion
	)
