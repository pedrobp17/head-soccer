class_name ConfiguracionIA
extends Resource

enum Dificultad {DIFICIL, EXTREMA}

@export var dificultad: Dificultad = Dificultad.DIFICIL
@export_range(0.02, 1.0) var reaccion: float = 0.16
@export_range(0.2, 2.0) var horizonte: float = 0.95
@export_range(0.0, 60.0) var error_posicion: float = 18.0
@export_range(1.0, 40.0) var tolerancia: float = 12.0
@export_range(0.3, 1.0) var pausa_patada: float = 0.45

static func crear(nivel: Dificultad) -> ConfiguracionIA:
	var configuracion := ConfiguracionIA.new()
	configuracion.dificultad = nivel
	if nivel == Dificultad.EXTREMA:
		configuracion.reaccion = 0.05
		configuracion.horizonte = 1.5
		configuracion.error_posicion = 2.0
		configuracion.tolerancia = 3.0
		configuracion.pausa_patada = 0.31
	return configuracion
