
start:
	move.l #$7000,a7	; set stack pointer
	move.l #$C126,a4	; set a4
	move.l #16,d5		; set d5
	jsr printString		; call printstring
	move.b #255,d7
	trap #14


;;; Printstring subroutine ;;;
printString:
	move.l d4,-(a7)		; throw on stack
	move.l a4,-(a7)		; throw on stack
	move.l d5,-(a7)		; throw on stack
print_loop:
	move.b (a4)+,d4		; a4 value to d4 and increment
	jsr printChar		; call printchar
	sub.b #1,d5			; increment loop var
	bne print_loop		; loop call

	move.l (a7)+,d5		; restore from stack
	move.l (a7)+,a4		; restore from stack
	move.l (a7)+,d4		; restore from stack
	rts

;;; Printchar subroutine ;;;
printChar:
	move.b d5,-(a7)     ; save d5 on stack
wait_tx:
	move.b $10040,d5    ; status register for serialport
	and.b #2,d5			; isolate bit 1, ready for transmit
	beq wait_tx			; wait until serialport is ready to transmit
	move.b d4,$10042 	; transmit d4
	move.b (a7)+,d5	 	; reset d5
	rts
