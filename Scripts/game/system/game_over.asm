END_GAME: {

	* = * "GAME OVER"

	Timer:		.byte 0
	Progress: 	.byte 0

	.label GameOverTime = 75
	.label StatsTime = 250
	.label OverRow = 14
	.label OverColumn = 10


	.label StatsColumn = 2
	.label ValuesColumn = 20

	.label ResultRow = 12
	.label ResultColumn = 9



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

		lda #GAME_MODE_SWITCH_TITLE
		sta MAIN.GameMode
		rts

	}

	ShowStats: {	


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

		rts
	}





}