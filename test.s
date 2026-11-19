; Second 6502 lab: addition with carry.
; Read README.md before changing this program.

.segment "DATA"
i_low:       .byte $C1       ; i = $2EC1 (11969)
i_high:      .byte $2E
j_low:       .byte $97       ; j = $1797 (6039)
j_high:      .byte $17

.segment "BSS"
result_low:  .res 1
result_high: .res 1

.segment "CODE"
.export _main

_main:
    lda #$16
    sta $FFCB              ; Enable sim65 tracing

    ; First experiment: what happens when we add 255 and 1?
    lda #255
    clc
    adc #1
    sta result_low

    ; TODO: Replace the four instructions above with a program
    ; that adds the 16-bit numbers i and j.
    ; Add low bytes first, then high bytes.
    ; Store the answer in result_low and result_high.

    lda #0
    sta $FFCB              ; Disable tracing

    ; The Makefile chooses which result byte sim65 returns.
.ifdef RETURN_HIGH
    lda result_high
.else
    lda result_low
.endif
    rts
