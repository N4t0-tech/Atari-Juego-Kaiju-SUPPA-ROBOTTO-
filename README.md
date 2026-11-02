# atari-juego

Recreación del juego **Kaiju** ("SUPPA ROBOTTO") para Atari de 8 bits, escrita desde cero en ensamblador 6502.
Las reglas del original se obtuvieron por ingeniería inversa de su binario (compilado con cc65). Los gráficos,
niveles, robots y la imagen de título son los del disco original, convertidos byte a byte.

Controlas al robot Kaiju a lo largo de 30 etapas (5 mundos de 6 mapas): recoge todas las células, esquiva o
destruye a los robots y no le dispares a las células.

## Requisitos

- [MADS](https://github.com/tebe6502/Mad-Assembler) 2.1.7 (Mad-Assembler)
- Un emulador de Atari 8-bit; el proyecto se prueba con [Altirra](https://www.virtualdub.org/altirra.html)

## Compilar y jugar

```sh
mads main.asm -o:juego.xex
altirra juego.xex
```

`juego.xex` no está en el repositorio (se genera al compilar).

### Versión de depuración

```sh
mads main.asm -d:DEBUG=1 -o:juego-debug.xex
```

En la pantalla de título aparece **START LEVEL m-n** para empezar en cualquier etapa:
con el joystick a la izquierda o a la derecha cambias de etapa de una en una; arriba o abajo, de mundo
(6 etapas).

### Windows

MADS y Altirra tienen versiones nativas para Windows, así que los comandos son los mismos:

1. Descarga `mads.exe` desde los [releases de Mad-Assembler](https://github.com/tebe6502/Mad-Assembler/releases)
   y déjalo en el `PATH` o en la carpeta del proyecto.
2. Desde `cmd` o PowerShell, **ubicado en la carpeta del proyecto** (los `icl` usan rutas relativas):

   ```bat
   mads main.asm -o:juego.xex
   ```

3. Abre `juego.xex` con Altirra (doble clic, arrastrándolo a la ventana o con `Altirra64.exe juego.xex`).

Si clonas con git, evita que convierta los finales de línea del binario `kaiju_titulo.mic`
(`git config core.autocrlf false`); MADS acepta igual los `.asm` con CRLF.

## Controles

| Control              | Acción                                   |
|----------------------|------------------------------------------|
| Joystick 1           | Moverse (8 direcciones)                  |
| Botón                | Disparar hacia donde miras               |
| Botón (en el título) | Empezar la partida                       |

## Reglas

- **Células**: tócalas para recogerlas (+100). Cuando no queda ninguna, pasas a la etapa siguiente.
  Si le disparas a una, pierdes la etapa: −1 de energía y "TRY AGAIN".
- **Robots**: patrullan su zona y te persiguen si entras en ella. Tocarlos cuesta 1 de energía.
  Cada disparo les quita una vida (1, 2 o 3 según el mundo); destruirlos da +10.
- **Bloques azules**: se rompen a disparos (+1). El borde verde también te daña.
- **Energía**: empiezas con 5; después de cada golpe quedas un rato invulnerable. Con 0 es GAME OVER.
  Cada 5000 puntos ganas 1 de energía (hasta 5).
- Al superar las 30 etapas aparece "YOU ARE SUPER PLAYER".

## Pantalla

- **Marcador** (fila superior): la energía a la izquierda, las células que faltan al centro y el
  puntaje a la derecha.
- **Efectos**: la bala saca chispas al chocar con un muro; los robots parpadean cuando los hieres y
  explotan al destruirlos; tú parpadeas mientras eres invulnerable.

## Estructura

| Archivo                | Contenido                                                      |
|------------------------|----------------------------------------------------------------|
| `main.asm`             | Punto de entrada, bucle principal; incluye todo lo demás       |
| `hardware.asm`         | Registros del Atari y mapa de memoria                          |
| `jugador.asm`          | Movimiento, animación y dibujo del jugador                     |
| `bala.asm`             | Disparo y chispas                                              |
| `enemigos.asm`         | Robots: patrulla, persecución, contactos, parpadeo y explosión |
| `celulas.asm`          | Células                                                        |
| `nivel.asm`            | Pantallas (juego, mensajes, título) y choques con los bloques  |
| `etapas.asm`           | Título, etapas, mensajes y selector de depuración              |
| `hud.asm`              | Marcador: energía, células restantes y puntaje                 |
| `sonido.asm`           | Efectos de sonido                                              |
| `datos.asm`            | Variables y tablas                                             |
| `kaiju_*.asm`, `.mic`  | Recursos del Kaiju original (gráficos, niveles, robots, título)|
| `editor-sprite.html`   | Editor visual de sprites y colores (se abre en el navegador)   |
| `AGENTS.md`            | Documentación técnica detallada (memoria, reglas, detalles)    |

## Editor de sprites

`editor-sprite.html` se abre directamente en el navegador, sin instalar nada. Permite editar las poses del
robot, la bala y los colores con la paleta del Atari. Tiene una escena de prueba para ver el movimiento y
los disparos sobre los mapas de Kaiju, y exporta bloques `.byte` listos para pegar en el código.

## Diferencias con el original

- La persecución de los robots usa 8 direcciones limpias (el original comparaba mal un eje en algunos casos).
- En vertical, el jugador se mueve 2 líneas por paso (el original, 1).
- La bala choca con su caja completa de 4 × 8; así se puede salir de la caja del mapa 6.
- Efectos nuevos: chispas, parpadeos, explosión de los robots y vida extra cada 5000 puntos.
- Sonidos simplificados.
- Los colores no cambian solos tras varios minutos jugando solo con el joystick (el juego desactiva el
  modo atracción del Atari).
