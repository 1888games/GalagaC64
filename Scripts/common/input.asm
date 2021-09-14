


INPUT: {

	* = * "Input"

	.label joyUpMask =  %00001
	.label joyDownMask = %00010
	.label joyLeftMask = %00100
	.label joyRightMask = %01000
	.label joyFireMask = %10000

	JOY_READING: 		.word $00
	PortToRead:			.byte 0

	JOY_RIGHT_LAST: 	.word $00
	JOY_LEFT_LAST:  	.word $00
	JOY_DOWN_LAST: 		.word $00
	JOY_UP_LAST:  		.word $00
	JOY_FIRE_LAST: 		.word $00

	JOY_RIGHT_NOW:  	.word $00
	JOY_LEFT_NOW:  		.word $00
	JOY_DOWN_NOW: 		.word $00
	JOY_UP_NOW:  		.word $00
	JOY_FIRE_NOW: 		.word $00

	FIRE_UP_THIS_FRAME: .word $00


	ReadC64Joystick: {

		cpy #ZERO
		beq PortOne

	* = * "Joystick"

		lda $dc00
		jmp StoreReading

		PortOne:

		lda $dc01

		StoreReading:

		sta JOY_READING, y

		rts
	}


	CalculateButtons: {

		ldy PortToRead

		CheckFire:

			// Check i fire held now
			lda JOY_READING, y
			and #INPUT.joyFireMask
			bne CheckFireUp

			// Fire held now
			lda #ONE
			sta JOY_FIRE_NOW, y

			lda JOY_FIRE_LAST, y
			eor #%00000001
			sta FIRE_UP_THIS_FRAME, y

			//jsr RANDOM.Change
			
			jmp CheckLeft

			// Fire not held now
			CheckFireUp:

				//lda JOY_FIRE_LAST, y
				//sta FIRE_UP_THIS_FRAME, y

		CheckLeft:

			lda JOY_READING, y
			and #INPUT.joyLeftMask
			bne LeftUp

			lda #ONE
			sta JOY_LEFT_NOW, y

			//jsr RANDOM.Change

			jmp CheckUp

			LeftUp:

		CheckUp:

			lda JOY_READING, y
			and #INPUT.joyUpMask
			bne UpUp


			lda #ONE
			sta JOY_UP_NOW, y

			//jsr RANDOM.Change


			jmp CheckRight
			
			UpUp:
				

		CheckDown:

			lda JOY_READING, y
			and #INPUT.joyDownMask
			bne DownUp


			lda #ONE
			sta JOY_DOWN_NOW, y

			//jsr RANDOM.Change

			jmp CheckRight
			
			DownUp:
				

		CheckRight:

			lda JOY_READING, y
			and #INPUT.joyRightMask

			bne RightUp
			lda #ONE

			sta JOY_RIGHT_NOW, y

			//jsr RANDOM.Change

			jmp Finish
			
			RightUp:
				

		Finish:



		rts
	}

	ReadJoystick: {

		dey
		sty INPUT.PortToRead

		lda INPUT.JOY_FIRE_NOW, y
		sta INPUT.JOY_FIRE_LAST, y

		lda INPUT.JOY_RIGHT_NOW, y
		sta INPUT.JOY_RIGHT_LAST, y

		lda INPUT.JOY_UP_NOW, y
		sta INPUT.JOY_UP_LAST, y

		lda INPUT.JOY_DOWN_NOW, y
		sta INPUT.JOY_DOWN_LAST, y

		lda INPUT.JOY_LEFT_NOW, y
		sta INPUT.JOY_LEFT_LAST, y
		
		lda #ZERO
		sta INPUT.JOY_FIRE_NOW, y
		sta INPUT.JOY_RIGHT_NOW, y
		sta INPUT.JOY_LEFT_NOW, y
		sta INPUT.JOY_UP_NOW, y
		sta INPUT.JOY_DOWN_NOW, y

		jsr INPUT.ReadC64Joystick
		jsr INPUT.CalculateButtons


		rts


	}


}



