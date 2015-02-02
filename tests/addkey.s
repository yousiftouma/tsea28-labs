start:
	move.l #$7000,a7	; set stack pointer
	jsr clearinput		; call clearinput
	move.b #1,d1
	jsr addkey2		; call addkey
	move.b #2,d1
	jsr addkey2		; call addkey
	move.b #3,d1
	jsr addkey2		; call addkey
	move.b #4,d1
	jsr addkey2		; call addkey	
	move.b #255,d7
	trap #14

;;; Clearinput subroutine;;;
clearinput:
	move.l #$FFFFFFFF,$4000	; reset $4000
	rts

;;; Addkey subroutine ;;;
addkey:
	move.b $4001,$4000
	move.b $4002,$4001
	move.b $4003,$4002
	move.b d1,$4003		; move in new value
	rts
