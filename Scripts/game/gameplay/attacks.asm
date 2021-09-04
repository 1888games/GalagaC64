ATTACKS: {


	* = * "Attacks"

	NumAttackers:	.byte 0
	DelayTimer:		.byte 0
	MakeBeam:		.byte 0



	AttackOrder:	.byte 4, 20, 12, 30, 11, 29, 19, 39,  5, 21, 13, 31, 10, 28
					.byte 18, 38,  6, 22, 14, 32,  9, 27, 17, 37,  7, 23, 15, 33
					.byte 8, 26, 16, 36, 24, 34, 25, 35

	TransformOrder:	.byte 30, 39, 20, 29, 31, 38, 21, 28, 32, 37, 22, 27
					.byte 33, 36, 23, 26, 34, 35, 24, 25
					.byte 12, 19, 4, 11, 13, 18, 5, 10, 14, 17, 6, 9, 15, 16, 7, 8



	* = * "Attackers"


	Active:					.byte 0
	BeamStatus:				.byte 0
	BeamBoss:				.byte 255
	OrphanedFighterColumn:	.byte 0
	OrphanedFighterID:	    .byte 255
	AddFighterToWave:		.byte 0
	InitialAttacks:			.byte 255
	MaxAttackers:			.byte 2
	TransformsQueued:		.byte 0
	TransformID:			.byte 255
	TransformTimer:			.byte 250
	TransformsDone:			.byte 0

	.label DelayTime = 20
	.label TransformChance = 100
	.label TransformGap = 15


	ConvoySize:		.byte 0, 0, 0, 0
	DelayTimes:		.byte 20, 30, 40, 50


	Reset: {

		lda #255
		sta BeamBoss
		sta InitialAttacks
		sta TransformID
		sta OrphanedFighterID

		lda #0
		sta Active
		sta BeamStatus
		sta NumAttackers
		sta DelayTimer
		sta OrphanedFighterColumn

		

		rts


	}


	CheckBeamBossHit: {

		lda BeamStatus
		cmp #BEAM_DOCKED
		bne NotBeamBoss

		cpx BeamBoss
		bne NotBeamBoss

		lda FORMATION.Column, x
		sta OrphanedFighterColumn

		lda #1
		sta AddFighterToWave

		lda #BEAM_ORPHANED
		sta BeamStatus

		lda BeamBoss
		sta OrphanedFighterID

		lda #255
		sta BeamBoss

		NotBeamBoss:

		rts
	}


	CalculateMaxAttackers: {

		lda #2
		sta MaxAttackers

		lda STAGE.CurrentStage
		cmp #7
		bcc Finish

		cmp #11
		bcc AddOne

		inc MaxAttackers

		AddOne:

		inc MaxAttackers

		Finish:

		rts
	}

	AttackReady: {

		jsr CalculateMaxAttackers


		lda InitialAttacks
		bpl SecondAttack

		jsr CalculateAttackSpeed

		lda #2
		sta InitialAttacks

		lda BEAM.Progress
		cmp #BEAM_DOCKED
		beq NoResetBeam

		ResetBeam:

			lda #255
			sta BeamBoss
			sta OrphanedFighterID

			lda #0
			sta BeamStatus

		NoResetBeam:	
			
			lda #255	
			sta TransformID

			lda #1
			sta Active

			ldx #0
			stx NumAttackers
			stx TransformsQueued
			stx TransformsDone

		SecondAttack:

		lda SpeedCalcActive
		beq Loop

		rts

		Loop:

			lda AttackOrder, x
			tay

			lda FORMATION.Occupied, y
			beq EndLoop

			lda FORMATION.Plan, y
			cmp #PLAN_GRID
			bne EndLoop

		Found:

			// y = Formation ID


			jsr LaunchAttacker


			sfx(SFX_DIVE)

			jmp Finish

		EndLoop:

			inx
			cpx #40
			bcc Loop

			lda #255
			sta InitialAttacks
			rts



		Finish:

			dec InitialAttacks

			lda InitialAttacks
			bne StillMore

			lda #255
			sta InitialAttacks

		StillMore:

		
			rts

	}


	LaunchAttacker: {

		sty ZP.CurrentID

		tya
		tax

		ldy NumAttackers
		lda DelayTimes, y
		sta DelayTimer

		inc NumAttackers

		jsr FORMATION.Delete

		ldy ZP.CurrentID

		lda #0
		sta FORMATION.Occupied, y

		lda #PLAN_ATTACK
		sta FORMATION.NextPlan, y
		sta FORMATION.Plan, y

		jsr ENEMY.LaunchFromGrid


		rts
	}


	AttackerReturns: {

		dec NumAttackers

		lda #DelayTime
		sta DelayTimer

		CheckIfBeamBoss:

			cpx BeamBoss
			bne NotBeamBoss

			lda BEAM.Progress
			cmp #BEAM_CLOSING
			bne NotBeamBoss

			lda #0
			sta BeamStatus

			lda BEAM.BeamBossSpriteID
			bmi NotBeamBoss

			lda #255
			sta BeamBoss

		NotBeamBoss:

		rts


		Error:

			lda #0
			sta NumAttackers

			jmp CheckIfBeamBoss

			rts
	}

	AttackerKilled: {

		lda Active
		beq NotBeamBoss

		jsr AttackerReturns

		CheckIfBeamBoss:

			lda BeamBoss
			cmp ZP.Amount

			bne NotBeamBoss

			lda #255
			sta BeamBoss

			lda #0
			sta BeamStatus

		NotBeamBoss:

			rts
	}

		

	LaunchOrphan: {

		ldy OrphanedFighterID

		lda #ENEMY_FIGHTER
		sta FORMATION.Type, y

		jsr LaunchAttacker

		lda #DelayTime
		sta DelayTimer

		lda #PLAN_BOSS_ATTACK
		sta FORMATION.NextPlan, y

		lda #0
		sta OrphanedFighterColumn

		lda #10
		sta SpriteY + SHIP.MAIN_SHIP_POINTER + 1

		rts
	}


	 TryAndPickBoss: {

	 	lda OrphanedFighterColumn
		beq NoOrphan

		jmp LaunchOrphan

		NoOrphan:


		ldy #0

		Loop:

			sty ZP.StoredYReg

			CheckIfEnemyAvailable:

				lda FORMATION.Plan, y
				sty ZP.Amount
				cmp #PLAN_GRID
				beq CheckWhetherToTakeShip

				jmp EndLoop

			CheckWhetherToTakeShip:

				cpy TransformID
				bne NotTransform

				jmp EndLoop

			NotTransform:

				lda SHIP.Docked
				beq NoShipDocked

				cpy BeamBoss
				bne NoShipDocked

			LaunchAndTakeShip:

				lda #CAPTURE_PLAYER_ATTACK
				sta BEAM.CaptureProgress
				
				jsr LaunchAttacker

				lda #PLAN_BOSS_ATTACK
				sta FORMATION.NextPlan, y

				stx ENEMY.EnemyWithShipID
				jmp CheckCargo

			NoShipDocked:

				lda BeamStatus
				bne LaunchNormalAttack

				lda SHIP.DualFighter
				clc
				adc SHIP.TwoPlayer
				bne LaunchNormalAttack

				jsr RANDOM.Get
				and #%00000001
				beq LaunchNormalAttack

				//jmp LaunchNormalAttack

			LaunchAndMakeBeam:

				sty BeamBoss

				jsr LaunchAttacker

				lda #DelayTime
	 			sta DelayTimer


				stx BEAM.BeamBossSpriteID

				lda #PLAN_GOTO_BEAM
				sta FORMATION.NextPlan, y

				lda #0
				sta ConvoySize, y

	 			lda #BEAM_POSITION
	 			sta BeamStatus

	 			jmp FinishUp

			LaunchNormalAttack:

				jsr LaunchAttacker

				lda #DelayTime
	 			sta DelayTimer

				lda #PLAN_BOSS_ATTACK
				sta FORMATION.NextPlan, y

			CheckCargo:

				tya
				clc
				adc #5
				sta ZP.EndID

				lda #0
				sta ZP.Temp1
				sta ConvoySize, y
			
				CargoLoop:

					ldx NumAttackers
					cpx #4
					bcs FinishUp

				NotFirst:

					ldy ZP.EndID
					lda FORMATION.Plan, y
					cmp #PLAN_GRID
					bne EndCargoLoop

					cpy TransformID
					beq EndCargoLoop

					jsr LaunchAttacker

					lda #PLAN_BOSS_ATTACK
					sta FORMATION.NextPlan, y


					ldy ZP.StoredYReg

					lda ConvoySize, y
					clc
					adc #1
					sta ConvoySize, y

				EndCargoLoop:		

					inc ZP.EndID

					inc ZP.Temp1
					lda ZP.Temp1
					cmp #2
					bcc CargoLoop
			
			FinishUp:

				sfx(SFX_DIVE)

				rts


		EndLoop:

			ldy ZP.StoredYReg
			iny
			cpy #4
	 		beq Finish

	 		jmp Loop

	 	Finish:

			rts

	 }


	InitialiseTransforms: {

	 	sty TransformID

	 	lda #3
	 	sta TransformsQueued

	 	inc TransformsDone

	 	lda #250
	 	sta TransformTimer

	 	jsr FORMATION.StartTransform

	 	sfx(SFX_TRANSFORM)

	 	rts
	 }


	 TryTransform: {

		ldx #0

		BeeLoop:

			lda TransformOrder, x
			tay

			lda FORMATION.Plan, y
			sty ZP.Amount
			cmp #PLAN_GRID
			bne EndBeeLoop

			jmp InitialiseTransforms

		EndBeeLoop:

			inx
			cpx #36
			bcc BeeLoop



	 	rts
	 }

	 StartTransforms: {

	 	lda #0
	 	sta TransformTimer

	 	rts
	 }

	 CancelTransforms: {

	 	lda #1
	 	sta TransformsDone

	 	lda #0
	 	sta TransformsQueued

	 	lda #255
	 	sta TransformID

	 	rts
	 }

	 TryBeeOrButterfly: {

		lda NumAttackers
		cmp MaxAttackers
		bcs Finish

		CheckTransform:

			lda TransformsDone
			bne NoTransforms

			lda STAGE.CurrentStage
			cmp #3
			bcc NoTransforms

			lda TransformsQueued
			bne NoTransforms

			jsr RANDOM.Get
			cmp #TransformChance
			//bcs NoTransforms

			jmp TryTransform

		NoTransforms:


		ldx #0

		BeeLoop:

			lda AttackOrder, x
			tay

			cpy TransformID
			beq EndBeeLoop

			lda FORMATION.Plan, y
			sty ZP.Amount
			cmp #PLAN_GRID
			bne EndBeeLoop

			jsr LaunchAttacker


			sfx(SFX_DIVE)

			jmp Finish

		EndBeeLoop:

			inx
			cpx #36
			bcc BeeLoop


		Finish:


		rts
	 }


	ShowDebug: {

		lda NumAttackers
		clc
		adc #48
		sta SCREEN_RAM + 439

		lda #CYAN
		sta VIC.COLOR_RAM + 439

		lda BeamBoss
		clc
		adc #48
		sta SCREEN_RAM + 478

		lda #GREEN
		sta VIC.COLOR_RAM + 478
		lda BeamStatus
		clc
		adc #48
		sta SCREEN_RAM + 479

		lda #YELLOW
		sta VIC.COLOR_RAM + 479


		lda ConvoySize
		clc
		adc #48
		sta SCREEN_RAM + 518

		lda #WHITE
		sta VIC.COLOR_RAM + 518


		lda OrphanedFighterColumn
		clc
		adc #48
		sta SCREEN_RAM + 519

		lda #PURPLE
		sta VIC.COLOR_RAM + 519



		rts
	}

	 ChooseAttacker: {

	 //	jsr ShowDebug

	 	CheckAllowed:

		 	lda Active
		 	beq Finish

		 	lda SHIP.Active
		 	beq Finish

		 	lda SHIP.Captured
		 	clc
		 	adc SHIP.Recaptured
			beq NotCapture

			rts

	 	NotCapture:

	 		lda DelayTimer
	 		beq Ready

			dec DelayTimer
	 		rts

	 	Ready:	

	 		
	 		lda #DelayTime
	 		sta DelayTimer

	 	CheckNeedNewAttackers:

			lda NumAttackers
			cmp #2
			bcc TryPickBoss

			cmp MaxAttackers
			bcc TryBee

			rts

		TryPickBoss:

			
			jsr TryAndPickBoss

		TryBee:

			jsr TryBeeOrButterfly		
			
	 	Finish:


	 	rts
	}

	CountAttackers: {

		lda NumAttackers
		sta ZP.EndID

		lda #0
		sta NumAttackers

		ldx #0

		Loop:


			lda ENEMY.Plan, x
			cmp #PLAN_INACTIVE
			beq EndLoop

			inc NumAttackers

			EndLoop:

				inx
				cpx #MAX_ENEMIES
				bcc Loop




		rts
	}



	LaunchTransform: {


		dec TransformsQueued

		ldx TransformID
		jsr FORMATION.Delete

		ldy TransformID

		lda #0
		sta FORMATION.Occupied, y
		sta FORMATION.Plan, y

		tya
		tax

		lda #40
		clc
		adc TransformsQueued
		tay

		lda FORMATION.Column, x
		sta FORMATION.Column, y

		lda FORMATION.Row, x
		sta FORMATION.Row, y

		lda Mirror, x
		sta Mirror, y

		lda #PLAN_ATTACK
		sta FORMATION.Plan, y
		sta FORMATION.NextPlan, y

		jsr ENEMY.LaunchFromGrid

		lda TransformsQueued
		bne StillSomeToGo

		lda #255
		sta TransformID


		StillSomeToGo:

		rts
	}

		

	CheckTransforms: {

		lda TransformsQueued
		beq Finish

		lda TransformTimer
		beq Ready

		dec TransformTimer
		rts

		Ready:

		lda #TransformGap
		sta TransformTimer

		jsr LaunchTransform

		


		Finish:

		rts
	}

	FrameUpdate: {

		// lda AddFighterToWave
		// clc
		// adc #48
		// sta SCREEN_RAM + 5

		// lda #RED
		// sta VIC.COLOR_RAM + 5



		lda Active
		beq Finish	

		

		jsr CountAttackers
		jsr CheckTransforms

		lda DelayTimer
		beq Ready

		dec DelayTimer
		rts

		Ready:

		lda InitialAttacks
		bmi DoneInitial

			jsr AttackReady
			rts

		DoneInitial:

			lda BEAM.CaptureProgress
			cmp #RECAPTURE_PLAYER_SPIN
			beq Finish

			jsr ChooseAttacker

		Finish:

		rts
	}

	
}



