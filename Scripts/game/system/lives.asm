LIVES: {


	
	* = * "Lives"

	.label Lives = 3
	.label FlashTime = 16
	.label LabelColumn = 31
	.label LivesColumn = 28


	Chars:	.byte 36, 38, 34, 35

	Columns:	.byte 30, 32, 34, 36, 28, 38, 26
				.byte 30, 32, 34, 36, 28, 38, 26

	Rows:		.byte 15, 15, 15, 15, 15, 15, 15
				.byte 17, 17, 17, 17, 17, 17, 17

	FlashTimer:	.byte FlashTime
	FlashState:	.byte 1

	LabelRows:	.byte 6, 10
	Left:		.byte 3, 3
	Active:		.byte 0

	NewGame: {

		lda #Lives
		sta Left
		sta Left +1

		lda #1
		sta FlashState


		lda STAGE.Players
		cmp #2
		bcs TwoPlayer

		OnePlayer:


			lda LabelRows + 1
			tay

			ldx #LabelColumn

			lda #4
			jsr UTILITY.DeleteText	
			
			lda LabelRows + 1
			tay
			iny

			ldx #LivesColumn

			lda #8
			jsr UTILITY.DeleteText	

			rts

		TwoPlayer:



		rts

	}


	DeleteLives: {


		ldx Columns
		ldy Rows

		lda #14
		jsr UTILITY.DeleteText

		ldx Columns
		ldy Rows
		iny

		lda #14
		jsr UTILITY.DeleteText

		ldx Columns
		ldy Rows +7

		lda #14
		jsr UTILITY.DeleteText

		ldx Columns
		ldy Rows + 7
		iny

		lda #14
		jsr UTILITY.DeleteText


		rts

	}


	Decrease: {


		ldx STAGE.CurrentPlayer
		dec Left, x

		bmi GameOver


		jsr Draw
		rts


		GameOver:

		.break

		lda #50
		sta SHIP.DeadTimer

	
		rts
	}

	Add: {

		ldx STAGE.CurrentPlayer
		lda Left, x
		cmp #12
		bcs CantAdd

		clc
		adc #1
		sta Left, x

		jsr Draw

		sfx(SFX_EXTRA)

		CantAdd:

		rts

	}


	DrawShip: {

		TopLeft:

			lda Columns, x
			sta ZP.Column


			lda Rows, x
			sta ZP.Row
			tay

			lda Chars
			ldx ZP.Column

			jsr PLOT.PlotCharacter

			lda #WHITE_MULT

			jsr PLOT.ColorCharacter

		TopRight:

			ldy #1

			lda Chars + 1
			sta (ZP.ScreenAddress), y

			lda #WHITE_MULT
			sta (ZP.ColourAddress), y

		BottomLeft:

			ldy #40

			lda Chars + 2
			sta (ZP.ScreenAddress), y

			lda #WHITE_MULT
			sta (ZP.ColourAddress), y

		BottomRight:

			iny

			lda Chars + 3
			sta (ZP.ScreenAddress), y

			lda #WHITE_MULT
			sta (ZP.ColourAddress), y
			


		rts
	}

	Draw: {

		jsr DeleteLives

		ldx STAGE.CurrentPlayer
		lda Left, x
		sta ZP.Amount
		beq Finish

		ldx #0

		Loop:

			stx ZP.StoredXReg

			jsr DrawShip


			ldx ZP.StoredXReg
			inx
			cpx ZP.Amount
			bcs Finish

			jmp Loop

		Finish:



		rts
	}


	FrameUpdate: {

		lda Active
		beq Finish

		lda FlashTimer
		beq Ready

		dec FlashTimer
		rts

		Ready:

			lda #FlashTime
			sta FlashTimer

			lda FlashState
			beq TurnOn

		TurnOff:

			dec FlashState

			ldx STAGE.CurrentPlayer
			lda LabelRows, x
			tay

			ldx #LabelColumn

			lda #4
			jsr UTILITY.DeleteText

			rts

		TurnOn:

			inc FlashState

			ldx STAGE.CurrentPlayer
			lda LabelRows, x
			sta TextRow

			lda #LabelColumn
			sta TextColumn

			ldx #RED
			lda #TEXT.ONE_UP

			jsr TEXT.Draw

		Finish:

		rts
	}



}