CHALLENGE: {


	
	Progress:		.byte 0
	Timer:			.byte 0
	PerfectProgress:	.byte 0

	.label GapTime = 50
	.label EndTime = 200

	.label HitsRow = 12
	.label HitsColumn = 3
	.label HitNumColumn = HitsColumn + 16

	.label BonusRow = 15

	.label BonusColumn = HitsColumn + 3
	.label BonusNumColumn = BonusColumn + 7

	.label PerfectRow = HitsRow - 3
	.label PerfectColumn = HitsColumn + 5
	.label SpecialColumn = 1

	.label FlashTime = 15

	Initialise: {


		lda #GAME_MODE_CHALLENGE
		sta MAIN.GameMode

		lda #0
		sta Progress
		sta PerfectProgress

		jsr DrawHitsTitle

		lda #GapTime
		sta Timer

		lda #10
		ldx #0

		Loop:

			sta SpriteX, x
			sta SpriteY, x

			inx
			cpx #MAX_SPRITES - 2
			bcc Loop

		lda SHIP.TwoPlayer
		bne NotPerfect

		lda STAGE.KillCount
		cmp #STAGE.NumberOfWaves * 8
		bcc NotPerfect

	Perfect:

		lda #SUBTUNE_PERFECT
		jsr sid.init
		rts

	NotPerfect:

		lda #SUBTUNE_CHALLENGING
		jsr sid.init

		rts
	}



	FrameUpdate: {

		CheckTimer:

			lda Timer
			beq Ready

			dec Timer
			rts

		Ready:

			lda Progress
			cmp #CHALLENGE_NUM_HITS
			bne NotNumHits

			jmp ShowHits

		NotNumHits:

			cmp #CHALLENGE_BONUS_TITLE
			bne NotBonusTitle

			jmp ShowBonusTitle

		NotBonusTitle:

			cmp #CHALLENGE_BONUS
			bne NotBonus

			jmp ShowNormalBonus


		NotBonus:

			cmp #CHALLENGE_PERFECT
			bne NotPerfect

			jmp ShowPerfect

		NotPerfect:

			cmp #CHALLENGE_SPECIAL
			bne NotSpecial

			jmp ShowSpecialBonus

		NotSpecial:


			jsr Exit

		Finish:


		rts
	}

	ShowSpecialBonus: {


		lda #BonusRow
		sta TextRow

		lda #SpecialColumn
		sta TextColumn

		ldx #YELLOW
		lda #TEXT.SPECIAL

		jsr TEXT.Draw


		lda #EndTime
		sta Timer

	 	lda #CHALLENGE_EXIT
	 	sta Progress

	 	ldy #17
	 	jsr SCORE.AddScore


		rts
	}

	ShowPerfect: {

		lda #RED
		sta ZP.Colour

		lda PerfectProgress
		cmp #7
		beq Finished

		and #%00000001
		beq Show

		lda #BLACK
		sta ZP.Colour


		Show:

			lda #PerfectRow
			sta TextRow

			lda #PerfectColumn
			sta TextColumn

			ldx ZP.Colour
			lda #TEXT.PERFECT

			jsr TEXT.Draw

			lda #FlashTime
			sta Timer

			inc PerfectProgress
			rts

		Finished:

			inc Progress
			rts
	}

	Exit: {

		lda #GAME_MODE_PRE_STAGE
		sta MAIN.GameMode

		lda #1
		sta PRE_STAGE.Progress
		sta STAGE.SpawnTimer
		sta PRE_STAGE.NewStage

		jsr DeleteText

		rts
	}


	ShowNormalBonus: {

		lda #0
		sta TEXT.Text.Word
		sta TEXT.Text.Word + 1

		lda STAGE.KillCount
		beq SkipBonus

		ldx #0

		Loop:	

			stx ZP.KillID

			lda TEXT.Text.Word
			clc
			adc #100
			sta TEXT.Text.Word

			lda TEXT.Text.Word + 1
			adc #0
			sta TEXT.Text.Word + 1

			lda #0
			sta BULLETS.PlayerShooting

			ldy #1
			jsr SCORE.AddScore

			ldx ZP.KillID
			inx
			cpx STAGE.KillCount
			bcc Loop


			SkipBonus:

			lda #BonusRow
			sta TextRow

			lda #BonusNumColumn
			sta TextColumn	

			ldy #CYAN
			ldx #0
			jsr TEXT.DrawWordInDigits	

			inc Progress

			lda #EndTime
			sta Timer


		Finish:

		jmp ShowTwoPlayerBonus

		
	}

	ShowTwoPlayerBonus: {

		lda SHIP.TwoPlayer
		beq Finish

		lda #0
		sta TEXT.Text.Word
		sta TEXT.Text.Word + 1

		lda STAGE.KillCount + 1
		beq SkipBonus

		ldx #0

		Loop:	

			stx ZP.X

			lda TEXT.Text.Word
			clc
			adc #100
			sta TEXT.Text.Word

			lda TEXT.Text.Word + 1
			adc #0
			sta TEXT.Text.Word + 1

			lda #1
			sta BULLETS.PlayerShooting

			ldy #1
			jsr SCORE.AddScore

			ldx ZP.X
			inx
			cpx STAGE.KillCount + 1
			bcc Loop


		SkipBonus:

			lda #BonusRow
			sta TextRow

			lda #BonusNumColumn + 5
			sta TextColumn	

			ldy #YELLOW
			ldx #0
			jsr TEXT.DrawWordInDigits	

			inc Progress

			lda #EndTime
			sta Timer


		Finish:


		rts
	}
	DrawHitsTitle: {

		lda #HitsRow
		sta TextRow

		lda #HitsColumn
		sta TextColumn

		ldx #CYAN
		lda #TEXT.HITS

		jsr TEXT.Draw

		inc Progress


		rts
	}

	ShowBonusTitle: {

		lda #BonusRow
		sta TextRow

		lda #BonusColumn
		sta TextColumn

		ldx #CYAN
		lda #TEXT.BONUS

		jsr TEXT.Draw

		inc Progress

		lda #GapTime
		sta Timer


		rts
	}


	DeleteText: {

		ldy #HitsRow
		ldx #HitsColumn
		lda #24
	
		jsr UTILITY.DeleteText

		ldy #BonusRow
		ldx #SpecialColumn
		lda #25
	
		jsr UTILITY.DeleteText

		ldy #PerfectRow
		ldx #PerfectColumn
		lda #12
	
		jsr UTILITY.DeleteText

		rts
	}

	ShowHits: {

		lda #HitsRow
		sta TextRow

		lda #HitNumColumn
		sta TextColumn

		ldy #CYAN

		lda STAGE.KillCount
		ldx #0
		jsr TEXT.DrawByteInDigits

		lda SHIP.TwoPlayer
		beq OnePlayer

	TwoPlayer:

		lda #HitsRow
		sta TextRow

		lda #HitNumColumn + 3
		sta TextColumn

		ldy #YELLOW

		lda STAGE.KillCount + 1
		ldx #0
		jsr TEXT.DrawByteInDigits

	OnePlayer:

		lda #GapTime
		sta Timer

		
		lda SHIP.TwoPlayer
		bne NotPerfect

		lda STAGE.KillCount
		cmp #STAGE.NumberOfWaves * 8
		bcc NotPerfect

	Perfect:

		inc Progress
		rts

	NotPerfect:

		lda #CHALLENGE_BONUS_TITLE
		sta Progress

		rts
	}

	
}