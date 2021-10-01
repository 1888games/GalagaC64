BULLETS: {


	* = * "Bullets"
	
	BulletSpriteX:		.byte 0, 0, 0, 0
	SpriteY_MSB:	.byte 0, 0, 0, 0
	SpriteY_LSB:	.byte 0, 0, 0, 0


	CharX:		.byte 255, 255, 255, 255
	CharY:		.byte 0, 0, 0, 0

	OffsetX:	.byte 0, 0, 0, 0
	OffsetY:	.byte 0, 0, 0, 0


	CharLookups:	.byte 177, 178, 179, 180
	Cooldown:		.byte CooldownTime, CooldownTime
	MaxBullets:		.byte 1, 4
	BulletToDie:	.byte 0
	PlayerShooting:	.byte 0
	PlayerLookup:	.byte 0, 0, 1, 1

	.label SPEED_MSB = 4
	.label SPEED_LSB = 20
	.label CooldownTime = 3
	.label SpriteYOffset = 12

	ActiveBullets:		.byte 0, 0





	
	Fire2: {

		lda FORMATION.EnemiesLeftInStage
		clc
		adc ATTACKS.OrphanedFighterColumn
		bne CanFire	

			jmp AbortFire

		CanFire:

			sty ZP.Amount

			lda Cooldown + 1
			beq CooldownExpired

			jmp Finish

		CooldownExpired:

			ldx #2

		CheckOneBullet:

			lda ActiveBullets + 1
			cmp MaxBullets + 1
			bcs AbortFire


		FindLoop:

			lda CharX, x
			bmi SetupData

			inx
			cpx MaxBullets + 1
			bcc FindLoop

			jmp AbortFire

		SetupData:


			sfx(SFX_FIRE)

		NoSFX:

			lda #SHIP.CharY
			sta CharY, x
			
			lda SHIP.CharX + 1, y
			sta CharX, x

			lda #0
			sta SpriteY_LSB, x

			lda #SHIP.SHIP_Y
			sec
			sbc #SpriteYOffset
			sta SpriteY_MSB, x

			lda SHIP.PosX_MSB + 1, y
			sta BulletSpriteX, x

			lda #0
			sta OffsetY, x

			lda SHIP.OffsetX + 1, y
			lsr
			cmp #4
			bcc Okay

			
			.break
			nop

			
			ldy #0

		Okay:

			sta OffsetX, x

			inc ActiveBullets + 1

			jsr DrawBullet

			lda #1
			sta BULLETS.PlayerShooting

			jsr STATS.Shoot

		NoDual:

			lda #CooldownTime
			sta Cooldown + 1

		Finish:

			lda #0
			rts

		AbortFire:

			lda #255
			rts



		rts
	}

	
	Fire: {

		lda FORMATION.EnemiesLeftInStage
		clc
		adc ATTACKS.OrphanedFighterColumn
		bne CanFire	

			jmp AbortFire

		CanFire:

			sty ZP.Amount

			lda Cooldown
			beq CooldownExpired

			jmp Finish

		CooldownExpired:

			ldx #0

			lda SHIP.DualFighter
			beq CheckOneBullet

		CheckTwoBullet:

			lda ZP.Amount
			bne CheckOneBullet

			lda ActiveBullets
			cmp #3
			bcs AbortFire

		CheckOneBullet:

			lda ActiveBullets
			cmp MaxBullets
			bcs AbortFire


		FindLoop:

			lda CharX, x
			bmi SetupData

			inx
			cpx MaxBullets
			bcc FindLoop

			jmp AbortFire

		SetupData:


			cpy #1
			beq NoSFX

			sfx(SFX_FIRE)
			//sfx(SFX_BADGE)
				
		NoSFX:

			lda #SHIP.CharY
			sta CharY, x
			
			lda SHIP.CharX, y
			sta CharX, x

			lda #0
			sta SpriteY_LSB, x

			lda #SHIP.SHIP_Y
			sec
			sbc #SpriteYOffset
			sta SpriteY_MSB, x

			lda SHIP.PosX_MSB, y
			sta BulletSpriteX, x

			lda #0
			sta OffsetY, x

			lda SHIP.OffsetX, y
			lsr
			cmp #4
			bcc Okay

			lda #3

			.break
			nop

		Okay:

			sta OffsetX, x

			inc ActiveBullets

			jsr DrawBullet

			lda #0
			sta BULLETS.PlayerShooting

			jsr STATS.Shoot

			lda SHIP.DualFighter
			beq NoDual

			lda ZP.Amount
			bne NoDual

			jmp Finish

		NoDual:

			lda #CooldownTime
			sta Cooldown

		Finish:

			lda #0
			rts

		AbortFire:

			lda #255
			rts

	}


	DrawBullet: {

		lda CharX, x
		bmi Finish

		sta ZP.Column

		lda CharY, x
		sta ZP.Row

		lda OffsetX, x
		tay
		cpy #4
		bcc Okay

		.break
		nop


		Okay:

		lda CharLookups, y
		cmp #177
		bcc Error

		cmp #181
		bcs Error

		jmp NoError

		Error:

		.break
		nop

		NoError:


		ldx ZP.Column
		ldy ZP.Row

		jsr PLOT.PlotCharacter

		lda #YELLOW
		jsr PLOT.ColorCharacter


		Finish:

		rts

	}

	DeleteBullet: {

		lda CharX, x
		sta ZP.Column

		lda ZP.Temp1
		tay

		lda #0
		ldx ZP.Column

		jsr PLOT.PlotCharacter

		
		Finish:

		rts


	}


	Move: {

		ldx #0

		BulletLoop:	

			stx ZP.StoredXReg

			lda PlayerLookup, x
			sta PlayerShooting

			lda CharX, x
			bmi EndLoop


			lda CharY, x
			sta ZP.Temp1

			lda SpriteY_LSB, x
			sec
			sbc #SPEED_LSB
			sta SpriteY_LSB, x

			lda SpriteY_MSB, x
			sta ZP.Amount
			sbc #0
			sec
			sbc #SPEED_MSB
			sta SpriteY_MSB, x

			jsr CheckSpriteCollisions
			ldx ZP.StoredXReg


		CheckOffset:

			lda SpriteY_MSB, x
			sec
			sbc ZP.Amount
			clc
			adc OffsetY, x
			sta OffsetY, x

			bpl EndLoop

			clc
			adc #8
			sta OffsetY, x

			dec CharY, x
			bmi BulletDead

			jsr CheckFormationCollision

			
			ldx ZP.StoredXReg
			jsr DeleteBullet
			ldx ZP.StoredXReg
			jsr DrawBullet

			jmp EndLoop

		BulletDead:

			jsr CheckOrphanedCollision

			lda #1
			sta Cooldown

			jsr KillBullet

		EndLoop:

			ldx ZP.StoredXReg
			inx
			cpx #4
			bcc BulletLoop


			rts


	}


	CheckOrphanedCollision: {

		lda ATTACKS.OrphanedFighterColumn
		beq Finish

		sta ZP.Amount

		lda CharX, x
		sec
		sbc ZP.Amount
		cmp #2
		bcs Finish

		lda SpriteX + SHIP.MAIN_SHIP_POINTER + 1
		sta ZP.Column

		lda SpriteY + SHIP.MAIN_SHIP_POINTER + 1
		sta ZP.Row

		lda #10
		//sta SpriteX + SHIP.MAIN_SHIP_POINTER + 1
		sta SpriteY + SHIP.MAIN_SHIP_POINTER + 1

		lda #255
		sta ATTACKS.BeamBoss
		sta ATTACKS.OrphanedFighterID

		lda #0
		sta ATTACKS.BeamStatus
		sta ATTACKS.OrphanedFighterColumn
		sta ATTACKS.AddFighterToWave

		ldy #8
		jsr SCORE.AddScore

		ldy #2
		jsr BONUS.ShowBonus
	
		Finish:


		rts
	}


	KillBullet: {

		jsr DeleteBullet

		ldx ZP.StoredXReg
		lda #255
		sta CharX, x

		lda SHIP.TwoPlayer
		beq OnePlayer

		cpx #2
		bcc OnePlayer

		dec ActiveBullets + 1
		bpl Okay

		lda #0
		sta ActiveBullets + 1
		rts

		OnePlayer:

		dec ActiveBullets
		bpl Okay

		lda #0
		sta ActiveBullets


		Okay:

		lda #0
		sta FORMATION.Stop

		rts


	}


	CheckSpriteCollision: {
		
		ldx ZP.StoredXReg


		
		lda BULLETS.BulletSpriteX, x
		sec
		sbc #4
		sec
		ldx ZP.StoredYReg
		sbc SpriteX, x

		clc
		adc #6
		cmp #12

		bcs NoCollision

		ldx ZP.StoredXReg
		lda BULLETS.SpriteY_MSB, x
		sec
		ldx ZP.StoredYReg
		sbc SpriteY, x
		adc #8
		cmp #16
		bcs NoCollision


		jsr ENEMY.Kill

		lda #1
		sta BulletToDie


		NoCollision:


		rts
	}

	CheckSpriteCollisions: {

		ldx #0
		stx BulletToDie

		Loop:

			stx ZP.StoredYReg

			lda ENEMY.Plan, x
			beq EndLoop

			cmp #PLAN_EXPLODE
			beq EndLoop

			jsr CheckSpriteCollision


			EndLoop:

				ldx ZP.StoredYReg
				inx
				cpx #MAX_ENEMIES
				bcc Loop


		lda BulletToDie
		beq BulletAlive

		lda #1
		sta Cooldown

		ldx ZP.StoredXReg
		jsr KillBullet

		BulletAlive:

		rts
	}

	CheckFormationCollision: {

		lda CharY, x
		cmp #14
		bcs Finish

		ldy #45

		Loop:

			sty ZP.StoredYReg

			lda FORMATION.Occupied, y
			beq EndLoop

			lda CharY, x
			sec
			sbc FORMATION.Row, y
			sta ZP.Temp4
			cmp #2
			bcc WithinRange

			cmp #5
			bcs EndLoop

		WithinRange:

			lda FORMATION.Column, y
			clc
			adc FORMATION.Position
			sta ZP.Amount

			lda CharX, x
			sec
			sbc ZP.Amount
			cmp #2
			bcs EndLoop

			cmp #1
			beq NoOffsetCheck
	
			lda OffsetX, x
			cmp #2
			bcs NoOffsetCheck

			Missed:

				lda #1
				sta FORMATION.Stop
				
				jmp EndLoop

			NoOffsetCheck:

			lda ZP.Temp4
			cmp #2
			bcs EndLoop

			tya
			tax
			jsr FORMATION.Hit

			ldx ZP.StoredXReg

			lda #1
			sta Cooldown
			jsr KillBullet


			
			EndLoop:

				ldy ZP.StoredYReg
				dey
				bpl Loop


		Finish:


		rts
	}

	FrameUpdate: {

		lda SHIP.DualFighter
		asl
		clc
		adc #1
		sta MaxBullets

		jsr Move

		lda Cooldown + 1
		beq Done

		dec Cooldown + 1

		Done:

		lda Cooldown
		beq Finish

		dec Cooldown

		Finish:

			rts


	}

}