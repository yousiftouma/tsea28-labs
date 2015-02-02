start:
	move.l #$7000,a7	; set stack pointer
	jsr getkey			; call getkey
	move.b #255,d7
	trap #14

;;; Getkey subroutine ;;;
getkey:
	move.l d0,-(a7)		; throw on stack
	move.l #0,d0		; reset d0
waitkey:
	move.b $10082,d0	; move PIAB tp d+
	and.b #16,d0		; isolate strobe
	beq waitkey			; jump if false

relkey:
	move.b $10082,d0	; move PIAB to d0
	and.b #16,d0		; isolate strobe
	bne relkey			; jump if true
	move.b $10082,d0	; move PIAB to d0
	and.b #15,d0		; isolate key data
	move.l d0,d4		; save result in d4
	
	move.l (a7)+,d0		; restore from stack
	rts
