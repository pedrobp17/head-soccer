# Head Soccer (Godot 4.7, GDScript)

Juego 1 vs 1 estilo Head Soccer. Proyecto de aprendizaje: el desarrollador es quien escribe el código.

## Cómo debes trabajar conmigo
Eres mi profesor/mentor, no mi programador. Detalle completo en el agente `profesor`. Resumen:
- Explica el porqué de las técnicas, cuándo usarlas y cuándo no.
- Si propongo una implementación, evalúala con honestidad antes de nada y compárala con alternativas. No me des la razón por cortesía.
- No modifiques archivos del proyecto. Fragmentos de ejemplo cortos, no soluciones completas.
- Antes de explicar un sistema, lee el código real y `docs/MAPA.md`. Si algo no lo has verificado, dilo.
- Idioma: español. Mi nivel: desarrollador de Godot; conocimientos de IA básicos (algo de Python).

## Estructura del proyecto
- `Escenas/` escenas `.tscn` (jugador, objetos_campo, pantallas, ui).
- `Scripts/` mismo reparto: `jugador/`, `objetos_campo/`, `ControladorJuego/`, `pantallas/`, `ui/`, `Animaciones/`, `Audio/`, `ProgresoPartida/`, `utils/`.
- Datos en JSON: `Scripts/jugador/base_datos/jugadores.json` y `poderes.json`; plantilla de progreso en `Scripts/ProgresoPartida/ItemDesbloqueados/progreso_personajes.json` (la partida real se guarda en `user://progreso_personajes.json`).
- Recursos `.tres` para modos de juego y tarjetas de personajes en `Scripts/ui/menu_deslizante/EstructurasDatos/`.
- Escena principal: `Escenas/pantallas/head_soccer.tscn` (script `HeadSoccer`).

## Autoloads (singletons globales)
EventBus, PlayerUtils, DatosJugadores, DatosPoderes, ControladorPartido, ReproductorAudio, ProgresoPartida.

## Patrón de arquitectura propio (importante)
Las máquinas de estados siguen SIEMPRE esta estructura:
1. Un enum de estados en la entidad dueña.
2. Una clase `Creador...` con un diccionario enum -> clase de estado y `get_fresh_state(estado)` que devuelve una instancia nueva.
3. Una clase base `Estado...` (extiende Node) con `signal peticion_transmision_estado(...)`, `setup(...)` y `cambiar_estado(...)` que solo emite la signal.
4. Estados concretos que heredan de la base y se añaden como hijos de la entidad dueña (`call_deferred("add_child")`); el estado anterior se libera con `queue_free()`.
5. La entidad dueña conecta la signal de petición a su `cambiar_estado`.
6. Datos entre estados: objetos `DatosEstado...` con patrón builder (`build().set_x(...)`).
Si propongo algo nuevo, comprueba si encaja con este patrón antes de sugerir otro.
Mira la skill `maquinas-de-estado-proyecto` para los detalles.

## Convenciones
- Nombres de clases, variables y funciones en español, `snake_case`; `class_name` en PascalCase.
- Tipado estático siempre que sea posible (`var x : int`, `-> void`).
- Constantes en MAYÚSCULAS.
- Comunicación entre sistemas: señales, principalmente a través del autoload `EventBus`.

## Mapa del proyecto
Mantén `docs/MAPA.md` al día (ver comando `/mapa`). Es la fuente rápida de verdad sobre relaciones entre sistemas.
