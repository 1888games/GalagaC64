// The arcade difficulty's endgame: once ARCADE.EndgameLeft enemies or fewer are left, they
// stop going home and keep diving
ENDGAME: {

	* = $7080 "Endgame"

	.errorif * > $7200, "ENDGAME runs into the smooth formation tables"
}
