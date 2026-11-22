.namespace ENEMY {

	.var dives_pc = *

	* = $5a10 "Arcade Dives"

	// Dives that steer like the arcade's. A diver has a heading (10 bits: 0 right, 256 up,
	// counter-clockwise) that turns by Rate a frame, and moves Speed pixels along the main
	// axis of its octant and the other axis in proportion to the angle into it (so faster on
	// the diagonals, as the arcade's are). A path is a list of segments: speed (this frame's
	// pixels in the low nibble on odd frames, the high on even), rate, frames; with commands
	// between. The arcade's 60 Hz rates and frame counts are converted to 50 Hz (rates x1.2,
	// frames x5/6) at the same pixels a frame, which shrinks the shapes by 5/6 to fit the
	// shorter playfield: the bees' turn under the ship bottoms out at Y 251 (PLEXOR shows up
	// to 254)
	Dive: {

		.label WAIT_Y = $fc			// y: keep the segment going until SpriteY >= y
		.label AIM = $fb			// 8 frame counts: keep turning for the one picked by the ship's X
		.label HOME = $fe			// fly up into the slot from here (ENEMY.ReturnGrid)
		.label TOP = $fd			// come back in at the top, above the slot, and drop into it

		// the endgame's (ENDGAME.Command), in the arcade's continuous bombing
		.label FREE = $fa			// p: carry on while the endgame lasts, else from p (home)
		.label GOTO = $f9			// p: carry on from p
		.label ENTER = $f8			// h: come in at the top heading h x 4, with bombs again
		.label LATER = $f7			// p: before stage 12 carry on from p, else the faster pass here

		.label TOP_Y = 8			// (hidden: PLEXOR shows Y >= 20)
		.label MIN_X = 8			// off the sides past these: come back in at the top
		.label MAX_X = 236
		.label BEE_TURN_Y = 205		// where the bees start their turn under the ship

		Pending:	.fill MAX_ENEMIES, 0
		HeadingLo:	.fill MAX_ENEMIES, 0
		HeadingHi:	.fill MAX_ENEMIES, 0
		Rate:		.fill MAX_ENEMIES, 0
		Speed:		.fill MAX_ENEMIES, 0
		Frames:		.fill MAX_ENEMIES, 0
		WaitY:		.fill MAX_ENEMIES, 0
		PathPos:	.fill MAX_ENEMIES, 0
		Flip:		.fill MAX_ENEMIES, 0
		Leaving:	.fill MAX_ENEMIES, 0	// hidden off the bottom or a side, to the top next frame

		Pixels:		.byte 0
		Fraction:	.byte 0
		OtherLo:	.byte 0
		OtherHi:	.byte 0
		Octant:		.byte 0
		Out:		.byte 0
		Temp:		.byte 0
		Vector:		.word 0

		.errorif mod(Vector, 256) == $ff, "jmp (Vector) can't straddle a page"

		OctantCode:	.word Octant0, Octant1, Octant2, Octant3, Octant4, Octant5, Octant6, Octant7

		// for a slot in the left half; the right half turns the other way
		Paths:

		BeePath:

			.byte $12, 29, 25			// loop out of the formation

		BeeDive:

			.byte $12, 0, 43			// across
			.byte $12, -6, 32			// round to face down
			.byte $12, 0, 2
			.byte WAIT_Y, BEE_TURN_Y	// down to the ship
			.byte $12, -7, 51			// turn under it
			.byte FREE, BeeHome - Paths
			.byte $12, -10, 13			// the endgame: loop round and off the bottom
			.byte $12, -7, 79
			.byte $12, 0, 255
			.byte TOP

		BeeHome:

			.byte $12, -10, 13
			.byte $12, 0, 53			// climb
			.byte HOME

		// the endgame's passes (ENDGAME.Again): in at the top above the slot and dive
		// again (gg1-5.s db_flv_atk_yllw). From stage 12 a faster one
		BeeAgain:

			.byte LATER, BeeAgain2 - Paths
			.byte ENTER, $b0
			.byte $23, 10, 24
			.byte $23, 0, 21
			.byte $23, -10, 18
			.byte $23, 0, 2
			.byte WAIT_Y, BEE_TURN_Y - 3
			.byte $23, -11, 31
			.byte FREE, BeeHome - Paths
			.byte $23, -20, 8
			.byte $23, -13, 35
			.byte $23, -14, 6
			.byte $23, 0, 255
			.byte TOP

		BeeAgain2:

			.byte ENTER, $ab
			.byte $12, 1, 26
			.byte $12, 2, 7
			.byte $12, 12, 20
			.byte GOTO, BeeDive - Paths

		ButterflyPath:

			.byte $12, 29, 24

		ButterflyDive:

			.byte $12, 0, 33
			.byte $12, -7, 2
			.byte AIM, 53, 49, 45, 42, 33, 32, 30, 28	// (the ship far left to far right)
			.byte $12, 5, 38			// weave
			.byte $12, -5, 38
			.byte $12, 0, 255			// off the bottom
			.byte TOP

		// (db_flv_atk_red) from stage 12 two faster passes before each usual one
		ButterflyAgain:

			.byte LATER, ButterflyAgain2 - Paths
			.byte ENTER, $c0
			.byte $23, 10, 13
			.byte $23, 0, 29
			.byte $23, -10, 12
			.byte $23, 0, 255
			.byte ENTER, $b0
			.byte $23, 10, 26
			.byte $23, 0, 7
			.byte $23, -10, 2
			.byte AIM, 42, 39, 36, 33, 27, 30, 25, 19
			.byte $23, 10, 19
			.byte $23, -10, 19
			.byte $23, 0, 255

		ButterflyAgain2:

			.byte ENTER, $b0
			.byte $12, 1, 26
			.byte $12, 2, 7
			.byte $12, 12, 11
			.byte $12, 13, 6
			.byte GOTO, ButterflyDive - Paths

		// and its escorts
		BossPath:

			.byte $12, 28, 17

		BossDive:

			.byte $12, 4, 32
			.byte $12, 0, 3
			.byte $12, 19, 54			// a full loop
			.byte $12, 1, 27
			.byte $12, -2, 56			// a long curve off the bottom
			.byte $12, -3, 38
			.byte $12, 0, 255
			.byte TOP

		// (db_flv_0411) from stage 12 a faster one
		BossAgain:

			.byte LATER, BossAgain2 - Paths
			.byte ENTER, $b0
			.byte $23, 5, 21
			.byte $23, 4, 22
			.byte $23, 31, 31			// a loop
			.byte $23, 4, 12
			.byte $23, -4, 54
			.byte $23, 0, 255
			.byte TOP

		BossAgain2:

			.byte ENTER, $ab
			.byte $12, 2, 17
			.byte $12, 3, 10
			.byte GOTO, BossDive - Paths

		.label BEE = BeePath - Paths
		.label BUTTERFLY = ButterflyPath - Paths
		.label BOSS = BossPath - Paths
		.label BEE_AGAIN = BeeAgain - Paths
		.label BUTTERFLY_AGAIN = ButterflyAgain - Paths
		.label BOSS_AGAIN = BossAgain - Paths

		.errorif * - Paths > 256, "the dive paths are indexed with y"


		// x = enemy, the frame after ENEMY.LaunchFromGrid, once ATTACKS has said what the
		// attacker's for. Bees, butterflies and bosses with their escorts take a dive; the beam
		// boss, a boss bringing the captured fighter, fighters and transforms keep the launch path
		Start: {

			lda #0
			sta Pending, x
			sta Leaving, x

			lda Plan, x
			cmp #PLAN_ATTACK
			bne Exit

			ldy Slot, x
			lda FORMATION.NextPlan, y
			cmp #PLAN_BOSS_ATTACK
			beq Boss

			cmp #PLAN_ATTACK
			bne Exit

			lda FORMATION.Type, y
			cmp #ENEMY_HORNET
			beq Bee

			cmp #ENEMY_MOTH
			beq Butterfly

		Exit:

			rts

		Butterfly:

			lda #BUTTERFLY
			jmp WhichWay

		Bee:

			lda #BEE

		WhichWay:

			sta PathPos, x

			lda Mirror, y
			sta Flip, x
			jmp Begin

		Boss:

			lda BEAM.CaptureProgress
			cmp #CAPTURE_PLAYER_ATTACK
			bne NotBringingFighter

			cpx EnemyWithShipID
			beq Finish

		NotBringingFighter:

			lda FORMATION.Type, y
			cmp #ENEMY_FIGHTER
			beq Finish

			lda #BOSS
			sta PathPos, x

			// the bosses in the right half (2 and 3) turn the other way, and their escorts
			// (boss + 5 and + 6) with them
			tya
			cmp #4
			bcc IsBoss

			sbc #5
			cmp #4
			bcs Sixth

			tay
			lda FORMATION.Plan, y
			cmp #PLAN_GRID
			bne HaveBoss

			dey
			bpl HaveBoss

			iny
			jmp HaveBoss

		Sixth:

			sbc #1
			tay

		HaveBoss:

			tya

		IsBoss:

			cmp #2
			lda #0
			rol
			sta Flip, x

			ldy Slot, x

		Begin:

			lda #PLAN_ARCADE
			sta Plan, x

			lda FORMATION.NextPlan, y
			sta FORMATION.Plan, y

			// straight up
			lda #0
			sta HeadingLo, x
			sta WaitY, x
			lda #1
			sta HeadingHi, x

			jsr BOMBS.LoadOnLaunch

			ldx ZP.EnemyID
			jmp ReadPath

		Finish:

			rts
		}


		// x = enemy: the next segment or command
		ReadPath: {

			ldy PathPos, x

			lda Paths, y
			cmp #LATER
			bcs Command

			sta Speed, x

			lda Flip, x
			beq NotFlipped

			lda #0
			sec
			sbc Paths + 1, y
			jmp SetRate

		NotFlipped:

			lda Paths + 1, y

		SetRate:

			sta Rate, x

			lda Paths + 2, y
			sta Frames, x

			tya
			clc
			adc #3
			sta PathPos, x

			rts

		Command:

			cmp #AIM
			beq Aim
			bcc Endgame

			cmp #WAIT_Y
			beq Wait

			cmp #HOME
			bne ToTop

			jmp ReturnGrid

		ToTop:

			jmp Leave

		Endgame:

			jmp ENDGAME.Command

		Wait:

			lda Paths + 1, y
			sta WaitY, x

			iny
			iny
			tya
			sta PathPos, x

			rts

		// which of 8 16 pixel bands, from 64 left to 64 right, the ship is in, from the
		// diver (mirrored for the right half)
		Aim:

			lda SHIP.PosX_MSB
			sec
			sbc SpriteX, x
			bcc ShipLeft

		ShipRight:

			cmp #64
			bcs FarRight

			lsr
			lsr
			lsr
			lsr
			ora #4
			jmp Band

		FarRight:

			lda #7
			jmp Band

		ShipLeft:

			cmp #256 - 64
			bcc FarLeft

			sbc #256 - 64
			lsr
			lsr
			lsr
			lsr
			jmp Band

		FarLeft:

			lda #0

		Band:

			ldy Flip, x
			beq NoMirror

			eor #7

		NoMirror:

			clc
			adc PathPos, x
			tay
			lda Paths + 1, y
			sta Frames, x

			lda PathPos, x
			clc
			adc #9
			sta PathPos, x

			rts
		}


		// x = enemy: off the bottom or a side. PLEXOR draws this frame from the Y that Sort
		// copied at the start of it, but with the X as it is now, so moving the diver above
		// its slot now would flash it at its old Y and new X. Hide it now and move it next
		// frame (Move)
		Leave: {

			lda #1
			sta Leaving, x

			lda #0
			sta SpriteY, x

			rts
		}


		// x = enemy: hidden by Leave last frame, come back in at the top above the slot and
		// drop into it (ENEMY.ReturnToGridFromTop)
		Top: {

			ldy Slot, x
			lda FORMATION.Row, y
			tay
			lda FORMATION.RowSpriteY, y
			sta UltimateTargetSpriteY, x

			ldy Slot, x
			lda FORMATION.Column, y
			clc
			adc FORMATION.Position
			tay
			lda FORMATION.ColumnSpriteX, y
			clc
			adc FORMATION.SubPixels
			sta SpriteX, x

			lda #TOP_Y
			sta SpriteY, x

			lda #0
			sta SpriteX_LSB, x
			sta SpriteY_LSB, x

			lda #PLAN_RETURN_GRID_TOP
			sta Plan, x

			jmp ReturnToGridFromTop
		}


		// x = enemy, every frame of a dive
		Move: {

			lda Leaving, x
			beq OnScreen

			lda #0
			sta Leaving, x

			jmp ENDGAME.Again

		OnScreen:

			lda #0
			sta Out

			lda ZP.Counter
			lsr
			lda Speed, x
			bcs OddFrame

			lsr
			lsr
			lsr
			lsr

		OddFrame:

			and #15
			sta Pixels

			// the octant, 0 - 7 counter-clockwise from right, and the angle into it from the
			// main axis (0 - 127: the odd octants count back from their end)
			lda HeadingLo, x
			asl
			lda HeadingHi, x
			rol
			sta Octant

			lda HeadingLo, x
			and #127
			sta Fraction

			lda Octant
			lsr
			bcc EvenOctant

			lda #127
			sec
			sbc Fraction
			sta Fraction

		EvenOctant:

			asl Fraction

			// the other axis moves pixels x angle / 128 (x 256 for the fraction byte)
			lda #0
			sta OtherLo
			sta OtherHi

			ldy Pixels
			beq Turn

		Sum:

			lda OtherLo
			clc
			adc Fraction
			sta OtherLo
			bcc NoCarry

			inc OtherHi

		NoCarry:

			dey
			bne Sum

			lda Octant
			asl
			tay
			lda OctantCode, y
			sta Vector
			lda OctantCode + 1, y
			sta Vector + 1

			jmp (Vector)

		Moved:

			lda Out
			bne OffScreen

			lda SpriteX, x
			cmp #MIN_X
			bcc OffScreen

			cmp #MAX_X
			bcc Turn

		OffScreen:

			jmp Leave

		Turn:

			ldy #0
			lda Rate, x
			bpl Add

			dey

		Add:

			clc
			adc HeadingLo, x
			sta HeadingLo, x
			tya
			adc HeadingHi, x
			and #3
			sta HeadingHi, x

			// the sprite: 16 ways clockwise from up, (288 - heading) / 64
			lda #<288
			sec
			sbc HeadingLo, x
			sta Temp
			lda #>288
			sbc HeadingHi, x
			and #3
			asl
			asl
			sta Octant

			lda Temp
			asl
			rol
			rol
			and #3
			ora Octant
			sta Angle, x

			clc
			adc BasePointer, x
			sta SpritePointer, x

			lda WaitY, x
			beq Count

			lda SpriteY, x
			cmp WaitY, x
			bcc Done

			lda #0
			sta WaitY, x
			jmp ReadPath

		Count:

			dec Frames, x
			bne Done

			jmp ReadPath

		Done:

			rts
		}


		Octant0: {

			jsr MainRight
			jsr OtherUp
			jmp Move.Moved
		}

		Octant1: {

			jsr MainUp
			jsr OtherRight
			jmp Move.Moved
		}

		Octant2: {

			jsr MainUp
			jsr OtherLeft
			jmp Move.Moved
		}

		Octant3: {

			jsr MainLeft
			jsr OtherUp
			jmp Move.Moved
		}

		Octant4: {

			jsr MainLeft
			jsr OtherDown
			jmp Move.Moved
		}

		Octant5: {

			jsr MainDown
			jsr OtherLeft
			jmp Move.Moved
		}

		Octant6: {

			jsr MainDown
			jsr OtherRight
			jmp Move.Moved
		}

		Octant7: {

			jsr MainRight
			jsr OtherDown
			jmp Move.Moved
		}


		// past an edge (except the top) sets Out
		MainRight: {

			lda SpriteX, x
			clc
			adc Pixels
			sta SpriteX, x
			bcc Finish

			inc Out

		Finish:

			rts
		}

		MainLeft: {

			lda SpriteX, x
			sec
			sbc Pixels
			sta SpriteX, x
			bcs Finish

			inc Out

		Finish:

			rts
		}

		MainDown: {

			lda SpriteY, x
			clc
			adc Pixels
			sta SpriteY, x
			bcc Finish

			inc Out

		Finish:

			rts
		}

		MainUp: {

			lda SpriteY, x
			sec
			sbc Pixels
			sta SpriteY, x
			bcs Finish

			lda #0
			sta SpriteY, x

		Finish:

			rts
		}

		OtherRight: {

			lda SpriteX_LSB, x
			clc
			adc OtherLo
			sta SpriteX_LSB, x
			lda SpriteX, x
			adc OtherHi
			sta SpriteX, x
			bcc Finish

			inc Out

		Finish:

			rts
		}

		OtherLeft: {

			lda SpriteX_LSB, x
			sec
			sbc OtherLo
			sta SpriteX_LSB, x
			lda SpriteX, x
			sbc OtherHi
			sta SpriteX, x
			bcs Finish

			inc Out

		Finish:

			rts
		}

		OtherDown: {

			lda SpriteY_LSB, x
			clc
			adc OtherLo
			sta SpriteY_LSB, x
			lda SpriteY, x
			adc OtherHi
			sta SpriteY, x
			bcc Finish

			inc Out

		Finish:

			rts
		}

		OtherUp: {

			lda SpriteY_LSB, x
			sec
			sbc OtherLo
			sta SpriteY_LSB, x
			lda SpriteY, x
			sbc OtherHi
			sta SpriteY, x
			bcs Finish

			lda #0
			sta SpriteY, x

		Finish:

			rts
		}
	}

	.errorif * > $6000, "the arcade dives run into the SID"

	* = dives_pc
}
