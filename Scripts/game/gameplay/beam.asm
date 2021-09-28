BEAM: {

	* = * "BEAM"

	BeamBossSpriteID:	.byte 0
	Active:				.byte 0
	Progress:			.byte 0
	Timer:				.byte 0
	RowsDrawn:			.byte 0
	Flash:				.byte 0
	DrawSides:			.byte 0
	DrawTimer:			.byte 0
	CaptureProgress:	.byte 0
	Column:				.byte 0

	TopRow:			.byte 31, 39, 40, 82, 240, 241, 242, 243
	OtherRows:		.byte 47, 29, 30, 83, 244, 245, 246, 247
	BottomRow:		.byte 80, 29, 30, 81, 248, 245, 246, 249

	StartID:		.byte 0, 8, 8, 8, 8, 8, 16

	StartPointers:	.byte 90, 106
	Colours:		.byte WHITE, RED


	ShipX:		.byte 0
	ShipY:		.byte 0
	Angle:		.byte 0
	Pointer:	.byte 0
	Red:		.byte 0
	DrawDelay:	.byte 8
	Colour:		.byte 0
	TargetX:	.byte 0

	ShipBossOffsetX:	.byte 0
	ShipBossOffsetY:	.byte 0

	BossColumnX:		.byte 0
	BossRowY:			.byte 0

	.label Row = 17
	.label OpenSpeed = 8
	.label DeleteSpeed = 1
	.label CloseSpeed = 5
	.label CaptureSpeed = 3
	.label HoldTime = 85
	.label SpinTime = 90
	.label GrabHeight = 183
	.label DockedShipY = 31

	NewGame: {

		lda #0
		sta Active
		sta Progress
		sta CaptureProgress

		lda #255
		sta BeamBossSpriteID


		rts
	}


	Launch: {

		stx BeamBossSpriteID


		lda #SUBTUNE_BEAM
		jsr sid.init

		lda #0
		sta allow_channel_1

		lda #BEAM_OPENING
		sta Progress

		lda #1
		sta Active

		lda #0
		sta RowsDrawn
		sta Flash
		sta CaptureProgress

		dec Column

		//lda #6
		//sta RowsDrawn
		//inc DrawSides

		lda #OpenSpeed
		sta DrawDelay

		jsr Draw

		lda DrawDelay
		sta DrawTimer

		rts

	}


	FrameUpdate: {

		lda Active
		beq Finish

		lda DrawTimer
		beq ReadyDraw

		dec DrawTimer
		jmp CheckMainTimer

		ReadyDraw:

			lda Progress
			cmp #BEAM_CLOSING
			bne NotClosing

			jsr DeleteFirst

		NotClosing:

			jsr Draw

			lda DrawDelay
			sta DrawTimer


		CheckMainTimer:	

			lda Progress
			cmp #BEAM_HOLD
			bne Finish

			lda Timer
			beq MainReady

			jsr CheckShipCapture

			dec Timer
			jmp Finish

		MainReady:

			lda #BEAM_CLOSING
			sta Progress

			lda SHIP.Captured
			beq NotCapture

			lda #CaptureSpeed
			jmp SetDelay

		NotCapture:

			lda #CloseSpeed	

		SetDelay:

			sta DrawDelay

		Finish:


			rts
	}


	

	CheckShipCapture: {

		lda SHIP.Active
		beq NoCapture

		lda SHIP.Captured
		bne NoCapture


	SetupShip:

		lda BULLETS.ActiveBullets
		bne NoCapture

		lda ATTACKS.BeamStatus
		beq NoCapture

		lda #SUBTUNE_BEAM_CAPTURE
		jsr sid.init

		lda #0
		sta allow_channel_1
		
		ldx BeamBossSpriteID
		lda SpriteX, x
		sec
		sbc SHIP.PreviousX
		clc
		adc #14
		cmp #28
		bcs NoCapture

		lda #1
		sta SHIP.Captured

		lda #255
		sta STARS.Scrolling


		lda #0
		sta Angle
		sta Red

		tay
		lda StartPointers, y
		sta Pointer

		lda Colours, y
		sta Colour

		ldx BeamBossSpriteID
		lda SpriteX, x
		sta ShipX

		lda #SHIP.SHIP_Y
		sec
		sbc #2
		sta ShipY

		lda #BEAM_HOLD
		sta Progress

		lda #SpinTime
		sta Timer



		NoCapture:



		rts
	}





	ShipRecaptured: {

		lda CaptureProgress
		cmp #RECAPTURE_PLAYER_SPIN
		bne NotSpinning

	Spinning:

		jsr SpinShip
		
		lda Timer
		beq StopSpinning

		dec Timer
		jmp Update

	StopSpinning:

		lda ATTACKS.NumAttackers
		bne Update

		lda #RECAPTURE_PLAYER_MOVE_X
		sta CaptureProgress

		lda #0
		sta SHIP.Active
		sta Angle
		
		jmp Update

	NotSpinning:

		cmp #RECAPTURE_PLAYER_MOVE_X
		bne NotMoveX

		jsr RecaptureMoveX
		
	NotMoveX:	

		cmp #RECAPTURE_PLAYER_MOVE_Y
		bne Update

		jsr RecaptureMoveY

	Update:

		lda CaptureProgress
		beq Finish

		ldx #1
		jsr UpdateShipSprite


		Finish:

		rts
	}


	RecaptureMainShip: {

			lda #1
			sta ZP.Amount

			lda SHIP.PosX_MSB
			cmp #SHIP.SHIP_START_X
			beq MainShipReady
			bcc GoRightMain

		GoLeftMain:

			dec SHIP.PosX_MSB
			dec ZP.Amount
			jmp UpdateMainShip

		GoRightMain:

			inc SHIP.PosX_MSB
			dec ZP.Amount

		UpdateMainShip:

			jsr SHIP.UpdateSprites.Override


		MainShipReady:


		rts
	}


	RecaptureMoveY: {

		jsr RecaptureMainShip

		lda #SHIP.SHIP_Y
		sec
		sbc #2
		cmp ShipY
		beq Arrived

		inc ShipY
		rts

	Arrived:

		jsr play_background

		lda #50
		sta ATTACKS.DelayTimer

		lda ZP.Amount
		beq WaitMainShip

		lda #0
		sta CaptureProgress
		sta SHIP.Recaptured
		sta ATTACKS.BeamStatus

		lda SHIP.Dead
		bne MainShipDead

		lda #1
		sta SHIP.DualFighter

	MainShipDead:

		jsr SHIP.NewGame
		jsr SHIP.Initialise


	WaitMainShip:

		rts
	}

	RecaptureMoveX: {

		jsr RecaptureMainShip

		lda SHIP.Dead
		beq NoRetarget	

		lda #SHIP.SHIP_START_X
		sta TargetX

		NoRetarget:

		lda TargetX
		sec
		sbc #4
		cmp ShipX
		beq Arrived
		bcs GoRight

	GoLeft:

		dec ShipX
		rts

	GoRight:

		inc ShipX
		rts

	Arrived:

		lda #RECAPTURE_PLAYER_MOVE_Y
		sta CaptureProgress

		rts
	}

	
	CheckEnemy: {

		cpx ENEMY.EnemyWithShipID
		beq EnemyHasShip

		cpx BeamBossSpriteID
		beq EnemyHasShip

		rts

	EnemyHasShip:

		lda ATTACKS.BeamStatus
		cmp #BEAM_DOCKED
		bne DontHaveShip

		lda #SUBTUNE_RECAPTURE
		jsr sid.init

		lda #1
		sta SHIP.Recaptured

		lda #0
		sta SHIP.Captured
		sta SHIP.Docked

		lda #RECAPTURE_PLAYER_SPIN
		sta CaptureProgress

		lda #50
		sta Timer

		lda StartPointers
		sta Pointer

		lda Colours
		sta Colour

		lda SHIP.Dead
		beq NextToMain

		WillBeMain:

			lda #SHIP.SHIP_START_X
			jmp TargetX

		NextToMain:

			lda #SHIP.SHIP_START_X
			clc
			adc #16

		Target:

			sta TargetX

			lda #255
			sta ENEMY.EnemyWithShipID
			sta BeamBossSpriteID
			sta ATTACKS.BeamBoss
			//sta ATTACKS.BossDocked


			lda #BEAM_RECAPTURE
			sta ATTACKS.BeamStatus

		rts


	DontHaveShip:


		lda #0
		sta DrawDelay

		lda #BEAM_CLOSING
		sta Progress

	Tidy:

		lda #255
		sta ENEMY.EnemyWithShipID
		sta BeamBossSpriteID
		sta ATTACKS.BeamBoss
		
		lda #0
		sta ATTACKS.BeamStatus

	NotBeamBoss:

		
		rts
	}

	DeleteFirst: {

		ldx Column
		ldy #Row

		jsr PLOT.GetCharacter

		ldx #0
		ldy #0

		Loop:

			lda #32
			sta (ZP.ScreenAddress), y

			inx
			cpx #4
			beq NextRow

			iny
			jmp Loop

		NextRow:

			cpy #243
			beq Finish

			tya
			clc 
			adc #37
			tay

			ldx #0

			jmp Loop


		Finish:


		rts
	}


	ShipDocked: {


		lda CaptureProgress
		beq Finish


		ldx ENEMY.EnemyWithShipID
		lda SpriteX, x
		sta ShipX

		lda SpriteY, x
		sec
		sbc #16
		sta ShipY

		lda ENEMY.Angle, x
		sta Angle

		ldx #1
		jsr UpdateShipSprite

		Finish:




		rts
	}


	ShipCaptured: {

		lda CaptureProgress
		cmp #CAPTURE_PLAYER_SPIN
		bne NotSpinning

	Spinning:

		jsr SpinShip
		jsr MoveShipToBoss

	NotSpinning:

		cmp #CAPTURE_PLAYER_TURN
		bne NotTowed

		jsr FollowBoss

	NotTowed:	

		cmp #CAPTURE_PLAYER_DOCK
		bne NotDocking	

		jsr DockShip


	NotDocking:

		lda SHIP.Captured
		beq Finish

		ldx #0
		jsr UpdateShipSprite


		Finish:

		rts
	}


	BossReturnedHomeWithShip: {

		stx ZP.Temp4

		lda #0
		sta CaptureProgress
		sta Angle

		lda BossColumnX
		sec
		sbc #4
		sta ShipX

		lda #DockedShipY 
		sta ShipY

		ldx #1
		jsr UpdateShipSprite

		ldx ZP.Temp4

		rts
	}


	FollowBoss: {

		//p Move
		lda Timer
		bmi Move

		beq Ready

		ldx BeamBossSpriteID
		lda #8
		sta ENEMY.Angle, x

		lda ShipBossOffsetX
		sta SpriteX, x

		lda ShipBossOffsetY
		sta SpriteY, x

		dec Timer
		rts

		Ready:

		lda #255
		sta Timer

		jsr BossTurn

		Move:

			ldx ATTACKS.BeamBoss
			lda FORMATION.Occupied, x
			bne BossArrived

			ldx BeamBossSpriteID
			lda SpriteX, x
			sec
			sbc ShipBossOffsetX
			sta ShipX


			lda SpriteY, x
			sec
			sbc ShipBossOffsetY
			sta ShipY

			rts


		BossArrived:

			lda #CAPTURE_PLAYER_DOCK
			sta CaptureProgress

			lda #255
			sta BeamBossSpriteID

			lda BossColumnX
			sec
			sbc #4
			sta ShipX

			lda #0
			sta Timer


		rts
	}

	DockShip: {

		dec ShipY
		lda ShipY
		cmp #DockedShipY + 1
		bcs NotDocked


		Docked:	

			jsr play_background

			

			lda #50
			sta ATTACKS.DelayTimer

			lda #0
			sta CaptureProgress

			lda #BEAM_DOCKED
			sta ATTACKS.BeamStatus

			//ldx EnemySpriteID
			//lda ENEMY.Slot, x
			//sta ATTACKS.BossDocked

			lda SpritePointer + SHIP.MAIN_SHIP_POINTER
			sta SpritePointer + SHIP.MAIN_SHIP_POINTER + 1
			
			lda SpriteColor + SHIP.MAIN_SHIP_POINTER
			sta SpriteColor + SHIP.MAIN_SHIP_POINTER + 1

			lda SpriteX + SHIP.MAIN_SHIP_POINTER
			sta SpriteX + SHIP.MAIN_SHIP_POINTER + 1

			lda SpriteY + SHIP.MAIN_SHIP_POINTER
			sta SpriteY + SHIP.MAIN_SHIP_POINTER + 1

			inc SHIP.Docked

			jsr LIVES.Decrease
			jsr SHIP.MainShip
			
			lda LIVES.GameOver
			beq NotDocked

			lda #1
			sta SHIP.Dead

			lda #0
			sta SHIP.Active

			jmp END_GAME.Initialise


		NotDocked:



		rts
	}

	MoveShipToBoss: {

		dec ShipY
		lda ShipY
		cmp #GrabHeight
		bne NoMove

		lda #0
		sta Angle

		lda StartPointers + 1
		sta Pointer

		lda #CAPTURE_PLAYER_HOLD
		sta CaptureProgress

		NoMove:

			rts

	}

	SpinShip: {

		inc Angle
		lda Angle
		cmp #16
		bcc NotWrap

		lda #0
		sta Angle

		NotWrap:


		rts
	}


	UpdateShipSprite: {

		lda Pointer
		clc
		adc Angle
		sta SpritePointer + SHIP.MAIN_SHIP_POINTER, x

		lda Colour
		sta SpriteColor + SHIP.MAIN_SHIP_POINTER, x

		lda ShipX
		sta SpriteX + SHIP.MAIN_SHIP_POINTER, x

		lda ShipY
		sta SpriteY + SHIP.MAIN_SHIP_POINTER, x


		rts
	}

	OrphanedFighterSprite: {

		lda Pointer
		sta SpritePointer + SHIP.MAIN_SHIP_POINTER + 1
		
		lda Colour
		sta SpriteColor + SHIP.MAIN_SHIP_POINTER + 1

		lda ShipX
		sta SpriteX + SHIP.MAIN_SHIP_POINTER + 1

		lda ShipY
		sta SpriteY + SHIP.MAIN_SHIP_POINTER + 1


		rts


	}

	DoFlash: {

		lda Flash
		beq Make1

		dec Flash
		jmp NowDoIt

		Make1:

		inc Flash

		NowDoIt:

			rts

	}

	Draw: {

		jsr DoFlash


		lda Progress
		cmp #BEAM_CLOSING
		bne NotClosing3

		lda DrawSides
		bne NotClosing3

		lda RowsDrawn
		bne NotClosing3

		jmp FinishedClosing

		NotClosing3:

			ldy #0

		Loop:	

			sty ZP.EndID

			lda Flash
			asl
			asl
			clc
			adc StartID, y
			sta ZP.Amount


			ldx Column

			tya
			clc
			adc #Row
			tay

			jsr PLOT.GetCharacter

			ldy ZP.EndID

			cpy RowsDrawn
			bcc DrawLeft

			lda DrawSides
			bne DrawLeft

			inc ZP.Amount
			jmp DrawCentre

			DrawLeft:

				ldx ZP.Amount
				lda TopRow, x

				ldy #0
				sta (ZP.ScreenAddress), y

				lda #PURPLE_MULT
				sta (ZP.ColourAddress), y

				inc ZP.Amount

			DrawCentre:

				ldx ZP.Amount
				lda TopRow, x

				ldy #1
				sta (ZP.ScreenAddress), y

				lda #PURPLE_MULT
				sta (ZP.ColourAddress), y

				inc ZP.Amount

				ldx ZP.Amount
				lda TopRow, x

				ldy #2
				sta (ZP.ScreenAddress), y

				lda #PURPLE_MULT
				sta (ZP.ColourAddress), y

				inc ZP.Amount

				ldy ZP.EndID
				cpy RowsDrawn
				bcc DrawRight

				lda DrawSides
				bne DrawRight

				jmp NextRow

			DrawRight:

				ldx ZP.Amount
				lda TopRow, x

				ldy #3
				sta (ZP.ScreenAddress), y

				lda #PURPLE_MULT
				sta (ZP.ColourAddress), y	

			NextRow:

				ldy ZP.EndID
				cpy RowsDrawn
				beq AllDrawn

				iny
				jmp Loop


			AllDrawn:

				lda Progress
				cmp #BEAM_CLOSING
				beq CloseBeam

				lda RowsDrawn
				beq StraightToNext

				lda DrawSides
				beq MakeOne

				jmp StraightToNext

				MakeOne:

				inc DrawSides

				rts

			StraightToNext:

				lda Progress
				cmp #BEAM_HOLD
				bne NotHolding

				rts

			NotHolding:

				lda RowsDrawn
				cmp #6
				bcc Continue

				lda #BEAM_HOLD
				sta Progress

				lda #HoldTime
				sta Timer

				rts

			Continue:

				inc RowsDrawn
				lda #0
				sta DrawSides

				rts


			CloseBeam:

				lda DrawSides
				bne MakeZero

				lda RowsDrawn
				beq FinishedClosing

				jmp StraightToNext2

				MakeZero:

				dec DrawSides
				rts

			StraightToNext2:

				dec RowsDrawn
				lda #1
				sta DrawSides

				rts

			FinishedClosing:

				lda CaptureProgress
				beq CloseBeamNoCapture


			CaptureClosedBeam:

				jsr ShipWasCaptured


				//jsr BossTurn

				rts



			CloseBeamNoCapture:

				lda #0
				sta Active

				jsr play_background

				
				ldx BeamBossSpriteID
				bmi EnemyDeadAlready

				jsr ENEMY.ReturnToGridFromTop

				lda #255
				sta ENEMY.EnemyWithShipID
				sta BeamBossSpriteID



			EnemyDeadAlready:

				rts


	}


	ShipWasCaptured: {

		lda #13
		sta TextRow

		lda #8
		sta TextColumn

		ldx #RED
		lda #TEXT.CAPTURED

		jsr TEXT.Draw

		lda #CAPTURE_PLAYER_TURN
		sta CaptureProgress

		lda #1
		sta STARS.Scrolling

		lda #0
		sta Active

		lda #BEAM_DOCKED
		sta Progress

		lda #100
		sta Timer

		lda #SUBTUNE_CAPTURE
		jsr sid.init

		ldx BeamBossSpriteID
		lda #PLAN_BOSS_HELD
		sta ENEMY.Plan, x

		dec ENEMY.PositionInPath, X


		lda SpriteX, x
		sta ShipBossOffsetX

		lda SpriteY, x
		sta ShipBossOffsetY



		rts
	}



	BossTurn: {

		ldy #13
		ldx #8
		lda #20
	
		jsr UTILITY.DeleteText

		ldx BeamBossSpriteID

		lda SpriteX, x
		sec
		sbc ShipX
		sta ShipBossOffsetX

		lda SpriteY, x
		sec
		sbc ShipY
		sta ShipBossOffsetY

		lda ENEMY.Slot, x
		tay

		lda #PLAN_BOSS_TURN
		sta ENEMY.Plan, x
		sta FORMATION.Plan, y

		lda #PLAN_RETURN_GRID
		sta FORMATION.NextPlan, y

		lda #255
		sta ENEMY.PositionInPath, x

		sty ZP.Amount

		lda FORMATION.Home_Column, y
		tay
		lda FORMATION.ColumnSpriteX, y
		sta BossColumnX
		cmp SpriteX, x
		bcc GoLeft

		lda #1
		jmp AddPath

		GoLeft:

		lda #0

		AddPath:

		clc
		adc #PATH_BOSS_TURN_HOME
		sta PathID, x

		jsr ENEMY.GetNextMovement


		ldy ZP.Amount
		lda FORMATION.Row, y
		tay
		lda FORMATION.RowSpriteY, y
		sta BossRowY


		rts
	}

	
}