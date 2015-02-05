start:
	move.l #$7000,a7	; set stack pointer
	move.l #$12345678,$4000	; set aribitary value
	jsr clearInput		; call clearinput
	move.b #255,d7
	trap #14

;;; Clearinput subroutine ;;;
clearInput:
	move.l #$FFFFFFFF,$4000	; reset $4000
	rts
