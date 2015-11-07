;Далее следуют все строки и всё, что выводится стрингами:
;

aMAP_MODE:	.BYTE 'MAPS',$68,$FF   ; DATA XREF: Draw_TitleScreen+C6t
					; Draw_TitleScreen+CAt
					; Часть	тайловой карты для надписи NAMCOT
aBattle:	.BYTE 'BATTLE',$FF      ; DATA XREF: Load_DemoLevel+36t
					; Load_DemoLevel+3At
					; Draw_TitleScreen+12t
					; Draw_TitleScreen+16t
aCity:		.BYTE 'CITY',$FF        ; DATA XREF: Load_DemoLevel+49t
					; Load_DemoLevel+4Dt
					; Draw_TitleScreen+25t
					; Draw_TitleScreen+29t
aK:		.BYTE $5E,$6B,$FF	; DATA XREF: Draw_TitleScreen+3At
					; Draw_TitleScreen+3Et
					; Для экрана подсчёта очков: 'I-'
a_k:		.BYTE $5F,$6B,$FF	; DATA XREF: Draw_TitleScreen+74t
					; Draw_TitleScreen+78t
					; Для экрана подсчёта очков: 'II-'
I_p:		.BYTE $58,$13,$FF	; DATA XREF: Draw_IPt Draw_IP+4t
					; надпись IP прямо над жизнями игроков
II_p:		.BYTE $5A,$13,$FF	; DATA XREF: Draw_IP:Draw_IIPt
					; Draw_IP+1Dt
					; надпись IIP прямо над	жизнями	игроков
aHik:		.BYTE 'HIk',$FF         ; DATA XREF: Draw_TitleScreen+55t
					; Draw_TitleScreen+59t
					; HI-
aHiscore:	.BYTE 'HISCORE',$FF     ; DATA XREF: Draw_Record_HiScore+18t
					; Draw_Record_HiScore+1Ct
					; Выводится в виде кирпичной надписи, если рекорд
aHikscore:	.BYTE 'HIkSCORE',$FF    ; DATA XREF: Draw_Pts_Screen_Template+2At
					; Draw_Pts_Screen_Template+2Et
					; k=тире
a1Player:	.BYTE '1 PLAYER',$FF    ; DATA XREF: Draw_TitleScreen+96t
					; Draw_TitleScreen+9At
a2Players:	.BYTE '2 PLAYERS',$FF   ; DATA XREF: Draw_TitleScreen+A5t
					; Draw_TitleScreen+A9t
aKplayer:	.BYTE '^kPLAYER',$FF    ; DATA XREF: Draw_Pts_Screen_Template+68t
					; Draw_Pts_Screen_Template+6Ct
					; 'I-PLAYER'
a_kplayer:	.BYTE '_kPLAYER',$FF    ; DATA XREF: Draw_Pts_Screen_Template+C6t
					; Draw_Pts_Screen_Template+CAt
					; 'II-PLAYER'
aConstruction:	.BYTE 'CONSTRUCTION',$FF ; DATA XREF: Draw_TitleScreen+B4t
					; Draw_TitleScreen+B8t
Copyrights:	.BYTE '@1985 NAMCO LTD',$64,' 2008 GRIEVER',$FF ; DATA XREF: Draw_TitleScreen+D5t
					; Draw_TitleScreen+D9t
					; Кстати, в начале РОМа	первая цифра не	1980 а 1981
aSite: 		.BYTE 'MAGICTEAM',$FF
PlayerLives_Icon:.BYTE $14,$FF		; DATA XREF: Draw_Player_Lives+At
					; Draw_Player_Lives+Et
					; Draw_Player_Lives:Draw_2P_Livest
					; Draw_Player_Lives+2Et
					; Значок жизней	игрока
aGame:		.BYTE 'GAME',$FF        ; DATA XREF: Draw_Brick_GameOver+18t
					; Draw_Brick_GameOver+1Ct
					; Выводится в виде кирпичной надписи на	весь экран
aOver:		.BYTE 'OVER',$FF        ; DATA XREF: Draw_Brick_GameOver+2Bt
					; Draw_Brick_GameOver+2Ft
aCongrats: .BYTE 'CONGRATS',$FF
aPts:		.BYTE 'PTS',$FF         ; DATA XREF: Draw_Pts_Screen+199t
					; Draw_Pts_Screen+19Dt
					; Draw_Pts_Screen+1F4t
					; Draw_Pts_Screen+1F8t
					; Draw_Pts_Screen_Template+120t
					; Draw_Pts_Screen_Template+124t
					; Draw_Pts_Screen_Template+12Ft
					; Draw_Pts_Screen_Template+133t
					; Draw_Pts_Screen_Template+13Et
					; Draw_Pts_Screen_Template+142t
					; Draw_Pts_Screen_Template+14Dt
					; Draw_Pts_Screen_Template+151t
					; Draw_Pts_Screen_Template+163t
					; Draw_Pts_Screen_Template+167t
					; Draw_Pts_Screen_Template+172t
					; Draw_Pts_Screen_Template+176t
					; Draw_Pts_Screen_Template+181t
					; Draw_Pts_Screen_Template+185t
					; Draw_Pts_Screen_Template+190t
					; Draw_Pts_Screen_Template+194t

aBoss:	.BYTE $60,$61,$62,$62,$11,$23,$24,$25,$26,$27,$11,$11,$FF; BOSS STAGE
aStageScr: .BYTE $23,$24,$25,$26,$27,$11,$11,$FF ; STAGE




Reinforcement_Icon:.BYTE $6A,$FF	; DATA XREF: ReinforceToRAM+3t
					; ReinforceToRAM+7t
					; Составляют лист оставшихся врагов
LevelFlag_Upper_Icons:.BYTE $6C,$FC,$FF	; DATA XREF: Draw_LevelFlag+3t
					; Draw_LevelFlag+7t
					; Флажок над номером уровня в правой части экрана
LevelFlag_Lower_Icons:.BYTE $6D,$FD,$FF	; DATA XREF: Draw_LevelFlag+12t
					; Draw_LevelFlag+16t
Empty_Tile:	.BYTE $11,$FF		; DATA XREF: Draw_EmptyTile+3t
					; Draw_EmptyTile+7t
					; Подменяет значок врага, когда	тот рождается

;! Стринги режимов карты:
MAP_MODE_STRINGS:
.WORD aOriginal
.WORD aRandom
.WORD aMixed

aOriginal: .BYTE 'ORIGINAL',$FF
aRandom:   .BYTE 'RANDOM  ',$FF
aMixed:    .BYTE 'MI',$65,'ED   ',$FF
aBack:	   .BYTE 'BACK FROM SOURCE',$FF





;Штаб отрисовывается стрингами
Normal_HQ_TSA:	.BYTE	0,  0,	0,  0,	0,  0,$FF
NormalLine2:	.BYTE	0, $F, $F, $F, $F,  0,$FF ; DATA XREF: DraW_Normal_HQ+Ft
					; DraW_Normal_HQ+13t
NormalLine3:	.BYTE	0, $F,$C8,$CA, $F,  0,$FF ; DATA XREF: DraW_Normal_HQ+1Et
					; DraW_Normal_HQ+22t
Normalline4:	.BYTE	0, $F,$C9,$CB, $F,  0,$FF ; DATA XREF: DraW_Normal_HQ+2Dt
					; DraW_Normal_HQ+31t
Armour_HQ_TSA_Line1:.BYTE   0,	0,  0,	0,  0,	0,$FF ;	DATA XREF: Draw_ArmourHQt
					; Draw_ArmourHQ+4t
Armour_HQ_TSA_Line2:.BYTE   0,$10,$10,$10,$10,	0,$FF ;	DATA XREF: Draw_ArmourHQ+Ft
					; Draw_ArmourHQ+13t
Armour_HQ_TSA_Line3:.BYTE   0,$10,$C8,$CA,$10,	0,$FF ;	DATA XREF: Draw_ArmourHQ+1Et
					; Draw_ArmourHQ+22t
Armour_HQ_TSA_Line4:.BYTE   0,$10,$C9,$CB,$10,	0,$FF ;	DATA XREF: Draw_ArmourHQ+2Dt
					; Draw_ArmourHQ+31t

Naked_HQ_TSA_FirstLine:.BYTE $C8,$CA,$FF ; DATA	XREF: Draw_Naked_HQt
					; Draw_Naked_HQ+4t
Naked_HQ_TSA_SecndLine:.BYTE $C9,$CB,$FF ; DATA	XREF: Draw_Naked_HQ+Ft
					; Draw_Naked_HQ+13t
DestroyedHQ_TSA_Line1:.BYTE $CC,$CE,$FF	; DATA XREF: Draw_Destroyed_HQt
					; Draw_Destroyed_HQ+4t
					; Draw_Destroyed_HQ+Ft
DestroyedHQ_TSA_Line2:.BYTE $CD,$CF,$FF	; DATA XREF: Draw_Destroyed_HQ+Ft
					; Draw_Destroyed_HQ+13t

Shovel_HQ_TSA_Line1:.BYTE   0,0,0,0,0,0,$FF ;	Рисуется после взятия врагом лопаты
					
Shovel_HQ_TSA_Line2:.BYTE   0,0,0,0,0,0,$FF 
					
Shovel_HQ_TSA_Line3:.BYTE   0,0,$C8,$CA,0,0,$FF 
					
Shovel_HQ_TSA_Line4:.BYTE   0,0,$C9,$CB,0,0,$FF 
					






Arrow_Left:	.BYTE $5B,$FF		; DATA XREF: Draw_Pts_Screen_Template+83t
					; Draw_Pts_Screen_Template+87t
					; Draw_Pts_Screen_Template+92t
					; Draw_Pts_Screen_Template+96t
					; Draw_Pts_Screen_Template+A1t
					; Draw_Pts_Screen_Template+A5t
					; Draw_Pts_Screen_Template+B0t
					; Draw_Pts_Screen_Template+B4t
Arrow_Right:	.BYTE $5D,$FF		; DATA XREF: Draw_Pts_Screen_Template+E1t
					; Draw_Pts_Screen_Template+E5t
					; Draw_Pts_Screen_Template+F0t
					; Draw_Pts_Screen_Template+F4t
					; Draw_Pts_Screen_Template+FFt
					; Draw_Pts_Screen_Template+103t
					; Draw_Pts_Screen_Template+10Et
					; Draw_Pts_Screen_Template+112t
					; Используются при подсчёте очков
aTotal:		.BYTE 'TOTAL',$FF       ; DATA XREF: Draw_Pts_Screen_Template+1B1t
					; Draw_Pts_Screen_Template+1B5t
aLine:		.BYTE $5C,$5C,$5C,$5C,$5C,$5C,$5C,$5C,$FF
					; DATA XREF: Draw_Pts_Screen_Template+1A2t
					; Draw_Pts_Screen_Template+1A6t
					; Полоска над 'TOTAL' при подсчёте очков
aBonus:		.BYTE 'BONUS',$15,$FF   ; DATA XREF: Draw_Pts_Screen+18At
					; Draw_Pts_Screen+18Et
					; Draw_Pts_Screen+1E5t
					; Draw_Pts_Screen+1E9t
					; Draw_Pts_Screen+1F4t
aStage:		.BYTE 'STAGE',$FF       ; DATA XREF: Draw_Pts_Screen_Template+45t
					; Draw_Pts_Screen_Template+49t