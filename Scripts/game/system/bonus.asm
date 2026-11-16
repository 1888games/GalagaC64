BONUS: {



	Timer:	.byte 255, 255
	Active:	.byte 0, 0

	Colours:	.byte RED, ORANGE, BLUE, GREEN, CYAN, YELLOW, WHITE


	.label StartPointer = 138
	.label StartSpriteID = 10
	.label ShowTime = 60


	FrameUpdate: {

		ldx #0

		Loop:

			lda Active, x
			beq EndLoop

			lda Timer, x
			beq Ready

			dec Timer, x
			jmp EndLoop

			Ready:

				lda #10
			//	sta SpriteX + StartSpriteID, x
				sta SpriteY + StartSpriteID, x

				lda #0
				sta Active, x

			EndLoop:

				inx
				cpx #2
				bcc Loop



		rts
	}


	ShowBonus: {

		// ZP.Row = sprite y
		// ZP.Column = sprite x
		// bonus type = y
		ldx #0

		Loop:

			lda Active, x
			bne NextSlot

			// sprites 10-11 are shared with enemies 10-11,
			// so only borrow one that is free or exploding
			lda ENEMY.Plan + StartSpriteID, x
			beq Found

			cmp #PLAN_EXPLODE
			beq Found

		NextSlot:

			inx
			cpx #2
			beq Abandon

			jmp Loop


		Found:

			lda ZP.Row
			sta SpriteY + StartSpriteID, x

			lda ZP.Column
			sta SpriteX + StartSpriteID, x

			lda Colours, y
			sta SpriteColor + StartSpriteID, x

			tya
			clc
			adc #StartPointer
			sta SpritePointer + StartSpriteID, x

			lda #0
			sta ENEMY.Plan + StartSpriteID, x

			lda #ShowTime
			sta Timer, x

			lda #1
			sta Active, x


		Abandon:

		rts
	}


	ReleaseSprite: {

		// x = enemy ID about to be launched.
		// Cancel any popup borrowing its sprite, otherwise the
		// popup timer later moves the new enemy off screen.

		cpx #StartSpriteID
		bcc Finish

		lda #0
		sta Active - StartSpriteID, x

		Finish:

		rts
	}
}