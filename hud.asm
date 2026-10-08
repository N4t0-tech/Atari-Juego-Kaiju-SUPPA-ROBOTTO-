; hud.asm - HUD superior al estilo de Kaiju (fila 0, ANTIC 4, fuente de Kaiju)
;
;   columnas 0-9    energia: un icono ($06,$07) por punto (hasta 5)
;   columnas 10-27  una barra ($34) por celula que falta recoger
;   columnas 29-38  puntos: 10 digitos ($0A + digito); los 4 primeros son 0
;                   y los 6 ultimos salen de puntos (BCD)

dibujar_hud
        lda #0
        sta hud_dirty
        ldy #39
hud_clr sta PANTALLA,y
        dey
        bpl hud_clr
        ldx energia     ; iconos de energia
        ldy #0
hud_en  cpx #0
        beq hud_ba
        lda #$06
        sta PANTALLA,y
        iny
        lda #$07
        sta PANTALLA,y
        iny
        dex
        jmp hud_en
hud_ba  ldx celrest     ; barra de celulas
        ldy #10
hud_ba2 cpx #0
        beq hud_pt
        lda #$34
        sta PANTALLA,y
        iny
        dex
        jmp hud_ba2
hud_pt  ldy #29         ; puntos
        lda #$0A
hud_p0  sta PANTALLA,y
        iny
        cpy #33
        bne hud_p0
        ldx #0
hud_dig lda puntos,x
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$0A
        sta PANTALLA,y
        iny
        lda puntos,x
        and #$0F
        clc
        adc #$0A
        sta PANTALLA,y
        iny
        inx
        cpx #3
        bcc hud_dig
        rts

; suma a puntos+X el digito BCD de A ($01-$09 o $10-$90: un solo digito no
; nulo), con acarreo decimal hacia los digitos de mas peso, y pide redibujar
; el HUD. +1: X=2 A=$01; +10: X=2 A=$10; +100: X=1 A=$01. Sin modo decimal
; (SED), para no depender de las interrupciones del OS. Conserva Y.
; 999999 + 1 vuelve a 000000.
sumar_bcd
sp_byte clc
        adc puntos,x
        sta puntos,x
        and #$0F        ; digito bajo > 9?
        cmp #$0A
        bcc sp_alto
        lda puntos,x
        adc #$05        ; C = 1: +6 corrige el digito y lleva 1 al alto
        sta puntos,x
sp_alto lda puntos,x
        cmp #$A0        ; digito alto > 9?
        bcc sp_fin
        sbc #$A0        ; C = 1
        sta puntos,x
        lda #$01        ; acarreo al digito bajo del byte siguiente
        dex
        bpl sp_byte
sp_fin  lda #1
        sta hud_dirty
        rts

; solo redibuja si algo cambio (puntos, energia o celulas ponen hud_dirty=1)
actualizar_hud
        lda hud_dirty
        beq hud_fin
        jsr dibujar_hud
hud_fin rts
