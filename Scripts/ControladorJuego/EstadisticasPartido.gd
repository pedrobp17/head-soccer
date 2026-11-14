extends RefCounted
class_name EstadisticasPartido

var tipos_goles: Dictionary = {
    LogrosArcadeHelper.Ids.GOL_CABEZAZO: 0,
    LogrosArcadeHelper.Ids.GOL_PATADA: 0,
    LogrosArcadeHelper.Ids.PODER: 0,
}
var mayor_diferencia_perdiendo_local: int = 0
var primer_gol_jugador_local: bool = false
# Momento mas tardio en que marco el local, en segundos de juego transcurridos.
var ultimo_gol_local_transcurrido: float = 0.0
# Tiempo restante cuando comenzo la ventaja continua actual; 0 si no existe.
var inicio_ventaja_local: float = 0.0
