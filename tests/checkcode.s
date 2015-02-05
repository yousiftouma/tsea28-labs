start:
	move.l #$7000,a7 ; set stack pointer
	move.l #0,d4	 ; reset d4
	move.l #$12ABCDEF,$4000 ; set input code
	move.l #$12ABCDEF,$4010 ; set stored code

	jsr checkcode	; call checkcode
	move.b #255,d7
	trap #14

;;; Checkcode subroutine ;;;
checkCode:
	move.l #1,d4		; set default value
	move.l d5,-(a7)		; throw on stack
	move.l d6,-(a7)		; throw on stack
	move.l $4000,d5		; point to input code
	move.l $4010,d6		; point to stored code
	
	cmp.l d5,d6			; compare pointers
	bne false_code		; false, jump
	bra end_code			; jump to end
false_code:
	move.l #0,d4		; set d4 (false)
end_code:
	move.l (a7)+,d6		; restore from stack
	move.l (a7)+,d5		; restore from stack
	rts
