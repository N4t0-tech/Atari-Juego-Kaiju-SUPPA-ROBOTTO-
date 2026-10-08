; kaiju_titulo.asm - pantalla de titulo de Kaiju ("SUPPA ROBOTTO / PRESS BUTTON")
; Imagen MicroPainter (kaiju_titulo.mic = SUNSET.MIC original): ANTIC modo E,
; 160 x 240 pixeles, 4 colores, 40 bytes por linea; 9600 bytes + 4 de color.
; El juego original solo mostraba las primeras 196 lineas (7840 bytes) y
; debajo una linea de texto en modo 7 (kaiju_txt_muviron + kaiju_txt_soulbattery).
; La imagen cruza un limite de 4 KB: la lista de pantalla necesita un LMS
; nuevo en la linea que empieza en una direccion multiplo de $1000.

KAIJU_TITULO_LINEAS     = 196   ; lineas que mostraba el juego
KAIJU_TITULO_COLOR0     = $C8   ; pixel 01
KAIJU_TITULO_COLOR1     = $DE   ; pixel 10
KAIJU_TITULO_COLOR2     = $CC   ; pixel 11
KAIJU_TITULO_COLOR4     = $00   ; pixel 00 (fondo)

; El juego la usa en dos bloques de 4 KB (una linea de 40 bytes no puede
; cruzar un limite de 4 KB): lineas 0-101 en $6000 y 102-195 en $7000.
; Este archivo va al final de main.asm.
        org $6000
kaiju_titulo1           ins 'kaiju_titulo.mic',0,102*40
        org $7000
kaiju_titulo2           ins 'kaiju_titulo.mic',102*40,94*40
