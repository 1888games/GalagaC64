
* = $c400 "Sprites" //Start at frame #16
 	.import binary "../../assets/spritepad/galaxian - sprites.bin"




* = $a800 "Sprites Source" //Start at frame #16
 	SPRITE_SOURCE: .import binary "../../assets/spritepad/galaga_ch - sprites.bin"


* = $7800 "Game Colours" 
	CHAR_COLORS: .import binary "../assets/charpad/galaga_D - CharAttribs.bin"


* = $f000 "Charset"

	CHAR_SET:
		.import binary "../assets/charpad/galaxian_W - Chars.bin"   //roll 12!

* = $5900 "Demo Map" 
MAP_DEMO: .import binary "../assets/charpad/galaga_D - Demo (8bpc, 20x13).bin"

* = $7400 "Game Map" 
MAP: .import binary "../assets/charpad/galaga_D - Game (8bpc, 20x13).bin"

* = $7504 "Game Tiles" 
MAP_TILES: .import binary "../assets/charpad/galaga_D - Tiles.bin"
	
* = $7900 "Logo"
LOGO:	.import binary "../assets/charpad/galax_logo.bin"


	.pc = sid.location "sid"
	.fill sid.size, sid.getData(i)