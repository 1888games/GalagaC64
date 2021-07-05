ATTACKS: {


	* = * "Attacks"

	NumAttackers:	.byte 0
	DelayTimer:		.byte 0
	MakeBeam:		.byte 0


	AttackOrder:	.byte 4, 20, 12, 30, 11, 29, 19, 39,  5, 21, 13, 31, 10, 28
					.byte 18, 38,  6, 22, 14, 32,  9, 27, 17, 37,  7, 23, 15, 33
					.byte 8, 26, 16, 36, 24, 34, 25, 35


	* = * "Attackers"
	//Attackers:		.fill 4, 255
	//AttackType:		.fill 4, 255

	Active:			.byte 0
	BeamStatus:		.byte 0
	BeamBoss:		.byte 255
	OrphanedFighterColumn:	.byte 0
	AddFighteroWave:	.byte 0

	//BossDocked:		.byte 255

	.label DelayTime = 25


	ConvoySize:		.byte 0, 0, 0, 0


	Reset: {

		lda #255
		//sta Attackers
		//sta Attackers + 1
		//sta Attackers + 2
		//sta Attackers + 3
		sta BeamBoss

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

		lda #BEAM_ORPHANED
		sta BeamStatus

		lda #255
		sta BeamBoss


		NotBeamBoss:



		rts
	}

	AttackReady: {

		jsr CalculateAttackSpeed

		lda #255
		//sta Attackers + 2
		//sta Attackers + 3
		sta BeamBoss

		lda #1
		sta Active

		ldx #0
		//sty NumAttackers
		stx BeamStatus

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

			lda NumAttackers
			cmp #2
			bcs Finish


		EndLoop:

			inx
			cpx #40
			bcc Loop

		Finish:
		
			rts

	}


	LaunchAttacker: {

		inc NumAttackers

		


		sty ZP.CurrentID

		tya
		tax

		jsr FORMATION.Delete

		ldy ZP.CurrentID

		lda #0
		sta FORMATION.Occupied, y

		lda #DelayTime
		sta DelayTimer

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

	


	 TryAndPickBoss: {

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
				jmp FinishUp

			NoShipDocked:

				lda BeamStatus
				bne LaunchNormalAttack

				lda SHIP.DualFighter
				bne LaunchNormalAttack

				jsr RANDOM.Get
				and #%00000001
				beq LaunchNormalAttack

				//jmp LaunchNormalAttack

			LaunchAndMakeBeam:

				sty BeamBoss

				jsr LaunchAttacker

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

	 TryBeeOrButterfly: {

		lda NumAttackers
		cmp #2
		bcs Finish

		ldx #0

		BeeLoop:

			lda AttackOrder, x
			tay

			lda FORMATION.Plan, y
			sty ZP.Amount
			cmp #PLAN_GRID
			bne EndBeeLoop	


			jsr LaunchAttacker

			sfx(SFX_DIVE)

			jmp Finish

		EndBeeLoop:

			inx
			cpx #40
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

	 	jsr ShowDebug


	 	CheckAllowed:

		 	lda Active
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

			rts

		TryPickBoss:

			lda SHIP.Active
			beq Finish

			jsr TryAndPickBoss
			jsr TryBeeOrButterfly		
			
	 	Finish:


	 	rts
	 }




	FrameUpdate: {

		lda Active
		beq Finish	

		jsr ChooseAttacker

		Finish:

		rts
	}

	
}



