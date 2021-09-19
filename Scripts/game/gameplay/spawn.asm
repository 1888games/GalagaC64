.namespace ENEMY {

	* = * "Spawn"

	SpecialColours:		.byte WHITE, CYAN, WHITE, GREEN, YELLOW, WHITE
	TransformColours:	.byte CYAN, GREEN, YELLOW

	GetNextAvailable: {

		ldx #0

		Loop:

			lda Plan, x
			cmp #PLAN_INACTIVE
			beq Found

			inx
			cpx #MAX_ENEMIES
			bcc Loop

		Found:

			stx ZP.CurrentID


		rts
	}
	

	LaunchFromGrid: {

		// y = GridID

		GetID_Setup:

			jsr GetNextAvailable

			sty ZP.Amount

			tya
			sta Slot, x

			inc EnemiesAlive
			inc STAGE.SpawnedInWave

			lda #PLAN_ATTACK
			sta Plan, x

		ResetStuff:

			lda #0
			sta SpriteX_LSB, x
			sta SpriteY_LSB, x
			sta IsExtraEnemy, x
			sta BOMBS.BombsLeft, x
			sta BOMBS.ShotTimer, x

		CopyHitsLeft:

			lda FORMATION.HitsLeft, y
			sta HitsLeft, x

		CalculateSpritePositions:

			lda FORMATION.Column, y
			tay
			lda FORMATION.ColumnSpriteX, y
			sta SpriteX, x

			ldy ZP.Amount
			lda FORMATION.Row, y
			tay
			lda FORMATION.RowSpriteY, y
			sta SpriteY, x


		CalculateSpritePointerColour:

			ldy ZP.Amount
			lda FORMATION.Type, y
			cmp #5
			bne NotFighter

			tay
			jmp GetSpriteData

		NotFighter:

			sec
			sbc HitsLeft, x
			tay

		GetSpriteData:

			lda EnemyTypeFrameStart, y
			sta BasePointer, x
			sta SpritePointer, x

			cpy #4
			beq Special

			cpy #5
			beq Fighter

			jmp NotSpecial

		Fighter:

			lda SpriteY, x
			sec
			sbc #16
			sta SpriteY, x

			lda #0
			sta HitsLeft, x

			jmp NotSpecial

		Special:

			jsr CalculateSpecialColour
			jmp DoneColour

		NotSpecial:

			lda Colours, y
			sta SpriteColor, x

		DoneColour:

				lda #0
				sta Angle, x


		SetUpLaunchPath:

			lda #255
			sta PositionInPath, x

			ldy ZP.Amount
			lda Mirror, y
			clc
			adc #LaunchWaveID
			sta PathID, x

			jsr GetNextMovement

			ldy ZP.Amount


		rts
	}


	CalculateSpecialColour: {

		lda STAGE.StageIndex
		cmp #3
		bcc NormalStage

		ChallengingStage:

			ldy STAGE.CurrentPlayer
			lda STAGE.ChallengeStage, y
			tay
			lda STAGE.ChallengeSpriteIDs, y
			tay

			lda SpecialColours, y
			sta SpriteColor, x
			rts

		NormalStage:

			ldy STAGE.TransformType
			lda TransformColours, y
			sta SpriteColor, x

		rts
	}

	

	CheckAddFighter: {

		lda STAGE.StageIndex
		cmp #3
		bcs NotFighter

		lda ATTACKS.AddFighterToWave
		beq NotFighter

		IsFighterWave:

			ldy STAGE.CurrentWave
			iny
			cpy #STAGE.NumberOfWaves
			bcc NotFighter

			ldy STAGE.SpawnedInWave
			iny
			cpy EnemiesInWave
			bne NotFighter

		IsFighter:

			inc AddingFighter
			dec ATTACKS.AddFighterToWave

			lda #ENEMY_FIGHTER
			sta ZP.EnemyType

			lda #8 // this makes slot = 0
			sta ZP.StageOrderID

		NotFighter:


		rts
	}


	CheckExtraEnemyOrFighter: {

		ldy #0
		lda #0
		sta IsExtraEnemy, x

		lda STAGE.MaxExtraEnemies
		beq Finish

		Loop:

			lda STAGE.ExtraEnemyIDs, y
			cmp ZP.EnemyID
			beq IsExtra

			iny
			cpy STAGE.MaxExtraEnemies
			bcc Loop

			jmp Finish

		IsExtra:

			lda #1
			sta IsExtraEnemy, x
			rts

		Finish:	

			jsr CheckAddFighter

		rts
	}



	CalculateStageOrderID: {

		lda STAGE.SpawnedInStage
		sta ZP.StageOrderID

		CheckIfExtraEnemy:

			lda IsExtraEnemy, x
			beq NotExtraEnemy

		ExtraEnemy:

			lda NextSpawnValue
			sta ZP.StageOrderID

		NotExtraEnemy:

		rts
	}

	SetupInitialEnemyState: {

		lda #0
		sta SpriteX_LSB, x
		sta SpriteY_LSB, x
		sta BOMBS.BombsLeft, x
		sta BOMBS.ShotTimer, x
		sta Angle, x
		sta ZP.EnemyType

		lda #255
		sta PositionInPath, x


		rts
	}


	CalculateEnemyType: {

		CheckIfFighter:

			lda ZP.EnemyType
			bne Finish

		CheckIfChallenging:
			
			lda STAGE.StageIndex
			cmp #3
			bcc NormalStage

		Challenging:	

			ldy STAGE.CurrentPlayer
			lda STAGE.ChallengeStage, y
			asl
			tay

			lda ChallengeSpawn, y
			sta ZP.TextAddress

			lda ChallengeSpawn + 1, y
			sta ZP.TextAddress + 1

			ldy STAGE.SpawnedInStage
			lda (ZP.TextAddress), y
			sta ZP.EnemyType

			rts

		NormalStage:

			ldy ZP.StageOrderID
			lda KindOrder, y
			sta ZP.EnemyType

		Finish:

			rts


	}


	CalculateSpriteData: {

		GetSide:

			lda STAGE.SpawnSide
			sta Side, x

		SpritePosition:

			tay
			lda STAGE.StartX, y
			sta SpriteX, x

			lda STAGE.StartY,y
			sta SpriteY, x

		PointerAndColour:

			ldy ZP.EnemyType

			lda EnemyTypeFrameStart, y
			sta BasePointer, x
			sta SpritePointer, x

			cpy #ENEMY_TRANSFORM
			bne NotSpecial

			jmp CalculateSpecialColour
		
		NotSpecial:

			lda Colours, y
			sta SpriteColor, x


		rts
	}
	
	// ZP.EnemyID = x = ID of new enemy,
	// ZP.WaveOrderID = 0-7 id of enemy, or enemy in front of a diver. 8 = fighter.
	// ZP.EnemyType = 0-3 Normal Enemy. 4 = special challenge enemy. 5 = fighter.
	
	CalculateSlotAndHits: {

		GetSlot:


			ldy ZP.StageOrderID
			lda SpawnOrder, y
			sta Slot, x

		Hits:

			tay
			lda FORMATION.Hits, y
			sec
			sbc AddingFighter
			sta HitsLeft, x


		rts
	}

	CalculatePlan: {

		// y = slot

		lda #PLAN_PATH
		sta FORMATION.Plan, y
		sta Plan, x

	GetNextPlan:

		lda IsExtraEnemy, x
		beq GotoGrid

	DiveAway:

		lda #PLAN_DIVE_AWAY_LAUNCH
		sta FORMATION.NextPlan, y
		sta NextPlan, x

		rts

	GotoGrid:

		lda #PLAN_GOTO_GRID	
		sta FORMATION.NextPlan, y
		sta NextPlan, x

		rts

	}


	CalculateBombs: {


			lda STAGE.Every
			beq NoBombs

			lda STAGE.EveryCounter
			beq AddBombs

			dec STAGE.EveryCounter

			lda STAGE.EveryCounter
			bpl Okay

			lda STAGE.Every
			sta STAGE.EveryCounter

		Okay:

			jmp NoBombs

		AddBombs:

			jsr BOMBS.Add

		NoBombs:



		rts
	}

	IncrementIDs: {

		inc STAGE.SpawnedInWave


		lda IsExtraEnemy, x
		bne NoIncrementOverall

		lda STAGE.SpawnedInStage
		sta NextSpawnValue
	
		inc STAGE.SpawnedInStage

		NoIncrementOverall:


		rts
	}

	Spawn: {

		stx ZP.EnemyID

		jsr SetupInitialEnemyState
		jsr CheckExtraEnemyOrFighter
		jsr CalculateStageOrderID
		jsr CalculateEnemyType
		jsr CalculateSpriteData
		jsr CalculateSlotAndHits
		jsr CalculatePlan
		jsr CalculateBombs
		jsr GetNextMovement
		jsr IncrementIDs

		rts
	}

}