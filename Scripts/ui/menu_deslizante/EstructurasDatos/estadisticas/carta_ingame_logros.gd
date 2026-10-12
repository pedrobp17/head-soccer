extends Control
class_name CartaIngameLogro

@onready var bloqueado: Control = %bloqueado
@onready var descripcion: Label = %descripcion
@onready var desbloqueado: Control = %desbloqueado
@onready var imagen: TextureRect = %imagen
@onready var equipo: TextureRect = %equipo

func inicializar(jugador : String) ->void:
	if ProgresoPartida.personajes_desbloqueados.get_desbloqueado(jugador) :
		imagen.texture = CabezasHelper.get_cabeza(jugador)
		equipo.texture = BanderasHelper.get_sprite(DatosJugadores.get_jugador(jugador).equipo)
		mostrar_desbloqueado()
	else:
		descripcion.text = ProgresoPartida.personajes_desbloqueados.get_descripcion(jugador)
		mostrar_bloqueado()

func mostrar_bloqueado() -> void:
	bloqueado.show()
	desbloqueado.hide()

func mostrar_desbloqueado() ->void:
	bloqueado.hide()
	desbloqueado.show()
