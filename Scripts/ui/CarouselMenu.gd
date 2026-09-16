
extends Control

@export var duracion_animacion: float = 0.5
@export var escala_inicial: float = 0.75
@export var reduccion_escala: float = 0.15
@export var escala_minima: float = 0.1

@onready var contenedor_posiciones: Control = %Placeholders
@onready var contenedor_elementos: Control = %Items
@onready var contenedor_ubicaciones: Control = %Placements

var indice_actual: int = 0
var animacion_activa: Tween
var esta_animando: bool = false


func _ready() -> void:
	contenedor_posiciones.hide()
	contenedor_elementos.hide()
	
	_asegurar_elementos_minimos()
	_configurar_identificadores()
	inicializar_posiciones()


func _input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_left"):
		ir_izquierda()
	elif evento.is_action_pressed("ui_right"):
		ir_derecha()
	elif evento.is_action_pressed("ui_accept"):
		confirmar_seleccion()


func confirmar_seleccion() -> void:
	if esta_animando:
		return
	
	var total_elementos: int = contenedor_elementos.get_child_count()
	var indice_modo_seleccionado: int = posmod(indice_actual, total_elementos)
	
	print("Modo de juego seleccionado: ", indice_modo_seleccionado)
	
	# get_tree().change_scene_to_file(
	# 	"res://escenas/modo_" + str(indice_modo_seleccionado) + ".tscn"
	# )


func inicializar_posiciones() -> void:
	var posiciones_anteriores: Array[Node] = contenedor_ubicaciones.get_children()
	var posiciones_nuevas: Array[ElementoMenuCarrusel] = []
	
	var total_elementos: int = contenedor_elementos.get_child_count()
	var total_posiciones: int = contenedor_posiciones.get_child_count()
	var casilla_central: int = int(total_posiciones / 2.0)
	
	var elemento_activo: ElementoMenuCarrusel = null
	
	for indice_casilla in range(total_posiciones):
		var desplazamiento: int = indice_casilla - casilla_central
		var indice_elemento: int = posmod(
			indice_actual + desplazamiento,
			total_elementos
		)
		
		var elemento_origen: ElementoMenuCarrusel = contenedor_elementos.get_child(indice_elemento)
		var clon_elemento: ElementoMenuCarrusel = elemento_origen.duplicate()
		var posicion_objetivo: ElementoMenuCarrusel = contenedor_posiciones.get_child(indice_casilla)
		var escala_objetivo: float = obtener_escala_por_distancia(
			indice_casilla,
			casilla_central
		)
		clon_elemento.scale = Vector2.ONE * escala_objetivo
		
		if indice_casilla == casilla_central:
			elemento_activo = clon_elemento
		
		contenedor_ubicaciones.add_child(clon_elemento)
		posiciones_nuevas.append(clon_elemento)
		
		_copiar_transformacion_diseno(
			clon_elemento,
			posicion_objetivo
		)
	
	if elemento_activo:
		elemento_activo.establecer_es_actual(true)
	
	for nodo in posiciones_anteriores:
		nodo.queue_free()
	
	_actualizar_visibilidad_elementos(
		posiciones_nuevas,
		casilla_central
	)


func ir_izquierda() -> void:
	if esta_animando:
		return
	
	var total_elementos: int = contenedor_elementos.get_child_count()
	indice_actual = posmod(indice_actual - 1, total_elementos)
	animar_elementos(indice_actual)


func ir_derecha() -> void:
	if esta_animando:
		return
	
	var total_elementos: int = contenedor_elementos.get_child_count()
	indice_actual = posmod(indice_actual + 1, total_elementos)
	animar_elementos(indice_actual)


func animar_elementos(
	indice_objetivo: int = indice_actual,
	duracion: float = duracion_animacion,
	es_inverso: bool = false
) -> void:
	inicializar_posiciones()
	esta_animando = true
	
	var total_posiciones: int = contenedor_posiciones.get_child_count()
	var casilla_central: int = int(total_posiciones / 2.0)
	var total_elementos: int = contenedor_elementos.get_child_count()
	
	var indices_posiciones: Array = range(total_posiciones)
	var indices_elementos: Array = []
	
	for indice_casilla in range(total_posiciones):
		var desplazamiento: int = indice_casilla - casilla_central
		
		var indice_elemento_mapeado: int = posmod(
			indice_objetivo + desplazamiento,
			total_elementos
		)
		
		indices_elementos.append(indice_elemento_mapeado)
	
	var elementos_animados: Array[ElementoMenuCarrusel] = _animar_elementos_a_posiciones(
		indices_posiciones,
		indices_elementos,
		duracion,
		es_inverso
	)
	
	var animacion_desvanecimiento: Tween = get_tree().create_tween()
	
	for indice_casilla in range(elementos_animados.size()):
		var nodo_elemento: ElementoMenuCarrusel = elementos_animados[indice_casilla]
		
		var es_casilla_visible: bool = (
			indice_casilla >= casilla_central - 2
			and indice_casilla <= casilla_central + 2
		)
		
		var opacidad_objetivo: float = 1.0 if es_casilla_visible else 0.0
		
		animacion_desvanecimiento.parallel().tween_property(
			nodo_elemento,
			"modulate:a",
			opacidad_objetivo,
			duracion
		)
	
	await animacion_activa.finished
	esta_animando = false


func _animar_elementos_a_posiciones(
	indices_posiciones: Array,
	indices_elementos: Array,
	duracion: float,
	es_inverso: bool
) -> Array[ElementoMenuCarrusel]:
	var posiciones_anteriores: Array[Node] = contenedor_ubicaciones.get_children()
	var elementos_nuevos: Array[ElementoMenuCarrusel] = []
	
	var casilla_central: int = int(
		contenedor_posiciones.get_child_count() / 2.0
	)
	
	animacion_activa = get_tree().create_tween()
	
	var rastreador_uso_elementos: Dictionary = {}
	
	for i in range(indices_posiciones.size()):
		var indice_posicion: int = i
		var indice_elemento: int = indices_elementos[i]
		
		var posicion_objetivo: ElementoMenuCarrusel = (
			contenedor_posiciones.get_child(indice_posicion)
		)
		var escala_objetivo: float = obtener_escala_por_distancia(
			indice_posicion,
			casilla_central
		)
		
		if not rastreador_uso_elementos.has(indice_elemento):
			rastreador_uso_elementos[indice_elemento] = 0
		
		var plantilla_estatica: ElementoMenuCarrusel = (
			contenedor_elementos.get_child(indice_elemento)
		)
		
		var ocurrencia_uso: int = rastreador_uso_elementos[indice_elemento]
		
		var posicion_origen: ElementoMenuCarrusel = _buscar_posicion_por_elemento(
			plantilla_estatica,
			ocurrencia_uso,
			es_inverso
		)
		
		rastreador_uso_elementos[indice_elemento] += 1
		
		if posicion_origen == null:
			continue
		
		var clon_elemento: ElementoMenuCarrusel = posicion_origen.duplicate()
		
		clon_elemento.establecer_es_actual(false)
		
		contenedor_ubicaciones.add_child(clon_elemento)
		elementos_nuevos.append(clon_elemento)
		
		_copiar_transformacion_diseno(
			clon_elemento,
			posicion_origen
		)
		
		animacion_activa.parallel().tween_property(
			clon_elemento,
			"position",
			posicion_objetivo.position,
			duracion
		)
		
		animacion_activa.parallel().tween_property(
			clon_elemento,
			"anchor_left",
			posicion_objetivo.anchor_left,
			duracion
		)
		
		animacion_activa.parallel().tween_property(
			clon_elemento,
			"anchor_right",
			posicion_objetivo.anchor_right,
			duracion
		)
		
		animacion_activa.parallel().tween_property(
			clon_elemento,
			"anchor_top",
			posicion_objetivo.anchor_top,
			duracion
		)
		
		animacion_activa.parallel().tween_property(
			clon_elemento,
			"anchor_bottom",
			posicion_objetivo.anchor_bottom,
			duracion
		)
		
		animacion_activa.parallel().tween_property(
			clon_elemento,
			"offset_left",
			posicion_objetivo.offset_left,
			duracion
		)
		
		animacion_activa.parallel().tween_property(
			clon_elemento,
			"offset_right",
			posicion_objetivo.offset_right,
			duracion
		)
		
		animacion_activa.parallel().tween_property(
			clon_elemento,
			"offset_top",
			posicion_objetivo.offset_top,
			duracion
		)
		
		animacion_activa.parallel().tween_property(
			clon_elemento,
			"offset_bottom",
			posicion_objetivo.offset_bottom,
			duracion
		)
		
		animacion_activa.parallel().tween_property(
			clon_elemento,
			"z_index",
			posicion_objetivo.z_index,
			duracion
		)
		
		animacion_activa.parallel().tween_property(
			clon_elemento,
			"scale",
			Vector2.ONE * escala_objetivo,
			duracion
		)
		
	for nodo in posiciones_anteriores:
		nodo.queue_free()
	
	if elementos_nuevos.size() > casilla_central:
		elementos_nuevos[casilla_central].establecer_es_actual(true)
	
	return elementos_nuevos


func _buscar_posicion_por_elemento(
	elemento_objetivo: ElementoMenuCarrusel,
	ocurrencia_uso: int,
	es_inverso: bool
) -> ElementoMenuCarrusel:
	var posiciones_existentes: Array[Node] = (
		contenedor_ubicaciones.get_children()
	)
	
	if es_inverso:
		posiciones_existentes.reverse()
	
	var ocurrencia_actual: int = 0
	
	for nodo in posiciones_existentes:
		if (
			nodo is ElementoMenuCarrusel
			and nodo.identificador == elemento_objetivo.identificador
		):
			if ocurrencia_actual >= ocurrencia_uso:
				return nodo
			
			ocurrencia_actual += 1
	
	return null


func _copiar_transformacion_diseno(
	nodo_objetivo: ElementoMenuCarrusel,
	nodo_origen: ElementoMenuCarrusel
) -> void:
	nodo_objetivo.position = nodo_origen.position
	nodo_objetivo.anchor_left = nodo_origen.anchor_left
	nodo_objetivo.anchor_right = nodo_origen.anchor_right
	nodo_objetivo.anchor_top = nodo_origen.anchor_top
	nodo_objetivo.anchor_bottom = nodo_origen.anchor_bottom
	nodo_objetivo.offset_left = nodo_origen.offset_left
	nodo_objetivo.offset_right = nodo_origen.offset_right
	nodo_objetivo.offset_top = nodo_origen.offset_top
	nodo_objetivo.offset_bottom = nodo_origen.offset_bottom
	nodo_objetivo.z_index = nodo_origen.z_index


func _asegurar_elementos_minimos() -> void:
	var total_posiciones: int = contenedor_posiciones.get_child_count()
	var elementos_minimos_requeridos: int = total_posiciones + 1
	var cantidad_elementos_faltantes: int = (
		elementos_minimos_requeridos
		- contenedor_elementos.get_child_count()
	)
	
	if cantidad_elementos_faltantes > 0:
		var conteo_inicial: int = contenedor_elementos.get_child_count()
		
		for i in range(cantidad_elementos_faltantes):
			var indice_origen: int = i % conteo_inicial
			var nodo_origen: Node = contenedor_elementos.get_child(indice_origen)
			
			contenedor_elementos.add_child(
				nodo_origen.duplicate()
			)


func _configurar_identificadores() -> void:
	for i in range(contenedor_elementos.get_child_count()):
		var nodo_elemento: ElementoMenuCarrusel = (
			contenedor_elementos.get_child(i)
		)
		
		nodo_elemento.identificador = i
		nodo_elemento.duracion_animacion = duracion_animacion

func obtener_escala_por_distancia(indice_placeholder: int, centro: int) -> float:
	var distancia: int = abs(indice_placeholder - centro)
	
	return max(
		escala_inicial - distancia * reduccion_escala,
		escala_minima
	)
	
	
func _actualizar_visibilidad_elementos(
	lista_elementos: Array,
	casilla_central: int
) -> void:
	for i in range(lista_elementos.size()):
		var nodo_elemento: ElementoMenuCarrusel = lista_elementos[i]
		
		if i >= casilla_central - 2 and i <= casilla_central + 2:
			nodo_elemento.modulate.a = 1.0
		else:
			nodo_elemento.modulate.a = 0.0
