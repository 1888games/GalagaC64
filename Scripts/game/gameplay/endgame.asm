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
	// the arcade's bomb timer on each pass, 30 frames (gg1-5.s case_0BA8)
	.label ShotDelay = 25
	// where a pass may come in at the top (Again)
	.label EdgeLeft = ENEMY.Dive.MIN_X + 40
	.label EdgeRight = ENEMY.Dive.MAX_X - 40


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


	// from Dive.ReadPath: A = an endgame command, y = PathPos, x = the diver
	Command: {

		cmp #ENEMY.Dive.ENTER
		beq Enter

		// FREE: on while the endgame lasts, else home
		cmp #ENEMY.Dive.FREE
		bne NotFree

		lda Flag
		bne Next
		beq Jump

	NotFree:

		cmp #ENEMY.Dive.GOTO
		beq Jump

		// LATER: the faster pass from stage 12, else the usual one
		lda Faster
		bne Next

	Jump:

		lda ENEMY.Dive.Paths + 1, y
		sta ENEMY.Dive.PathPos, x
		jmp ENEMY.Dive.ReadPath

	Enter:

		// heading h x 4, mirrored for the right half (128 - h)
		lda ENEMY.Dive.Paths + 1, y
		ldy ENEMY.Dive.Flip, x
		beq Heading

		eor #255
		clc
		adc #129

	Heading:

		sta ENEMY.Dive.HeadingLo, x
		lda #0
		sta ENEMY.Dive.HeadingHi, x
		asl ENEMY.Dive.HeadingLo, x
		rol ENEMY.Dive.HeadingHi, x
		asl ENEMY.Dive.HeadingLo, x
		rol ENEMY.Dive.HeadingHi, x

		// bombs for the pass
		jsr BOMBS.LoadOnLaunch

		ldx ZP.EnemyID
		lda #ShotDelay
		sta BOMBS.ShotTimer, x

	Next:

		lda ENEMY.Dive.PathPos, x
		clc
		adc #2
		sta ENEMY.Dive.PathPos, x
		jmp ENEMY.Dive.ReadPath
	}


	// from Dive.Move, x = a diver that Dive.Leave hid last frame. While the endgame lasts it
	// comes back in at the top above its slot and dives again, else it drops into the slot
	// (Dive.Top)
	Again: {

		lda Flag
		bne Pass

		jmp ENEMY.Dive.Top

	Pass:

		// off the bottom where its path planned a pass (ENTER) it takes that one, else
		// the usual one for its path
		ldy ENEMY.Dive.PathPos, x
		lda ENEMY.Dive.Paths, y
		cmp #ENEMY.Dive.ENTER
		beq Position

		ldy #ENEMY.Dive.BEE_AGAIN
		lda ENEMY.Dive.PathPos, x
		cmp #ENEMY.Dive.BUTTERFLY
		bcc Usual

		ldy #ENEMY.Dive.BUTTERFLY_AGAIN
		cmp #ENEMY.Dive.BOSS
		bcc Usual

		ldy #ENEMY.Dive.BOSS_AGAIN

	Usual:

		tya
		sta ENEMY.Dive.PathPos, x

	Position:

		ldy ENEMY.Slot, x
		lda FORMATION.Column, y
		clc
		adc FORMATION.Position
		tay
		lda FORMATION.ColumnSpriteX, y
		clc
		adc FORMATION.SubPixels

		// the passes swing out up to 35 pixels before they turn in, so keep the outer
		// columns clear of the sides (Dive.MIN_X and MAX_X)
		cmp #EdgeLeft
		bcs NotLeft

		lda #EdgeLeft

	NotLeft:

		cmp #EdgeRight
		bcc NotRight

		lda #EdgeRight

	NotRight:

		sta SpriteX, x

		lda #ENEMY.Dive.TOP_Y
		sta SpriteY, x

		lda #0
		sta SpriteX_LSB, x
		sta SpriteY_LSB, x
		sta ENEMY.Dive.WaitY, x

		sfx(SFX_DIVE)

		jmp ENEMY.Dive.ReadPath
	}

	.errorif * > $7200, "ENDGAME runs into the smooth formation tables"
}
