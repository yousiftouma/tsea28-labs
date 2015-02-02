start:
	move.l #$7000,a7	; set stack pointer
	jsr setuppia		; call setuppia
	jsr activatealarm	; call activatealarm
	move.l #5000,d6		; set loop var
testloop:
	sub.l #1,d6
	bne testloop
	jsr deactivatealarm	; call deactivatealarm
	move.b #255,d7
	trap #14

;;; Setuppia subroutine ;;;
setuppia:
	move.b #0,$10084	; choose DDRA
	move.b #1,$10080	; set PIAA pin 0 to output
	move.b #4,$10084	; choose I/O registry
	move.b #0,$10086	; choose DDRB
	move.b #0,$10082	; set all pins to input
	move.b #4,$10086	; choose I/O registry
	rts

;;; Activatealarm subroutine ;;;
activatealarm:
	move.b #1,$10080	; set PIAA pin 0 to 1
	rts

;;; Deactivatealarm subroutine ;;;
deactivatealarm:
	move.b #0,$10080	; set PIAA pin 0 to 0
	rts
