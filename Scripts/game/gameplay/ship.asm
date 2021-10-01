SHIP: {

	* = * "SHIP"

	.label SPRITE_POINTER = 16
	.label SHIP_Y = 240

	.label MIN_SHIP_X = 34
	.label MAX_SHIP_X = 206
	.label LEFT_OFFSET = 0
	.label RIGHT_OFFSET = 7
	

	.label SHIP_START_X = MIN_SHIP_X + ((MAX_SHIP_X - MIN_SHIP_X) / 2) + 1

	//.label SHIP_START_X = 32

	.label SPEED_LSB = 200
	.label SPEED_MSB = 1

	Active:			.byte 0, 0
	DualFighter:	.byte 0
	TwoPlayer:		.byte 0
	MaxShipX:		.byte 208, 192
	Dead:			.byte 0, 0
	Docked:			.byte 0

	PreviousX:		.byte SHIP_START_X
	PosX_MSB:		.byte SHIP_START_X, 0
	PosX_LSB:		.byte 0, 0
	CharX:			.byte 12, 12
	OffsetX:		.byte 6, 6

	.label CharY = 23
	.label EXPLODE_TIME = 7

	ExplodeTimer:		.byte 0, 0
	ExplodeProgress:	.byte 0, 0

	ExplosionFrames:	.byte 70, 71, 72, 73

	Captured:			.byte 0
	Recaptured:			.byte 0
	CanControl:			.byte 1
	DeadTimer:			.byte 255
	PlayerDied:			.byte 0

	.label MAIN_SHIP_POINTER = 18

	Initialise: {


		jsr MainShip
		jsr Reset
		jsr ResetPosition

		rts

	}

	NewStage: {

		jsr MainShip
		jsr Reset

		rts
	}

	ResetPosition: {


		lda #12
		sta CharX

		lda #6
		sta OffsetX

		lda #0
		sta PosX_LSB
		sta PosX_LSB + 1

		lda #SHIP_START_X
		sta SpriteX + MAIN_SHIP_POINTER
		sta PosX_MSB


		rts
	}

	MainShip: {

	
		lda #0
		sta Captured
		sta Recaptured

		lda #SPRITE_POINTER
		sta SpritePointer + MAIN_SHIP_POINTER

		lda #WHITE
		sta SpriteColor + MAIN_SHIP_POINTER

		lda #SHIP_Y
		sta SpriteY + MAIN_SHIP_POINTER


		rts
	}

	SecondShip: {

		lda TwoPlayer
		beq Finish

		jmp NewGame.TwoPlayerMode

		Finish:


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

		lda #0
		sta BULLETS.PlayerLookup + 2
		sta BULLETS.PlayerLookup + 3

		lda TwoPlayer
		beq Finish

		TwoPlayerMode:

			lda #SHIP_START_X + 16
			sta SpriteX + MAIN_SHIP_POINTER + 1
			sta PosX_MSB + 1

			lda #145
			sta SpritePointer + MAIN_SHIP_POINTER + 1

			lda #1
			sta Active + 1

			lda #14
			sta CharX + 1

			lda #1
			sta BULLETS.PlayerLookup + 2
			sta BULLETS.PlayerLookup + 3

			lda #6
			sta OffsetX + 1


		Finish:

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
		sta DeadTimer

		rts

	}



	KillDualShip: {

	
		lda Captured
		bne Finish

		lda TwoPlayer
		beq Dual


	Two:

		lda #0
		sta Active + 1
		sta Active

		lda #1
		sta Dead
		sta PlayerDied

		jmp Destroy

	Dual:

		lda #0
		sta DualFighter


	Destroy:

		lda ExplosionFrames
		sta SpritePointer + MAIN_SHIP_POINTER + 1

		lda #EXPLODE_TIME
		sta ExplodeTimer + 1

		lda #1
		sta ExplodeProgress + 1

		sfx(SFX_DEAD)

		Finish:

		rts

	}


	KillMainShip: {

		lda Captured
		beq NotCaptured

		jmp Finish

		NotCaptured:

		sfx(SFX_DEAD)

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

			lda CharX
			clc
			adc #2
			sta CharX

			lda PosX_MSB
			clc
			adc #16
			sta PosX_MSB

			lda PosX_LSB
			sta PreviousX

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
			sta PlayerDied

			lda ExplosionFrames
			sta SpritePointer + MAIN_SHIP_POINTER

			lda SpriteX + MAIN_SHIP_POINTER
			sec
			sbc #4
			sta SpriteX + MAIN_SHIP_POINTER

			lda SpriteY + MAIN_SHIP_POINTER
			sec
			sbc #2
			sta SpriteY + MAIN_SHIP_POINTER	

			lda #EXPLODE_TIME
			sta ExplodeTimer

			lda #1
			sta ExplodeProgress

			lda #0
			sta STARS.Scrolling

			lda TwoPlayer
			beq Finish

			lda #0
			sta Active + 1

		Finish:

		rts
	}


	Control2: {

	SetDebugBorder(1)

		lda Active + 1
		bne NotDead

		jmp Finish

		NotDead:

		ldy #0

		CheckRight:
			
			lda INPUT.JOY_RIGHT_NOW, y
			beq CheckLeft

		Right:	

			lda PosX_LSB + 1
			clc
			adc #SPEED_LSB
			sta PosX_LSB + 1

			lda PosX_MSB + 1
			sta ZP.Amount
			adc #0
			clc
			adc #SPEED_MSB
			sta PosX_MSB + 1

			ldx DualFighter
			cmp MaxShipX, x
			bcc CheckOffsetRight

			lda MaxShipX, x
			sta PosX_MSB + 1

			lda #0
			sta PosX_LSB + 1

			lda #RIGHT_OFFSET
			sta OffsetX + 1

			//jmp NoWrapOffsetRight

		CheckOffsetRight:

			ldy PosX_MSB + 1
			lda SpriteXToChar, y
			sta CharX + 1

			lda SpriteXToOffset, y
			sta OffsetX + 1

			ldy #0

			// lda PosX_MSB + 1
			// sec
			// sbc ZP.Amount
			// clc
			// adc OffsetX + 1
			// sta OffsetX + 1

			// cmp #8
			// bcc NoWrapOffsetRight

			// sec
			// sbc #8
			// sta OffsetX + 1

			// inc CharX + 1

		NoWrapOffsetRight:

			jmp CheckFire

		CheckLeft:
			
			lda INPUT.JOY_LEFT_NOW, y
			beq CheckFire

		Left:

			lda PosX_LSB + 1
			sec
			sbc #SPEED_LSB
			sta PosX_LSB + 1

			lda PosX_MSB + 1
			sta ZP.Amount
			sbc #0
			sec
			sbc #SPEED_MSB
			sta PosX_MSB + 1

			cmp #MIN_SHIP_X
			bcs CheckOffsetLeft

			lda #MIN_SHIP_X
			sta PosX_MSB + 1

			lda #LEFT_OFFSET
			sta OffsetX + 1

			lda #0
			sta PosX_LSB + 1

			//jmp NoWrapOffsetLeft

		CheckOffsetLeft:


			ldy PosX_MSB + 1
			lda SpriteXToChar, y
			sta CharX + 1

			lda SpriteXToOffset, y
			sta OffsetX + 1


			ldy #0


			// lda PosX_MSB + 1
			// sec
			// sbc ZP.Amount
			// clc
			// adc OffsetX + 1
			// sta OffsetX + 1

			// bpl NoWrapOffsetLeft

			// clc
			// adc #8
			// sta OffsetX + 1


			// dec CharX + 1

		NoWrapOffsetLeft:

		CheckFire:

			lda INPUT.FIRE_UP_THIS_FRAME, y
			beq Finish

			jsr BULLETS.Fire2


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

			lda #RIGHT_OFFSET
			sta OffsetX

			//jmp NoWrapOffsetRight

		CheckOffsetRight:

			ldy PosX_MSB
			lda SpriteXToChar, y
			sta CharX

			lda SpriteXToOffset, y
			sta OffsetX

			ldy #1


			// lda PosX_MSB
			// sec
			// sbc ZP.Amount
			// clc
			// adc OffsetX
			// sta OffsetX

			// cmp #8
			// bcc NoWrapOffsetRight

			// sec
			// sbc #8
			// sta OffsetX

			// inc CharX

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

		//	jmp NoWrapOffsetLeft

		CheckOffsetLeft:

			ldy PosX_MSB
			lda SpriteXToChar, y
			sta CharX

			lda SpriteXToOffset, y
			sta OffsetX

			ldy #1


			// lda PosX_MSB
			// sec
			// sbc ZP.Amount
			// clc
			// adc OffsetX
			// sta OffsetX

			// bpl NoWrapOffsetLeft

			// clc
			// adc #8
			// sta OffsetX


			// dec CharX

		NoWrapOffsetLeft:

		CheckFire:

			lda INPUT.FIRE_UP_THIS_FRAME, y
			beq Finish

			jsr Fire


		Finish:

			lda TwoPlayer
			bne SkipFix

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

		SkipFix:

			rts




	}

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

			lda TwoPlayer
			bne ShowSecondShip

			lda DualFighter
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
			//sta SpriteX + MAIN_SHIP_POINTER + 1
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
				//sta SpriteX + MAIN_SHIP_POINTER, x
				sta SpriteY + MAIN_SHIP_POINTER, x

				lda #255
				sta ExplodeProgress, x

				cpx #1
				beq EndLoop

				lda #50
				sta DeadTimer

				inc Dead


			EndLoop:

				inx
				cpx #2
				bcc Loop





		rts
	}

	* = * "CheckDead"

	CheckDead: {

		lda Dead
		beq Finish

		lda BEAM.CaptureProgress
		cmp #7
		beq SkipCheck

		cmp #0
		bne Finish

		SkipCheck:

		lda BULLETS.ActiveBullets
		bne Finish

		lda BOMBS.ActiveBombs
		bne Finish
		
		lda FORMATION.Mode
		bne NoCheckEnemies

		lda ENEMY.EnemiesAlive
		bne Finish

		NoCheckEnemies:

		ldx STAGE.CurrentPlayer
		lda LIVES.Left, x
		bne NotGameOver

		lda DeadTimer
		beq ReadyToExit

		dec DeadTimer
		rts

		ReadyToExit:

		jsr LIVES.Check2Player

		lda ZP.Amount
		bne NotGameOver

		jmp END_GAME.Initialise

	NotGameOver:

	
		lda ATTACKS.NumAttackers
		bne Finish

		lda DeadTimer
		bpl CheckNow

		lda #1
		sta DeadTimer
		rts

		CheckNow:

		lda DeadTimer
		beq Ready

		dec DeadTimer
		rts

		Ready:

		lda #255
		sta DeadTimer

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

			lda TwoPlayer
			beq OnePlayer

			jsr Control2


		OnePlayer:
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