start:
	move.l #$7000,a7	; set stack pointer
	jsr clearInput		; call clearinput
	move.b #1,d1
	jsr addKey		; call addkey
	move.b #2,d1
	jsr addKey		; call addkey
	move.b #3,d1
	jsr addKey		; call addkey
	move.b #4,d1
	jsr addKey		; call addkey	
	move.b #255,d7
	trap #14

;;; Clearinput subroutine ;;;
clearInput:
	move.l #$FFFFFFFF,$4000	; reset $4000
	rts

;;; Addkey subroutine ;;;
addKey:
	move.l a0,-(a7)		; throw on stack
	move.b d0,-(a7)		; throw on stack
	move.l $4000,a0		; oldest key
	move.b #2,d0		; init loop var
add_key_loop:
	move.b 1(a0),(a0)+	; shift a0 + 1 to a0
	sub.b #1,d0
	bne add_key_loop

	move.b d1,$4003		; move in new value
	move.l (a7)+,d0		; restore from stack
	move.l (a7)+,a0		; restore from stack
	rts