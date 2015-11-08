		;.segment RAM
;Здесь описаны все переменные, используемые в игре

Enum 0

Temp:		.BYTE 0	; (uninited)	; DATA XREF: SetUp_LevelVARs+6Fw
					; SetUp_LevelVARs+74r
					; Draw_RespawnPic:+w
					; Draw_RespawnPic+18r
					; Draw_Player_Lives+50w
					; Draw_Player_Lives+54r
					; Get_Random_A+11r
					; CoordTo_PPUaddress+2w
					; CoordTo_PPUaddress+6w
					; CoordTo_PPUaddress+9w
					; CoordTo_PPUaddress+Cw
					; CoordTo_PPUaddress+10r
					; TSA_Pal_Ops+33w TSA_Pal_Ops+39r
					; Read_Joypads:--w Read_Joypads+15w
					; Read_Joypads+1Er Read_Joypads+22r
					; Temp_Coord_shl+2w Temp_Coord_shl+Aw
					; Temp_Coord_shl+Cw Temp_Coord_shl+14w
					; Check_Objectr Draw_Destroyed_Brickr
					; NT_Buffer_Process_XOR+6r ROM:D75Cr
					; NT_Buffer_Process_OR+6r
					; Draw_TSABlock+1w Draw_TSABlock+Ar
					; Num_To_NumStringw
					; Num_To_NumString+7r
					; Num_To_NumString+Fr
					; ByteTo_Num_Stringw
					; ByteTo_Num_String+7r	Ice_Move+2Dw
					; Ice_Move+56r	Ice_Move+5Cr
					; Ice_Move:+++r Set_SprIndex+7w
					; Set_SprIndex+13r
					; Rise_TankStatus_Bitw
					; Rise_TankStatus_Bit+6r
					; Multiply_Bonus_Coordw
					; Multiply_Bonus_Coord+4r
					; BulletToBullet_Impact_Handle+1Dw
					; BulletToBullet_Impact_Handle+23r
					; Load_Level:Beginw Load_Level:-w
byte_1:		.BYTE 0	; (uninited)
CHR_Byte:	.BYTE 0	; (uninited)
Mask_CHR_Byte:	.BYTE 0	; (uninited)
TSA_Pal:	.BYTE 0	; (uninited)
PPU_Addr_Ptr:	.BYTE 0	; (uninited)
Joypad1_Buttons:.BYTE 0	; (uninited)	; DATA XREF: ROM:Skip_Status_Handler
					; ROM:loc_C13Er ROM:C185r ROM:C1AAr
					; FreezePlayer_OnHQDestroy+8w
					; Demo_AI+6Bw Move_Tankr
					; Move_Tank+2Dr Title_Screen_Loop:++r
					; Title_Screen_Loop:+++r
					; Read_Joypads+1Ar Read_Joypads+24w
					; Detect_Motionr Ice_Move:++++r
Joypad2_Buttons:.BYTE 0	; (uninited)
Joypad1_Differ:	.BYTE 0	; (uninited)	; DATA XREF: ROM:C102r	ROM:loc_C120r
					; ROM:Construct_StartCheckr ROM:C179r
					; ROM:C17Fr ROM:Check_Br ROM:C20Cr
					; FreezePlayer_OnHQDestroy+Cw
					; BonusLevel_ButtonCheck+3r
					; Draw_Brick_GameOver+4Er Demo_AI+6Dw
					; Demo_AI+75r Demo_AI+79w
					; Move_Tank+19r Move_Tank+1Fr
					; ROM:C789r ROM:loc_C792r
					; ROM:loc_C79Br Scroll_TitleScrn+Br
					; Title_Screen_Loop+38r
					; Title_Screen_Loop:Start_Checkr
					; Read_Joypads+20w Make_Player_Shot+Er
Joypad2_Differ:	.BYTE 0	; (uninited)
;1 = A
;2 = B
;4 = SELECT
;8 = START
;10 = UP
;20 = DOWN
;40 = LEFT
;80 = RIGHT
;
Seconds_Counter:.BYTE 0	; (uninited)
Frame_Counter:	.BYTE 0	; (uninited)
ScrBuffer_Pos:	.BYTE 0	; (uninited)
SprBuffer_Position:.BYTE 0 ; (uninited)
Gap:		.BYTE 0	; (uninited)
Random_Lo:	.BYTE 0	; (uninited)
Random_Hi:	.BYTE 0	; (uninited)
LowPtr_Byte:	.BYTE 0	; (uninited)	; DATA XREF: Show_Secret_Msg+22w
					; Show_Secret_Msg+34w
					; Show_Secret_Msg+46w
					; Show_Secret_Msg+58w
					; Show_Secret_Msg+6Aw
					; Show_Secret_Msg+7Cw
					; Show_Secret_Msg+8Ew
					; Show_Secret_Msg+A0w
					; Show_Secret_Msg+B2w ROM:C765w
					; ROM:C77Cw Draw_Player_Lives+10w
					; Draw_Player_Lives+30w Draw_IP+6w
					; Draw_IP+1Fw Draw_LevelFlag+9w
					; Draw_LevelFlag+18w ReinforceToRAM+9w
					; Draw_EmptyTile+9w
					; Title_Screen_Loop+9Fw
					; Title_Screen_Loop+A6r
					; DraW_Normal_HQ+6w DraW_Normal_HQ+15w
					; DraW_Normal_HQ+24w
					; DraW_Normal_HQ+33w Draw_Naked_HQ+6w
					; Draw_Naked_HQ+15w Draw_ArmourHQ+6w
					; Draw_ArmourHQ+15w Draw_ArmourHQ+24w
					; Draw_ArmourHQ+33w
					; Draw_Destroyed_HQ+6w
					; Draw_Destroyed_HQ+15w
					; Copy_AttribToScrnBuff+8w
					; Copy_AttribToScrnBuff+15r
					; FillScr_Single_Row+7w
					; FillScr_Single_Row+14r
					; FillScr_Single_Row+20r
					; Draw_Pts_Screen+190w
					; Draw_Pts_Screen+19Fw
					; Draw_Pts_Screen+1EBw
					; Draw_Pts_Screen+1FAw
					; Draw_Pts_Screen_Template+30w
					; Draw_Pts_Screen_Template+4Bw
					; Draw_Pts_Screen_Template+6Ew
					; Draw_Pts_Screen_Template+89w
					; Draw_Pts_Screen_Template+98w
					; Draw_Pts_Screen_Template+A7w
					; Draw_Pts_Screen_Template+B6w
					; Draw_Pts_Screen_Template+CCw
					; Draw_Pts_Screen_Template+E7w
					; Draw_Pts_Screen_Template+F6w
					; Draw_Pts_Screen_Template+105w
					; Draw_Pts_Screen_Template+114w
					; Draw_Pts_Screen_Template+126w
					; Draw_Pts_Screen_Template+135w
					; Draw_Pts_Screen_Template+144w
					; Draw_Pts_Screen_Template+153w
					; Draw_Pts_Screen_Template+169w
					; Draw_Pts_Screen_Template+178w
					; Draw_Pts_Screen_Template+187w
					; Draw_Pts_Screen_Template+196w
					; Draw_Pts_Screen_Template+1A8w
					; Draw_Pts_Screen_Template+1B7w
					; Draw_TitleScreen+40w
					; Draw_TitleScreen+5Bw
					; Draw_TitleScreen+7Aw
					; Draw_TitleScreen+9Cw
					; Draw_TitleScreen+ABw
					; Draw_TitleScreen+BAw
					; Draw_TitleScreen+CCw
					; Draw_TitleScreen+DBw
					; Draw_TitleScreen+EDw
					; String_to_Screen_Buffer:-r
					; Save_Str_To_ScrBuffer:-r
					; CoordsToRAMPos+5w Check_Object+4r
					; Draw_Destroyed_Brick+4r
					; NT_Buffer_Process_XORr
					; NT_Buffer_Process_XOR+Ar
					; NT_Buffer_Process_XOR+Cw
					; NT_Buffer_Process_ORr
					; NT_Buffer_Process_OR+8r
					; NT_Buffer_Process_OR+Aw
					; Save_to_VRAM+8r Save_to_VRAM+Dr
					; Draw_Tilew Draw_Tile+Fr
					; Draw_Tile+15r Inc_Ptr_on_A+1r
					; Inc_Ptr_on_A+3w
					; Store_NT_Buffer_InVRAM+2w
					; Draw_GrayFrame+26w
					; Draw_GrayFrame+2Dw Draw_Char+Bw
					; Draw_Char+21r
					; PtrToNonzeroStrElem+1Aw
					; SaveSprTo_SprBuffer+10r
					; Status_Core+Bw ...
HighPtr_Byte:	.BYTE 0	; (uninited)	; DATA XREF: Show_Secret_Msg+1Ew
					; Show_Secret_Msg+30w
					; Show_Secret_Msg+42w
					; Show_Secret_Msg+54w
					; Show_Secret_Msg+66w
					; Show_Secret_Msg+78w
					; Show_Secret_Msg+8Aw
					; Show_Secret_Msg+9Cw
					; Show_Secret_Msg+AEw ROM:C761w
					; ROM:C778w Draw_Player_Lives+Cw
					; Draw_Player_Lives+2Cw Draw_IP+2w
					; Draw_IP+1Bw Draw_LevelFlag+5w
					; Draw_LevelFlag+14w ReinforceToRAM+5w
					; Draw_EmptyTile+5w
					; Title_Screen_Loop+A4w
					; DraW_Normal_HQ+2w DraW_Normal_HQ+11w
					; DraW_Normal_HQ+20w
					; DraW_Normal_HQ+2Fw Draw_Naked_HQ+2w
					; Draw_Naked_HQ+11w Draw_ArmourHQ+2w
					; Draw_ArmourHQ+11w Draw_ArmourHQ+20w
					; Draw_ArmourHQ+2Fw
					; Draw_Destroyed_HQ+2w
					; Draw_Destroyed_HQ+11w
					; Copy_AttribToScrnBuff+4w
					; Copy_AttribToScrnBuff+Fr
					; FillScr_Single_Row+5w
					; FillScr_Single_Row+Br
					; Draw_Pts_Screen+18Cw
					; Draw_Pts_Screen+19Bw
					; Draw_Pts_Screen+1E7w
					; Draw_Pts_Screen+1F6w
					; Draw_Pts_Screen_Template+2Cw
					; Draw_Pts_Screen_Template+47w
					; Draw_Pts_Screen_Template+6Aw
					; Draw_Pts_Screen_Template+85w
					; Draw_Pts_Screen_Template+94w
					; Draw_Pts_Screen_Template+A3w
					; Draw_Pts_Screen_Template+B2w
					; Draw_Pts_Screen_Template+C8w
					; Draw_Pts_Screen_Template+E3w
					; Draw_Pts_Screen_Template+F2w
					; Draw_Pts_Screen_Template+101w
					; Draw_Pts_Screen_Template+110w
					; Draw_Pts_Screen_Template+122w
					; Draw_Pts_Screen_Template+131w
					; Draw_Pts_Screen_Template+140w
					; Draw_Pts_Screen_Template+14Fw
					; Draw_Pts_Screen_Template+165w
					; Draw_Pts_Screen_Template+174w
					; Draw_Pts_Screen_Template+183w
					; Draw_Pts_Screen_Template+192w
					; Draw_Pts_Screen_Template+1A4w
					; Draw_Pts_Screen_Template+1B3w
					; Draw_TitleScreen+3Cw
					; Draw_TitleScreen+57w
					; Draw_TitleScreen+76w
					; Draw_TitleScreen+98w
					; Draw_TitleScreen+A7w
					; Draw_TitleScreen+B6w
					; Draw_TitleScreen+C8w
					; Draw_TitleScreen+D7w
					; Draw_TitleScreen+E9w
					; CoordsToRAMPos+3w Save_to_VRAMr
					; Draw_Tile+6r	Inc_Ptr_on_A+7w
					; Store_NT_Buffer_InVRAM+7w
					; Store_NT_Buffer_InVRAM+11r
					; Draw_GrayFrame+24w Draw_Char+Fw
					; Draw_Char:+r	PtrToNonzeroStrElem+18w
					; Status_Core+10w
					; SingleTankStatus_Handle+10w
					; BulletStatus_Handle+10w
					; Draw_BulletGFX+10w Ice_Detect+23r
					; HideHiBit_Under_Tank+18w
					; HQ_Handle+57w Bonus_Handle+64w
					; Load_Level+14w Load_Level+2Er
LowStrPtr_Byte:	.BYTE 0	; (uninited)	; DATA XREF: Load_DemoLevel+3Cw
					; Load_DemoLevel+4Fw
					; Draw_Record_HiScore+1Ew
					; Draw_Brick_GameOver+1Ew
					; Draw_Brick_GameOver+31w
					; Draw_TitleScreen+18w
					; Draw_TitleScreen+2Bw
					; String_to_Screen_Buffer+13w
					; String_to_Screen_Buffer+21w
					; Draw_BrickStr:New_Charr
					; Draw_RecordDigit+22w	Load_Level+2Cw
					; Load_Level+47r Load_Level:++r
HighStrPtr_Byte:.BYTE 0	; (uninited)
HiScore_1P_String:.BYTE	0,0,0,0,0,0,0,0	; (uninited) ; DATA XREF: Null_both_HiScoreo
					; Reset_ScreenStuff+21o
					; Update_HiScore:loc_D981r
					; Update_HiScore:loc_D993r
					; Add_Score+Er	Add_Score:++w
					; Draw_Pts_Screen:+++o
					; Draw_Pts_Screen+172o
					; Draw_Pts_Screen_Template+77o
HiScore_2P_String:.BYTE	0,0,0,0,0,0,0,0	; (uninited) ; DATA XREF: Null_both_HiScore+5o
					; Reset_ScreenStuff+26o
					; Update_HiScore:loc_D9A0r
					; Update_HiScore:loc_D9B2r
					; Draw_Pts_Screen+C9o
					; Draw_Pts_Screen+1CDo
					; Draw_Pts_Screen_Template+D5o
;В формате строки Scr_Buffer: на конце $FF
;

Temp_1PPts_String:.BYTE	0,0,0,0,0,0,0,0	; (uninited) ; DATA XREF: Draw_Pts_Screen+2Co
					; Draw_Pts_Screen+98o
					; Строка при подсчете очков за текущий вид танка
Temp_2PPts_String:.BYTE	0,0,0,0,0,0,0,0	; (uninited) ; DATA XREF: Draw_Pts_Screen+31o
					; Draw_Pts_Screen+D7o
Num_String:	.BYTE 0,0,0,0,0,0,0,0 ;	(uninited) ; DATA XREF:	Add_Score:-r
					; Num_To_NumString+2o
					; ByteTo_Num_String+2o
					; Draw_StageNumString+53o
					; Draw_Pts_Screen+B3o
					; Draw_Pts_Screen+F2o
					; Draw_Pts_Screen+12Ao
					; Draw_Pts_Screen+13Fo
					; Draw_Pts_Screen+17Eo
					; Draw_Pts_Screen+1D9o
					; Draw_Pts_Screen_Template+59o
;Числовая строка. Используется для вывода на экран чисел в формате строки (на конце $FF): номера уровней, жизни	и т.п.
;Число хранится	в Little Endian	формате
;
HiScore_String:	.BYTE 0,0,0,0,0,0,0,0 ;	(uninited) ; DATA XREF:	Reset_ScreenStuff+30o
					; Draw_RecordDigit+Co
					; Update_HiScore+6r Update_HiScore+18w
					; Update_HiScore+25r
					; Update_HiScore+37w
					; Draw_Pts_Screen_Template+39o
;В формате строки Scr_Buffer: на конце $FF
;
HQArmour_Timer:	.BYTE 0	; (uninited)	; Таймер брони вокруг штаба
Level_Mode:	.BYTE 0	; (uninited)
;0 = обычный режим
;1 = усложнённый режим - выставляется, если уровни
;начинают проходиться по 2-му кругу (после 35-го).
;(если по третьему, то режим снова становится обычным (выставляется в ноль))
;2 = режим демо	уровня - надпись
;Game Over не отображается, не обрабатывается
;положение 1 или 2 игрока - в демо уровне их
;всегда	два, не	прибавляются очки.
;Нет мигания от	Friendly Fire


Spr_X:		.BYTE 0	; (uninited)
Spr_Y:		.BYTE 0	; (uninited)
Tank_Num:	.BYTE 0	; (uninited)	; Номер	танка игрока, при обработке взятия бонуса
Joy_Counter:	.BYTE 0	; (uninited)
Construction_Flag:.BYTE	0 ; (uninited)	; Выставляется,	если зашли в Construction
;Если <>0, то:
;-Демо-ролик не	будет показываться
;-Данные уровня	загружаться не будут (только танки и голый штаб)
;А в Construction вообще ничего	не будет загружаться
;Может использоваться как счетчик (при выводе секретного сообщения)

EnterGame_Flag:	.BYTE 0	; (uninited)	; Если 0, то можно выбрать уровень
;Если <>0, то после предыдущего	сразу начинается следующий уровень
;
BkgPal_Number:	.BYTE 0	; (uninited)
;0= PaletteFrame2
;1= LevelPalette
;2= PaletteFrame1
;3= TitleScrPalette
;4= LevelSelPalette
;5= PaletteMisc1
;6= PaletteMisc2
;Если больше $80,то палитры не перезагружаются при NMI
		.BYTE 0	; (uninited)
Scroll_Byte:	.BYTE 0	; (uninited)
PPU_REG1_Stts:	.BYTE 0	; (uninited)
Player1_Lives:	.BYTE 0	; (uninited)	; DATA XREF: ROM:Check_GameOverr
					; Init_Level_VARs+12w
					; SetUp_LevelVARs+10r
					; LevelEnd_Check+8r
					; Draw_Player_Lives+3Br
					; Draw_Pts_Screen+164r	Add_Life+10w
					; ROM:DE0Dw
					; ROM:Check1pLives_Explode_Handler
					; ROM:Bonus_Lifew
Player2_Lives:	.BYTE 0	; (uninited)
Spr_TileIndex:	.BYTE 0	; (uninited)
Temp_X:		.BYTE 0	; (uninited)
Temp_Y:		.BYTE 0	; (uninited)
Block_X:	.BYTE 0	; (uninited)
Block_Y:	.BYTE 0	; (uninited)
byte_58:	.BYTE 0	; (uninited)
byte_59:	.BYTE 0	; (uninited)
Counter:	.BYTE 0	; (uninited)
Counter2:	.BYTE 0	; (uninited)
TSA_BlockNumber:.BYTE 0	; (uninited)
;16 возможных TSA блоков.Три последних TSA блока пустые	(по счёту $0D-$0F)

BrickChar_X:	.BYTE 0	; (uninited)
BrickChar_Y:	.BYTE 0	; (uninited)
String_Position:.BYTE 0	; (uninited)
Char_Index_Base:.BYTE 0	; (uninited)	; DATA XREF: ROM:C75Dw	ROM:C787w
					; Draw_Player_Lives+8w
					; Draw_Player_Lives+63w
					; Draw_LevelFlag+23w
					; Draw_LevelFlag+38w
					; Draw_StageNumString+4Cw
					; Draw_StageNumString+61w
					; Draw_Pts_Screen+21Aw
					; Draw_Pts_Screen_Template+15w
					; Draw_TitleScreen+38w
					; Draw_TitleScreen+91w
					; Reset_ScreenStuff+2w
					; Save_Str_To_ScrBuffer+18r
					; Draw_BrickStr+12r
					; Draw_RecordDigit+Aw
					; Draw_RecordDigit+29w
		.BYTE 0	; (uninited)
BonusPts_TimeCounter:.BYTE 0 ; (uninited)
;Таймер	отображения очков после	взятия (0 = отображение	очков закончено)

Iterative_Byte:	.BYTE 0	; (uninited)	; Байт,	заполняющий большие массивы данных
AI_X_DifferFlag:.BYTE 0	; (uninited)
AI_Y_DifferFlag:.BYTE 0	; (uninited)
;1 - координаты	танка и	цели равны - цель достигнута
;0 - координата	танка больше координаты	цели
;2 - координата	танка меньше координаты	цели

AddLife_Flag:	.BYTE 0,0 ; (uninited)	;  <>0 - игрок получал дополнительную жизнь
;Жизнь может быть получена только один раз за игру, если игрок заработал 200 000 очков

HQ_Status:	.BYTE 0	; (uninited)	; 80=штаб цел, если ноль то уничтожен
HQExplode_SprBase:.BYTE	0 ; (uninited)	; DATA XREF: Add_ExplodeSprBase+1r
					; ROM:E330w ROM:E338w
EnemyRespawn_PlaceIndex:.BYTE 0	; (uninited)
;(0..2)	- три возможных	места следующего респауна
;лево-центр-право
;
byte_6B:	.BYTE 0	; (uninited)
TanksOnScreen:	.BYTE 0	; (uninited)	; Максимальное количество всех танков на экране
Pause_Flag:	.BYTE 0	; (uninited)	; <>0, значит режим паузы
Spr_Attrib:	.BYTE 0	; (uninited)
;vhp00000  Attributes:
;v = Vertical Flip   (1=Flip)
;h = Horizontal	Flip (1=Flip)
;p = Background	Priority
;0 = In	front
;1 = Behind
;
Player_Blink_Timer:.BYTE 0,0 ; (uninited) ; DATA XREF: ROM:C0DFw
					; SetUp_LevelVARs+32w
					; Title_Screen_Loop+1Aw Ice_Move+16r
					; Ice_Move+1Aw	ROM:OperTank_Playerr
					; Make_Respawn+14w
					; BulletToTank_Impact_Handle:CheckBlink_TankImpactr
					; BulletToTank_Impact_Handle+1A0w
					; Таймер мигания friendly fire
AI_X_Aim:	.BYTE 0	; (uninited)	; DATA XREF: Demo_AI+10w Demo_AI+26w
					; Demo_AI+3Cw Demo_AI+52w ROM:DD80w
					; ROM:DD8Bw ROM:DD96w	Load_AI_Statusr
AI_Y_Aim:	.BYTE 0	; (uninited)	; DATA XREF: Demo_AI+14w Demo_AI+2Aw
					; Demo_AI+40w Demo_AI+56w ROM:DD84w
					; ROM:DD8Fw ROM:DD9Aw
					; Load_AI_Status+Dr
;Координаты, к которым стремятся игроки	во время демо-уровня

Enmy_KlledBy1P_Count:.BYTE 0,0,0,0 ; (uninited)	; DATA XREF: Null_KilledEnms_Count:-w
					; Draw_Pts_Screen+8r
					; Draw_Pts_Screen+50r
					; Draw_Pts_Screen+5Cw
					; BulletToTank_Impact_Handle+102w
Enmy_KlledBy2P_Count:.BYTE 0,0,0,0 ; (uninited)	; DATA XREF: Draw_Pts_Screen+15r
					; Draw_Pts_Screen+6Er
					; Draw_Pts_Screen+7Aw
					; BulletToTank_Impact_Handle:ScndPlayerKll_Tank_Impactw
					; Draw_Pts_Screen+18r
					; Draw_Pts_Screen:End_Draw_Pts_Screeno
;количество врагов, убитых каждым игроком (4 возможных типа)
;
byte_7B:	.BYTE 0	; (uninited)
EndCount_Flag:	.BYTE 0	; (uninited)	; Если 0, завершить подсчет очков для текущего врага
TotalEnmy_KilledBy1P:.BYTE 0 ; (uninited)
TotalEnmy_KilledBy2P:.BYTE 0 ; (uninited)
Enemy_Reinforce_Count:.BYTE 0 ;	(uninited) ; Количество	врагов в запасе
Enemy_Counter:	.BYTE 0	; (uninited)	; Количество врагов на экране и	в запасе
BkgOccurence_Flag:.BYTE	0 ; (uninited)	; DATA XREF: ROM:C0D5w	ROM:C108r
					; ROM:C10Cw ROM:C126r	ROM:C12Aw
					; Move_Tank+Aw
Respawn_Timer:	.BYTE 0	; (uninited)	; Время	до следующего респауна
CursorPos:	.BYTE 0	; (uninited)
Respawn_Delay:	.BYTE 0	; (uninited)	; Задержка между респаунами врагов
Level_Number:	.BYTE 0	; (uninited)
;FF=бонус уровень
;
Bonus_X:	.BYTE 0	; (uninited)
Bonus_Y:	.BYTE 0	; (uninited)
Bonus_Number:	.BYTE 0	; (uninited)	; Определяет тип бонуса
Invisible_Timer:.BYTE 0	; (uninited)	; DATA XREF: SetUp_LevelVARs+36w
					; Invisible_Timer_Handle+6r
					; Invisible_Timer_Handle+10w
					; Load_New_Tank+Bw
					; BulletToTank_Impact_Handle+47r
					; BulletToTank_Impact_Handle+188r
					; ROM:E9F2w
					; Силовое поле вокруг игрока после рождения
byte_8A:	.BYTE 0	; (uninited)
Enemy_Count:	.BYTE 0,0,0,0 ;	(uninited) ; DATA XREF:	Load_New_Tank+15r
					; Load_New_Tank+22w
					; Load_Enemy_Count+14w
;Счётчики типов	врагов на уровне (4 возможных типа)

Enemy_TypeNumber:.BYTE 0 ; (uninited)
;Текущий тип врага (из 4-х возможных на	уровне). Кончается
;первый	тип, начинает респауниться второй.



;Далее идут атрибуты танков (координаты, статус	и тип).	Каждый атрибут - массив	байт, имеющий следующую	структуру:
;1 байт	   - атрибут первого игрока
;2 байт	   - атрибут второго игрока
;3-8 байты - атрибуты танков врагов в порядке, обратном	их появлению на	экране,	т.е. 8 - атрибут первого появившегося
;танка и т.п. 6	врагов появляется только в случае двух игроков

Tank_X:		.BYTE 0,0,0,0,0,0,0,0 ;	(uninited) ; DATA XREF:	ROM:C0C3w
					; Draw_TSA_On_Tank+4r Move_Tank+3Br
					; Move_Tank+3Dw Check_BorderReachr
					; Check_BorderReach+8w
					; Check_BorderReach:+r
					; Check_BorderReach+12w
					; Title_Screen_Loop+9w	Ice_Move+60r
					; Ice_Move+67w	ROM:DC80r ROM:DCB8r
					; ROM:DD08w ROM:CheckTile_Check_Objr
					; ROM:Aim_FirstPlayerr
					; Load_AI_Status+3r ROM:DED6r
					; ROM:DF1Ar ROM:DF26r	ROM:DF39r
					; Set_SprIndex+19r ROM:DFFBr
					; ROM:E027r Make_Shot+1Dr
					; Ice_Detect+14r Ice_Detect+4Br
					; Invisible_Timer_Handle+18r
					; Make_Respawn+Bw Make_Respawn+29w
					; Make_Respawn+4Cr
					; BulletToTank_Impact_Handle+24r
					; BulletToTank_Impact_Handle+A2r
					; BulletToTank_Impact_Handle+165r
					; Bonus_Handle+16r ROM:Aim_ScndPlayerr
					; Demo_AI+24r Demo_AI+50r Demo_AI+3Ar
Tank_Y:		.BYTE 0,0,0,0,0,0,0,0 ;	(uninited) ; DATA XREF:	ROM:C0C7w
					; Demo_AI+6Fr Draw_TSA_On_Tank+6r
					; Move_Tank+47r Move_Tank+49w
					; Check_BorderReach:++r
					; Check_BorderReach+1Cw
					; Check_BorderReach:+++r
					; Check_BorderReach+26w
					; CurPos_To_PixelCoord+9w Ice_Move+69r
					; Ice_Move+70w	ROM:DC86r ROM:DCA8r
					; ROM:DD0Cw ROM:DD36r	ROM:DD82r
					; Load_AI_Status+10r ROM:DED4r
					; ROM:DF18r ROM:Draw_PlayerKillr
					; ROM:DF37r Set_SprIndex+17r
					; ROM:DFF9r ROM:E025r	Make_Shot+28r
					; Ice_Detect+Er Ice_Detect:loc_E1DDr
					; Invisible_Timer_Handle+16r
					; Make_Respawn+10w Make_Respawn+2Ew
					; Make_Respawn+4Ar
					; BulletToTank_Impact_Handle+35r
					; BulletToTank_Impact_Handle+B3r
					; BulletToTank_Impact_Handle+176r
					; Bonus_Handle+26r ROM:DD8Dr
					; Demo_AI+28r Demo_AI+54r Demo_AI+3Er
Tank_Status:	.BYTE 0,0,0,0,0,0,0,0 ;	(uninited) ; DATA XREF:	ROM:C0CBw
					; Title_Screen_Loop+10w
					; Detect_Motion+6r Respawn_Handle+11r
					; Ice_Move:-r Ice_Move+38r
					; Ice_Move+3Aw	Ice_Move:++r
					; Ice_Move+76w	Motion_Handle+2Cr
					; Status_Corer
					; ROM:LoadStts_Misc_Status_Handler
					; ROM:DC70w ROM:DC76o	ROM:Check_Objr
					; ROM:DD25r ROM:DD27w
					; ROM:Change_Direction_Check_Objr
					; ROM:DD45w ROM:DD56r
					; ROM:Sbc_Get_RandomStatusr ROM:DD65o
					; ROM:DD67w ROM:DD9Fw
					; ROM:Explode_Handlew ROM:DDECr
					; ROM:DDF2r
					; ROM:SaveStts_Explode_Handlew
					; ROM:Skip_Explode_Handlew
					; ROM:Set_Respawnw ROM:DE57r
					; ROM:DE61w ROM:Load_Tankw ROM:DE66r
					; Get_RandomDirection+19w
					; Get_RandomDirection:loc_DE8Er
					; SingleTankStatus_Handler ROM:DED1r
					; Set_SprIndex+9r ROM:DFEBr
					; ROM:Respawnr	Make_Shot:+r
					; Make_Player_Shot+6r
					; Make_Enemy_Shot:loc_E169r
					; Ice_Detect+6r
					; HideHiBit_Under_Tank+6r
					; Make_Respawn+48w Load_New_Tank+3w
					; Null_Status:-w
					; Rise_TankStatus_Bit+2r
					; Rise_TankStatus_Bit+8w
					; BulletToTank_Impact_Handle+6r
					; BulletToTank_Impact_Handle+55w
					; BulletToTank_Impact_Handle+78r
					; BulletToTank_Impact_Handle+E8w
					; BulletToTank_Impact_Handle+139r
					; Bonus_Handle+Er ROM:EA22r ROM:EA2Dw
					; Demo_AI:NoBonusr Demo_AI:++r
					; Demo_AI:+r
;Статусы танков:
;
;Формат	байта:
;Четыре	старших	бита образуют индекс команды, который в	дальшейшем грузится из TankStts_JumpTable
;(16 возможных команд):
;0   - танка нет
;1-7 - 8 кадров	анимации взрыва	(если нужно взорвать танк в Status вписывают $73)
;8-D - обычный танк, при этом обрабатываются атрибуты направления (2 младших бита):
;	биты 0,1 - образуют атрибут направления:
;	0 - вверх
;	1 - влево
;	2 - вниз
;	3 - вправо
;E-F - Респаун,	при этом:
;	биты 1,2 - образуют номер кадра	анимации респауна (младший бит не используется): всего 4 кадра


Tank_Type:	.BYTE 0,0,0,0,0,0,0,0 ;	(uninited) ; DATA XREF:	ROM:C0CFw
					; Title_Screen_Loop+16w
					; Motion_Handle:+r ROM:DF01r
					; ROM:DF05r ROM:DFBAr	ROM:DFD2r
					; ROM:DFF0r Make_Shot+30r
					; Make_Player_Shot+14r	Make_Respawn+2w
					; Make_Respawn+40w Load_New_Tank:++r
					; Load_New_Tank:End_Load_New_Tankw
					; BulletToTank_Impact_Handle+61w
					; BulletToTank_Impact_Handle+C5r
					; BulletToTank_Impact_Handle+CEr
					; BulletToTank_Impact_Handle+D4w
					; BulletToTank_Impact_Handle:Skip_BonusHandle_TankImpactr
					; BulletToTank_Impact_Handle+DCw
					; BulletToTank_Impact_Handle+EFr
					; ROM:EA14w ROM:EA32w
;Типы танков:
;
;На одном уровне может встретиться 4 типа танков,
;однако	всего типов танков 8.
;
;Формат	байта:
;Биты:
;0,1 - уровень брони
;2   - флаг бонусного танка
;3,4 - не используются
;5,6,7 - тип танка (возможно 8 типов)


Track_Pos:	.BYTE 0	; (uninited)	; DATA XREF: ROM:C0D3w
					; Title_Screen_Loop+18w
					; Title_Screen_Loop+2Fr
					; Title_Screen_Loop+33w ROM:DC62r
					; ROM:DC66w ROM:TrackHandle_CheckObjr
					; ROM:DD2Dw ROM:DFF5r
					; Load_New_Tank+4Ew
;Расположение гусеничного трака	(если меняется,	то танк	едет)
;Возможно 2 положения =	0 или 4	(каждый	танк 4 тайла (16х16))
byte_B1:	.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
byte_B3:	.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
byte_B5:	.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)

;Далее следуют массивы,	относящиеся к свойствам	пуль (10 возможных на экране):
;первые	два элемента соответствуют игрокам, далее 6 элементов
;для врагов и оставшиеся два элемента -	для дополнительной пули
;каждого из игроков (в случае, если игрок является 2-м бонусным	танком)
Bullet_X:	.BYTE 0,0,0,0,0,0,0,0,0,0 ; (uninited) ; DATA XREF: Change_BulletCoord+5r
					; Change_BulletCoord+7w Make_Shot+1Fw
					; ROM:E102r ROM:E117r
					; Make_Player_Shot+28r
					; Bullet_Fly_Handle+40r
					; Bullet_Fly_Handle+51r
					; Bullet_Fly_Handle+63r
					; Bullet_Fly_Handle+7Ar
					; BulletToTank_Impact_Handle+20r
					; BulletToTank_Impact_Handle:Load_X_TankImpactr
					; BulletToTank_Impact_Handle+161r
					; BulletToBullet_Impact_Handle+30r
					; BulletToBullet_Impact_Handle+34r
					; Make_Player_Shot+2Aw
Bullet_Y:	.BYTE 0,0,0,0,0,0,0,0,0,0 ; (uninited) ; DATA XREF: Change_BulletCoord+Er
					; Change_BulletCoord+10w Make_Shot+2Aw
					; ROM:E100r ROM:E115r
					; Make_Player_Shot+2Cr
					; Bullet_Fly_Handle+3Er
					; Bullet_Fly_Handle+4Ar
					; Bullet_Fly_Handle+5Dr
					; Bullet_Fly_Handle+70r
					; BulletToTank_Impact_Handle+31r
					; BulletToTank_Impact_Handle+AFr
					; BulletToTank_Impact_Handle+172r
					; BulletToBullet_Impact_Handle+41r
					; BulletToBullet_Impact_Handle+45r
					; Make_Player_Shot+2Ew
Bullet_Status:	.BYTE 0,0,0,0,0,0,0,0,0,0 ; (uninited) ; DATA XREF: BulletStatus_Handler
					; ROM:Bullet_Mover ROM:Make_Ricochetw
					; ROM:E078r ROM:E07Er
					; ROM:Skip_Animate_Ricochetw
					; Make_Shotr Make_Shot+14w
					; Draw_BulletGFXr ROM:Draw_Bulletr
					; ROM:Update_Ricochetr
					; Make_Player_Shot+1Cr
					; Make_Player_Shot+24r
					; Make_Player_Shot+36w
					; Hide_All_Bullets:-w
					; Bullet_Fly_Handle+6r
					; Bullet_Fly_Handle:+r
					; BulletToObject_Impact_Handle+27w
					; BulletToObject_Impact_Handle+36w
					; BulletToTank_Impact_Handle+17r
					; BulletToTank_Impact_Handle+44w
					; BulletToTank_Impact_Handle+4Dw
					; BulletToTank_Impact_Handle+92r
					; BulletToTank_Impact_Handle+C2w
					; BulletToTank_Impact_Handle+150r
					; BulletToTank_Impact_Handle+185w
					; BulletToTank_Impact_Handle+18Ew
					; BulletToBullet_Impact_Handle+Cr
					; BulletToBullet_Impact_Handle+27r
					; BulletToBullet_Impact_Handle+54w
					; BulletToBullet_Impact_Handle+56w
					; Make_Player_Shot+20r
					; Make_Player_Shot+26w
;Статус	пули. Формат:
;2 младших бита	(№0,1):
; счётчик фреймов на один кадр (до 3)
;Бит№4,5:
; счётчик кадров анимации рикошета (до 3)
;Бит№6
; выставлен = пуля в полете, при этом обрабатываются атрибуты направления (два младших бита):
;     0	= вверх
;     1	= влево
;     2	= вниз
;     3	= вправо

Bullet_Property:.BYTE 0,0,0,0,0,0,0,0,0,0 ; (uninited) ; DATA XREF: ROM:E059r
					; Make_Shot+2Ew Make_Shot+44w
					; Make_Shot+49w Make_Player_Shot+30r
					; Bullet_Fly_Handle+Er
					; BulletToObject_Impact_Handle+3Er
					; Make_Player_Shot+32w
;Свойство пули.	Формат:			; Скорость и бронебойность
;Бит 0:	выставлен = скорость пули в 2 раза выше
;    1:	выставлен = пуля бронебойная


NTAddr_Coord_Lo:.BYTE 0,0,0,0,0,0,0,0 ;	(uninited) ; DATA XREF:	Ice_Detect+21w
					; HideHiBit_Under_Tank+Er
NTAddr_Coord_Hi:.BYTE 0,0,0,0,0,0,0,0 ;	(uninited) ; DATA XREF:	Ice_Detect+27w
					; Ice_Detect+51r Ice_Detect+55w
					; Ice_Detect+62r Ice_Detect+66w
					; HideHiBit_Under_Tank+12r
					; HideHiBit_Under_Tank+1Fr
					; HideHiBit_Under_Tank:+r
;Координаты танков переведенные	в адреса Name Table (младший и старший байты):
;Старший байт хранит только два	младших	байта реального	старшего адреса	NT
;2 первых байта: 1 и 2 игрок
;6 последующих байт - враги

Low_Ptr_byte2:	.BYTE 0	; (uninited)	; DATA XREF: Sound_Stop+Cw
					; Sound_Stop+17w Sound_Stop+1Dr
					; Sound_Stop+21w Play_Sound+1Dw
					; Play_Sound+2Cr Play_Sound+50w
					; Play_Sound+5Br Play_Sound+66r
					; Play_Sound+6Aw Play_Sound+99w
					; Play_Sound+B1r Play_Sound+B5w
					; Play_Sound+C6r Play_Sound+CBw
					; Play_Sound+D5w Play_Sound+DFw
					; Play_Sound+E6w Play_Sound+EDw
					; Play_Sound+F4w Play_Sound+F8r
					; Play_Sound+103w Play_Sound+11Bw
					; Play_Sound+13Fr Play_Sound+145w
					; Play_Sound+14Aw Play_Sound+14Er
					; Play_Sound+157w Play_Sound+15Br
					; Play_Sound+15Ew Play_Sound+195w
					; Play_Sound+199r Play_Sound+19Ew
					; ROM:EC28r ROM:EC2Ew	ROM:EC3Ar
					; ROM:EC40w ROM:EC4Cr	ROM:EC4Eo
					; ROM:EC52w ROM:EC5Cw	ROM:EC66w
					; ROM:EC70w ROM:EC9Br	ROM:ECA0w
					; ROM:ECAAw sub_ECBE+4r sub_ECBE+Ew
High_Ptr_byte2:	.BYTE 0	; (uninited)	; DATA XREF: Sound_Stop+10w
					; Sound_Stop+25w Play_Sound+21w
					; Play_Sound+6Ew Play_Sound+9Dw
					; Play_Sound+B9w
Low_SndPtr:	.BYTE 0	; (uninited)	; DATA XREF: Load_Snd_Ptr+7w
					; sub_ECBE+7r
High_SndPtr:	.BYTE 0	; (uninited)
Sound_Number:	.BYTE 0	; (uninited)
byte_F5:	.BYTE 0	; (uninited)
byte_F6:	.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
byte_F8:	.BYTE 0	; (uninited)
byte_F9:	.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
byte_FD:	.BYTE 0	; (uninited)
byte_FE:	.BYTE 0	; (uninited)
byte_FF:	.BYTE 0	; (uninited)
EnemyFreeze_Timer:.BYTE	0 ; (uninited)
Player_Type:	.BYTE 0,0 ; (uninited)	; DATA XREF: Init_Level_VARs+2w
					; Load_New_Tank+Dr
					; BulletToTank_Impact_Handle+5Ew
					; ROM:Bonus_Starr ROM:EA11w
;(8 видов). 0=простой (Формат см. Tank_Type) ; Вид танка игрока

Player_Ice_Status:.BYTE	0,0 ; (uninited) ; DATA	XREF: Ice_Move:+++++r
					; Ice_Move:loc_DBB4r Ice_Move+4Aw
					; ROM:DC56r ROM:DC5Fw	Ice_Detect+37r
					; Ice_Detect+3Aw Ice_Detect:+r
					; Ice_Detect+45w
;Старший бит - флаг наличия под	танком льда
;5 младших бит - таймер	скольжения по льду (0=не скользит)

GameOverStr_X:	.BYTE 0	; (uninited)
GameOverStr_Y:	.BYTE 0	; (uninited)
GameOverScroll_Type:.BYTE 0 ; (uninited) ; Определяет вид перемещения надписи(0..3)
GameOverStr_Timer:.BYTE	0 ; (uninited)
byte_109:	.BYTE 0	; (uninited)	; DATA XREF: ROM:C755r	ROM:C76Er
					; ROM:C78Fw ROM:C798w	ROM:C7A1r
					; ROM:C7A7w
		.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
		.BYTE 0	; (uninited)
StaffString_RAM: DSB $10,0              ;	(uninited)
					
;!Мои переменные
Random_Level_Flag 	.BYTE 0; Если нужен случайный уровень, то выставлен младший бит.
Line_TSA_Count 		.BYTE 0; считает количество тса в одной линии случайного уровня
Old_Coord 		.BYTE 0;запоминает последнюю удачную координату
Map_Mode_Pos		.BYTE 0;Запоминает положение режима уровней 0=orig,1=rand,2=mixd
Boss_Mode		.BYTE 0;Если щас будет битва с боссом, то 1
Boss_Armour		.BYTE 0;Запоминает сколько hp*4 у босса

ENDE



ENUM $180					; StaffStr_Check:-r
Screen_Buffer:	DSB $80,0               ;	(uninited)
					; DATA XREF: Draw_StageNumString+Fw
					; Draw_StageNumString+14w
					; Draw_StageNumString+1Aw
					; Draw_StageNumString+20w
					; Draw_StageNumString+26w
					; Draw_StageNumString+2Cw
					; Draw_StageNumString+32w
					; Draw_StageNumString+38w
					; Draw_StageNumString+3Ew
					; Draw_StageNumString+44w
					; DraW_Normal_HQ+40w
					; DraW_Normal_HQ+46w
					; DraW_Normal_HQ+4Fw
					; DraW_Normal_HQ+5Bw
					; DraW_Normal_HQ+61w Draw_Naked_HQ+22w
					; Draw_Naked_HQ+28w Draw_Naked_HQ+34w
					; Draw_Naked_HQ+3Aw Draw_ArmourHQ+40w
					; Draw_ArmourHQ+46w Draw_ArmourHQ+4Fw
					; Draw_ArmourHQ+5Dw Draw_ArmourHQ+63w
					; Copy_AttribToScrnBuff+11w
					; Copy_AttribToScrnBuff+17w
					; Copy_AttribToScrnBuff+1Fw
					; Copy_AttribToScrnBuff+25w
					; FillScr_Single_Row+10w
					; FillScr_Single_Row+16w
					; FillScr_Single_Row:+w
					; FillScr_Single_Row+2Dw
					; AttribToScrBuffer+7w
					; AttribToScrBuffer+Fw
					; AttribToScrBuffer+16w
					; AttribToScrBuffer+1Cw
					; String_to_Screen_Buffer+Aw
					; String_to_Screen_Buffer+Fw
					; String_to_Screen_Buffer+19w
					; Save_Str_To_ScrBuffer+8w
					; Save_Str_To_ScrBuffer+Dw
					; Save_Str_To_ScrBuffer:+w
					; Draw_Tile+Bw	Draw_Tile+11w
					; Draw_Tile+17w Draw_Tile+1Dw
					; Update_Screen+4w Update_Screen+Cr
					; Update_Screen+13r Update_Screen:--r
					; Update_Screen+22r
;Буффер	строковых данных, в дальнейшем выводимый на экран:
;Буффер	размером 128 байт, однако он активно используется в игре,
;т.к. выводится	на экран каждое	NMI.
;Перед строкой стоит адрес в PPU (hi/lo), куда будет записана строка
;Конец вывода строки обозначается байтом $FF

SprBuffer:	DSB $100,0              ;	(uninited)
					; DATA XREF: SaveSprTo_SprBuffer+20w
					; Spr_Invisible+12w
					; SaveSprTo_SprBuffer+25w
					; SaveSprTo_SprBuffer+2Aw
					; SaveSprTo_SprBuffer+2Fw
;      +-----------+-----------+-----+------------+
;      | Sprite	#0 | Sprite #1 | ... | Sprite #63 |
;      +-+------+--+-----------+-----+------------+
;	 |	|
;	 +------+----------+--------------------------------------+
;	 + Byte	| Bits	   | Description			  |
;	 +------+----------+--------------------------------------+
;	 |  0	| YYYYYYYY | Y Coordinate - 1. Consider	the coor- |
;	 |	|	   | dinate the	upper-left corner of the  |
;	 |	|	   | sprite itself.			  |
;	 |  1	| IIIIIIII | Tile Index	#			  |
;	 |  2	| vhp000cc | Attributes				  |
;	 |	|	   |   v = Vertical Flip   (1=Flip)	  |
;	 |	|	   |   h = Horizontal Flip (1=Flip)	  |
;	 |	|	   |   p = Background Priority		  |
;	 |	|	   |	     0 = In front		  |
;	 |	|	   |	     1 = Behind			  |
;	 |	|	   |   c = Upper two (2) bits of colour	  |
;	 |  3	| XXXXXXXX | X Coordinate (upper-left corner)	  |
;	 +------+----------+--------------------------------------+

;Далее идет массив проигрывания	звуков (28 штук): чтобы	воспроизвести
;определенный звук, игра записывает $01	в одну из ячеек. Если воспроизводимый
;звук использует несколько каналов, то каждому каналу отводится	своя ячейка
;(обозначено индексами после названия звука)

Snd_Pause:	.BYTE 0	; (uninited)	; DATA XREF: ROM:C218w	Sound_Stop+19w
					; Play_Sound+25r Play_Sound+A1r
					; Play_Sound+AAw Play_Sound+190w
Snd_Battle1:	.BYTE 0	; (uninited)
Snd_Battle2:	.BYTE 0	; (uninited)
Snd_Battle3:	.BYTE 0	; (uninited)
Snd_Ancillary_Life1:.BYTE 0 ; (uninited)
Snd_Ancillary_Life2:.BYTE 0 ; (uninited)
Snd_BonusTaken:	.BYTE 0	; (uninited)
Snd_PlayerExplode:.BYTE	0 ; (uninited)
Snd_Unknown1:	.BYTE 0	; (uninited)
Snd_BonusAppears:.BYTE 0 ; (uninited)
Snd_EnemyExplode:.BYTE 0 ; (uninited)
Sns_HQExplode:	.BYTE 0	; (uninited)
Snd_Brick_Ricochet:.BYTE 0 ; (uninited)
Snd_ArmorRicochetWall:.BYTE 0 ;	(uninited)
Snd_ArmorRicochetTank:.BYTE 0 ;	(uninited)
Snd_Shoot:	.BYTE 0	; (uninited)
Snd_Ice:	.BYTE 0	; (uninited)
Snd_Move:	.BYTE 0	; (uninited)
Snd_Engine:	.BYTE 0	; (uninited)
Snd_PtsCount1:	.BYTE 0	; (uninited)
Snd_PtsCount2:	.BYTE 0	; (uninited)
Snd_RecordPts1:	.BYTE 0	; (uninited)
Snd_RecordPts2:	.BYTE 0	; (uninited)
Snd_RecordPts3:	.BYTE 0	; (uninited)
Snd_GameOver1:	.BYTE 0	; (uninited)
Snd_GameOver2:	.BYTE 0	; (uninited)
Snd_GameOver3:	.BYTE 0	; (uninited)
Snd_BonusPts:	.BYTE 0	; (uninited)
byte_31C:	.BYTE 0	; (uninited)
byte_31D:	.BYTE 0	; (uninited)
ENDE

ENUM $400
NT_Buffer:	DSB $400,0              ;	(uninited)
					; DATA XREF: Null_NT_Buffer:-w
					; Draw_GrayFrame:Fill_NTBufferw
ENDE
; end of 'RAM'