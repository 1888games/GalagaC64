
.label ZERO= 					0
.label FALSE = 					0	
.label ALL_ON = 				255
.label ONE=						1
.label TRUE = 					1



.label PAL = 					0
.label NTSC =	 				1

.label GAME_MAP =				0


.label PROCESSOR_PORT = 		$01
.label INTERRUPT_VECTOR = 		$fffe
.label JOY_PORT_2 = 			$dc00

.label SCREEN_RAM = 			$c000
.label SPRITE_POINTERS = SCREEN_RAM + $3f8


.label IRQControlRegister1 = 	$dc0d
.label IRQControlRegister2 = 	$dd0d


.label WHITE_MULT = 9
.label RED_MULT = 10
.label CYAN_MULT = 11
.label PURPLE_MULT = 12
.label GREEN_MULT = 13
.label BLUE_MULT = 14
.label YELLOW_MULT = 15

.label GAME_OVER_MSG = 0    
.label GAME_OVER_STATS = 1

    
.label SUBTUNE_START = 0
.label SUBTUNE_GAME_OVER = 1
.label SUBTUNE_CHALLENGING = 2
.label SUBTUNE_PERFECT = 3
.label SUBTUNE_HI_SCORE = 4
.label SUBTUNE_BLANK = 5
.label SUBTUNE_CAPTURE = 6
.label SUBTUNE_RECAPTURE = 7
.label SUBTUNE_DANGER = 8
.label SUBTUNE_BEAM = 11
.label SUBTUNE_BEAM_CAPTURE = 10


.label FORMATION_UNISON = 0
.label FORMATION_SPREAD = 1
.label FORMATION_PAUSE = 255

.label MAX_BOMBS = 6
.label MAX_ENEMIES = 12


.label ENEMY_BOSS = 0
.label ENEMY_BOSS_HIT = 1
.label ENEMY_MOTH = 2
.label ENEMY_HORNET = 3
.label ENEMY_DRAGONFLY = 4
.label ENEMY_TRANSFORM = 4
.label ENEMY_FIGHTER = 5


.label DEG_0 = 0
.label DEG_30 = 1
.label DEG_60 = 2
.label DEG_90 = 3
.label DEG_120 = 4
.label DEG_150 = 5
.label DEG_180 = 6
.label DEG_210 = 7
.label DEG_240 = 8
.label DEG_270 = 9
.label DEG_300 = 10
.label DEG_330 = 11
.label END_WAVE= 255

.label LEFT = 0
.label RIGHT = 1
.label DOWN = 1
.label UP = 0


.label TOP_RIGHT = 0
.label BOTTOM_RIGHT = 1
.label BOTTOM_LEFT = 2
.label TOP_LEFT = 3


.label GAME_MODE_TITLE = 0
.label GAME_MODE_PRE_STAGE = 1
.label GAME_MODE_ATTRACT = 2
.label GAME_MODE_PLAY = 3
.label GAME_MODE_OVER = 4
.label GAME_MODE_SWITCH_TITLE = 5
.label GAME_MODE_CHALLENGE = 6
.label GAME_MODE_SCORE = 7
.label GAME_MODE_DEMO = 8

.label CHALLENGING_STAGE = 3

.label CHALLENGE_NUM_HITS = 1
.label CHALLENGE_PERFECT = 2
.label CHALLENGE_SPECIAL = 3
.label CHALLENGE_BONUS_TITLE = 4
.label CHALLENGE_BONUS = 5
.label CHALLENGE_EXIT = 6

.label BEAM_OFF						    =	0
.label BEAM_BOSS_SELECTED			    =	1
.label BEAM_POSITION					=	2
.label BEAM_OPENING					    =	3
.label BEAM_HOLD						=	4
.label BEAM_CLOSING						=   5
.label BEAM_RECAPTURE                   =   6
.label BEAM_DOCKED                      =   7
.label BEAM_ORPHANED                    = 8 


.label  CAPTURE_PLAYER_SPIN              = 0
.label  CAPTURE_PLAYER_HOLD             = 1
.label  CAPTURE_PLAYER_MSG              = 2
.label  CAPTURE_PLAYER_TURN             = 3
.label  CAPTURE_PLAYER_DRAG              = 4
.label  CAPTURE_PLAYER_DOCK             = 5
.label  CAPTURE_PLAYER_DOCKED             = 6
.label  CAPTURE_PLAYER_ATTACK            = 7


.label RECAPTURE_PLAYER_SPIN            = 8
.label RECAPTURE_PLAYER_MOVE_X          = 9 
.label RECAPTURE_PLAYER_MOVE_Y          = 10


.label PLAN_INACTIVE					=	0
.label PLAN_INIT						=	1
.label PLAN_ALIVE						=	2
.label PLAN_PATH						=	3
.label PLAN_GOTO_GRID					=	4
.label PLAN_ORIENT						=	5
.label PLAN_GRID						=	6
.label PLAN_DIVE_AWAY_LAUNCH			=	7
.label PLAN_DIVE_AWAY					=	8
.label PLAN_DIVE_ATTACK					=	9
.label PLAN_DESCEND						=	10
.label PLAN_HOME_OR_FULL_CIRCLE			=	11
.label PLAN_FLUTTER						=	12
.label PLAN_GOTO_BEAM					=	13
.label PLAN_BEAM_ACTION					=	14
.label PLAN_EXPLODE 					=   15
.label PLAN_ATTACK  					=   16
.label PLAN_RETURN_GRID                 =   17
.label PLAN_RETURN_GRID_TOP             =   18
.label PLAN_WAIT_BEAM                   =   19
.label PLAN_BOSS_TURN                   =   20
.label PLAN_FLY_OFF                     =   21
.label PLAN_BOSS_HOME                    =   22
.label PLAN_BOSS_ATTACK                 =   23
.label PLAN_BOSS_HELD = 24
.label PLAN_TRANSFORM = 25



 .label PATH_TOP_SINGLE				=0
 .label PATH_TOP_SINGLE_MIR			=1
 .label PATH_TOP_DOUBLE_LEFT			=2
 .label PATH_TOP_DOUBLE_LEFT_MIR		=3
 .label PATH_TOP_DOUBLE_RIGHT			=4
 .label PATH_TOP_DOUBLE_RIGHT_MIR		=5
 .label PATH_BOTTOM_SINGLE			=6
 .label PATH_BOTTOM_SINGLE_MIR		=7
 .label PATH_BOTTOM_DOUBLE_OUT		=8
.label  PATH_BOTTOM_DOUBLE_OUT_MIR	=9
 .label PATH_BOTTOM_DOUBLE_IN			=10
.label  PATH_BOTTOM_DOUBLE_IN_MIR		=11
 .label PATH_CHALLANGE_1_1			=12
 .label PATH_CHALLANGE_1_1_MIR		=13
 .label PATH_CHALLANGE_1_2			=14
 .label PATH_CHALLANGE_1_2_MIR		=15
 .label PATH_CHALLANGE_2_1			=16
 .label PATH_CHALLANGE_2_1_MIR		=17
 .label PATH_CHALLANGE_2_2			=18
 .label PATH_CHALLANGE_2_2_MIR		=19
 .label PATH_CHALLANGE_3_1			=20
 .label PATH_CHALLANGE_3_1_MIR		=21
 .label PATH_CHALLANGE_3_2			=22
 .label PATH_CHALLANGE_3_2_MIR		=23
 .label PATH_LAUNCH					=24
 .label PATH_LAUNCH_MIR				=25
 .label PATH_BEE_ATTACK				=26
 .label PATH_BEE_ATTACK_MIR			=27
 .label PATH_BEE_BOTTOM_CIRCLE		=28
 .label PATH_BEE_BOTTOM_CIRCLE_MIR	=29
 .label PATH_BEE_TOP_CIRCLE			=30
 .label PATH_BEE_TOP_CIRCLE_MIR		=31
 .label PATH_BUTTERFLY_ATTACK			=32
 .label PATH_BUTTERFLY_ATTACK_MIR		=33
 .label PATH_BOSS_TURN_HOME = 34
 .label PATH_BOSS_TURN_HOME_MIR = 35
 .label PATH_BOSS_ATTACK = 36
 .label PATH_BOSS_ATTACK_MIR = 37
 .label PATH_FLUTTER = 38
 .label PATH_FLUTTER_MIR = 39
 .label PATH_TRANSFORM_1 = 40
.label PATH_TRANSFORM_1_MIR = 41


.label SCORE_BEE_FORMATION = 0
.label SCORE_BEE_DIVING = 1
.label SCORE_MOTH_FORMATION = 2
.label SCORE_MOTH_DIVING = 3
.label SCORE_BOSS_FORMATION = 4
.label SCORE_BOSS_DIVING_ALONE = 5
.label SCORE_BOSS_DIVING_1_ESCORT = 6
.label SCORE_BOSS_DIVING_2_ESCORT = 7
.label SCORE_CAPTURED_FIGHTER = 8
.label SCORE_CHALLENGE_GROUP_1_2 = 9
.label SCORE_CHALLENGE_GROUP_3_4 = 10
.label SCORE_CHALLENGE_GROUP_5_6 = 11
.label SCORE_CHALLENGE_GROUP_7_P = 12
.label SCORE_TRANSFORM = 13
.label SCORE_ALL_SCORPIONS = 14
.label SCORE_ALL_BOSCONIANS = 15
.label SCORE_ALL_GALAXIANS = 16
.label SCORE_CHALLENGE_BONUS= 17