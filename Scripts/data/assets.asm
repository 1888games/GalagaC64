
* = $c400 "Sprites" //Start at frame #16
 	.import binary "../../assets/spritepad/galaga_2 - sprites.bin"




* = $a800 "Sprites Source" //Start at frame #16
 	SPRITE_SOURCE: .import binary "../../assets/spritepad/galaga_ch - sprites.bin"


* = $7800 "Game Colours" 
	CHAR_COLORS: .import binary "../assets/charpad/galaga_D - CharAttribs.bin"


* = $f000 "Charset"

	CHAR_SET:
		.import binary "../assets/charpad/galaga_D - Chars.bin"   //roll 12!

// The formation's in-between positions (FORMATION.SmoothChars): for each 2 pixel step
// (0 - 4) and animation frame, the 36 characters FORMATION.DefineBank copies over chars
// 86 - 121 (the title logo's, put back by RestoreLogoChars). Built here from the charset:
// each enemy's 2x2 chars shifted right across 3 cells (left, middle, right, top then
// bottom), then the cells two neighbours share, the left one's right part ORed with the
// right one's left part. Boss, butterfly and bee with their pairs come first, then the hit
// boss and its pairs with the boss, which DefineBank copies only while there's a hit boss.

.var charsetData = LoadBinary("../assets/charpad/galaga_D - Chars.bin")

// FORMATION.TypeCharStart for the types the formation can sway with: boss, hit boss,
// butterfly, bee. Each frame is 4 chars: top left, top right, bottom right, bottom left
.var smoothTypeChars = List().add(169, 161, 181, 189)
.var smoothBankTypes = List().add(0, 2, 3, 1)
.var smoothPairs = List().add(List().add(0, 0), List().add(2, 2), List().add(3, 3), List().add(0, 1), List().add(1, 0), List().add(1, 1))

.function SmoothCell(type, frame, step, bottom, cell, row) {
	.var base = smoothTypeChars.get(type) + frame * 4
	.var left = charsetData.uget((base + (bottom == 1 ? 3 : 0)) * 8 + row)
	.var right = charsetData.uget((base + (bottom == 1 ? 2 : 1)) * 8 + row)
	.var shifted = ((left << 16) | (right << 8)) >> (step * 2)
	.return (shifted >> ((2 - cell) * 8)) & $ff
}

* = $e4c0 "Smooth Formation Chars"

SMOOTH_CHARS:
	.for (var step = 0; step < 5; step++) {
		.for (var frame = 0; frame < 2; frame++) {
			.for (var group = 0; group < 2; group++) {
				.for (var t = group * 3; t < 3 + group; t++) {
					.for (var bottom = 0; bottom < 2; bottom++) {
						.for (var cell = 0; cell < 3; cell++) {
							.for (var row = 0; row < 8; row++) {
								.byte SmoothCell(smoothBankTypes.get(t), frame, step, bottom, cell, row)
							}
						}
					}
				}
				.for (var p = group * 3; p < group * 3 + 3; p++) {
					.for (var bottom = 0; bottom < 2; bottom++) {
						.for (var row = 0; row < 8; row++) {
							.byte SmoothCell(smoothPairs.get(p).get(0), frame, step, bottom, 2, row) | SmoothCell(smoothPairs.get(p).get(1), frame, step, bottom, 0, row)
						}
					}
				}
			}
		}
	}

.errorif * > $f000, "the smooth formation chars run into the charset"

* = $5900 "Demo Map"
MAP_DEMO: .import binary "../assets/charpad/galaga_D - Demo (8bpc, 20x13).bin"

* = $7400 "Game Map" 
MAP: .import binary "../assets/charpad/galaga_D - Game (8bpc, 20x13).bin"

* = $7504 "Game Tiles" 
MAP_TILES: .import binary "../assets/charpad/galaga_D - Tiles.bin"
	
* = $7900 "Logo"
LOGO:	.import binary "../assets/charpad/galaga_logo.bin"


	.pc = sid.location "sid"
	.fill sid.size, sid.getData(i)