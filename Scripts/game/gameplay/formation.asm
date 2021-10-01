FORMATION: {

	


	.label SR = 50
	.label SC = 20

	.label TransformStages = 5
	.label TransformTime = 20


	SpriteRow:	.fill 2, SR
				.fill 6, SR + (2 * 8)
				.fill 8, SR + (4 * 8)
				.fill 10, SR + (6 * 8)
				.fill 10, SR + (8* 8)
				.fill 10, SR + (1* 8)
				.fill 2, 0


	SpriteColumn:

				.fill 1, SC + (9 * 8) + (i*16)
				.fill 1, SC + (1 * 8) + (i*16)
				.fill 6, SC + (7 * 8) + (i*16)
				.fill 8, SC + (5 * 8) + (i*16)
				.fill 10, SC + (3 * 8) + (i*16)
				.fill 10, SC + (3 * 8) + (i*16)
				.fill 10, SC + (3 * 8) + (i*16)
				.fill 2, 0


	.label ExplosionChar = 63
	.label EXPLOSION_TIME = 3
	.label UpdatesPerFrame = 8
	.label MAX_EXPLOSIONS= 3

	Hits:		.fill 4, 0
				.fill 36, 0
				.fill 3, 0
				.fill 3, 0
				.fill 2, 0


	Column:		.fill 48, 0
	PreviousColumn:	.fill 48, 0
	PreviousRow:	.fill 48, 0
	HitsLeft:	.fill 40, 1
				.fill 8, 0
	Switching:	.byte 0

	Plan:		.fill 48, 0
	NextPlan:	.fill 48, 0

	TypeToScore:		.byte 4, 4, 2, 0, 3, 7
	ChallengeToScore: 	.byte 5, 5, 1, 1, 1, 1
	Alive:			.byte 0

	Stop:			.byte 0



	* = * "Enemies Left"
	EnemiesLeftInStage:	.byte 0



	Home_Column:
				.byte 9, 15
				.byte 7, 9, 11, 13, 15, 17
				.byte 5, 7, 9, 11, 13, 15, 17, 19
				.byte 3, 5, 7, 9, 11, 13, 15, 17, 19, 21
				.byte 3, 5, 7, 9, 11, 13, 15, 17, 19, 21
				.byte 3, 5, 7, 9, 11, 13, 15, 17, 19, 21
				.byte 9, 9


	Spread_1:	.byte 9, 11, 13, 15
				.byte 5, 7, 9, 11, 13, 15, 17, 19
				.byte 5, 7, 9, 11, 13, 15, 17, 19
				.byte 2, 5, 7, 9, 11, 13, 15, 17, 19, 22
				.byte 2, 5, 7, 9, 11, 13, 15, 17, 19, 22

	Spread_2:	.byte 9, 11, 13, 15
				.byte 4, 7, 9, 11, 13, 15, 17, 20
				.byte 4, 7, 9, 11, 13, 15, 17, 20
				.byte 2, 5, 7, 9, 11, 13, 15, 17,20, 22
				.byte 2, 5, 7, 9, 11, 13, 15, 17, 20, 22

	Spread_3:	.byte 9, 11, 13, 15
				.byte 3, 6, 9, 11, 13, 15, 18, 20
				.byte 3, 6, 9, 11, 13, 15, 18, 20
				.byte 2, 4, 7, 9, 11, 13, 15, 17, 20, 22
				.byte 2, 4, 7, 9, 11, 13, 15, 17, 20, 22


	Spread_4:	.byte 9, 11, 13, 15
				.byte 2, 6, 9, 11, 13, 15, 18, 21
				.byte 2, 6, 9, 11, 13, 15, 18, 21
				.byte 1, 4, 7, 9, 11, 13, 15, 17, 20, 23
				.byte 1, 4, 7, 9, 11, 13, 15, 17, 20, 23

	Spread_5:	.byte 9, 11, 13, 15
				.byte 2, 6, 8, 11, 13, 17, 18, 21
				.byte 2, 6, 8, 11, 13, 17, 18, 21
				.byte 1, 3, 7, 9, 11, 13, 15, 17, 21, 23
				.byte 1, 3, 7, 9, 11, 13, 15, 17, 21, 23



	Row:		.byte 0, 0
				.byte 2, 2, 2, 2, 2, 2
				.byte 4, 4, 4, 4, 4, 4, 4, 4
				.byte 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
				.byte 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
				.byte 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
				.byte 9, 9
				
	Frames:		.byte 0, 1
				.byte 0, 1, 0, 1, 0, 1
				.byte 0, 1, 0, 1, 0, 1, 0, 1
				.byte 0, 1, 0, 1, 0, 1, 0, 1, 0, 1
				.byte 0, 1, 0, 1, 0, 1, 0, 1, 0, 1
				.byte 0, 1, 0, 1, 0, 1, 0, 1, 0, 1
				.byte 0, 1


	Home_Row:	
				.byte 0, 0
				.byte 2, 2, 2, 2, 2, 2
				.byte 4, 4, 4, 4, 4, 4, 4, 4
				.byte 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
				.byte 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
				.byte 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
				.byte 9, 9

	Spread_R1:	
				.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 4, 4, 4, 4, 4, 4, 4, 4
				.byte 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
				.byte 9, 9, 9, 9, 9, 9, 9, 9, 9, 9

	Spread_R2:	.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 4, 4, 4, 4, 4, 4, 4, 4
				.byte 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
				.byte 9, 9, 9, 9, 9, 9, 9, 9, 9, 9

	Spread_R3:	.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 4, 4, 4, 4, 4, 4, 4, 4
				.byte 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
				.byte 9, 9, 9, 9, 9, 9, 9, 9, 9, 9

	Spread_R4:	.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 5, 5, 5, 5, 5, 5, 5, 5
				.byte 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
				.byte 10, 10, 10, 10, 10, 10, 10, 10, 10, 10


	Spread_R5:	.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 5, 5, 5, 5, 5, 5, 5, 5
				.byte 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
				.byte 10, 10, 10, 10, 10, 10, 10, 10, 10, 10




	SpreadLookupR:	.word Home_Row, Spread_R1, Spread_R2, Spread_R3, Spread_R4, Spread_R5

	SpreadLookup:	.word Home_Column, Spread_1, Spread_2, Spread_3, Spread_4, Spread_5

	//Spread_Order:	.byte 0, 3, 4, 11, 12, 19, 20, 29, 30, 39


		Type:	.byte 0, 0	// 0-3
				.byte 1, 1, 1, 1, 1, 1 // 4-11
				.byte 2, 2, 2, 2, 2, 2, 2, 2 // 12-19
				.byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 // 20-29
				.byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 // 30-39
				.byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 // 30-39
				.byte 4, 4, 4 // 40-42



	Occupied:	.fill 48, 0


	ExplosionTimer: .fill MAX_EXPLOSIONS, 0
	ExplosionList:	.fill MAX_EXPLOSIONS, 255
	ExplosionProgress:	.fill MAX_EXPLOSIONS, 0
	ExplosionX:		.fill MAX_EXPLOSIONS, 0
	ExplosionY:		.fill MAX_EXPLOSIONS, 0

	ExplosionColour:	.byte WHITE + 8, YELLOW + 8, YELLOW + 8, YELLOW + 8


	Mode:		.byte FORMATION_UNISON

	Position:	.byte 0
	PreviousPosition: .byte 0
	Direction:	.byte 1
	Speeds:		.byte 12, 18
	SpreadPosition:	.byte 0



	Frame:			.byte 0
	CurrentSlot:	.byte 255
	FrameCounter:	.byte 0

	ColumnSpriteX:	.fill 40, 24 + (i * 8)
	RowSpriteY:		.fill 25, 50 + (i * 8)
	

	TypeCharStart:		.byte 169, 181, 189, 189, 246, 232 
	Colours:			.byte YELLOW + 8, YELLOW + 8, PURPLE + 8, CYAN + 8, YELLOW + 8, GREEN + 8
	TransformColours:	.byte GREEN + 8, YELLOW + 8, GREEN + 8, CYAN + 8, YELLOW + 8, GREEN + 8

	TransformProgress:	.byte 0
	TransformTimer:		.byte 0
	TransformID:		.byte 255


	Initialise: {

		ldx #0

		Loop:

			lda Home_Column, x
			sta Column, x
			sta PreviousColumn, x
			lda Home_Row, x
			sta Row, x
			sta PreviousRow, x

			lda Hits, x
			sta HitsLeft, x

			//jsr RANDOM.Get
			//and #%00000001

			lda #0
			sta Occupied, x
		
			inx
			cpx #48
			bcc Loop


		lda #0
		sta Position
		sta PreviousPosition
		sta CurrentSlot
		sta FrameCounter
		sta SpreadPosition
		sta Switching
		sta Stop
	

		lda #1
		sta Direction
		sta Frame
		

		lda #STAGE.NumberOfWaves * 8
		sta Alive

		lda #FORMATION_UNISON
		sta Mode

		lda #255
		sta TransformID


		rts
	}


	


	StartTransform: {

		sty TransformID

		lda #0
		sta TransformProgress

		lda #TransformTime
		sta TransformTimer

		rts
	}

	SpreadFormation: {

		FrameChange:

			ldx Mode
			lda Speeds, x
			sta FrameCounter

			lda Frame
			beq MakeOne	

			MakeZero:

				dec Frame
				lda SpreadPosition
				clc
				adc Direction
				sta SpreadPosition

				jmp CheckTurnAround

			MakeOne:

				inc Frame


		CheckTurnAround:

			lda SpreadPosition
			cmp #255
			beq TurnAroundLeft

			cmp #6
			beq TurnAroundRight

			jmp NowDraw

		TurnAroundRight:

			lda #255
			sta Direction

			lda #4
			sta SpreadPosition

			jmp NowDraw

		TurnAroundLeft:

			lda #1
			sta Direction

			lda #1
			sta SpreadPosition

		NowDraw:

		lda SpreadPosition
		asl	
		tax

		ldy #0

		lda SpreadLookup, x
		sta ZP.TextAddress

		lda SpreadLookup + 1, x
		sta ZP.TextAddress + 1

		lda SpreadLookupR, x
		sta ZP.ColourAddress

		lda SpreadLookupR + 1, x
		sta ZP.ColourAddress + 1

		Loop:

			lda (ZP.TextAddress), y
			sta Column, y

			lda (ZP.ColourAddress), y
			sta Row, y

			iny
			cpy #48
			bcc Loop


			lda Direction
			bmi StartFrom0

			lda #47
			sta CurrentSlot
			jmp Finish

		StartFrom0:

			lda #0
			sta CurrentSlot
			

		Finish:	




		rts
	}	



	EnemyKilled: {

		dec Alive

		lda Alive
		bmi Error
		// clc
	 // 	adc #48
		// sta SCREEN_RAM + 438

		// lda #1
		// sta VIC.COLOR_RAM + 438

		rts

		Error:

			//.break
			nop


		rts
	}

	Delete: {

		stx ZP.FormationID

		cpx #48
		bcc NoError

		rts
		clc

	NoError:

		lda PreviousColumn, x
		sta ZP.Column

	TopLeft:

		lda PreviousRow, x
		tay
		ldx ZP.Column

		jsr PLOT.GetCharacter

		jmp Okay

		ldx STAGE.CurrentWave
		beq Okay

		cmp #161
		bcc NotEnemy

		cmp #197
		bcs NotEnemy

		jmp Okay

	NotEnemy:

		.break
		nop

		ldx ZP.FormationID
		lda PreviousColumn, x
		tay

		lda Column, x
		clc
		adc Position



	Okay:

		ldy #0
		lda #0
		sta (ZP.ScreenAddress), y
		
	TopRight:

		iny
		sta (ZP.ScreenAddress), y

	BottomRight:

		ldy #41
		sta (ZP.ScreenAddress), y

	BottomLeft:

		dey
		sta (ZP.ScreenAddress), y

		ldx ZP.FormationID

		rts

	}

	DeleteAll: {

		ldx #0

		Loop:

			stx ZP.StoredXReg

			lda #0
			sta Occupied, x

			jsr Delete

			EndLoop:

				ldx ZP.StoredXReg
				inx
				cpx #48
				bcc Loop


		rts
	}

	DrawOne: {

		stx ZP.FormationID

		lda Column, x
		clc
		adc Position
		sta ZP.Column
		sta PreviousColumn, x

		lda Type, x
		//sec
		//sbc HitsLeft, x

		tay
		lda TypeCharStart, y
		sta ZP.CharID

		lda Frame
		asl
		asl
		clc
		adc ZP.CharID
		sta ZP.CharID

		lda Colours, y
		sta ZP.Colour

		lda Row, x
		sta PreviousRow, x
		tay
		ldx ZP.Column

		jsr DrawFourCorners

		ldx ZP.FormationID

		rts



	}

	


		

	DrawFourCorners: {

		TopLeft:

			lda ZP.CharID

			jsr PLOT.PlotCharacter
			lda ZP.Colour
			jsr PLOT.ColorCharacter

			inc ZP.CharID

		TopRight:

			iny
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			inc ZP.CharID

		BottomRight:

			ldy #41
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			inc ZP.CharID

		BottomLeft:

			dey
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y


		rts
	}

	DeleteExplosion: {

		stx ZP.FormationID

		lda ExplosionX, x
		sta ZP.Column
		
	TopLeft:

		lda ExplosionY, x
		tay
		ldx ZP.Column

		lda #0
		jsr PLOT.GetCharacter


		bmi TopRight

		ldy #0
		lda #0
		sta (ZP.ScreenAddress), y
		
	TopRight:

		ldy #1
		lda (ZP.ScreenAddress), y
		bmi BottomRight

		lda #0
		sta (ZP.ScreenAddress), y

	BottomRight:

		ldy #41
		lda (ZP.ScreenAddress), y
		bmi BottomLeft

		lda #0
		sta (ZP.ScreenAddress), y

	BottomLeft:

		ldy #40
		lda (ZP.ScreenAddress), y
		bmi Finish

		lda #0
		sta (ZP.ScreenAddress), y

		ldx ZP.FormationID
		
		Finish:

		rts
	}


	DrawExplosion: {

		TopLeft:

			jsr PLOT.GetCharacter

			bmi TopRight

			ldy #0
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y


		TopRight:

			inc ZP.CharID

			iny
			lda (ZP.ScreenAddress), y
			bmi BottomRight

			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			

		BottomRight:

			inc ZP.CharID

			ldy #41

			lda (ZP.ScreenAddress), y
			bmi BottomLeft

			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

		
		BottomLeft:

			inc ZP.CharID

			dey
			lda (ZP.ScreenAddress), y
			bmi Finish

			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

		Finish:

		rts
	}

	ProcessExplosion: {

		lda ExplosionTimer, x
		beq ReadyToDraw

		dec ExplosionTimer, x
		rts

		ReadyToDraw:


		DeleteFirst:


			jsr DeleteExplosion

			ldx ZP.StoredXReg
			lda ExplosionProgress, x
			cmp #4
			bcc NowDraw

			lda #255
			sta ExplosionList, x
			jmp Finish


		NowDraw:

			ldx ZP.StoredXReg

			lda #EXPLOSION_TIME
			sta ExplosionTimer, x

			lda ExplosionProgress, x
			asl
			asl
			clc
			adc #ExplosionChar
			sta ZP.CharID

			lda ExplosionProgress, x
			tay
			lda ExplosionColour, y
			sta ZP.Colour

			ldx ZP.StoredXReg

			lda ExplosionX, x
			sta ZP.Column

			lda ExplosionY, x
			tay

			ldx ZP.Column

			jsr DrawExplosion

			
			ldx ZP.StoredXReg
			inc ExplosionProgress, x
			


		Finish:


		rts
	}

	CheckExplosions: {

		ldx #0

		Loop:

			stx ZP.StoredXReg
			lda ExplosionList, x
			bmi EndLoop	

			sta ZP.CurrentID

			jsr ProcessExplosion

		EndLoop:

			ldx ZP.StoredXReg
			inx
			cpx #MAX_EXPLOSIONS
			bcc Loop


		rts
	}

	AddExplosion: {


		ldy #0

		Loop:

			lda ExplosionList, y
			bmi Found

			iny
			cpy #MAX_EXPLOSIONS
			beq Exit

			jmp Loop

		Exit:

			rts

		Found:

			txa
			sta ExplosionList, y

			lda Column, x
			clc
			adc Position
			sta ExplosionX, y

			lda Row, x
			sta ExplosionY, y

			lda #0
			sta ExplosionTimer, y
			sta ExplosionProgress, y



			rts
	}

	Hit: {

		lda HitsLeft, x
		sta ZP.SoundFX
		beq Destroy

		dec HitsLeft, x

		stx ZP.FormationID

		jsr STATS.Hit

		ldx ZP.FormationID
		
		jsr Delete
		jsr DrawOne
		jmp NoDelete

		Destroy:

			lda #$52

			jsr EnemyKilled

			lda #0
			sta Occupied, x

			stx ZP.FormationID

			jsr ATTACKS.CheckBeamBossHit

			lda #PLAN_INACTIVE
			sta Plan, x
			sta NextPlan, x

			lda Type, x
			tay
			sec
			sbc ZP.SoundFX

			sfxFromA()


			lda TypeToScore, y
			tay

			jsr SCORE.AddScore

			ldx ZP.FormationID

			jsr AddExplosion
			jsr Delete




		NoDelete:

		


		rts
	}

	CheckDraw: {

		lda CurrentSlot
		bpl NotExit

		jmp Finish


		NotExit:

		lda Direction
		bmi ZeroTo39

			lda CurrentSlot
			sec
			sbc #UpdatesPerFrame
			sta ZP.EndID


			jmp Loop

		ZeroTo39:

			lda CurrentSlot
			clc
			adc #UpdatesPerFrame
			sta ZP.EndID


		Loop:

			ldx CurrentSlot

			lda Occupied, x
			beq EndLoop

			jsr Delete

			ldx CurrentSlot

			lda Column, x
			clc
			adc Position
			sta PreviousColumn, x
			sta ZP.Column

			lda Type, x
			//sec
			//sbc HitsLeft, x

			tay

			CheckTransform:

				lda Frame
				beq NotTransform

				cpx TransformID
				bne NotTransform

				iny
				iny

			NotTransform:

				lda TypeCharStart, y
				sta ZP.CharID

				tya
				pha

				txa
				clc
				adc Frame
				tay

				lda Frames, y	
				asl
				asl
				clc
				adc ZP.CharID
				sta ZP.CharID

				pla
				tay

				lda Colours, y
				sta ZP.Colour

			RowAndColumn:

				lda Row, x
				sta PreviousRow, x
				tay
				ldx ZP.Column

				jsr DrawFourCorners



		EndLoop:

			lda CurrentSlot
			sec
			sbc Direction
			sta CurrentSlot
			cmp ZP.EndID
			beq Finish

			jmp Loop


		Finish:

			cmp #255
			beq AllDone

			cmp #48
			bne NotFinished

		AllDone:

			lda #255
			sta CurrentSlot

			lda Position
			sta PreviousPosition


		NotFinished:


			rts

	}

	CalculateEnemiesLeft: {

		lda #46
		sta EnemiesLeftInStage


		lda STAGE.StageIndex
		cmp #3
		bcc NotChallenging

		ChallengingStage:

		lda Alive
		sta EnemiesLeftInStage
		rts

		NotChallenging:

		lda ATTACKS.Active
		bne Calculate

		//lda #0
		//sta SCREEN_RAM
		//sta SCREEN_RAM + 1
		rts

		Calculate:

		ldx #0
		stx EnemiesLeftInStage

		Loop:

			lda FORMATION.Occupied, x
			beq CheckDive

			inc EnemiesLeftInStage


			CheckDive:

			cpx #MAX_ENEMIES
			bcs EndLoop

			lda ENEMY.Plan, x
			beq EndLoop

			inc EnemiesLeftInStage

			EndLoop:

				inx
				cpx #48
				bcc Loop

		Display:

			//lda #48
			//sta SCREEN_RAM
//
			lda EnemiesLeftInStage

		DisplayLoop:

			sec
			sbc #10
			bmi Done

			//inc SCREEN_RAM

			jmp DisplayLoop

			Done:

			

			

		rts

	}


	CheckTransform: {

		lda TransformID
		bmi Finish


		lda TransformTimer
		beq Ready

		dec TransformTimer
		rts

		Ready:

		lda #TransformTime
		sta TransformTimer

		inc TransformProgress
		lda TransformProgress
		cmp #TransformStages
		bcc Exit

		ldy TransformID
		lda Occupied, y
		bne EnemyStillAlive

		EnemyKilled:

			jsr ATTACKS.CancelTransforms
			jmp Finish

		EnemyStillAlive:

			jsr ATTACKS.StartTransforms

		Finish:

		lda #255
		sta TransformID

		Exit:

		rts
	}

	FrameUpdate: {

		SetDebugBorder(5)

		jsr CalculateEnemiesLeft
		jsr CheckTransform

		CheckWhetherActive:

			lda Mode
			bmi Finish

		Explosions:

			jsr CheckExplosions

		MoveCounter:



			lda FrameCounter
			beq ReadyToMove

		NotYet:

			dec FrameCounter
			jmp CheckDraw
			rts

		ReadyToMove:

			inc ENEMY.FormationUpdated

		CheckSwitchToSpread:

			lda Switching
			beq NoSwitch

			lda Position
			bne NoSwitch

			lda #FORMATION_SPREAD
			sta Mode

			jsr ATTACKS.AttackReady

			lda #0
			sta Switching

		NoSwitch:

			lda Mode
			cmp #FORMATION_UNISON
			bne NotInUnison

			jmp UnisonFormation

		NotInUnison:

			jmp SpreadFormation 

		Finish:



		SetDebugBorder(0)

			rts

	}


	UnisonFormation: {

		FrameChange:

			ldx Mode
			lda Speeds, x
			sta FrameCounter

			lda Stop
			beq NotStopped

			jmp NowDraw

		NotStopped:


			lda Frame
			beq MakeOne	

			MakeZero:

				dec Frame
				lda Position
				clc
				adc Direction
				sta Position

				jmp CheckTurnAround

			MakeOne:

				inc Frame

		CheckTurnAround:

			cmp #252
			beq TurnAroundLeft

			cmp #4
			beq TurnAroundRight

			jmp NowDraw

		TurnAroundRight:

			lda #255
			sta Direction

			lda #2
			sta Position

			jmp NowDraw

		TurnAroundLeft:

			lda #1
			sta Direction

			lda #254
			sta Position

		NowDraw:

			lda Direction
			bmi StartFrom0

			lda #47
			sta CurrentSlot
			jmp Finish

		StartFrom0:

			lda #0
			sta CurrentSlot
		

		Finish:	


		SetDebugBorder(0)

		rts
	}

}