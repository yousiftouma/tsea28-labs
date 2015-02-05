start:
	move.l #$7000,a7	; set stack pointer
	jsr getKey		; call getkey
	move.b #255,d7
	trap #14

;;; Getkey subroutine ;;;
getKey:
wait_press:
	btst #4,$10082		; check strobe
	beq wait_press		; jump if not strobe

wait_release:
	btst #4,$10082		; jump if not strobe
	bne wait_release	; jump if strobe
	move.b $10082,d4	; move PIAB to d4
	and.b #15,d4		; isolate key data
	rts
