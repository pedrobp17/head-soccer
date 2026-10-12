extends Control
class_name CartaPoderesLogro

@onready var bloqueado: Control = %bloqueado
@onready var desbloqueado: Control = %desbloqueado
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var nombre: Label = %nombre
@onready var descripcion: Label = %descripcion
@onready var imagen: TextureRect = %imagen

func inicializar( jugador : String , nombre_poder : String, indice : int) -> void:
	var desbloqueado = ProgresoPartida.personajes_desbloqueados.get_poder_desbloqueado(jugador, indice)
	if desbloqueado:
		nombre.text = nombre_poder
		mostrar_desbloqueado()
	else:
		descripcion.text = ProgresoPartida.personajes_desbloqueados.get_descripcion_poder(jugador, indice)
		mostrar_bloqueado()
	imagen.texture = PoderesHelper.get_icono( jugador, DatosJugadores.get_jugador(jugador).poderes)[indice - 1]
	

func mostrar_bloqueado() -> void:
	bloqueado.show()
	desbloqueado.hide()

func mostrar_desbloqueado() ->void:
	bloqueado.hide()
	desbloqueado.show()
