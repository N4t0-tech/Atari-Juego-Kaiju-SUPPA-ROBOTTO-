; sonido.asm - efectos de sonido (POKEY, canal 1)

; mientras sndtim > 0 suena el efecto sndtipo (SND_*, tablas en datos.asm):
; AUDF1 = base + paso * k con k = 0..7 y el volumen decae de 11 a 4
actualizar_sonido
        lda sndtim
        beq silencio
        ldx sndtipo
        lda #8
        sec
        sbc sndtim      ; k = 0..7 segun avanza el efecto
        tay
        lda snd_base,x
snd_k   cpy #0
        beq snd_f
        clc
        adc snd_paso,x
        dey
        jmp snd_k
snd_f   sta AUDF1
        lda sndtim
        clc
        adc #3
        ora snd_dist,x  ; distorsion (tono puro o ruido) + volumen
        sta AUDC1
        dec sndtim
        rts
silencio
        lda #0          ; si no se pone a 0 el tono queda sonando
        sta AUDC1
        rts

; empieza el efecto A (SND_*): 8 frames. Conserva X e Y.
sonar   sta sndtipo
        lda #8
        sta sndtim
        rts
