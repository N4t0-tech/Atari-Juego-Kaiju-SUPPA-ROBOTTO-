; datos.asm - variables y graficos del sprite

px      .byte 120
py      .byte 120       ; en lineas (PMG a 1 linea)
FRAMES_PASO = 2         ; frames por paso del juego (1 = 50/60 pasos por segundo)
npaso   .byte 0         ; contador de pasos del juego (freno en diagonal)
tick    .byte 0         ; frames desde el ultimo cambio de paso
paso    .byte 0         ; paso de la caminata: 0 = A, 1 = B
pose    .byte 0         ; pose a dibujar (POSE_*)
espejo  .byte 0         ; $80 = dibujar la pose espejada
filas   .byte 0         ; auxiliar (sonido.asm)
oldx    .byte 0         ; posicion antes de mover (para frenar la diagonal)
oldy    .byte 0
ddx     .byte 4         ; hacia donde mira: -4, 0 o 4 (empieza mirando a la derecha)
ddy     .byte 0
sndtim  .byte 0         ; frames que le quedan al sonido de disparo
activa  .byte 0         ; 1 = hay una bala en vuelo
bx      .byte 0         ; posicion de la bala
by      .byte 0
bdx     .byte 0         ; velocidad de la bala
bdy     .byte 0
tmp     .byte 0         ; auxiliar para el dibujo espejado
tmp2    .byte 0         ; auxiliar (mascaras de las vidas)
mvx     .byte 0         ; movimiento pedido este frame: -1, 0, 1
mvy     .byte 0         ; -2, 0, 2 (lineas)
nivel   .byte 0         ; nivel de Kaiju en pantalla (0-5 = LEVEL1-6)
fil0    .byte 0         ; caja del robot en filas/columnas (choca)
fil1    .byte 0
col0    .byte 0
col1    .byte 0
andando .byte 0         ; 1 = el jugador se movio este frame (anima la caminata)
gatillo .byte 1         ; STRIG0 de este frame (0 = presionado)
gatant  .byte 1         ; STRIG0 del frame anterior (para disparar solo al apretar)
puntos  .byte 0,0,0     ; puntuacion BCD, 6 digitos (alto, medio, bajo)

; --- partida (etapas.asm) ---
etapa   .byte 0         ; 0-29: mundo = etapa/6 + 1, mapa = etapa%6 + 1, robots = DAT(etapa)
etapa_ini .byte 0       ; etapa con la que empieza la partida (selector DEBUG)
dbg_stick .byte $0F     ; STICK0 anterior del selector (para moverse al apretar)
        .if DEBUG
; linea de texto del titulo en DEBUG (ANTIC 7, 20 caracteres, fuente de la ROM)
txt_debug dta d'   START LEVEL 1-1  '
TXT_DEBUG_M = 15        ; posicion del digito del mundo (n va 2 despues)
        .endif
energia .byte 5         ; iconos de energia; 0 = fin de la partida
invul   .byte 0         ; frames de invulnerabilidad que quedan tras un golpe
fin     .byte 0         ; 1 = se disparo a una celula: se repite la etapa
cuenta  .byte 0         ; 0-11: animacion de las celulas (cambian a los 0 y 6)
cnt11   .byte 11        ; frames hasta la proxima actualizacion de los enemigos
sndtipo .byte 0         ; efecto que suena (SND_*)
bcol    .byte 0         ; casilla que toco la bala (bloque_en)
bfil    .byte 0
bpunto  .byte 0         ; esquina de la bala que se esta probando (3..0)
brompe  .byte 0         ; 1 = la bala rompio algun bloque azul en este frame
bala_px .byte 0,3,0,3   ; esquinas de la bala (4 px x 8 lineas) desde bx, by
bala_py .byte 0,0,7,7
pcx     .byte 0         ; casilla del centro del jugador (enemigos.asm)
pcy     .byte 0
tmp3    .byte 0         ; auxiliares
ox_r    .byte 0
oy_r    .byte 0

; --- robots enemigos de la etapa (enemigos.asm), hasta MAXROB ---
MAXROB  = 10
nrob    .byte 0
rob_x   :MAXROB .byte 0 ; casilla de arriba a la izquierda de sus 2 x 2 caracteres
rob_y   :MAXROB .byte 0
rob_dira :MAXROB .byte 0        ; patrulla: direccion de la 1a mitad del recorrido
rob_dirb :MAXROB .byte 0        ; y de la 2a
rob_pasos :MAXROB .byte 0       ; largo del recorrido (actualizaciones)
rob_clase :MAXROB .byte 0       ; primer caracter: $9C (inverso, COLOR3) o $1C
rob_zy0 :MAXROB .byte 0         ; zona de vigilancia: filas zy0-zy1,
rob_zy1 :MAXROB .byte 0
rob_zx0 :MAXROB .byte 0         ; columnas zx0-zx1
rob_zx1 :MAXROB .byte 0
rob_dir :MAXROB .byte 0         ; direccion actual (DIR_*); 9 = destruido
rob_paso :MAXROB .byte 0        ; paso de la patrulla
rob_estado :MAXROB .byte 0      ; 1 = patrulla, 2 = persigue al jugador
rob_vida :MAXROB .byte 0        ; disparos que aguanta
rob_fase :MAXROB .byte 0        ; animacion; avanza cuando vuelve a 0

; --- celulas de la etapa (celulas.asm), hasta MAXCEL ---
MAXCEL  = 18
ncel    .byte 0
celrest .byte 0         ; celulas que faltan recoger
cel_x   :MAXCEL .byte 0
cel_y   :MAXCEL .byte 0
cel_viva :MAXCEL .byte 0

; direcciones de Kaiju (medidas en el original): desplazamiento en casillas
; 0 arr-izq, 1 arr, 2 izq, 3 aba-izq, 4 aba-der, 5 aba, 6 der, 7 arr-der, 8 quieto
dir_dx  .byte $FF,0,$FF,$FF,1,0,1,1,0
dir_dy  .byte $FF,$FF,0,1,1,1,0,$FF,0
; persecucion: direccion segun (signo dy + 1) * 3 + (signo dx + 1)
persigue .byte 0,1,7, 2,8,6, 3,5,4

; efectos de sonido (sonido.asm): AUDF1 = base + paso * k, k = 0..7
SND_DISPARO = 0
SND_RECOGER = 1
SND_GOLPE   = 2
snd_base .byte 20,60,40
snd_paso .byte 6,$FC,12
snd_dist .byte $A0,$A0,$80      ; $A = tono puro, $8 = ruido

txt_level .byte $28,$29,$2A,$29,$28     ; "LEVEL" con la fuente de Kaiju
hud_dirty .byte 1       ; 1 = hay que redibujar el HUD
; icono de vidas (11 px x 3 filas con Player 2+3). Ya no se dibuja: el HUD
; usa los iconos de energia de Kaiju; se conserva para el editor.: 3 mini-iconos de 3 px
; en columnas 0-2, 4-6 y 8-10 (columnas 3 y 7 libres). 2 bytes por fila:
; P2 = columnas 0-7, P3 = columnas 8-10 en sus bits 7-5. Dibujalo en
; editor-sprite.html (panel Vidas) y pega aqui el .byte exportado.
vida_icono .byte %10101010,%10100000
        .byte %11101110,%11100000
        .byte %01000100,%01000000
; sprite de la bala (missiles 0+1, 2 cols x 4 filas): cada pareja de
; bits se enciende en bloque, sin pixeles sueltos. M1 = col 0 (bits 3-2),
; M0 = col 1 (bits 1-0). Valores por fila: $0 vacio, $3 der, $C izq,
; $F bloque. Dibujalo en editor-sprite.html (panel Bala) y pega aqui
; el .byte exportado.
bala_icono .byte %0000
        .byte %1111
        .byte %1111
        .byte %0000

; poses del jugador (kaiju_graficos.asm). Cada pose es P0 (24 bytes) seguido
; de P1 (24 bytes); dibujar_jugador cuenta con eso. Las B van tras las A.
POSE_QUIETO_DER = 0
POSE_CAMINA_A   = 1     ; + paso: 2 = camina B
POSE_ARRIBA_A   = 3     ; + paso: 4 = de espaldas B
POSE_QUIETO_IZQ = 5
poses_lo .byte <kaiju_quieto_der_p0,<kaiju_camina_a_p0,<kaiju_camina_b_p0
        .byte <kaiju_arriba_a_p0,<kaiju_arriba_b_p0,<kaiju_quieto_izq_p0
poses_hi .byte >kaiju_quieto_der_p0,>kaiju_camina_a_p0,>kaiju_camina_b_p0
        .byte >kaiju_arriba_a_p0,>kaiju_arriba_b_p0,>kaiju_quieto_izq_p0
        .if kaiju_quieto_der_p1<>kaiju_quieto_der_p0+24 .or kaiju_camina_a_p1<>kaiju_camina_a_p0+24 .or kaiju_camina_b_p1<>kaiju_camina_b_p0+24
        .error "kaiju_graficos.asm: cada pose debe tener P1 justo despues de P0"
        .endif
        .if kaiju_arriba_a_p1<>kaiju_arriba_a_p0+24 .or kaiju_arriba_b_p1<>kaiju_arriba_b_p0+24 .or kaiju_quieto_izq_p1<>kaiju_quieto_izq_p0+24
        .error "kaiju_graficos.asm: cada pose debe tener P1 justo despues de P0"
        .endif

; direccion de cada fila de la pantalla (fila 0 = HUD, 1-23 = nivel)
filas_lo :24 dta l(PANTALLA+#*40)
filas_hi :24 dta h(PANTALLA+#*40)

; lista de pantalla (se copia a DLIST): 24 lineas en blanco, 24 filas en
; ANTIC 4 (la 0 es el HUD) y salto con espera del VBI
dl_datos .byte $70,$70,$70
        .byte $44,<PANTALLA,>PANTALLA   ; ANTIC 4 + LMS
        :23 .byte $04                   ; ANTIC 4 (multicolor)
        .byte $41,<DLIST,>DLIST
dl_fin


; ---------- robot original (12 filas a doble linea) ----------
; El juego ya no lo dibuja (usa las poses de Kaiju); se conserva porque
; editor-sprite.html todavia lo edita.

; ---------- Player 0: cuerpo del robot (color turquesa) ----------
; frame 0 (offset 0): quieto
sprite  .byte %00000000
        .byte %00111100
        .byte %00101000
        .byte %00111100
        .byte %00100000
        .byte %00011000
        .byte %11111111
        .byte %10100101
        .byte %00111100
        .byte %00111100
        .byte %00100100
        .byte %01100110
; frame 1 (offset 12): paso A
        .byte %00000000
        .byte %00111100
        .byte %00101000
        .byte %00111100
        .byte %00100000
        .byte %00011000
        .byte %01111110
        .byte %10100101
        .byte %00111100
        .byte %00111100
        .byte %00101000
        .byte %01001100
; frame 2 (offset 24): paso B
        .byte %00000000
        .byte %00111100
        .byte %00101000
        .byte %00111100
        .byte %00100000
        .byte %00011000
        .byte %01111110
        .byte %10100101
        .byte %00111100
        .byte %00111100
        .byte %00010100
        .byte %00110010

; ---------- Player 1: detalles del robot (color naranja, uno por frame) ----------
; offsets 0/12/24, en paso con el cuerpo
; detalles 0 (offset 0): quieto
detalle .byte %00011000
        .byte %00000000
        .byte %00010100
        .byte %01000010
        .byte %00011100
        .byte %00000000
        .byte %00000000
        .byte %00011000
        .byte %10000001
        .byte %00000000
        .byte %00000000
        .byte %00000000
; detalles 1 (offset 12): paso A
        .byte %00011000
        .byte %00000000
        .byte %00010100
        .byte %01000010
        .byte %00011100
        .byte %00000000
        .byte %00000000
        .byte %00011000
        .byte %01000001
        .byte %00000000
        .byte %00000000
        .byte %00000000
; detalles 2 (offset 24): paso B
        .byte %00011000
        .byte %00000000
        .byte %00010100
        .byte %01000010
        .byte %00011100
        .byte %00000000
        .byte %00000000
        .byte %00011000
        .byte %10000010
        .byte %00000000
        .byte %00000000
        .byte %00000000

; tabla para espejar el sprite (bit invertido): revtab[$3C] = $3C, etc.
revtab  .byte $00,$80,$40,$C0,$20,$A0,$60,$E0
        .byte $10,$90,$50,$D0,$30,$B0,$70,$F0
        .byte $08,$88,$48,$C8,$28,$A8,$68,$E8
        .byte $18,$98,$58,$D8,$38,$B8,$78,$F8
        .byte $04,$84,$44,$C4,$24,$A4,$64,$E4
        .byte $14,$94,$54,$D4,$34,$B4,$74,$F4
        .byte $0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC
        .byte $1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
        .byte $02,$82,$42,$C2,$22,$A2,$62,$E2
        .byte $12,$92,$52,$D2,$32,$B2,$72,$F2
        .byte $0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA
        .byte $1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
        .byte $06,$86,$46,$C6,$26,$A6,$66,$E6
        .byte $16,$96,$56,$D6,$36,$B6,$76,$F6
        .byte $0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE
        .byte $1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
        .byte $01,$81,$41,$C1,$21,$A1,$61,$E1
        .byte $11,$91,$51,$D1,$31,$B1,$71,$F1
        .byte $09,$89,$49,$C9,$29,$A9,$69,$E9
        .byte $19,$99,$59,$D9,$39,$B9,$79,$F9
        .byte $05,$85,$45,$C5,$25,$A5,$65,$E5
        .byte $15,$95,$55,$D5,$35,$B5,$75,$F5
        .byte $0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED
        .byte $1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
        .byte $03,$83,$43,$C3,$23,$A3,$63,$E3
        .byte $13,$93,$53,$D3,$33,$B3,$73,$F3
        .byte $0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB
        .byte $1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
        .byte $07,$87,$47,$C7,$27,$A7,$67,$E7
        .byte $17,$97,$57,$D7,$37,$B7,$77,$F7
        .byte $0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF
        .byte $1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF
