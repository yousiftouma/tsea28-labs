start:
	move.l #$7000,a7	; set stackpointer
	jsr setuppia		; call setuppia
	move.b #255,d7
	trap #14

;;; Setuppia subrountine ;;;
setuppia:
	move.b #0,$10084	; choose DDRA
	move.b #1,$10080	; set PIAA pin 0 to output
	move.b #4,$10084	; choose I/O registry
	move.b #0,$10086	; choose DDRB
	move.b #0,$10082	; set all pins to input
	move.b #4,$10086	; choose I/O registry
	rts
