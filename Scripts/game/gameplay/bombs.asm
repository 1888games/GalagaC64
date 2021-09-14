BOMBS: {

	* = * "Bombs"
	// Enemies - Sprites 0-11

	// Bombs - Sprites 12-17

	// Ship - Sprites 18-19

	.label BombStartID = 12
	.label Pointer =69
	.label BombEndID = BombStartID + 6
	.label ReloadTime = 15

	Active: 		.fill MAX_ENEMIES + MAX_BOMBS, 0

	PixelSpeedX:	.fill MAX_ENEMIES + MAX_BOMBS, 0
	PixelSpeedY:	.fill MAX_ENEMIES + MAX_BOMBS, 0
	FractionSpeedX:	.fill MAX_ENEMIES + MAX_BOMBS, 0
	FractionSpeedY:	.fill MAX_ENEMIES + MAX_BOMBS, 0

	BombsLeft:				.fill MAX_ENEMIES, 0
	ShotTimer:				.fill MAX_ENEMIES, 0

	MoveX:	.byte 0
	MoveY:	.byte 0
	ActiveBombs:	.byte 0

	MoveXReverse:	.byte 0
	MoveYReverse:	.byte 0

	.label MaxY = 250

	PixelLookup:

	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte 2,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte 2,2,2,1,1,1,0,0,0,0,0,0,0,0,0,0
	.byte 2,2,2,2,2,1,1,1,1,0,0,0,0,0,0,0
	.byte 2,2,2,2,2,2,1,1,1,1,1,0,0,0,0,0
	.byte 2,2,2,2,2,2,2,1,1,1,1,1,1,1,0,0
	.byte 2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1
	.byte 2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1
	.byte 2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2


	FractionLookup:
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.byte 188,188,94,233,175,140,117,100,88,78,70,64,58,54,50,47
	.byte 188,188,188,211,94,24,233,200,175,156,140,127,117,108,100,93
	.byte 188,188,188,188,13,164,94,44,7,233,210,191,175,162,150,140
	.byte 188,188,188,188,188,48,211,144,94,55,24,255,233,215,200,187
	.byte 188,188,188,188,188,188,71,244,182,133,94,62,36,13,250,233
	.byte 188,188,188,188,188,188,188,88,13,211,164,126,94,67,44,24
	.byte 188,188,188,188,188,188,188,188,101,32,234,189,152,121,94,71
	.byte 188,188,188,188,188,188,188,188,188,110,48,253,211,175,144,117
	.byte 188,188,188,188,188,188,188,188,188,188,118,61,13,229,194,164
	.byte 188,188,188,188,188,188,188,188,188,188,188,124,71,26,244,211
	.byte 188,188,188,188,188,188,188,188,188,188,188,188,130,80,38,1
	.byte 188,188,188,188,188,188,188,188,188,188,188,188,188,134,88,48
	.byte 188,188,188,188,188,188,188,188,188,188,188,188,188,188,138,95
	.byte 188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,141
	.byte 188,188,188,188,188,188,188,188,188,188,188,188,188,188,188,188



	Fire: {

		ldy #BombStartID

		FindLoop:

			lda Active, y
			beq Found

			iny
			cpy #BombEndID
			bcc FindLoop

			jmp Finish


		Found:

			ldx ZP.EnemyID
		
			jsr SetupSprite
			jsr CalculateDistanceToPlayer
			jsr CalculateRequiredSpeed

			inc ActiveBombs

			ldx ZP.EnemyID

		Finish:

		rts

	}


	SetupSprite: {

		lda SpriteY, x
		sta SpriteY, y

		lda #1
		sta Active, y

		lda SpriteX, x
		sta SpriteX, y

		lda #0
		sta SpriteX_LSB, y
		sta SpriteY_LSB, y

		lda #WHITE
		sta SpriteColor, y

		lda #Pointer
		sta SpritePointer, y


		rts	
	}

	CalculateDistanceToPlayer: {

		.label TargetX = ZP.Amount

		lda SHIP.PreviousX
		sta TargetX

		lda SHIP.TwoPlayer
		beq PutBombIDIntoX

		jsr RANDOM.Get
		and #%00000001
		beq PutBombIDIntoX

		lda SHIP.PosX_MSB + 1
		sta TargetX

		PutBombIDIntoX:
			tya
			tax

		CalculateDistance:

			lda #MaxY
			sec
			sbc SpriteY, x
			sta MoveY
			eor #%11111111
			sta MoveYReverse

		CalculateXTarget:

			jsr RANDOM.Get
			and #%00011111
			sec
			sbc #16
			clc
			adc TargetX

		CheckDirection:

			sec
			sbc SpriteX, x
			bcs AimRight

		AimLeft:

			cmp #195
			bcs NoWrap

			lda #195
	
			jmp NoWrap

		AimRight:

			cmp #60
			bcc NoWrap

			lda #60
			
		NoWrap:

			sta MoveX
			eor #%11111111
			sta MoveXReverse

			
		CheckAngleOfShot:

			lda MoveX
			bpl GoingRight

		GoingLeft:

			lda MoveXReverse
			cmp MoveY
			bcc NoAdjustX

			lda MoveYReverse
			sta MoveX
			jmp NoAdjustX

		GoingRight:

			lda MoveX
			cmp MoveY
			bcc NoAdjustX

			lda MoveY
			sta MoveX

		NoAdjustX:

			lda SpriteX, x
			clc
			adc MoveX
			sta TargetSpriteX, x


			lda #MaxY
			sta TargetSpriteY, x

		rts
	}



	 CalculateRequiredSpeed: {

	 	lda MoveX
	 	bpl XNotReverse

	 	MinusX:

		 	eor #%11111111
		 	clc
		 	adc #1
		 	sta MoveX

	 	XNotReverse:

	 	CheckMagnitude:

		 	lda MoveX
		 	cmp #16
		 	bcc XOkay

		 	lsr MoveX
		 	lsr MoveY
		 	jmp CheckMagnitude

	 	XOkay:

	 		lda MoveY
	 		cmp #16
	 		bcc CalculateXSpeed

	 		lsr MoveX
	 		lsr MoveY

	 		jmp XOkay


		CalculateXSpeed:

			lda MoveX
			asl
			asl
			asl
			asl
			clc
			adc MoveY
			tay

			lda PixelLookup, y
			sta PixelSpeedX, x

			lda FractionLookup, y
			sta FractionSpeedX, x


		CalculateYSpeed:

			lda MoveY
			asl
			asl
			asl
			asl
			clc
			adc MoveX
			tay

			lda PixelLookup, y
			sta PixelSpeedY, x

			lda FractionLookup, y
			sta FractionSpeedY, x

		rts


	 }



	 CheckMove: {

	 	lda SpriteY, x
	 	cmp #20
	 	bcc Reached
	
	 	CheckMoveX:

			lda TargetSpriteX, x
			sec
			sbc SpriteX, x
			beq MoveYNow

		MoveXNow:

			bmi MoveLeft

		MoveRight:

			lda SpriteX_LSB, x
			clc
			adc FractionSpeedX, x
			sta SpriteX_LSB, x

			lda SpriteX, x
			adc #0
			clc
			adc PixelSpeedX, x
			sta SpriteX, x

			cmp TargetSpriteX, x
			bcc MoveYNow
			beq MoveYNow

			lda TargetSpriteX, x
			sta SpriteX, x
			jmp MoveYNow

		MoveLeft:

			lda SpriteX_LSB, x
			sec
			sbc FractionSpeedX, x
			sta SpriteX_LSB, x

			lda SpriteX, x
			sbc #0
			sec
			sbc PixelSpeedX, x
			sta SpriteX, x

			cmp TargetSpriteX, x
			bcs MoveYNow
			
			lda TargetSpriteX, x
			sta SpriteX, x
			

		MoveYNow:

			lda SpriteY, x
			cmp #MaxY
			bcc MoveDown

			cmp #20
			bcs MoveDown

			lda #MaxY
			sta SpriteY, x

		Reached:

			lda #0
			sta Active, x

			lda #10
			//sta SpriteX, x
			sta SpriteY, x

			dec ActiveBombs


			jmp Done

	
		MoveDown:

			lda SpriteY, x
			sta ZP.Amount

			lda SpriteY_LSB, x
			clc
			adc FractionSpeedY, x
			sta SpriteY_LSB, x

			lda SpriteY, x
			adc #0
			clc
			adc PixelSpeedY, x
			sta SpriteY,x 

			CheckWrapped:

				bmi NoErrorCheck

				lda ZP.Amount
				bpl NoErrorCheck

				jmp Reached

			NoErrorCheck:

				cmp #MaxY
				bcc Done

			Reached2:
				
				lda TargetSpriteY,x 
				sta SpriteY,x 

				jmp Reached



		Done:

		rts
	}	


	

	CheckCollision: {

		lda SHIP.Active
		beq NoCollision

		lda #SHIP.SHIP_Y
		sec
		sbc #14
		sec
		sbc SpriteY, x
		adc #7
		cmp #14
		bcs NoCollision

		lda SHIP.PosX_MSB
		clc
		adc #3
		sec
		sbc SpriteX, x
		clc
		adc #7
		cmp #14
		bcs CheckDualFighter

		Collision:

			jsr SHIP.KillMainShip

		DestroyBombs:

			lda SHIP.Active
			bne NotDead

			ldy #BombStartID

			DestroyLoop:

				lda #0
				sta Active, y

				lda #10
			//	sta SpriteX, y
				sta SpriteY, y

				iny
				cpy #BombStartID + 6
				bcc DestroyLoop

				lda  #0
				sta ActiveBombs

				rts

			NotDead:

				lda #0
				sta Active, x


				lda #10
			//	sta SpriteX, x
				sta SpriteY, x

				dec ActiveBombs

				rts



		CheckDualFighter:

			lda SHIP.DualFighter
			clc
			adc SHIP.TwoPlayer
			beq NoCollision

			lda BEAM.CaptureProgress
			bne NoCollision

			lda SHIP.PosX_MSB + 1
			clc
			adc #3
			sec
			sbc SpriteX, x
			clc
			adc #7
			cmp #14
			bcs NoCollision

			jsr SHIP.KillDualShip
			jmp DestroyBombs

		NoCollision:




		rts
	}

	FrameUpdate: {


		ldx #BombStartID

		Loop:	

			stx ZP.StoredXReg

			lda Active, x
			beq EndLoop

			jsr CheckCollision

			lda Active, x
			beq EndLoop

			jsr CheckMove
		

		EndLoop:

			ldx ZP.StoredXReg
			inx
			cpx #BombEndID
			bcc Loop

		Finish:


	 	rts
	 }


	
	CheckEnemyFire: {

		lda BombsLeft, x
		beq Finish

		lda ShotTimer, x
		beq ReadyToFire

		dec ShotTimer, x
		rts

		ReadyToFire:

			lda SpriteY, x
			cmp #120
			bcs Finish

			dec BombsLeft, x
			lda #ReloadTime
			sta ShotTimer, x

			jsr Fire


		Finish:


		rts
	}	


	LoadOnLaunch: {

		lda #0
		sta BombsLeft, x

		cpx BEAM.BeamBossSpriteID
		beq Finish

		lda STAGE.CurrentStage
		cmp #3
		bcc ZeroOrOne

		cmp #7
		bcc One

		cmp #15
		bcs Two

		OneOrTwo:

			jsr RANDOM.Get
			and #%00000001
			clc
			adc #1
			jmp StoreBombs

		One:

			lda #1
			jmp StoreBombs

		Two:

			lda #2
			jmp StoreBombs

		ZeroOrOne:

			jsr RANDOM.Get
			and #%00000001
			jmp StoreBombs


		StoreBombs:

			sta BombsLeft, x

			jsr RANDOM.Get
			and #%00001111
			clc
			adc #12
			sta ShotTimer, x


		NoBombs:


		Finish:

		rts
	}


	Add: {

		lda STAGE.Every
		sta STAGE.EveryCounter

		lda STAGE.Bullets
		sta BombsLeft, x

		lda ENEMY.Side, x
		tay
		lda STAGE.CurrentWaveIDs, y

		CalculateDelay:

			cmp #PATH_BOTTOM_SINGLE
			bcc SmallDelay

			cmp #PATH_BOTTOM_DOUBLE_IN + 1
			bcs SmallDelay

		LargeDelay:

			lda #20
			sta ShotTimer, x 

			jmp AddRandom

		SmallDelay:

			jsr RANDOM.Get
			and #%00001111
			clc 
			adc #12
			sta ShotTimer, x

		AddRandom:

			jsr RANDOM.Get
			and #%00001111
			clc
			adc ShotTimer, x
			sta ShotTimer, x

		rts


	}

}