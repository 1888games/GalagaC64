.namespace ENEMY {

	* = * "Enemy"

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

	FrameUpdate: {

		ldx #0

		Loop:

			stx ZP.EnemyID
			stx ZP.StoredXReg

			lda Plan, x
			beq EndLoop

			jsr ProcessEnemy

		EndLoop:

			ldx ZP.EnemyID
			inx
			cpx #MAX_ENEMIES
			bcc Loop

		Finish:

			lda #0
			sta FormationUpdated

		rts
	}	


	ProcessEnemy: {


		cmp #PLAN_EXPLODE
		bne DontExplode

		jmp Explode
		
		DontExplode:

			//lda FormationUpdated
			//bne FormationIsUpdated
			//jmp NotMovingTowardsGrid

		FormationIsUpdated:

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
			beq Finish

			jsr CheckShipCollision
			jsr BOMBS.CheckEnemyFire

		Finish:


		rts
	}





}