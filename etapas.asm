; etapas.asm - flujo de la partida (como en Kaiju): titulo, «LEVEL m-n», 30
; etapas (5 mundos x 6 mapas) y los mensajes de fin
;
; Etapa e: mapa LEVEL(e%6 + 1) y robots/celulas DAT(e). Se supera al recoger
; todas las celulas. Disparar a una celula cuesta 1 de energia y repite la
; etapa («TRY AGAIN»); sin energia, «GAME OVER». Tras la 30, «YOU ARE SUPER
; PLAYER». La energia y los puntos pasan de una etapa a la siguiente.

nueva_partida
        lda #0
        sta etapa
        sta puntos
        sta puntos+1
        sta puntos+2
        lda #5
        sta energia
        rts

; imagen de titulo hasta que se aprieta el boton (hay que soltarlo antes)
titulo
        jsr modo_titulo
tit_suelta
        jsr esperar_frame
        lda STRIG0
        beq tit_suelta
tit_espera
        jsr esperar_frame
        lda STRIG0
        bne tit_espera
        rts

; «LEVEL m-n» en el centro durante 2 segundos, con la fuente de Kaiju
pantalla_level
        jsr limpiar_pantalla
        ldx #4
pl_txt  lda txt_level,x
        sta PANTALLA+11*40+15,x
        dex
        bpl pl_txt
        lda etapa       ; m = etapa/6 + 1, n = etapa%6 + 1
        ldx #0
pl_div  cmp #6
        bcc pl_res
        sbc #6
        inx
        jmp pl_div
pl_res  clc
        adc #$0B        ; digito n ($0A = '0')
        sta PANTALLA+11*40+23
        txa
        clc
        adc #$0B
        sta PANTALLA+11*40+21
        lda #$2B        ; '-'
        sta PANTALLA+11*40+22
        lda #>FUENTE
        jsr modo_texto
        ldx #120
        jmp esperar_n

; mensaje A (bajo) / X (alto) de kaiju_graficos.asm (terminado en $FF) en la
; fila 11 desde la columna Y, con la fuente de la ROM, durante 3 segundos
mensaje
        sta ptr
        stx ptr+1
        sty tmp3
        jsr limpiar_pantalla
        lda #<(PANTALLA+11*40)
        clc
        adc tmp3
        sta ptr2
        lda #>(PANTALLA+11*40)
        adc #0
        sta ptr2+1
        ldy #0
ms_car  lda (ptr),y
        cmp #$FF
        beq ms_fin
        sta (ptr2),y
        iny
        bne ms_car
ms_fin  lda #>FUENTE_ROM
        jsr modo_texto
        ldx #180
        ; sigue en esperar_n

; espera X frames
esperar_n
        jsr esperar_frame
        dex
        bne esperar_n
        rts

; arma la etapa «etapa»: mapa, robots, celulas, HUD y jugador
cargar_etapa
        jsr limpiar_pmg
        lda etapa       ; mapa = etapa % 6
pe_mod  cmp #6
        bcc pe_niv
        sbc #6
        jmp pe_mod
pe_niv  sta nivel
        jsr limpiar_pantalla
        jsr dibujar_nivel
        lda #0
        sta fin
        sta invul
        sta cuenta
        sta ddy
        lda #4          ; mirando a la derecha
        sta ddx
        lda #11
        sta cnt11
        jsr cargar_robots
        jsr pintar_celulas
        jsr dibujar_hud
        jsr modo_juego
        jsr animar_jugador
        jmp dibujar_jugador
