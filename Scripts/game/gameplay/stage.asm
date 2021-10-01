STAGE: {

	* = * "Stage"

	ReadyNextWave:		.byte 0

	CurrentStage:	.byte 0, 0
	StageIndex:		.byte 0
	Players:		.byte 1
	ChallengeStage:	.byte 2, 0

	CurrentPlayer:	.byte 0
	CurrentWave:	.byte 0
	TransformTypes:	.byte 0, 0

	TransformType:	.byte 0

	CurrentWaveIDs:	.byte 0, 0



	StartX:		.byte 0, 0
	StartY:		.byte 0, 0

	SpawnSide:	.byte 0
	SpawnTimer:	.byte 0// set to 250 to test

	SpawnedInWave:		.byte 0
	SpawnedInStage:		.byte 0


	Every:		.byte 0
	Bullets:	.byte 0
	EveryCounter:	.byte 0

	DelayTimer:	.byte 0

	KillCount:			.byte 0, 0
	WaveKillCount:		.byte 0, 0
	TransformsKilled:	.byte 0

	MaxExtraEnemies:	.byte 0
	ExtraEnemies:		.byte 0


	ExtraEnemyIDs:		.byte 0, 0, 0, 0

	SpriteAddresses:	.fillword 6, SPRITE_SOURCE + (i * (16 *  64))
	TransformSpriteIDs:	.byte 1, 3, 4
	ChallengeSpriteIDs: .byte 0, 0, 0, 1, 2, 3, 4, 5
	SoftlockProtect:	.byte 0, 0
	SoftlockTimer:		.byte 255

	.label SpawnGap = 8
	.label NumberOfWaves = 5
	.label DelayTime = 40
	.label WaveYAdjust = 8
	.label NumChallengeStages = 8





	NewGame: {

		lda #0
		sta CurrentWave
		sta CurrentStage
		sta CurrentStage + 1
		sta ReadyNextWave
		sta TransformTypes
		sta TransformTypes + 1
		sta TransformType
	
		sta SpawnedInWave
		sta SpawnedInStage
		sta Every
		sta Bullets
		sta EveryCounter
		sta DelayTimer
		sta SpawnTimer
		sta MaxExtraEnemies
		sta SoftlockProtect
		sta SoftlockProtect + 1

		lda #255
		sta ChallengeStage
		sta ChallengeStage + 1
		sta SoftlockTimer

		lda #250
		sta SpawnTimer

		lda #0
		sta CurrentStage


		rts
	}

	CalculateStageIndex: {

		ldx CurrentPlayer
		lda CurrentStage, x
		clc
		adc #1

		cmp #2
		bcc IndexIsTwo

		cmp #1
		beq IndexIsOne

		and #%00000011
		sta StageIndex

		cmp #3
		bcc Finish

		ChallengingStage:

			lda ZP.Amount
			bmi Finish

			inc ChallengeStage, x

			lda ChallengeStage, x
			cmp #NumChallengeStages
			bcc NoWrap

			lda #0
			sta ChallengeStage, x

		NoWrap:

			clc
			adc StageIndex
			sta StageIndex

			rts

		IndexIsOne:	

			lda #1
			sta StageIndex
			jmp Finish


		IndexIsTwo:	

			lda #2
			sta StageIndex

		Finish:

			rts

	}

	CalculateFiring: {

		lda #0
		sta Every
		sta Bullets

		lda StageIndex
		cmp #3
		bcs ChallengingStage

		ldx CurrentPlayer
		lda CurrentStage, x

		cmp #1
		bcc Finish

		cmp #2
		beq EveryFourth

		cmp #7
		bcs EveryOtherEnemy

		EveryFourth:

			lda #4
			sta Every

			jmp OneBullet

		EveryThird:

			lda #3
			sta Every

			jmp OneBullet

		EveryOtherEnemy:

			cmp #10
			beq Finish

			lda #2
			sta Every

			jmp OneBullet

		CalcBullets:

			lda CurrentStage, x
			cmp #5
			bcc OneBullet

			jsr RANDOM.Get
			and #%00000001
			clc
			adc #1
			sta Bullets
			jmp Finish

		OneBullet:

			inc Bullets
			jmp Finish

		ChallengingStage:


		Finish:


		rts
	}


	CalculateExtraEnemies: {
		//	
	//	rts

		lda #255
		sta ExtraEnemyIDs
		sta ExtraEnemyIDs + 1
		sta ExtraEnemyIDs + 2
		sta ExtraEnemyIDs + 3

		lda StageIndex
		cmp #3
		bcs NoExtra

		ldx CurrentPlayer
		lda CurrentStage, x
		cmp #3
		bcc NoExtra

		FourExtra:

			cmp #9
			bcc TwoExtra

			lda #4
			sec
			sbc ATTACKS.AddFighterToWave
			sta MaxExtraEnemies

			jmp NoExtra

		TwoExtra:

			lda #2
			sta MaxExtraEnemies

		NoExtra:

			lda MaxExtraEnemies
			sta ExtraEnemies
			clc
			adc #8
			sta ENEMY.EnemiesInWave

		lda MaxExtraEnemies
		beq DontCalculatePositions

		ldx #0

		Loop:

			stx ZP.StoredXReg

			jsr RANDOM.Get
			and #%00000111
			cmp ENEMY.EnemiesInWave
			bcs Loop

			ldy ZP.StoredXReg

		ExistLoop:

			cpy #0
		
			beq NoCheck

			dey
			cmp ExtraEnemyIDs, y
			beq Loop

			jmp ExistLoop

		NoCheck:

			sta ExtraEnemyIDs, x

			inx
			cpx MaxExtraEnemies
			bcc Loop





		DontCalculatePositions:


		rts
	}

	ClearSprites: {

		ldx #0

		lda #10

		Loop:

			sta SpriteY, x

			inx
			cpx #MAX_SPRITES - 2
			bcc Loop



		rts
	}

	GetStageData: {

		jsr ClearSprites

		lda #0
		sta CurrentWave
		sta SoftlockProtect
		sta SoftlockProtect + 1
		sta SpawnedInWave
		sta SpawnedInStage
		sta ATTACKS.Active
		sta KillCount
		sta KillCount + 1
		sta TransformsKilled
		sta WaveKillCount
		sta WaveKillCount + 1
		sta MaxExtraEnemies
		sta ENEMY.EnemiesAlive
		sta ENEMY.NextSpawnValue
		sta ENEMY.AddingFighter

		lda #DelayTime
		sta DelayTimer

		dec CurrentWave

		lda #0
		sta ZP.Amount
		jsr CalculateStageIndex

		asl
		tax

		lda StageIndexLookup, x
		sta ZP.StageWaveOrderAddress

		lda StageIndexLookup + 1, x
		sta ZP.StageWaveOrderAddress + 1


		jsr CalculateExtraEnemies

		jsr CalculateFiring

		ldx CurrentPlayer
		lda TransformTypes, x
		sta TransformType

		jsr CopySpriteData

		jsr UpdateTransformType

		lda #1
		sta STAGE.ReadyNextWave


	
		//lda #30
		//sta SpawnTimer


		rts
	}


	UpdateTransformType: {


		lda STAGE.CurrentStage
		cmp #3
		bcc NoTransformIncrease

		lda STAGE.StageIndex
		cmp #3
		bcs NoTransformIncrease

		ldx CurrentPlayer
		inc TransformTypes, x

		lda TransformTypes, x
		cmp #3
		bcc NoTransformIncrease

		lda #0
		sta TransformTypes, x

		NoTransformIncrease:

		rts

	}

	CopySpriteData: {



		lda STAGE.StageIndex
		cmp #3
		bcc NormalStage

		ChallengeStage:

			ldx STAGE.CurrentPlayer
			lda STAGE.ChallengeStage, x
			tax
			lda ChallengeSpriteIDs, x
			asl
			tax
			jmp SetupAddresses

		NormalStage:

			ldx STAGE.TransformType
			lda TransformSpriteIDs, x
			asl
			tax

		SetupAddresses:

			lda SpriteAddresses, x
			sta ZP.RightPathAddressX

			lda SpriteAddresses + 1, x
			sta ZP.RightPathAddressX + 1

			lda #<$C440
			sta ZP.LeftPathAddressY

			lda #>$C440
			sta ZP.LeftPathAddressY + 1


		CopyData:

			ldx #0
			ldy #0

		Loop:

			lda (ZP.RightPathAddressX), y
			sta (ZP.LeftPathAddressY), y

			iny
			bne Loop

			inx
			cpx #4
			beq Done

			inc ZP.RightPathAddressX + 1
			inc ZP.LeftPathAddressY + 1

			jmp Loop


		Done:



		rts
	}

	GetWaveData: {


		lda #DelayTime
		sta DelayTimer

		lda StageIndex
		cmp #3
		bcc NormalStage

		lda #50
		sta SpawnTimer

		NormalStage:

		lda ENEMY.EnemiesInWave
		sta ENEMY.EnemiesAlive

		lda #0
		sta EveryCounter
		sta WaveKillCount


		lda CurrentWaveIDs
		asl
		tax
		lda WaveStartPos, x

		sta StartX

		lda WaveStartPos + 1, x
		sec
		sbc #WaveYAdjust
		sta StartY


		lda CurrentWaveIDs + 1
		asl
		tax
		lda WaveStartPos, x
	

		sta StartX + 1

		lda WaveStartPos + 1, x
		sec
		sbc #WaveYAdjust
		sta StartY + 1


		lda CurrentWaveIDs
		asl
		tax

		lda X_Paths, x
		sta ZP.LeftPathAddressX

		lda X_Paths + 1, x
		sta ZP.LeftPathAddressX + 1

		lda Y_Paths, x
		sta ZP.LeftPathAddressY

		lda Y_Paths + 1, x
		sta ZP.LeftPathAddressY + 1


		lda CurrentWaveIDs + 1
		asl
		tax

		lda X_Paths, x
		sta ZP.RightPathAddressX

		lda X_Paths + 1, x
		sta ZP.RightPathAddressX + 1

		lda Y_Paths, x
		sta ZP.RightPathAddressY

		lda Y_Paths + 1, x
		sta ZP.RightPathAddressY + 1




		rts
	}


	MoveIntoFormationMode: {

		lda #1
		sta FORMATION.Switching

		lda #0
		sta SpawnedInWave

		lda #255
		sta SpawnTimer

		lda #SUBTUNE_DANGER
		jsr sid.init


		rts
	}

	GetNextWave: {

		inc CurrentWave
		
		ldy CurrentWave
		cpy #NumberOfWaves
		bcc MoreWaves

	AllWavesDone:

		lda #255
		sta SpawnTimer

		lda StageIndex
		cmp #3
		bcc NotChallenge

	Challenging:

		lda #0
		sta SpawnedInWave

		rts


	NotChallenge:

		jmp MoveIntoFormationMode	

	MoreWaves:

		//jsr ENEMY.ClearData

		lda #30
		sta SpawnTimer

		//jsr ClearSprites

		cpy #NumberOfWaves - 1
		bne NotLastWave

		lda STAGE.StageIndex
		cmp #3
		bcs ChallengingStage

		IsNormal:

			lda ENEMY.EnemiesInWave
			clc
			adc ATTACKS.AddFighterToWave
			sta ENEMY.EnemiesInWave

		ChallengingStage:

			lda #50
			sta SpawnTimer

		NotLastWave:
	

			lda #0
			sta SpawnedInWave
			sta SpawnSide

			tya
			asl
			tay
			
			lda (ZP.StageWaveOrderAddress), y
			sta CurrentWaveIDs

			iny
			lda (ZP.StageWaveOrderAddress), y
			sta CurrentWaveIDs + 1

			jsr GetWaveData
			
		Finish:

		rts

	}


	TestFormation: {

		lda #NumberOfWaves * 8
		sta FORMATION.Alive

		lda #NumberOfWaves
		sta CurrentWave


		ldx #0

		Loop:

			lda #PLAN_GRID
			sta FORMATION.Plan, x

			lda #1
			sta FORMATION.Occupied, x

			lda #0
			sta FORMATION.HitsLeft, x

			inx
			cpx #46
		//	cpx #1
			bcc Loop


		jsr MoveIntoFormationMode

		lda #0
		sta FORMATION.Mode

		lda #0
		sta FORMATION.Switching

	//	jsr ATTACKS.AttackReady




		rts
	}


	* = * "Check Complete"

	CheckComplete: {	

/*
	
	lda #WHITE
		sta VIC.COLOR_RAM + 558
		sta VIC.COLOR_RAM + 598
		sta VIC.COLOR_RAM + 638
		sta VIC.COLOR_RAM + 678
		sta VIC.COLOR_RAM + 718*/



		lda FORMATION.EnemiesLeftInStage
		//sta SCREEN_RAM + 558
		bne LevelNotComplete

		lda ATTACKS.OrphanedFighterColumn
		//sta SCREEN_RAM + 598
		bne LevelNotComplete

		lda SHIP.Recaptured
		//sta SCREEN_RAM + 638
		bne LevelNotComplete

		lda SHIP.Active
		//sta SCREEN_RAM + 678
		beq LevelNotComplete

		lda DelayTimer
		beq FinishLevel
			
		dec DelayTimer
		rts

		FinishLevel:

			lda BULLETS.ActiveBullets
			clc
			adc BOMBS.ActiveBombs
			//sta SCREEN_RAM + 718
			bne LevelNotComplete

		LevelComplete:

			lda #0
			sta FORMATION.Mode

			jsr play_background

			inc CurrentStage

			lda CurrentStage
			cmp #255
			bcc NoWrap

			lda #0
			sta CurrentStage

		NoWrap:

			lda STAGE.StageIndex
			cmp #3
			bcc NormalStage

		ChallengeStage:

			jsr CHALLENGE.Initialise
			rts

		NormalStage:

			lda #GAME_MODE_PRE_STAGE
			sta MAIN.GameMode

			lda #1
			sta PRE_STAGE.Progress
			sta SpawnTimer
			sta PRE_STAGE.NewStage


		LevelNotComplete:




		rts
	}

	CheckSoftlock: {

		lda SoftlockProtect
		clc
		adc #1
		sta SoftlockProtect

		lda SoftlockProtect + 1
		adc #0
		sta SoftlockProtect + 1

		cmp #5
		bcc Okay

		.break
		
		Okay:


		rts
	}

	FrameUpdate: {

		lda SpawnTimer
		cmp #250
		bne NoSkip

		jmp TestFormation

		NoSkip:

		//jsr CheckSoftlock
		jsr CheckSpawn
		jsr CheckComplete

		rts

	}



	CheckNewWave: {

		lda SHIP.Active
		bne Okay

		rts

		Okay:

		jsr GetNextWave

		lda #0
		sta ReadyNextWave

		

		rts
	}	


	* = * "Check Spawn"

	CheckSpawn: {


		CheckAllDone:

			lda SpawnTimer
			bmi Finish

		CheckIfNewWave:

			lda ReadyNextWave
			beq NotNewWave

			jmp CheckNewWave

		NotNewWave:

			lda SpawnTimer
			beq ReadyToSpawn

			dec SpawnTimer
			jmp Finish

		ReadyToSpawn:

		CheckDelay:

			lda SpawnSide
			bne Delay

			ldx CurrentWaveIDs
			lda AllowDelaySkip, x
			beq Delay

			lda CurrentWaveIDs
			sec
			sbc CurrentWaveIDs + 1
			bne NoDelay

		Delay:

			lda #SpawnGap
			sta SpawnTimer

		NoDelay:

			ldx SpawnedInWave
			cpx ENEMY.EnemiesInWave
			bcc AvailableToSpawn

			jsr CheckEnemies

			jmp Finish

		AvailableToSpawn:

			lda #255
			sta SoftlockTimer

			jsr ENEMY.Spawn

			lda SpawnSide  
			eor #%00000001
			sta SpawnSide

		Finish:

		rts
	}


	CheckEnemies: {

		lda #0
		sta ZP.Amount

		ldx #0

		Loop:

			lda ENEMY.Plan, x
			beq EndLoop

			inc ZP.Amount

			EndLoop:

			inx
			cpx #MAX_ENEMIES
			bcc Loop

		lda ZP.Amount
		cmp ENEMY.EnemiesAlive
		bcs Okay

		sta ENEMY.EnemiesAlive
		bne Okay

		lda #1
		sta ReadyNextWave
		

		Okay:


		rts
	}


}