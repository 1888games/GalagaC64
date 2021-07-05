VIC: {

	.label COLOR_ADDRESS = ZP.ColourAddress
	.label SCREEN_ADDRESS = ZP.ScreenAddress

	MSB_On:		.byte %00000001, %00000010, %00000100,%00001000,%00010000,%00100000,%01000000,%10000000
	MSB_Off:	.byte %11111110, %11111101, %11111011,%11110111,%11101111,%11011111,%10111111,%01111111
	
	ScreenRowLSB:
		.fill 25, <[i * $28]
	ScreenRowMSB:
		.fill 25, >[i * $28]

	.label SPRITE_0_X = $d000
	.label SPRITE_0_Y = $d001

	.label SPRITE_1_X = $d002
	.label SPRITE_1_Y = $d003

	.label SPRITE_2_X = $d004
	.label SPRITE_2_Y = $d005

	.label SPRITE_3_X = $d006
	.label SPRITE_3_Y = $d007

	.label SPRITE_4_X = $d008
	.label SPRITE_4_Y = $d009

	.label SPRITE_5_X = $d00a
	.label SPRITE_5_Y = $d00b

	.label SPRITE_6_X = $d00c
	.label SPRITE_6_Y = $d00d

	.label SPRITE_7_X = $d00e
	.label SPRITE_7_Y = $d00f

	.label SPRITE_MSB = $d010

	.label RASTER_Y = $d012 

	.label SPRITE_ENABLE = $d015
	.label SCREEN_CONTROL_2 = $d016

	.label BANK_SELECT = $dd00

	.label SCREEN_CONTROL = $d011
	.label MEMORY_SETUP = $d018

	.label INTERRUPT_CONTROL = $d01a
	.label INTERRUPT_STATUS = $d019
	
	.label SPRITE_MULTICOLOR = $d01c

	.label BORDER_COLOR = $d020
	.label BACKGROUND_COLOR = $d021
	.label EXTENDED_BG_COLOR_1 = $d022
	.label EXTENDED_BG_COLOR_2 = $d023

	.label SPRITE_MULTICOLOR_1 = $d025
	.label SPRITE_MULTICOLOR_2 = $d026

	.label SPRITE_COLOR_0 = $d027
	.label SPRITE_COLOR_1 = $d028
	.label SPRITE_COLOR_2 = $d029
	.label SPRITE_COLOR_3 = $d02a
	.label SPRITE_COLOR_4 = $d02b
	.label SPRITE_COLOR_5 = $d02c
	.label SPRITE_COLOR_6 = $d02d
	.label SPRITE_COLOR_7 = $d02e

	.label SPRITE_PRIORITY = $d01b
	.label SPRITE_BG_COLLISION = $d01f

	.label COLOR_RAM = $d800


}