STARS: {


	.label MAX_STARS = 24
	.label FlashTime = 7

	Columns:	.fill MAX_STARS, random() * 38 + 1
	Rows:		.fill MAX_STARS, random() * 23

	//StartIDs:	.byte 0, 16, 32, 48, 64
	StartIDs:	.byte 0, MAX_STARS/2
	EndIDs:		.byte MAX_STARS/2, MAX_STARS


	//StartIDs:	.byte 0, 8, 16, 24, 32, 40, 48, 56
	CharIDs:	.fill MAX_STARS, 197 + floor(i/3.1)
	FlashTimer:	.fill MAX_STARS, 1 +random() * (FlashTime-1)
	On:			.fill MAX_STARS, random() * 1
	Colours:	.fill MAX_STARS, 1 + random() * 6

	
	FrameTimer:		.byte 0
	StartID:		.byte 0

	MaxColumns:		.byte 24

	.label BlankCharacterID = 0


	Scrolling: 		.byte 0



	
	FrameUpdate: {

		SetDebugBorder(4)

		inc FrameTimer

		lda FrameTimer
		and #%00000001
		tax
		sta ZP.Temp1

		lda EndIDs, x
		sta ZP.StarEndID

		lda StartIDs, x
		tax


		Loop:

			stx ZP.StoredXReg

			CheckIfOffScreen:

				lda Scrolling
				bpl MovingDown

			MovingUp:

				lda Rows, x
				bmi NewStar

				jmp DeleteStar

			MovingDown:

				lda Rows, x
				cmp #25
				bcs NewStar

			DeleteStar:

				lda On, x
				beq MoveStar

				lda Rows, x
				sta ZP.Row

				lda Columns, x
				tax

				lda #BlankCharacterID
				sta ZP.CharID


				jsr PLOT.PlotStar

				ldx ZP.StoredXReg
				jmp MoveStar
		
			NewStar:

				lda #FlashTime
				sta FlashTimer, x

				jsr RANDOM.Get
				cmp MaxColumns
				bcc NewIsOk

				jmp EndLoop

			NewIsOk:
				
				clc
				adc #1
				sta Columns, x

				lda Scrolling
				bpl MovingDownNew

				lda #24
				sta Rows, x

				jmp MoveStar

			MovingDownNew:

				lda #0
				sta Rows, x

			MoveStar:

				lda FlashTimer, x
				beq ReadyToFlash

				dec FlashTimer, x
				jmp NoFlash

				ReadyToFlash:

					lda #FlashTime
					sta FlashTimer, x

					lda On, x
					beq TurnOn

					lda #0
					sta On, x

					jmp NoFlash

				TurnOn:

					lda #1
					sta On, x

				NoFlash:

					lda CharIDs, x
					clc
					adc Scrolling
					clc
					adc Scrolling
					sta CharIDs, x

					lda ZP.Temp1
					beq NoDoubleSpeed

					lda CharIDs, x
					clc
					adc Scrolling
					sta CharIDs, x
				

				NoDoubleSpeed:

					lda CharIDs, x
					cmp #205
					bcs NoStar

					cmp #197
					bcc NoStar

					jmp DrawStar

				NoStar:
					
					lda #197
					sta CharIDs, x

					lda Scrolling
					bpl DownRow

					dec Rows, x
					jmp DrawStar

				DownRow:
					inc Rows, x
					
			DrawStar:

				lda On, x
				beq EndLoop

				lda Columns, x
				bmi EndLoop

				lda Rows, x
				sta ZP.Row

				lda CharIDs, x
				sta ZP.CharID

				lda Colours, x
				sta ZP.Colour

				lda Columns, x
				cmp MaxColumns
				bcc Okay

				jsr RANDOM.Get
				and #%00001111
				clc
				adc #3
				sta Columns, X

				Okay:

				tax

				lda ZP.Row
				cmp #25
				bcs EndLoop

				jsr PLOT.PlotStar

			EndLoop:	

				ldx ZP.StoredXReg
				inx
				cpx ZP.StarEndID
				bcs Finish
				jmp Loop

		Finish:

			SetDebugBorder(0)


		rts


	}




}