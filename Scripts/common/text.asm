TEXT: {

	*=* "---String Data"


	Text: {

		Digits: .fill 7, 0
		Pad:	.byte 0
		Digit:	.byte 0
		Word:	.byte 0, 0
	}
		
				    // 0   1    2    3    4    5    6    7    8    9    10   11	  12   13   14   15  16.   17   18.  19,  20,  21, 22
	Bank1:		.word Top, Scr, One, Two, Tmn, Arl, Str, Stg, Cst, Rea, Onu, Twu, Gmo, Res, Shf, Nmh, Hmr, Dot, Pct, Bon, Per, Spb, Fic
					// 23  24   25   26   27   28   29   30   31   32   33.   34
				.word Eni, Sco, Tp5, Nm1, Nm2, Nm3, Nm4, Nm5, Pau, Loa, Lo2, Ver


	Bank2:	  

	.label CharacterSetStart = 0
	.label Space = 32
	.label LineBreak = 47
	.label SpaceAscii = 32
	.label MonthStart = 0
	.label ZeroInCharSet = 48


	.label TITLE_GALAGA = 0
	.label TITLE_SCORE = 1

	.label START = 6
	.label STAGE = 7
	.label CHALLENGING_STAGE = 8
	.label READY = 9

	.label ONE_UP = 10
	.label TWO_UP = 11
	.label GAME_OVER = 12
	.label RESULT = 13
	.label SHOTS = 14
	.label HITS = 15
	.label RATIO = 16
	.label DOT = 17
	.label PERC = 18
	.label BONUS = 19
	.label PERFECT = 20
	.label SPECIAL = 21
	.label CAPTURED = 22
	.label INITIALS = 23
	.label SCORE = 24
	.label TOP_5 = 25
	.label NUM_START = 26
	.label PAUSE = 31
	.label LOADING = 32
	.label LOADING2 = 33
	.label VERSION = 34

	.encoding "screencode_mixed"
	Top:	.text @"1up      hi-score     2up\$00"	
	Scr:	.text @"  00                    00\$00"	
	One:	.text @"  1 player\$00"
	Two:	.text @"  2 players\$00"	
	Tmn:	.text @"tm and [ 1981 namco ltd.\$00"	
	Arl:	.text @"c64 port arlasoft 2021\$00"
	Str:	.text @"start\$00"		
	Stg:	.text @"stage\$00"
	Cst:	.text @"challenging stage\$00"
	Rea:	.text @"ready\$00"	
	Onu:	.text @"1 up\$00"	
	Twu:	.text @"2 up\$00"	
	Gmo:	.text @"game over\$00"	
	Res:	.text @"-results-\$00"	
	Shf:	.text @"shots fired\$00"
	Nmh:	.text @"number of hits\$00"		
	Hmr:	.text @"hit-miss ratio\$00"	
	Dot:		.text @".\$00"	
	Pct:		.text @"%\$00"	
	Bon:		.text @"bonus\$00"	
	Per:		.text @"perfect !\$00"	
	Spb:		.text @"special bonus 10000 pts\$00"	
	Fic:		.text @"fighter captured\$00"	
	Eni:		.text @"enter your initials !\$00"
	Sco:		.text @"pos    score    name\$00"
	Tp5:		.text @"galactic heroes\$00"
	Nm1:		.text @"1st\$00"
	Nm2:		.text @"2nd\$00"
	Nm3:		.text @"3rd\$00"
	Nm4:		.text @"4th\$00"
	Nm5:		.text @"5th\$00"
	Pau:		.text @"paused - hit fire to quit\$00"
	Loa:		.text @"ram ok\$00"
	Lo2:		.text @"rom ok\$00"
	Ver:		.text @"v1.05\$00"

	*=* "---Text"


	DrawByteInDigits: {

		stx ZP.CurrentID

		jsr ByteToDigits
		ldx #3

		jsr DrawDigits

		rts
	}

	DrawWordInDigits: {

		sty ZP.Temp4
		stx ZP.CurrentID

		jsr WordToDigits

		ldx #5

		ldy ZP.Temp4
		jsr DrawDigits

		rts
	}


	ByteToDigits: {


		ldx #$FF
		sec

		Dec100:

			inx
			sbc #100
			bcs Dec100

		adc #100
		stx Text.Digits

		ldx #$FF
		sec

		Dec10:

			inx
			sbc #10
			bcs Dec10

		adc #10
		stx Text.Digits + 1

		sta Text.Digits + 2

		rts	

	}

	PrDec16Tens: .word 1, 10, 100, 1000, 10000
  

	WordToDigits: {

		lda #0
		sta Text.Pad
		sta Text.Digit

		ldy #8

		Loop1:

			ldx #$FF
			sec

		Loop2:

			lda Text.Word + 0
			sbc PrDec16Tens +0, y
			sta Text.Word + 0

			lda Text.Word + 1
			sbc PrDec16Tens + 1, y
			sta Text.Word + 1

			inx
			bcs Loop2

			lda Text.Word + 0
			adc PrDec16Tens +0, y
			sta Text.Word + 0

			lda Text.Word + 1
			adc PrDec16Tens + 1, y
			sta Text.Word + 1

			txa
			bne Print



			Print:

				ldx Text.Digit
				inc Text.Digit
				sta Text.Digits, x

			Next:

				dey
				dey
				bpl Loop1


		rts
	}


	DrawDigits: {

		// TextRow
		// TextColumn
		// amount = number to draw
		// y=colour

		.label HadAValue = ZP.Temp1
		stx ZP.Amount	
		ldx #0
		sty ZP.Colour

		ldy ZP.CurrentID
		sty HadAValue

		Loop:

			stx ZP.CurrentID
	
			lda Text.Digits, x
			bne NonZero

			IsZero:

				lda HadAValue
				beq SkipDraw

				lda #ZeroInCharSet
				jmp Draw

			NonZero:

				cmp #99
				bne NotBlank	

				lda #Space
				jmp Draw

			NotBlank:

				clc
				adc #ZeroInCharSet

			Draw:

				inc HadAValue

				ldx TextColumn
				ldy TextRow
				jsr PLOT.PlotText



				lda ZP.Colour	
				jsr PLOT.ColorCharacter

			SkipDraw:

				inc TextColumn


			EndLoop:

				ldx ZP.CurrentID
				inx
				inx
				cpx ZP.Amount

				bcc NotLast

				inc HadAValue

				NotLast:
				dex
				cpx ZP.Amount
				beq Finish
				
				jmp Loop


		Finish:

			rts


	}



	DrawCustom: {

		stx ZP.Colour
		jsr DrawText

		rts

	}


		
	DrawText: {

		ldy #0

		Loop:

			sty ZP.CharOffset

			lda (ZP.TextAddress), y
			beq Finish

			cmp #LineBreak
			bne Okay

			NextRow:

				lda ZP.Column
				sta TextColumn
				inc TextRow
				jmp EndLoop

			Okay:

			cmp #SpaceAscii
			bne NotSpace

			lda #Space
			jmp Write

			NotSpace:

			clc
			adc #CharacterSetStart

			Write:

			ldx TextColumn
			ldy TextRow

			jsr PLOT.PlotText

			lda ZP.Colour
			jsr PLOT.ColorCharacter

			inc TextColumn

			EndLoop:

			ldy ZP.CharOffset
			iny
			jmp Loop


		Finish:

		rts

	}


	Draw: {

		// a = textID
		// y = bank
		// x = colour
		// TextColumn
		// TextRow

		stx ZP.Colour

		cmp #128
		bcc FromBank1


		FromBank2:

			sec
			sbc #128
			asl
			tax

			lda Bank2, x

			sta ZP.TextAddress
			inx

			lda Bank2, x
			sta ZP.TextAddress + 1
			jmp DrawNow

		FromBank1:

			asl
			tax
			lda Bank1, x

			sta ZP.TextAddress
			inx

			lda Bank1, x
			sta ZP.TextAddress + 1

		DrawNow:

			jsr DrawText

		rts
		

	}

	
  
}