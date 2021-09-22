
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
allow_channel_1: .byte 1



play_background: {

	lda FORMATION.Mode
	bne PlayBack

	lda #SUBTUNE_BLANK
	jmp Play

	PlayBack:

	lda #SUBTUNE_DANGER


	Play:

	jsr sid.init
	lda #1
	sta allow_channel_1


	rts
}

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

			bne NoOneCheck

			lda allow_channel_1
			bne NoOneCheck

			inc channel

			NoOneCheck:
			
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
.label SFX_COIN = 10
.label SFX_EXTRA = 11
.label SFX_DEAD = 12
.label SFX_TRANSFORM = 13

channels:	.byte 1, 1, 1, 1, 0, 2, 0, 1, 2, 0, 1, 0, 0, 0

sfx_hit1: .import binary "../../Assets/goattracker/hit1.sfx"
sfx_hit2: .import binary "../../Assets/goattracker/hit2.sfx"
sfx_hit3: .import binary "../../Assets/goattracker/hit3.sfx"
sfx_hit4: .import binary "../../Assets/goattracker/hit4.sfx"
sfx_dive: .import binary "../../Assets/goattracker/dive.sfx"
sfx_fire: .import binary "../../Assets/goattracker/fire4.sfx"

sfx_ch1: .import binary "../../Assets/goattracker/c1.sfx"
sfx_ch2: .import binary "../../Assets/goattracker/c2.sfx"
sfx_ch3: .import binary "../../Assets/goattracker/c3.sfx"
sfx_badge: .import binary "../../Assets/goattracker/badge.sfx"
sfx_coin: .import binary "../../Assets/goattracker/coin.sfx"
sfx_extra: .import binary "../../Assets/goattracker/extra.sfx"
sfx_dead: .import binary "../../Assets/goattracker/dead2.sfx"
sfx_transform: .import binary "../../Assets/goattracker/transform.sfx"

//.import binary "../../Assets/sfx/high_blip.sfx"








wavetable_l:
.byte <sfx_hit3, <sfx_hit4, <sfx_hit1, <sfx_hit2, <sfx_dive, <sfx_fire, <sfx_ch1, <sfx_ch2, <sfx_ch3, <sfx_badge, <sfx_coin, <sfx_extra, <sfx_dead, <sfx_transform

wavetable_h:
.byte >sfx_hit3, >sfx_hit4, >sfx_hit1, >sfx_hit2, >sfx_dive, >sfx_fire, >sfx_ch1, >sfx_ch2,>sfx_ch3, >sfx_badge, >sfx_coin, >sfx_extra, >sfx_dead, >sfx_transform

