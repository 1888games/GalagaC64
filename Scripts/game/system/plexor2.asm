PLEXOR2: {

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Spritemultiplexing example V2.1                                              ³
//³by Lasse ™”rni (loorni@student.oulu.fi)                                      ³
//³Available at http://covertbitops.cjb.net                                     ³
//³                                                                             ³
//³Quite easy (?) to understand example how to make a spritemultiplexer,        ³
//³using 32 sprites. The routine is capable of more but the screen starts       ³
//³to become very crowded, as they move randomly...                             ³
//³                                                                             ³
//³Uses a "new" more optimal sortmethod that doesn't take as much time          ³
//³as bubblesort. This method is based on the idea of an orderlist that         ³
//³is not recreated from scratch each frame// but instead modified every         ³
//³frame to create correct top-bottom order of sprites.                         ³
//³                                                                             ³
//³Why sorted top-bottom order of sprites is necessary for multiplexing:        ³
//³because raster interrupts are used to "rewrite" the sprite registers         ³
//³in the middle of the screen and raster interrupts follow the                 ³
//³top->bottom movement of the TV/monitor electron gun as it draws each         ³
//³frame.                                                                       ³
//³                                                                             ³
//³Light grey color in the bottom of the screen measures the time taken         ³
//³by sprite sorting.                                                           ³
//³                                                                             ³
//³What is missing from this tutorial for sake of simplicity:                   ³
//³* 16-bit X coordinates (it's now multiplying the X-coord by 2)               ³
//³* Elimination of "extra" (more than 8) sprites on a row                      ³
//³                                                                             ³
//³This source code is in DASM format.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

* = * "PLEXOR2"
.label sprx           = SpriteX                //Unsorted sprite table
.label spry         = SpriteY
.label sprc         =  SpriteColor
.label sprf           = SpritePointer



        //Main program

start:          jsr initsprites             //Init the multiplexing-system
 
                ldx #MAXSPR                 //Use all sprites
                stx numsprites

  				rts
        //Routine to init the raster interrupt system

        //Routine to init the sprite multiplexing system

initsprites:    lda #$00
                sta sortedsprites
                sta sprupdateflag
                ldx #MAXSPR-1                   //Init the order table with a
is_orderlist:   txa                             //0,1,2,3,4,5... order
                sta sortorder,x
                dex
                bpl is_orderlist
                rts

        //Raster interrupt 1. This is where sorting happens.

irq1:           //dec $d019                       //Acknowledge raster interrupt
                lda #$ff                        //Move all sprites
                sta $d001                       //to the bottom to prevent
                sta $d003                       //weird effects when sprite
                sta $d005                       //moves lower than what it
                sta $d007                       //previously was
                sta $d009
                sta $d00b
                sta $d00d
                sta $d00f

                lda sprupdateflag               //New sprites to be sorted?
                beq irq1_nonewsprites
                lda #$00
                sta sprupdateflag
                lda numsprites                  //Take number of sprites given
                                                //by the main program
                sta sortedsprites               //If itïs zero, donït need to
                bne irq1_beginsort              //sort

irq1_nonewsprites:
                ldx sortedsprites
                cpx #$09
                bcc irq1_notmorethan8
                ldx #$08
irq1_notmorethan8:
                lda d015tbl,x                   //Now put the right value to
                sta $d015                       //$d015, based on number of
                beq irq1_nospritesatall         //sprites
                                                //Now init the sprite-counter
                lda #$00                        //for the actual sprite display
                sta sprirqcounter               //routine
             
irq1_nospritesatall:
               rts

irq1_beginsort: inc $d020
                ldx #MAXSPR
                dex
                cpx sortedsprites
                bcc irq1_cleardone
                lda #$ff                        //Mark unused sprites with the
irq1_clearloop: sta spry,x                      //lowest Y-coordinate ($ff)//
                dex                             //these will "fall" to the
                cpx sortedsprites               //bottom of the sorted table
                bcs irq1_clearloop
irq1_cleardone: ldx #$00
irq1_sortloop:  ldy sortorder+1,x               //Sorting code. Algorithm
                lda spry,y                      //ripped from Dragon Breed :-)
                ldy sortorder,x
                cmp spry,y
                bcs irq1_sortskip
                stx irq1_sortreload+1
irq1_sortswap:  lda sortorder+1,x
                sta sortorder,x
                sty sortorder+1,x
                cpx #$00
                beq irq1_sortreload
                dex
                ldy sortorder+1,x
                lda spry,y
                ldy sortorder,x
                cmp spry,y
                bcc irq1_sortswap
irq1_sortreload:ldx #$00
irq1_sortskip:  inx
                cpx #MAXSPR-1
                bcc irq1_sortloop
                ldx sortedsprites
                lda #$ff                       //$ff is the endmark for the
                sta sortspry,x                 //sprite interrupt routine
                ldx #$00
irq1_sortloop3: ldy sortorder,x                //Final loop:
                lda spry,y                     //Now copy sprite variables to
                sta sortspry,x                 //the sorted table
                lda sprx,y
                sta sortsprx,x
                lda sprf,y
                sta sortsprf,x
                lda sprc,y
                sta sortsprc,x
                inx
                cpx sortedsprites
                bcc irq1_sortloop3
                dec $d020
               	rts

        //Raster interrupt 2. This is where sprite displaying happens

irq2:           dec $d019                       //Acknowledge raster interrupt
irq2_direct:    ldy sprirqcounter               //Take next sorted sprite number
                lda sortspry,y                  //Take Y-coord of first new sprite
                clc
                adc #$10                        //16 lines down from there is
                bcc irq2_notover                //the endpoint for this IRQ
                lda #$ff                        //Endpoint canït be more than $ff
irq2_notover:   sta tempvariable
irq2_spriteloop:lda sortspry,y
                cmp tempvariable                //End of this IRQ?
                bcs irq2_endspr
                ldx physicalsprtbl2,y           //Physical sprite number x 2
                sta $d001,x                     //for X & Y coordinate
                lda sortsprx,y
                asl
                sta $d000,x
                bcc irq2_lowmsb
                lda $d010
                ora ortbl,x
                sta $d010
                jmp irq2_msbok
irq2_lowmsb:    lda $d010
                and andtbl,x
                sta $d010
irq2_msbok:     ldx physicalsprtbl1,y           //Physical sprite number x 1
                lda sortsprf,y
                sta SPRITE_POINTERS,x                     //for color & frame
                lda sortsprc,y
                sta $d027,x
                iny
                bne irq2_spriteloop
irq2_endspr:    cmp #$ff                        //Was it the endmark?
                beq irq2_lastspr
                sty sprirqcounter
                sec                             //That coordinate - $10 is the
                sbc #$10                        //position for next interrupt
                cmp $d012                       //Already late from that?
                bcc irq2_direct                 //Then go directly to next IRQ
                sta $d012
                rti
irq2_lastspr:   lda #<IRQ.OpenBorderIRQ
				ldx #>IRQ.OpenBorderIRQ
				ldy #IRQ.OpenBorderIRQLine
				jsr IRQ.SetNextInterrupt
                rti

sortsprx:       .fill MAXSPR,0                   //Sorted sprite table
sortspry:       .fill MAXSPR+1,0                 //Must be one byte extra for the
                                                //$ff endmark
sortsprc:       .fill MAXSPR,0
sortsprf:       .fill MAXSPR,0


d015tbl:        .byte %00000000                  //Table of sprites that are "on"
                .byte %00000001                  //for $d015
                .byte %00000011
                .byte %00000111
                .byte %00001111
                .byte %00011111
                .byte %00111111
                .byte %01111111
                .byte %11111111

physicalsprtbl1: .byte 0,1,2,3,4,5,6,7            //Indexes to frame & color
                .byte 0,1,2,3,4,5,6,7            //registers
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7

physicalsprtbl2:.byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14

andtbl:         .byte 255-1
ortbl:          .byte 1
                .byte 255-2
                .byte 2
                .byte 255-4
                .byte 4
                .byte 255-8
                .byte 8
                .byte 255-16
                .byte 16
                .byte 255-32
                .byte 32
                .byte 255-64
                .byte 64
                .byte 255-128
                .byte 128





}