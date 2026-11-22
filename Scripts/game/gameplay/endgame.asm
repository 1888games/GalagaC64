// The arcade difficulty's endgame: once fewer than ARCADE.EndgameLeft enemies are left, they
// stop going home and keep diving (the arcade's continuous bombing)
ENDGAME: {

	* = $7080 "Endgame"

	// set while it lasts (gg1-5.s: fewer left than stage parameter 7 and the fire button in
	// play), else 0. Only ever set on arcade
	Flag:		.byte 0

	// the stage Left and Faster are for
	Stage:		.byte 255
	Left:		.byte 0
	// 1 from stage 12 (parameter 9): the faster passes in the dive paths (Dive.LATER)
	Faster:		.byte 0

	// the arcade launches a bomber every 2 ticks of its 16 frame timer (game_ctrl.s f_0857)
	.label LaunchDelay = 26


	// from the frame loop before the enemies move
	FrameUpdate: {

		lda ARCADE.On
		beq Clear

		lda STAGE.CurrentStage
		cmp Stage
		beq SameStage

		jsr NewStage

	SameStage:

		// not while the waves fly in, on a challenging stage, or with the ship gone or
		// being captured
		lda ATTACKS.Active
		beq Clear

		lda SHIP.Active
		beq Clear

		lda SHIP.Captured
		ora SHIP.Recaptured
		bne Clear

		lda FORMATION.Alive
		cmp Left
		bcs Clear

		lda #1
		sta Flag

		// and the next launch comes sooner
		lda ATTACKS.DelayTimer
		cmp #LaunchDelay + 1
		bcc Finish

		lda #LaunchDelay
		sta ATTACKS.DelayTimer

	Finish:

		rts

	Clear:

		lda #0
		sta Flag
		rts
	}


	// A = STAGE.CurrentStage. Later stages repeat 23-26 (as in ARCADE.BombCount)
	NewStage: {

		sta Stage

	Fold:

		cmp #26
		bcc Folded

		sbc #4
		bcs Fold

	Folded:

		tay
		lda ARCADE.EndgameLeft, y
		sta Left

		cpy #11
		lda #0
		rol
		sta Faster

		rts
	}


	.errorif * > $7200, "ENDGAME runs into the smooth formation tables"
}
