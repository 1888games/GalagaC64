SHIP: {

	* = * "SHIP"

	.label SPRITE_POINTER = 16
	.label SHIP_Y = 240

	.label MIN_SHIP_X = 32
	.label MAX_SHIP_X = 206
	.label LEFT_OFFSET = 7
	

	.label SHIP_START_X = MIN_SHIP_X + ((MAX_SHIP_X - MIN_SHIP_X) / 2) + 1

	//.label SHIP_START_X = 32

	.label SPEED_LSB = 200
	.label SPEED_MSB = 1

	Active:			.byte 0
	DualFighter:	.byte 0
	MaxShipX:		.byte 202, 188
	Dead:			.byte 0, 0
	Docked:			.byte 0

	PreviousX:		.byte SHIP_START_X
	PosX_MSB:		.byte SHIP_START_X, 0
	PosX_LSB:		.byte 0, 0
	CharX:			.byte 12, 12
	OffsetX:		.byte 6, 6

	.label CharY = 23
	.label EXPLODE_TIME = 3

	ExplodeTimer:		.byte 0, 0
	ExplodeProgress:	.byte 0, 0

	ExplosionFrames:	.byte 70, 71, 72, 73

	Captured:			.byte 0
	Recaptured:			.byte 0
	CanControl:			.byte 1

	.label MAIN_SHIP_POINTER = 18

	Initialise: {


		jsr MainShip
		jsr Reset

		rts

	}

	MainShip: {

	
		lda #0
		sta Captured
		sta Recaptured
		sta PosX_LSB

		lda #12
		sta CharX

		lda #6
		sta OffsetX

		lda #SPRITE_POINTER
		sta SpritePointer + MAIN_SHIP_POINTER

		lda #WHITE
		sta SpriteColor + MAIN_SHIP_POINTER

		lda #SHIP_START_X
		sta SpriteX + MAIN_SHIP_POINTER
		sta PosX_MSB


		lda #SHIP_Y
		sta SpriteY + MAIN_SHIP_POINTER


		rts
	}

	NewGame: {

		lda #%11111111
		sta VIC.SPRITE_MULTICOLOR

		lda #0
		sta Docked

		lda #SPRITE_POINTER
		sta SpritePointer + MAIN_SHIP_POINTER + 1

		lda #WHITE
		sta SpriteColor + MAIN_SHIP_POINTER + 1

		lda #SHIP_Y
		sta SpriteY + MAIN_SHIP_POINTER + 1

		rts

	}

	Reset: {


		lda #0
		sta Dead

		lda #1
		sta Active
		sta CanControl

		lda #255
		sta ExplodeProgress
		sta ExplodeProgress + 1

		rts

	}



	KillDualShip: {

		lda Captured
		bne Finish

		lda #0
		sta DualFighter

		lda ExplosionFrames
		sta SpritePointer + MAIN_SHIP_POINTER + 1

		lda #EXPLODE_TIME
		sta ExplodeTimer + 1

		lda #1
		sta ExplodeProgress + 1

		Finish:

		rts

	}


	KillMainShip: {

		lda Captured
		bne Finish

		lda DualFighter
		beq MainKilled

		lda #0
		sta DualFighter

		MainKilledButOneLeft:

			lda SpriteX + MAIN_SHIP_POINTER
			sta ZP.Column

			lda SpriteY + MAIN_SHIP_POINTER
			sta ZP.Row

			lda SpriteX + MAIN_SHIP_POINTER + 1
			sta SpriteX + MAIN_SHIP_POINTER

			lda SpriteY + MAIN_SHIP_POINTER + 1
			sta SpriteY + MAIN_SHIP_POINTER

			lda CharX + 1
			sta CharX

			lda OffsetX + 1
			sta OffsetX

			lda PosX_MSB + 1
			sta PosX_MSB

			lda PosX_LSB + 1
			sta PosX_LSB

			lda ZP.Column
			sec
			sbc #4
			sta SpriteX + MAIN_SHIP_POINTER + 1

			lda ZP.Row
			sec
			sbc #3
			sta SpriteY + MAIN_SHIP_POINTER	+ 1

			lda ExplosionFrames
			sta SpritePointer + MAIN_SHIP_POINTER + 1

			lda #EXPLODE_TIME
			sta ExplodeTimer + 1

			lda #1
			sta ExplodeProgress + 1

			rts


		MainKilled:

			lda #0
			sta Active

			lda ExplosionFrames
			sta SpritePointer + MAIN_SHIP_POINTER

			lda SpriteX + MAIN_SHIP_POINTER
			sec
			sbc #4
			sta SpriteX + MAIN_SHIP_POINTER

			lda SpriteY + MAIN_SHIP_POINTER
			sec
			sbc #3
			sta SpriteY + MAIN_SHIP_POINTER	

			lda #EXPLODE_TIME
			sta ExplodeTimer

			lda #1
			sta ExplodeProgress

			lda #0
			sta STARS.Scrolling

		Finish:

		rts
	}

	
	Control: {	

		SetDebugBorder(1)

		//lda CanControl
		//bne NotDisabled

		//jmp Finish

	//NotDisabled:

		lda Active
		bne NotDead

		jmp Finish

		NotDead:

		ldy #1

		CheckRight:
			
			lda INPUT.JOY_RIGHT_NOW, y
			beq CheckLeft

		Right:	

			lda PosX_LSB
			clc
			adc #SPEED_LSB
			sta PosX_LSB

			lda PosX_MSB
			sta ZP.Amount
			adc #0
			clc
			adc #SPEED_MSB
			sta PosX_MSB

			ldx DualFighter
			cmp MaxShipX, x
			bcc CheckOffsetRight

			lda MaxShipX, x
			sta PosX_MSB

			lda #0
			sta PosX_LSB

		CheckOffsetRight:

			lda PosX_MSB
			sec
			sbc ZP.Amount
			clc
			adc OffsetX
			sta OffsetX

			cmp #8
			bcc NoWrapOffsetRight

			sec
			sbc #8
			sta OffsetX

			inc CharX

		NoWrapOffsetRight:

			jmp CheckFire

		CheckLeft:
			
			lda INPUT.JOY_LEFT_NOW, y
			beq CheckFire

		Left:

			lda PosX_LSB
			sec
			sbc #SPEED_LSB
			sta PosX_LSB

			lda PosX_MSB
			sta ZP.Amount
			sbc #0
			sec
			sbc #SPEED_MSB
			sta PosX_MSB

			cmp #MIN_SHIP_X
			bcs CheckOffsetLeft

			lda #MIN_SHIP_X
			sta PosX_MSB

			lda #LEFT_OFFSET
			sta OffsetX

			lda #0
			sta PosX_LSB

		CheckOffsetLeft:

			lda PosX_MSB
			sec
			sbc ZP.Amount
			clc
			adc OffsetX
			sta OffsetX

			bpl NoWrapOffsetLeft

			clc
			adc #8
			sta OffsetX


			dec CharX

		NoWrapOffsetLeft:

		CheckFire:

			lda INPUT.JOY_FIRE_NOW, y
			beq Finish

			jsr Fire


		Finish:

			lda PosX_MSB
			clc
			adc #16
			sta PosX_MSB + 1

			lda CharX
			clc
			adc #2
			sta CharX + 1

			lda PosX_LSB
			sta PosX_LSB + 1

			lda OffsetX
			sta OffsetX + 1

			rts




	}

	// jsr RANDOM.Get
	// 		and #%00111111
	// 		sec
	// 		sbc #32
	// 		clc
	// 		adc #124
	// 		sta TargetSpriteX
	// 		sec
	// 		sbc SpriteX, x
	// 		sta 




	Fire: {

		ldy #0
		jsr BULLETS.Fire

		bmi Finish

		lda DualFighter
		beq Finish

		ldy #1
		jsr BULLETS.Fire


		Finish:


		rts
	}



	UpdateSprites: {

		lda Active
		beq Finish

		Override:

			lda PosX_MSB
			sta PreviousX
			sta SpriteX +  MAIN_SHIP_POINTER

			lda Active + 1
			beq HideSecondShip

		ShowSecondShip:

			lda PosX_MSB + 1
			sta SpriteX + MAIN_SHIP_POINTER + 1

			lda #SHIP_Y
			sta SpriteY + MAIN_SHIP_POINTER + 1

			rts

		HideSecondShip:

			lda Docked
			clc
			adc Recaptured
			bne Finish

			lda ExplodeProgress + 1
			cmp #255
			bne ExplosionInProcess

			lda #10
			sta SpriteX + MAIN_SHIP_POINTER + 1
			sta SpriteY + MAIN_SHIP_POINTER + 1

			ExplosionInProcess:

		Finish:

			
		rts


	}

	Explosion: {

		ldx #0

		Loop:

			lda ExplodeProgress, x
			bmi EndLoop

			lda ExplodeTimer, x
			beq ReadyToUpdate

			dec ExplodeTimer, x
			jmp EndLoop

			ReadyToUpdate:


			lda ExplodeProgress, x
			cmp #4
			beq DoneExploding

			tay
			lda ExplosionFrames, y
			sta SpritePointer + MAIN_SHIP_POINTER, x

			lda #EXPLODE_TIME
			sta ExplodeTimer, x

			inc ExplodeProgress, x

			jmp EndLoop


			DoneExploding:

				lda #10
				sta SpriteX + MAIN_SHIP_POINTER, x
				sta SpriteY + MAIN_SHIP_POINTER, x

				lda #255
				sta ExplodeProgress, x

				cpx #1
				beq EndLoop

				inc Dead


			EndLoop:

				inx
				cpx #2
				bcc Loop





		rts
	}

	CheckDead: {

		lda Dead
		beq Finish

		lda BEAM.CaptureProgress
		bne Finish

		lda BULLETS.ActiveBullets
		bne Finish

		ldx STAGE.CurrentPlayer
		lda LIVES.Left, x
		bne NotGameOver

		jmp END_GAME.Initialise

	NotGameOver:

		lda ATTACKS.NumAttackers
		bne Finish

		lda #GAME_MODE_PRE_STAGE
		sta MAIN.GameMode

		lda #0
		sta PRE_STAGE.NewStage

		lda #3
		sta PRE_STAGE.Progress


		Finish:

		rts
	}	


	FrameUpdate: {

		CheckIfCaptured:

			lda Captured
			beq NotCapture

		ShipCaptured:

			jmp BEAM.ShipCaptured

		NotCapture:

			lda Recaptured
			beq NotRecaptured

			jsr BEAM.ShipRecaptured

		NotRecaptured:

			jsr Control
			jsr Explosion
			jsr UpdateSprites
			jsr CheckDead

		CheckIfShipDocked:

			lda Docked
			beq Finish

		IsDocked:

			jsr BEAM.ShipDocked


		Finish:



		rts
	}

}