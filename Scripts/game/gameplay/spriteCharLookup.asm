* = $fd00 "SpriteCharLookup"

.label remove = 24

SpriteXToChar: 		.fill 256, round((i - 21)/8)
SpriteXToOffset:	.fill 256, (i - 25) - (floor((i - 25)/8) * 8)