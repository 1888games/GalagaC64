



// most likely errors: 
// a = $05 (device not present) 
// a = $04 (file not found) 
// a = $1d (load error) 
// a = $00 (break, run/stop has been pressed during loading) 
	
DISK: {

.label K_close           = $ffc3 
.label K_open            = $ffc0 
.label K_setnam          = $ffbd 
.label K_setlfs          = $ffba 
.label K_clrchn          = $ffcc 
.label K_load            = $ffd5 
.label K_save            = $ffd8 

.label file_start = $0810
.label file_end = $0833


// ************************************************************** 
// Save High Score Data 


    SAVE: { 


            .label file_start = $0810    // example addresses
            .label file_end   = $0833    // SAVE stops before this, so one past LowByte + 4

            jsr OnDrive
            bcs Okay

            rts

        Okay:

            lda #0
            sta $02a1
            sta $d404               // Sid silent 
            sta $d404+7 
            sta $d404+14 

    		lda #0
    		sta VIC.SPRITE_ENABLE
    		sta VIC.INTERRUPT_CONTROL

    		jsr MAIN.SaveGameZP

    		sei
    		jsr UTILITY.BankInKernal
    		cli

            jsr DELETE

          
            lda #0
            sta $02a1 

            lda #fname_end-fname
            ldx #<fname
            ldy #>fname
            jsr $FFBD     // call SETNAM
            
            lda #$02
            ldx $BA       // last used device number
            bne skip
            ldx #$08      // default to device 8
    skip:   ldy #$00
            jsr $FFBA     // call SETLFS

            lda #<file_start
            sta $C1
            lda #>file_start
            sta $C2

            ldx #<file_end
            ldy #>file_end
            lda #$C1      // start address located in $C1/$C2
            jsr $FFD8     // call SAVE
            bcs error    // if carry set, a load error has happened


            lda #2               // Logical 
            jsr K_close 
            jsr K_clrchn 


    		jsr MAIN.SaveKernalZP
    		jsr UTILITY.BankOutKernalAndBasic

            lda VIC.BANK_SELECT
            and #%11111100
            sta VIC.BANK_SELECT

    		jsr IRQ.SetupInterrupts


    		lda #255
    		sta VIC.SPRITE_ENABLE

    		lda #%00000001
    		sta VIC.INTERRUPT_CONTROL

    		rts
    error:
            // Akkumulatorkkumulator contains BASIC error code


            .break

             lda #2               // Logical 
            jsr K_close 
            jsr K_clrchn 


            jsr MAIN.SaveKernalZP
    		jsr UTILITY.BankOutKernalAndBasic
    
    		lda #255
    		sta VIC.SPRITE_ENABLE

    		lda #%00000001
    		sta VIC.INTERRUPT_CONTROL

            lda VIC.BANK_SELECT
            and #%11111100
            sta VIC.BANK_SELECT

            jsr IRQ.SetupInterrupts

          //	.break
          	nop
            rts

    fname:  .text "GALSCORES,S"
    fname_end:

    }
        	

    DELETE: {

    	

            lda #fname_end-fname
            ldx #<fname
            ldy #>fname
            jsr $FFBD     // call SETNAM
            lda #2
            ldx $BA       // last used device number
            bne skip
            ldx #$08      // default to device 8
    skip:   ldy #15
            jsr $FFBA     // call SETLFS

            jsr $FFC0    // call OPEN        bcs error    // if carry set, a load error has happened
            bcs error

            lda #2               // Logical 
            jsr K_close 
            jsr K_clrchn 

    		rts
    error:
            // Akkumulator contains BASIC error code

            inc $d020
            dec $d020
            
            lda #2               // Logical 
            jsr K_close 
            jsr K_clrchn 

    	

          //	.break
          	nop
            rts

    fname:      .byte $53,$30,$3A 
                .text "GALSCORES"
    fname_end:

    }
	


    // The scores live on disk. Loaded from tape the last device ($BA) is 1,
    // and the KERNAL would wait for a GALSCORES file on the tape, so keep
    // the table in memory. The game uses $BA itself, so read the copy kept
    // at startup. Returns C = 1 for a disk drive (0 means 8, as below).

    OnDrive: {

    		lda KernalZP + $ba
    		beq Drive

    		cmp #8
    		rts

    	Drive:

    		sec
    		rts
    }


    LOAD: {

    		.label load_address = $0810  // just an example

    		jsr OnDrive
    		bcs Okay

    		rts

    	Okay:

    		lda #0
    		sta VIC.SPRITE_ENABLE
    		sta VIC.INTERRUPT_CONTROL

    		jsr MAIN.SaveGameZP

    		sei
    		jsr UTILITY.BankInKernal
    		cli

    		

            lda #fname_end-fname
            ldx #<fname
            ldy #>fname
            jsr $FFBD     // call SETNAM
            lda #$01
            ldx $BA       // last used device number
            bne skip
            ldx #$08      // default to device 8
    skip:   ldy #$00      // $00 means: load to new address
            jsr $FFBA     // call SETLFS

            ldx #<load_address
            ldy #>load_address
            lda #$00      // $00 means: load to memory (not verify)
            jsr $FFD5     // call LOAD
            bcs error    // if carry set, a load error has happened


            lda #2               // Logical 
            jsr K_close 
            jsr K_clrchn 

            jsr MAIN.SaveKernalZP
    		jsr UTILITY.BankOutKernalAndBasic

    		lda #255
    		sta VIC.SPRITE_ENABLE

    		lda #%00000001
    		sta VIC.INTERRUPT_CONTROL

            jsr IRQ.SetupInterrupts


            rts
    error:

        
            lda #2               // Logical 
            jsr K_close 
            jsr K_clrchn 

            jsr MAIN.SaveKernalZP
    		jsr UTILITY.BankOutKernalAndBasic
    	
    		lda #255
    		sta VIC.SPRITE_ENABLE

    		lda #%00000001
    		sta VIC.INTERRUPT_CONTROL

            jsr IRQ.SetupInterrupts


            // Accumulator contains BASIC error code

            // most likely errors:
            // A = $05 (DEVICE NOT PRESENT)
            // A = $04 (FILE NOT FOUND)
            // A = $1D (LOAD ERROR)
            // A = $00 (BREAK, RUN/STOP has been pressed during loading)

           // ... error handling ...

          // .break
           nop
            rts

    fname:  .text "GALSCORES,S"
    fname_end:



    }


}
