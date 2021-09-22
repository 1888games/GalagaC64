
* = $c400 "Sprites" //Start at frame #16
 	.import binary "../../assets/galaga_2 - sprites.bin"




* = $a800 "Sprites Source" //Start at frame #16
 	SPRITE_SOURCE: .import binary "../../assets/galaga_ch - sprites.bin"


* = $7800 "Game Colours" 
	CHAR_COLORS: .import binary "../assets/galaga_D - CharAttribs.bin"


* = $f000 "Charset"

	CHAR_SET:
		.import binary "../assets/galaga_D - Chars.bin"   //roll 12!

* = $5900 "Demo Map" 
MAP_DEMO: .import binary "../assets/galaga_D - Demo (8bpc, 20x13).bin"

* = $7400 "Game Map" 
MAP: .import binary "../assets/galaga_D - Game (8bpc, 20x13).bin"

* = $7504 "Game Tiles" 
MAP_TILES: .import binary "../assets/galaga_D - Tiles.bin"
	
* = $7900 "Logo"
LOGO:	.import binary "../assets/galaga_logo.bin"


	.pc = sid.location "sid"
	.fill sid.size, sid.getData(i)