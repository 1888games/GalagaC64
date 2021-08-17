


.namespace ENEMY {

	* = * "Enemies"

	
	.label LaunchWaveID= 24

	.label BottomCircleStartPoint = 220
	.label MaxY = 245
	.label MinY = 24

	.label MinYDisappear = 31
	.label MaxYDisappear = 235

	Angle:					.fill MAX_ENEMIES, 0

	PixelSpeedX:			.fill MAX_ENEMIES, 0
	PixelSpeedY:			.fill MAX_ENEMIES, 0
	FractionSpeedX:			.fill MAX_ENEMIES, 0
	FractionSpeedY:			.fill MAX_ENEMIES, 0

	ExplosionTimer:
	PositionInPath:			.fill MAX_ENEMIES, 0
		
	ExplosionProgress:
	Side:					.fill MAX_ENEMIES, 0
	
	BasePointer:			.fill MAX_ENEMIES, 0
	Plan:					.fill MAX_ENEMIES, 0
	NextPlan:				.fill MAX_ENEMIES, 0
	PreviousMoveX:			.fill MAX_ENEMIES, 0
	Slot:					.fill MAX_ENEMIES, 0
	HitsLeft:				.fill MAX_ENEMIES, 0
	PreviousMoveY:			.fill MAX_ENEMIES, 0
	IsExtraEnemy:			.fill MAX_ENEMIES, 0

	UltimateTargetSpriteY:	.fill MAX_ENEMIES, 0

	Quadrant:			.byte 0
	EnemiesInWave:		.byte 8
	FormationUpdated:	.byte 0
	EnemiesAlive:		.byte 0
	MoveX:				.byte 0
	MoveY:				.byte 0
	EnemyWithShipID:	.byte 0
	NextSpawnValue:		.byte 0
	AddingFighter:		.byte 0


	FlutterMoveX_Min:	.byte 30, 30
	FlutterMoveX_Max:	.byte 125, 50
	FlutterMoveY:		.byte 30, 40

	FlutterMode:		.byte 0

	EnemyTypeSFX:	.byte 0, 0, 1, 2, 1, 10

	ChallengeBonusLookup:	.byte 9, 9, 10, 10, 11, 11, 12, 12
	BonusSpriteLookup:		.byte 2, 2, 3, 3, 4, 4, 5, 5
	TransformSpriteLookup:	.byte 2, 5, 6


	.label StandardEnemiesInWave = 8

	NewGame: {

		lda #255
		sta EnemyWithShipID

		lda #0
		sta Quadrant
		sta FormationUpdated
		sta EnemiesAlive
		sta MoveX
		sta MoveY
		sta AddingFighter

		ldx #0

		jsr ClearData

	
		rts
	}


	
	ClearData: {

		ldx #0

		Loop:

			sta Side, x
			sta Angle, x
			sta BasePointer, x
			sta Plan, x
			sta PreviousMoveX, x
			sta Slot, x
			sta HitsLeft, x
			sta PreviousMoveY, x
			sta IsExtraEnemy, x
			sta UltimateTargetSpriteY, x

			inx
			cpx #MAX_ENEMIES
			bcc Loop

		rts
	}

	
	Explode: {

		lda ExplosionTimer, x
		beq Ready

		dec ExplosionTimer, x
		rts

		Ready:

			lda #FORMATION.EXPLOSION_TIME
			sta ExplosionTimer, x

			inc ExplosionProgress, x

			lda ExplosionProgress, x
			tay
			cpy #4
			bcs ExplosionDone

			lda ExplosionFrames, y
			sta SpritePointer, x

			lda #YELLOW
			sta SpriteColor, x

			rts

		ExplosionDone:

			lda #10
			sta SpriteX, x
			sta SpriteY, x

			lda #0
			sta Plan, x

			rts

	}




	


	CheckShipCollision: {

		lda SHIP.Active
		beq Finish

		lda SpriteY, x
		cmp #SHIP.SHIP_Y + 1
		bcs Finish

		cmp #SHIP.SHIP_Y - 16
		bcc Finish

		lda SHIP.PreviousX
		sec
		sbc SpriteX, x
		sec
		sbc #4
		clc
		adc #8

		cmp #15
		bcs CheckDualShip

		HitShip:

			jsr SHIP.KillMainShip
			jmp KillShip

		CheckDualShip:

			lda SHIP.DualFighter
			beq Finish

			lda SHIP.PosX_MSB + 1
			sec
			sbc SpriteX, x
			sec
			sbc #4
			clc
			adc #8

			cmp #15
			bcs Finish

		HitDualShip:

			jsr SHIP.KillDualShip

		KillShip:

			ldx ZP.StoredXReg

			lda #10
			sta SpriteX, x
			sta SpriteY, x

			lda #PLAN_INACTIVE
			sta Plan, x

			jsr Kill.Kamikaze

			ldx ZP.StoredXReg
			

		Finish:



		rts
	}


	EnemyHitSFX: {

		lda ZP.Temp1
		sfxFromA()

		rts

	}


	CheckWaveBonus: {

		inc STAGE.KillCount
		inc STAGE.WaveKillCount

		stx ZP.Temp4

		lda STAGE.StageIndex
		cmp #3
		bcc NoWaveBonus

		lda STAGE.WaveKillCount
		cmp #8
		bcc NoWaveBonus

		ldx STAGE.CurrentPlayer
		lda STAGE.ChallengeStage, x
		tay
		sty ZP.Temp3

		lda ChallengeBonusLookup, y
		tay
		
		jsr SCORE.AddScore

		
		ldy ZP.Temp3
		lda BonusSpriteLookup, y
		tay

		ldx ZP.Temp4
		lda SpriteX, x
		sta ZP.Column

		lda SpriteY, x
		sta ZP.Row

		jsr BONUS.ShowBonus

		ldx ZP.Temp4

		NoWaveBonus:


		rts
	}


	CheckTransformBonus: {

		stx ZP.EnemyID

		lda ZP.EnemyType
		cmp #ENEMY_TRANSFORM
		bne NotTransform

		inc STAGE.TransformsKilled

		lda STAGE.TransformsKilled
		cmp #3
		bcc NotTransform


		AddScore:

			lda #14
			clc
			adc STAGE.TransformType
			tay

			jsr SCORE.AddScore

		ShowPopup:

			ldy STAGE.TransformType
			lda TransformSpriteLookup, y
			tay

			ldx ZP.EnemyID

			lda SpriteX, x
			sta ZP.Column

			lda SpriteY, x
			sta ZP.Row

			jsr BONUS.ShowBonus

			ldx ZP.EnemyID

		NotTransform:

		rts
	}

	Kill: {

		txa
		pha

		jsr STATS.Hit

		pla
		tax

		lda HitsLeft, x
		sta ZP.SoundFX
		beq Destroy

		HitTwoHitter:

			dec HitsLeft, x

			lda #WHITE
			sta SpriteColor, x

			lda BasePointer, x
			clc
			adc #22
			sta BasePointer, x

			lda SpritePointer, x
			clc
			adc #22
			sta SpritePointer, x


			jmp StillEnemiesToDock

		Destroy:

			lda #PLAN_EXPLODE
			sta Plan, x

			lda #0
			sta ExplosionProgress, x

			lda ExplosionFrames
			sta SpritePointer, x

			lda #FORMATION.EXPLOSION_TIME
			sta ExplosionTimer, x

			lda #WHITE
			sta SpriteColor, x

			jsr CheckWaveBonus
//
		Kamikaze:	

			jsr BEAM.CheckEnemy

			stx ZP.Temp2

			lda IsExtraEnemy, x
			bne NotConvoyBoss

			lda Slot, x
			tax
			sta ZP.Amount

			jsr ATTACKS.AttackerKilled

			ldx ZP.Temp2
			ldy ZP.Amount

			lda #PLAN_INACTIVE
			sta FORMATION.Plan, y

			lda #0
			sta FORMATION.Occupied, y
			
			lda #$C4

			jsr FORMATION.EnemyKilled
			
		NotConvoyBoss:

			lda #0
			sta ZP.Temp2

			lda Slot, x
			tay
			sta ZP.Amount

			lda FORMATION.Type, y
			cmp #ENEMY_FIGHTER
			bcc NotFighter

			lda #0
			sta ATTACKS.AddFighterToWave

			lda FORMATION.Type, y

		NotFighter:

			cmp #2
			bcs NotBoss

			lda ATTACKS.ConvoySize, y
			sta ZP.Temp2

		NotBoss:

			tay
			sty ZP.EnemyType
			sec
			sbc ZP.SoundFX
			
			jsr EnemyHitSFX

			lda STAGE.StageIndex
			cmp #3
			bcc NormalStage

			Challenging:

				ldy #1
				jmp DoScore

			NormalStage:

				jsr CheckTransformBonus

				ldy ZP.EnemyType
				lda FORMATION.TypeToScore, y
				clc
				adc #1
				clc
				adc ZP.Temp2
				tay
				sty ZP.Temp2
	
			DoScore:

				jsr SCORE.AddScore

				ldx ZP.EnemyID

				ldy ZP.Temp2
				lda SCORE.PopupID, y
				tay
				beq NoPopup

				lda SpriteX, x
				sta ZP.Column

				lda SpriteY, x
				sta ZP.Row

				jsr BONUS.ShowBonus

				ldx ZP.EnemyID

			NoPopup:

				lda FORMATION.Mode
				cmp #FORMATION_SPREAD
				beq StillEnemiesToDock

				dec EnemiesAlive
				lda EnemiesAlive
				bne StillEnemiesToDock

				lda #1
				sta STAGE.ReadyNextWave

		StillEnemiesToDock:




		rts
	}

	FrameUpdate: {

		ldx #0

		Loop:

			stx ZP.StoredXReg

			lda Plan, x
			beq EndLoop

			cmp #PLAN_EXPLODE
			bne DontExplode

			jsr Explode
			jmp EndLoop

			DontExplode:

				lda FormationUpdated
				beq NotMovingTowardsGrid

				cmp #PLAN_GOTO_GRID
				beq GotoGrid

				cmp #PLAN_RETURN_GRID
				beq GotoGrid

				cmp #PLAN_RETURN_GRID_TOP
				beq GotoGridTop

				cmp #PLAN_WAIT_BEAM
				beq Waiting

				jmp NotMovingTowardsGrid

			GotoGridTop:

				jsr ReturnToGridFromTop
				jmp NotMovingTowardsGrid

			GotoGrid:

				jsr FindGridSlot

			NotMovingTowardsGrid:

				jsr CheckMove

			Waiting:

				lda Plan, x
				beq EndLoop

				jsr CheckShipCollision
				jsr BOMBS.CheckEnemyFire


		EndLoop:

			ldx ZP.StoredXReg
			inx
			cpx #MAX_ENEMIES
			bcc Loop

		Finish:

			lda #0
			sta FormationUpdated

		rts
	}	




}