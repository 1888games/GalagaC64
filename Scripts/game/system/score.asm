SCORE:{

	* = * "Score"
	
	Value: 	.byte 0, 0, 0, 0	// H M L
	Value2: .byte 0, 0, 0, 0

	Best: 	.byte 0, 0, 3, 0

	.label CharacterSetStart = 48


	DrawWhenFree:	.byte 0
	ScoreInitialised: .byte 0

	ScoreH:		.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ,$00, $00, $00, $00, $01
	ScoreM:		.byte $00, $01, $00, $01, $01, $04, $08, $16, $10, $10, $15, $20, $30, $01, $10, $20, $30, $00
	ScoreL:		.byte $50, $00, $80, $60, $50, $00, $00, $00, $00, $00, $00, $00, $00, $60, $00, $00, $00, $00
	
	PopupID:	.byte $00, $00, $00, $00, $00, $01, $02, $05, $03, $03, $04, $06, $07, $00, $00, $00, $00, $00


	NextExtra:		.byte 2, 2
	CurrentExtra:	.byte 0, 0
	ExtraNormal:	.byte 0, 0

	Reset:{

		lda ScoreInitialised
		beq InitialiseScore

		jmp Finish

		InitialiseScore:

		lda #1
		sta ScoreInitialised

		lda #ZERO
		sta Value
		sta Value + 1
		sta Value + 2
		sta Value + 3
		sta Value + 4
		sta Value + 5
		sta Value + 6
		sta Value + 7
		sta ExtraNormal
		sta ExtraNormal + 1
		sta CurrentExtra 
		sta CurrentExtra + 1

		lda #2
		sta NextExtra
		sta NextExtra + 1



		

		

		Finish:

		rts

	}






	AddScore: {

		// y = scoreType
		// x = score index

		lda #0
		sta ZP.Amount

		lda BULLETS.PlayerShooting
		asl
		asl
		tax

		sed

		FirstDigit:

			lda ScoreL, y
			beq SecondDigit
			clc
			adc Value, x
			sta Value, x

			lda Value + 1, x
			adc #0
			sta Value + 1, x

			lda ZP.Amount
			adc #0
			sta ZP.Amount

		SecondDigit:
		
			lda ScoreM, y
			beq ThirdDigit
			clc
			adc Value + 1, x
			sta Value + 1, x

			lda ZP.Amount
			adc #0
			sta ZP.Amount

		ThirdDigit:

			lda ScoreH, y
			beq Finish
			sta ZP.Amount

			
		Finish:

			lda Value + 2, x
			clc
			adc ZP.Amount
			sta Value + 2, x

			lda Value + 3, x
			adc #0
			sta Value + 3, x

			ldx STAGE.CurrentPlayer
			lda CurrentExtra, x
			clc
			adc ZP.Amount
			sta CurrentExtra, x

			cmp #$10
			bcc CheckAgainstNext

			sec
			sbc #$10
			sta CurrentExtra, x

		CheckAgainstNext:

			cmp NextExtra, X
			bne NotYet

		ExtraLife:

			lda ExtraNormal, x
			beq AddFive

		AddSeven:

			lda NextExtra, x
			clc
			adc #7
			sta NextExtra, x

			cmp #$10
			bcc AddLife

			sec
			sbc #$10
			sta NextExtra, X

			jmp AddLife

		AddFive:

			lda NextExtra, x
			clc
			adc #5
			sta NextExtra, x

			inc ExtraNormal, x

		AddLife:
			cld
			jsr LIVES.Add
			jmp NowDraw

		NotYet:

			cld

		NowDraw:

			ldx BULLETS.PlayerShooting
			jsr DrawScore
			jsr CheckHighScore


		NoHigh:


		rts
	}


	CheckHighScore: {

		lda Value + 3
		cmp Best + 3
		bcc NoHigh

		beq Check2

		jmp IsHigh


	Check2:

		lda Value + 2
		cmp Best + 2
		bcc NoHigh

		beq Check3

		jmp IsHigh

	Check3:

		lda Value + 1
		cmp Best + 1
		bcc NoHigh

		beq Check4

		jmp IsHigh

	Check4:

		lda Value
		cmp Best
		bcc NoHigh



	IsHigh:

		lda Value
		sta Best

		lda Value + 1
		sta Best + 1

		lda Value + 2
		sta Best + 2

		lda Value + 3
		sta Best + 3


		jsr DrawBest


		NoHigh:

		rts
	}



	DrawBestTitle:{

		ldy #7	// screen offset, right most digit
		ldx #ZERO	// score byte index

		lda #4
		sta ZP.EndID

		lda Best+ 3, x
		bne ScoreLoop

		dec ZP.EndID

		lda Best + 2, x
		bne ScoreLoop

		dec ZP.EndID

		lda Best + 1, x
		bne ScoreLoop

		dec ZP.EndID


		InMills:

		ScoreLoop:

			lda Best, x
			pha
			and #$0f	// keep lower nibble
			jsr PlotDigit
			pla
			lsr
			lsr
			lsr	
			lsr // shift right to get higher lower nibble
			
		NextSet:
			inx 
			cpx ZP.EndID
			bne NoCheck

			cmp #0
			beq Finish

		NoCheck:

			jsr PlotDigit

			cpx ZP.EndID
			beq Finish

			jmp ScoreLoop


		PlotDigit: {

			clc
			adc #CharacterSetStart
			sta SCREEN_RAM + 95, y

			lda #WHITE
			sta VIC.COLOR_RAM + 95, y
			dey
			rts


		}

		Finish:

		rts

	}


	
	DrawBest:{

		ldy #7	// screen offset, right most digit
		ldx #ZERO	// score byte index

		lda #4
		sta ZP.EndID

		lda Best+ 3, x
		bne ScoreLoop

		dec ZP.EndID

		lda Best + 2, x
		bne ScoreLoop

		dec ZP.EndID

		lda Best + 1, x
		bne ScoreLoop

		dec ZP.EndID


		InMills:

		ScoreLoop:

			lda Best, x
			pha
			and #$0f	// keep lower nibble
			jsr PlotDigit
			pla
			lsr
			lsr
			lsr	
			lsr // shift right to get higher lower nibble
			
		NextSet:
			inx 
			cpx ZP.EndID
			bne NoCheck

			cmp #0
			beq Finish

		NoCheck:

			jsr PlotDigit

			cpx ZP.EndID
			beq Finish

			jmp ScoreLoop


		PlotDigit: {

			clc
			adc #CharacterSetStart
			sta SCREEN_RAM + 148, y

			lda #WHITE
			sta VIC.COLOR_RAM + 148, y
			dey
			rts


		}

		Finish:

		rts

	}

	DrawP1:{

		ldy #7	// screen offset, right most digit
		ldx #ZERO	// score byte index

		lda #4
		sta ZP.EndID

		lda Value + 3, x
		bne ScoreLoop

		dec ZP.EndID

		lda Value + 2, x
		bne ScoreLoop

		dec ZP.EndID

		lda Value + 1, x
		bne ScoreLoop

		dec ZP.EndID


		InMills:

		ScoreLoop:

			lda Value, x
			pha
			and #$0f	// keep lower nibble
			jsr PlotDigit
			pla
			lsr
			lsr
			lsr	
			lsr // shift right to get higher lower nibble
	NextSet:
			inx 
			cpx ZP.EndID
			bne NoCheck

			cmp #0
			beq Finish

		NoCheck:

			jsr PlotDigit

			cpx ZP.EndID
			beq Finish

			jmp ScoreLoop


		PlotDigit: {

			clc
			adc #CharacterSetStart
			sta SCREEN_RAM + 308, y

			lda #WHITE
			sta VIC.COLOR_RAM + 308, y
			dey
			rts


		}

		Finish:

		rts

	}


	DrawP2Title:{

		ldy #7	// screen offset, right most digit
		ldx #4	// score byte index

		lda #8
		sta ZP.EndID

		lda Value + 3, x
		bne ScoreLoop

		dec ZP.EndID

		lda Value + 2, x

		dec ZP.EndID

		lda Value + 1, x
		bne ScoreLoop

		dec ZP.EndID


		InMills:

		ScoreLoop:

			lda Value, x
			pha
			and #$0f	// keep lower nibble
			jsr PlotDigit
			pla
			lsr
			lsr
			lsr	
			lsr // shift right to get higher lower nibble
	NextSet:
			inx 
			cpx ZP.EndID
			bne NoCheck

			cmp #0
			beq Finish

		NoCheck:

			jsr PlotDigit

			cpx ZP.EndID
			beq Finish

			jmp ScoreLoop


		PlotDigit: {

			clc
			adc #CharacterSetStart
			sta SCREEN_RAM + 105, y

			lda #WHITE
			sta VIC.COLOR_RAM + 105, y
			dey
			rts


		}

		Finish:

		rts

	}

	DrawP1Title:{

		ldy #7	// screen offset, right most digit
		ldx #ZERO	// score byte index

		lda #4
		sta ZP.EndID

		lda Value + 3, x
		bne ScoreLoop

		dec ZP.EndID

		lda Value + 2, x
		bne ScoreLoop

		dec ZP.EndID

		lda Value + 1, x
		bne ScoreLoop

		dec ZP.EndID


		InMills:

		ScoreLoop:

			lda Value, x
			pha
			and #$0f	// keep lower nibble
			jsr PlotDigit
			pla
			lsr
			lsr
			lsr	
			lsr // shift right to get higher lower nibble
	NextSet:
			inx 
			cpx ZP.EndID
			bne NoCheck

			cmp #0
			beq Finish

		NoCheck:

			jsr PlotDigit

			cpx ZP.EndID
			beq Finish

			jmp ScoreLoop


		PlotDigit: {

			clc
			adc #CharacterSetStart
			sta SCREEN_RAM + 83, y

			lda #WHITE
			sta VIC.COLOR_RAM + 83, y
			dey
			rts


		}

		Finish:

		rts

	}


	DrawScore: {


		cpx #0
		beq PlayerOne

			jmp DrawP2

		PlayerOne:

			jmp DrawP1


	}	

	DrawP2:{

		ldy #7	// screen offset, right most digit
		ldx #4	// score byte index

		lda #8
		sta ZP.EndID

		lda Value + 3, x
		bne ScoreLoop

		dec ZP.EndID

		lda Value + 2, x
		bne ScoreLoop

		dec ZP.EndID

		lda Value + 1, x
		bne ScoreLoop

		dec ZP.EndID


		InMills:

		ScoreLoop:

			lda Value, x
			pha
			and #$0f	// keep lower nibble
			jsr PlotDigit
			pla
			lsr
			lsr
			lsr	
			lsr // shift right to get higher lower nibble
	NextSet:
			inx 
			cpx ZP.EndID
			bne NoCheck

			cmp #0
			beq Finish

		NoCheck:

			jsr PlotDigit

			cpx ZP.EndID
			beq Finish

			jmp ScoreLoop


		PlotDigit: {

			clc
			adc #CharacterSetStart
			sta SCREEN_RAM + 468, y

			lda #WHITE
			sta VIC.COLOR_RAM + 468, y
			dey
			rts


		}

		Finish:

		rts

	}


	



}