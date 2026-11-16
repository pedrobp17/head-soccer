# IA del rival

Durante la presentación del partido, selecciona **Difícil** o **Extrema** en la esquina superior izquierda y comienza con espacio como antes. La elección se conserva durante la sesión. VERSUS mantiene los dos mandos humanos.

## Qué cambia entre dificultades

| Parámetro | Difícil | Extrema |
|---|---:|---:|
| Intervalo entre decisiones | 160 ms | 50 ms |
| Horizonte de predicción | 0.95 s | 1.5 s |
| Error horizontal por decisión | ±18 px | ±2 px |
| Tolerancia al llegar al destino | 12 px | 3 px |
| Pausa mínima entre patadas | 450 ms | 310 ms |
| Patadas deliberadas al rival cercano | No | Sí |

Los perfiles están en `Scripts/jugador/IA/configuracion_ia.gd`. Para ajustar dificultad, empieza por reacción y error. Una reacción menor permite responder antes a cambios de trayectoria. Un error mayor vuelve menos precisa la colocación. Aumentar el horizonte permite encontrar intercepciones más lejanas, pero también aumenta el trabajo de predicción y la incertidumbre.

## Decisión y ejecución

`ComportamientoIA` decide una posición horizontal y pulsos de salto y patada. Los estados existentes ejecutan esas órdenes con la misma gravedad, velocidad, salto, colisiones y daño que los personajes humanos. No se sustituyen sus máquinas de estados ni se multiplican sus estadísticas.

`PredictorPelotaIA` usa la forma física real de la pelota para consultar rebotes contra el escenario sin moverla. Reproduce el paso de integración de `Pelota`: gravedad, amortiguación del aire, velocidad máxima y rebotes. Excluye a ambos personajes porque sus movimientos y golpes futuros son desconocidos. No usa rayos ni áreas adicionales.

De las posiciones futuras, la IA busca una que pueda alcanzar con sus estadísticas actuales. Se coloca del lado de su propia portería para golpear hacia la contraria. Calcula si necesita saltar y cuándo. Si no encuentra una intercepción y la trayectoria amenaza su portería, retrocede para cubrirla. Intenta saltar sobre una pelota baja a su espalda y sobre un rival que bloquee su avance.

La predicción se recalcula a intervalos, mientras la física y la ejecución del movimiento continúan cada paso físico. Así, ralentizar sus decisiones no ralentiza la gravedad ni el desplazamiento.

## Límites y validación

La IA no usa poderes: sus implementaciones actuales están vacías y el estado de poder tiene problemas previos. No se han inventado efectos nuevos para resolverlos.

Los radios de alcance y los márgenes son aproximaciones de juego. La planificación del salto no simula todo el cuerpo contra el escenario; un rival, un larguero o un golpe pueden frustrar la maniobra. El alcance depende del personaje elegido. Los márgenes de movimiento respecto a las porterías están calibrados para el campo actual.

Validación realizada con Godot 4.7.1 en una copia aislada sin escrituras al progreso: 20 segundos simulados por perfil en la escena real, movimiento/salto/patada, goles y reposición, selector de dificultad, ausencia de órdenes con el partido parado y conservación de P1/P2 en VERSUS. La predicción se comparó contra 60 pasos físicos reales con rebote, con error inferior a 1 px. Las comprobaciones de IA pasaron. La carga también informa de dos texturas de indicadores de islas que ya faltaban y de recursos pendientes al cerrar.

Falta calibración jugando contra una persona: estas comprobaciones verifican funcionamiento, no garantizan una tasa de victorias ni que Extrema sea invencible.
