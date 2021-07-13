STAGE: {


	CurrentStage:	.byte 0, 0
	StageIndex:		.byte 0
	Players:		.byte 1
	ChallengeStage:	.byte 2, 0

	CurrentPlayer:	.byte 0
	CurrentWave:	.byte 0

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

	KillCount:			.byte 0
	WaveKillCount:		.byte 0

	MaxExtraEnemies:	.byte 0
	ExtraEnemies:		.byte 0

	ExtraEnemyIDs:		.byte 0, 0, 0, 0

	.label SpawnGap = 8
	.label NumberOfWaves = 5
	.label DelayTime = 40
	.label WaveYAdjust = 8
	.label NumChallengeStages = 3





	NewGame: {

		lda #0
		sta CurrentWave
		sta CurrentStage
		sta CurrentStage + 1
	
		sta SpawnedInWave
		sta SpawnedInStage
		sta Every
		sta Bullets
		sta EveryCounter
		sta DelayTimer
		sta SpawnTimer
		sta MaxExtraEnemies

		lda #255
		sta ChallengeStage
		sta ChallengeStage + 1

		lda #250
		//sta SpawnTimer

		lda #9
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

		cmp #2
		bcc Finish

		cmp #6
		bcs EveryOtherEnemy

		EveryThird:

			lda #2
			sta Every

			jmp CalcBullets

		EveryOtherEnemy:

			cmp #10
			beq Finish

			lda #1
			sta Every

		CalcBullets:

			lda CurrentStage, x
			cmp #5
			bcc OneBullet

			lda #2
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
			and #%00001111
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

	GetStageData: {

		lda #0
		sta CurrentWave
		sta SpawnedInWave
		sta SpawnedInStage
		sta ATTACKS.Active
		sta KillCount
		sta WaveKillCount
		sta MaxExtraEnemies
		sta ENEMY.EnemiesAlive
		sta ENEMY.NextSpawnValue

		lda #DelayTime
		sta DelayTimer

		dec CurrentWave

		lda  #0
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

		jsr GetNextWave

		//lda #30
		//sta SpawnTimer


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

		jsr ATTACKS.AttackReady


		rts
	}

	GetNextWave: {

		inc CurrentWave

	
		
		ldy CurrentWave
		cpy #NumberOfWaves
		bcc MoreWaves

	AllWavesDone:

		lda StageIndex
		cmp #3
		bcc NotChallenge

	Challenging:

		lda #255
		sta SpawnTimer

		lda #0
		sta SpawnedInWave

		rts


	NotChallenge:

		jmp MoveIntoFormationMode	

	MoreWaves:

		//jsr ENEMY.ClearData
		

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
			cpx #NumberOfWaves * 8
			bcc Loop


		jsr MoveIntoFormationMode

		lda #1
		sta FORMATION.Mode

		lda #0
		sta FORMATION.Switching




		rts
	}


	CheckComplete: {	


		lda #WHITE
		sta VIC.COLOR_RAM + 558
		sta VIC.COLOR_RAM + 598
		sta VIC.COLOR_RAM + 638
		sta VIC.COLOR_RAM + 678
		sta VIC.COLOR_RAM + 718


		lda FORMATION.Alive
		sta SCREEN_RAM + 558
		bne LevelNotComplete

		lda ATTACKS.OrphanedFighterColumn
		sta SCREEN_RAM + 598
		bne LevelNotComplete

		lda SHIP.Recaptured
		sta SCREEN_RAM + 638
		bne LevelNotComplete

		lda SHIP.Active
		sta SCREEN_RAM + 678
		beq LevelNotComplete

		lda DelayTimer
		beq FinishLevel
			
		dec DelayTimer
		rts

		FinishLevel:

			lda BULLETS.ActiveBullets
			clc
			adc BOMBS.ActiveBombs
			sta SCREEN_RAM + 718
			bne LevelNotComplete

			lda #0
			sta FORMATION.Mode

			jsr play_background

			inc CurrentStage

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

	FrameUpdate: {

		lda SpawnTimer
		cmp #250
		bne NoSkip

		jmp TestFormation

		NoSkip:

		jsr CheckSpawn
		jsr CheckComplete

		rts

	}




	CheckSpawn: {


		lda SpawnTimer
		bmi Finish

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

			jsr ENEMY.Spawn

			lda SpawnSide  
			beq MakeOne

			dec SpawnSide
			jmp Finish

		MakeOne:

			inc SpawnSide

		Finish:

		rts
	}


}