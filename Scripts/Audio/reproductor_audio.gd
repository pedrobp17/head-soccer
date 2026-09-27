extends Node

enum Sonidos {DAÑO, DISPARO, PODER, UI_NAV, UI_SELECT,UI_SELECT_ERROR, SILBATO}

const NUM_CANALES := 4

const mapa_sonidos : Dictionary[Sonidos, AudioStream] = {
	Sonidos.DAÑO : preload("res://Sonidos/hurt.wav"),
	Sonidos.PODER : preload("res://Sonidos/power-shot.wav"),
	Sonidos.DISPARO :preload("res://Sonidos/shoot.wav"),
	Sonidos.UI_NAV :preload("res://Sonidos/ui-navigate.wav"),
	Sonidos.UI_SELECT :preload("res://Sonidos/ui-select.wav"),
	Sonidos.SILBATO :preload("res://Sonidos/whistle.wav")
}

var canal_audio : Array[AudioStreamPlayer] = []

func _ready() -> void:
	for i in NUM_CANALES:
		var reproductor := AudioStreamPlayer.new()
		canal_audio.append(reproductor)
		add_child(reproductor)
		
func play(sonido : Sonidos) -> void:
	var reproductor = encontrar_primer_reproductor_disponible()
	if reproductor != null:
		reproductor.stream = mapa_sonidos[sonido]
		reproductor.play()
		
func encontrar_primer_reproductor_disponible() -> AudioStreamPlayer:
	for reproductor in canal_audio:
		if not reproductor.playing:
			return reproductor 
	return null
