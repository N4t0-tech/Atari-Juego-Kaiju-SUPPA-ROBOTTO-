; jugador.asm - movimiento, animacion y dibujo del jugador (Player 0 + 1)
; El jugador es el robot de Kaiju: poses de 8 x 24 a resolucion de 1 linea
; (kaiju_graficos.asm), P0 = cuerpo y P1 = contorno, mezclados (GPRIOR $31).

; lee el joystick y mueve al jugador: limites, freno en diagonal y choques
; con los bloques del nivel (primero en horizontal y luego en vertical, asi
; se desliza a lo largo de una pared)
mover_jugador
        jsr borrar_jugador      ; borrar sprite en la posicion vieja

        lda px          ; guardar posicion para deshacer el movimiento
        sta oldx
        lda py
        sta oldy

        ; si hay alguna direccion, se recalcula hacia donde mira (ddx, ddy)
        lda STICK0
        and #$0F
        cmp #$0F
        beq nodir
        lda #0
        sta ddx
        sta ddy
nodir
        ; leer joystick (bits 0=arriba 1=abajo 2=izq 3=der) y pedir movimiento
        lda #0
        sta mvx
        sta mvy
        lda STICK0
        lsr
        bcs noup
        ldx #$FE        ; vertical: 2 lineas por frame (PMG a 1 linea)
        stx mvy
        ldx #$FC        ; -4
        stx ddy
noup    lsr
        bcs nodown
        ldx #2
        stx mvy
        ldx #4
        stx ddy
nodown  lsr
        bcs noleft
        ldx #$FF
        stx mvx
        ldx #$FC        ; -4
        stx ddx
noleft  lsr
        bcs noright
        ldx #1
        stx mvx
        ldx #4
        stx ddx
noright

        ; diagonal: solo avanza 3 de cada 4 pasos (si no, va ~41% mas rapido);
        ; en el paso frenado no se mueve y andando queda como estaba (npaso y
        ; no RTCLOK: con 2 frames por paso RTCLOK & 3 frenaria 1 de cada 2)
        lda mvx
        beq nofreno
        lda mvy
        beq nofreno
        lda npaso
        and #3
        bne nofreno
        rts
nofreno

        ; horizontal: 50 <= px <= 200, y deshacer si choca con un bloque
        lda px
        clc
        adc mvx
        cmp #50
        bcs okleft
        lda #50
okleft  cmp #201
        bcc okright
        lda #200
okright sta px
        jsr choca
        bcc okx
        jsr borde_hiere
        lda oldx
        sta px
okx
        ; vertical: 40 <= py <= 198 (el borde del nivel ya impide llegar al HUD)
        lda py
        clc
        adc mvy
        cmp #40
        bcs okmin
        lda #40
okmin   cmp #199
        bcc okmax
        lda #198
okmax   sta py
        jsr choca
        bcc oky
        jsr borde_hiere
        lda oldy
        sta py
oky

        ; andando = 1 si la posicion cambio (contra un bloque no hay animacion)
        lda #0
        sta andando
        lda px
        cmp oldx
        bne semovio
        lda py
        cmp oldy
        beq finmov
semovio inc andando
finmov  rts

; choca devolvio en A el bloque: el borde verde (2 y 3) quita energia
borde_hiere
        cmp #2
        bcc bh_fin
        cmp #4
        bcs bh_fin
        jmp herir
bh_fin  rts

; animacion: al caminar alterna paso A y B cada 5 frames (como Kaiju).
; Elige la pose (POSE_*, datos.asm) y si se dibuja espejada (espejo = $80).
animar_jugador
        lda #0
        sta espejo
        lda andando
        bne caminando
        sta tick        ; quieto: A = 0
        sta paso
        lda ddx         ; mira a la izquierda o a la derecha
        bmi q_izq
        lda #POSE_QUIETO_DER
        sta pose
        rts
q_izq   lda #POSE_QUIETO_IZQ
        sta pose
        rts
caminando
        inc tick
        lda tick
        cmp #5
        bcc elegir
        lda #0
        sta tick
        lda paso
        eor #1
        sta paso
elegir
        lda ddx         ; solo hacia arriba (sin horizontal): de espaldas
        bne de_lado
        lda ddy
        bpl de_lado
        lda #POSE_ARRIBA_A
        jmp sumapaso
de_lado lda ddx
        bpl a_der
        lda #$80        ; caminando a la izquierda: pasos espejados
        sta espejo
a_der   lda #POSE_CAMINA_A
sumapaso
        clc
        adc paso        ; paso 0 = A, 1 = B (la pose B va justo despues)
        sta pose
        rts

; borra las 24 lineas del robot (Player 0 y Player 1) en la posicion actual
borrar_jugador
        ldx py
        ldy #24
        lda #0
er      sta PMG+$400,x
        sta PMG+$500,x
        inx
        dey
        bne er
        rts

; dibuja la pose actual: 24 filas de P0 (cuerpo) y P1 (contorno, guardado
; 24 bytes despues), espejadas con revtab si espejo = $80, y fija la columna
dibujar_jugador
        ldx pose
        lda poses_lo,x
        sta ptr
        lda poses_hi,x
        sta ptr+1
        ldx py
        ldy #0
dj      lda (ptr),y     ; fila de P0
        jsr espejar
        sta PMG+$400,x
        tya
        clc
        adc #24
        tay
        lda (ptr),y     ; misma fila de P1
        jsr espejar
        sta PMG+$500,x
        tya
        sec
        sbc #23         ; siguiente fila de P0
        tay
        inx
        cpy #24
        bne dj
        lda px
        sta HPOSP0
        sta HPOSP1
        rts

; si espejo = $80 invierte los bits de A (revtab); conserva X e Y
espejar bit espejo
        bpl esp_fin
        stx tmp
        tax
        lda revtab,x
        ldx tmp
esp_fin rts
