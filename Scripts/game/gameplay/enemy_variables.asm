.namespace ENEMY {

	* = * "Enemy Variables"

	Angle:					.fill MAX_ENEMIES, 0

	PixelSpeedX:			.fill MAX_ENEMIES, 0
	PixelSpeedY:			.fill MAX_ENEMIES, 0
	FractionSpeedX:			.fill MAX_ENEMIES, 0
	FractionSpeedY:			.fill MAX_ENEMIES, 0

	ExplosionTimer:			.fill MAX_ENEMIES, 0
	PositionInPath:			.fill MAX_ENEMIES, 0
		
	ExplosionProgress:		.fill MAX_ENEMIES, 0
	Side:					.fill MAX_ENEMIES, 0
	
	BasePointer:			.fill MAX_ENEMIES, 0

	* = * "Plan"
	
	Plan:					.fill MAX_ENEMIES, 0
	NextPlan:				.fill MAX_ENEMIES, 0
	PreviousMoveX:			.fill MAX_ENEMIES, 0
	Slot:					.fill MAX_ENEMIES, 0
	HitsLeft:				.fill MAX_ENEMIES, 0

	* = * "Extra"
	IsExtraEnemy:			.fill MAX_ENEMIES, 0

	UltimateTargetSpriteY:	.fill MAX_ENEMIES, 0



	Quadrant:			.byte 0

	* = * "Enemies In Wave"
	EnemiesInWave:		.byte 8
	FormationUpdated:	.byte 0
	EnemiesAlive:		.byte 0
	MoveX:				.byte 0
	MoveY:				.byte 0

	* = * "Enemy Ship ID"
	EnemyWithShipID:	.byte 0
	NextSpawnValue:		.byte 0
	AddingFighter:		.byte 0


	FlutterMoveX_Min:	.byte 30, 30
	FlutterMoveX_Max:	.byte 125, 50
	FlutterMoveY:		.byte 30, 40

	FlutterMode:		.byte 0

	EnemyTypeSFX:		.byte 0, 0, 1, 2, 1, 10

	ChallengeBonusLookup:	.byte 9, 9, 10, 10, 11, 11, 12, 12
	BonusSpriteLookup:		.byte 2, 2, 3, 3, 4, 4, 5, 5
	TransformSpriteLookup:	.byte 2, 5, 6



}