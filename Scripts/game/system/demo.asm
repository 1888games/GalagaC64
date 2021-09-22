DEMO: {

	* = * "Demo"

	.label DelayTime = 5
	.label FlipTime = 250


	DelayTimer:	.byte DelayTime
	FlipTimer:	.byte 0


	Progress:	.byte 0

	Sprite1: 	.byte 0, 0, 122, 34, 52, 52, 52, 17, 18, 19, 20, 21, 22
			
	


	Show: {

		jsr UTILITY.ClearTitleWindow

		lda #GAME_MODE_DEMO
		sta MAIN.GameMode

		lda #0
		sta Progress

		lda #FlipTime
		sta FlipTimer



		rts
	}

	

	FrameCode: {

		lda FlipTimer
		beq Ready

		dec FlipTimer
		rts





		Ready:

		jmp MAIN.ShowTitleScreen


		rts
	}





}