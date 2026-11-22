// The arcade difficulty's bomber launcher: the arcade's timers launch the divers all stage, no
// more at once than its limit. And its endgame: once fewer than ARCADE.EndgameLeft enemies are
// left, they stop going home and keep diving (the arcade's continuous bombing)
ENDGAME: {

	* = $7080 "Endgame"

	// set while it lasts (gg1-5.s: fewer left than stage parameter 7 and the fire button in
	// play), else 0. Only ever set on arcade
	Flag:		.byte 0

	// the stage's: enemies left for the endgame (parameter 7), 1 from stage 12 for the
	// faster passes in the dive paths (parameter 9, Dive.LATER), parameter 1 as a row of
	// BossTimes and 2 and 3 as rows of ShipTimes
	Left:		.byte 0
	Faster:		.byte 0
	BossRow:	.byte 0
	ShipRows:	.byte 0, 0
	// the most bombers flying at once: parameter 4, then 5 once the stage timer is below 60
	Most:		.byte 0
	MostLater:	.byte 0

	// the arcade's stage timer (ds4_game_tmrs[2]) x 2: 240 as a stage starts, down one a tick
	// (the arcade's goes down every other tick), 60 back when a ship comes in after a loss
	StageTimer:	.byte 0

	// the arcade's bomber timers (gg1-2_fx.s f_1B65), boss, red and yellow, in ticks of its
	// 16 frame timer: 13 1/3 frames here, 3 added a frame and a tick at 40
	Timers:		.byte 0, 0, 0
	Ticks:		.byte 0
	// the types the red and yellow timers launch, and the one being looked for
	TimerTypes:	.byte ENEMY_MOTH, ENEMY_HORNET
	Type:		.byte 0

	// 1 once the endgame has stopped the formation's drone, until the next stage
	HumOff:		.byte 0


	// from the frame loop before the enemies move
	FrameUpdate: {

		lda ARCADE.On
		beq Clear

		lda Ticks
		clc
		adc #3
		cmp #40
		bcc NoTick

		sbc #40

	NoTick:

		sta Ticks
		bcc Timed

		// below 60 on the stage timer the most bombers rise to parameter 5 for the rest of
		// the stage (game_ctrl.s f_0857)
		lda StageTimer
		beq Timed

		dec StageTimer
		cmp #60 * 2 + 1
		bcs Timed

		lda MostLater
		sta Most

	Timed:

		// launches only once the formation is complete (gg1-3.s:1907), so not on a
		// challenging stage
		lda ATTACKS.Active
		bne Attacking

		// (the drone starts again with the next formation: STAGE.MoveIntoFormationMode)
		sta HumOff

	Clear:

		lda #0
		sta Flag
		rts

	Attacking:

		// the timers launch instead of ATTACKS.ChooseAttacker, which waits once the port's
		// first attacks are out (ATTACKS.AttackReady)
		lda ATTACKS.InitialAttacks
		bpl FirstAttacks

		lda #1
		sta ATTACKS.DelayTimer

	FirstAttacks:

		// and not with the ship gone or being captured (gg1-2_fx.s:861)
		lda SHIP.Active
		beq Clear

		lda SHIP.Captured
		ora SHIP.Recaptured
		bne Clear

		lda #0
		sta Flag

		lda FORMATION.Alive
		cmp Left
		bcs Launch

		inc Flag

		// the formation's drone stops for the rest of the stage (game_ctrl.s:1415). If
		// the tractor beam has the music, when that ends (play_background)
		lda HumOff
		bne Launch

		inc HumOff

		lda BEAM.Active
		bne Launch

		jsr play_background

	Launch:

		// each tick once the port's first attacks are out (Ticks is below 3 just after one)
		lda ATTACKS.InitialAttacks
		bpl Finish

		lda Ticks
		cmp #3
		bcs Finish

		// the arcade's clone attack (gg1-2_fx.s f_1A80) comes once a stage from stage 4,
		// when fewer than 10 are left: the port's transform then
		lda ATTACKS.TransformsDone
		ora ATTACKS.TransformsQueued
		bne Tick

		lda STAGE.CurrentStage
		cmp #3
		bcc Tick

		lda FORMATION.Alive
		cmp #10
		bcs Tick

		jsr ATTACKS.TryTransform
		jmp Tick

	Finish:

		rts
	}


	// the arcade's bomber launcher, each tick (gg1-2_fx.s:927 l_1BA8): the first timer to run
	// out launches its type, unless the most bombers allowed are flying already
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
		cmp Most
		bcc Launch

		// try again next tick (l_1BB4)
		inc Timers, x
		rts

	Launch:

		jsr Reload
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

		ldx #SFX_DIVE
		jmp sfx_play
	}


	// A = the ticks until timer x runs out again (game_ctrl.s f_0857): 2 in the endgame, else
	// the boss's by the enemies left / 10 (c_08BE), the others' by the stage timer: from 40,
	// below, at 0 (c_08AD). Keeps X
	Reload: {

		lda #2
		ldy Flag
		bne Finish

		txa
		bne Ships

		lda FORMATION.Alive
		ldy #255
		sec

	Tens:

		iny
		sbc #10
		bcs Tens

		cpy #5
		bcc Boss

		ldy #4

	Boss:

		tya
		clc
		adc BossRow
		tay
		lda BossTimes, y
		rts

	Ships:

		ldy #0
		lda StageTimer
		cmp #40 * 2
		bcs Column

		iny
		cmp #1 * 2
		bcs Column

		iny

	Column:

		tya
		clc
		adc ShipRows - 1, x
		tay
		lda ShipTimes, y

	Finish:

		rts
	}


	// from ATTACKS.LaunchAttacker: Y = ATTACKS.NumAttackers, which picks one of the 4
	// ATTACKS.DelayTimes. On arcade more can be flying, so 3 at most. Keeps X
	Attackers: {

		ldy ATTACKS.NumAttackers

		lda ARCADE.On
		beq Finish

		cpy #4
		bcc Finish

		ldy #3

	Finish:

		rts
	}


	// from PRE_STAGE.StartStage as play starts: a new stage, or the next ship after a loss
	Start: {

		lda ARCADE.On
		beq Finish

		lda PRE_STAGE.NewStage
		beq NextShip

		// the arcade's round start (task_man.s:252, new_stage.s:99)
		jsr NewStage

		lda #120 * 2
		sta StageTimer

		lda #22
		sta Timers
		lda #2
		sta Timers + 1
		sta Timers + 2
		rts

	NextShip:

		// to 120 at most (game_ctrl.s:856)
		lda StageTimer
		clc
		adc #30 * 2
		bcs Full

		cmp #120 * 2
		bcc Store

	Full:

		lda #120 * 2

	Store:

		sta StageTimer

	Finish:

		rts
	}


	.errorif * > $7200, "ENDGAME runs into the smooth formation tables"


	// in the gap after the smooth formation tables (nothing writes there)
	* = $73a4 "Endgame Tables"

	// the reloads (game_ctrl.s): the boss's (d_0909 + 32 on), 4 a row by parameter 1, by
	// the enemies left / 10. With all 40 left the arcade reads on into the next row, and past
	// the last into its code ($3a)
	BossTimes:	.byte 6, 10, 15, 15
				.byte 4, 8, 13, 13
				.byte 4, 6, 10, 10
				.byte $3a

	// arcade stages 1-26 (new_stage.s bmbr_stg_cfg_dat, rank A): parameters 2 and 3 (its
	// second byte), and 1, 4 and 5 (%11444555)
	Params23:	.byte $00, $11, $00, $12, $23, $24, $00, $25, $36, $11, $00, $46, $67
				.byte $67, $00, $78, $78, $22, $00, $88, $88, $88, $00, $89, $99, $99
	Params145:	.byte $12, $13, $00, $53, $53, $5b, $00, $9b, $9c, $13, $00, $9c, $a4
				.byte $a5, $00, $a5, $a5, $53, $00, $a6, $ae, $ae, $00, $af, $af, $af


	// from play_background: A = FORMATION.Mode, the drone unless 0. On arcade 0 once the
	// endgame has stopped the drone this stage. Keeps X and Y
	Hum: {

		lda ARCADE.On
		and HumOff
		beq Mode

		lda #0
		rts

	Mode:

		lda FORMATION.Mode
		rts
	}

	.errorif * > $7400, "the endgame's tables run into the game map"


	// in the gap after the dives
	* = $5fa1 "Endgame Stage"

	// STAGE.CurrentStage's parameters. Later stages repeat 23-26 (as in ARCADE.BombCount)
	NewStage: {

		lda STAGE.CurrentStage

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

		lda Params23, y
		lsr
		lsr
		lsr
		lsr
		jsr Times3
		sta ShipRows

		lda Params23, y
		and #15
		jsr Times3
		adc #30
		sta ShipRows + 1

		lda Params145, y
		and #7
		sta MostLater

		lda Params145, y
		lsr
		lsr
		lsr
		pha
		and #7
		sta Most

		pla
		lsr
		and #%00001100
		sta BossRow

		rts
	}


	// A x 3, carry clear
	Times3: {

		sta Type
		asl
		adc Type
		rts
	}

	.errorif * > $6000, "the endgame's stage set up runs into the music"


	// in the gap after the music (nothing writes there)
	* = $6bbd "Endgame Reloads"

	// the red's (d_08CD), 3 a row by parameter 2, then the yellow's (d_08EB) by parameter 3
	ShipTimes:	.byte 9, 7, 5,  8, 6, 4,  7, 5, 4,  6, 4, 3,  5, 3, 3
				.byte 4, 3, 3,  4, 2, 2,  3, 3, 2,  3, 2, 2,  2, 2, 2
				.byte 6, 5, 4,  5, 4, 3,  5, 3, 3,  4, 3, 2,  4, 2, 2
				.byte 3, 3, 2,  3, 2, 1,  2, 2, 1,  2, 1, 1,  1, 1, 1

	.errorif * > $6c00, "the endgame's reloads run into MAIN"
}
