// The difficulty picked on the title screen (left = normal, right = arcade). Normal keeps the
// port's own rules. Arcade follows the arcade (rank A, its factory setting): the ship can move
// during the stage banners and the challenge tally, enemy bombs drop, aim and count like the
// arcade's, and the last few enemies keep diving (ENDGAME)
ARCADE: {

	* = * "Arcade Rules"

	On:		.byte 0

	.label TitleRow = 16
	.label TitleColumn = 11

	// the arcade drops a bomb only while the diver is at least 96 of its 288 lines above the
	// fighter (gg1-5.s), the shortest warning its bombs give: 0.59 s, which at the port's bomb
	// speed is 81 lines above the ship's hit row
	.label ReleaseY = 144
	// the middle of the ship's hit rows (BOMBS.CheckCollision)
	.label AimRow = SHIP.SHIP_Y - 14
	// the ship's hit columns are SHIP.PosX_MSB - 3 to + 10 (BOMBS.CheckCollision), so aim at + 3
	// (BOMBS.CalculateDistanceToPlayer takes 16 off)
	.label AimOffset = 16 + 3

	// arcade stages 1-26 (new_stage.s bmbr_stg_cfg_dat, rank A). Later stages repeat 23-26.
	// BombRow (parameter 0) picks the row of BombsPerDiver. EndgameLeft (parameter 7) is how
	// few enemies are left when the rest stop going home. Unused on the challenging stages
	BombRow:		.byte 0, 0, 0, 1, 1, 2, 0, 2, 2, 1, 0, 3, 3, 3, 0, 4, 4, 1, 0, 5, 5, 5, 0, 6, 6, 6
	EndgameLeft:	.byte 6, 7, 0, 7, 8, 8, 0, 9, 9, 7, 0, 7, 8, 8, 0, 9, 9, 7, 0, 10, 10, 12, 0, 12, 12, 12

	// the bombs each diver may drop (game_ctrl.s d_0909: the bits set in each mask), by BombRow
	// and enemies left / 10. With all 40 left the arcade reads on into the next row
	BombsPerDiver:	.byte 2, 2, 1, 1
					.byte 2, 2, 2, 1
					.byte 3, 2, 2, 1
					.byte 3, 2, 2, 2
					.byte 3, 3, 2, 2
					.byte 4, 3, 2, 2
					.byte 4, 3, 3, 2
					.byte 4, 3, 3, 3
					.byte 2

	.encoding "screencode_mixed"
	NormalText:		.text @"difficulty normal\$00"
	ArcadeText:		.text @"difficulty arcade\$00"

	Row4:	.byte 0
	SaveY:	.byte 0


	// from TITLE.Controls: left on port 2 picks normal, right arcade. Drawn once the title has
	// scrolled in. Leaves y = 1 (port 2) for Controls
	TitleControls: {

		ldy #1

		lda INPUT.JOY_LEFT_NOW, y
		beq CheckRight

		lda #0
		sta On

	CheckRight:

		lda INPUT.JOY_RIGHT_NOW, y
		beq Draw

		lda #1
		sta On

	Draw:

		lda TITLE.Mode
		beq Finish

		lda #TitleRow
		sta TextRow

		lda #TitleColumn
		sta TextColumn

		ldx #WHITE
		lda #TEXT.DIFF_NORMAL

		ldy On
		beq Normal

		ldx #RED
		lda #TEXT.DIFF_ARCADE

	Normal:

		jsr TEXT.Draw

	Finish:

		ldy #1
		rts
	}


	// from the frame loop before a stage and during the challenge tally. The arcade leaves the
	// stick on through both (game_ctrl.s), so the ship can be lined up. Not before the first
	// stage or after losing a ship, and the fire button waits for the stage
	MoveShip: {

		lda On
		beq Finish

		lda PRE_STAGE.GameStarted
		beq Finish

		lda PRE_STAGE.NewStage
		beq Finish

		lda SHIP.Captured
		ora SHIP.Recaptured
		ora SHIP.Docked
		bne Finish

		lda #0
		sta INPUT.FIRE_UP_THIS_FRAME
		sta INPUT.FIRE_UP_THIS_FRAME + 1

		jsr SHIP.Control

		lda SHIP.TwoPlayer
		beq OnePlayer

		jsr SHIP.Control2

	OnePlayer:

		jsr SHIP.UpdateSprites

	Finish:

		rts
	}


	// from BOMBS.CheckEnemyFire, A = the diver's Y. Carry set when it's too low to drop a bomb.
	// The arcade uses the bomb up then, the port keeps it for later. Keeps Y
	TooLow: {

		pha
		lda On
		bne Arcade

		pla
		cmp #120
		rts

	Arcade:

		pla
		cmp #ReleaseY
		bcc Finish

		dec BOMBS.BombsLeft, x

		lda #BOMBS.ReloadTime
		sta BOMBS.ShotTimer, x

		sec

	Finish:

		rts
	}


	// from BOMBS.LoadOnLaunch, A = the port's bombs for diver x. On arcade, the arcade's
	// instead. Keeps Y (ENEMY.DecisionOnPostPath's formation slot)
	BombCount: {

		pha
		lda On
		bne Arcade

		pla
		rts

	Arcade:

		pla
		sty SaveY

		lda STAGE.CurrentStage

	Fold:

		cmp #26
		bcc Folded

		sbc #4
		bcs Fold

	Folded:

		tay
		lda BombRow, y
		asl
		asl
		sta Row4

		lda FORMATION.Alive
		ldy #255
		sec

	Tens:

		iny
		sbc #10
		bcs Tens

		cpy #5
		bcc NoClamp

		ldy #4

	NoClamp:

		tya
		clc
		adc Row4
		tay

		lda BombsPerDiver, y

		ldy SaveY
		rts
	}


	// from BOMBS.CalculateDistanceToPlayer: A = the random part of the aim. The arcade aims
	// straight at the fighter
	AimJitter: {

		lda On
		bne Arcade

		jmp RANDOM.Get

	Arcade:

		lda #AimOffset
		rts
	}


	// from BOMBS.CalculateDistanceToPlayer: A = the row a bomb is aimed at. The port aims at the
	// bottom of the screen, which lands short of a ship to the side
	AimY: {

		lda On
		bne Arcade

		lda #BOMBS.MaxY
		rts

	Arcade:

		lda #AimRow
		rts
	}


	// from BOMBS.CalculateRequiredSpeed: halve the sideways distance. The port rounds down, so
	// a bomb can fall short of the ship. The arcade's bombs reach it, so round up
	HalveX: {

		lsr BOMBS.MoveX

		lda On
		beq Finish

		bcc Finish

		inc BOMBS.MoveX

	Finish:

		rts
	}

	.errorif * > $7080, "the arcade rules run into ENDGAME"
}
