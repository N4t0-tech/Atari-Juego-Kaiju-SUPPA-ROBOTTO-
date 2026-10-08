; main.asm - punto de entrada y ciclo principal
; Ensamblar: mads main.asm -o:juego.xex
;
; Archivos del proyecto (todos en la misma carpeta):
;   hardware.asm  direcciones del Atari
;   jugador.asm   movimiento, animacion y dibujo del jugador
;   bala.asm      disparo y bala (missiles 0+1)
;   sonido.asm    efectos de sonido
;   hud.asm       HUD de Kaiju: energia, celulas que faltan y puntos
;   nivel.asm     pantallas, nivel de Kaiju y choques con los bloques
;   enemigos.asm  robots enemigos, contactos con el jugador
;   celulas.asm   celulas (objetos a recoger)
;   etapas.asm    titulo, etapas y mensajes
;   datos.asm     variables y graficos del sprite
;   kaiju_*.asm   recursos de Kaiju (graficos, niveles, robots, titulo);
;                 kaiju_titulo.asm va al final: ocupa $6000-$7EAF

        icl "hardware.asm"

        org $2000

start
        jsr iniciar

partida
        jsr titulo
        jsr nueva_partida
etapa_sig
        jsr pantalla_level
        jsr cargar_etapa

loop
        jsr esperar_paso
        jsr mover_jugador
        jsr animar_jugador
        jsr dibujar_jugador
        jsr actualizar_bala
        jsr actualizar_enemigos
        jsr dibujar_celulas
        jsr contactos
        jsr actualizar_sonido
        jsr actualizar_hud
        lda energia
        beq perdio
        lda fin
        bne fallo
        lda celrest
        bne loop
        ; etapa superada
        inc etapa
        lda etapa
        cmp #30
        bne etapa_sig
        lda #<kaiju_txt_super
        ldx #>kaiju_txt_super
        ldy #10
        jsr mensaje
        jmp partida
fallo   ; se disparo a una celula: -1 de energia y se repite la etapa
        dec energia
        beq perdio
        lda #<kaiju_txt_tryagain
        ldx #>kaiju_txt_tryagain
        ldy #15
        jsr mensaje
        jmp etapa_sig
perdio  lda #<kaiju_txt_gameover
        ldx #>kaiju_txt_gameover
        ldy #15
        jsr mensaje
        jmp partida

; espera FRAMES_PASO frames: un paso del juego. El original (cc65) no llegaba
; a dar una vuelta por frame, asi que todo iba a la mitad de velocidad
esperar_paso
        ldx #FRAMES_PASO
ep_fr   jsr esperar_frame
        dex
        bne ep_fr
        inc npaso
        rts

; espera al siguiente frame (sincroniza el juego a 50/60 cuadros por segundo)
esperar_frame
        lda RTCLOK
wait    cmp RTCLOK
        beq wait
        rts

; configura sprites, colores y pantallas (una sola vez)
iniciar
        jsr limpiar_pmg
        jsr iniciar_pantalla
        lda #>PMG
        sta PMBASE
        lda #$3E        ; DMA de jugadores y missiles (1 linea) y de pantalla
        sta SDMCTL
        lda #3
        sta GRACTL
        lda #KAIJU_PCOLR0
        sta PCOLR0      ; cuerpo del robot (kaiju_graficos.asm)
        lda #KAIJU_PCOLR1
        sta PCOLR1      ; contorno del robot
        lda #$31        ; bit 4: missiles con su propio color (COLOR3);
        sta GPRIOR      ; bit 5: P0+P1 se mezclan (3er color del robot)
        lda #$26        ; COLOR3: bala y enemigos (caracteres inversos)
        sta COLOR3
        lda #0          ; fondo negro (COLOR4: fondo y borde en ANTIC 4/E)
        sta COLOR4
        sta HPOSP2      ; P2 y P3 no se usan
        sta HPOSP3
        rts

        icl "jugador.asm"
        icl "bala.asm"
        icl "sonido.asm"
        icl "hud.asm"
        icl "nivel.asm"
        icl "enemigos.asm"
        icl "celulas.asm"
        icl "etapas.asm"
        icl "datos.asm"

        icl "kaiju_graficos.asm"
        icl "kaiju_niveles.asm"
        icl "kaiju_robots.asm"

        ; el titulo se carga en $6000 y $7000 (bloques de 4 KB para ANTIC)
        .if * > $6000
        .error "El programa pasa de $6000: no cabe antes de la imagen de titulo"
        .endif
        icl "kaiju_titulo.asm"

        ; el programa no puede pisar la memoria de los sprites
        .if * > PMG
        .error "El programa pasa de PMG: mover PMG mas arriba en hardware.asm"
        .endif

        run start
