TITLE: {


	DelayTimer:	.byte DelayTime

	.label DelayTime = 5

	TargetRow:	.byte 1

	CurrentRows:	.byte 25, 26, 36, 38, 43, 47
	//CurrentRows:	.byte 2, 3, 13, 15, 20, 24

	Columns:		.byte 7, 11, 14, 14, 8, 9
	Colours:		.byte RED, WHITE, WHITE, WHITE, WHITE, WHITE
	Mode:			.byte 0
	Finishing:		.byte 0

	ScrollValue:	.byte 7

	Scrolling:		.byte 0

	LogoColours:	.byte GREEN, GREEN, WHITE, GREEN, GREEN, WHITE
	LogoColour:		.byte 0

	FlipTimer:		.byte 0

	Players:		.byte 0

	.label FlipTime = 250


	FrameUpdate: {


		jsr DrawArrow

		lda Mode
		bne NotScroll

		jsr ScrollUp2

		NotScroll:

		jsr LogoFlash
		jsr Controls

		lda FlipTimer
		beq Flip

		dec FlipTimer
		rts


		Flip:

		lda #0
		jsr HI_SCORE.Show

		

		rts

	}


	DrawArrow: {

		lda Players
		asl
		clc
		adc #12
		tay

		ldx Columns + 2

		lda #28

		jsr PLOT.PlotCharacter

		lda #WHITE
		jsr PLOT.ColorCharacter

		lda Players
		eor #%00000001
		asl
		clc
		adc #12
		tay

		ldx Columns + 2

		lda #32

		jsr PLOT.PlotCharacter

		rts
	}
	Controls: {

		ldy #1
		lda INPUT.FIRE_UP_THIS_FRAME, y
		beq CheckUp

		Start:

			lda Players
			sta SHIP.TwoPlayer

			jsr MAIN.ResetGame

			lda #SUBTUNE_START
			jsr sid.init

		CheckUp:

			lda Players
			beq CheckDown

			lda INPUT.JOY_UP_NOW, y
			beq CheckDown

			dec Players
			jmp DrawArrow

		CheckDown:

			lda Players
			bne Finish

			lda INPUT.JOY_DOWN_NOW, y
			beq Finish

			inc Players
			jmp DrawArrow


		Finish:




		rts
	}

	LogoFlash: {

		lda ZP.Counter
		and #%00000001
		beq Okay

		rts

		Okay:

		inc LogoColour
		lda LogoColour
		cmp #6
		bcc Finish

		lda #0
		sta LogoColour


		Finish:	

		jsr DrawLogo

			rts

	}

	Initialise: {


		lda #FlipTime
		sta FlipTimer

		
		lda #1
		sta STARS.Scrolling

		lda #1
		sta PRE_STAGE.NewStage
		
		lda #40
		sta STARS.MaxColumns

		lda #0
		sta Finishing
		sta Mode
		sta PRE_STAGE.GameStarted

		lda #2
		sta CurrentRows

		lda #3
		sta CurrentRows + 1

		lda #13
		sta CurrentRows + 2

		lda #15
		sta CurrentRows + 3

		lda #20
		sta CurrentRows + 4

		lda #24
		sta CurrentRows + 5

		jsr DrawLogo

		lda #SUBTUNE_BLANK
		jsr sid.init

		lda #1
		sta allow_channel_1

		jsr DrawArrow

		// lda #0
		// sta SpriteX
		// sta SpriteX + 1
		// sta SpriteX + 2
		// sta SpriteX + 3
		// sta SpriteX + 4
		// sta SpriteX + 5
		// sta SpriteX + 6
		// sta SpriteX + 7



		rts
	}

	DrawLogo: {

		
		lda #5
		tay

		ldx #14

		jsr PLOT.GetCharacter

		ldx #0
		stx ZP.Amount

		ldy #0

		Loop:

			stx ZP.StoredXReg

			ldx ZP.Amount

			lda LOGO, x
			sta (ZP.ScreenAddress), y

			ldx LogoColour
			lda LogoColours, x
			sta (ZP.ColourAddress), y

			iny
			inc ZP.Amount

			ldx ZP.StoredXReg
			inx
			cpx #12
			bcc Loop

		NextRow:

			tya
			clc
			adc #28
			tay

			cpy #232
			bcs Finish

			ldx #0

			jmp Loop


		Finish:


		rts
	}

	ScrollUp: {

		lda $d011
		and #%11111000
		ora ScrollValue
		sta $d011

		dec ScrollValue
		bpl DontReset

		lda #7
		sta ScrollValue

		DontReset:


			rts



	}

	ScrollUp2: {

	//	inc $d020

		inc DelayTimer

		lda DelayTimer
		cmp #6
		bcc Ready

		lda #0
		sta DelayTimer

		Ready:

		tax

		Loop:	

			stx ZP.StoredXReg

			lda CurrentRows, x
			beq DontDelete

			cmp #25
			bcs DontDelete



			jsr DeleteRow

		DontDelete:

			ldx ZP.StoredXReg
			dec CurrentRows, x

			lda CurrentRows, x
			sta TextRow
			bpl NotFinished

			inc Mode
			rts
			
		NotFinished:
			
			cmp #25
			bcs EndLoop

		Draw:

			lda Columns, x
			sta TextColumn

			txa
			pha

			lda Colours, x
			tax

			pla

			jsr TEXT.Draw

			EndLoop:
		
				lda TextRow
				cmp #1
				bne NotTheEnd

				inc Finishing

				NotTheEnd:


	//	dec $d020

		lda DelayTimer
		cmp #5
		bcc Finish


		lda Finishing
		sta Mode

		

		jsr SCORE.DrawBestTitle
		jsr SCORE.DrawP1Title


		Finish:

		rts


	}

	DeleteRow: {


		lda Columns, x
		sta ZP.Column

		lda CurrentRows, x
		sta ZP.Row
		tay

		lda #0
		ldx ZP.Column

		jsr PLOT.PlotCharacter

		ldy #255

		Loop:

			iny
			cpy #25
			bcs Finish

			lda (ZP.ScreenAddress), y
			cmp #197
			bcs NoDelete

			lda #0
			sta (ZP.ScreenAddress), y

			NoDelete:

			jmp Loop

		Finish:


		rts
	}

	
}