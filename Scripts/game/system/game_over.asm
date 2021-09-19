END_GAME: {

	* = * "GAME OVER"

	Timer:		.byte 0
	Progress: 	.byte 0

	.label GameOverTime = 75
	.label StatsTime = 250
	.label OverRow = 14
	.label OverColumn = 10


	.label StatsColumn = 1

	.label ValuesColumn = 17

	.label ResultRow = 12
	.label ResultColumn = 8

	* = * ""

	Initialise: {


		lda #GAME_MODE_OVER
		sta MAIN.GameMode


		lda #0
		sta Progress

		jsr DisplayGameOver

		lda #GameOverTime
		sta Timer

		lda #10
		ldx #0

		Loop:

			sta SpriteX, x
			sta SpriteY, x

			inx
			cpx #MAX_SPRITES
			bcc Loop

		lda #SUBTUNE_DANGER
		jsr sid.init


		rts

	}

	* = * "DisplayGameOver"
	DisplayGameOver: {

		lda #OverRow
		sta TextRow

		lda #OverColumn
		sta TextColumn

		ldx #RED
		lda #TEXT.GAME_OVER

		jsr TEXT.Draw


		jsr STATS.Calculate


		rts
	}

	FrameUpdate: {

		lda Progress
		cmp #GAME_OVER_STATS
		bne NoJoyCheck

		ldy #1
		lda INPUT.FIRE_UP_THIS_FRAME, y
		beq NoJoyCheck

		jmp BackToTitle

		NoJoyCheck:

			lda ZP.Counter
			and #%00000001
			beq Finish

			lda Timer
			beq Ready

			dec Timer
			rts

		Ready:

			lda Progress
			bne NotStats

			jmp ShowStats

		NotStats:

			cmp #GAME_OVER_STATS
			bne NotEndStats

			jmp BackToTitle

		NotEndStats:

			lda #GameOverTime
			sta Timer

		Finish:


		rts
	}


	BackToTitle: {	

		lda SHIP.TwoPlayer
		bne TitleScreen

		jsr HI_SCORE.Check

		lda ZP.Amount
		bmi TitleScreen

		HiScore:

			ldy #ResultRow
			ldx #ResultColumn
			lda #10
			jsr UTILITY.DeleteText

			ldy #15
			ldx #StatsColumn
			lda #25
			jsr UTILITY.DeleteText

			ldy #18
			ldx #StatsColumn
			lda #25
			jsr UTILITY.DeleteText

			ldy #21
			ldx #StatsColumn
			lda #25
			jsr UTILITY.DeleteText

			lda #1
			jsr HI_SCORE.Show
		


			rts

		TitleScreen:

			lda #GAME_MODE_SWITCH_TITLE
			sta MAIN.GameMode
			rts

	}

	ShowStats: {	


		lda #0
		sta VIC.SPRITE_ENABLE
		

		jsr FORMATION.DeleteAll

		ldy #OverRow
		ldx #OverColumn
		lda #12
	
		jsr UTILITY.DeleteText

		lda #ResultRow
		sta TextRow

		lda #ResultColumn
		sta TextColumn

		ldx #RED
		lda #TEXT.RESULT

		jsr TEXT.Draw

		Shots:

			lda #15
			sta TextRow

			lda #StatsColumn
			sta TextColumn

			ldx #CYAN
			lda #TEXT.SHOTS

			jsr TEXT.Draw

			lda #15
			sta TextRow

			lda #ValuesColumn
			sta TextColumn

			lda STATS.ShotsFiredP1
			sta TEXT.Text.Word

			lda STATS.ShotsFiredP1 + 1
			sta TEXT.Text.Word + 1

			ldy #CYAN
			ldx #0
			jsr TEXT.DrawWordInDigits




		Hits:

			lda #18
			sta TextRow

			lda #StatsColumn
			sta TextColumn

			ldx #WHITE
			lda #TEXT.HITS

			jsr TEXT.Draw

			lda #18
			sta TextRow

			lda #ValuesColumn
			sta TextColumn

			lda STATS.ShotsHitP1
			sta TEXT.Text.Word

			lda STATS.ShotsHitP1 + 1
			sta TEXT.Text.Word + 1

			ldy #WHITE
			ldx #0
			jsr TEXT.DrawWordInDigits


		Ratio:

			lda #21
			sta TextRow

			lda #StatsColumn
			sta TextColumn

			ldx #YELLOW
			lda #TEXT.RATIO

			jsr TEXT.Draw

			lda #21
			sta TextRow

			lda #ValuesColumn - 1
			sta TextColumn

			ldy #YELLOW

			lda STATS.PercentageCounter
			ldx #0
			jsr TEXT.DrawByteInDigits


			lda #21
			sta TextRow

			lda #ValuesColumn + 2
			sta TextColumn

			ldy #YELLOW

			lda STATS.PercentageCounter + 1
			ldx #1
			jsr TEXT.DrawByteInDigits

			inc Progress

			lda #21
			sta TextRow

			lda #ValuesColumn + 4
			sta TextColumn

			ldx #YELLOW
			lda #TEXT.PERC

			jsr TEXT.Draw


			lda #21
			sta TextRow

			lda #ValuesColumn + 2
			sta TextColumn

			ldx #YELLOW
			lda #TEXT.DOT

			jsr TEXT.Draw

			lda #StatsTime
			sta Timer

		lda SHIP.TwoPlayer
		beq Finish

		jmp Stats2nd

		Finish:

		rts
	}


	Stats2nd: {

		jsr STATS.CalculateP2

		Shots:

		
			lda #15
			sta TextRow

			lda #ValuesColumn + 6
			sta TextColumn

			lda STATS.ShotsFiredP2
			sta TEXT.Text.Word

			lda STATS.ShotsFiredP2 + 1
			sta TEXT.Text.Word + 1

			ldy #CYAN
			ldx #0
			jsr TEXT.DrawWordInDigits




		Hits:

		
			lda #18
			sta TextRow

			lda #ValuesColumn + 6
			sta TextColumn

			lda STATS.ShotsHitP2
			sta TEXT.Text.Word

			lda STATS.ShotsHitP2 + 1
			sta TEXT.Text.Word + 1

			ldy #WHITE
			ldx #0
			jsr TEXT.DrawWordInDigits


		Ratio:

			
			lda #21
			sta TextRow

			lda #ValuesColumn + 5
			sta TextColumn

			ldy #YELLOW

			lda STATS.PercentageCounter
			ldx #0
			jsr TEXT.DrawByteInDigits


			lda #21
			sta TextRow

			lda #ValuesColumn + 8
			sta TextColumn

			ldy #YELLOW

			lda STATS.PercentageCounter + 1
			ldx #1
			jsr TEXT.DrawByteInDigits

	

			lda #21
			sta TextRow

			lda #ValuesColumn + 10
			sta TextColumn

			ldx #YELLOW
			lda #TEXT.PERC

			jsr TEXT.Draw


			lda #21
			sta TextRow

			lda #ValuesColumn + 8
			sta TextColumn

			ldx #YELLOW
			lda #TEXT.DOT

			jsr TEXT.Draw

			lda #StatsTime
			sta Timer


		rts



	}




}