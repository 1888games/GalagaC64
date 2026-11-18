FORMATION: {

	


	.label SR = 50
	.label SC = 20

	.label TransformStages = 5
	.label TransformTime = 20


	SpriteRow:	.fill 4, SR
				.fill 8, SR + (2 * 8)
				.fill 8, SR + (4 * 8)
				.fill 10, SR + (6 * 8)
				.fill 10, SR + (6*8)


	SpriteColumn:

				.fill 4, SC + (9 * 8) + (i*16)
				.fill 8, SC + (5 * 8) + (i*16)
				.fill 8, SC + (5 * 8) + (i*16)
				.fill 10, SC + (3 * 8) + (i*16)
				.fill 10, SC + (3 * 8) + (i*16)

	.label ExplosionChar = 63
	.label EXPLOSION_TIME = 3
	.label UpdatesPerFrame = 8
	.label MAX_EXPLOSIONS= 3

	Hits:		.fill 4, 1
				.fill 36, 0
				.fill 3, 0


	Column:		.fill 43, 0
	PreviousColumn:	.fill 40, 0
	PreviousRow:	.fill 40, 0
	HitsLeft:	.fill 40, 1
				.fill 3, 0
	Switching:	.byte 0

	Plan:		.fill 43, 0
	NextPlan:	.fill 43, 0

	TypeToScore:		.byte 4, 4, 2, 0, 3, 7
	ChallengeToScore: 	.byte 5, 5, 1, 1, 1, 1
	Alive:			.byte 0


	* = * "Enemies Left"
	EnemiesLeftInStage:	.byte 0



	Home_Column:
				.byte 9, 11, 13, 15
				.byte 5, 7, 9, 11, 13, 15, 17, 19
				.byte 5, 7, 9, 11, 13, 15, 17, 19
				.byte 3, 5, 7, 9, 11, 13, 15, 17, 19, 21
				.byte 3, 5, 7, 9, 11, 13, 15, 17, 19, 21


	Spread_1:	.byte 9, 11, 13, 15
				.byte 5, 7, 9, 11, 13, 15, 17, 19
				.byte 5, 7, 9, 11, 13, 15, 17, 19
				.byte 2, 5, 7, 9, 11, 13, 15, 17, 19, 22
				.byte 2, 5, 7, 9, 11, 13, 15, 17, 19, 22

	Spread_2:	.byte 9, 11, 13, 15
				.byte 4, 7, 9, 11, 13, 15, 17, 20
				.byte 4, 7, 9, 11, 13, 15, 17, 20
				.byte 2, 5, 7, 9, 11, 13, 15, 17,20, 22
				.byte 2, 5, 7, 9, 11, 13, 15, 17, 20, 22

	Spread_3:	.byte 9, 11, 13, 15
				.byte 3, 6, 9, 11, 13, 15, 18, 20
				.byte 3, 6, 9, 11, 13, 15, 18, 20
				.byte 2, 4, 7, 9, 11, 13, 15, 17, 20, 22
				.byte 2, 4, 7, 9, 11, 13, 15, 17, 20, 22


	Spread_4:	.byte 9, 11, 13, 15
				.byte 2, 6, 9, 11, 13, 15, 18, 21
				.byte 2, 6, 9, 11, 13, 15, 18, 21
				.byte 1, 4, 7, 9, 11, 13, 15, 17, 20, 23
				.byte 1, 4, 7, 9, 11, 13, 15, 17, 20, 23

	Spread_5:	.byte 9, 11, 13, 15
				.byte 2, 6, 8, 11, 13, 17, 18, 21
				.byte 2, 6, 8, 11, 13, 17, 18, 21
				.byte 1, 3, 7, 9, 11, 13, 15, 17, 21, 23
				.byte 1, 3, 7, 9, 11, 13, 15, 17, 21, 23



	Row:		.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 4, 4, 4, 4, 4, 4, 4, 4
				.byte 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
				.byte 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
				.byte 0, 0, 0


	Home_Row:	
				.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 4, 4, 4, 4, 4, 4, 4, 4
				.byte 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
				.byte 8, 8, 8, 8, 8, 8, 8, 8, 8, 8

	Spread_R1:	
				.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 4, 4, 4, 4, 4, 4, 4, 4
				.byte 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
				.byte 9, 9, 9, 9, 9, 9, 9, 9, 9, 9

	Spread_R2:	.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 4, 4, 4, 4, 4, 4, 4, 4
				.byte 6, 6, 6, 6, 6, 6, 6, 6, 6, 6
				.byte 9, 9, 9, 9, 9, 9, 9, 9, 9, 9

	Spread_R3:	.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 4, 4, 4, 4, 4, 4, 4, 4
				.byte 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
				.byte 9, 9, 9, 9, 9, 9, 9, 9, 9, 9

	Spread_R4:	.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 5, 5, 5, 5, 5, 5, 5, 5
				.byte 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
				.byte 10, 10, 10, 10, 10, 10, 10, 10, 10, 10


	Spread_R5:	.byte 0, 0, 0, 0
				.byte 2, 2, 2, 2, 2, 2, 2, 2
				.byte 5, 5, 5, 5, 5, 5, 5, 5
				.byte 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
				.byte 10, 10, 10, 10, 10, 10, 10, 10, 10, 10




	SpreadLookupR:	.word Home_Row, Spread_R1, Spread_R2, Spread_R3, Spread_R4, Spread_R5

	SpreadLookup:	.word Home_Column, Spread_1, Spread_2, Spread_3, Spread_4, Spread_5

	//Spread_Order:	.byte 0, 3, 4, 11, 12, 19, 20, 29, 30, 39


		Type:	.byte 1, 1, 1, 1	// 0-3
				.byte 2, 2, 2, 2, 2, 2, 2, 2 // 4-11
				.byte 2, 2, 2, 2, 2, 2, 2, 2 // 12-19
				.byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 // 20-29
				.byte 3, 3, 3, 3, 3, 3, 3, 3, 3, 3 // 30-39
				.byte 4, 4, 4 // 40-42



	Occupied:	.fill 43, 0


	ExplosionTimer: .fill MAX_EXPLOSIONS, 0
	ExplosionList:	.fill MAX_EXPLOSIONS, 255
	ExplosionProgress:	.fill MAX_EXPLOSIONS, 0
	ExplosionX:		.fill MAX_EXPLOSIONS, 0
	ExplosionY:		.fill MAX_EXPLOSIONS, 0

	ExplosionColour:	.byte WHITE + 8, YELLOW + 8, YELLOW + 8, YELLOW + 8


	Mode:		.byte FORMATION_UNISON

	Position:	.byte 0
	PreviousPosition: .byte 0
	Direction:	.byte 1
	Speeds:		.byte 6, 18			// unison: a 2 pixel step every 6 frames
	SpreadPosition:	.byte 0

	// - Smooth sway: in unison the formation moves 2 pixels at a time (FinePosition: Position * 4
	// - + SubPos, -8 to 8). On a whole char the enemies are the plain 2x2 chars (static). In
	// - between they're 3 cells wide in the bank's chars, chars 86 - 121, redefined for each step
	// - (DefineBank) from SMOOTH_CHARS (data/assets.asm), with the cell two neighbours share as
	// - their pair. On a whole char the two layouts look the same, so a pass changes one into
	// - the other a few slots a frame without it showing.

	// - On a whole char: the step redefines the bank, a pass makes the slots static, the bank is
	// - redefined for the next window, and a second pass makes them 3 wide again. FrameUpdate
	// - only says when a step is due: the steps and passes are done by SpareTime at the end of
	// - the frame, in whatever time is left, so a busy frame holds the formation a frame instead
	// - of slowing the whole game.

	.label SMOOTH_STATIC = 0
	.label SMOOTH_DYNAMIC = 1
	.label SMOOTH_TO_STATIC = 2
	.label SMOOTH_TO_DYNAMIC = 3
	.label SMOOTH_BEGIN_DYNAMIC = 4		// all static: redefine the bank next frame, then pass

	.label BANK_FIRST_CHAR = 86			// the title logo's chars, put back by RestoreLogoChars
	.label BANK_CHARS = 36				// boss, butterfly, bee: (left, middle, right) x 2 rows, their
	.label BANK_CORE_CHARS = 24			// pairs x 2, then the hit boss's 6 and its 3 pairs with the boss
	.label BANK_HIT_CHAR = BANK_FIRST_CHAR + BANK_CORE_CHARS
	.label BANK_RUN = 24				// DefineBank copies 8 runs of 24 bytes, the hit boss's 4
	.label FINE_LIMIT = 8				// Position -2 to 2
	.label FORMATION_BOTTOM_LINE = 136	// the raster line below unison's rows (0 - 9)
	.label STEP_DEADLINE = 198			// SpareTime starts a step (a bank copy, ~2500 cycles) before
	.label STEP_DEADLINE_HIT = 182		// this, or this with the hit boss's chars too (~3600)
	.label PASS_DEADLINE = 232			// and a ContinuePass call before this (the IRQ is at 255)
	.label LOGO_BACKUP = $a600			// (free: after the zero page backups)

	Frame:			.byte 0
	CurrentSlot:	.byte 255
	FrameCounter:	.byte 0

	ColumnSpriteX:	.fill 40, 24 + (i * 8)
	RowSpriteY:		.fill 25, 50 + (i * 8)
	

	TypeCharStart:		.byte 169, 161, 181, 189, 246, 232 
	Colours:			.byte GREEN + 8, WHITE + 8, WHITE + 8, YELLOW + 8, YELLOW + 8, GREEN + 8
	TransformColours:	.byte GREEN + 8, YELLOW + 8, GREEN + 8, CYAN + 8, YELLOW + 8, GREEN + 8

	TransformProgress:	.byte 0
	TransformTimer:		.byte 0
	TransformID:		.byte 255


	Initialise: {

		ldx #0

		Loop:

			lda Home_Column, x
			sta Column, x
			sta PreviousColumn, x
			lda Home_Row, x
			sta Row, x
			sta PreviousRow, x

			lda Hits, x
			sta HitsLeft, x

			//jsr RANDOM.Get
			//and #%00000001

			lda #0
			sta Occupied, x

			lda #1
			sta SlotDynamic, x

			inx
			cpx #40
			bcc Loop


		lda #0
		sta Position
		sta PreviousPosition
		sta CurrentSlot
		sta FrameCounter
		sta SpreadPosition
		sta Switching
		sta FinePosition
		sta SubPos
		sta SubPixels
		sta HitPosition
		sta WindowPos
		sta PassSlot
		sta StepDue

		// the formation starts empty, so every slot can start in the 3 cell layout
		lda #SMOOTH_DYNAMIC
		sta SmoothState

		lda #3
		sta WindowOffset


		lda #1
		sta Direction
		sta Frame
		sta Type
		sta Type + 1
		sta Type + 2
		sta Type + 3

		lda #STAGE.NumberOfWaves * 8
		sta Alive

		lda #FORMATION_UNISON
		sta Mode

		lda #255
		sta TransformID

		// no static redraw pending (unison moves through the bank now, not CheckDraw)
		sta CurrentSlot

		lda #0
		jsr DefineBank

		rts
	}


	


	StartTransform: {

		sty TransformID

		lda #0
		sta TransformProgress

		lda #TransformTime
		sta TransformTimer

		rts
	}

	SpreadFormation: {

		FrameChange:

			ldx Mode
			lda Speeds, x
			sta FrameCounter

			lda Frame
			beq MakeOne	

			MakeZero:

				dec Frame
				lda SpreadPosition
				clc
				adc Direction
				sta SpreadPosition

				jmp CheckTurnAround

			MakeOne:

				inc Frame


		CheckTurnAround:

			lda SpreadPosition
			cmp #255
			beq TurnAroundLeft

			cmp #6
			beq TurnAroundRight

			jmp NowDraw

		TurnAroundRight:

			lda #255
			sta Direction

			lda #4
			sta SpreadPosition

			jmp NowDraw

		TurnAroundLeft:

			lda #1
			sta Direction

			lda #1
			sta SpreadPosition

		NowDraw:

		lda SpreadPosition
		asl	
		tax

		ldy #0

		lda SpreadLookup, x
		sta ZP.TextAddress

		lda SpreadLookup + 1, x
		sta ZP.TextAddress + 1

		lda SpreadLookupR, x
		sta ZP.ColourAddress

		lda SpreadLookupR + 1, x
		sta ZP.ColourAddress + 1

		Loop:

			lda (ZP.TextAddress), y
			sta Column, y

			lda (ZP.ColourAddress), y
			sta Row, y

			iny
			cpy #40
			bcc Loop


			lda Direction
			bmi StartFrom0

			lda #39
			sta CurrentSlot
			jmp Finish

		StartFrom0:

			lda #0
			sta CurrentSlot
			

		Finish:	




		rts
	}	



	EnemyKilled: {

		dec Alive

		lda Alive
		bmi Error
		// clc
	 // 	adc #48
		// sta SCREEN_RAM + 438

		// lda #1
		// sta VIC.COLOR_RAM + 438

		rts

		Error:

			//.break
			nop


		rts
	}

	// x = slot: take it off the screen, in whichever layout it was drawn
	Delete: {

		lda SlotDynamic, x
		beq Static

		jmp DeleteSmooth

		Static:

		jsr DeleteStatic

		// mid pass, a neighbour still 3 cells wide shares a cell with it
		lda SmoothState
		beq Finish

		jmp RedrawNeighbours

		Finish:

		rts
	}

	DeleteStatic: {

		stx ZP.FormationID

		cpx #40
		bcc NoError

		.break
		clc

	NoError:

		lda PreviousColumn, x
		sta ZP.Column

	TopLeft:

		lda PreviousRow, x
		tay
		ldx ZP.Column

		jsr PLOT.GetCharacter

		jmp Okay

		ldx STAGE.CurrentWave
		beq Okay

		cmp #161
		bcc NotEnemy

		cmp #197
		bcs NotEnemy

		jmp Okay

	NotEnemy:

		.break
		nop

		ldx ZP.FormationID
		lda PreviousColumn, x
		tay

		lda Column, x
		clc
		adc Position



	Okay:

		ldy #0
		lda #0
		sta (ZP.ScreenAddress), y
		
	TopRight:

		iny
		sta (ZP.ScreenAddress), y

	BottomRight:

		ldy #41
		sta (ZP.ScreenAddress), y

	BottomLeft:

		dey
		sta (ZP.ScreenAddress), y

		ldx ZP.FormationID

		rts

	}

	DeleteAll: {

		ldx #0

		Loop:

			stx ZP.StoredXReg

			lda #0
			sta Occupied, x

			jsr Delete

			EndLoop:

				ldx ZP.StoredXReg
				inx
				cpx #40
				bcc Loop


		rts
	}

	// x = slot: draw it in its slot's current layout. On the way to static it goes static
	// straight away (the bank's on step 0 or 4, so it looks the same), so no bank char lands
	// next to a slot the pass has made static already
	DrawOne: {

		lda SmoothState
		cmp #SMOOTH_TO_STATIC
		bne ByLayout

		lda #0
		sta SlotDynamic, x
		jmp DrawStatic

		ByLayout:

		lda SlotDynamic, x
		beq Static

		jmp DrawSmooth

		Static:

		jmp DrawStatic
	}

	DrawStatic: {

		stx ZP.FormationID

		lda Column, x
		clc
		adc Position
		sta ZP.Column
		sta PreviousColumn, x

		lda Type, x
		sec
		sbc HitsLeft, x

		tay
		lda TypeCharStart, y
		sta ZP.CharID

		lda Frame
		asl
		asl
		clc
		adc ZP.CharID
		sta ZP.CharID

		lda Colours, y
		sta ZP.Colour

		lda Row, x
		sta PreviousRow, x
		tay
		ldx ZP.Column

		jsr DrawFourCorners

		ldx ZP.FormationID

		rts



	}

	


		

	DrawFourCorners: {

		TopLeft:

			lda ZP.CharID

			jsr PLOT.PlotCharacter
			lda ZP.Colour
			jsr PLOT.ColorCharacter

			inc ZP.CharID

		TopRight:

			iny
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			inc ZP.CharID

		BottomRight:

			ldy #41
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			inc ZP.CharID

		BottomLeft:

			dey
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y


		rts
	}

	// the main code block is full up to the demo map, so the smooth formation's routines
	// go in the free space after the logo
	.var mainBlockPC = *
	* = $7948 "Smooth Formation"

	FinePosition:	.byte 0
	SubPos:			.byte 0
	SubPixels:		.byte 0			// SubPos * 2: added to sprite X targets
	HitPosition:	.byte 0			// Position rounded to the nearest char: bullets, explosions
	SmoothState:	.byte SMOOTH_STATIC
	WindowPos:		.byte 0			// where the 3 cell layout starts: Position, or one less
	WindowOffset:	.byte 3			// WindowPos + 3, for SlotWindowAddress
	BankStep:		.byte 0			// the step the bank holds (0 - 4)
	MovedDirection:	.byte 0
	StepDue:		.byte 0			// FrameUpdate's: SpareTime does the step
	HitBank:		.byte 0			// the bank has the hit boss's chars for BankStep
	HitSaveX:		.byte 0
	BankDeadline:	.byte 0
	PassSlot:		.byte 0
	SlotDynamic:	.fill 40, 0

	// the lookup tables go in the free space after the main code ($6f05 - $73ff)
	.var smoothCodePC = *
	* = $7200 "Smooth Formation Tables"

	// each slot's home cell (unison doesn't change Column or Row), 3 to the left so that
	// SlotWindowAddress can add WindowPos + 3
	SlotScreenLo:	.fill 40, <(SCREEN_RAM - 3 + (i < 4 ? 0 : i < 12 ? 2 : i < 20 ? 4 : i < 30 ? 6 : 8) * 40 + (i < 4 ? 9 + i * 2 : i < 12 ? 5 + (i - 4) * 2 : i < 20 ? 5 + (i - 12) * 2 : i < 30 ? 3 + (i - 20) * 2 : 3 + (i - 30) * 2))
	SlotScreenHi:	.fill 40, >(SCREEN_RAM - 3 + (i < 4 ? 0 : i < 12 ? 2 : i < 20 ? 4 : i < 30 ? 6 : 8) * 40 + (i < 4 ? 9 + i * 2 : i < 12 ? 5 + (i - 4) * 2 : i < 20 ? 5 + (i - 12) * 2 : i < 30 ? 3 + (i - 20) * 2 : 3 + (i - 30) * 2))

	// slots side by side in a row (unison: always 2 columns apart)
	LeftSlot:		.fill 40, (i == 0 || i == 4 || i == 12 || i == 20 || i == 30) ? 255 : i - 1
	RightSlot:		.fill 40, (i == 3 || i == 11 || i == 19 || i == 29 || i == 39) ? 255 : i + 1

	// a type's first bank char: left, middle, right top, then left, middle, right bottom
	// (types: boss, hit boss, butterfly, bee)
	TypeBankChar:	.byte BANK_FIRST_CHAR, BANK_HIT_CHAR, BANK_FIRST_CHAR + 6, BANK_FIRST_CHAR + 12

	// the shared cell's top char for left type * 4 + right type (+1 the bottom): the pairs
	// SMOOTH_CHARS has (boss and hit boss either way round, butterflies, bees), else the
	// right one's left part
	PairChars:		.byte BANK_FIRST_CHAR + 18, BANK_HIT_CHAR + 6, BANK_FIRST_CHAR + 6, BANK_FIRST_CHAR + 12
					.byte BANK_HIT_CHAR + 8, BANK_HIT_CHAR + 10, BANK_FIRST_CHAR + 6, BANK_FIRST_CHAR + 12
					.byte BANK_FIRST_CHAR, BANK_HIT_CHAR, BANK_FIRST_CHAR + 20, BANK_FIRST_CHAR + 12
					.byte BANK_FIRST_CHAR, BANK_HIT_CHAR, BANK_FIRST_CHAR + 6, BANK_FIRST_CHAR + 22

	// each step and frame's 288 bytes, (step * 2 + frame): 8 runs of 24 then the hit boss's 4
	CoreSourceLo:	.fill 10 * 8, <(SMOOTH_CHARS + floor(i / 8) * BANK_CHARS * 8 + mod(i, 8) * BANK_RUN)
	CoreSourceHi:	.fill 10 * 8, >(SMOOTH_CHARS + floor(i / 8) * BANK_CHARS * 8 + mod(i, 8) * BANK_RUN)
	HitSourceLo:	.fill 10 * 4, <(SMOOTH_CHARS + floor(i / 4) * BANK_CHARS * 8 + BANK_CORE_CHARS * 8 + mod(i, 4) * BANK_RUN)
	HitSourceHi:	.fill 10 * 4, >(SMOOTH_CHARS + floor(i / 4) * BANK_CHARS * 8 + BANK_CORE_CHARS * 8 + mod(i, 4) * BANK_RUN)

	.errorif * > $7400, "the smooth formation tables run into the game map"
	* = smoothCodePC

	// DrawSmooth's working values
	SmoothType:			.byte 0
	SmoothColour:		.byte 0
	SmoothRightColour:	.byte 0
	SmoothPairIndex:	.byte 0
	SmoothChar:			.byte 0
	SmoothSlot:			.byte 0
	ColourSaveX:		.byte 0
	DeletingSlot:		.byte 0


	// x = slot (keeps x). Clears its 3 x 2 cells, then puts back the neighbours' parts of
	// the two cells it shared with them
	DeleteSmooth: {

		stx DeletingSlot

		lda PreviousRow, x
		tay
		lda PreviousColumn, x
		tax

		jsr PLOT.GetCharacter

		lda #0
		ldy #0
		sta (ZP.ScreenAddress), y
		iny
		sta (ZP.ScreenAddress), y
		iny
		sta (ZP.ScreenAddress), y

		ldy #40
		sta (ZP.ScreenAddress), y
		iny
		sta (ZP.ScreenAddress), y
		iny
		sta (ZP.ScreenAddress), y

		ldx DeletingSlot
		jmp RedrawNeighbours
	}

	// x = slot (keeps x): redraw the neighbours in the formation as if this slot was empty,
	// so the cells they shared with it hold only their own parts
	RedrawNeighbours: {

		stx DeletingSlot

		lda Occupied, x
		pha

		lda #0
		sta Occupied, x

		Left:

			ldy LeftSlot, x
			bmi Right

			tya
			tax
			jsr RedrawSlot

		Right:

			ldx DeletingSlot
			ldy RightSlot, x
			bmi Finish

			tya
			tax
			jsr RedrawSlot

		Finish:

			ldx DeletingSlot
			pla
			sta Occupied, x

		rts
	}

	// x = slot, on screen: draw it again. On the way to static, one still 3 wide is
	// converted, which also empties its third cell (DrawOne's static draw would leave it,
	// and the bank's next window would show what's in it)
	RedrawSlot: {

		lda Occupied, x
		beq Finish

		lda SmoothState
		cmp #SMOOTH_TO_STATIC
		bne Normal

		lda SlotDynamic, x
		beq Normal

		lda #0
		sta SlotDynamic, x
		jmp PassToStatic

		Normal:

		jmp DrawOne

		Finish:

		rts
	}

	// x = slot: draw it if it's in the formation
	DrawSlot: {

		lda Occupied, x
		beq Finish

		jmp DrawOne

		Finish:

		rts
	}

	// a = column, y = row: that cell's addresses in ZP.ScreenAddress and ZP.ColourAddress
	// (PLOT.CalculateAddresses without the zero page round trip; the passes call it a lot)
	CellAddress: {

		clc
		adc VIC.ScreenRowLSB, y
		sta ZP.ScreenAddress
		sta ZP.ColourAddress

		lda VIC.ScreenRowMSB, y
		adc #0
		tay

		clc
		adc #>SCREEN_RAM
		sta ZP.ScreenAddress + 1

		tya
		clc
		adc #>VIC.COLOR_RAM
		sta ZP.ColourAddress + 1

		rts
	}


	// y = slot: a = its colour (keeps x and y). The bank only has the four types, so the one
	// about to transform flashes its colour instead of its shape
	SlotColour: {

		stx ColourSaveX

		lda Type, y
		sec
		sbc HitsLeft, y
		tax

		cpy TransformID
		bne Plain

		lda Frame
		beq Plain

		inx
		inx

		Plain:

		lda Colours, x
		ldx ColourSaveX

		rts
	}


	// x = slot (keeps x): draw it 3 cells wide from the bank at Column + WindowPos. A cell it
	// shares with a neighbour in the formation gets their pair char, coloured as the right one
	DrawSmooth: {

		cpx #4
		bcs NotBoss

		jsr EnsureHitBank

		NotBoss:

		stx SmoothSlot

		lda Type, x
		sec
		sbc HitsLeft, x
		sta SmoothType
		tay

		// SlotColour, inline
		cpx TransformID
		bne OwnColour

		lda Frame
		beq OwnColour

		iny
		iny

		OwnColour:

		lda Colours, y
		sta SmoothColour

		lda Row, x
		sta PreviousRow, x
		tay

		lda Column, x
		clc
		adc WindowPos
		sta PreviousColumn, x

		jsr CellAddress

		ldx SmoothSlot

		LeftCell:

			ldy LeftSlot, x
			bmi OwnLeft

			lda Occupied, y
			beq OwnLeft

			lda Type, y
			sec
			sbc HitsLeft, y
			asl
			asl
			adc SmoothType
			tay

			lda PairChars, y
			ldy #0
			sta (ZP.ScreenAddress), y
			clc
			adc #1
			ldy #40
			sta (ZP.ScreenAddress), y
			jmp MiddleCell

			OwnLeft:

			ldy SmoothType
			lda TypeBankChar, y
			ldy #0
			sta (ZP.ScreenAddress), y
			clc
			adc #3
			ldy #40
			sta (ZP.ScreenAddress), y

		MiddleCell:

			ldy SmoothType
			lda TypeBankChar, y
			clc
			adc #1
			ldy #1
			sta (ZP.ScreenAddress), y
			adc #3
			ldy #41
			sta (ZP.ScreenAddress), y

			lda SmoothColour
			ldy #0
			sta (ZP.ColourAddress), y
			iny
			sta (ZP.ColourAddress), y
			ldy #40
			sta (ZP.ColourAddress), y
			iny
			sta (ZP.ColourAddress), y

		RightCell:

			ldy RightSlot, x
			bmi OwnRight

			lda Occupied, y
			beq OwnRight

			jsr SlotColour
			sta SmoothRightColour

			lda SmoothType
			asl
			asl
			sta SmoothPairIndex

			lda Type, y
			sec
			sbc HitsLeft, y
			clc
			adc SmoothPairIndex
			tay

			lda PairChars, y
			ldy #2
			sta (ZP.ScreenAddress), y
			clc
			adc #1
			ldy #42
			sta (ZP.ScreenAddress), y

			lda SmoothRightColour
			jmp RightColour

			OwnRight:

			ldy SmoothType
			lda TypeBankChar, y
			clc
			adc #2
			ldy #2
			sta (ZP.ScreenAddress), y
			adc #3
			ldy #42
			sta (ZP.ScreenAddress), y

			lda SmoothColour

		RightColour:

			ldy #2
			sta (ZP.ColourAddress), y
			ldy #42
			sta (ZP.ColourAddress), y

		rts
	}


	// x = slot: the addresses of its window's first cell (Column + WindowPos) in
	// ZP.ScreenAddress and ZP.ColourAddress. Keeps x and leaves carry clear
	SlotWindowAddress: {

		lda SlotScreenLo, x
		clc
		adc WindowOffset
		sta ZP.ScreenAddress
		sta ZP.ColourAddress

		lda SlotScreenHi, x
		adc #0
		sta ZP.ScreenAddress + 1
		adc #>(VIC.COLOR_RAM - SCREEN_RAM)
		sta ZP.ColourAddress + 1

		rts
	}


	// x = slot (keeps x), drawn 3 wide with the bank on step 0 or 4, so it looks static
	// already: the plain 2x2 chars and colour at Position in place of the bank's, and its
	// spare cell emptied unless a neighbour's part is in it. Nothing is drawn 3 wide during
	// this pass (see DrawOne), so a shared cell next to a slot made static already holds
	// its static char
	PassToStatic: {

		lda Type, x
		sec
		sbc HitsLeft, x
		tay

		lda Colours, y
		sta SmoothColour

		lda Frame
		asl
		asl
		adc TypeCharStart, y
		sta SmoothChar

		lda Column, x
		clc
		adc Position
		sta PreviousColumn, x

		jsr SlotWindowAddress

		lda BankStep
		bne CameFromLeft

		// step 0: in the window's first two cells, the third spare
		CameFromRight:

			lda SmoothChar
			ldy #0
			sta (ZP.ScreenAddress), y
			adc #1
			iny
			sta (ZP.ScreenAddress), y
			adc #1
			ldy #41
			sta (ZP.ScreenAddress), y
			adc #1
			dey
			sta (ZP.ScreenAddress), y

			lda SmoothColour
			sta (ZP.ColourAddress), y
			iny
			sta (ZP.ColourAddress), y
			ldy #0
			sta (ZP.ColourAddress), y
			iny
			sta (ZP.ColourAddress), y

			ldy RightSlot, x
			bmi EmptyRight

			lda Occupied, y
			bne Finish

			EmptyRight:

			lda #0
			ldy #2
			sta (ZP.ScreenAddress), y
			ldy #42
			sta (ZP.ScreenAddress), y
			rts

		// step 4: in the last two cells, the first spare
		CameFromLeft:

			lda SmoothChar
			ldy #1
			sta (ZP.ScreenAddress), y
			adc #1
			iny
			sta (ZP.ScreenAddress), y
			adc #1
			ldy #42
			sta (ZP.ScreenAddress), y
			adc #1
			dey
			sta (ZP.ScreenAddress), y

			lda SmoothColour
			sta (ZP.ColourAddress), y
			iny
			sta (ZP.ColourAddress), y
			ldy #1
			sta (ZP.ColourAddress), y
			iny
			sta (ZP.ColourAddress), y

			ldy LeftSlot, x
			bmi EmptyLeft

			lda Occupied, y
			bne Finish

			EmptyLeft:

			lda #0
			tay
			sta (ZP.ScreenAddress), y
			ldy #40
			sta (ZP.ScreenAddress), y

		Finish:

		rts
	}


	// x = slot (keeps x), static at Position, the bank on the new window's step 0 or 4:
	// draw it 3 wide as DrawSmooth does, but quicker. Its static cells keep their colours;
	// only the cell it takes on gets one, and a shared cell that changes hands gets the
	// right one's (as DrawSmooth)
	PassToDynamic: {

		cpx TransformID
		bne Quick

		jmp DrawSmooth

		Quick:

		cpx #4
		bcs NotBoss

		jsr EnsureHitBank

		NotBoss:

		lda Type, x
		sec
		sbc HitsLeft, x
		sta SmoothType
		tay

		lda TypeBankChar, y
		sta SmoothChar

		lda Column, x
		clc
		adc WindowPos
		sta PreviousColumn, x

		jsr SlotWindowAddress

		LeftCell:

			ldy LeftSlot, x
			bmi OwnLeft

			lda Occupied, y
			beq OwnLeft

			lda Type, y
			sec
			sbc HitsLeft, y
			asl
			asl
			adc SmoothType
			tay

			lda PairChars, y
			ldy #0
			sta (ZP.ScreenAddress), y
			adc #1
			ldy #40
			sta (ZP.ScreenAddress), y
			jmp MiddleCell

			OwnLeft:

			lda SmoothChar
			ldy #0
			sta (ZP.ScreenAddress), y
			adc #3
			ldy #40
			sta (ZP.ScreenAddress), y

		MiddleCell:

			lda SmoothChar
			adc #1
			ldy #1
			sta (ZP.ScreenAddress), y
			adc #3
			ldy #41
			sta (ZP.ScreenAddress), y

		RightCell:

			ldy RightSlot, x
			bmi OwnRight

			lda Occupied, y
			beq OwnRight

			lda Type, y
			sec
			sbc HitsLeft, y
			sta SmoothPairIndex

			lda SmoothType
			asl
			asl
			adc SmoothPairIndex
			tay

			lda PairChars, y
			ldy #2
			sta (ZP.ScreenAddress), y
			adc #1
			ldy #42
			sta (ZP.ScreenAddress), y

			// going left, this cell was its static right half: the right one's colour now
			lda BankStep
			beq LeftColour

			ldy RightSlot, x
			jsr SlotColour
			jmp RightColour

			OwnRight:

			lda SmoothChar
			adc #2
			ldy #2
			sta (ZP.ScreenAddress), y
			adc #3
			ldy #42
			sta (ZP.ScreenAddress), y

			// going right, this cell is new to it
			lda BankStep
			bne LeftColour

			txa
			tay
			jsr SlotColour

			RightColour:

			ldy #2
			sta (ZP.ColourAddress), y
			ldy #42
			sta (ZP.ColourAddress), y

		// going left, the first cell is new to it (shared or not, it's in its colour)
		LeftColour:

			lda BankStep
			beq Finish

			txa
			tay
			jsr SlotColour

			ldy #0
			sta (ZP.ColourAddress), y
			ldy #40
			sta (ZP.ColourAddress), y

		Finish:

		rts
	}


	// SpareTime's: change slots into the layout SmoothState is heading for, until the pass is
	// done (carry clear) or the next frame's near (carry set)
	ContinuePass: {

		ldx PassSlot
		cpx #40
		bcs Done

		lda SmoothState
		cmp #SMOOTH_TO_STATIC
		bne ToDynamic

		ToStatic:

			lda MAIN.PerformFrameCodeFlag
			bne Pause

			bit VIC.SCREEN_CONTROL
			bmi Convert

			lda VIC.RASTER_Y
			cmp #PASS_DEADLINE
			bcs Pause

			Convert:

			// (drawn static already since the pass began: see DrawOne)
			lda SlotDynamic, x
			beq NextStatic

			lda #0
			sta SlotDynamic, x

			lda Occupied, x
			beq NextStatic

			jsr PassToStatic

			NextStatic:

			inx
			cpx #40
			bcc ToStatic

			bcs Done

		ToDynamic:

			lda MAIN.PerformFrameCodeFlag
			bne Pause

			bit VIC.SCREEN_CONTROL
			bmi Draw

			lda VIC.RASTER_Y
			cmp #PASS_DEADLINE
			bcs Pause

			Draw:

			lda #1
			sta SlotDynamic, x

			lda Occupied, x
			beq NextDynamic

			jsr PassToDynamic

			NextDynamic:

			inx
			cpx #40
			bcc ToDynamic

		Done:

			stx PassSlot

			lda SmoothState
			cmp #SMOOTH_TO_STATIC
			beq StaticDone

			lda #SMOOTH_DYNAMIC
			sta SmoothState
			clc
			rts

		StaticDone:

			lda #SMOOTH_STATIC
			sta SmoothState

			// stopping in the middle to spread out, so stay static
			lda Mode
			bne Stay

			lda Switching
			beq Begin

			lda FinePosition
			beq Stay

			Begin:

			// the bank for the next window
			lda #SMOOTH_BEGIN_DYNAMIC
			sta SmoothState

		Stay:

			clc
			rts

		Pause:

			stx PassSlot
			sec
			rts
	}


	// all static at Position: set up the 3 cell layout for the next step, whose window
	// starts on Position going right, or one char left of it going left
	BeginDynamic: {

		lda Position
		ldx Direction
		bmi GoingLeft

		GoingRight:

			sta WindowPos
			lda #0
			jmp Define

		GoingLeft:

			sec
			sbc #1
			sta WindowPos
			lda #4

		Define:

			jsr DefineBank

		lda WindowPos
		clc
		adc #3
		sta WindowOffset

		lda #0
		sta PassSlot

		lda #SMOOTH_TO_DYNAMIC
		sta SmoothState

		rts
	}


	// a = step (0 - 4): copy that step of SMOOTH_CHARS, in the current Frame, over the bank:
	// 8 runs of 24 bytes a loop, their sources patched into the loop's loads. The hit boss's
	// chars only while there's one in the formation (EnsureHitBank catches the next one)
	DefineBank: {

		sta BankStep
		asl
		clc
		adc Frame
		asl
		asl
		asl
		tax

		.for (var lane = 0; lane < 8; lane++) {

			lda CoreSourceLo + lane, x
			sta Copy + lane * 6 + 1
			lda CoreSourceHi + lane, x
			sta Copy + lane * 6 + 2
		}

		ldy #BANK_RUN - 1

		Copy:

		.for (var lane = 0; lane < 8; lane++) {

			lda $ffff, y
			sta CHAR_SET + BANK_FIRST_CHAR * 8 + lane * BANK_RUN, y
		}

			dey
			bpl Copy

		lda #0
		sta HitBank

		jsr HitBossIn
		bcs DefineHitBank

		rts
	}


	// the hit boss's chars and its pairs for BankStep and Frame (keeps x)
	DefineHitBank: {

		stx HitSaveX

		lda BankStep
		asl
		clc
		adc Frame
		asl
		asl
		tax

		.for (var lane = 0; lane < 4; lane++) {

			lda HitSourceLo + lane, x
			sta Copy + lane * 6 + 1
			lda HitSourceHi + lane, x
			sta Copy + lane * 6 + 2
		}

		ldy #BANK_RUN - 1

		Copy:

		.for (var lane = 0; lane < 4; lane++) {

			lda $ffff, y
			sta CHAR_SET + BANK_HIT_CHAR * 8 + lane * BANK_RUN, y
		}

			dey
			bpl Copy

		lda #1
		sta HitBank

		ldx HitSaveX

		rts
	}


	// carry set if a boss in the formation has been hit
	HitBossIn: {

		ldy #3

		Loop:

			lda Occupied, y
			beq Next

			lda HitsLeft, y
			beq Yes

			Next:

			dey
			bpl Loop

		clc
		rts

		Yes:

		sec
		rts
	}


	// x = boss row slot, about to be drawn from the bank (keeps x): the hit boss's chars, if
	// the bank doesn't have them and there's a hit boss
	EnsureHitBank: {

		lda HitBank
		bne Finish

		jsr HitBossIn
		bcc Finish

		jmp DefineHitBank

		Finish:

		rts
	}


	// called at the end of the frame's code (MAIN.FrameCode): the unison step FrameUpdate says
	// is due, and the passes on a whole char, while there's time before the next frame. What
	// doesn't fit waits for the next frame, holding the formation rather than dropping a frame
	// of the whole game
	SpareTime: {

		lda Mode
		bne Finish

		Loop:

			lda SmoothState
			cmp #SMOOTH_TO_STATIC
			bcc Step

			cmp #SMOOTH_BEGIN_DYNAMIC
			beq Begin

			jsr ContinuePass
			bcc Loop

			rts

		Begin:

			jsr BankTime
			bcs Finish

			jsr BeginDynamic
			jmp Loop

		Step:

			lda StepDue
			beq Finish

			jsr BankTime
			bcs Finish

			lda #0
			sta StepDue

			jsr UnisonFormation
			jmp Loop

		Finish:

		rts
	}


	// carry clear if there's time left in this frame for a bank copy, waiting first for the
	// beam to draw the formation (so a frame can't show half of one step and half of the next).
	// A copy with the hit boss's chars takes longer
	BankTime: {

		ldx #STEP_DEADLINE

		jsr HitBossIn
		bcc Wait

		ldx #STEP_DEADLINE_HIT

		Wait:

			lda MAIN.PerformFrameCodeFlag
			bne Late

			// (lines 256 on: the formation's still to be drawn)
			bit VIC.SCREEN_CONTROL
			bmi Wait

			lda VIC.RASTER_Y
			cmp #FORMATION_BOTTOM_LINE
			bcc Wait

			stx BankDeadline
			cmp BankDeadline
			rts

		Late:

			sec
			rts
	}


	// the bank borrows the title logo's chars: keep a copy at start up, put it back for the title
	BackupLogoChars: {

		ldy #0

		First:

			lda CHAR_SET + BANK_FIRST_CHAR * 8, y
			sta LOGO_BACKUP, y
			iny
			bne First

		ldy #BANK_CHARS * 8 - 257

		Rest:

			lda CHAR_SET + BANK_FIRST_CHAR * 8 + 256, y
			sta LOGO_BACKUP + 256, y
			dey
			bpl Rest

		rts
	}

	RestoreLogoChars: {

		ldy #0

		First:

			lda LOGO_BACKUP, y
			sta CHAR_SET + BANK_FIRST_CHAR * 8, y
			iny
			bne First

		ldy #BANK_CHARS * 8 - 257

		Rest:

			lda LOGO_BACKUP + 256, y
			sta CHAR_SET + BANK_FIRST_CHAR * 8 + 256, y
			dey
			bpl Rest

		rts
	}


	// a = char on screen: carry set if an explosion mustn't draw over it or clear it,
	// an enemy (static, or from the bank) or a star
	Solid: {

		cmp #128
		bcs Yes

		cmp #BANK_FIRST_CHAR
		bcc No

		cmp #BANK_FIRST_CHAR + BANK_CHARS
		bcs NotBank

		sec
		rts

		NotBank:

		clc

		No:
		Yes:

		rts
	}

	.var smoothBlockEnd = *
	* = mainBlockPC "Formation Explosions"


	DeleteExplosion: {

		stx ZP.FormationID

		lda ExplosionX, x
		sta ZP.Column
		
	TopLeft:

		lda ExplosionY, x
		tay
		ldx ZP.Column

		lda #0
		jsr PLOT.GetCharacter


		jsr Solid
		bcs TopRight

		ldy #0
		lda #0
		sta (ZP.ScreenAddress), y
		
	TopRight:

		ldy #1
		lda (ZP.ScreenAddress), y
		jsr Solid
		bcs BottomRight

		lda #0
		sta (ZP.ScreenAddress), y

	BottomRight:

		ldy #41
		lda (ZP.ScreenAddress), y
		jsr Solid
		bcs BottomLeft

		lda #0
		sta (ZP.ScreenAddress), y

	BottomLeft:

		ldy #40
		lda (ZP.ScreenAddress), y
		jsr Solid
		bcs Finish

		lda #0
		sta (ZP.ScreenAddress), y

		ldx ZP.FormationID
		
		Finish:

		rts
	}


	DrawExplosion: {

		TopLeft:

			jsr PLOT.GetCharacter

			jsr Solid
			bcs TopRight

			ldy #0
			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y


		TopRight:

			inc ZP.CharID

			// (not iny: skipping a solid top left leaves y = the row, from GetCharacter)
			ldy #1
			lda (ZP.ScreenAddress), y
			jsr Solid
			bcs BottomRight

			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			

		BottomRight:

			inc ZP.CharID

			ldy #41

			lda (ZP.ScreenAddress), y
			jsr Solid
			bcs BottomLeft

			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

		
		BottomLeft:

			inc ZP.CharID

			dey
			lda (ZP.ScreenAddress), y
			jsr Solid
			bcs Finish

			lda ZP.CharID
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

		Finish:

		rts
	}

	ProcessExplosion: {

		lda ExplosionTimer, x
		beq ReadyToDraw

		dec ExplosionTimer, x
		rts

		ReadyToDraw:


		DeleteFirst:


			jsr DeleteExplosion

			ldx ZP.StoredXReg
			lda ExplosionProgress, x
			cmp #4
			bcc NowDraw

			lda #255
			sta ExplosionList, x
			jmp Finish


		NowDraw:

			ldx ZP.StoredXReg

			lda #EXPLOSION_TIME
			sta ExplosionTimer, x

			lda ExplosionProgress, x
			asl
			asl
			clc
			adc #ExplosionChar
			sta ZP.CharID

			lda ExplosionProgress, x
			tay
			lda ExplosionColour, y
			sta ZP.Colour

			ldx ZP.StoredXReg

			lda ExplosionX, x
			sta ZP.Column

			lda ExplosionY, x
			tay

			ldx ZP.Column

			jsr DrawExplosion

			
			ldx ZP.StoredXReg
			inc ExplosionProgress, x
			


		Finish:


		rts
	}

	CheckExplosions: {

		ldx #0

		Loop:

			stx ZP.StoredXReg
			lda ExplosionList, x
			bmi EndLoop	

			sta ZP.CurrentID

			jsr ProcessExplosion

		EndLoop:

			ldx ZP.StoredXReg
			inx
			cpx #MAX_EXPLOSIONS
			bcc Loop


		rts
	}

	AddExplosion: {


		ldy #0

		Loop:

			lda ExplosionList, y
			bmi Found

			iny
			cpy #MAX_EXPLOSIONS
			beq Exit

			jmp Loop

		Exit:

			rts

		Found:

			txa
			sta ExplosionList, y

			lda Column, x
			clc
			adc HitPosition
			sta ExplosionX, y

			lda Row, x
			sta ExplosionY, y

			lda #0
			sta ExplosionTimer, y
			sta ExplosionProgress, y



			rts
	}

	Hit: {

		lda HitsLeft, x
		sta ZP.SoundFX
		beq Destroy

		dec HitsLeft, x

		stx ZP.FormationID

		jsr STATS.Hit

		ldx ZP.FormationID
		
		jsr Delete
		jsr DrawOne
		jmp NoDelete

		Destroy:

			lda #$52

			jsr EnemyKilled

			lda #0
			sta Occupied, x

			stx ZP.FormationID

			jsr ATTACKS.CheckBeamBossHit

			lda #PLAN_INACTIVE
			sta Plan, x
			sta NextPlan, x

			lda Type, x
			tay
			sec
			sbc ZP.SoundFX

			sfxFromA()


			lda TypeToScore, y
			tay

			jsr SCORE.AddScore

			ldx ZP.FormationID

			jsr AddExplosion
			jsr Delete




		NoDelete:

		


		rts
	}

	CheckDraw: {

		lda CurrentSlot
		bmi Finish

		lda Direction
		bmi ZeroTo39

			lda CurrentSlot
			sec
			sbc #UpdatesPerFrame
			sta ZP.EndID

			jmp Loop

		ZeroTo39:

			lda CurrentSlot
			clc
			adc #UpdatesPerFrame
			sta ZP.EndID

		Loop:

			ldx CurrentSlot

			lda Occupied, x
			beq EndLoop

			jsr Delete

			ldx CurrentSlot

			lda Column, x
			clc
			adc Position
			sta PreviousColumn, x
			sta ZP.Column

			lda Type, x
			sec
			sbc HitsLeft, x

			tay

			CheckTransform:

				lda Frame
				beq NotTransform

				cpx TransformID
				bne NotTransform

				iny
				iny

			NotTransform:

				lda TypeCharStart, y
				sta ZP.CharID

				lda Frame
				asl
				asl
				clc
				adc ZP.CharID
				sta ZP.CharID

				lda Colours, y
				sta ZP.Colour

			RowAndColumn:

				lda Row, x
				sta PreviousRow, x
				tay
				ldx ZP.Column

				jsr DrawFourCorners



		EndLoop:

			lda CurrentSlot
			sec
			sbc Direction
			sta CurrentSlot
			cmp ZP.EndID
			beq Finish

			jmp Loop


		Finish:

			cmp #255
			beq AllDone

			cmp #40
			bne NotFinished

		AllDone:

			lda #255
			sta CurrentSlot

			lda Position
			sta PreviousPosition


		NotFinished:


			rts

	}

	CalculateEnemiesLeft: {

		lda #40
		sta EnemiesLeftInStage


		lda STAGE.StageIndex
		cmp #3
		bcc NotChallenging

		ChallengingStage:

		lda Alive
		sta EnemiesLeftInStage
		rts

		NotChallenging:

		lda ATTACKS.Active
		bne Calculate

		//lda #0
		//sta SCREEN_RAM
		//sta SCREEN_RAM + 1
		rts

		Calculate:

		ldx #0
		stx EnemiesLeftInStage

		Loop:

			lda FORMATION.Occupied, x
			beq CheckDive

			inc EnemiesLeftInStage


			CheckDive:

			cpx #MAX_ENEMIES
			bcs EndLoop

			lda ENEMY.Plan, x
			beq EndLoop

			inc EnemiesLeftInStage

			EndLoop:

				inx
				cpx #40
				bcc Loop

		Display:

			//lda #48
			//sta SCREEN_RAM
//
			lda EnemiesLeftInStage

		DisplayLoop:

			sec
			sbc #10
			bmi Done

			//inc SCREEN_RAM

			jmp DisplayLoop

			Done:

			

			

		rts

	}


	CheckTransform: {

		lda TransformID
		bmi Finish


		lda TransformTimer
		beq Ready

		dec TransformTimer
		rts

		Ready:

		lda #TransformTime
		sta TransformTimer

		inc TransformProgress
		lda TransformProgress
		cmp #TransformStages
		bcc Exit

		ldy TransformID
		lda Occupied, y
		bne EnemyStillAlive

		EnemyKilled:

			jsr ATTACKS.CancelTransforms
			jmp Finish

		EnemyStillAlive:

			jsr ATTACKS.StartTransforms

		Finish:

		lda #255
		sta TransformID

		Exit:

		rts
	}

	FrameUpdate: {

		SetDebugBorder(5)

		jsr CalculateEnemiesLeft
		jsr CheckTransform

		CheckWhetherActive:

			lda Mode
			bmi Finish

		Explosions:

			jsr CheckExplosions

		MoveCounter:

			// the layout change on a whole char (SpareTime) has to finish before the
			// formation moves on
			lda SmoothState
			cmp #SMOOTH_TO_STATIC
			bcc NoPass

			lda FrameCounter
			beq PassWait

			dec FrameCounter

			PassWait:

			jmp Finish

			NoPass:

			lda FrameCounter
			beq ReadyToMove

		NotYet:

			dec FrameCounter
			jmp CheckDraw
			rts

		ReadyToMove:

		CheckSwitchToSpread:

			lda Switching
			beq NoSwitch

			// centred, and back in the static layout
			lda FinePosition
			bne NoSwitch

			lda SmoothState
			bne NoSwitch

			lda #FORMATION_SPREAD
			sta Mode

			jsr ATTACKS.AttackReady

			lda #0
			sta Switching

		NoSwitch:

			lda Mode
			cmp #FORMATION_UNISON
			bne NotInUnison

			// SpareTime steps it (UnisonFormation), when there's time
			lda #1
			sta StepDue
			jmp Finish

		NotInUnison:

			inc ENEMY.FormationUpdated
			jmp SpreadFormation

		Finish:



		SetDebugBorder(0)

			rts

	}


	// (after the other smooth formation routines, out of the full main block)
	.var unisonReturnPC = *
	* = smoothBlockEnd "Smooth Formation Step"

	// one 2 pixel step. Between whole chars only the bank changes; arriving on one starts the
	// pass to static (ContinuePass carries on, then sets up the next window)
	UnisonFormation: {

		inc ENEMY.FormationUpdated

		ldx Mode
		lda Speeds, x
		sta FrameCounter

		lda Direction
		sta MovedDirection
		clc
		adc FinePosition
		sta FinePosition

		CheckTurnAround:

			cmp #FINE_LIMIT
			bne CheckLeftEnd

			lda #255
			sta Direction
			jmp Split

			CheckLeftEnd:

			cmp #256 - FINE_LIMIT
			bne Split

			lda #1
			sta Direction

		Split:

			lda FinePosition
			and #%00000011
			sta SubPos
			asl
			sta SubPixels

			lda FinePosition
			cmp #$80
			ror
			cmp #$80
			ror
			sta Position

			ldx SubPos
			cpx #2
			adc #0
			sta HitPosition

			lda SubPos
			beq Arrived

		Between:

			// the animation frame changes every other step, never on a whole char
			and #%00000001
			beq SameFrame

			lda Frame
			eor #%00000001
			sta Frame

			SameFrame:

			lda SubPos
			jsr DefineBank

			// the one about to transform flashes with the frame
			lda SubPos
			and #%00000001
			beq Finish

			ldx TransformID
			bmi Finish

			jsr DrawSlot
			jmp Finish

		Arrived:

			// came from the left: step 4 of the old window. From the right: step 0
			lda MovedDirection
			bmi FromRight

			lda #4
			jmp Define

			FromRight:

			lda #0

			Define:

			jsr DefineBank

			lda #0
			sta PassSlot

			lda #SMOOTH_TO_STATIC
			sta SmoothState

		Finish:


		SetDebugBorder(0)

		rts
	}

	.errorif * > $8000, "the smooth formation routines run into the code at $8000"
	* = unisonReturnPC

}