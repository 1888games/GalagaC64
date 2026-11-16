// - Tape Turbo Loader
// -------------------------------------------------------------------------------------
// - The tape (tape/maketap.js): a standard KERNAL header and data block, then blocks in
// - this loader's own format, about 6 times faster. The header block's spare 171 bytes
// - after the name (the cassette buffer from $0351) hold the loader (High); the data block
// - loads the rest (Low) from $02A7 up to BASIC's main loop vector ($0302), and the vector
// - itself, so when LOAD finishes BASIC jumps here (SHIFT + RUN / STOP or LOAD both work).
// - Every pulse is timed by CIA 1's clock, free running, so a picture on show (its bad
// - lines) only moves when it's read: short a 0, long a 1, bytes the top bit first, the
// - border striped with them. A block: pilot bytes (PILOT) until the countdown 9 - 1, then
// - its start, end (not included) and run address, the bytes and an XOR check. The run
// - address: RUN_NEXT the next block, RUN_SHOW_PICTURE the loading picture shown then the
// - next block (its screen and colours have loaded, the bitmap follows, drawing in), else
// - the program's start (the exomizer decruncher's SYS), the screen off for it
// - Output: bin/tape/turbo_high.bin (the header block's last 171 bytes), turbo_low.bin
// - (the data block: $02A7 - $0303)

.label TURBO_LOW = $02a7					// (free: up to BASIC's vectors)
.label BASIC_MAIN_VECTOR = $0302
.label TURBO_HIGH = $0351					// (the cassette buffer: the header's bytes 21 - 191)
.label BUFFER_END = $03fc

// the pulses (maketap.js): short 264 cycles, long 528. CIA 1's timer A runs out every 4
// cycles and timer B counts that down, both free running: a pulse is 66 or 132 counts

.label THRESHOLD = 99
.label PILOT = $02
.label COUNTDOWN = 9
.label RUN_NEXT = 0
.label RUN_SHOW_PICTURE = 1

// the loading picture: multicolour bitmap in VIC bank 3, clear of the game loading below
// $C000. The bitmap's under the KERNAL (the VIC sees the RAM), the colours straight in

.label PICTURE_SCREEN = $c000
.label PICTURE_BITMAP = $e000
.label BITMAP_PAGES = $20
.label BANK_3 = %11111100					// CIA 2 port A's VIC bank bits 0
.label PICTURE_MEMORY = (PICTURE_SCREEN & $3c00) >> 6 | (PICTURE_BITMAP & $2000) >> 10

.label PROCESSOR_PORT = $01
.label MOTOR_OFF = %00100000
.label KEYBOARD_COUNT = $c6
.label SCREEN_CONTROL = $d011
.label SCREEN_ON = %00010000
.label BITMAP_ON = %00111011				// bitmap mode, the screen on, 25 rows
.label TEXT_SCREEN_OFF = %00001011			// text mode, the screen off, 25 rows
.label CONTROL_2 = $d016
.label MULTICOLOUR = %00011000				// multicolour, 40 columns
.label MEMORY_SETUP = $d018
.label BORDER_COLOUR = $d020
.label RED = 2
.label CIA1_TIMER_A = $dc04
.label CIA1_TIMER_B = $dc06
.label CIA1_ICR = $dc0d
.label CIA1_CONTROL_A = $dc0e
.label CIA1_CONTROL_B = $dc0f
.label FLAG = %00010000						// the cassette read line's falling edge
.label CIA2_PORT_A = $dd00

.errorif PICTURE_MEMORY != %00001000, "the picture's screen and bitmap in $D018"

// zero page (the game sets up its own after)

.label Byte = $f7
.label Check = $f8
.label Pointer = $f9						// (2) the block's start, end and run address in
.label End = $fb							// (2) the order they're on the tape (Header)
.label Run = $fd							// (2)
.label Last = $ff							// timer B at the last edge

.segmentdef Low [start=TURBO_LOW, min=TURBO_LOW, max=BASIC_MAIN_VECTOR + 1, fill]
.segmentdef High [start=TURBO_HIGH, max=BUFFER_END - 1]
.file [name="turbo_low.bin", type="bin", segments="Low"]
.file [name="turbo_high.bin", type="bin", segments="High"]

.segment High

	Turbo: {

			sei
			lda #$7f
			sta CIA1_ICR						// no CIA interrupts

			lda SCREEN_CONTROL					// the screen off until there's a picture
			and #255 - SCREEN_ON
			sta SCREEN_CONTROL

			lda PROCESSOR_PORT					// motor on
			and #255 - MOTOR_OFF
			sta PROCESSOR_PORT

			// the clock: timer A runs out every 4 cycles, timer B counts it (only its low byte
			// is read: from a latch $xxFF it runs on through 0)

			lda #3
			sta CIA1_TIMER_A
			ldx #0
			stx CIA1_TIMER_A + 1
			dex
			stx CIA1_TIMER_B
			lda #%00010001						// start, continuous, loaded: the system clock
			sta CIA1_CONTROL_A
			lda #%01010001						// (the same) timer A running out
			sta CIA1_CONTROL_B

		// on the pilot: bits until they make a pilot byte, then whole bytes

		Block:

			jsr ReadBit
			rol Byte
			lda Byte
			cmp #PILOT
			bne Block

		Pilot:

			jsr ReadByte
			cmp #PILOT
			beq Pilot

			ldy #COUNTDOWN						// (ReadByte keeps Y)

		Countdown:

			sty Check
			cmp Check
			bne Block

			dey
			beq Header

			jsr ReadByte
			jmp Countdown

		Header:

			jsr ReadByte						// (Y = 0 to 5)
			sta Pointer, y
			iny
			cpy #Run + 2 - Pointer
			bne Header

			ldy #0
			sty Check

		Next:

			jsr ReadByte
			sta (Pointer), y
			sta BORDER_COLOUR
			eor Check
			sta Check

			inc Pointer
			bne !+
			inc Pointer + 1
		!:
			lda Pointer
			cmp End
			lda Pointer + 1
			sbc End + 1
			bcc Next

			jsr ReadByte
			cmp Check
			bne Failed

			jmp BlockDone

		Failed:

			lda #RED
			sta BORDER_COLOUR
			bne Failed
	}

	// - Read Bit: the clock's count since the last falling edge
	// - Returns: C = 1 a long pulse
	// - Clobbers: AX

	ReadBit: {

			lda #FLAG

		Wait:

			bit CIA1_ICR
			beq Wait

			ldx CIA1_TIMER_B					// (counting down)
			lda Last
			stx Last
			sec
			sbc Last
			cmp #THRESHOLD
			rts
	}

.segment Low

	// - Read Byte: 8 bits, the top first
	// - Returns: A
	// - Clobbers: X

	ReadByte: {

			lda #1								// a marker bit: out into C after 8
			sta Byte

		Bits:

			jsr ReadBit
			rol Byte
			bcc Bits

			lda Byte
			rts
	}

	// - Block Done: what the block's run address says
	// - Params: Y = 0

	BlockDone: {

			lda Run + 1
			bne Start

			lda Run
			beq Next

			jsr ShowPicture

		Next:

			jmp Turbo.Block

			// the program: motor off; text mode as BASIC had it (the game keeps $D011 but
			// its row count), the screen off while the decruncher writes all over the
			// picture: its exit puts it on (make.bat's exomizer -f); the keys typed (RUN
			// after SHIFT + RUN / STOP) forgotten

		Start:

			lda PROCESSOR_PORT
			ora #MOTOR_OFF
			sta PROCESSOR_PORT

			lda #TEXT_SCREEN_OFF
			sta SCREEN_CONTROL

			sty KEYBOARD_COUNT

			jmp (Run)
	}

	// - Show Picture: its bitmap cleared (it loads next, in view), then multicolour bitmap
	// - mode in bank 3
	// - Params: Y = 0

	ShowPicture: {

			.errorif (PICTURE_BITMAP & $ff) != 0, "the bitmap on a page"

			sty Pointer
			lda #>PICTURE_BITMAP
			sta Pointer + 1
			ldx #BITMAP_PAGES
			tya

		Clear:

			sta (Pointer), y
			iny
			bne Clear

			inc Pointer + 1
			dex
			bne Clear

			lda CIA2_PORT_A
			and #BANK_3
			sta CIA2_PORT_A
			lda #PICTURE_MEMORY
			sta MEMORY_SETUP
			lda #MULTICOLOUR
			sta CONTROL_2
			lda #BITMAP_ON
			sta SCREEN_CONTROL
			rts
	}

	* = BASIC_MAIN_VECTOR "Main Loop Vector"

	.word Turbo
