setup:
	move.l #$7000,a7	; set stack pointer
	; Correct code ;
	move.l #$03050801,$4000

	jsr setupPia		; setup PIAA, PIAB
	jsr setupErrorString

start_program:
	jsr clearInput		; clear input buffer
	jsr deactivateAlarm

wait_activation:
	jsr getKey
	cmp.b #$A,d4		; wait for A to be pressed
	bne wait_activation
	jsr activateAlarm

wait_input:
	jsr getKey
	move.l #$0,d2		; reset d2

check_numeric:
	move.b d4,d2		; so not to mod d4
	sub.b #10,d2
	bmi wait_confirm	; jump if negative
	jsr addKey 			; add key to buffer
	bra wait_input		; wait for next key

wait_confirm:
	cmp.b #$F,d4		; wait for F to be pressed
	bne wait_input		; incorrect input
	jsr checkCode		; check if code is correct
	cmp.b #1,d4
	beq start_program	; restart program
	jsr incrementCounter
	jsr printString		; write error code
	bra wait_input		; else wait for next key

	move.b #255,d7
	trap #14


;;; ;;; Subroutines ;;; ;;;

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

;;; Clearinput subroutine ;;;
clearInput:
	move.l #$FFFFFFFF,$4000	; reset $4000
	rts

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

;;; Setup error string subroutine ;;;
setupErrorString:
	; 'Felaktig kod!' ;
	move.l #$46656C61,$4020
	move.l #$6B746967,$4024
	move.l #$206B6F64,$4028

	move.w #$2120,$402C
	move.b #$30,$402E
	move.b #$30,$402F
	move.w #$0A0D,$4030 ; new line and cr

	move.l #18,d5		; string len
	move.l #$4020,a4	; string pos
	rts

;;; Increment counter ;;;
incrementCounter:
	move.l d5,-(a7)	; throw on stack
	move.l d6,-(a7)	; throw on stack

	move.b $402E,d5
	move.b $402F,d6

	cmp.b #$39,d6	; if unit = 9
	beq increment_ten
	add.b #$1,d6	; inrcrement unit
	bra increment_end

increment_ten:
	move.b #$30,d6	; reset unit
	add.b #$1,d5	; increment ten

increment_end:
	move.b d5,$402E
	move.b d6,$402F
	move.l (a7)+,d6	; restore from stack
	move.l (a7)+,d5	; restore from stack
	rts
	