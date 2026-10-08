; kaiju_graficos.asm - sprites, fuente, colores y textos de Kaiju ("SUPPA ROBOTTO")
; Extraidos de AUTORUN.SYS (juego en C compilado con cc65). El jugador usa las
; poses y los colores KAIJU_PCOLR0/1; dibujar_jugador espera cada _p1 justo
; despues de su _p0 (datos.asm lo comprueba al ensamblar).
;
; Como los usaba el juego original:
;   - sprites a 1 linea (SDMCTL = $3E) y 24 filas por frame
;   - cada pose = Player 0 (cuerpo) + Player 1 (contorno), en la misma X
;   - GPRIOR = $31: P0 y P1 se mezclan (OR) donde se solapan: 3er color
;   - pantalla de juego en ANTIC modo 4 (caracteres multicolor, 2 bits por
;     pixel: 00 fondo, 01 COLOR0, 10 COLOR1, 11 COLOR2; caracter inverso usa COLOR3)

; --- colores (registros sombra del OS) ---
KAIJU_PCOLR0    = $B8   ; cuerpo del jugador (P0)
KAIJU_PCOLR1    = $3A   ; contorno del jugador (P1); mezcla P0|P1 = $BA
KAIJU_PCOLR2    = $EC   ; disparo (P2)
KAIJU_PCOLR3    = $60   ; P3
KAIJU_GPRIOR    = $31   ; bit 5 mezcla de colores, bit 4 missiles con COLOR3
KAIJU_COLOR0    = $8A   ; bloques: pixel 01
KAIJU_COLOR1    = $34   ; bloques: pixel 10
KAIJU_COLOR2    = $CC   ; bloques: pixel 11
KAIJU_COLOR3    = $26   ; caracteres inversos y missiles
KAIJU_COLOR4    = $00   ; fondo

; --- jugador: 7 poses x 2 players x 24 filas ---
; quieto mirando a la derecha (y mirando abajo) (Player 0, cuerpo)
kaiju_quieto_der_p0     .byte %00000000
                        .byte %00000000
                        .byte %00000000
                        .byte %00111100
                        .byte %00111100
                        .byte %00101000
                        .byte %00111100
                        .byte %00100000
                        .byte %00111100
                        .byte %00011000
                        .byte %01111110
                        .byte %10110101
                        .byte %10111101
                        .byte %10111101
                        .byte %10111101
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00100100
                        .byte %00100100
                        .byte %00100100
                        .byte %00000000
                        .byte %00000000
                        .byte %00000000
; quieto mirando a la derecha (y mirando abajo) (Player 1, contorno)
kaiju_quieto_der_p1     .byte %00000000
                        .byte %00000000
                        .byte %00011000
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %01111110
                        .byte %00111100
                        .byte %00111100
                        .byte %00011000
                        .byte %01111110
                        .byte %10101101
                        .byte %10100101
                        .byte %10100101
                        .byte %10100101
                        .byte %10111101
                        .byte %00000000
                        .byte %00111100
                        .byte %00100100
                        .byte %00100100
                        .byte %00100100
                        .byte %00110110
                        .byte %00000000
                        .byte %00000000
; caminando, paso A (Player 0, cuerpo)
kaiju_camina_a_p0       .byte %00000000
                        .byte %00000000
                        .byte %00000000
                        .byte %00111100
                        .byte %00111100
                        .byte %00101000
                        .byte %00111100
                        .byte %00100000
                        .byte %00111100
                        .byte %00011000
                        .byte %01111100
                        .byte %10110110
                        .byte %10111110
                        .byte %10111111
                        .byte %10111110
                        .byte %00111110
                        .byte %00111100
                        .byte %00111100
                        .byte %00100100
                        .byte %00100000
                        .byte %00100000
                        .byte %00000000
                        .byte %00000000
                        .byte %00000000
; caminando, paso A (Player 1, contorno)
kaiju_camina_a_p1       .byte %00000000
                        .byte %00000000
                        .byte %00011000
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %01111110
                        .byte %00111100
                        .byte %00111100
                        .byte %00011000
                        .byte %01111100
                        .byte %10101110
                        .byte %10100110
                        .byte %10100111
                        .byte %10100110
                        .byte %10111110
                        .byte %00000010
                        .byte %00111100
                        .byte %00100100
                        .byte %00100110
                        .byte %00100000
                        .byte %00110000
                        .byte %00000000
                        .byte %00000000
; caminando, paso B (Player 0, cuerpo)
kaiju_camina_b_p0       .byte %00000000
                        .byte %00000000
                        .byte %00000000
                        .byte %00111100
                        .byte %00111100
                        .byte %00101000
                        .byte %00111100
                        .byte %00100000
                        .byte %00111100
                        .byte %00011000
                        .byte %00111110
                        .byte %01110101
                        .byte %01111101
                        .byte %11111101
                        .byte %01111101
                        .byte %01111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00100100
                        .byte %00000100
                        .byte %00000100
                        .byte %00000000
                        .byte %00000000
                        .byte %00000000
; caminando, paso B (Player 1, contorno)
kaiju_camina_b_p1       .byte %00000000
                        .byte %00000000
                        .byte %00011000
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %01111110
                        .byte %00111100
                        .byte %00111100
                        .byte %00011000
                        .byte %00111110
                        .byte %01101101
                        .byte %01100101
                        .byte %11100101
                        .byte %01100101
                        .byte %01111101
                        .byte %01000000
                        .byte %00111100
                        .byte %00100100
                        .byte %00110100
                        .byte %00000100
                        .byte %00000110
                        .byte %00000000
                        .byte %00000000
; de espaldas (joystick arriba), paso A (Player 0, cuerpo)
kaiju_arriba_a_p0       .byte %00000000
                        .byte %00000000
                        .byte %00000000
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00011000
                        .byte %00111110
                        .byte %01111101
                        .byte %01111101
                        .byte %01111101
                        .byte %01111101
                        .byte %01111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00100100
                        .byte %00000100
                        .byte %00000100
                        .byte %00000000
                        .byte %00000000
                        .byte %00000000
; de espaldas (joystick arriba), paso A (Player 1, contorno)
kaiju_arriba_a_p1       .byte %00000000
                        .byte %00000000
                        .byte %00011000
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %01111110
                        .byte %00111100
                        .byte %00111100
                        .byte %00011000
                        .byte %00111110
                        .byte %01111101
                        .byte %01111101
                        .byte %01111101
                        .byte %01111101
                        .byte %01111101
                        .byte %01000000
                        .byte %00111100
                        .byte %00100100
                        .byte %00110100
                        .byte %00000100
                        .byte %00000110
                        .byte %00000000
                        .byte %00000000
; de espaldas (joystick arriba), paso B (Player 0, cuerpo)
kaiju_arriba_b_p0       .byte %00000000
                        .byte %00000000
                        .byte %00000000
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00011000
                        .byte %00111100
                        .byte %01111110
                        .byte %10111110
                        .byte %10111110
                        .byte %10111110
                        .byte %00111110
                        .byte %00111100
                        .byte %00111100
                        .byte %00100100
                        .byte %00100000
                        .byte %00100000
                        .byte %00000000
                        .byte %00000000
                        .byte %00000000
; de espaldas (joystick arriba), paso B (Player 1, contorno)
kaiju_arriba_b_p1       .byte %00000000
                        .byte %00000000
                        .byte %00011000
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %01111110
                        .byte %00111100
                        .byte %00111100
                        .byte %00011000
                        .byte %00111100
                        .byte %01111110
                        .byte %10111110
                        .byte %10111110
                        .byte %10111110
                        .byte %10111110
                        .byte %00000010
                        .byte %00111100
                        .byte %00100100
                        .byte %00100110
                        .byte %00100000
                        .byte %00110000
                        .byte %00000000
                        .byte %00000000
; quieto mirando a la izquierda (Player 0, cuerpo)
kaiju_quieto_izq_p0     .byte %00000000
                        .byte %00000000
                        .byte %00000000
                        .byte %00111100
                        .byte %00111100
                        .byte %00010100
                        .byte %00111100
                        .byte %00000100
                        .byte %00111100
                        .byte %00011000
                        .byte %01111110
                        .byte %10110101
                        .byte %10111101
                        .byte %10111101
                        .byte %10111101
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00100100
                        .byte %00100100
                        .byte %00100100
                        .byte %00000000
                        .byte %00000000
                        .byte %00000000
; quieto mirando a la izquierda (Player 1, contorno)
kaiju_quieto_izq_p1     .byte %00000000
                        .byte %00000000
                        .byte %00011000
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %01111110
                        .byte %00111100
                        .byte %00111100
                        .byte %00011000
                        .byte %01111110
                        .byte %10101101
                        .byte %10100101
                        .byte %10100101
                        .byte %10100101
                        .byte %10111101
                        .byte %00000000
                        .byte %00111100
                        .byte %00100100
                        .byte %00100100
                        .byte %00100100
                        .byte %01101100
                        .byte %00000000
                        .byte %00000000
; pose que el juego no usa (variante de quieto) (Player 0, cuerpo)
kaiju_sin_usar_p0       .byte %00000000
                        .byte %00000000
                        .byte %00111100
                        .byte %00111100
                        .byte %00101000
                        .byte %00111100
                        .byte %00100000
                        .byte %00111100
                        .byte %00011000
                        .byte %01111110
                        .byte %10100101
                        .byte %10100101
                        .byte %10100101
                        .byte %10100101
                        .byte %00111100
                        .byte %00111100
                        .byte %00111100
                        .byte %00100100
                        .byte %00100100
                        .byte %00100100
                        .byte %00000000
                        .byte %00000000
                        .byte %00000000
                        .byte %00000000
; pose que el juego no usa (variante de quieto) (Player 1, contorno)
kaiju_sin_usar_p1       .byte %00000000
                        .byte %00011000
                        .byte %00111100
                        .byte %00111100
                        .byte %00101000
                        .byte %01111110
                        .byte %00100000
                        .byte %00111100
                        .byte %00011000
                        .byte %01111110
                        .byte %10100101
                        .byte %10100101
                        .byte %10100101
                        .byte %10100101
                        .byte %10111101
                        .byte %00000000
                        .byte %00111100
                        .byte %00100100
                        .byte %00100100
                        .byte %00100100
                        .byte %00110110
                        .byte %00000000
                        .byte %00000000
                        .byte %00000000

; --- disparo (Player 2, 24 filas). Vertical: kaiju_disparo_v; horizontal: kaiju_disparo_h ---
kaiju_disparo_v         .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$3C,$3C,$3C   ; disparo vertical (arriba/abajo/diagonales)
                        .byte $3C,$3C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
kaiju_disparo_v2        .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$3C,$7E,$3C   ; variante sin usar
                        .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
kaiju_disparo_h         .byte $00,$00,$00,$00,$00,$00,$00,$1C,$1C,$1C,$1C,$1C   ; disparo horizontal (izquierda/derecha)
                        .byte $1C,$1C,$1C,$00,$00,$00,$00,$00,$00,$00,$00,$00
kaiju_disparo_h2        .byte $00,$00,$00,$00,$00,$00,$00,$00,$08,$08,$08,$08   ; variante sin usar
                        .byte $08,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; --- fuente: 57 caracteres propios (codigos $02-$3A), 8 bytes cada uno.
; El juego copia la fuente de la ROM ($E000) y encima pone estos a partir
; del caracter 2 (CHBAS*256 + $10). Bloques de los niveles = caracteres 2-5.
; Los codigos $10-$19 (digitos) y $21-$3A (letras) estan redibujados.
kaiju_fuente            .byte $FF,$03,$0C,$0C,$30,$30,$C0,$FF   ; $02 borde (valor 2 en los niveles)
                        .byte $C3,$C3,$F3,$F3,$CF,$CF,$C3,$C3   ; $03 borde, esquina (3)
                        .byte $AA,$82,$A2,$A2,$8A,$8A,$82,$AA   ; $04 muro tipo 4
                        .byte $55,$41,$51,$51,$45,$45,$41,$55   ; $05 muro tipo 5
                        .byte $02,$0F,$0F,$0E,$2F,$0E,$0F,$00   ; $06
                        .byte $A0,$FC,$FC,$EC,$FE,$AC,$FC,$00   ; $07
                        .byte $0B,$2F,$BA,$FB,$FB,$BA,$2F,$0B   ; $08
                        .byte $E0,$F8,$AE,$EF,$EF,$AE,$F8,$E0   ; $09
                        .byte $2A,$22,$22,$22,$22,$22,$2A,$00   ; $0A
                        .byte $02,$02,$02,$02,$02,$02,$02,$00   ; $0B
                        .byte $2A,$02,$02,$2A,$20,$20,$2A,$00   ; $0C
                        .byte $2A,$02,$02,$2A,$02,$02,$2A,$00   ; $0D
                        .byte $22,$22,$22,$2A,$02,$02,$02,$00   ; $0E
                        .byte $2A,$20,$20,$2A,$02,$02,$2A,$00   ; $0F
                        .byte $2A,$20,$20,$2A,$22,$22,$2A,$00   ; $10 '0'
                        .byte $2A,$02,$02,$02,$02,$02,$02,$00   ; $11 '1'
                        .byte $2A,$22,$22,$2A,$22,$22,$2A,$00   ; $12 '2'
                        .byte $2A,$22,$22,$2A,$02,$02,$2A,$00   ; $13 '3'
                        .byte $00,$00,$00,$00,$00,$BF,$BA,$FB   ; $14 '4'
                        .byte $00,$00,$00,$00,$00,$FE,$AE,$EF   ; $15 '5'
                        .byte $FB,$BA,$BF,$00,$00,$00,$00,$00   ; $16 '6'
                        .byte $EF,$AE,$FE,$00,$00,$00,$00,$00   ; $17 '7'
                        .byte $00,$00,$00,$00,$00,$BF,$BA,$F8   ; $18 '8'
                        .byte $00,$00,$00,$00,$00,$FE,$AE,$2F   ; $19 '9'
                        .byte $F8,$BA,$BF,$00,$00,$00,$00,$00   ; $1A
                        .byte $2F,$AE,$FE,$00,$00,$00,$00,$00   ; $1B
                        .byte $00,$00,$00,$00,$3C,$0C,$FF,$3F   ; $1C
                        .byte $03,$03,$0F,$0F,$3C,$3C,$3C,$F0   ; $1D
                        .byte $3F,$0F,$33,$33,$C0,$C0,$00,$00   ; $1E
                        .byte $F3,$FF,$F3,$F3,$F0,$F0,$30,$FC   ; $1F
                        .byte $00,$00,$00,$00,$3C,$0C,$FF,$0F   ; $20
                        .byte $30,$30,$3C,$3C,$3C,$3C,$3C,$F0   ; $21 'A'
                        .byte $3F,$0F,$0F,$0C,$0C,$0C,$00,$00   ; $22 'B'
                        .byte $F3,$FF,$FF,$FF,$3C,$3C,$0C,$0C   ; $23 'C'
                        .byte $00,$00,$00,$00,$3C,$0C,$00,$00   ; $24 'D'
                        .byte $30,$00,$00,$3C,$00,$3C,$00,$FC   ; $25 'E'
                        .byte $3F,$00,$00,$00,$0C,$00,$00,$00   ; $26 'F'
                        .byte $00,$00,$00,$F3,$00,$00,$30,$30   ; $27 'G'
                        .byte $80,$80,$80,$80,$80,$80,$80,$A8   ; $28 'H'
                        .byte $A8,$80,$80,$A0,$80,$80,$80,$A8   ; $29 'I'
                        .byte $88,$88,$88,$88,$88,$88,$88,$A0   ; $2A 'J'
                        .byte $00,$00,$00,$28,$00,$00,$00,$00   ; $2B 'K'
                        .byte $C0,$C0,$F0,$F0,$3C,$3C,$3C,$0F   ; $2C 'L'
                        .byte $00,$00,$00,$00,$3C,$30,$FF,$FC   ; $2D 'M'
                        .byte $CF,$FF,$CF,$CF,$0F,$0F,$0C,$3F   ; $2E 'N'
                        .byte $FC,$F0,$CC,$CC,$03,$03,$00,$00   ; $2F 'O'
                        .byte $0C,$0C,$3C,$3C,$3C,$3C,$3C,$0F   ; $30 'P'
                        .byte $00,$00,$00,$00,$3C,$30,$FF,$F0   ; $31 'Q'
                        .byte $CF,$FF,$FF,$FF,$3C,$3C,$30,$30   ; $32 'R'
                        .byte $FC,$F0,$F0,$30,$30,$30,$00,$00   ; $33 'S'
                        .byte $30,$B8,$B8,$EC,$B8,$B8,$30,$00   ; $34 'T'
                        .byte $00,$00,$00,$00,$0B,$00,$BA,$00   ; $35 'U'
                        .byte $00,$00,$00,$00,$E0,$00,$AE,$00   ; $36 'V'
                        .byte $FB,$00,$2F,$00,$00,$00,$00,$00   ; $37 'W'
                        .byte $EF,$00,$F8,$00,$00,$00,$00,$00   ; $38 'X'
                        .byte $00,$00,$00,$00,$00,$00,$00,$00   ; $39 'Y'
                        .byte $00,$00,$00,$00,$00,$00,$00,$00   ; $3A 'Z'

; --- textos del juego (codigos de pantalla, terminados en $FF porque el espacio es 0; * = video inverso) ---
kaiju_txt_titulo        dta d'MUVIRON  ',d'SOULBATTERY'*,$FF   ; 20 caracteres, modo 7
kaiju_txt_gameover      dta d'GAME OVER',$FF
kaiju_txt_super         dta d'YOU ARE SUPER PLAYER',$FF
kaiju_txt_tryagain      dta d'TRY AGAIN',$FF
