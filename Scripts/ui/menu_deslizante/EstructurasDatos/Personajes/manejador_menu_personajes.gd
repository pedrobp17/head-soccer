extends Control
class_name ManejadorMenuPersonajes

enum Interactuables {SUPERIOR, PERSONAJES, PODERES, BOTON}

const ANIMACION_TIEMPO := 0.3
const OFFSET_ANIMACION_MARCO_OBJETOS := 345
const POSICION_INICIAL_MARCO_OBJETOS := 2

@onready var selector_personajes: MenuDeslizanteSeleccionPersonajes = $SelectorPersonajes
@onready var estadisticas_personaje_seleccionado: EstadisticasPersonajeSeleccionado = %EstadisticasPersonajeSeleccionado
@onready var boton: BotonSeleccionPersonaje = %Boton
@onready var marco_objetos_personajes: TextureRect = %MarcoObjetosPersonajes
@onready var marco_objetos_estadisticas: TextureRect = %MarcoObjetosEstadisticas

var estado_actual := Interactuables.SUPERIOR
var tween_entrada: Tween = null
var generacion_animacion_entrada: int = 0

func cambiar_estado_foco(foco: bool) -> void:
	estado_actual = Interactuables.BOTON if foco else Interactuables.SUPERIOR
	boton.cambiar_estado_foco(foco)
	
func puedo_subir_menu_principal() -> bool:
	return estado_actual == Interactuables.BOTON


func _input(event):
	#TRANSICION: boton -> personajes
	if event.is_action_pressed("ui_left") and estado_actual == Interactuables.BOTON:
		estado_actual = Interactuables.PERSONAJES
		boton.cambiar_estado_foco(false)
		selector_personajes.cambiar_estado_foco(true)
		return
	
	#TRANSICION: personajes ->  boton 
	if event.is_action_pressed("ui_right") and estado_actual == Interactuables.PERSONAJES:
		estado_actual = Interactuables.BOTON
		selector_personajes.cambiar_estado_foco(false)
		boton.cambiar_estado_foco(true)
		return
			
	#TRANSICION: boton -> poderes
	if event.is_action_pressed("ui_right") and estado_actual == Interactuables.BOTON:
		estado_actual = Interactuables.PODERES
		boton.cambiar_estado_foco(false)
		estadisticas_personaje_seleccionado.cambiar_estado_foco(true)
		return
	
	#TRANSICION: personajes ->  boton 
	if event.is_action_pressed("ui_left") and estado_actual == Interactuables.PODERES:
		estado_actual = Interactuables.BOTON
		estadisticas_personaje_seleccionado.cambiar_estado_foco(false)
		boton.cambiar_estado_foco(true)
		return
	
func set_item_central(indice: int) -> void:
	selector_personajes.set_elemento_central(indice)

func preparar_animacion() -> void:
	selector_personajes.preparar_animacion()
	boton.preparar_animacion()
	estadisticas_personaje_seleccionado.preparar_animacion()

func animar() -> void:
	generacion_animacion_entrada += 1
	var generacion_actual := generacion_animacion_entrada
	tween_entrada = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE).set_parallel()
	tween_entrada.tween_property(marco_objetos_personajes, "global_position:x", POSICION_INICIAL_MARCO_OBJETOS, ANIMACION_TIEMPO)
	tween_entrada.tween_property(marco_objetos_estadisticas, "global_position:x", POSICION_INICIAL_MARCO_OBJETOS, ANIMACION_TIEMPO)

	while tween_entrada != null and tween_entrada.is_valid() and tween_entrada.is_running():
		await get_tree().process_frame
		if generacion_actual != generacion_animacion_entrada:
			return

	tween_entrada = null
	await selector_personajes.animar()
	if generacion_actual != generacion_animacion_entrada:
		return

	var tween_boton := boton.animar()
	var tween_estadisticas := estadisticas_personaje_seleccionado.animar()

	# Los dos tweens se ejecutan en paralelo. Se sondea su estado en vez de
	# esperar `finished`, porque reposicionar() puede cancelarlos con kill().
	while (
		(tween_boton.is_valid() and tween_boton.is_running())
		or (tween_estadisticas.is_valid() and tween_estadisticas.is_running())
	):
		await get_tree().process_frame
		if generacion_actual != generacion_animacion_entrada:
			return

func reposicionar() -> void:
	generacion_animacion_entrada += 1
	if tween_entrada != null and tween_entrada.is_valid():
		tween_entrada.kill()
	tween_entrada = null
	selector_personajes.reposicionar()
	var posicion_marco_objetos := POSICION_INICIAL_MARCO_OBJETOS + OFFSET_ANIMACION_MARCO_OBJETOS
	marco_objetos_estadisticas.global_position.x = posicion_marco_objetos
	marco_objetos_personajes.global_position.x = - posicion_marco_objetos
	boton.reposicionar()
	estadisticas_personaje_seleccionado.reposicionar()
