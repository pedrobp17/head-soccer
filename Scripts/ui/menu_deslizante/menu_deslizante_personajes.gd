extends MenuDeslizante
class_name MenuDeslizanteSeleccionPersonajes

const TIEMPO_PASO_ENTRADA := 0.12

@export var modes : Array[DatosSeleccionPersonajes]

var indice_carta_seleccionada := -1
var tween_entrada: Tween = null
var generacion_animacion_entrada: int = 0

func _ready():
	card_scene = preload("res://Escenas/ui/Cartas/CartasSeleccionPersonaje.tscn")

	use_scaling = false
	use_fade = false
	use_rotation = false
	
	super()

	set_items(modes)
	set_elemento_central(ProgresoPartida.progreso_general.get_indice_jugador_seleccionado())
	EventBus.item_selected_personajes.connect(_al_confirmar_personaje)

func get_center_slot() -> int:
	return visible_slots / 2


func configure_card(card: Control, data: Variant, is_selected: bool, animar_seleccion: bool = false) -> void:
	
	var es_el_personaje_elegido = (items.find(data) == indice_carta_seleccionada)
	
	card.set_mode(
		data,
		is_selected,
		animar_seleccion,
		es_el_personaje_elegido
	)


func preparar_animacion() -> void:
	if cards.size() < 3 or placeholders.size() != cards.size():
		return

	var primer_slot_visible := 1
	var ultimo_slot_visible := placeholders.size() - 2
	var placeholder_origen := placeholders[0]

	# Los slots extremos son orientativos. Las cartas interiores parten
	# superpuestas en el placeholder izquierdo y terminan en los slots 1..5.
	for slot in range(primer_slot_visible, ultimo_slot_visible + 1):
		_apply_placeholder(cards[slot], placeholder_origen)


func animar() -> void:
	if animating or cards.size() < 3 or placeholders.size() != cards.size():
		return

	animating = true
	generacion_animacion_entrada += 1
	var generacion_actual := generacion_animacion_entrada

	var primer_slot_visible := 1
	var ultimo_slot_visible := placeholders.size() - 2
	var cantidad_cartas_visibles := ultimo_slot_visible - primer_slot_visible + 1

	# Cada iteracion desplaza simultaneamente una diagonal de cartas:
	# 0: carta 0, 0 -> 1
	# 1: carta 0, 1 -> 2 y carta 1, 0 -> 1
	for i in range(cantidad_cartas_visibles):
		tween_entrada = create_tween()
		tween_entrada.set_parallel(true)
		tween_entrada.set_trans(Tween.TRANS_LINEAR)

		for j in range(i + 1):
			var indice_carta := ultimo_slot_visible - j
			var indice_destino := i - j + 1

			tween_entrada.tween_property(
				cards[indice_carta],
				"global_position",
				placeholders[indice_destino].global_position,
				TIEMPO_PASO_ENTRADA
			)

		while tween_entrada != null and tween_entrada.is_valid() and tween_entrada.is_running():
			await get_tree().process_frame
			if generacion_actual != generacion_animacion_entrada:
				return

	tween_entrada = null
	animating = false


func reposicionar() -> void:
	generacion_animacion_entrada += 1
	if tween_entrada != null and tween_entrada.is_valid():
		tween_entrada.kill()
	tween_entrada = null
	animating = false
	refresh()
	

func _al_confirmar_personaje() -> void:
	if items.is_empty() or animating:
		return
		
	var nuevo_indice = get_current_item().indice
	
	if nuevo_indice != -1:
		indice_carta_seleccionada = nuevo_indice
		refresh() 
	
