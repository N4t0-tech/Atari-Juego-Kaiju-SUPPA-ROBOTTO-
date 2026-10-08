; nivel.asm - pantallas (juego, mensajes, titulo), nivel de Kaiju y choques
;
; Pantalla de juego (DLIST): 24 filas de ANTIC 4 (caracteres multicolor) con
; la fuente de Kaiju; la fila 0 es el HUD. Como en el original no hay DLI.
; Coordenadas: la fila r ocupa las lineas 32+8r a 39+8r y la columna c los
; HPOS 48+4c a 51+4c (un caracter de ANTIC 4 = 4 x 8).
; Titulo (DLIST_T): imagen de Kaiju en ANTIC E (196 lineas, en dos bloques de
; 4 KB, kaiju_titulo.asm) y una linea de texto en ANTIC 7.

; arma la fuente y las dos listas de pantalla
iniciar_pantalla
        ; fuente: la de la ROM y encima los 57 caracteres de Kaiju (codigos 2-58)
        ldx #0
fnt_rom lda FUENTE_ROM,x
        sta FUENTE,x
        lda FUENTE_ROM+$100,x
        sta FUENTE+$100,x
        lda FUENTE_ROM+$200,x
        sta FUENTE+$200,x
        lda FUENTE_ROM+$300,x
        sta FUENTE+$300,x
        inx
        bne fnt_rom
fnt_k1  lda kaiju_fuente,x       ; primeros 256 bytes (X vale 0)
        sta FUENTE+$10,x
        inx
        bne fnt_k1
fnt_k2  lda kaiju_fuente+$100,x  ; los 200 restantes (57 x 8 = 456)
        sta FUENTE+$110,x
        inx
        cpx #200
        bne fnt_k2

        ; lista de pantalla del juego
        ldx #dl_fin-dl_datos-1
cp_dl   lda dl_datos,x
        sta DLIST,x
        dex
        bpl cp_dl

        ; lista del titulo: 24 en blanco, 102 lineas desde kaiju_titulo1, 94
        ; desde kaiju_titulo2 (ANTIC no cruza 4 KB sin otro LMS), texto, salto
        lda #$70
        sta DLIST_T
        sta DLIST_T+1
        sta DLIST_T+2
        lda #$4E
        sta DLIST_T+3
        lda #<kaiju_titulo1
        sta DLIST_T+4
        lda #>kaiju_titulo1
        sta DLIST_T+5
        ldx #6
        ldy #101
        lda #$0E
dlt_1   sta DLIST_T,x
        inx
        dey
        bne dlt_1
        lda #$4E
        sta DLIST_T,x
        lda #<kaiju_titulo2
        sta DLIST_T+1,x
        lda #>kaiju_titulo2
        sta DLIST_T+2,x
        inx
        inx
        inx
        ldy #93
        lda #$0E
dlt_2   sta DLIST_T,x
        inx
        dey
        bne dlt_2
        lda #$47        ; ANTIC 7 + LMS: "MUVIRON  SOULBATTERY"
        sta DLIST_T,x
        .if DEBUG       ; o el selector de nivel
        lda #<txt_debug
        sta DLIST_T+1,x
        lda #>txt_debug
        .else
        lda #<kaiju_txt_titulo
        sta DLIST_T+1,x
        lda #>kaiju_txt_titulo
        .endif
        sta DLIST_T+2,x
        lda #$41
        sta DLIST_T+3,x
        lda #<DLIST_T
        sta DLIST_T+4,x
        lda #>DLIST_T
        sta DLIST_T+5,x
        rts

; pone la lista de pantalla A (bajo) / X (alto) justo despues de un VBI, para
; que el OS no copie una direccion a medias
poner_dl
        pha
        jsr esperar_frame
        pla
        sta SDLSTL
        stx SDLSTH
        rts

; colores de la pantalla de juego (los bloques de Kaiju)
colores_juego
        lda #KAIJU_COLOR0
        sta COLOR0
        lda #KAIJU_COLOR1
        sta COLOR1
        lda #KAIJU_COLOR2
        sta COLOR2
        rts

; pantalla de juego: fuente de Kaiju
modo_juego
        lda #<DLIST
        ldx #>DLIST
        jsr poner_dl
        lda #>FUENTE
        sta CHBAS
        jmp colores_juego

; pantalla de mensajes: la misma con la fuente de pagina A, sin sprites ni sonido
modo_texto
        pha
        jsr limpiar_pmg
        lda #0
        sta sndtim
        sta AUDC1
        lda #<DLIST
        ldx #>DLIST
        jsr poner_dl
        pla
        sta CHBAS
        jmp colores_juego

; pantalla de titulo
modo_titulo
        jsr limpiar_pmg
        lda #<DLIST_T
        ldx #>DLIST_T
        jsr poner_dl
        lda #>FUENTE_ROM        ; para la linea de texto
        sta CHBAS
        lda #KAIJU_TITULO_COLOR0
        sta COLOR0
        lda #KAIJU_TITULO_COLOR1
        sta COLOR1
        lda #KAIJU_TITULO_COLOR2
        sta COLOR2
        rts

; borra los 2 KB de los sprites (jugador, bala, todo)
limpiar_pmg
        lda #0
        sta activa
        tax
lpm     sta PMG,x
        sta PMG+$100,x
        sta PMG+$200,x
        sta PMG+$300,x
        sta PMG+$400,x
        sta PMG+$500,x
        sta PMG+$600,x
        sta PMG+$700,x
        inx
        bne lpm
        rts

; borra las 24 filas de la pantalla (960 bytes)
limpiar_pantalla
        lda #0
        tax
lpa     sta PANTALLA,x
        sta PANTALLA+$100,x
        sta PANTALLA+$200,x
        cpx #960-$300
        bcs lpa_s
        sta PANTALLA+$300,x
lpa_s   inx
        bne lpa
        rts

; copia el nivel «nivel» (0-5) a las filas 1-23 y pone al jugador en su inicio
dibujar_nivel
        lda nivel
        asl
        tax
        lda kaiju_niveles,x
        sta ptr
        lda kaiju_niveles+1,x
        sta ptr+1
        ldy #0          ; 2 bytes de cabecera: inicio del jugador
        lda (ptr),y
        sta px
        iny
        lda (ptr),y
        sta py
        lda ptr         ; saltar la cabecera
        clc
        adc #2
        sta ptr
        bcc niv_nc
        inc ptr+1
niv_nc  lda #<(PANTALLA+40)
        sta ptr2
        lda #>(PANTALLA+40)
        sta ptr2+1
        ldx #3          ; 920 bytes = 3 paginas + 152
        ldy #0
niv_pag lda (ptr),y
        sta (ptr2),y
        iny
        bne niv_pag
        inc ptr+1
        inc ptr2+1
        dex
        bne niv_pag
niv_res lda (ptr),y
        sta (ptr2),y
        iny
        cpy #152
        bne niv_res
        rts

; caja del robot en (px, py), en filas fil0-fil1 y columnas col0-col1: las 8
; columnas del sprite y sus lineas 2-21 (las filas 0-1 y 22-23 estan vacias)
caja_jugador
        lda py
        clc
        adc #2-32
        lsr
        lsr
        lsr
        sta fil0
        lda py
        clc
        adc #21-32
        lsr
        lsr
        lsr
        sta fil1
        lda px
        sec
        sbc #48
        lsr
        lsr
        sta col0
        lda px
        clc
        adc #7-48
        lsr
        lsr
        sta col1
        rts

; C = 1 si el robot en (px, py) toca algun bloque, con A = ese caracter.
; Las celulas ($14-$1B) y los enemigos ($1C-$33, tambien en inverso) se
; atraviesan: tocarlos lo resuelve contactos (enemigos.asm).
choca
        jsr caja_jugador
ch_fila ldx fil0
        lda filas_lo,x
        sta ptr2
        lda filas_hi,x
        sta ptr2+1
        ldy col0
ch_col  lda (ptr2),y
        beq ch_sig
        and #$7F
        cmp #$14
        bcc ch_si       ; 1-$13: bloque
        cmp #$34
        bcc ch_sig      ; $14-$33: celula o enemigo
ch_si   lda (ptr2),y
        sec
        rts
ch_sig  cpy col1        ; C = 0 mientras falten columnas (INY no toca C)
        iny
        bcc ch_col
        lda fil0
        cmp fil1
        inc fil0
        bcc ch_fila
        clc
        rts

; C = 1 si la casilla de la linea A y el HPOS X tiene algo. Devuelve A = el
; caracter, bfil/bcol = la casilla y ptr2/Y apuntando a ella (para romperla)
bloque_en
        sec
        sbc #32
        lsr
        lsr
        lsr
        sta bfil
        tay
        lda filas_lo,y
        sta ptr2
        lda filas_hi,y
        sta ptr2+1
        txa
        sec
        sbc #48
        lsr
        lsr
        sta bcol
        tay
        lda (ptr2),y
        cmp #1          ; C = 1 si no es 0
        rts
