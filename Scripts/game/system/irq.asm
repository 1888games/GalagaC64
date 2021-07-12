
IRQ: {

	*= * "IRQ"

	.label OpenBorderIRQLine = 249
	.label MainIRQLine =255

	.label ResetBorderIRQLine = 0
	.label MultiplexerIRQLine = 1
	
	DisableCIA: {

		// prevent CIA interrupts now the kernal is banked out
		lda #$7f
		sta IRQControlRegister1
		sta IRQControlRegister2

		rts

	}


	SetupInterrupts: {

		sei 	// disable interrupt flag
		lda VIC.INTERRUPT_CONTROL
		ora #%00000001		// turn on raster interrupts
		sta VIC.INTERRUPT_CONTROL

		//lda #<MainIRQ
		//ldx #>MainIRQ
	//	ldy #MainIRQLine
		//jsr SetNextInterrupt

		lda #<PLEXOR.MP_IRQ
		ldx #>PLEXOR.MP_IRQ
		ldy #0
		jsr SetNextInterrupt

		asl VIC.INTERRUPT_STATUS
		cli

		rts


	}



	SetNextInterrupt: {

		sta INTERRUPT_VECTOR
		stx INTERRUPT_VECTOR + 1
		sty VIC.RASTER_Y
		lda VIC.SCREEN_CONTROL
		and #%01111111		// don't use 255+
		sta VIC.SCREEN_CONTROL

		rts
	}

	SetLowInterrupt: {

		sta INTERRUPT_VECTOR
		stx INTERRUPT_VECTOR + 1
		sty VIC.RASTER_Y
		lda VIC.SCREEN_CONTROL
		and #%01111111		// don't use 255+

		sta VIC.SCREEN_CONTROL

		rts

	}


	OpenBorderIRQ: {

			//lda #CYAN
			//sta $d020

		:StoreState()



		OpenBorder:

			lda MAIN.GameMode
			beq Finish

			lda VIC.SCREEN_CONTROL 
			and #%11110111
			sta VIC.SCREEN_CONTROL 
			
		Finish:

			ldy #MainIRQLine
			lda #<MainIRQ
			ldx #>MainIRQ
			jsr SetNextInterrupt 
			


		asl VIC.INTERRUPT_STATUS
		:RestoreState()

		//lda  #BLACK
		//sta $d020

		rti

	}

	ResetBorderIRQ: {

		:StoreState()

		ResetBorder:

			lda MAIN.GameMode
			beq Finish

			lda VIC.SCREEN_CONTROL 
			ora #%00001000
			sta VIC.SCREEN_CONTROL 
			
		Finish:

			ldy #MultiplexerIRQLine
			lda #<PLEXOR.MP_IRQ
			ldx #>PLEXOR.MP_IRQ
			jsr SetNextInterrupt 
		

		asl VIC.INTERRUPT_STATUS
		:RestoreState()

		rti

	}

	MainIRQ: {

		:StoreState()

		SetDebugBorder(2)

		ResetBorder:	

			lda MAIN.GameMode
			beq KickOffFrameCode

			lda VIC.SCREEN_CONTROL 
			ora #%00001000
			sta VIC.SCREEN_CONTROL 

		KickOffFrameCode:

			lda #0
			sta $dc02

			ldy #2
			jsr INPUT.ReadJoystick

			jsr sid.play

			lda #TRUE
			sta MAIN.PerformFrameCodeFlag
			
			inc ZP.Counter
	
		Finish:

			
			ldy #MultiplexerIRQLine
			lda #<PLEXOR.MP_IRQ
			ldx #>PLEXOR.MP_IRQ
			jsr SetNextInterrupt 

		NoSprites:

		lda MAIN.GameActive
		beq NoSort

		//jsr PLEXOR.Sort



		NoSort:

		asl VIC.INTERRUPT_STATUS

		SetDebugBorder(0)


		:RestoreState()

		rti

	}

	





}