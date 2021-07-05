PLEXOR: {

	SpriteIndex:
		.byte $00
	VicSpriteIndex:
		.byte $00

	POT:
		.byte 1,2,4,8,16,32,64,128
	IPOT:
		.byte 254,253,251,247,239,223,191,127


.align $100
	* = * "VicSpriteTable"
	VicSpriteTable:
		.word MP_IRQ.LoopStart[0].Unrolled
		.word MP_IRQ.LoopStart[1].Unrolled
		.word MP_IRQ.LoopStart[2].Unrolled
		.word MP_IRQ.LoopStart[3].Unrolled
		.word MP_IRQ.LoopStart[4].Unrolled
		.word MP_IRQ.LoopStart[5].Unrolled
		.word MP_IRQ.LoopStart[6].Unrolled
		.word MP_IRQ.LoopStart[7].Unrolled

	Initialise: {

	ldx #$00
	!:
		lda __DATA, x
		sta SpriteX, x

		inx
		cpx #[__DATAEND - __DATA]
		bne !-

		.break

		lda SpriteX - 1, x 

		lda #$00
		sta $d020
		sta $d021



		rts


	}

	__DATA:
		_SpriteX:
			.fill MAX_SPRITES,0
		_SpriteY:
			.var yy = 10
			.for(var i=0; i<MAX_SPRITES; i++) {
				.byte yy
			}
		_SpriteColor:
			.fill MAX_SPRITES, random() * 15 + 1
		_SpritePointer:
			.fill MAX_SPRITES, $c0
		_SpriteOrder:
			.fill MAX_SPRITES, i
	__DATAEND:




	*=* "IRQ"
	MP_IRQ: {
			pha
			txa 
			pha 
			tya 
			pha 

				inc $d020

			CheckWhere:

				lda VicSpriteIndex
				and #$07
				asl 
				sta SelfMod + 1
			SelfMod:
				jmp (VicSpriteTable)

			LoopStart:
				.for(var i=0; i<8; i++) {
			Unrolled:
						ldx SpriteIndex
						lda SpriteOrder, x
						tax

						lda SpriteColor, x
						sta $d027 + i
						lda SpritePointer, x
						sta SPRITE_POINTERS + i

						lda SpriteCopyX, x
						sta $d000 + i * 2
						lda SpriteCopyY, x
						cmp #11
						bcs Okay

						lda #0
						sta $d000 + i * 2
						jmp NextSprite

						Okay:

						sta $d001 + i * 2

					NextSprite:

						inc VicSpriteIndex

						ldx SpriteIndex
						inx 
						stx SpriteIndex
						cpx #MAX_SPRITES
						bne !+
						jmp !Finish+
					!:


						lda SpriteOrder, x
						tax
						lda SpriteCopyY, x
						sec 
						sbc #8
						cmp $d012
						bcc !+
						jmp !nextRaster+
					!:
				}	
				jmp CheckWhere


				!nextRaster:
					clc
					adc #PADDING
					sta $d012
					jmp !ExitRaster+

			
			!Finish:
				lda #$00
				sta $d012
				sta VicSpriteIndex
				sta SpriteIndex

				lda #<IRQ.OpenBorderIRQ
				ldx #>IRQ.OpenBorderIRQ
				ldy #IRQ.OpenBorderIRQLine
				jsr IRQ.SetNextInterrupt

				jmp Done


		!ExitRaster:
			

			lda $d011
			and #$7f
			sta $d011
			lda #<MP_IRQ
			sta $fffe	 
			lda #>MP_IRQ
			sta $ffff

		Done:
			dec $d020
			asl $d019
			pla
			tay 
			pla 
			tax
			pla
			rti
	}

	

	Sort: {	

		inc $d020

       
		ldx #0 

			Loop2:

				lda SpriteY, x
				sta SpriteCopyY, x

				lda SpriteX, x
				sta SpriteCopyX, x

				inx
				cpx #MAX_SPRITES
				bcc Loop2

			restart:
				//SWIV adapted SORT
                ldx #$00
                txa 
		sortloop:       
				ldy SpriteOrder,x 
                cmp SpriteY,y 
                beq noswap2 
                bcc noswap1 
                stx TEMP1 
                sty TEMP2 
                lda SpriteY,y 
                ldy SpriteOrder - 1,x 
                sty SpriteOrder,x 
                dex 
                beq swapdone 
		swaploop:       
				ldy SpriteOrder - 1,x 
                sty SpriteOrder,x 
                cmp SpriteY,y 
                bcs swapdone 
                dex 
                bne swaploop 
		swapdone:       
				ldy TEMP2 
                sty SpriteOrder, x 
                ldx TEMP1 
                ldy SpriteOrder, x 
		noswap1:
		        lda SpriteY, y 
		noswap2:
		        inx 
                cpx #MAX_SPRITES
                bne sortloop 

        dec $d020


        rts
	}



}