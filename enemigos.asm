; enemigos.asm - robots enemigos de Kaiju (datos de kaiju_robots.asm)
;
; Cada robot son 2 x 2 caracteres de la pantalla (no sprites), en la casilla
; rob_x/rob_y. Se actualizan cada 11 frames y avanzan una casilla cada 2
; actualizaciones (como en el original). Patrullan con rob_dira la primera
; mitad del recorrido y rob_dirb la segunda; cuando el jugador entra en su
; zona de vigilancia pasan a perseguirlo. Caracteres: rob_clase + 0/4
; (mirando a la izquierda, direcciones 0-3) o + $10/$14 (4-8), alternando.

; carga los robots y las celulas de la etapa «etapa» (DAT de kaiju_robots.asm)
cargar_robots
        lda etapa
        asl
        tax
        lda kaiju_dats,x
        sta ptr
        lda kaiju_dats+1,x
        sta ptr+1
        ldy #0
        lda (ptr),y
        sta nrob
        iny
        lda (ptr),y
        sta ncel
        sta celrest
        lda #1          ; vida segun la etapa: 1, desde la 6 = 2, desde la 18 = 3
        ldx etapa
        cpx #6
        bcc cr_vida
        lda #2
        cpx #18
        bcc cr_vida
        lda #3
cr_vida sta tmp3
        lda ptr         ; saltar la cabecera (2 bytes)
        clc
        adc #2
        sta ptr
        bcc cr_n1
        inc ptr+1
cr_n1   ldx #0
cr_rob  cpx nrob
        bcs cr_cel
        ldy #0          ; registro de 16 bytes (ver kaiju_robots.asm)
        lda (ptr),y
        sta rob_x,x
        iny
        lda (ptr),y
        sta rob_y,x
        ldy #5
        lda (ptr),y
        sta rob_dira,x
        sta rob_dir,x
        iny
        lda (ptr),y
        sta rob_dirb,x
        iny
        lda (ptr),y
        sta rob_pasos,x
        ldy #9
        lda (ptr),y
        sta rob_clase,x
        ldy #12
        lda (ptr),y
        sta rob_zy0,x
        iny
        lda (ptr),y
        sta rob_zy1,x
        iny
        lda (ptr),y
        sta rob_zx0,x
        iny
        lda (ptr),y
        sta rob_zx1,x
        lda #0
        sta rob_paso,x
        sta rob_fase,x
        lda #1
        sta rob_estado,x
        lda tmp3
        sta rob_vida,x
        lda ptr
        clc
        adc #16
        sta ptr
        bcc cr_n2
        inc ptr+1
cr_n2   inx
        jmp cr_rob
cr_cel  ldx #0          ; celulas: pares (x, y)
        ldy #0
cr_c2   cpx ncel
        bcs cr_dib
        lda (ptr),y
        sta cel_x,x
        iny
        lda (ptr),y
        sta cel_y,x
        iny
        lda #1
        sta cel_viva,x
        inx
        jmp cr_c2
cr_dib  ldx #0          ; dibujar los robots
cr_d2   cpx nrob
        bcs cr_fin
        jsr dibujar_robot
        inx
        jmp cr_d2
cr_fin  rts

; ptr2 = direccion en pantalla de la casilla del robot X. Conserva X.
dir_robot
        ldy rob_y,x
        lda filas_lo,y
        clc
        adc rob_x,x
        sta ptr2
        lda filas_hi,y
        adc #0
        sta ptr2+1
        rts

; escribe A, A+1 en ptr2 y A+2, A+3 en la fila de abajo
poner2x2
        ldy #0
        sta (ptr2),y
        clc
        adc #1
        iny
        sta (ptr2),y
        adc #1
        ldy #40
        sta (ptr2),y
        adc #1
        iny
        sta (ptr2),y
        rts

; borra los 2 x 2 caracteres de ptr2
borrar2x2
        lda #0
        ldy #0
        sta (ptr2),y
        iny
        sta (ptr2),y
        ldy #40
        sta (ptr2),y
        iny
        sta (ptr2),y
        rts

; Z = 1 si los 2 x 2 caracteres de ptr2 estan vacios
libre2x2
        ldy #0
        lda (ptr2),y
        iny
        ora (ptr2),y
        ldy #40
        ora (ptr2),y
        iny
        ora (ptr2),y
        rts

; dibuja el robot X segun su direccion y su fase
dibujar_robot
        jsr dir_robot
        lda rob_dir,x
        cmp #4          ; 0-3: mirando a la izquierda; 4-8: a la derecha
        lda rob_clase,x
        bcc dr_fase
        clc
        adc #$10
dr_fase ldy rob_fase,x
        beq dr_pon
        clc
        adc #4
dr_pon  jmp poner2x2

; casilla del centro del jugador en pcx, pcy
centro_jugador
        lda px
        clc
        adc #4-48
        lsr
        lsr
        sta pcx
        lda py
        clc
        adc #12-32
        lsr
        lsr
        lsr
        sta pcy
        rts

; cada 11 frames: decidir la direccion de cada robot, moverlo y redibujarlo
actualizar_enemigos
        dec cnt11
        beq ae_ya
        rts
ae_ya   lda #11
        sta cnt11
        jsr centro_jugador
        ldx #0
ae_rob  cpx nrob
        bcc ae_uno
        rts
ae_uno  lda rob_dir,x
        cmp #9
        bne ae_vivo
        jmp ae_sig
ae_vivo
        ; zona de vigilancia: si el jugador esta dentro, a perseguirlo
        lda pcx
        cmp rob_zx0,x
        bcc ae_nozona
        lda rob_zx1,x
        cmp pcx
        bcc ae_nozona
        lda pcy
        cmp rob_zy0,x
        bcc ae_nozona
        lda rob_zy1,x
        cmp pcy
        bcc ae_nozona
        lda #2
        sta rob_estado,x
ae_nozona
        lda rob_estado,x
        cmp #2
        bne ae_patr
        jsr hacia_jugador
        sta rob_dir,x
        jmp ae_mover
ae_patr lda rob_pasos,x ; patrulla: dira si paso < pasos/2, si no dirb
        beq ae_mover    ; sin recorrido: sigue en su direccion
        lsr
        sta tmp3
        lda rob_paso,x
        cmp tmp3
        bcs ae_db
        lda rob_dira,x
        jmp ae_pd
ae_db   lda rob_dirb,x
ae_pd   sta rob_dir,x
        inc rob_paso,x
        lda rob_paso,x
        cmp rob_pasos,x
        bcc ae_mover
        lda #0
        sta rob_paso,x
ae_mover
        jsr dir_robot   ; borrar, y avanzar una casilla cuando la fase vuelve a 0
        jsr borrar2x2
        lda rob_fase,x
        eor #1
        sta rob_fase,x
        bne ae_dib
        ldy rob_dir,x
        lda rob_x,x
        sta ox_r
        clc
        adc dir_dx,y
        sta rob_x,x
        lda rob_y,x
        sta oy_r
        clc
        adc dir_dy,y
        sta rob_y,x
        jsr dir_robot
        jsr libre2x2    ; solo entra en casillas vacias
        beq ae_dib
        lda ox_r
        sta rob_x,x
        lda oy_r
        sta rob_y,x
ae_dib  jsr dibujar_robot
ae_sig  inx
        jmp ae_rob

; A = direccion hacia el jugador para el robot X (tabla persigue)
hacia_jugador
        ldy #1          ; columna: 0 si pcx < x, 2 si pcx > x+1, 1 si no
        lda pcx
        cmp rob_x,x
        bcs hj_x1
        ldy #0
        jmp hj_x2
hj_x1   lda rob_x,x
        clc
        adc #1
        cmp pcx
        bcs hj_x2
        ldy #2
hj_x2   sty tmp3
        ldy #3          ; fila: 0 si pcy < y, 6 si pcy > y+1, 3 si no
        lda pcy
        cmp rob_y,x
        bcs hj_y1
        ldy #0
        jmp hj_y2
hj_y1   lda rob_y,x
        clc
        adc #1
        cmp pcy
        bcs hj_y2
        ldy #6
hj_y2   tya
        clc
        adc tmp3
        tay
        lda persigue,y
        rts

; C = 1 si los 2 x 2 de la casilla (A = x, Y = y) se solapan con la caja del
; jugador (col0-col1, fil0-fil1)
toca_caja
        sta tmp3
        cmp col1        ; x <= col1
        beq tc_x
        bcs tc_no
tc_x    clc
        adc #1          ; x+1 >= col0
        cmp col0
        bcc tc_no
        tya             ; y <= fil1
        cmp fil1
        beq tc_y
        bcs tc_no
tc_y    clc
        adc #1          ; y+1 >= fil0
        cmp fil0
        bcc tc_no
        sec
        rts
tc_no   clc
        rts

; la bala toco la casilla bcol/bfil de un enemigo: le quita vida y, si llega
; a 0, lo borra y suma 10 puntos
golpear_enemigo
        ldx #0
ge_rob  cpx nrob
        bcs ge_fin
        lda rob_dir,x
        cmp #9
        beq ge_sig
        lda bcol        ; bcol en x..x+1 y bfil en y..y+1
        sec
        sbc rob_x,x
        cmp #2
        bcs ge_sig
        lda bfil
        sec
        sbc rob_y,x
        cmp #2
        bcs ge_sig
        dec rob_vida,x
        bne ge_fin
        lda #9          ; destruido
        sta rob_dir,x
        jsr dir_robot
        jsr borrar2x2
        ldx #2
        lda #$10
        jsr sumar_bcd
        lda #SND_GOLPE
        jmp sonar
ge_sig  inx
        jmp ge_rob
ge_fin  rts

; cada frame: celulas que toca el jugador (se recogen) y enemigos que lo
; tocan (le quitan energia, con 50 frames de invulnerabilidad)
contactos
        lda invul
        beq ct_cel
        dec invul
ct_cel  jsr caja_jugador
        ldx #0
ct_c2   cpx ncel
        bcs ct_rob
        lda cel_viva,x
        beq ct_cs
        ldy cel_y,x
        lda cel_x,x
        jsr toca_caja
        bcc ct_cs
        jsr recoger_celula
ct_cs   inx
        jmp ct_c2
ct_rob  ldx #0
ct_r2   cpx nrob
        bcs ct_fin
        lda rob_dir,x
        cmp #9
        beq ct_rs
        ldy rob_y,x
        lda rob_x,x
        jsr toca_caja
        bcc ct_rs
        jsr herir
ct_rs   inx
        jmp ct_r2
ct_fin  rts

; el jugador recibe un golpe: -1 de energia si no esta invulnerable.
; Conserva X e Y.
herir   lda invul
        bne he_fin
        lda energia
        beq he_fin
        dec energia
        lda #50
        sta invul
        lda #1
        sta hud_dirty
        lda #SND_GOLPE
        jmp sonar
he_fin  rts
