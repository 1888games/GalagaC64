RANDOM: {	

	* = * "-Random"

	RandomAdd: .byte 0


	Get: {

		jsr Get2

		adc $D41B

		//lda $D41B
		adc ZP.Counter
		adc RandomAdd

		rts

	}

	init2: {
			lda #$7f
			sta $dc04
			lda #$33
			sta $dc05
			lda #$2f
			sta $dd04
			lda #$79
			sta $dd05

			lda #$91
			sta $dc0e
			sta $dd0e
			rts

		}

	Get2: {
	        lda seed
	        beq doEor
	        asl
	        beq noEor
	        bcc noEor
	    doEor:    
	        eor #$1d
	        eor $dc04
	        eor $dd04
	    noEor:  
	        sta seed
	        rts
	    seed:
	        .byte $62
	}



    
    init: 

    	jsr init2
       
        lda #$FF  // maximum frequency values
		sta $D40E //voice 3 frequency low byte
		sta $D40F //voice 3 frequency high byte
		lda #$80  //noise waveform, gate bit off
		sta $D412 //voice 3 control register
		rts
		




	}