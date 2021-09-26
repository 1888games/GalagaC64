
*=$02 "Temp vars zero page" virtual


.label PADDING = 4
.label MAX_SPRITES = 20

ZP: {

	Counter:				.byte 0


	Row:					.byte 0
	Column:					.byte 0
	RowOffset:				.byte 0
	CharID:					.byte 0
	StartID:				.byte 0
	Temp1:					.byte 0
	Temp2:					.byte 0
	Temp3:					.byte 0
	Temp4:					.byte 0
	X:						.byte 0
	Colour:					.byte 0
	StoredXReg:				.byte 0
	EndID:					.byte 0
	Amount:					.byte 0
	StoredYReg:				.byte 0
	CurrentID:				.byte 0
	StarEndID:				.byte 0
	EnemyID:				.byte 0
	EnemyType:				.byte 0
	SlotID:					.byte 0
	StageOrderID:			.byte 0
	FormationID:			.byte 0
	KillID:					.byte 0


	ScreenAddress:			.word 0
	ColourAddress:			.word 0
	CharOffset:				.byte 0
	TextAddress:			.word 0

	StageWaveOrderAddress:	.word 0

	* = * "LPAX" virtual
	LeftPathAddressX:		.word 0
	RightPathAddressX:		.word 0
	LeftPathAddressY:		.word 0
	RightPathAddressY:		.word 0
	AttackAddressX:			.word 0
	AttackAddressY:			.word 0
	SoundFX:				.byte 0

	XDiff:					.byte 0
	YDiff:					.byte 0
	XReached:				.byte 0
	YReached:				.byte 0
}


//* = * $21

	* = * "SpriteX" virtual
	SpriteX:
		.fill MAX_SPRITES, 0

//* = * "SpriteY"

	* = * "SpriteY" virtual
	SpriteY:
		.fill MAX_SPRITES, 0
	SpriteColor:
		.fill MAX_SPRITES, 0
	SpritePointer:
		.fill MAX_SPRITES, 0
	SpriteOrder:
		.fill MAX_SPRITES, 0

	SpriteCopyX:
		.fill MAX_SPRITES, 0


	* = * "SpriteCopyY" virtual
	SpriteCopyY:
		.fill MAX_SPRITES, 0

	
	.label IRQ1LINE        = $fc           //This is the place on screen where the sorting
                                //IRQ happens
	.label IRQ2LINE        = $2a           //This is where sprite displaying begins...

	.label MAXSPR          = 18            //Maximum number of sprites

	numsprites: .byte 0                //Number of sprites that the main program wants
                                //to pass to the sprite sorter
	sprupdateflag:	.byte  0           //Main program must write a nonzero value here
                                //when it wants new sprites to be displayed
	sortedsprites: .byte  0        //Number of sorted sprites for the raster
                                //interrupt
	 tempvariable:   .byte 0          //Just a temp variable used by the raster
                                //interrupt
	sprirqcounter:   .byte 0         //Sprite counter used by the interrupt

	sortorder:	.fill MAXSPR - 1, 0
	sortorderlast: .byte 0


	TextRow:	.byte 0
	TextColumn:	.byte 0
	TEMP1:		.byte 0
	TEMP2:		.byte 0
