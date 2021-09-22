UTILITY: {

	* = * "Utility"

	BankOutKernalAndBasic:{

		lda PROCESSOR_PORT
		and #%11111000
		ora #%00000101
		sta PROCESSOR_PORT
		rts
	}

	BankInKernal: {

		lda PROCESSOR_PORT
		and #%11111000
		ora #%00000110
		sta PROCESSOR_PORT
		rts

	}
	

	ClearScreen: {

		ldx #250
		lda #0

		Loop:

			sta SCREEN_RAM - 1, x
			sta SCREEN_RAM + 249, x
			sta SCREEN_RAM + 499, x
			sta SCREEN_RAM + 749, x

			dex
			bne Loop


		rts	


	}


	ClearTitleWindow: {

		ldx #250
		lda #0

		Loop:

			sta SCREEN_RAM + 119, x
			sta SCREEN_RAM + 249, x
			sta SCREEN_RAM + 499, x
			sta SCREEN_RAM + 749, x

			dex
			bne Loop




		rts
	}


	DeleteText: {

		sta ZP.Amount

		jsr PLOT.GetCharacter

		ldy #0
		lda #0

		Loop:


			sta (ZP.ScreenAddress), y

			iny
			cpy ZP.Amount
			bcc Loop


		rts
	}
}