HI_SCORE:  {
		
	.label ScreenTime = 250
	.label ColourTime = 5
	.label SCORE_MODE_VIEW = 0
	.label SCORE_MORE_ENTER = 1
	.label InputCooldown = 5

	* = * "High Scores"


	ScreenTimer: 		.byte ScreenTime
	Screen:				.byte 0

	Colour:				.byte 1
	ColourTimer:		.byte ColourTime

	StartIndexes:		.byte 0

	Rows:				.byte 8, 11, 14, 17, 20

	NameAddresses:		.word SCREEN_RAM + 335, SCREEN_RAM + 455, SCREEN_RAM + 575, SCREEN_RAM + 695, SCREEN_RAM + 815
	ScoreAddresses:		.word SCREEN_RAM + 344, SCREEN_RAM + 464, SCREEN_RAM + 584, SCREEN_RAM + 704, SCREEN_RAM + 824

	TextRows:			.byte 15, 17, 19, 21, 23

	.label NumberColumn = 3
	.label ScoreColumn = 7
	.label NameColumn = 19
	.label HeaderRow = 13
	.label Top5Row = 11



	Scores:	.byte 0, 0, 0, 0

	TextIDs:	.byte 49, 50, 51

	* = * "Position"
	PlayerPosition:	.byte 0
	InitialPosition:	.byte 0
	AddColumns:		.byte 6, 0
	AddColumn:		.byte 0
	AddRows:		.byte 251, 0
	AddRow:			.byte 0

	Mode:		.byte 0
	Cooldown:	.byte 0

	PositionLookup:	.byte 0, 3, 6, 9, 12


	Show: {

		CheckMode:

			sta Mode
			tax
			lda AddColumns, x
			sta AddColumn

			lda AddRows, x
			sta AddRow

			lda Mode
			bne EnterMode

			jsr UTILITY.ClearScreen
			jmp NoMusic

		EnterMode:

			lda PlayerPosition
			beq First

			lda #SUBTUNE_GAME_OVER
			jmp Play

		First:

			lda #SUBTUNE_HI_SCORE

		Play:

			jsr sid.init

		NoMusic:

			lda #GAME_MODE_SCORE
			sta MAIN.GameMode

			lda #0
			sta VIC.SPRITE_ENABLE

			lda #1
			sta Colour

			lda #ScreenTime
			sta ScreenTimer
		
			jsr DrawScreen
			jsr PopulateTable

			lda #0
			sta Screen

			rts

	}


	DrawScreen: {

		lda Mode
		beq Top5

		EnterInitials:

		
			lda #3
			sta TextRow

			lda #3
			clc
			adc AddColumn
			sta TextColumn

			ldx #RED
			lda #TEXT.INITIALS

			jsr TEXT.Draw

		ScoreTop:


			lda #5
			sta TextRow

			lda #7
			clc
			adc AddColumn
			sta TextColumn

			ldx #CYAN
			lda #TEXT.SCORE

			jsr TEXT.Draw

		Top5:

			lda #Top5Row
			clc
			adc AddRow
			sta TextRow

			lda #ScoreColumn - 2
			clc
			adc AddColumn
			sta TextColumn

			ldx #RED
			lda #TEXT.TOP_5

			jsr TEXT.Draw

		Score:

			lda #HeaderRow
			clc
			adc AddRow
			sta TextRow

			lda #NumberColumn
			clc
			adc AddColumn
			sta TextColumn

			ldx #WHITE
			lda #TEXT.SCORE

			jsr TEXT.Draw


		rts
	}


	ShowEnterMode: {






		jmp HiScoreLoop
	}



	Check: {


		//lda MENU.SelectedOption
		//sta Screen

		jmp Player1

		Player2:


			lda SCORE.Value2 
			sta Scores

			lda SCORE.Value2 + 1
			sta Scores + 1

			lda SCORE.Value2 + 2
			sta Scores + 2


			lda SCORE.Value2+ 3
			sta Scores + 3

			jmp CheckScore

		Player1:

			lda SCORE.Value
			sta Scores

			lda SCORE.Value + 1
			sta Scores + 1

			lda SCORE.Value + 2
			sta Scores + 2

			lda SCORE.Value + 3
			sta Scores + 3

		CheckScore:

			ldx Screen
			lda StartIndexes, x
			sta ZP.StartID

			lda #255
			sta ZP.Amount

			ldx #0

		Loop:

			stx ZP.StoredXReg

			ldx ZP.StartID 

			lda Scores + 3
			cmp MillByte, x
			bcc EndLoop

			beq EqualsMill

				stx ZP.Amount
				jmp Done

			EqualsMill:

				lda Scores + 2
				cmp HiByte, x
				bcc EndLoop

				beq EqualsHigh

			BiggerHigh:

				stx ZP.Amount
				jmp Done

			EqualsHigh:

				lda Scores + 1
				cmp MedByte, x
				bcc EndLoop

				beq EqualsMed

			BiggerMed:

				stx ZP.Amount
				jmp Done

			EqualsMed:

				lda Scores
				cmp LowByte, x
				bcc EndLoop

				stx ZP.Amount
				jmp Done

			EndLoop:	

				inc ZP.StartID

				ldx ZP.StoredXReg
				inx
				cpx #5
				bcc Loop


		Done:

			lda ZP.Amount
			bmi Finish

			stx PlayerPosition

			cpx #4
			bcs NoCopy


		ldx #3
		ldy #4

		CopyLoop:

			lda MillByte, x
			sta MillByte, y

			lda HiByte, x
			sta HiByte, y

			lda MedByte, x
			sta MedByte, y

			lda LowByte, x
			sta LowByte, y

			lda FirstInitials, x
			sta FirstInitials, y

			lda SecondInitials, x
			sta SecondInitials, y

			lda ThirdInitials, x
			sta ThirdInitials, y


			lda PlayerPosition

			dex
			dey
			cpx #255
			beq NoCopy
			cpx PlayerPosition
			bcs CopyLoop


		NoCopy:

			ldx PlayerPosition

			lda Scores + 3
			sta MillByte, x

			lda Scores + 2
			sta HiByte, x

			lda Scores + 1
			sta MedByte, x

			lda Scores
			sta LowByte, x

			lda #0
			sta InitialPosition

			lda #32
			sta FirstInitials, x

			lda #32
			
			sta SecondInitials, x
			sta ThirdInitials, X


			
			//lda #GAME_MODE_SWITCH_SCORE
			//sta MAIN.GameMode


		Finish:


		rts






	}

	PopulateHeader: {

		lda #16
		clc
		adc AddColumn
		sta TextColumn

		lda #5
		sta TextRow

		ldx Screen
		lda TextIDs, x

		ldx #WHITE

		jsr TEXT.Draw
	


		rts
	}


	PopulateTable: {


	//	jsr PopulateHeader

		ldx Screen
		lda StartIndexes, x
		sta ZP.StartID

		Names:

		ldx #0

		Loop:

			lda #CYAN
			sta ZP.Colour

			stx ZP.StoredXReg
			cpx PlayerPosition
			bne NotPlayer

			lda #YELLOW
			sta ZP.Colour

			NotPlayer:

			lda TextRows, x
			clc
			adc AddRow
			tay 

			lda #NameColumn
			clc
			adc AddColumn
			tax

			jsr PLOT.GetCharacter

			ldx ZP.StartID
			lda FirstInitials, x

			ldy #0
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			lda SecondInitials, x

			iny
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			lda ThirdInitials, x

			iny
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			inc ZP.StartID

			ldx ZP.StoredXReg
			inx
			cpx #5
			bcc Loop


		Score:

		ldx Screen
		lda StartIndexes, x
		sta ZP.StartID


		ldx #0

		Loop2:

			stx ZP.StoredXReg

			lda #CYAN
			sta ZP.Colour

			cpx PlayerPosition
			bne NotPlayer2

			lda #YELLOW
			sta ZP.Colour

			NotPlayer2:

			lda TextRows, x
			clc
			adc AddRow
			tay 

			lda #ScoreColumn
			clc
			adc AddColumn
			tax

			jsr PLOT.GetCharacter

			ldx ZP.StartID

			lda MillByte, x
			sta Scores + 3

			lda HiByte, x
			sta Scores + 2

			lda MedByte, x
			sta Scores + 1

			lda LowByte, x
			sta Scores

			jsr DrawScore

			inc ZP.StartID


		Place:

			ldx ZP.StoredXReg

			lda TextRows, x
			clc
			adc AddRow
			sta TextRow

			lda #NumberColumn
			clc
			adc AddColumn
			sta TextColumn

			ldx ZP.Colour
			lda #TEXT.NUM_START
			clc
			adc ZP.StoredXReg

			jsr TEXT.Draw

			ldx ZP.StoredXReg
			inx
			cpx #5
			bcc Loop2



		rts
	}




	DrawScore:{

		ldy #7	// screen offset, right most digit
		ldx #ZERO	// score byte index

		lda #4
		sta ZP.EndID

		lda Scores + 3, x
		bne ScoreLoop

		dec ZP.EndID

		lda Scores + 2, x
		bne ScoreLoop

		dec ZP.EndID

		lda Scores + 1, x
		bne ScoreLoop

		dec ZP.EndID


		InMills:

		ScoreLoop:

			lda Scores, x
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
			adc #SCORE.CharacterSetStart
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			dey
			rts


		}

		Finish:

		rts

	}



	HiScoreLoop: {


		WaitForRasterLine:

			lda VIC.RASTER_Y
			cmp #175
			bne WaitForRasterLine


		lda Mode
		bne Finish

		ldy #1
		lda INPUT.FIRE_UP_THIS_FRAME, y
		beq Finish

		//jmp MENU.Show
		.break
		nop

		Finish:

		jmp FrameCode
	}




	EnterMode: {

		lda Cooldown
		beq Ready

		dec Cooldown
		jmp Finish

		Ready:	

		lda #InputCooldown
		sta Cooldown

		ldx Screen
		lda StartIndexes, x
		clc
		adc PlayerPosition
		sta ZP.StartID

		CheckRight:

			ldy #1
			lda INPUT.JOY_RIGHT_NOW, y
		    bne Right

			lda INPUT.JOY_DOWN_NOW, y
			beq CheckLeft

		Right:

			ldx ZP.StartID
			lda InitialPosition
			beq First

			cmp #1
			beq Second

		Third:

			inc ThirdInitials, x
			lda ThirdInitials, x
			cmp #27
			bcs NotValid

			jmp Draw

			NotValid:

			beq MakeFullStop

			lda #0
			jmp Now3

			MakeFullStop:

			lda #46

			Now3:

			sta ThirdInitials, x
			jmp Draw

		Second:

			inc SecondInitials, x
			lda SecondInitials, x
			cmp #27
			bcc Draw

			beq MakeFullStop2

			lda #0
			jmp Now2

			MakeFullStop2:

			lda #46
		

			Now2:
			sta SecondInitials, x
			jmp Draw

		First:

			inc FirstInitials, x
			lda FirstInitials, x
			cmp #27
			bcc Draw

			beq MakeFullStop1

			lda #0
			jmp Now1

			MakeFullStop1:

			lda #46

			Now1:
	
			sta FirstInitials, x
			jmp Draw

		CheckLeft:
			
			lda INPUT.JOY_LEFT_NOW, y
			bne Left

			lda INPUT.JOY_UP_NOW, y
			beq Finish

		Left:

			ldx ZP.StartID
			lda InitialPosition
			beq First2

			cmp #1
			beq Second2

		Third2:

			dec ThirdInitials, x
			lda ThirdInitials, x
			bne Draw

			lda #26
			sta ThirdInitials, x
			jmp Draw

		Second2:

			dec SecondInitials, x
			lda SecondInitials, x
			bne Draw
		
			lda #26
			sta SecondInitials, x
			jmp Draw

		First2:

			dec FirstInitials, x
			lda FirstInitials, x
			bne Draw
		
			lda #26
			sta FirstInitials, x
			jmp Draw


		Draw:

			jsr PopulateTable
			rts


		Finish:

			ldy #1
			lda INPUT.FIRE_UP_THIS_FRAME, y
			beq NoFire

			ldx ZP.StartID

			inc InitialPosition
			lda InitialPosition
			cmp #3
			beq Fire

			cmp #2
			bne Second3

			Third3:

				lda #1
				sta ThirdInitials, x
				jsr PopulateTable
				jmp NoFire

			Second3:

				lda #1
				sta SecondInitials, x
				jsr PopulateTable
				jmp NoFire

			Fire:

				lda #0
				sta Mode

			    sta $d404               // Sid silent 
	            sta $d404+7 
	            sta $d404+14 

				jsr DISK.SAVE	

				lda #0
				sta VIC.SPRITE_ENABLE

				jmp MAIN.ShowTitleScreen


			NoFire:

			rts

	}

	FrameCode: {

		lda Mode
		beq ViewMode

		jmp EnterMode


		ViewMode:

			lda ScreenTimer
			beq Ready

			dec ScreenTimer

		CheckFire:

			ldy #1
			lda INPUT.FIRE_UP_THIS_FRAME, y
			beq NoFire

			sfx(SFX_COIN)

		Demo:

			

			jmp MAIN.ShowTitleScreen


		NoFire:

			rts

		Ready:

			lda #ScreenTime
			sta ScreenTimer

			jsr DEMO.Show

			rts



	}


	

	




		


}