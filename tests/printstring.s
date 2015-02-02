
start:
	move.l #$7000,a7	; set stack pointer
	move.l #$C126,a4	; set a4
	move.l #16,d5		; set d5
	jsr printstring		; call printstring
	move.b #255,d7
	trap #14


;;; Printstring subroutine ;;;
printstring:
printloop:
	move.b (a4)+,d4		; a4 value to d4 and increment
	jsr printchar		; call printchar
	sub.b #1,d5		; increment loop var
	bne printloop		; loop call
	move.b #$0A,d4		; new line
	jsr printchar
	rts

;;; Printchar subroutine ;;;
printchar:
	move.b d5,-(a7)         ; save d5 on stack
waittx:

	move.b $10040,d5        ; status register for serialport
	and.b #2,d5		; isolate bit 1, ready for transmit
	beq waittx		; wait until serialport is ready to transmit
	move.b d4,$10042 	; transmit d4
	move.b (a7)+,d5	 	; reset d5
	rts
