
start:
	move.l #$7000,a7	; set stack pointer
	jsr setuppia		; setup PIAA, PIAB

	; 'Felaktig kod!' ;
	move.l #$46656C61,$5000
	move.l #$6B746967,$5004
	move.l #$206B6F64,$5008
	move.b #$21,$500C
	move.l #13,d5		; string len
	move.l #$5000,a4	; string pos
	

restart:
	jsr clearinput		; clear input buffer
	jsr deactivatealarm

waitactivate:
	jsr getkey
	cmp.b #$41,d4		; wait for A to be pressed
	bne waitactivate

	jsr activatealarm

	move.l #0,d1		; reset d1
	move.l #$30,d2		; set d2 to first ASCII numeric

waitinput:
	jsr getkey
	move.b #10,d1		; init lopp var

checkkey:			; Checks whether key is numeric
	cmp.b d2,d4
	beq addkeyif		; if numeric
	add.b #1,d2		; next ASCII numeric
	sub.b #1,d1		; inrement loop var
	bne checkkey
	bra waitforcode		; if false check if F

addkeyif:
	jsr addkey		; add keypressed
	bra waitinput		; next key

waitforcode:
	cmp.b #$46,d4		; wait fpr F tp ne pressed
	bne waitinput		; incorrect input
	jsr checkcode		; check if code is correct
	cmp.b #1,d4
	beq restart		; jump and deactivate alarm
	jsr printstring		; write 'Fel kod'
	bra waitinput		; else wait for next key

	move.b #255,d7
	trap #14


;;; ;;; Subroutines ;;; ;;;

;;; Setuppia subrountine ;;;
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

;;; Clearinput subroutine ;;;
clearinput:
	move.l #$FFFFFFFF,$4000	; reset $4000
	rts

;;; Getkey subroutine ;;;
getkey:
waitkey:
	btst #4,$10082		; check strobe
	beq waitkey		; jump if not strobe

relkey:
	btst #4,$10082		; jump if not strobe
	bne relkey		; jump if strobe
	move.b $10082,d4	; move PIAB to d4
	and.b #15,d4		; isolate key data
	rts

;;; Addkey subroutine ;;;
addkey:
	move.l a0,-(a7)		; throw on stack
	move.b d0,-(a7)		; throw on stack
	move.l $4000,a0		; oldest key
	move.b #2,d0		; init loop var
addkeyloop:
	move.b 1(a0),(a0)+	; shift a0 + 1 to a0
	sub.b #1,d0
	bne addkeyloop
	move.b d1,$4003		; move in new value
	rts
	
;;; Checkcode subroutine ;;;
checkcode:
	move.l #1,d4		; set default val
	move.l d5,-(a7)		; throw on stack
	move.l d6,-(a7)		; throw on stack
	move.l $4000,d5		; point to input code
	move.l $4010,d6		; point to stored code
	
	cmp.l d5,d6		; compare pointers
	bne falsecode		; false, jump
	bra endcode		; jump to end
falsecode:
	move.l #0,d4		; set d4 (false)
endcode:
	move.l (a7)+,d6		; restore from stack
	move.l (a7)+,d5		; restore from stack
	rts

;;; Printstring subroutine ;;;
printstring:
	move.l d4,-(a7)		; throw on stack
	move.l a4,-(a7)		; throw on stack
	move.l d5,-(a7)		; throw on stack
printloop:
	move.b (a4)+,d4		; a4 value to d4 and increment
	jsr printchar		; call printchar
	sub.b #1,d5		; increment loop var
	bne printloop		; loop call
	
	move.b #$0A,d4		; new line
	jsr printchar
	move.l (a7)+,d5		; restore from stack
	move.l (a7)+,a4		; restore from stack
	move.l (a7)+,d4		; restore from stack
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
