  //exomizer sfx sys -t 64 -x "inc $d020" -o yakf.exo yakf.prg

.var sid = LoadSid("../assets/galaga.sid")

MAIN: {

	#import "data/zeropage.asm"

	BasicUpstart2(Entry)

	*=$1000 "Modules"

	#import "data/labels.asm"
	#import "data/vic.asm"
	#import "game/system/irq.asm"
	#import "common/utility.asm"
	#import "common/macros.asm"
	#import "common/input.asm"
	#import "game/gameplay/ship.asm"
	#import "game/gameplay/bullets.asm"
	#import "game/gameplay/formation.asm"


	#import "common/maploader.asm"
	#import "common/plot.asm"
	#import "game/system/stars.asm"
	#import "common/random.asm"
	#import "data/wave_data.asm"
	#import "data/challenge_paths.asm"
	#import "game/system/multiplexor.asm"
//	#import "game/system/shallan.asm"
	#import "game/gameplay/enemy.asm"
	#import "game/gameplay/enemy_variables.asm"
	#import "game/gameplay/collision.asm"
	
	#import "game/gameplay/spawn.asm"
	#import "game/gameplay/pathfinding.asm"	
	#import "game/gameplay/stage.asm"
	#import "game/system/title.asm"
	#import "common/text.asm"

	#import "game/system/pre_stage.asm"


	
	#import "data/enemy_data.asm"


	* = $f800
	#import "game/system/hi_score.asm"

 	* = $8000

	#import "game/system/disk.asm"
	#import "game/system/score.asm"
		#import "game/gameplay/bombs.asm"
	
	* = $9000
	#import "game/system/stats.asm"
	#import "game/system/game_over.asm"
	#import "game/gameplay/beam.asm"
	#import "common/sfx.asm"
	#import "game/system/challenge.asm"
	#import "game/system/bonus.asm"
	#import "game/gameplay/attacks.asm"
		#import "game/system/lives.asm"

	
	//* = $2000
	//#import "data/enemy_data.asm"
	

	* = $6c00 "Main"

	GameActive: 			.byte FALSE
	PerformFrameCodeFlag:	.byte FALSE
	GameIsOver:				.byte FALSE
	MachineType: 			.byte PAL

	GameMode:				.byte 0
	
	Entry: {


		jsr IRQ.DisableCIA

		jsr SaveKernalZP

		jsr UTILITY.BankOutKernalAndBasic


		lda #SUBTUNE_BLANK
		jsr sid.init
		jsr set_sfx_routine
		jsr RANDOM.init
		jsr PLEXOR.Initialise

		//jsr 
		jsr IRQ.SetupInterrupts


		jsr SetGameColours	
		jsr SetupVIC

		//jsr STATS.Calculate
		//jsr PLEXOR2.start

		lda #<nmi
		sta $fffa7
		lda #>nmi
		sta $fffb

		lda $2A6
		sta MachineType
		
		sfx(SFX_COIN)

		
		//jsr DISK.LOAD


		jmp ShowTitleScreen	

		jmp InitialiseGame

	}

	

	nmi: {

		rti
	}


	ShowTitleScreen: {



		jsr UTILITY.ClearScreen
		jsr TITLE.Initialise
		//jsr LoadScreen

		lda #GAME_MODE_TITLE
		sta GameMode

		lda #TRUE
		sta GameActive



		jmp Loop


		rts
	}





	ResetGame: {

		lda #0
		sta GameActive
		sta SCORE.ScoreInitialised

		jsr UTILITY.ClearScreen

		jsr LoadScreen	

		jsr SCORE.Reset
		jsr SCORE.DrawP1
		jsr SCORE.DrawBest
		jsr STATS.Reset

		jsr LIVES.Draw
		
		jsr LIVES.NewGame

		jsr PRE_STAGE.Initialise

		rts

	}


	InitialiseGame: {
		
		jsr ResetGame



		jmp Loop

	}


	LoadScreen: {

		lda #GAME_MAP
		sta MAPLOADER.CurrentMapID

		jsr MAPLOADER.DrawMap

		lda #RED
		sta VIC.COLOR_RAM + 271
		sta VIC.COLOR_RAM + 431



		rts
	}

	SetupVIC: {

		lda #0
		sta $bfff

		lda #ALL_ON
		sta VIC.SPRITE_ENABLE

		lda #%00001100
		sta VIC.MEMORY_SETUP

		//Set VIC BANK 3, last two bits = 00
		lda VIC.BANK_SELECT
		and #%11111100
		//ora #%00000001
		sta VIC.BANK_SELECT

		lda #%00000000
		sta VIC.SPRITE_PRIORITY


	SwitchOnMulticolourMode:

		lda VIC.SCREEN_CONTROL_2
 		and #%11101111
 		ora #%00010000
 		sta VIC.SCREEN_CONTROL_2


		rts
	}

	SetGameColours: {

		lda #BLACK
		sta VIC.BACKGROUND_COLOR

		lda #BLACK
		sta VIC.BORDER_COLOR

		lda #RED
		sta VIC.EXTENDED_BG_COLOR_1
		sta VIC.SPRITE_MULTICOLOR_1
	 	lda #BLUE
	 	sta VIC.EXTENDED_BG_COLOR_2
	 	sta VIC.SPRITE_MULTICOLOR_2

		rts

	}



	Loop: {

		lda PerformFrameCodeFlag
		beq Loop

		jmp FrameCode

	}




	FrameCode: {

		lda #0
		sta PerformFrameCodeFlag

		lda GameActive
		bne IsActive

		jmp GamePaused

	IsActive:

		jsr SpeedFrameUpdate

		lda GameMode
		cmp #GAME_MODE_PLAY
		beq Playing

		cmp #GAME_MODE_PRE_STAGE
		beq PreStage

		cmp #GAME_MODE_OVER
		beq GameOver

		cmp #GAME_MODE_CHALLENGE
		beq Challenge

		cmp #GAME_MODE_SCORE
		beq Score

		cmp #GAME_MODE_SWITCH_TITLE
		bne TitleScreen


		jmp ShowTitleScreen


		Score:

			jsr STARS.FrameUpdate
			jsr HI_SCORE.FrameCode

			jmp Loop

		Challenge:

			jsr PLEXOR.Sort
			jsr CHALLENGE.FrameUpdate
			jsr STARS.FrameUpdate
			jmp Loop

		TitleScreen:
			
			jsr PLEXOR.Sort
			jsr TITLE.FrameUpdate

			lda GameMode
			cmp #GAME_MODE_PLAY
			beq Loop

			jsr STARS.FrameUpdate

			
			jmp Loop


		Playing:	

			jsr PLEXOR.Sort

			jsr STARS.FrameUpdate
			jsr FORMATION.FrameUpdate
			jsr BULLETS.FrameUpdate
			jsr STAGE.FrameUpdate
			jsr ENEMY.FrameUpdate
			jsr BOMBS.FrameUpdate
			jsr LIVES.FrameUpdate
			jsr ATTACKS.FrameUpdate
			jsr SHIP.FrameUpdate
			//jsr BEAM.FrameUpdate
			jsr BONUS.FrameUpdate

			jmp Loop

		PreStage:

			jsr STARS.FrameUpdate
			jsr PRE_STAGE.FrameUpdate
			jsr LIVES.FrameUpdate
			jsr BONUS.FrameUpdate

			jmp Loop

		GameOver:

			jsr PLEXOR.Sort
			jsr LIVES.FrameUpdate
			jsr STARS.FrameUpdate
			jsr END_GAME.FrameUpdate
			jsr BONUS.FrameUpdate

			jmp Loop
		

		GamePaused:

			jmp Loop


	}	

	SaveKernalZP: {

		ldx #2

		Loop:

			lda $02, x
			sta KernalZP, x

			lda GameZP, x
			sta $02, x

			inx
			bne Loop

		rts
	}

	SaveGameZP: {

		ldx #2

		Loop:

			lda $02, x
			sta GameZP, x

			lda KernalZP, x
			sta $02, x

			inx
			bne Loop

		rts
	}
	
	
 
}

* = $900 "Hi score_Data"

		FirstInitials:		.text "acnse"
		SecondInitials:		.text "roiaa"
		ThirdInitials:		.text "lrcmk"

		// HiByte:				.byte $10, $07, $04, $02, $01, $10, $07, $04, $02, $01, $10, $07, $05, $02, $01
		// MedByte:			.byte $45, $69, $82, $57, $50, $45, $69, $82, $57, $29, $52, $41, $11, $40, $58
		// LowByte:			.byte $23, $12, $70, $63, $78, $91, $52, $46, $02, $08, $99, $31, $47, $28, $12

		MillByte:			.byte $00, $00, $00, $00, $00
		HiByte:				.byte $03, $02, $02, $01, $01
		MedByte:			.byte $00, $50, $00, $50, $00
		LowByte:			.byte $00, $00, $00, $00, $00

* = $a400 "Game ZP Backup"
	
GameZP:		.fill 256, 0
KernalZP:	.fill 256, 0



		
	#import "data/assets.asm"