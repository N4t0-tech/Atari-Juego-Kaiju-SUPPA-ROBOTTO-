; celulas.asm - las celulas de cada etapa: los objetos que hay que recoger
;
; Cada celula son 2 x 2 caracteres en cel_x/cel_y, animados: $18-$1B y
; $14-$17, alternando cada 6 frames (como en el original). Tocarla con el
; jugador la recoge (+100); dispararle termina la etapa (fin = 1).

; ptr2 = direccion en pantalla de la celula X. Conserva X.
dir_celula
        ldy cel_y,x
        lda filas_lo,y
        clc
        adc cel_x,x
        sta ptr2
        lda filas_hi,y
        adc #0
        sta ptr2+1
        rts

; cada frame: avanza la animacion y redibuja las celulas cuando cambia
dibujar_celulas
        inc cuenta
        lda cuenta
        cmp #12
        bcc dc_ok
        lda #0
        sta cuenta
dc_ok   lda cuenta
        beq pintar_celulas
        cmp #6
        beq pintar_celulas
        rts

; dibuja todas las celulas que quedan con la fase de «cuenta»
pintar_celulas
        ldx #0
pc_cel  cpx ncel
        bcs pc_fin
        lda cel_viva,x
        beq pc_sig
        jsr dir_celula
        lda #$18
        ldy cuenta
        cpy #6
        bcc pc_pon
        lda #$14
pc_pon  jsr poner2x2
pc_sig  inx
        jmp pc_cel
pc_fin  rts

; el jugador recoge la celula X: se borra, +100 puntos. Conserva X.
recoger_celula
        lda #0
        sta cel_viva,x
        jsr dir_celula
        jsr borrar2x2
        dec celrest
        stx tmp3
        ldx #1
        lda #$01
        jsr sumar_bcd
        ldx tmp3
        lda #SND_RECOGER
        jmp sonar

; la bala toco la casilla bcol/bfil de una celula: se cambia por la
; explosion y fin = 1 (explotar_celula la anima antes del TRY AGAIN)
romper_celula
        ldx #0
rc_cel  cpx ncel
        bcs rc_fin
        lda cel_viva,x
        beq rc_sig
        lda bcol        ; bcol en x..x+1 y bfil en y..y+1
        sec
        sbc cel_x,x
        cmp #2
        bcs rc_sig
        lda bfil
        sec
        sbc cel_y,x
        cmp #2
        bcs rc_sig
        lda #0          ; ya no se anima ni se recoge
        sta cel_viva,x
        stx cel_expl
        jsr dir_celula
        lda #EXPLO+$80
        jsr poner2x2
        lda #SND_EXPLOSION
        jsr sonar
        lda #1
        sta fin
        rts
rc_sig  inx
        jmp rc_cel
rc_fin  lda #1          ; no deberia pasar: igual se pierde la etapa
        sta fin
        rts

; animacion de la celula destruida (el juego queda congelado): la explosion
; alterna sus 2 fases, el nivel se corrompe, el fondo destella y el ruido
; se repite; luego se borra y vuelven los colores
explotar_celula
        lda #32
        sta ecuenta
ec_paso jsr esperar_paso
        lda ecuenta
        and #7
        bne ec_snd
        lda #SND_EXPLOSION
        jsr sonar
ec_snd  jsr actualizar_sonido
        lda #0          ; destello: fondo naranja/negro la primera mitad
        ldx ecuenta
        cpx #16
        bcc ec_col
        txa
        and #1
        beq ec_col
        lda #$24
ec_col  sta COLOR4
        jsr corromper
        ldx cel_expl
        jsr dir_celula
        lda ecuenta
        and #4          ; cambia de fase cada 4 pasos
        clc
        adc #EXPLO+$80
        jsr poner2x2
        dec ecuenta
        bne ec_paso
        jsr borrar2x2   ; ptr2 sigue en la celula
        lda #0
        sta COLOR4
        jsr colores_juego
        jmp actualizar_sonido

; el nivel se corrompe: (33 - ecuenta) * 2 caracteres al azar en posiciones
; al azar de las filas 1-23 (el HUD no), y a veces los colores tambien.
; No hace falta deshacerlo: cargar_etapa redibuja el mapa entero
corromper
        lda #33
        sec
        sbc ecuenta
        asl
        sta tmp3
co_fil  lda RANDOM
        and #31
        beq co_fil
        cmp #24
        bcs co_fil
        tay
        lda filas_lo,y
        sta ptr
        lda filas_hi,y
        sta ptr+1
co_col  lda RANDOM
        and #63
        cmp #40
        bcs co_col
        tay
        lda RANDOM
        sta (ptr),y
        dec tmp3
        bne co_fil
        lda RANDOM      ; 1 de cada 4 pasos: colores al azar
        and #3
        bne co_fin
        lda RANDOM
        sta COLOR0
        lda RANDOM
        sta COLOR1
        lda RANDOM
        sta COLOR2
co_fin  rts

; animacion de etapa superada (el juego queda congelado): el nivel se borra
; fila por fila de arriba abajo, el robot baila (baile_*: una pose cada 4
; pasos, saltando en algunas) y suena un tono que sube. cargar_etapa
; redibuja el mapa de la etapa siguiente
celebrar
        jsr borrabala   ; la bala o las chispas que hubiera
        lda #0
        sta activa
        sta chispa
        sta invul       ; que no parpadee mientras baila
        sta ecuenta     ; aqui cuenta hacia arriba: 0..39
        lda py
        sta oldy        ; altura del suelo (los saltos suben desde aqui)
ce_paso jsr esperar_paso
        lda ecuenta
        and #7
        bne ce_snd
        lda #SND_VICTORIA
        jsr sonar
ce_snd  jsr actualizar_sonido
        jsr borrar_jugador
        lda ecuenta     ; tiempo del baile = (ecuenta / 4) % 8
        lsr
        lsr
        and #7
        tax
        lda baile_pose,x
        sta pose
        lda baile_espejo,x
        sta espejo
        lda oldy
        sec
        sbc baile_salto,x
        sta py
        jsr dibujar_jugador
        ldy ecuenta     ; pasos 1-23: se borra esa fila
        beq ce_sig
        cpy #24
        bcs ce_sig
        lda filas_lo,y
        sta ptr
        lda filas_hi,y
        sta ptr+1
        lda #0
        ldy #39
ce_fila sta (ptr),y
        dey
        bpl ce_fila
ce_sig  inc ecuenta
        lda ecuenta
        cmp #40
        bne ce_paso
        jmp actualizar_sonido
