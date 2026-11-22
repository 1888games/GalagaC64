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

	// the arcade's bomber timers (gg1-2_fx.s f_1B65), boss, red and yellow, in ticks of its
	// 16 frame timer: 13 1/3 frames here, 3 added a frame and a tick at 40
	Timers:		.byte 0, 0, 0
	Ticks:		.byte 0
	// the types the red and yellow timers launch, and the one being looked for
	TimerTypes:	.byte ENEMY_MOTH, ENEMY_HORNET
	Type:		.byte 0

	// while the endgame lasts each timer starts again at 2 ticks after a launch
	// (game_ctrl.s f_0857)
	.label Reload = 2


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

		// as it starts, each timer as if its type had just launched
		lda Flag
		bne Started

		lda #Reload
		sta Timers
		sta Timers + 1
		sta Timers + 2

	Started:

		lda #1
		sta Flag

		// the timers launch instead of ATTACKS.ChooseAttacker, which waits
		sta ATTACKS.DelayTimer

		lda Ticks
		clc
		adc #3
		cmp #40
		bcc Wait

		sbc #40
		sta Ticks
		jmp Tick

	Wait:

		sta Ticks
		rts

	Clear:

		lda #0
		sta Flag
		rts
	}


	// the arcade's bomber launcher, each tick (gg1-2_fx.s:927 l_1BA8): the first timer to run
	// out launches its type, unless the most attackers allowed are flying already
	Tick: {

		ldx #0

	Loop:

		dec Timers, x
		beq Ready

		inx
		cpx #3
		bcc Loop

		rts

	Ready:

		lda ATTACKS.NumAttackers
		cmp ATTACKS.MaxAttackers
		bcc Launch

		// try again next tick (l_1BB4)
		inc Timers, x
		rts

	Launch:

		lda #Reload
		sta Timers, x

		dex
		bpl RedOrYellow

		jmp ATTACKS.TryAndPickBoss

	RedOrYellow:

		// the first of the type waiting in the formation, in the port's attack order
		lda TimerTypes, x
		sta Type

		ldx #0

	Find:

		ldy ATTACKS.AttackOrder, x
		cpy ATTACKS.TransformID
		beq Next

		lda FORMATION.Plan, y
		cmp #PLAN_GRID
		bne Next

		lda FORMATION.Type, y
		cmp Type
		beq Found

	Next:

		inx
		cpx #36
		bcc Find

		rts

	Found:

		sty ZP.Amount
		jsr ATTACKS.LaunchAttacker

		sfx(SFX_DIVE)
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
