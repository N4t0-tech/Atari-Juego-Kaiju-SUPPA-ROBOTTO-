; hardware.asm - direcciones del Atari 8-bit usadas por el juego

; --- variables del sistema (shadow registers del OS) ---
SDMCTL  = $022F         ; shadow de DMACTL
GPRIOR  = $026F         ; shadow de PRIOR (prioridades y color de missiles)
STICK0  = $0278         ; joystick 1 (bit en 0 = presionado)
STRIG0  = $0284         ; boton de disparo (0 = presionado)
PCOLR0  = $02C0         ; color del jugador 0
PCOLR1  = $02C1         ; color del jugador 1
PCOLR2  = $02C2         ; color del jugador 2 (vidas del HUD)
PCOLR3  = $02C3         ; color del jugador 3 (vidas del HUD)
COLOR0  = $02C4         ; color 0 del playfield (pixel 01 en ANTIC 4/E)
COLOR1  = $02C5         ; texto del modo texto (GR.0)
COLOR3  = $02C7         ; color 3 (lo usan los missiles con GPRIOR bit 4)
COLOR2  = $02C6         ; fondo del modo texto (GR.0)
COLOR4  = $02C8         ; fondo de modos graficos y borde
CRSINH  = $02F0         ; 1 = ocultar cursor
CHBAS   = $02F4         ; shadow de CHBASE (pagina de la fuente)
RTCLOK  = $14           ; contador de frames (byte bajo)
SAVMSC  = $58           ; puntero a la memoria de pantalla (GR.0 del OS; ya no se usa)
SDLSTL  = $0230         ; shadow de la lista de pantalla (byte bajo)
SDLSTH  = $0231         ; (byte alto)
VDSLST  = $0200         ; vector de la DLI

; --- GTIA / ANTIC ---
HPOSP0  = $D000         ; posicion horizontal del jugador 0
HPOSP1  = $D001         ; posicion horizontal del jugador 1
HPOSP2  = $D002         ; posicion horizontal del jugador 2 (vidas izq)
HPOSP3  = $D003         ; posicion horizontal del jugador 3 (vidas der)
HPOSM0  = $D004         ; posicion horizontal del missile 0 (bala)
HPOSM1  = $D005         ; posicion horizontal del missile 1 (bala, 2a mitad)
GRACTL  = $D01D         ; activa jugadores y missiles
PMBASE  = $D407         ; pagina base de la memoria PMG
COLPF0  = $D016         ; colores del playfield (solo desde la DLI)
COLPF1  = $D017
COLPF2  = $D018
CHBASE  = $D409         ; fuente (solo desde la DLI; el OS la repone desde CHBAS)
WSYNC   = $D40A         ; espera al final de la linea
NMIEN   = $D40E         ; activa DLI ($80) y VBI ($40)

; --- ROM ---
FUENTE_ROM = $E000      ; fuente del sistema (1 KB)

; --- POKEY (sonido) ---
AUDF1   = $D200         ; canal 1: frecuencia (valor mayor = tono mas grave)
AUDC1   = $D201         ; canal 1: distorsion (4 bits altos) y volumen (bajos)

; --- pagina cero ($CB-$D1 libres para programas de usuario) ---
ptr     = $CB           ; puntero de 2 bytes (pose del jugador, nivel)
ptr2    = $CD           ; puntero de 2 bytes (pantalla)

; --- memoria del juego ---
PMG     = $8000         ; bloque PMG a 1 linea (2 KB, alineado a 2 KB):
                        ; +$300 missiles, +$400 P0, +$500 P1, +$600 P2, +$700 P3
FUENTE  = $8800         ; fuente del juego (1 KB, alineada a 1 KB)
PANTALLA = $8C00        ; 24 filas x 40: fila 0 HUD, 1-23 nivel (960 bytes)
DLIST   = $8FC0         ; lista de pantalla del juego (32 bytes, no cruza 1 KB)
DLIST_T = $9000         ; lista de pantalla del titulo (209 bytes; $9000-$9BFF es
                        ; RAM libre aunque este BASIC: la pantalla del OS no se usa)
                        ; el programa ($2000 en adelante) debe terminar antes
