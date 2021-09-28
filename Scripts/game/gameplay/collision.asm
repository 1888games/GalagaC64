


.namespace ENEMY {

	* = * "Enemies"

	.label LaunchWaveID= 24
	.label BottomCircleStartPoint = 220
	.label MaxY = 245
	.label MinY = 24
	.label MinYDisappear = 31
	.label MaxYDisappear = 235
	.label StandardEnemiesInWave = 8


	

	
	Explode: {

		lda ExplosionTimer, x
		beq Ready

		dec ExplosionTimer, x
		rts

		Ready:

			Okay:

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
			//sta SpriteX, x
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
		sbc #5
		clc
		adc #10

		cmp #15
		bcs CheckDualShip

		HitShip:

			jsr SHIP.KillMainShip
			jmp KillShip

		CheckDualShip:

			lda SHIP.DualFighter
			clc
			adc SHIP.TwoPlayer
			beq Finish

			lda SHIP.PosX_MSB + 1
			sec
			sbc SpriteX, x
			sec
			sbc #5
			clc
			adc #10

			cmp #15
			bcs Finish

		HitDualShip:

			jsr SHIP.KillDualShip

		KillShip:

			ldx ZP.EnemyID

			lda #10
			//sta SpriteX, x
			sta SpriteY, x

			lda #PLAN_INACTIVE
			sta Plan, x

			jsr Kill.Kamikaze

			ldx ZP.EnemyID
			

		Finish:



		rts
	}


	EnemyHitSFX: {

		lda ZP.Temp1
		sfxFromA()

		rts

	}


	CheckWaveBonus: {

		stx ZP.Temp4

		lda SHIP.TwoPlayer
		beq OnePlayer


	TwoPlayer:

		ldx BULLETS.PlayerShooting
		inc STAGE.KillCount, x

		jmp NoWaveBonus

	OnePlayer:

		inc STAGE.KillCount
		inc STAGE.WaveKillCount

	

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

		NoWaveBonus:

		
		ldx ZP.Temp4



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

			pha
			lda ATTACKS.ConvoySize, y
			sta ZP.Temp2
			pla

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

				ldy ZP.EnemyType
				sty ZP.Temp2
				lda FORMATION.ChallengeToScore, y
				tay

				jmp DoScore

			NormalStage:

				lda FORMATION.Mode
				//beq Formation

				jsr CheckTransformBonus

				ldy ZP.EnemyType
				lda FORMATION.TypeToScore, y
				clc
				adc #1
				clc
				adc ZP.Temp2
				tay
				sty ZP.Temp2

				jmp DoScore


			Formation:

				ldy ZP.EnemyType
				lda FORMATION.TypeToScore, y
				tay

			DoScore:

				jsr SCORE.AddScore

				ldx ZP.EnemyID


				ldy ZP.Temp2
				lda SCORE.PopupID, y
				tay
				beq NoPopup

				dey

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

	




}