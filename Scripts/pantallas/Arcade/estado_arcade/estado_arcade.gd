extends Node
class_name EstadoArcade

signal peticion_transmision_estado( nuevo_estado : PantallaArcade.Estado )

var arcade : PantallaArcade = null

## false mientras la animación de entrada del estado está en curso.
## El input está bloqueado hasta que mostrar_escena() termina de verdad.
var escena_lista : bool = false

func setup( _arcade : PantallaArcade ) -> void:
	arcade = _arcade

func cambiar_estado( nuevo_estado : PantallaArcade.Estado ) -> void:
	peticion_transmision_estado.emit(nuevo_estado)

func mostrar_escena() -> void:
	pass

## Gancho para los estados concretos. Solo se llama si la escena ya está lista.
func procesar_input( _event : InputEvent ) -> void:
	pass

## Único punto de entrada del input del estado.
## Mientras escena_lista sea false (animación de entrada en curso) o la pantalla
## esté transicionando, se descarta TODO el input: flechas, ui_accept y p1_back.
func _input( event : InputEvent ) -> void:
	if not escena_lista:
		_diagnostico_bloqueo(event, "animacion de entrada en curso")
		return
	if arcade != null and arcade.juego != null and arcade.juego.transicionando:
		_diagnostico_bloqueo(event, "pantalla transicionando")
		return
	procesar_input(event)

## Solo para pruebas: imprime qué tecla se descarta y por qué motivo.
func _diagnostico_bloqueo( event : InputEvent, motivo : String ) -> void:
	var tecla := event as InputEventKey
	if tecla != null and tecla.pressed and not tecla.echo:
		print("[arcade] input descartado (", motivo, "): ", OS.get_keycode_string(tecla.keycode))

func _enter_tree() -> void:
	# El análisis estático resuelve mostrar_escena() contra ESTA clase (que es `pass`,
	# no corrutina) y avisa de "redundant_await". En runtime la llamada se despacha a la
	# subclase, que SÍ es corrutina: el await es imprescindible para no abrir el candado
	# antes de que la animación termine.
	@warning_ignore("redundant_await")
	await mostrar_escena()
	escena_lista = true
	print("[arcade] animacion terminada -> input desbloqueado (", name, ")")
