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
