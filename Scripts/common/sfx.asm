
.macro sfx(sfx_id)
{		
		:StoreState()

		ldx #sfx_id
		jsr sfx_play

		:RestoreState()
}

.macro sfxFromA() {

		:StoreState()

		tax	
		jsr sfx_play

		:RestoreState()

}

* = * "-Sound"

music_on: .byte 0
channel:	.byte 0

set_sfx_routine:
{
			lda music_on
			bne !on+
			
			lda #<play_no_music
			sta sfx_play.sfx_routine + 1
			
			lda #>play_no_music
			sta sfx_play.sfx_routine + 2
			rts
			
		!on:
			lda #<play_with_music
			sta sfx_play.sfx_routine + 1
			
			lda #>play_with_music
			sta sfx_play.sfx_routine + 2
			rts	
}

sfx_play:
{			
	sfx_routine:
			jmp play_with_music
}


//when sid is not playing, we can use any of the channels to play effects
play_no_music:
{			
			lda channels, x
			sta channel

			//lda channel
		//	cmp #3
		//	bne NoWrap

		//	lda #0
		//	sta channel
		//NoWrap:
			
			lda wavetable_l,x
			ldy wavetable_h,x
			ldx channel
			pha
			lda times7,x
			tax
			pla
			jmp sid.init + 6			
			

times7:
.fill 3, 7 * i			
}


play_with_music:
{
			lda wavetable_l,x
			ldy wavetable_h,x
			ldx #7 * 2
			jmp sid.init + 6
			rts
}


StopChannel0: {

	lda #0
	sta $d404

	rts


}




//effects must appear in order of priority, lowest priority first.

.label SFX_HIT_1 = 2
.label SFX_HIT_2 = 3
.label SFX_DIVE = 4
.label SFX_FIRE = 5
.label SFX_CH1 = 6
.label SFX_CH2 = 7
.label SFX_CH3 = 8
.label SFX_BADGE = 9


channels:	.byte 1, 1, 1, 1, 2, 0, 0, 1, 2, 0

sfx_hit1: .import binary "../../Assets/hit1.sfx"
sfx_hit2: .import binary "../../Assets/hit2.sfx"
sfx_hit3: .import binary "../../Assets/hit3.sfx"
sfx_hit4: .import binary "../../Assets/hit4.sfx"
sfx_dive: .import binary "../../Assets/dive.sfx"
sfx_ch1: .import binary "../../Assets/c1.sfx"
sfx_ch2: .import binary "../../Assets/c2.sfx"
sfx_ch3: .import binary "../../Assets/c3.sfx"

//.import binary "../../Assets/sfx/high_blip.sfx"

sfx_fire:
.import binary "../../Assets/fire2.sfx"

sfx_badge:
.import binary "../../Assets/badge.sfx"



wavetable_l:
.byte <sfx_hit3, <sfx_hit4, <sfx_hit1, <sfx_hit2, <sfx_dive, <sfx_fire, <sfx_ch1, <sfx_ch2, <sfx_ch3, <sfx_badge

wavetable_h:
.byte >sfx_hit3, >sfx_hit4, >sfx_hit1, >sfx_hit2, >sfx_dive, >sfx_fire, >sfx_ch1, >sfx_ch2,>sfx_ch3, >sfx_badge

