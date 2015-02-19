;;; Huvudprogram som testar utskriftsrutinen
setup:
	move.l #$7000,a7	; set SP
	jsr $20EC		; PINIT, init PIA
	move.l #rightPlayerStrike,$0074 ; interupt, level 5 (PIAA)
	move.l #leftPlayerStrike,$0068	; interupt, level 2 (PIAB)
	and.w #$F8FF,SR			; set interupt lvel, accept all
	
	move.b #$80,d2		; set start position to left
	
	move.l #0,d3		; reset player
	move.l #0,d4		; goals

	move.l #$FF,d5		; set right direction
	move.l #$FF,d6		; no serve
	
	move.l #7,d7		; start position
gameLoop:
	jsr showgame
	move.l #1000,d0		; set loop timer
	jsr $2000		; delay
	cmp.b #$FF,d6		; if serve
	beq gameLoop		; wait
	
	cmp.b #$FF,d5
	beq goingright
goingleft:
	cmp.b #7,d7
	beq addedScoreRight
	lsl.b #1,d2
	add.b #1,d7
	bra gameLoop
goingright:
	cmp.b #0,d7
	beq addedScoreLeft
	lsr.b #1,d2
	sub.b #1,d7
	bra gameLoop

addedScoreLeft:
	jsr leftPlayerScore
	bra gameLoop

addedScoreRight:
	jsr rightPlayerScore
	bra gameLoop
	
	move.b #255,d7
        trap #14

;; Argument: D2 innehaller spelplanen
showgame:                               
        move.b d1,-(a7)		; Spara register som används
	move.b d4,-(a7)
        move.b d7,-(a7)
        move.b #$80,d1		; d1: Nuvarande bit
loop:                                   
        move.b d1,d7		; Kolla om biten är satt, 
        and.b  d2,d7		; skriv ut en stjärna isåfall, 
        beq    notlighted       ; annars en punkt.
        move.b #'*',d4                  
        jsr     printchar               
        bra     nextiteration           
notlighted:                             
        move.b #'.',d4                  
        jsr     printchar               
                                        
nextiteration:                          
        lsr.b #1,d1		; Gå vidare till nästa bit i d1
        bne   loop                      
                                        
        move.b  #13,d4		; Skriv ut nyrad/radframmatning
        jsr     printchar               
        move.b  #10,d4                  
        jsr     printchar

	move.b  (a7)+,d7	; Återställ...
	move.b  (a7)+,d4
	move.b  (a7)+,d1
        rts                             
                                        
;;; Samma printchar som tidigare...
printchar:                              
        move.b d5,-(a7)                 
waittx:                                 
        move.b $10040,d5                
        and.b #2,d5                     
        beq waittx                      
        move.b d4,$10042                
        move.b (a7)+,d5                 
        rts



;;; LEFT PLAYER ACTIONS ;;;
leftPlayerStrike:

	cmp.b #7,d7		; is in left most position
	beq leftPlayerCorrectStrike
	jsr rightPlayerScore
	bra endLeftPlayerStrike
	
leftPlayerCorrectStrike:
	move.b #00,d6
	move.b #$FF,d5		; reverse direction

endLeftPlayerStrike:	
	btst #7,$10082		; reset CB1
	rte

leftPlayerScore:
	add.l #1,d4		; increment score
	move.l #$FF,d6		; set serve, TRUE
	move.l #$FF,d5		; set direction, right
	move.l #7,d7		; set position, left most
	move.l #$80,d2		; set light
	rts

;;; RIGHT PLAYER ACTIONS ;;;
rightPlayerStrike:

	cmp.b #0,d7		; is in right most position
	beq rightPlayerCorrectStrike
	jsr leftPlayerScore
	bra endRightPlayerStrike
	
rightPlayerCorrectStrike:
	move.b #00,d6
	move.b #$00,d5		; reverse direction

endRightPlayerStrike:	
	btst #7,$10080		; reset CA1
	rte

rightPlayerScore:
	add.l #1,d3		; increment score
	move.l #$FF,d6		; set serve, TRUE
	move.l #$00,d5		; set direction, left
	move.l #0,d7		; set position, right most
	move.l #1,d2		; set light
	rts
