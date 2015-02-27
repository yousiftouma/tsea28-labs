setup:
	move.l #$7000,a7	; set SP
	jsr piaInit		; setup PIA
	and.w #$F8FF,SR		; allow interups, set level 0
	move.l #BCD,$74
	move.l #MUX,$68

	move.l #0,$900
	move.l #$900,a1
	move.l #$901,a2
	move.l #$902,a3
	move.l #$903,a4

	
	clr.l d1		; Clear d1 reg
	move.l #$900,d0		; MUX counter (900-903)
	clr.l d2		; Number to be displayed
	
loop:
	move.l $900,d7
	move.b d1,$10082	; Choose which number to display this time
	move.b d2,$10080	; Segments to display
	
	stop #$2000		; Stop execution, keep interupt level
	bra loop
	
	ds.b 300
BCD:
	btst #0,$10080

;;; Increment BCD time ;;;
	cmp.b #9,(a1)
	beq full_sec
	add.b #1,(a1)
	rte
full_sec:
	move.b #0,(a1)
	cmp.b #5,(a2)
	beq full_tensec
	add.b #1,(a2)
	rte
full_tensec:
	move.b #0,(a2)
	cmp.b #9,(a3)
	beq full_min
	add.b #1,(a3)
	rte
full_min:
	move.b #0,(a3)
	cmp.b #5,(a4)
	beq full_hour
	add.b #1,(a4)
	rte
full_hour:
	clr.l $900
	rte
	
	ds.b 100

MUX:
	btst #0,$10082
	move.b d0,d1
	and.b #3,d1		; last two bits

	and.l #$F,d2		; mask out number (last four bits)
	lea SJUSEG,a0		; table start
	add.l d2,a0		; point out correct index
	move.b (a0),d2		; extract bit pattern

	
	cmp.w #$903,d0
	beq MUX_reset
	add.b #1,d0
	rte
MUX_reset:
	move.w #$900,d0
	rte
	
	ds.b 400

	
SJUSEG:	dc.b $3F	; '0'
	dc.b $6		; '1'
	dc.b $5B	; '2'
	dc.b $4F	; '3'
	dc.b $66	; '4'
	dc.b $6C	; '5'
	dc.b $7D	; '6'
	dc.b $07	; '7'
	dc.b $7F	; '8'
	dc.b $67	; '9'
	
piaInit:
	clr.b $10084		; reset CRA
	clr.b $10086		; reset CRB
	move.b #127,$10080	; set DDRA
	move.b #3,$10082	; set DRRB
	move.b #31,$10084	; allow interupt IRQA
	move.b #31,$10086	; allow interupt IRQB
	tst.b $10080
	tst.b $10082
	rts

