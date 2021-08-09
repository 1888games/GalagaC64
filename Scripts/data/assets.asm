
* = $c400 "Sprites" //Start at frame #16
 	.import binary "../../assets/galaga_2 - sprites.bin"




* = $a800 "Sprites Source" //Start at frame #16
 	SPRITE_SOURCE: .import binary "../../assets/galaga_ch - sprites.bin"


* = $7700 "Game Colours" 
	CHAR_COLORS: .import binary "../assets/galaga - CharAttribs.bin"


* = $f000 "Charset"

	CHAR_SET:
		.import binary "../assets/galaga - Chars.bin"   //roll 12!



* = $7400 "Game Map" 
MAP: .import binary "../assets/galaga - MapArea (8bpc, 20x13).bin"

* = $7504 "Game Tiles" 
MAP_TILES: .import binary "../assets/galaga - Tiles.bin"
	
* = $7800 "Logo"
LOGO:	.import binary "../assets/galaga_logo.bin"


	.pc = sid.location "sid"
	.fill sid.size, sid.getData(i)