.namespace ENEMY {

	* = * "Pathfinding"

	// 1 = right, 0 = left
	// 1 = down, 0 = up


	 CalculateRequiredSpeed: {

	 	lda #BOTTOM_RIGHT
	 	sta Quadrant

	 	lda MoveX
	 	sta PreviousMoveX, x
	 	bpl XNotReverse

	 	MinusX:

		 	eor #%11111111
		 	clc
		 	adc #1
		 	sta MoveX

		 	lda #BOTTOM_LEFT
		 	sta Quadrant

		 	lda MoveY
		 	bpl CheckMagnitude

		 BothMinus:

		 	eor #%11111111
		 	clc
		 	adc #1
		 	sta MoveY

		 	lda #TOP_LEFT
		 	sta Quadrant
		 	jmp CheckMagnitude
	 	
	 	XNotReverse:

		 	lda MoveY
		 	sta PreviousMoveY, x
		 	bpl CheckMagnitude

		 	eor #%11111111
		 	clc
		 	adc #1
		 	sta MoveY

		 	lda #TOP_RIGHT
		 	sta Quadrant


	 	CheckMagnitude:

		 	lda MoveX
		 	cmp #16
		 	bcc XOkay

		 	lsr MoveX

		 	lda MoveY
		 	cmp #1
		 	beq NoChangeY
		 	lsr MoveY

		 	NoChangeY:

		 	jmp CheckMagnitude

	 	XOkay:

	 		lda MoveY
	 		cmp #16
	 		bcc CalculateXSpeed

	 		lsr MoveY

	 	
	 		lda MoveX
	 		cmp #1
	 		beq NoChangeX

	 		lsr MoveX

	 		NoChangeX:

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


		cpx #0
		bne NoBreak

		//.break
		nop


		NoBreak:


		lda MoveX
		asl
		asl
		asl
		asl
		clc
		adc MoveY
		tay


		lda Quadrant
		beq TopRightAngle

		cmp #BOTTOM_RIGHT
		beq BottomRightAngle

		cmp #BOTTOM_LEFT
		beq BottomLeftAngle

		TopLeftAngle:

			lda TopLeftLookup, y
			jmp Finish

		BottomLeftAngle:

			lda BottomLeftLookup, y
			jmp Finish


		BottomRightAngle:

			lda BottomRightLookup, y
			jmp Finish

		TopRightAngle:

			lda TopRightLookup, y
			

		Finish:

			sta Angle, x	
			clc
			adc BasePointer, x
			sta SpritePointer, x


		rts


	 }


	 FindGridSlot: {


		GetSlotYPosition:

			lda Slot, x
			sta ZP.Amount
			tay
			lda FORMATION.Row, y
			tay
			lda FORMATION.RowSpriteY, y
			sta UltimateTargetSpriteY, x

		CalculateMovementRequired:

			sec
			sbc SpriteY, x
			sta MoveY

		CheckIfLess128:

			bmi MoveOkay

		TooBigGap:

			lda #-48
			sta MoveY

			lda SpriteY, x
			clc
			adc MoveY
			sta TargetSpriteY, x
			jmp CalculateX

		MoveOkay:

			lda UltimateTargetSpriteY, x
			sta TargetSpriteY, x


		CalculateX:

			ldy ZP.Amount
			lda FORMATION.Column, y
			clc
			adc FORMATION.Position
			tay

			lda FORMATION.ColumnSpriteX, y
			sta TargetSpriteX, x

			sec
			sbc SpriteX, x
			sta MoveX

		CalculateSpeed:

			jsr CalculateRequiredSpeed



		rts
	}	

	ReturnedGrid: {

			lda SpriteY, x
			cmp UltimateTargetSpriteY, x
			beq ArrivedGrid

			jsr FindGridSlot
			rts

		ArrivedGrid:

			cpx EnemyWithShipID
			bne NoShipAttached

			jsr BEAM.BossReturnedHomeWithShip

			lda #255
			sta EnemyWithShipID

		NoShipAttached:

			lda #10
			sta SpriteY, x
			sta TargetSpriteY, x

			lda #PLAN_INACTIVE
			sta Plan, x

			lda HitsLeft, x
			sta ZP.Amount

			txa
			pha

			lda Slot, x
			tax
			inc FORMATION.Occupied, x

			lda #PLAN_GRID
			sta FORMATION.Plan, x

			lda ZP.Amount
			sta FORMATION.HitsLeft, x

			stx ZP.Amount

			jsr FORMATION.DrawOne

			ldx ZP.Amount

			jsr ATTACKS.AttackerReturns

			pla
			tax

			rts
	}

	

	ReturnedGridTop: {


		lda SpriteY, x
		cmp UltimateTargetSpriteY, x
		beq ArrivedGrid

		jsr ReturnToGridFromTop
		rts 

		ArrivedGrid:

			jmp ReturnedGrid.ArrivedGrid
	}





	GetNextMovement: {

		lda Plan, x
		cmp #PLAN_PATH
		beq GetNextPathPoint

		cmp #PLAN_GOTO_GRID
		beq ArrivedGrid

		cmp #PLAN_RETURN_GRID
		beq ReturnedGrid

		cmp #PLAN_RETURN_GRID_TOP
		beq ReturnedGridTop


		AnotherPlan:

			jmp GetNextAttackPoint

		ArrivedGrid:



			lda #10
			sta SpriteY, x
			sta TargetSpriteY, x

			lda #PLAN_INACTIVE
			sta Plan, x


			lda HitsLeft, x
			sta ZP.Amount

			txa
			pha

			lda Slot, x
			tax
			inc FORMATION.Occupied, x

			lda #PLAN_GRID
			sta FORMATION.Plan, x

			lda ZP.Amount
			sta FORMATION.HitsLeft, x

			jsr FORMATION.DrawOne

			pla
			tax

			dec EnemiesAlive
			lda EnemiesAlive
			bne StillEnemiesToDock

			lda #1
			sta STAGE.ReadyNextWave

		StillEnemiesToDock:

			rts

		NotGotoGrid:
			rts

		GetNextPathPoint:

			inc PositionInPath, x

		DoPath:

			lda Side, x
			beq LeftPath


			RightPath:

				lda PositionInPath, x 
				tay

				lda (ZP.RightPathAddressX), y
				cmp #128
				beq EndOfPath
				sta MoveX
				clc
				adc SpriteX, x
				sta TargetSpriteX, x

				lda (ZP.RightPathAddressY), y
				sta MoveY
				clc
				adc SpriteY, x
				sta TargetSpriteY, x

				lda SpriteY, x
				cmp #MaxYDisappear
				bcs OffScreen

				jsr CalculateRequiredSpeed

				rts


			LeftPath:	

				lda PositionInPath, x 
				tay

				lda (ZP.LeftPathAddressX), y
				cmp #128
				beq EndOfPath
				sta MoveX
				clc
				adc SpriteX, x
				sta TargetSpriteX, x

				lda (ZP.LeftPathAddressY), y
				sta MoveY
				clc
				adc SpriteY, x
				sta TargetSpriteY, x

				lda SpriteY, x
				cmp #MaxYDisappear
				bcs OffScreen

				jsr CalculateRequiredSpeed

				rts

			EndOfPath:

				lda STAGE.StageIndex
				cmp #3
				bcc NotChallenge


			Challenge:

				lda SpriteX, x
				cmp #13
				bcc OffScreen

				cmp #228
				bcs OffScreen

				lda SpriteY, x
			
				cmp #MinYDisappear
				bcc OffScreen

				cmp #MaxY
				bcs OffScreen

				dec PositionInPath, x
				jmp DoPath

			OffScreen:


				lda #PLAN_INACTIVE
				sta Plan, x

				lda #10
				sta SpriteY, x
				sta TargetSpriteY, x
				sta SpriteX, x

				jsr FORMATION.EnemyKilled

				dec EnemiesAlive
				lda EnemiesAlive
				bne StillEnemiesToDock2

				lda #1
				sta STAGE.ReadyNextWave

			StillEnemiesToDock2:
				
				rts

			NotChallenge:

				lda NextPlan, x
				sta Plan, x

				cmp #PLAN_GOTO_GRID
				beq DoGrid

			FlyAway:

				lda #255
				sta PositionInPath, x


				lda Slot, x
				tay
				lda Mirror, y
				clc
				adc #LaunchWaveID
				sta PathID, x

				cmp #24
				bcc Error

				cmp #26
				bcs Error

				jmp Okay

				Error:

				.break
				nop


				Okay:

				jsr GetNextMovement

				rts

			DoGrid:

				lda #0
				sta Angle, x

				jsr FindGridSlot




		rts
	}



	GetNextAttackPoint: {



		MoveToNextPosition:

			inc PositionInPath, x

		GetCurrentPath:

			lda PathID, x
			asl
			tay

		GetAddressOfPath:

			lda X_Paths, y
			sta ZP.RightPathAddressX

			lda X_Paths + 1, y
			sta ZP.RightPathAddressX + 1

			lda Y_Paths, y
			sta ZP.RightPathAddressY

			lda Y_Paths + 1, y
			sta ZP.RightPathAddressY + 1


		CheckPathNotFinished:

			lda PositionInPath, x 
			tay

			lda (ZP.RightPathAddressX), y
			cmp #128
			beq EndOfPath

		PathContinues:

			sta MoveX
			clc
			adc SpriteX, x
			sta TargetSpriteX, x

			lda SpriteX, x
			cmp #70
			bcc LeftSide

			cmp #180
			bcs RightSide

		LeftSide:

			lda TargetSpriteX, x
			cmp #230
			bcc NoWrap

			lda #5
			sta TargetSpriteX, x

		RightSide:

			lda TargetSpriteX, x
			cmp #25
			bcs NoWrap

			.break

			lda #250
			sta TargetSpriteX, x

		NoWrap:


			lda (ZP.RightPathAddressY), y
			sta MoveY
			clc
			adc SpriteY, x
			sta TargetSpriteY, x

		CalculateSpeed:

			jsr CalculateRequiredSpeed

			
			rts


		EndOfPath:


			jmp DecisionOnPostPath
		
	}



	FlyToBottomOfScreen: {

		lda SpriteY, x
		cmp #BottomCircleStartPoint
		beq StartBottomCirclePath

		KeepGoing:

			jsr RANDOM.Get
			and #%000000011
			tay
			lda XMoveLookup, y
			sta MoveX

			

			lda SpriteY, x
			clc
			adc #32
			bcs SetToTargetPosition

			cmp #BottomCircleStartPoint
			bcs SetToTargetPosition

			sta TargetSpriteY, x
			jmp CalculateMovement

		SetToTargetPosition:

			lda #BottomCircleStartPoint
			sta TargetSpriteY, x

			lda #0
			sta MoveX

		CalculateMovement:

			sec
			sbc SpriteY, x
			sta MoveY

			lda SpriteX, x
			clc
			adc MoveX
			sta TargetSpriteX, x

			jsr CalculateRequiredSpeed

			
			dec PositionInPath, x

			rts

		StartBottomCirclePath: 

			lda Slot, x
			tay

			lda #PLAN_ATTACK
			sta Plan, x
			sta FORMATION.Plan, y

			lda #PLAN_HOME_OR_FULL_CIRCLE
			sta FORMATION.NextPlan, y

			lda Mirror, y
			clc
			adc #PATH_BEE_BOTTOM_CIRCLE
			sta PathID, x

			lda #255
			sta PositionInPath, x

			jsr GetNextMovement

			rts


	}

	DecideHomeOrFullCircle: {

		jmp DoCircle

		CheckNumberEnemies:

			lda FORMATION.Alive
			cmp #7
			bcs GotoGrid

		PossibleCircle:

			ldx STAGE.CurrentPlayer
			lda SHIP.Active, x
			bne GotoGrid

		DoCircle:

			lda Slot, x
			tay

		// 	lda FORMATION.Type, y
		// 	cmp #ENEMY_TRANSFORM
		// 	bne NotTransform


		// Transform:




		NotTransform:

			lda Mirror, y
			sta ZP.Amount

			lda #PATH_BEE_TOP_CIRCLE
			clc
			adc #1
			sec
			sbc ZP.Amount
			sta PathID, x

			lda #PLAN_ATTACK
			sta Plan, x
			sta FORMATION.Plan, y

			lda #PLAN_DIVE_ATTACK
			sta FORMATION.NextPlan, y

			lda #255
			sta PositionInPath, x


			jsr GetNextMovement

			ldx ZP.StoredXReg

			rts


		GotoGrid:

			jmp ReturnGrid


		rts
	}

	ReturnGrid: {

		lda #PLAN_RETURN_GRID
		sta Plan, x

		jsr FindGridSlot

		rts
	}


	ReturnToGridFromTop: {

		lda SpriteY, x
		cmp #140
		bcc NormalFlyingDown

		cmp #MaxY
		beq WrapRound


		FlyOutOfScreen:

			lda #PLAN_RETURN_GRID_TOP
			sta Plan, x

			lda Slot, x
			sta ZP.Amount
			tay
			lda FORMATION.Row, y
			tay
			lda FORMATION.RowSpriteY, y
			sta UltimateTargetSpriteY, x

			ldy ZP.Amount
			lda FORMATION.Column, y
			clc
			adc FORMATION.Position
			tay

			lda SpriteX, X
			sta TargetSpriteX, x

		
			lda #0
			sta MoveX

			lda #MaxY
			sta TargetSpriteY, x
			sec
			sbc SpriteY, x
			sta MoveY

			jmp CalculateSpeedEtc

		WrapRound:

			lda Slot, x
			tay
			lda FORMATION.Type, y
			cmp #ENEMY_TRANSFORM
			bne NotTransform

		IsTransform:

			lda #0
			sta Plan, x
			sta FORMATION.Plan, y

			lda #10
			sta SpriteY, x
			sta TargetSpriteY, x
			rts

		NotTransform:

			lda #MinY
			sta SpriteY, x


		NormalFlyingDown:

			lda UltimateTargetSpriteY, x
			sec
			sbc SpriteY, x
			sta MoveY

			bpl MoveOkay

		TooBigGap:

			lda #64
			sta MoveY

			lda SpriteY, x
			clc
			adc MoveY
			sta TargetSpriteY, x
			jmp CalculateX

		MoveOkay:

			lda UltimateTargetSpriteY, x
			sta TargetSpriteY, x

		CalculateX:

			lda Slot, x
			tay
			lda FORMATION.Column, y
			clc
			adc FORMATION.Position
			tay

			lda FORMATION.ColumnSpriteX, y
			sta TargetSpriteX, x

			sec
			sbc SpriteX, x
			sta MoveX

		CalculateSpeedEtc:

			jsr CalculateRequiredSpeed


		rts
	}




	TargetShipX: {


		lda SHIP.PreviousX
		cmp SpriteX, x
		bcs NeedMoveRight

	NeedMoveLeft:

		sec
		sbc SpriteX, x
		bmi OkayMove

		lda #-85
		jmp OkayMove

	NeedMoveRight:

		sec
		sbc SpriteX, x
		bpl OkayMove

		lda #85

	OkayMove:

		sta MoveX
		clc
		adc SpriteX, x
		sta TargetSpriteX, x

		rts

	}

	InitiateFlutter: {	


		CheckSpaceAvailable:

			lda SpriteY, x
			cmp #210
			bcc OkToFlutter

			jmp ReturnToGridFromTop


		OkToFlutter:

			lda SpriteY, x
			cmp #161
			bcs FlutterDown


		FlyTowardsShip:

			jsr TargetShipX

			lda #30
			sta MoveY
			clc
			adc SpriteY, x
			sta TargetSpriteY, x
			
			jsr CalculateRequiredSpeed
			rts

		FlutterDown:

			lda Slot, x
			sty ZP.SlotID
			tay
			lda Mirror, y
			clc
			adc #PATH_FLUTTER
			sta PathID, x

			ldy ZP.SlotID

			lda #PLAN_ATTACK
			sta Plan, x

			lda #PLAN_FLUTTER
			sta NextPlan, x
			sta FORMATION.NextPlan, y

			lda #255
			sta PositionInPath, x

			jsr GetNextMovement
			rts

	}

	

	


	WaitBeam: {

		lda BEAM.Active
		bne BeamActivated

		jsr BEAM.Launch

		ldx ZP.StoredXReg

		lda #8
		sta Angle, x
	


		BeamActivated:

		dec PositionInPath, X

		rts
	}

	BossBeamStraightOut: {

		jmp GotoBeam

		lda #255
		sta PositionInPath, x
		
		lda Mirror, y
		clc
		adc #PATH_BEE_ATTACK
		sta PathID, x

		jsr GetNextMovement

		ldx ZP.StoredXReg

		rts
	}

	GotoBeam: {

		jsr TargetShipX

		tya
		pha

		lda SHIP.CharX
		sta BEAM.Column
		tay

		lda FORMATION.ColumnSpriteX, y
		sec
		sbc #2
		sta TargetSpriteX, x

		pla
		tay

		lda #164
		sta TargetSpriteY, x
		sec
		sbc SpriteY, x
		sta MoveY

		lda #PLAN_WAIT_BEAM
		sta Plan, x
		sta FORMATION.Plan, y

		jsr CalculateRequiredSpeed

		dec PositionInPath, x
	
		rts
	}



	


	BossAttack: {

		lda #255
		sta PositionInPath, x

		lda #PLAN_BOSS_HOME
		sta FORMATION.NextPlan, y

		lda Mirror, y
		clc
		adc #PATH_BOSS_ATTACK
		sta PathID, x

		jsr GetNextMovement
			
		rts
	}

	BossHome: {

		.break

		jmp ReturnToGridFromTop

	}

	DiveAway: {

		lda SpriteY, x
		cmp #230
		bcc SetPath

		Arrived:	

			lda #10
			sta SpriteX, x
			sta SpriteY, x

			lda #0
			sta Plan, x

			lda FORMATION.Mode
			cmp #FORMATION_SPREAD
			beq StillEnemiesToDock3

			dec EnemiesAlive
			lda EnemiesAlive
			bne StillEnemiesToDock3

			lda #1
			sta STAGE.ReadyNextWave

		StillEnemiesToDock3:

			rts

		SetPath:
			
			jsr RANDOM.Get
			and #%00111111
			clc
			adc #(124-32)
			sta TargetSpriteX, x
			sec
			sbc SpriteX, x
			sta MoveX

			lda #230
			sta TargetSpriteY, x
			sec
		 	sbc SpriteY, x
			sta MoveY
 
			bpl Okay

			lda #120
			sta MoveY

		Okay:


		 	jsr CalculateRequiredSpeed

			rts


	}

	


	
	


	CheckMove: {

		//.break
	
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

			cmp #5
			bcs NoWrapRight

			lda #255
			sta SpriteX, x

		NoWrapRight:

			cmp TargetSpriteX, x
			bcc CheckYMove
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

			cmp #245
			bcc NoWrap

			lda #0
			sta SpriteX, x

		NoWrap:

			cmp TargetSpriteX, x
			beq MoveYNow
			
			bcc Wrapped

			jmp CheckYMove

		Wrapped:

			lda TargetSpriteX, x
			sta SpriteX, x
			//jmp CheckYMove		

		MoveYNow:

			lda TargetSpriteY, x
			sec
			sbc SpriteY, x
			clc
			adc #2
			cmp #4
			bcs XMoved

			lda TargetSpriteY, x
			sta SpriteY, x

		Reached:

			jsr GetNextMovement

			ldx ZP.StoredXReg


			//jsr NewDirection
			jmp Done

		CheckYMove:

			lda TargetSpriteY, x
			sec
			sbc SpriteY, x
			bne XMoved

		YArrivedCheckXClose:

			lda TargetSpriteX, x
			sec
			sbc SpriteX, x
			clc
			adc #2
			cmp #4
			bcc Reached

			lda TargetSpriteX, x
			sta SpriteX, x

		XMoved:

			bmi MoveUp

		MoveDown:

			lda SpriteY_LSB, x
			clc
			adc FractionSpeedY, x
			sta SpriteY_LSB, x

			lda SpriteY, x
			adc #0
			clc
			adc PixelSpeedY, x
			sta SpriteY,x 

			cmp TargetSpriteY,x 
			bcc Done
			beq Done

			lda TargetSpriteY,x 
			sta SpriteY,x 
			jmp Done

		MoveUp:

			lda SpriteY_LSB, x
			sec
			sbc FractionSpeedY, x
			sta SpriteY_LSB, x

			lda SpriteY,x 
			sbc #0
			sec
			sbc PixelSpeedY, x
			sta SpriteY, x

			cmp TargetSpriteY, x
			bcs Done
			
			lda TargetSpriteY,x 
			sta SpriteY, x


		Done:


			lda Angle, x
			clc
			adc BasePointer, x
			sta SpritePointer, x


		rts
	}


	DecisionOnPostPath: {

		GetSlotID:

			lda Slot, x
			tay

		CheckWhetherGridEnemy:

			lda IsExtraEnemy, x
			bne NoShot

		CheckWhetherToShoot:

			lda PathID, x
			and #%11111110
			cmp #PATH_LAUNCH
			bne NoShot

		LoadBombs:

			lda Slot, x
			cmp #40
			bcs NoShot

			jsr BOMBS.LoadOnLaunch

		NoShot:

			lda Plan, x
			cmp #PLAN_ATTACK
			beq CurrentAttack

			jmp HandleNonAttackPlan

		CurrentAttack:

			lda FORMATION.NextPlan, y
			sta Plan, x
			sta FORMATION.Plan, y

			cmp #PLAN_ATTACK
			bne HandleNewPlan

			jmp HandleAttack


		HandleNewPlan:

			cmp #PLAN_BOSS_ATTACK
			bne NotBossAttack

			jmp BossAttack

		NotBossAttack:

			cmp #PLAN_DESCEND
			bne NoStartingDescend

			jmp FlyToBottomOfScreen

		NoStartingDescend:

			cmp #PLAN_HOME_OR_FULL_CIRCLE	
			bne NoHomeFullCircle

			jmp DecideHomeOrFullCircle

		NoHomeFullCircle:

			cmp #PLAN_DIVE_ATTACK
			bne NotDiveAttack

			jmp ReturnToGridFromTop

		NotDiveAttack:

			cmp #PLAN_FLUTTER
			bne NotFlutter

		Flutter:


			lda #0
			sta PreviousMoveX, x

			jmp InitiateFlutter

		NotFlutter:

			cmp #PLAN_GOTO_BEAM
			bne NotBeam

			jmp BossBeamStraightOut

		NotBeam:


			lda #PLAN_INACTIVE
			sta Plan, x
			rts

	}	


	HandleAttack: {

		NextAttack:

			lda #255
			sta PositionInPath, x

			lda FORMATION.Type, y
			cmp #ENEMY_HORNET
			beq BeeAttack

		OtherAttack:

			cmp #ENEMY_TRANSFORM
			beq TransformAttack

		ButterflyAttack:

			lda #PLAN_FLUTTER
			sta FORMATION.NextPlan, y

			lda Mirror, y
			clc
			adc #PATH_BEE_ATTACK
			sta PathID, x
			jmp GetNext

		TransformAttack:

			lda #PLAN_DIVE_ATTACK
			sta FORMATION.NextPlan, y

			lda Mirror, y
			clc
			adc #PATH_TRANSFORM_1
			sta PathID, x
			jmp GetNext

		BeeAttack:

			lda #PLAN_DESCEND
			sta FORMATION.NextPlan, y

			lda Mirror, y
			clc
			adc #PATH_BEE_ATTACK
			sta PathID, x

		GetNext:

			jsr GetNextMovement
			ldx ZP.StoredXReg

			rts

	}


	HandleNonAttackPlan: {

			cmp #PLAN_DIVE_AWAY_LAUNCH
			bne NotDiveAway

			jmp DiveAway

		NotDiveAway:

			cmp #PLAN_BOSS_ATTACK
			bne CheckDescending

			jmp ReturnToGridFromTop

		CheckDescending:

			cmp #PLAN_DESCEND
			bne NotFinishedDescend

			jmp FlyToBottomOfScreen

		NotFinishedDescend:

			cmp #PLAN_FLUTTER
			bne NotFlutter

			jmp InitiateFlutter

		NotFlutter:

			cmp #PLAN_GOTO_BEAM
			bne NotBeam

			jmp GotoBeam

		NotBeam:

			cmp #PLAN_TRANSFORM
			bne NotTransform

			jmp NotBossTurn

		NotTransform:

			cmp #PLAN_WAIT_BEAM
			bne NotWaitBeam

			jmp WaitBeam

		NotWaitBeam:

			cmp #PLAN_BOSS_HELD
			bne NotHeld	

			dec PositionInPath, X
			rts

		NotHeld:

			cmp #PLAN_BOSS_TURN
			bne NotBossTurn

			jmp ReturnGrid

		NotBossTurn:

			lda #PLAN_INACTIVE
			sta Plan, x
			rts

	}

}