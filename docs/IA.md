# IA del rival

Durante la presentación del partido elige **Competitiva** o **Experta**. La elección se mantiene durante la sesión; VERSUS conserva los dos mandos humanos. Internamente se mantienen los identificadores DIFICIL y EXTREMA para compatibilidad.

## Perfiles

| Parámetro | Competitiva | Experta |
|---|---:|---:|
| Retraso de percepción | 120 ms | 80 ms |
| Intervalo entre decisiones, variable | 130–250 ms | 90–170 ms |
| Horizonte estimado | 0.50 s | 0.65 s |
| Error horizontal máximo de lectura | ±30 px | ±16 px |
| Error relativo de velocidad por componente | ±16% | ±9% |
| Error temporal del cálculo de salto | ±60 ms | ±35 ms |
| Tolerancia al llegar | 20 px | 12 px |
| Pausa mínima entre patadas | 480 ms | 380 ms |

El retraso y el intervalo son distintos: un cambio de dirección debe llegar primero a la memoria visible y después a la siguiente decisión. Los intervalos se miden en tiempo de juego y se ejecutan en pasos físicos. No representan una medición del tiempo de reacción humano.

## Cómo percibe y decide

`ComportamientoIA._observar()` es el único punto que captura posiciones actuales de pelota y rival. Mantiene un historial breve y solo entrega observaciones anteriores al retraso configurado. Las decisiones y las patadas usan esa memoria; no leen `pelota.velocity`.

La velocidad se deduce de la diferencia entre posiciones observadas y se filtra para que no cambie instantáneamente tras un rebote. El error de posición, el de velocidad, el temporal y la gravedad estimada se conservan durante 0.65–1.05 segundos. La posición es más precisa a corta distancia. Esto permite una lectura equivocada que dura parte de una jugada, en lugar de ruido independiente en cada frame.

`PredictorPelotaIA.predecir()` recibe posición y velocidad percibidas y estima un vuelo parabólico corto. No consulta las colisiones del escenario, no reproduce su física exacta y no conoce por adelantado rebotes contra suelo, paredes, largueros ni jugadores. Después de un rebote o golpe, la lectura se corrige cuando llegan las nuevas observaciones. Una estimación puede atravesar el suelo: es una creencia equivocada, no un movimiento de la pelota real.

El planificador elige contactos que estima alcanzables y calcula el salto según las estadísticas propias, con error temporal. La patada también depende de la lectura atrasada. El movimiento sigue ejecutándose cada paso físico con la gravedad y estadísticas normales.

## Contención conservada

Sin peligro ni ventaja clara, espera entre el 20% y el 30% del campo desde su portería. Sale si la pelota percibida está cerca y estima llegar al menos 0.18 s antes que el rival. Evita perseguir más allá del 60% del campo salvo peligro. Mantiene inicialmente la disputa durante 0.65 s y reconsidera con histéresis para reducir cambios constantes.

El peligro interrumpe la espera una vez percibido; no concede acceso instantáneo a información actual. Experta solo intenta golpear al rival si la pelota percibida está cerca de ambos. Ambos perfiles conservan sus estadísticas, aturdimiento y reglas de colisión. Los poderes siguen pendientes porque sus implementaciones actuales están vacías.

## Presión ante pérdida de tiempo

Si va perdiendo y percibe al rival a menos de 140 px de un balón con velocidad de hasta 35 px/s durante 1.5 s seguidos, sale a disputarlo. Esta excepción permite superar el 60% del campo y acercarse aunque el rival llegue antes. Usa únicamente la memoria visual atrasada, manteniendo los errores y reflejos de cada dificultad.

Renueva la presión mientras continúa la retención y la conserva durante 1 s tras un toque breve para evitar retiradas constantes. El peligro defensivo mantiene prioridad. Empatar, ganar, perder al rival, dejar de poder actuar o reiniciar cancela el contador y la presión.

Parámetros en `ConfiguracionIA`: `demora_para_presionar`, `velocidad_balon_retenido`, `distancia_rival_balon_retenido` y `compromiso_presion`. Son valores iniciales para calibrar jugando.

Validación aislada en Godot 4.7.1: 56 comprobaciones con los scripts reales de IA y marcador y dobles de las entidades físicas. Incluye ambos bandos y dificultades, activación sostenida, avance fuera de la zona habitual, prioridad defensiva, persistencia tras un toque, caducidad y cancelación al empatar, ganar, reiniciar, perder al rival o parar el partido. No sustituye la evaluación en una partida real.

## Archivos y ajuste

- `configuracion_ia.gd`: parámetros de ambos perfiles.
- `comportamiento_ia.gd`: memoria visual, errores persistentes, táctica y órdenes.
- `predictor_pelota_ia.gd`: estimación aproximada sin acceso al escenario.
- `campo.gd`: nombres del selector. Los estados del jugador ejecutan las órdenes como antes.

Para aumentar los errores de lectura, ajusta `error_posicion` y `error_velocidad`. Para dar más oportunidades tras un golpe inesperado, aumenta `retraso_percepcion` o `reaccion`. Un horizonte mayor vuelve a aumentar su capacidad de anticipación. No es una IA entrenada ni adaptativa.

## Validación y límites

Comprobado en Godot 4.7.1 en copia aislada sin guardar progreso: ambos perfiles y bandos, ausencia de observaciones inmediatas, corrección tras el retraso, velocidad inferida independiente de la propiedad real, persistencia del error, historial acotado y limpieza de memoria al reiniciar. Se comprobó la estimación sin anticipación de rebotes y se ejecutaron 20 segundos de escena real por perfil, además del selector y bloqueo fuera de partido. Las comprobaciones de IA pasaron.

La copia de pruebas conserva avisos previos de recursos de islas y recursos pendientes al cerrar. Falta calibración contra una persona: las pruebas verifican la mecánica de percepción, no garantizan que la sensación resulte humana ni una dificultad concreta. La geometría de alcance y los saltos siguen usando aproximaciones.
