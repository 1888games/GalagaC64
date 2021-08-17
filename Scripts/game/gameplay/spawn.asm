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
			sec
			sbc HitsLeft, x
			tay

		GetSpriteData:

			lda EnemyTypeFrameStart, y
			sta BasePointer, x
			sta SpritePointer, x

			cpy #4
			bcc NotSpecial

			jsr CalculateSpecialColour
			jmp DoneColour

		NotSpecial:

			lda Colours, y
			sta SpriteColor, x

		DoneColour:

				lda #0
				sta PreviousMoveX, x
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

		stx ZP.EnemyID

		lda STAGE.StageIndex
		cmp #3
		bcc NormalStage

		ChallengingStage:

			ldy STAGE.CurrentPlayer
			lda STAGE.ChallengeStage, y
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

	CheckExtraEnemy: {

		ldy #0
		lda  #0
		sta IsExtraEnemy, x

		lda STAGE.MaxExtraEnemies
		beq NoExtra

		Loop:

			lda STAGE.ExtraEnemyIDs, y
			cmp ZP.CurrentID
			beq IsExtra

			iny
			cpy STAGE.MaxExtraEnemies
			bcc Loop

			jsr CheckAddFighter
			
			lda ATTACKS.AddFighterToWave
			beq NotFighter

			inc AddingFighter
			dec ATTACKS.AddFighterToWave
			.break
			nop

			NotFighter:

			rts

		IsExtra:

			lda #1
			sta IsExtraEnemy, x
			rts

		NoExtra:	

			jsr CheckAddFighter

		rts
	}

	CheckAddFighter: {

		lda ATTACKS.AddFighterToWave
		beq NotFighter

		ldy STAGE.CurrentWave
		iny
		cpy #STAGE.NumberOfWaves
		bcc NotFighter

		ldy STAGE.SpawnedInWave
		iny
		cpy EnemiesInWave
		bne NotFighter

		inc AddingFighter
		dec ATTACKS.AddFighterToWave

		NotFighter:


		rts
	}

	Spawn: {

		ldx STAGE.SpawnedInWave
		cpx EnemiesInWave
		bcc AvailableToSpawn

		jmp Finish

		AvailableToSpawn:

			stx ZP.CurrentID

			jsr CheckExtraEnemy

			//inc EnemiesAlive
			
			lda #PLAN_PATH
			sta Plan, x

			lda STAGE.SpawnedInStage
			sta ZP.EndID

			lda IsExtraEnemy, x
			beq NoRevertID

			lda NextSpawnValue
			sta ZP.EndID

		NoRevertID:

			lda #0
			sta SpriteX_LSB
			sta SpriteY_LSB
			sta BOMBS.BombsLeft, x
			sta BOMBS.ShotTimer, x

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
			tay

			jmp SpritePointerAndColour

		NormalStage:

			lda AddingFighter
			beq NotFighter

		IsFighter:

			ldy #ENEMY_FIGHTER
			lda #8
			sta ZP.EndID

			jmp SpritePointerAndColour

		NotFighter:

			ldy ZP.EndID
			lda KindOrder, y
			tay

		SpritePointerAndColour:

			lda EnemyTypeFrameStart, y
			sta BasePointer, x
			sta SpritePointer, x

			lda Colours, y
			sta SpriteColor, x

			

			ldy ZP.EndID
			lda SpawnOrder, y
			sta Slot, x

			tay
			lda FORMATION.Hits, y
			sec
			sbc AddingFighter
			sta HitsLeft, x


			lda IsExtraEnemy, x
			beq GotoGrid

		DiveAway:


			lda #PLAN_DIVE_AWAY_LAUNCH
			sta NextPlan, x

			jmp DoneGridCheck

		GotoGrid:

			lda #PLAN_PATH
			sta FORMATION.Plan, y

			lda #PLAN_GOTO_GRID	
			sta FORMATION.NextPlan, y
			sta NextPlan, x


		DoneGridCheck:

			lda #255
			sta PositionInPath, x

			lda STAGE.SpawnSide
			sta Side, x

		SpritePosition:

			tay
			lda STAGE.StartX, y
			sta SpriteX, x

			lda STAGE.StartY,y
			sta SpriteY, x

			lda #0
			sta Angle, x


		AssignBombs:

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

			jsr GetNextMovement

			inc STAGE.SpawnedInWave

			lda IsExtraEnemy, x
			bne NoIncrementOverall
			
			lda STAGE.SpawnedInStage
			sta NextSpawnValue

			inc STAGE.SpawnedInStage

			NoIncrementOverall:
		
		Finish:

			

			rts
	}

}