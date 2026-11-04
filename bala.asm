; bala.asm - disparo y bala (una a la vez, con los missiles 0+1: 2x4 editable)

actualizar_bala
        jsr borrabala
        lda gatillo     ; recordar el boton del frame anterior
        sta gatant
        lda STRIG0      ; 0 = presionado
        sta gatillo
        lda activa
        bne bal_mueve
        jsr nuevabala   ; disparar cancela las chispas (chispa = 0)
        lda chispa
        beq finchi
        dec chispa
        beq finchi
        jmp pintachispa
finchi  rts
bal_mueve
        lda bx          ; avanzar la bala
        clc
        adc bdx
        sta bx
        lda by
        clc
        adc bdy
        sta by
        lda bx          ; si sale de la zona visible, se destruye
        cmp #48
        bcc matar
        cmp #205         ; bx+3 (esquina derecha) <= col 39
        bcs matar
        lda by
        cmp #40           ; fila 0 reservada para el HUD
        bcc matar
        cmp #216
        bcs matar
        ; se prueban las 4 esquinas de la bala (4 x 8): rompe todos los bloques
        ; azules que toque; lo primero que no sea azul la destruye
        lda #0
        sta brompe
        ldx #3
bal_pt  stx bpunto
        lda by
        clc
        adc bala_py,x
        pha
        lda bx
        clc
        adc bala_px,x
        tax
        pla
        jsr bloque_en
        bcc bal_sig       ; vacio
        cmp #5            ; bloque azul: se rompe, +1 punto
        bne bal_cel
        lda #0
        sta (ptr2),y      ; bloque_en dejo ptr2/Y apuntando a la casilla
        lda #1
        sta brompe
        ldx #2
        lda #$01
        jsr sumar_bcd
bal_sig ldx bpunto
        dex
        bpl bal_pt
        lda brompe
        bne chocar
        jmp pintabala
bal_cel and #$7F
        cmp #$14
        bcc chocar        ; borde o ladrillo
        cmp #$1C
        bcs bal_rob
        jsr romper_celula ; celula: explota y fin de la etapa (se repite)
        jmp matar
bal_rob cmp #$34
        bcs chocar        ; bloque solido ($34+)
        jsr golpear_enemigo
matar   lda #0
        sta activa
        rts
chocar  lda #0            ; contra un muro: chispas en bx/by
        sta activa
        lda #CHISPA_PASOS
        sta chispa
; chispas (missiles 0+1, 8 lineas desde by): cerca y luego lejos de bx
pintachispa
        ldx #0            ; cerca: filas 0-3 de chispa_icono, separacion 1
        ldy #1
        lda chispa
        cmp #CHISPA_PASOS/2+1
        bcs chi_c
        ldx #4            ; lejos: filas 4-7, separacion 4
        ldy #4
chi_c   tya
        eor #$FF          ; HPOSM1 = bx - sep
        sec
        adc bx
        sta HPOSM1
        tya
        clc
        adc bx
        adc #2            ; HPOSM0 = bx + 2 + sep
        sta HPOSM0
        ldy by
chi_pb  lda chispa_icono,x
        sta PMG+$300,y
        sta PMG+$301,y
        iny
        iny
        inx
        txa
        and #3
        bne chi_pb
        rts
nuevabala
        lda gatillo
        bne finbala     ; 1 = boton sin presionar
        lda gatant
        beq finbala     ; ya estaba presionado: hay que soltarlo para volver a disparar
        lda px          ; la bala (4 px) sale del centro del jugador (8 px)
        clc
        adc #2
        sta bx
        lda py
        clc
        adc #8          ; altura del pecho del robot
        sta by
        lda ddx
        sta bdx
        lda ddy
        asl             ; en vertical el doble: las lineas miden la mitad
        sta bdy
        ; en diagonal la velocidad baja a 3 (x) y 6 (y) (si no, va ~41% mas rapido)
        lda bdx
        beq recta
        lda bdy
        beq recta
        ldx #3
        lda bdx
        bpl dpx
        ldx #$FD        ; -3
dpx     stx bdx
        ldx #6
        lda bdy
        bpl dpy
        ldx #$FA        ; -6
dpy     stx bdy
recta
        lda #1
        sta activa
        lda #0
        sta chispa
        lda #SND_DISPARO
        jsr sonar
pintabala
        ldy by          ; 4 filas de bala_icono (datos.asm), cada una en 2 lineas
        ldx #0          ; cada fila: M1 (izq) + M0 (der), en bloque
bal_pb  lda bala_icono,x
        sta PMG+$300,y  ; M0+M1 comparten estos bytes (bits 1-0 y 3-2)
        sta PMG+$301,y
        iny
        iny
        inx
        cpx #4
        bcc bal_pb
        lda bx
        sta HPOSM1      ; M1 = columna izquierda
        clc
        adc #2
        sta HPOSM0      ; M0 = columna derecha (2 px despues): bala de 4 px
finbala rts

; borra la bala o las chispas (8 lineas de los missiles 0+1)
borrabala
        lda activa
        ora chispa
        beq nobala
        ldy by
        lda #0
        ldx #8
bal_bb  sta PMG+$300,y
        iny
        dex
        bne bal_bb
nobala  rts
