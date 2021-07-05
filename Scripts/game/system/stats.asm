STATS: {

	* = * "STATS"

	ShotsFiredP1:	.word 1291
	ShotsFiredP2:	.word 0

	EnemiesHitP1:	.word 712
					.byte 0

	EnemiesHitP2:	.word 0

	ShotsHitP1:		.word 712
	ShotsHitP2:		.word 0

	Ratio:		.byte 0, 0, 0

	PercentageCounter:	.byte 0, 0

	PrevRatio:	.byte 0, 0, 0


	Reset: {

		lda #0

		sta Ratio
		sta Ratio + 1
		sta Ratio + 2

		sta PercentageCounter
		sta PercentageCounter + 1

		sta EnemiesHitP1
		sta EnemiesHitP1 + 1		
		sta EnemiesHitP1 + 2

		sta EnemiesHitP2
		sta EnemiesHitP2 + 1

		sta ShotsHitP1
		sta ShotsHitP1 + 1

		sta ShotsHitP2
		sta ShotsHitP2 + 1

		sta ShotsFiredP1
		sta ShotsFiredP1 + 1
		sta ShotsFiredP2
		sta ShotsFiredP2



		rts
	}


	Shoot: {

		lda STAGE.CurrentPlayer
		asl
		tax

		lda ShotsFiredP1, x
		clc
		adc #1
		sta ShotsFiredP1, x

		lda ShotsFiredP1 + 1, x
		adc #0
		sta ShotsFiredP1 + 1, x


		rts
	}

	Hit: {

		lda STAGE.CurrentPlayer
		asl
		tax

		lda ShotsHitP1, x
		clc
		adc #1
		sta ShotsHitP1, x

		lda ShotsHitP1 + 1, x
		adc #0
		sta ShotsHitP1 + 1, x

		rts

	}

	Calculate: {

		lda #0
		sta Ratio
		sta Ratio + 1
		sta Ratio + 2
		sta PercentageCounter
		sta PercentageCounter + 1

		lda ShotsHitP1 
		sta EnemiesHitP1

		lda ShotsHitP1 + 1
		sta EnemiesHitP1 + 1


		MultiplyHitBy100:

			ldx #1
			jsr SHIFTMIS

			ldx #2
			jsr SHIFTMIS

			ldx #0
			jsr SHIFTMIS


		DivideHitsByShots:

			ldx #0

			lda ShotsFiredP1
			bne DivMis

			lda ShotsFiredP1 + 1
			beq Done

		DivMis:

			lda Ratio
			sta PrevRatio

			lda Ratio + 1
			sta PrevRatio + 1

			lda Ratio + 2
			sta PrevRatio + 2

			lda Ratio
			sec
			sbc ShotsFiredP1
			sta Ratio

			lda Ratio + 1
			sbc ShotsFiredP1 + 1
			sta Ratio + 1

			lda Ratio + 2
			sbc #0
			sta Ratio + 2

			bmi DoneDivision

			inc PercentageCounter, x
			lda PercentageCounter, x
			cmp #100
			beq Done

			jmp DivMis

		DoneDivision:

			jsr RatioBy100Again

			inx 
			cpx #2
			bcc DivMis

		Done:

			lda PercentageCounter + 1
			
			jsr TEXT.ByteToDigits

			lda TEXT.Text.Digits + 2
			cmp #5
			bcc NoRound

			lda PercentageCounter + 1
			clc
			adc #10
			sta PercentageCounter + 1


			NoRound:
		



			nop

		rts
	}


	RatioBy100Again: {

		lda #0
		sta Ratio
		sta Ratio + 1
		sta Ratio + 2

		ldy #0

		Loop:

			lda Ratio
			clc
			adc PrevRatio
			sta Ratio

			lda Ratio + 1
			adc #0
			sta Ratio + 1

			lda Ratio + 2
			adc #0
			sta Ratio + 2

			iny
			cpy #100
			bcc Loop

		rts
	}

	SHIFTMIS: {

		clc
		asl EnemiesHitP1 + 2
		asl EnemiesHitP1 + 1
		bcc SHIFTM1

		inc EnemiesHitP1 + 2

		SHIFTM1:	

			asl EnemiesHitP1
			bcc SHIFTM2
			inc EnemiesHitP1 + 1

		SHIFTM2:

			dex
			bpl SHIFTMIS
			lda Ratio
			clc
			adc EnemiesHitP1
			sta Ratio

			lda Ratio + 1
			adc EnemiesHitP1 + 1
			sta Ratio + 1

			lda Ratio + 2
			adc EnemiesHitP1 + 2
			sta Ratio + 2

			rts


	}

}