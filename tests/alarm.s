start:
	move.l #$7000,a7	; set stack pointer
	jsr setupPia		; call setuppia
	jsr activateAlarm	; call activatealarm
	move.l #5000,d6		; set loop var
testloop:
	sub.l #1,d6
	bne testloop
	jsr deactivateAlarm	; call deactivatealarm
	move.b #255,d7
	trap #14

;;; Setuppia subrountine ;;;
setupPia:
	move.b #0,$10084	; choose DDRA
	move.b #1,$10080	; set PIA port A pin 0 to output
	move.b #4,$10084	; choose I/O registry
	move.b #0,$10086	; choose DDRB
	move.b #0,$10082	; set all PIA port B pins to input 
	move.b #4,$10086	; choose I/O registry
	rts

;;; Activatealarm subroutine ;;;
activateAlarm:
	move.b #1,$10080	; set PIAA pin 0 to 1
	rts

;;; Deactivatealarm subroutine ;;;
deactivateAlarm:
	move.b #0,$10080	; set PIAA pin 0 to 0
	rts
