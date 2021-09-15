PRE_STAGE: {

	* = * "Pre-Stage"
	
	Progress:	.byte 0

	Timer:		.byte 0

	//.label StartTime = 150
	//.label DelayTime = 25
	//.label StageTime = 25
	//.label ReadyTime = 50
	//.label BadgeTime = 3



	.label StartTime = 1
	.label DelayTime = 2
	.label StageTime = 2
	.label ReadyTime = 5
	.label BadgeTime = 3

	.label StartRow = 14
	.label StartColumn = 11

	.label StageRow = 10
	.label StageColumn = 9
	.label ChallengeColumn =5

	  
	.label StageNumColumn = 17

	BadgeValues:	.byte 50, 30, 20, 10, 5, 1

	BadgeChars:		.byte 142, 143, 159, 160
					.byte 140, 141, 157, 158
					.byte 138, 139, 155, 156
					.byte 136, 137, 153, 154
					.byte 43, 44, 60, 61
					.byte 41, 42, 58, 59

	BadgeColours:	.byte WHITE_MULT, YELLOW_MULT, PURPLE_MULT, YELLOW_MULT, WHITE_MULT, WHITE_MULT


	BadgesToShow:	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	NumBadges:		.byte 0
	BadgeProgress:	.byte 0

	BadgeRows:		.byte 19, 19, 19, 19, 21, 21, 21, 21, 23, 23, 23, 23
	BadgeColumns:	.byte 29, 31, 33, 35, 29, 31, 33, 35, 29, 31, 33, 35
	GameStarted:	.byte 0

	NewStage:		.byte 1


	Initialise: {

		lda #255
		sta VIC.SPRITE_ENABLE


		lda #StartTime
		sta Timer

		lda #0
		sta Progress
		sta STARS.Scrolling
		sta GameStarted

		lda #24
		sta STARS.MaxColumns

		lda #TRUE
		sta MAIN.GameActive
		sta NewStage

		lda #GAME_MODE_PRE_STAGE
		sta MAIN.GameMode

		lda #StartRow
		sta TextRow

		lda #StartColumn
		sta TextColumn

		ldx #RED
		lda #TEXT.START

		jsr TEXT.Draw

		jsr STAGE.NewGame

		rts
	}



	StartStage: {


		ldy #StartRow
		ldx #StartColumn
		lda #5
		
		jsr UTILITY.DeleteText

	
		lda GameStarted
		bne NoShipDecrease

		jsr LIVES.Decrease
		jsr SHIP.NewGame
		jsr SHIP.Initialise
		jsr STAGE.NewGame
		jsr ENEMY.NewGame
		jsr BEAM.NewGame
	


		NoShipDecrease:

			lda NewStage
			bne IsNewStage

			jsr LIVES.Decrease
			jsr SHIP.Initialise
			jsr SHIP.SecondShip
			jmp NoNewStage	

		IsNewStage:

			jsr SHIP.NewStage
			jsr FORMATION.Initialise
			jsr ATTACKS.Reset
			jsr STAGE.GetStageData
			

		NoNewStage:

			jsr SHIP.Reset

			lda #GAME_MODE_PLAY
			sta MAIN.GameMode

		Loop:

			//lda $d012
			//cmp #230
			//bne Loop

		lda #1
		sta GameStarted

		rts
	}

	FrameUpdate: {

		lda ZP.Counter
		and #%00000001
		beq NoUpdate

		CheckTimer:

			lda Timer
			beq Ready

			dec Timer
			rts

		Ready:

			lda Progress
			beq PreStageDelay

			cmp #1
			beq ShowStage2

			cmp #2
			beq ShowBadges2

			cmp #3
			beq ShowReady2

			jmp StartStage

		ShowBadges2:

			jmp ShowBadges

		ShowStage2:

			jmp ShowStage	

		ShowReady2:

			jmp ShowReady

		PreStageDelay:

			lda #PreStageDelay
			sta Timer

			inc Progress

			ldy #StartRow
			ldx #StartColumn
			lda #5
		
			jsr UTILITY.DeleteText

			lda #DelayTime
			sta Timer


		NoUpdate:	

		rts
	}	


	ShowReady: {

		lda NewStage
		beq NotNewStage

		ldy #StageRow
		ldx #ChallengeColumn
		lda #18
	
		jsr UTILITY.DeleteText

		NotNewStage:

		lda #1
		sta STARS.Scrolling

		lda #StartRow
		sta TextRow

		lda #StartColumn
		sta TextColumn

		ldx #RED
		lda #TEXT.READY

		jsr TEXT.Draw

		lda #ReadyTime
		sta Timer

		inc Progress

		lda #1
		sta LIVES.Active


		rts
	}


	ShowStage: {

		inc Progress

		jsr CalculateBadges
		jsr DeleteBadges
		jsr ShowStageTitle


		jsr CalculateWaveSpeed

		rts
	}	


	ChallengeJingle: {


		sfx(SFX_CH1)
		sfx(SFX_CH2)
		sfx(SFX_CH3)


		rts
	}

	ShowStageTitle: {

		lda #StageRow
		sta TextRow

		lda #StageColumn
		sta TextColumn

		lda #255
		sta ZP.Amount
		jsr STAGE.CalculateStageIndex

		cmp #3
		bcc NormalStage

		ChallengingStage:

			lda #ChallengeColumn
			sta TextColumn

			jsr ChallengeJingle

			ldx #CYAN
			lda #TEXT.CHALLENGING_STAGE
			jsr TEXT.Draw
			rts

		NormalStage:

			lda #TEXT.STAGE
			ldx #CYAN

			jsr TEXT.Draw

			lda #StageNumColumn
			sta TextColumn

			ldx STAGE.CurrentPlayer
			lda STAGE.CurrentStage, x
			clc
			adc #1

			ldy #CYAN

			ldx #0
			jsr TEXT.DrawByteInDigits


		rts
	}


	ShowBadge: {

		// ZP.Amount is badge type
		// ZP.StoredYReg = charID lookup

		// ZP.StoredXReg = badgeposition

		//sfx(SFX_BADGE)

		lda BadgeRows, x
		sta ZP.Row

		lda BadgeColumns, x
		sta ZP.Column

		ldx ZP.StoredYReg
		inc ZP.StoredYReg

		TopLeft:

			lda BadgeChars, x
			ldx ZP.Column
			ldy ZP.Row

			jsr PLOT.PlotCharacter

			lda ZP.Colour

			jsr PLOT.ColorCharacter


		TopRight:

			ldy #1
			ldx ZP.StoredYReg
			inc ZP.StoredYReg
			lda BadgeChars, x

			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y
			


		BottomLeft:

			ldy #40
			ldx ZP.StoredYReg
			inc ZP.StoredYReg
			lda BadgeChars, x

			sta (ZP.ScreenAddress), y


			lda ZP.Colour
			sta (ZP.ColourAddress), y


		BottomRight:

			ldy #41
			ldx ZP.StoredYReg
			inc ZP.StoredYReg
			lda BadgeChars, x

			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y





		rts
	}

	DeleteBadges: {

		ldx BadgeColumns
		ldy BadgeRows

		lda #8
		jsr UTILITY.DeleteText

		ldx BadgeColumns
		ldy BadgeRows
		iny

		lda #8
		jsr UTILITY.DeleteText

		ldx BadgeColumns
		ldy BadgeRows + 4

		lda #8
		jsr UTILITY.DeleteText

		ldx BadgeColumns
		ldy BadgeRows + 4
		iny

		lda #8
		jsr UTILITY.DeleteText

		ldx BadgeColumns
		ldy BadgeRows + 8

		lda #8
		jsr UTILITY.DeleteText

		ldx BadgeColumns
		ldy BadgeRows + 8
		iny

		lda #8
		jsr UTILITY.DeleteText


		rts
	}

	ShowBadges: {

		ldx BadgeProgress

		Loop:

			stx ZP.StoredXReg

			lda BadgesToShow, x
			bmi NoMoreBadges
			sta ZP.Amount

			asl
			asl
			sta ZP.StoredYReg

			ldx ZP.Amount
			lda BadgeColours, x
			sta ZP.Colour

			ldx ZP.StoredXReg

			jsr ShowBadge

		
			lda STAGE.StageIndex
			cmp #CHALLENGING_STAGE
			bcs NoSound

			sfx(SFX_BADGE)


			NoSound:


			inc BadgeProgress

			lda #BadgeTime
			sta Timer

		Finish:

			rts

		NoMoreBadges:

			inc Progress

			lda #StageTime
			sta Timer
			rts
	}

	CalculateBadges: {



		ldx STAGE.CurrentPlayer
		lda STAGE.CurrentStage
		clc
		adc #1
		sta ZP.Amount

		ldx #0
		stx NumBadges
		stx BadgeProgress

		BadgeLoop:

			lda ZP.Amount
			sec
			sbc BadgeValues, x
			bpl AddBadge

		NotEnoughLeft:

			inx
			cpx #6
			bcc BadgeLoop

			lda #255
			ldy NumBadges
			sta BadgesToShow, y
			jmp Finish

		AddBadge:

			sta ZP.Amount

			txa
			ldy NumBadges

			sta BadgesToShow, y

			inc NumBadges

			jmp BadgeLoop


		Finish:

		rts
	}


}