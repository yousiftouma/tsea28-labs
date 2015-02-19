setup:
	move.l #$7000,a7	; set SP
	jsr $20EC		; PINIT, init PIA
	move.l #$1200,$0074	; interupt, level 5 (PIAA)
	move.l #$1100,$0068	; interupt, level 2 (PIAB)
	and.w #$F8FF,SR		; set interupt level, accept all
	move.l #1000,d0		; 1000ms delay on print
mainLoop:
	jsr $2020		; write BAKGRUNDSPROGRAM
	jsr $2000		; delay
	bra mainLoop
