# atari-juego

Recreación del juego **Kaiju** ("SUPPA ROBOTTO") para Atari de 8 bits, escrita desde cero en ensamblador 6502.
Las reglas del original se sacaron por ingeniería inversa de su binario (compilado con cc65). Los gráficos,
niveles, robots y la imagen de título son los del disco original, convertidos byte a byte.

Manejás al robot Kaiju por 30 etapas (5 mundos de 6 mapas): juntá todas las células, esquivá o destruí
a los robots y no le dispares a las células.

## Requisitos

- [MADS](https://github.com/tebe6502/Mad-Assembler) 2.1.7 (Mad-Assembler)
- Un emulador de Atari 8-bit; el proyecto se prueba con [Altirra](https://www.virtualdub.org/altirra.html)

## Compilar y jugar

```sh
mads main.asm -o:juego.xex
altirra juego.xex
```

`juego.xex` no está en el repo (se genera al compilar).

### Build de debug

```sh
mads main.asm -d:DEBUG=1 -o:juego-debug.xex
```

En la pantalla de título aparece **START LEVEL m-n** para empezar en cualquier etapa:
joystick izquierda/derecha cambia de a una etapa, arriba/abajo de a un mundo (6 etapas).

## Controles

| Control              | Acción                                   |
|----------------------|------------------------------------------|
| Joystick 1           | Mover (8 direcciones)                    |
| Botón                | Disparar en la dirección en que mirás    |
| Botón (en el título) | Empezar la partida                       |

## Reglas

- **Células**: tocalas para juntarlas (+100). Cuando no queda ninguna, pasás a la etapa siguiente.
  Si le disparás a una, perdés la etapa: −1 de energía y "TRY AGAIN".
- **Robots**: patrullan su zona y te persiguen si entrás en ella. Tocarlos cuesta 1 de energía.
  Cada disparo les quita una vida (1, 2 o 3 según el mundo); destruirlos da +10.
- **Bloques azules**: se rompen a tiros (+1). El borde verde también lastima.
- **Energía**: empezás con 5; después de cada golpe hay un rato de invulnerabilidad. Con 0 es GAME OVER.
- Superando las 30 etapas aparece "YOU ARE SUPER PLAYER".

## Estructura

| Archivo                | Contenido                                                      |
|------------------------|----------------------------------------------------------------|
| `main.asm`             | Punto de entrada, bucle principal, incluye todo lo demás       |
| `hardware.asm`         | Registros del Atari y mapa de memoria                          |
| `jugador.asm`          | Movimiento, animación y dibujo del jugador                     |
| `bala.asm`             | Disparo                                                        |
| `enemigos.asm`         | Robots: patrulla, persecución, contactos                       |
| `celulas.asm`          | Células                                                        |
| `nivel.asm`            | Pantallas (juego, mensajes, título) y choques con los bloques  |
| `etapas.asm`           | Título, etapas, mensajes y selector de debug                   |
| `hud.asm`              | Energía, células restantes y puntaje                           |
| `sonido.asm`           | Efectos de sonido                                              |
| `datos.asm`            | Variables y tablas                                             |
| `kaiju_*.asm`, `.mic`  | Recursos del Kaiju original (gráficos, niveles, robots, título)|
| `editor-sprite.html`   | Editor visual de sprites y colores (se abre en el navegador)   |
| `AGENTS.md`            | Documentación técnica detallada (memoria, reglas, detalles)    |

## Editor de sprites

`editor-sprite.html` se abre directamente en el navegador, sin instalar nada. Permite editar las poses del
robot, la bala y los colores con la paleta del Atari. Tiene una escena de prueba para ver el movimiento y
los disparos sobre los mapas de Kaiju y exporta bloques `.byte` listos para pegar en el código.

## Diferencias con el original

- La persecución de los robots usa 8 direcciones limpias (el original comparaba mal un eje en algunos casos).
- En vertical, el jugador se mueve 2 líneas por paso (el original, 1).
- La bala choca con su caja de 4 × 8 completa; así se puede salir de la caja del mapa 6.
- Sonidos simplificados.
