;                               Griever's Stuff
;                    -=#Battle City - Back From Source#=-


	INCLUDE RAM.asm; Описание всех переменных вынесено в отдельный файл.
	INCLUDE REGS.asm; Регистры вынесены в отдельный файл.

; ═══════════════════════════════════════════════════════════════════════════
; Заголовок формата iNES:
	.BYTE 'NES',$1A ;String "NES^Z" used to recognize .NES files
	.BYTE	2       ;Number of 16kB ROM banks.
	.BYTE	1       ;Number of 8kB VROM banks.
	 DSB 10,0   


; ═══════════════════════════════════════════════════════════════════════════
$ = $8000

INCLUDE Level.asm; В верхнем окне будут уровни.

PAD $C000; в нижнем окне  - код.
; ═══════════════════════════════════════════════════════════════════════════

; Segment type:	Pure code

StaffString:	.BYTE 'RYOUITI OOKUBO  TAKEFUMI HYOUDOUJUNKO OZAWA     '
					; DATA XREF: StaffStr_Store:-r
					; StaffStr_Check+5r
; ───────────────────────────────────────────────────────────────────────────

RESET:					; DATA XREF: ROM:FFFCo	ROM:FFFEo
		SEI
		LDA	#00010000b
		STA	PPU_CTRL_REG1	; Бэкграунду второй знакогенератор
		CLD
		LDX	#2

Wait:					; CODE XREF: ROM:C07Cj	ROM:C084j
		LDA	PPU_STATUS	; PPU Status Register (R)
		BPL	Wait
		LDA	#00000110b
		STA	PPU_CTRL_REG2	; PPU Control Register #2 (W)
		DEX
		BNE	Wait
		LDX	#$7F ; ''      ; Вершина стека
		TXS
		JSR	Reset_ScreenStuff
		LDA	#0
		STA	Scroll_Byte
		STA	PPU_REG1_Stts
		JSR	Set_PPU

BEGIN:					; CODE XREF: ROM:Skip_RecordShowj
		JSR	Draw_TitleScreen
		LDA	#0
		STA	Construction_Flag ; Пока в Construction	не заходили

; START	OF FUNCTION CHUNK FOR BonusLevel_ButtonCheck

New_Scroll:				; CODE XREF: BonusLevel_ButtonCheck-372j
		JSR	Null_Upper_NT
		JSR	Scroll_TitleScrn ; Убираем из верхней (0(1)) тайловой карты уровень и
					; скроллим на титульник	в нижней (2(3))тайловой	карте.

Title_Loaded:				; CODE XREF: ROM:C156j
					; BonusLevel_ButtonCheck+2Bj
					; Scroll_TitleScrn+1Aj
		JSR	Title_Screen_Loop
		JSR	Load_DemoLevel
		JSR	BonusLevel_ButtonCheck ; Рекурсия.
		JMP	New_Scroll	; После	окончания бонус	уровня,	заново скроллируем титульник.
; END OF FUNCTION CHUNK	FOR BonusLevel_ButtonCheck
; ───────────────────────────────────────────────────────────────────────────

Construction:				; CODE XREF: ROM:CA82j
		LDA	Construction_Flag ; Выставляется, если зашли в Construction
		BNE	Skip_LoadFrame	; Если уже заходили в Construction, рамка уже отрисована
		JSR	Screen_Off
		JSR	Make_GrayFrame
		JSR	Store_NT_Buffer_InVRAM ; Сбрасывает на экран содержимое	NT_Buffer
		JSR	Set_PPU

Skip_LoadFrame:				; CODE XREF: ROM:C0B0j
		JSR	Null_Status
		LDA	#$10
		STA	Tank_X
		LDA	#$18
		STA	Tank_Y		; Начальная позиция танка на экране
		LDA	#$84 ; 'Д'
		STA	Tank_Status	; Дулом	вверх
		LDA	#0
		STA	Tank_Type
		STA	Spr_Attrib
		STA	Track_Pos
		STA	BkgOccurence_Flag
		STA	byte_7B
		STA	TSA_BlockNumber
		STA	Scroll_Byte
		STA	PPU_REG1_Stts
		STA	Player_Blink_Timer ; Таймер мигания friendly fire
		STA	Player_Blink_Timer+1 ; Таймер мигания friendly fire
		LDA	Construction_Flag ; Выставляется, если зашли в Construction
		BNE	Construction_Loop
		JSR	DraW_Normal_HQ	; Если уже заходили в Construction, штаб уже отрисован

Construction_Loop:			; CODE XREF: ROM:C0E5j	ROM:C14Dj
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		JSR	Move_Tank	; Двигает танк в зависимости от	нажатых	кнопок
		JSR	Check_BorderReach ; Не дает танку выйти	за границы серой рамки
		LDA	Frame_Counter
		AND	#$10
		BEQ	Skip_Status_Handle
		JSR	TanksStatus_Handle ; Обрабатывает статусы всех 8-ми танков

Skip_Status_Handle:			; CODE XREF: ROM:C0F7j
		LDA	Joypad1_Buttons
		AND	#$F0 ; 'Ё'
		BNE	loc_C13E
		LDA	Joypad1_Differ
		AND	#1
		BEQ	loc_C120
		LDA	BkgOccurence_Flag
		BNE	loc_C111
		INC	BkgOccurence_Flag
		JMP	Construct_Draw_TSA
; ───────────────────────────────────────────────────────────────────────────

loc_C111:				; CODE XREF: ROM:C10Aj
		INC	TSA_BlockNumber
		LDA	TSA_BlockNumber
		CMP	#$E
		BNE	Construct_Draw_TSA
		LDA	#0
		STA	TSA_BlockNumber
		JMP	Construct_Draw_TSA
; ───────────────────────────────────────────────────────────────────────────

loc_C120:				; CODE XREF: ROM:C106j
		LDA	Joypad1_Differ
		AND	#2
		BEQ	loc_C13E
		LDA	BkgOccurence_Flag
		BNE	loc_C12F
		INC	BkgOccurence_Flag
		JMP	Construct_Draw_TSA
; ───────────────────────────────────────────────────────────────────────────

loc_C12F:				; CODE XREF: ROM:C128j
		DEC	TSA_BlockNumber
		LDA	TSA_BlockNumber
		CMP	#$FF
		BNE	Construct_Draw_TSA
		LDA	#$D		; $D - первый пустой блок
		STA	TSA_BlockNumber
		JMP	Construct_Draw_TSA
; ───────────────────────────────────────────────────────────────────────────

loc_C13E:				; CODE XREF: ROM:C100j	ROM:C124j
		LDA	Joypad1_Buttons
		AND	#3		; При нажатии А	или В рисуется блок под	танком
		BEQ	Construct_StartCheck

Construct_Draw_TSA:			; CODE XREF: ROM:C10Ej	ROM:C117j
					; ROM:C11Dj ROM:C12Cj	ROM:C135j
					; ROM:C13Bj
		JSR	Draw_TSA_On_Tank ; Рисует TSA блок под танком

Construct_StartCheck:			; CODE XREF: ROM:C142j
		LDA	Joypad1_Differ
		AND	#8
		BNE	End_Construction ; Если	нажато старт, выходим
		JMP	Construction_Loop
; ───────────────────────────────────────────────────────────────────────────

End_Construction:			; CODE XREF: ROM:C14Bj
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		INC	Construction_Flag ; Помечаем, что зашли	в Construction
		JMP	Title_Loaded

; ───────────────────────────────────────────────────────────────────────────

Start_StageSelScrn:			; CODE XREF: ROM:C280j	ROM:CA7Bj
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		JSR	Sound_Stop	; Останавливаем	звук, включаем каналы и	т.п. (аналогично Load в	NSF формате)
		LDA	#$1C
		STA	PPU_Addr_Ptr	; Запись будет в верхнюю NT
		LDA	#0
		STA	Scroll_Byte
		STA	PPU_REG1_Stts
		STA	Pause_Flag
		LDA	#4
		STA	BkgPal_Number


		JSR	FillNT_with_Grey ; создаёт эффект сходящихся вертикальных створок

StageSelect_Loop:			; CODE XREF: ROM:C19Bj	ROM:C1A1j
					; ROM:C1AEj ROM:C1B4j	ROM:C1BCj
					; ROM:C1C2j
;!Определяем нужен ли нам Уровень с боссом (каждый восьмой уровень)
		LDA Level_Number
		AND #7
		BNE Skip_Make_Armour
		LDA #1
		sta Boss_Mode

		Lda #Init_Boss_Armour
		Sta Boss_Armour
		jmp Draw_Stage_String

		Skip_Make_Armour:
		lda #0
		Sta Boss_Armour
		sta Boss_Mode

Draw_Stage_String:
		JSR	Draw_StageNumString
;! Сразу начинаем уровень - безо всяких проверок на кнопки или флага начала игры.

; ───────────────────────────────────────────────────────────────────────────
Start_Level:				; CODE XREF: ROM:C177j	ROM:C17Dj
Init_Boss_Armour = #10



		LDA	Construction_Flag ; Выставляется, если зашли в Construction
		BNE	Skip_Lvl_Load	; Если побывали	в Construction,	то
					; данные уровня	загружаться не будут (они уже в	NT_Buffer)
					; (только танки	и штаб)


;! Определяем какой уровень нужно загрузить: обычный или случайный.
Get_Map_Mode:
		Lda Map_Mode_Pos
		BEQ Orig_Map
		CMP #2			
		BCC Random_Map
		
		JSR Get_Random_A	;Выбран пункт Mixed
		AND #1
		JMP Make_Gray_Frame
		
Orig_Map:
		LDA #0			;Выбран пункт Original
		JMP Make_Gray_Frame
Random_Map:
		LDA #1			;Выбран пункт Random
		


Make_Gray_Frame:
		STA Random_Level_Flag
		JSR	Make_GrayFrame
		LDA	Level_Number
		JSR	Load_Level; Тут будет проверен флаг случайного и если нужно, загружен пустой уровень
;!Проверяем флаг и если надо рисуем на пустом уровне лабиринт.
		ldx Random_Level_Flag
		Beq ++++
		jsr Draw_Random_Level
++++



		JSR	DraW_Normal_HQ	; Рисует штаб с	кирпичами
		JMP	+
; ───────────────────────────────────────────────────────────────────────────

Skip_Lvl_Load:				; CODE XREF: ROM:C1D2j
		JSR	Draw_Naked_HQ	; Даже если штаб был зарисован в Construction, он будет	поверх

+:
		LDA	#1
		STA	Snd_Battle1
		STA	Snd_Battle2
		STA	Snd_Battle3	; Проигрываем мелодию боя

					; CODE XREF: ROM:C1DFj
		LDA	#0
		STA	ScrBuffer_Pos
		JSR	Copy_AttribToScrnBuff
		JSR	FillNT_with_Black ; Создаёт эффект расходящихся	вертикальных створок
		LDA	#0
		STA	BkgPal_Number
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		JSR	SetUp_LevelVARs

Battle_Engine:				; CODE XREF: ROM:C221j
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	Pause_Flag
		BNE	Skip_Battle_Loop ; В режиме паузы не нужно обрабатывать	танки, жизни и т.п.
		JSR	Battle_Loop	; Основные операции с танками и	пулями

Skip_Battle_Loop:			; CODE XREF: ROM:C1FEj
		JSR	Bonus_Draw	; Рисует или пустоту или бонус или очки	за бонус
		JSR	Draw_All_BulletGFX ; Рисует все	пули
		JSR	TanksStatus_Handle ; Обрабатывает статусы всех 8-ми танков
		LDA	Joypad1_Differ
		AND	#8		; Проверка на нажатие старт
		BEQ	Skip_Pause_Switch
		LDA	#1
		EOR	Pause_Flag
		STA	Pause_Flag	; Переключаем флаг паузы на противоположный
		STA	Snd_Pause

Skip_Pause_Switch:			; CODE XREF: ROM:C210j
		JSR	Draw_Pause	; Рисует мигающую надпись, в случае если выставлена пауза
		JSR	LevelEnd_Check	; if ExitLevel then A=1
		BEQ	Battle_Engine
		LDA	#0
		STA	Seconds_Counter
		STA	Frame_Counter	; Останавливаем	таймеры
		STA	Snd_Move
		STA	Snd_Engine	; Останавливаем	звуки
		LDA	GameOverStr_Timer
		BEQ	AfterDeath_BattleRun
		LDA	#$FE ; '■'
		STA	Seconds_Counter

AfterDeath_BattleRun:			; CODE XREF: ROM:C232j	ROM:C251j
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		JSR	FreezePlayer_OnHQDestroy ; Лишает игрока подвижности, если штаб	разрушен
		JSR	Battle_Loop	; Основные операции с танками и	пулями
		JSR	Bonus_Draw	; Рисует или пустоту или бонус или очки	за бонус
		JSR	TanksStatus_Handle ; Обрабатывает статусы всех 8-ми танков
		JSR	Draw_All_BulletGFX ; Рисует все	пули
		JSR	Swap_Pal_Colors	; Периодическое	мигание	- эффект воды на 01 палитре
		LDA	Seconds_Counter
		CMP	#2		; 2 Секунды держится неподвижная надпись GameOver c замороженным игроком
		BNE	AfterDeath_BattleRun
		JSR	Sound_Stop	; Останавливаем	звук, включаем каналы и	т.п. (аналогично Load в	NSF формате)
		JSR	Draw_Pts_Screen



 
Check_GameOver:				; CODE XREF: ROM:C26Dj
		LDA	Player1_Lives
		CLC
		ADC	Player2_Lives
		BEQ	Make_GameOver	; Если жизней ни у кого	не осталось, геймовер
		LDA	HQ_Status	; 80=штаб цел, если ноль то уничтожен
		CMP	#$80 ; 'А'
		BNE	Make_GameOver	; Если штаб разрушен, геймовер
		INC Level_Number   ;! Увеличиваем псевдономер уровня (из 99-ти)

		LDA Level_Number
		Cmp #51
		BCC Skip_Make_Hard
		LDA	#1
		STA	Level_Mode

Skip_Make_Hard:
		LDA Level_Number
		CMP #100
		BCC Continue_Game
		Lda #1                ;отображаем финальный экран.
		STA Level_Number
		LDA	#0
		STA	Level_Mode

                JSR     Draw_Congrats ; Рисует большую кирпичную надпись с поздравлением
                JSR     Clear_NT        ; Очищаем верхнюю карту тайлов (титульник будет в нижней)
                JMP     BEGIN

Continue_Game:		
		JMP	Start_StageSelScrn ; Если мы вышли из уровня победителями, то переходим	к следующему уровню
; ───────────────────────────────────────────────────────────────────────────

Make_GameOver:
		LDA #0
		STA Boss_Mode				; CODE XREF: ROM:C278j	ROM:C27Ej
		JSR	Draw_Brick_GameOver ; Рисует большую кирпичную надпись GameOver

;! Если произошел геймовер, то откатываемся на 5 уровней назад, предварительно проверив сам номер уровня.
		Lda Level_Number
		CMP #6
		BCC +; Если номер уровня меньше 6, то отнимать 5 уровней нельзя.
		SEC
		SBC #5
		STA Level_Number

+
		JSR	Update_HiScore	; На выходе A =	$FF, значит есть рекорд
		TYA
		BEQ	Skip_RecordShow
		JSR	Draw_Record_HiScore ; Рисует большую кирпичную надпись с рекордом
		JSR	Clear_NT	; Очищаем верхнюю карту	тайлов (титульник будет	в нижней)

Skip_RecordShow:			; CODE XREF: ROM:C28Aj
		JMP	BEGIN

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Clear_NT:				; CODE XREF: ROM:C28Fp
		JSR	Screen_Off
		JSR	Null_NT_Buffer
		JSR	Store_NT_Buffer_InVRAM ; Сбрасывает на экран содержимое	NT_Buffer
		JSR	Set_PPU
		RTS
; End of function Clear_NT


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Лишает игрока	подвижности, если штаб разрушен

FreezePlayer_OnHQDestroy:		; CODE XREF: ROM:C23Bp
		LDA	HQ_Status	; 80=штаб цел, если ноль то уничтожен
		CMP	#$80 ; 'А'
		BEQ	+
		LDA	#0
		STA	Joypad1_Buttons
		STA	Joypad2_Buttons
		STA	Joypad1_Differ
		STA	Joypad2_Differ

+:					; CODE XREF: FreezePlayer_OnHQDestroy+4j
		RTS
; End of function FreezePlayer_OnHQDestroy


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Null_both_HiScore:			; CODE XREF: ROM:CA78p
		LDX	#HiScore_1P_String
		JSR	Null_8Bytes_String
		LDX	#HiScore_2P_String
		JSR	Null_8Bytes_String
; End of function Null_both_HiScore


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Init_Level_VARs:			; CODE XREF: Load_DemoLevel+8p
		LDA	#0
		STA	Player_Type	; Вид танка игрока
		STA	Player_Type+1	; Вид танка игрока
		LDA	#0
		STA	AddLife_Flag	;  <>0 - игрок получал дополнительную жизнь
		STA	AddLife_Flag+1	;  <>0 - игрок получал дополнительную жизнь
		STA	EnterGame_Flag	; Если 0, то можно выбрать уровень
		LDA	#3		; Начальное количество жизней
		STA	Player1_Lives
		STA	Player2_Lives
		STA	EnemyRespawn_PlaceIndex
		LDA	CursorPos
		BNE	+
		LDA	#0		; Если 2 игрока	нет, обнуляем его жизни
		STA	Player2_Lives

+:					; CODE XREF: Init_Level_VARs+1Aj

		
		LDA	#0		; Game Over будет отображаться
		STA	Level_Mode
		RTS
; End of function Init_Level_VARs


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Основные операции с танками и	пулями

Battle_Loop:				; CODE XREF: ROM:C200p	ROM:C23Ep
					; BonusLevel_ButtonCheck+Cp
		JSR	Ice_Detect	; Обрабатывает игрока, если тот	на льду
		JSR	Ice_Move	; Выполняет скольжение,	если танк двигается на льду
		JSR	Motion_Handle	; Замораживает врагов, если нужно (обработка движения)
		JSR	HideHiBit_Under_Tank
		JSR	AllBulletsStatus_Handle	; Обрабатывает статусы всех пуль
		JSR	HQ_Handle	; Обрабатывает статус и	броню штаба
		JSR	Invisible_Timer_Handle ; Рисует	силовое	поле, если нужно
		JSR	Make_Player_Shot ; Делает выстрел игрока, если нажата кнопка
		JSR	Make_Enemy_Shot	; Производит выстрел, используя	случайные числа
		JSR	Respawn_Handle
		JSR	Bullet_Fly_Handle ; Обрабатывает полет пули (столкновение и т.п.)
		JSR	BulletToBullet_Impact_Handle ; Обрабатывает столкновение двух пуль, если оно есть
		JSR	BulletToTank_Impact_Handle ; Обрабатывает столкновение пули с танком
		JSR	Bonus_Handle	; Обрабатывает взятие бонуса, если таковое есть
		JSR	GameOver_Str_Move_Handle ; Выводит надпись Game	Over если нужно
		JSR	Play_Snd_Move	; Играет и гасит звук движения когда нужно
		JSR	Draw_Player_Lives ; Рисует IP/IIP и число жизней в правом углу
		JSR	Swap_Pal_Colors	; Периодическое	мигание	- эффект воды на 01 палитре
		RTS
; End of function Battle_Loop


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Периодическое	мигание	- эффект воды на 01 палитре

Swap_Pal_Colors:			; CODE XREF: ROM:C24Ap	Battle_Loop+33p
		LDA	Frame_Counter
		AND	#$3F ; '?'
		BEQ	switch
		CMP	#$20 ; ' '
		BNE	exit
		LDA	#1
		STA	BkgPal_Number
		RTS
; ───────────────────────────────────────────────────────────────────────────

switch:					; CODE XREF: Swap_Pal_Colors+4j
		LDA	#2
		STA	BkgPal_Number

exit:					; CODE XREF: Swap_Pal_Colors+8j
		RTS
; End of function Swap_Pal_Colors


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


SetUp_LevelVARs:			; CODE XREF: ROM:C1F6p
					; Load_DemoLevel+5Ap
		JSR	Hide_All_Bullets ; Уводим с экраны все пули
		JSR	Null_Status
		LDA	#$F0 ; 'Ё'
		STA	GameOverStr_Y	; Уводим за экран надпись
		LDA	#0
		STA	GameOverStr_Timer
		LDA	Player1_Lives	; Если жизней нет,
					; больше не респаунимся
		BEQ	+
		LDX	#0
		JSR	Make_Respawn

+:					; CODE XREF: SetUp_LevelVARs+12j
		LDA	Player2_Lives
		BEQ	Set_VARs
		LDX	#1
		JSR	Make_Respawn

Set_VARs:

		LDA Boss_Mode;!
		BEQ Skip_Boss_Mode
		LDA Level_Number
		CMP #80;! После 80 уровня два босса
		BCC Low_Levels
		LDA #2
		JMP Save_Enemy_Counter
Low_Levels:
		LDA #1
		JMP Save_Enemy_Counter;! босс будет один, а после 80-го уровня их станет два.

Skip_Boss_Mode:				
		LDA	#20 ;20 врагов в каждом уровне

Save_Enemy_Counter:
		STA	Enemy_Reinforce_Count ;	Количество врагов в запасе
		STA	Enemy_Counter	; Количество врагов на экране и	в запасе
		LDA	#0
		STA	Enemy_TypeNumber
		STA	Seconds_Counter
		STA	Construction_Flag ; Выставляется, если зашли в Construction
		STA	HQArmour_Timer	; Таймер брони вокруг штаба
		STA	Player_Blink_Timer ; Таймер мигания friendly fire
		STA	Player_Blink_Timer+1 ; Таймер мигания friendly fire
		STA	Invisible_Timer	; Силовое поле вокруг игрока после рождения
		STA	byte_8A
		STA	Respawn_Timer	; Время	до следующего респауна
		STA	Bonus_X
		STA	EnemyFreeze_Timer
		STA	EnemyRespawn_PlaceIndex	; Начинаем респауниться	слева
		JSR	Null_KilledEnms_Count ;	Обнуляет массив	счётчиков убитых врагов
		JSR	Draw_Reinforcemets
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		JSR	Draw_IP
		JSR	Draw_LevelFlag

		LDA Boss_Mode
		BEQ Skip_Boss_Mode2
		JSR Get_Random_A ; в режиме босса записываем единицу в один из типов врагов
		AND #3
		TAY
		LDA #1
		STA Enemy_Count,Y
		JMP Init_HQ_Stat

Skip_Boss_Mode2:
		JSR	Load_Enemy_Count
Init_HQ_Stat:
		LDA	#$80 ; 'А'
		STA	HQ_Status	; 80=штаб цел, если ноль то уничтожен
		LDA	#1
		STA	Snd_Engine
		STA	EnterGame_Flag	; Если 0, то можно выбрать уровень
		LDA	Level_Mode
		CMP	#1
		BNE	++
		LDA	#35
		JMP	Respawn_Delay_Calc
; ───────────────────────────────────────────────────────────────────────────

++:					; CODE XREF: SetUp_LevelVARs+64j
		LDA	Level_Number

Respawn_Delay_Calc:			; CODE XREF: SetUp_LevelVARs+68j
		CMP	#43		;! На уровнях выше 42, оставляем время на респаун минимальным
		BCC	Level_Small
		LDA	#42
Level_Small:
		ASL	A
		ASL	A
		STA	Temp
		LDA	#190
		SEC
		SBC	Temp
		STA	Respawn_Delay	; Задержка между респаунами врагов
		LDA	CursorPos
		BEQ	+++
		LDA	Respawn_Delay	; Задержка между респаунами врагов
		SEC
		SBC	#20
		STA	Respawn_Delay	; Задержка между респаунами во фреймах может быть вычислена по формуле:
					; 190 -	(№уровня)*4 - (количество_игроков - 1)*20

+++:					; CODE XREF: SetUp_LevelVARs+7Aj
		RTS
; End of function SetUp_LevelVARs


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Load_DemoLevel:				; CODE XREF: BonusLevel_ButtonCheck-378p
		LDA	#1
		STA	Pause_Flag
		LDA	#0
		STA	BkgPal_Number
		JSR	Init_Level_VARs
		LDA	#3
		STA	Player2_Lives	; Вне зависимости от выбора игрока,
					; появится второй танк.
		LDA	#0
		STA	Scroll_Byte	; Таким	образом	на экране будет	содержимое 0(1)
					; тайловой карты. Во 2(3) всегда находится титульник,
					; что позволяет	не загружать его каждый	раз, когда
					; нужно	вернуться (в этом случае очищаются 0(1)
					; тайловые карты и происходит скролл на	2(3), который
					; также	заметен	глазу игрока)
		STA	PPU_REG1_Stts
		STA	Seconds_Counter
		STA	Frame_Counter
		JSR	Make_GrayFrame
		LDA	#$FF
		STA	Level_Number
		JSR	Load_Level
		LDA	#1
		STA	Level_Number	; В правом углу	во время бонус уровня указан
					; именно 30-й номер уровня, хотя по
					; содержимому это и не он
		LDA	#2
		STA	Level_Mode
		JSR	Screen_Off
		LDX	#$1A
		STX	Block_X
		LDY	#$46 ; 'F'
		STY	Block_Y
		LDA	#>aBattle	; "BATTLE\xFF"
		STA	HighStrPtr_Byte
		LDA	#<aBattle	; "BATTLE\xFF"
		STA	LowStrPtr_Byte	; Загрузка указателя для "Кирпичного" слова 'BATTLE'
					;
		JSR	Draw_BrickStr
		LDX	#$3C ; '<'
		STX	Block_X
		LDY	#$78 ; 'x'
		STY	Block_Y		;
					;
		LDA	#>aCity		; "CITY\xFF"
		STA	HighStrPtr_Byte
		LDA	#<aCity		; "CITY\xFF"
		STA	LowStrPtr_Byte	; Загрузка указателя для "Кирпичного" слова 'CITY'
					;
		JSR	Draw_BrickStr
		JSR	Store_NT_Buffer_InVRAM ; Сбрасывает на экран содержимое	NT_Buffer
		JSR	Set_PPU
		JSR	SetUp_LevelVARs
		JSR	DraW_Normal_HQ	; Рисует штаб с	кирпичами
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	#5
		STA	TanksOnScreen	; Максимальное количество всех танков на экране
		RTS
; End of function Load_DemoLevel


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


BonusLevel_ButtonCheck:			; CODE XREF: BonusLevel_ButtonCheck-375p
					; BonusLevel_ButtonCheck+1Bj

; FUNCTION CHUNK AT C09C SIZE 00000012 BYTES

		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	Joypad1_Differ
		AND	#1100b		; проверка на select(4)	или start(8)
					; во время скроллинга титульника или
					; бонус	уровня.
		BNE	Button_Pressed

DemoLevel_Loop:				; Управление танками игроков во	время демо уровня
		JSR	Demo_AI
		JSR	Battle_Loop	; Основные операции с танками и	пулями
		JSR	Bonus_Draw	; Рисует или пустоту или бонус или очки	за бонус
		JSR	TanksStatus_Handle ; Обрабатывает статусы всех 8-ми танков
		JSR	Draw_All_BulletGFX ; Рисует все	пули
		JSR	LevelEnd_Check	; if ExitLevel then A=1
		BEQ	BonusLevel_ButtonCheck

End_Demo:
		LDA	#0
		STA	ScrBuffer_Pos
		RTS
; ───────────────────────────────────────────────────────────────────────────

Button_Pressed:				; CODE XREF: BonusLevel_ButtonCheck+7j
		PLA
		PLA			; Убираем из стека точку возврата
					; (по RTS всё равно выходить не	будем),
					; но процедура в конце вызывает	себя
					; рекурсивно - и стек стал бы
					; неограниченно	заполняться
		LDA	#0
		STA	ScrBuffer_Pos
		JSR	Null_Upper_NT
		JMP	Title_Loaded
; End of function BonusLevel_ButtonCheck


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует большую кирпичную надпись с рекордом

Draw_Record_HiScore:			; CODE XREF: ROM:C28Cp
		JSR	Screen_Off
		LDA	#$1C
		STA	PPU_Addr_Ptr
		LDA	#0
		STA	Scroll_Byte
		STA	PPU_REG1_Stts
		JSR	Null_NT_Buffer
		LDX	#$10
		STX	Block_X
		LDY	#$32 ; '2'
		STY	Block_Y
		LDA	#>aHiscore	; Выводится в виде кирпичной надписи, если рекорд
		STA	HighStrPtr_Byte
		LDA	#<aHiscore	; Выводится в виде кирпичной надписи, если рекорд
		STA	LowStrPtr_Byte
		JSR	Draw_BrickStr
		JSR	Draw_RecordDigit ; Выводит на экран цифру рекорда
		JSR	Store_NT_Buffer_InVRAM ; Сбрасывает на экран содержимое	NT_Buffer
		JSR	Set_PPU
		LDA	#0
		STA	Seconds_Counter
		LDA	#1
		STA	Snd_RecordPts1
		STA	Snd_RecordPts2
		STA	Snd_RecordPts3

-:					; CODE XREF: Draw_Record_HiScore+4Aj
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	Frame_Counter
		AND	#3
		CLC
		ADC	#5
		STA	BkgPal_Number	; Мигание надписи
		LDA	Snd_RecordPts1
		BNE	-		; Ждём,	пока не	закончит играть	мелодия	рекорда
		LDA	#0
		STA	BkgPal_Number
		RTS
; End of function Draw_Record_HiScore



; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_RespawnPic:			; CODE XREF: Draw_Drop:-p Draw_Drop+Fp
					; Draw_Drop+12p Draw_Drop+15p
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	#3
		STA	TSA_Pal
		LDA	#3
		SEC
		SBC	Counter
		BPL	+
		EOR	#$FF
		CLC
		ADC	#1

+:					; CODE XREF: Draw_RespawnPic+Cj
		STA	Temp
		LDA	#3
		SEC
		SBC	Temp
		ASL	A
		ASL	A
		CLC
		ADC	#$A1 ; 'б'      ; начало в Pattern Table графики респауна
		STA	Spr_TileIndex
		LDX	Block_X
		LDY	Block_Y
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)
		RTS
; End of function Draw_RespawnPic


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует большую кирпичную надпись GameOver

Draw_Brick_GameOver:			; CODE XREF: ROM:Make_GameOverp
		JSR	Screen_Off
		LDA	#$1C
		STA	PPU_Addr_Ptr
		LDA	#0
		STA	Scroll_Byte
		STA	PPU_REG1_Stts
		JSR	Null_NT_Buffer
		LDX	#$3C ; '<'
		STX	Block_X
		LDY	#$46
		STY	Block_Y
		LDA	#>aGame		; Выводится в виде кирпичной надписи на	весь экран
		STA	HighStrPtr_Byte
		LDA	#<aGame		; Выводится в виде кирпичной надписи на	весь экран
		STA	LowStrPtr_Byte
		JSR	Draw_BrickStr
		LDX	#$3C ; '<'
		STX	Block_X
		LDY	#$78 ; 'x'
		STY	Block_Y
		LDA	#>aOver		; "OVER\xFF"
		STA	HighStrPtr_Byte
		LDA	#<aOver		; "OVER\xFF"
		STA	LowStrPtr_Byte
		JSR	Draw_BrickStr
		JSR	Store_NT_Buffer_InVRAM ; Сбрасывает на экран содержимое	NT_Buffer
		JSR	Set_PPU
		LDA	#0
		STA	Seconds_Counter
		LDA	#1
		STA	Snd_GameOver1
		STA	Snd_GameOver2
		STA	Snd_GameOver3

Next_Frame:				; CODE XREF: Draw_Brick_GameOver+57j
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	Joypad1_Differ
		AND	#$C
		BNE	End_Draw_Brick_GameOver	; Если нажато Select или Start,	выходим
		LDA	Snd_GameOver1
		BNE	Next_Frame	; Если мелодия закончила играть, выходим

End_Draw_Brick_GameOver:		; CODE XREF: Draw_Brick_GameOver+52j
		JSR	Screen_Off
		JSR	Null_NT_Buffer
		JSR	Store_NT_Buffer_InVRAM ; Сбрасывает на экран содержимое	NT_Buffer
		JSR	Set_PPU
		JSR	Sound_Stop	; Останавливаем	звук, включаем каналы и	т.п. (аналогично Load в	NSF формате)
		RTS
; End of function Draw_Brick_GameOver


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Управление танками игроков во	время демо уровня

Demo_AI:				; CODE XREF: BonusLevel_ButtonCheck:DemoLevel_Loopp
		LDA	#1
		STA	Counter		; Обрабатываем двух игроков

-:					; CODE XREF: Demo_AI+7Dj
		LDX	Counter
		LDA	Bonus_X
		BEQ	NoBonus		; Bonus_X=0 - бонус выведен за экран
		LDA	BonusPts_TimeCounter
		BNE	NoBonus		; Если таймер !=0, бонус взят
					; и отображаются очки за него
					; Если бонус на	экране,	в первую очередь забираем его

Take_Bonus:
		LDA	Bonus_X
		STA	AI_X_Aim
		LDA	Bonus_Y
		STA	AI_Y_Aim
		JSR	Load_AI_Status
		JMP	Load_Direction_DemoAI ;	4 направления
; ───────────────────────────────────────────────────────────────────────────

NoBonus:				; CODE XREF: Demo_AI+8j Demo_AI+Cj
		LDA	Tank_Status+2,X	; Либо бонуса нет,
					; либо он уже взят
					; Далее	производятся проверки танков врагов на жизнеспособность,
					; и если они живы, происходит перенацеливание на них
		BPL	+		; Если <$80, враг умирает
		CMP	#$E0 ; 'р'
		BCS	+		; A>$E0	(если больше,
					; враг зарождается)
		LDA	Tank_X+2,X
		STA	AI_X_Aim
		LDA	Tank_Y+2,X
		STA	AI_Y_Aim
		JSR	Load_AI_Status
		JMP	Load_Direction_DemoAI ;	4 направления
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Demo_AI+1Ej Demo_AI+22j
		LDA	Tank_Status+4,X
		BPL	++		; Если <$80, враг умирает
		CMP	#$E0 ; 'р'
		BCS	++		; A>$E0	(если больше,
					; враг зарождается)
		LDA	Tank_X+4,X
		STA	AI_X_Aim
		LDA	Tank_Y+4,X
		STA	AI_Y_Aim
		JSR	Load_AI_Status
		JMP	Load_Direction_DemoAI ;	4 направления
; ───────────────────────────────────────────────────────────────────────────

++:					; CODE XREF: Demo_AI+34j Demo_AI+38j
		LDA	Tank_Status+3,X
		BPL	EnemiesNotActing ; Если	<$80, враг умирает
		CMP	#$E0 ; 'р'
		BCS	EnemiesNotActing ; A>$E0 (если больше,
					; враг зарождается)
		LDA	Tank_X+3,X
		STA	AI_X_Aim
		LDA	Tank_Y+3,X
		STA	AI_Y_Aim
		JSR	Load_AI_Status
		JMP	Load_Direction_DemoAI ;	4 направления
; ───────────────────────────────────────────────────────────────────────────

EnemiesNotActing:			; CODE XREF: Demo_AI+4Aj Demo_AI+4Ej
		LDA	#0		; Если танков нет, ничего не делаем
		JMP	SaveButton_DemoAI
; ───────────────────────────────────────────────────────────────────────────

Load_Direction_DemoAI:			; CODE XREF: Demo_AI+19j Demo_AI+2Fj
					; Demo_AI+45j Demo_AI+5Bj
		AND	#3		; 4 направления
		TAY
		LDA	Tank_Direction,Y ; Направление танков в	демо-уровне (в формате порта джойстика)

SaveButton_DemoAI:			; CODE XREF: Demo_AI+60j
		LDX	Counter
		STA	Joypad1_Buttons,X
		STA	Joypad1_Differ,X
		LDA	Tank_Y,X
		CMP	#$C8 ; '╚'
		BCC	Next_Demo_AI
		LDA	Joypad1_Differ,X
		AND	#$F0 ; 'Ё'
		STA	Joypad1_Differ,X

Next_Demo_AI:				; CODE XREF: Demo_AI+73j
		DEC	Counter
		BPL	-
		RTS
; End of function Demo_AI

; ───────────────────────────────────────────────────────────────────────────
Tank_Direction:	.BYTE $13,$43,$23,$83	; DATA XREF: Demo_AI+66r
					; Направление танков в демо-уровне (в формате порта джойстика)

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует TSA блок под танком

Draw_TSA_On_Tank:			; CODE XREF: ROM:Construct_Draw_TSAp
		LDA	TSA_BlockNumber
		AND	#$F
		LDX	Tank_X
		LDY	Tank_Y
		JSR	Draw_TSABlock
		RTS
; End of function Draw_TSA_On_Tank


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Двигает танк в зависимости от	нажатых	кнопок

Move_Tank:				; CODE XREF: ROM:C0EDp
		LDA	Joypad1_Buttons
		AND	#$F0 ; 'Ё'      ; Проверка на нажатые клавиши управления
		BEQ	ArrowNotPressed
		INC	byte_7B
		LDA	#0
		STA	BkgOccurence_Flag
		JMP	+
; ───────────────────────────────────────────────────────────────────────────

ArrowNotPressed:			; CODE XREF: Move_Tank+4j
		LDA	#0
		STA	byte_7B

+:					; CODE XREF: Move_Tank+Cj
		LDA	byte_7B
		CMP	#$14
		BEQ	loc_C6FB
		LDA	Joypad1_Differ
		AND	#$F0 ; 'Ё'      ; Если кнопки направления не
					; нажаты, танк не двигаем
		BEQ	End_Move_Tank
		LDA	Joypad1_Differ
		JSR	Button_To_DirectionIndex ; $FF = кнопки	управления не нажаты
		BMI	End_Move_Tank	; Перестраховка, на случаай, если
					; кнопки управления не нажаты
		JMP	loc_C704
; ───────────────────────────────────────────────────────────────────────────

loc_C6FB:				; CODE XREF: Move_Tank+17j
		LDA	#$F
		STA	byte_7B
		LDA	Joypad1_Buttons
		JSR	Button_To_DirectionIndex ; $FF = кнопки	управления не нажаты

loc_C704:				; CODE XREF: Move_Tank+26j
		TAY
		LDA	Coord_X_Increment,Y
		ASL	A
		ASL	A
		ASL	A
		ASL	A		; Перемещаем танк на 16	пикселей
					; (каждый TSA блок 16х16)
		CLC
		ADC	Tank_X
		STA	Tank_X
		LDA	Coord_Y_Increment,Y
		ASL	A
		ASL	A
		ASL	A
		ASL	A
		CLC
		ADC	Tank_Y
		STA	Tank_Y

End_Move_Tank:				; CODE XREF: Move_Tank+1Dj
					; Move_Tank+24j
		RTS
; End of function Move_Tank


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Обнуляет массив счётчиков убитых врагов

Null_KilledEnms_Count:			; CODE XREF: SetUp_LevelVARs+43p
		LDX	#7
;4 типа	врагов и 2 игрока = массив из 8	байт
		LDA	#0

-:					; CODE XREF: Null_KilledEnms_Count+7j
		STA	Enmy_KlledBy1P_Count,X
		DEX
		BPL	-
		RTS
; End of function Null_KilledEnms_Count


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; if ExitLevel then A=1

LevelEnd_Check:				; CODE XREF: ROM:C21Ep
					; BonusLevel_ButtonCheck+18p
		LDA	HQ_Status	; 80=штаб цел, если ноль то уничтожен
		BEQ	Init_GameOverStr ; Процедура проверяет статусы:	штаба, жизней игроков,
					; количества оставшихся	врагов и если нужно выйти из
					; уровня, на выходе в А	выдаёт 1, если нужно продолжать
					; процедуру уровня, то 0
		LDA	Enemy_Counter	; Если врагов нет, выходим
		BEQ	ExitLevel
		LDA	Player1_Lives
		CLC
		ADC	Player2_Lives	; Если жизней у	всех игроков нет, выходим
		BNE	PlayLevel

Init_GameOverStr:			; CODE XREF: LevelEnd_Check+2j
		LDA	#$70 ; 'p'
		STA	GameOverStr_X
		LDA	#$F0 ; 'Ё'
		STA	GameOverStr_Y
		LDA	#0
		STA	GameOverScroll_Type ; Определяет вид перемещения надписи(0..3)
		LDA	#$11
		STA	GameOverStr_Timer
		LDA	#0		; обнуляем счетчик, чтобы корректно
					; обработать таймер надписи Game Over
		STA	Frame_Counter

ExitLevel:				; CODE XREF: LevelEnd_Check+6j
		LDA	#1
		RTS
; ───────────────────────────────────────────────────────────────────────────

PlayLevel:				; CODE XREF: LevelEnd_Check+Dj
		LDA	#0
		RTS
; End of function LevelEnd_Check

; ───────────────────────────────────────────────────────────────────────────
		LDA	byte_109	; Не использовался
		JSR	Num_To_NumString ; Переводит число из А	в строку NumString
		LDA	#$30 ; '0'
		STA	Char_Index_Base
		LDA	#0
		STA	HighPtr_Byte
		LDA	#$39 ; '9'
		STA	LowPtr_Byte
		LDX	#9
		LDY	#2
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDX	byte_109
		LDA	0,X
		JSR	Num_To_NumString ; Переводит число из А	в строку NumString
		LDA	#0
		STA	HighPtr_Byte
		LDA	#$39 ; '9'
		STA	LowPtr_Byte
		LDX	#$D
		LDY	#2
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDA	#0
		STA	Char_Index_Base
		LDA	Joypad1_Differ
		AND	#4
		BEQ	loc_C792
		INC	byte_109

loc_C792:				; CODE XREF: ROM:C78Dj
		LDA	Joypad1_Differ
		AND	#2
		BEQ	loc_C79B
		DEC	byte_109

loc_C79B:				; CODE XREF: ROM:C796j
		LDA	Joypad1_Differ
		AND	#1
		BEQ	locret_C7AA
		LDA	byte_109
		CLC
		ADC	#$10
		STA	byte_109

locret_C7AA:				; CODE XREF: ROM:C79Fj
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Scroll_TitleScrn:			; CODE XREF: BonusLevel_ButtonCheck-37Ep
		LDA	#0
		STA	Scroll_Byte
		STA	PPU_REG1_Stts

-:					; CODE XREF: Scroll_TitleScrn+15j
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		INC	Scroll_Byte
		LDA	Joypad1_Differ
		AND	#1100b		; Проверка на Select или Start
		BNE	+		; То же	самое, что RTS (?)
		LDA	Scroll_Byte
		CMP	#$F0 ; 'Ё'
		BNE	-
		RTS
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Scroll_TitleScrn+Fj
		PLA			; То же	самое, что RTS (?)
		PLA
		JMP	Title_Loaded
; End of function Scroll_TitleScrn


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует IP/IIP	и число	жизней в правом	углу

Draw_Player_Lives:			; CODE XREF: Battle_Loop+30p
		LDA	#1
		STA	Counter		; По умолчанию отрисовываем жизни обоих	игроков
		STA	byte_6B
		LDA	#$6E ; 'n'
		STA	Char_Index_Base	; c $6E	в VRAM начинаются цифры
		LDA	#>PlayerLives_Icon ; Значок жизней игрока
		STA	HighPtr_Byte
		LDA	#<PlayerLives_Icon ; Значок жизней игрока
		STA	LowPtr_Byte
		LDX	#$1D
		LDY	#$12		; Координаты надписи
		JSR	String_to_Screen_Buffer
		LDA	Level_Mode
		CMP	#2
		BEQ	Draw_2P_Lives	; Рисуем значок	жизней второго игрока
		LDA	CursorPos	; Если выбран один игрок, то
					; не рисуем жизни 2 игрока.
		BNE	Draw_2P_Lives	; Рисуем значок	жизней второго игрока
		LDA	#0
		STA	Counter		; Жизни	второго	игрока уже
					; рисовать не будем
		JMP	Draw_1P_Lives
; ───────────────────────────────────────────────────────────────────────────

Draw_2P_Lives:				; CODE XREF: Draw_Player_Lives+1Dj
					; Draw_Player_Lives+21j
		LDA	#>PlayerLives_Icon ; Рисуем значок жизней второго игрока
		STA	HighPtr_Byte
		LDA	#<PlayerLives_Icon ; Значок жизней игрока
		STA	LowPtr_Byte
		LDX	#$1D
		LDY	#$15
		JSR	String_to_Screen_Buffer

Draw_1P_Lives:				; CODE XREF: Draw_Player_Lives+27j
					; Draw_Player_Lives+5Fj
		LDX	Counter
		LDA	Player1_Lives,X
		SEC
		SBC	#1
		BPL	Draw_LivesDigit
		LDA	#0		; Если жизни отрицательные, рисуем ноль

Draw_LivesDigit:			; CODE XREF: Draw_Player_Lives+40j
		JSR	ByteTo_Num_String
		LDY	#$36 ; '6'
		LDX	#$19
		JSR	PtrToNonzeroStrElem ; Будем читать из числовой строки
		LDA	Counter
		STA	Temp
		ASL	A
		CLC
		ADC	Temp
		CLC
		ADC	#$12		; Y координата жизней на экране
		TAY
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		DEC	Counter
		BPL	Draw_1P_Lives
		LDA	#0
		STA	Char_Index_Base
		STA	byte_6B
		RTS
; End of function Draw_Player_Lives


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_IP:				; CODE XREF: SetUp_LevelVARs+4Cp
		LDA	#>I_p		; надпись IP прямо над жизнями игроков
		STA	HighPtr_Byte
		LDA	#<I_p		; надпись IP прямо над жизнями игроков
		STA	LowPtr_Byte
		LDX	#$1D
		LDY	#$11
		JSR	String_to_Screen_Buffer
		LDA	Level_Mode
		CMP	#2
		BEQ	Draw_IIP	; Если бонус уровень, то игроков всегда	два
		LDA	CursorPos
		BEQ	+

Draw_IIP:				; CODE XREF: Draw_IP+13j
		LDA	#>II_p		; надпись IIP прямо над	жизнями	игроков
		STA	HighPtr_Byte
		LDA	#<II_p		; надпись IIP прямо над	жизнями	игроков
		STA	LowPtr_Byte
		LDX	#$1D
		LDY	#$14
		JSR	String_to_Screen_Buffer

+:					; CODE XREF: Draw_IP+17j
		RTS
; End of function Draw_IP


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_LevelFlag:				; CODE XREF: SetUp_LevelVARs+4Fp
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	#>LevelFlag_Upper_Icons	; Флажок над номером уровня в правой части экрана
		STA	HighPtr_Byte
		LDA	#<LevelFlag_Upper_Icons	; Флажок над номером уровня в правой части экрана
		STA	LowPtr_Byte
		LDX	#$1D
		LDY	#$17
		JSR	String_to_Screen_Buffer
		LDA	#>LevelFlag_Lower_Icons
		STA	HighPtr_Byte
		LDA	#<LevelFlag_Lower_Icons
		STA	LowPtr_Byte
		LDX	#$1D
		LDY	#$18
		JSR	String_to_Screen_Buffer
		LDA	#$6E ; 'n'
		STA	Char_Index_Base	; C $6E	начинаются цифры жизней	в Pattern Table
		LDA	Level_Number
		JSR	ByteTo_Num_String
		LDY	#$36 ; '6'
		LDX	#$19
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#$19
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDA	#0
		STA	Char_Index_Base
		RTS
; End of function Draw_LevelFlag


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


PointAt_RightScrnColumn:		; CODE XREF: ReinforceToRAMp
					; Draw_EmptyTilep
		PHA
		AND	#1
		CLC
		ADC	#29		; 29 тайлов от начала строки экрана до начала правого информационного столбца
		TAX
		PLA
		LSR	A		; делим	на 2 (в	строке информационного столбца всегда два тайла)
		CLC
		ADC	#3		; информационный столбец отстоит от верхней границы экрана на 3	тайла
		TAY
;X и Y теперь координаты в тайлах куда будет
;записана очередная иконка информационного столбца
		RTS
; End of function PointAt_RightScrnColumn


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


ReinforceToRAM:				; CODE XREF: Draw_Reinforcemets+6p
		JSR	PointAt_RightScrnColumn
		LDA	#>Reinforcement_Icon ;	Составляют лист	оставшихся врагов
		STA	HighPtr_Byte
		LDA	#<Reinforcement_Icon ;	Составляют лист	оставшихся врагов
		STA	LowPtr_Byte
		JSR	String_to_Screen_Buffer
		RTS
; End of function ReinforceToRAM


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует пустой	тайл в колонке запасов врагов, когда они выходят

Draw_EmptyTile:				; CODE XREF: Respawn_Handle+20p
		JSR	PointAt_RightScrnColumn
		LDA	#>Empty_Tile	; Подменяет значок врага, когда	тот рождается
		STA	HighPtr_Byte
		LDA	#<Empty_Tile	; Подменяет значок врага, когда	тот рождается
		STA	LowPtr_Byte
		JSR	String_to_Screen_Buffer
		RTS
; End of function Draw_EmptyTile


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_Reinforcemets:
		LDA	Boss_Mode
		BNE	End_Draw_Reinforcemets			; CODE XREF: SetUp_LevelVARs+46p
		SEC
		LDA	Enemy_Reinforce_Count ;! считаем врагов - они могут измениться, если враг взял бонус жизнь
		SBC	#1
		;LDA #18
		STA	Counter		; В листе запасов врагов будет 20 иконок врагов,
					; здесь	цикл с постусловием, поэтому 18

-:					; CODE XREF: Draw_Reinforcemets+Dj
		LDA	Counter
		JSR	ReinforceToRAM
		DEC	Counter
		;DEC	Counter		; По две иконки	в линии, поэтому уменьшаем 2 раза
		BPL	-
End_Draw_Reinforcemets:
		RTS
; End of function Draw_Reinforcemets


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Не дает танку	выйти за границы серой рамки

Check_BorderReach:			; CODE XREF: ROM:C0F0p
		LDA	Tank_X
		CMP	#$D8 ; '╪'
		BCC	+
		LDA	#$D8 ; '╪'
		STA	Tank_X		; Если правее рамки, присваиваем танку
					; крайнюю правую координату

+:					; CODE XREF: Check_BorderReach+4j
		LDA	Tank_X
		CMP	#$18
		BCS	++
		LDA	#$18
		STA	Tank_X		; Если левее рамки, присваиваем	танку
					; крайнюю левую	координату

++:					; CODE XREF: Check_BorderReach+Ej
		LDA	Tank_Y
		CMP	#$D8 ; '╪'
		BCC	+++
		LDA	#$D8 ; '╪'
		STA	Tank_Y		; Если выше рамки, присваиваем танку
					; крайнюю верхнюю координату

+++:					; CODE XREF: Check_BorderReach+18j
		LDA	Tank_Y
		CMP	#$18
		BCS	End_Check_BorderReach
		LDA	#$18
		STA	Tank_Y		; Если ниже рамки, присваиваем танку
					; крайнюю нижнюю координату

End_Check_BorderReach:			; CODE XREF: Check_BorderReach+22j
		RTS
; End of function Check_BorderReach


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует мигающую надпись, в случае если выставлена пауза

Draw_Pause:				; CODE XREF: ROM:Skip_Pause_Switchp
		LDA	Pause_Flag
		BEQ	End_Draw_Pause	; Если пауза не	выставлена, выходим
		LDA	Frame_Counter
		AND	#$10		; Создаёт мигание надписи раз в	16 фреймов
		BEQ	End_Draw_Pause
;Топорный способ вывода	надписи	"PAUSE"	на экран
		LDA	#3
		STA	TSA_Pal		; Пауза	использует спрайтовую палитру 3
		LDA	#0
		STA	Spr_Attrib	; Надпись поверх форна
		LDX	#$64 ; 'd'      ; Координата Х буквы
		LDY	#$80 ; 'А'      ; Координата Y буквы
		LDA	#$17		; P
		STA	Spr_TileIndex
		JSR	SaveSprTo_SprBuffer ; Сбрасывает в спрайтовый буффер один спрайт 8х16
		LDX	#$6C ; 'l'
		LDY	#$80 ; 'А'
		LDA	#$19		; A
		STA	Spr_TileIndex
		JSR	SaveSprTo_SprBuffer ; Сбрасывает в спрайтовый буффер один спрайт 8х16
		LDX	#$74 ; 't'
		LDY	#$80 ; 'А'
		LDA	#$1B		; U
		STA	Spr_TileIndex
		JSR	SaveSprTo_SprBuffer ; Сбрасывает в спрайтовый буффер один спрайт 8х16
		LDX	#$7C ; '|'
		LDY	#$80 ; 'А'
		LDA	#$1D		; S
		STA	Spr_TileIndex
		JSR	SaveSprTo_SprBuffer ; Сбрасывает в спрайтовый буффер один спрайт 8х16
		LDX	#$84 ; 'Д'
		LDY	#$80 ; 'А'
		LDA	#$1F		; E
		STA	Spr_TileIndex
		JSR	SaveSprTo_SprBuffer ; Сбрасывает в спрайтовый буффер один спрайт 8х16
		LDA	#$20 ; ' '
		STA	Spr_Attrib

End_Draw_Pause:				; CODE XREF: Draw_Pause+2j
					; Draw_Pause+8j
		RTS
; End of function Draw_Pause


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует надпись Game Over, когда она остановилась

Draw_Fixed_GameOver:			; CODE XREF: GameOver_Str_Move_Handle:Stopped_Motionp
		LDA	#3
		STA	TSA_Pal
		LDA	#0
		STA	Spr_Attrib
		LDX	GameOverStr_X
		LDY	GameOverStr_Y
		LDA	#$79 ; 'y'      ; Начало первого спрайта 16х16 надписи Game Over
		STA	Spr_TileIndex
		JSR	Draw_WholeSpr	; Рисуем левую половинку надписи
		LDA	GameOverStr_X
		CLC
		ADC	#$10		; Смещаемся на два тайла вправо	(16 пикселей)
		TAX
		LDY	GameOverStr_Y
		LDA	#$7D ; '}'      ; Начало графики второй половинки надписи в Pattern Table
		STA	Spr_TileIndex
		JSR	Draw_WholeSpr	; Рисуем вторую	половину
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		RTS
; End of function Draw_Fixed_GameOver


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Выводит надпись Game Over если нужно

GameOver_Str_Move_Handle:		; CODE XREF: Battle_Loop+2Ap
		LDA	GameOverStr_Timer
		BEQ	End_GameOver_Str_Move ;	Если надписи нет, выходим
		LDA	Level_Mode
		CMP	#2		; На бонус уровне надпись Game Over не отображается
		BEQ	End_GameOver_Str_Move
		LDA	Frame_Counter
		AND	#$F		; Счётчик уменьшается
					; каждые 16 фреймов
		BNE	Check_Motion
		DEC	GameOverStr_Timer
		BNE	Check_Motion

Hide_String:				; Если время кончилось,
		LDA	#$F0 ; 'Ё'      ; прячем надпись
		STA	GameOverStr_Y

Check_Motion:				; CODE XREF: GameOver_Str_Move_Handle+Fj
					; GameOver_Str_Move_Handle+14j
		LDA	GameOverStr_Timer
		CMP	#10		; за 10	циклов до исчезновения
					; надпись останавливается
		BCC	Stopped_Motion
		LDA	GameOverScroll_Type ; Определяет вид перемещения надписи(0..3)
		TAY
		LDA	Coord_X_Increment,Y
		CLC
		ADC	GameOverStr_X
		STA	GameOverStr_X
		LDA	Coord_Y_Increment,Y
		CLC
		ADC	GameOverStr_Y
		STA	GameOverStr_Y

Stopped_Motion:				; CODE XREF: GameOver_Str_Move_Handle+20j
		JSR	Draw_Fixed_GameOver ; Рисует надпись Game Over,	когда она остановилась

End_GameOver_Str_Move:			; CODE XREF: GameOver_Str_Move_Handle+3j
					; GameOver_Str_Move_Handle+9j
		RTS
; End of function GameOver_Str_Move_Handle


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Make_GrayFrame:				; CODE XREF: ROM:C0B5p	ROM:C1D4p
					; Load_DemoLevel+19p
					; Show_Secret_Msg+C1p
		LDA	#2
		STA	Block_X
		STA	Block_Y		; Рамочка шириной 2 тайла по вертикали и горизонтали
					; (потом к ней прибавляется правый информационный столбец)
					; На самом деле, сначала весь экран заполняется	серым, потом
					; в нем	отрисовывается черный квадрат игрового поля
		LDA	#$1A
		STA	Counter		; $19 -	ширина и высота	игрового поля (в процедуре от $1A отнимается единица)
					; Counter - будет играть роль высоты
					; Counter2 - ширины
		STA	Counter2
		JSR	Draw_GrayFrame
		RTS
; End of function Make_GrayFrame


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Title_Screen_Loop:			; CODE XREF: BonusLevel_ButtonCheck:Title_Loadedp ; выходы по JMP	на разные команды
		LDA	#3
		STA	BkgPal_Number	; По RTS - загрузка демо-ролика
		LDA     #$24
		STA     PPU_Addr_Ptr;Пишем в нижнюю тайловую карту		

		JSR	Null_Status
		LDA	#$48 ; 'H'      ; X на титульнике изменяться не будет
		STA	Tank_X
		JSR	CurPos_To_PixelCoord
		LDA	#$83
		STA	Tank_Status	; Танк направлен дулом вправо
		LDA	#0
		Sta	Random_Level_Flag
		STA	Seconds_Counter	; Обнуление таймера
		STA	Tank_Type
		STA	Track_Pos
		STA	Player_Blink_Timer ; Таймер мигания friendly fire
		STA	Player_Blink_Timer+1 ; Таймер мигания friendly fire
		STA	Scroll_Byte
		LDA	#2
		STA	PPU_REG1_Stts

Begin_Title_Screen_Loop:					; CODE XREF: Title_Screen_Loop+81j
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	Frame_Counter
		AND	#3
		BNE	+		; Каждые 3 фрейма смещаем гусеницу
		LDA	Track_Pos
		EOR	#4
		STA	Track_Pos

+:					; CODE XREF: Title_Screen_Loop+2Dj
		JSR	TanksStatus_Handle ; Обрабатывает статусы всех 8-ми танков

;Проверяем на вправо-влево:
		Lda	CursorPos
		Cmp	#3
		BNE	Check_Select

		LDA	Joypad1_Differ
		AND	#$40		; проверка на left
		BEQ +++
		LDA	#0
		STA	Seconds_Counter
		Dec Map_Mode_Pos
		BPL Draw_Map_Mode
		LDA #2
		STA Map_Mode_Pos
		JMP Draw_Map_Mode



+++:
		LDA	Joypad1_Differ
		AND	#$80		; проверка на right
		BEQ Check_Select
		LDA	#0
		STA	Seconds_Counter
		INC Map_Mode_Pos
		LDA Map_Mode_Pos
		CMP #3
		BCC Draw_Map_Mode
		Lda #0
		STA Map_Mode_Pos

Draw_Map_Mode:
		LDA	Map_Mode_Pos	
		ASL	A		; х2 (указатели	двухбайтовые)
		TAY
		LDA	MAP_MODE_STRINGS,Y
		STA	LowPtr_Byte
		LDA	MAP_MODE_STRINGS+1,Y
		STA	HighPtr_Byte
		LDX	#$11
		LDY	#$17
		JSR	Save_Str_To_ScrBuffer
		



Check_Select:
		LDA	Joypad1_Differ
		AND	#4		; проверка на select
		BEQ	Check_Max_CurPos
		INC	CursorPos
		LDA	#0
		STA	Seconds_Counter

Check_Max_CurPos:			; CODE XREF: Title_Screen_Loop+5Bj
					; Title_Screen_Loop+61j
		LDA	CursorPos
		CMP	#4;! добавили еще один пункт меню
		BCC	++
		LDA	#0
		STA	CursorPos

++:					; CODE XREF: Title_Screen_Loop+69j
		JSR	CurPos_To_PixelCoord
		LDA	Seconds_Counter
		CMP	#10		; Проверка на время начала Демо-ролика(10 секунд)
		BNE	Start_Check
		LDA	Construction_Flag ; Если были в	Construction, не показываем демо-уровень
		BNE	Start_Check
		LDA	#$1C
		STA     PPU_Addr_Ptr
		RTS			; Загружаем Демо-ролик
; ───────────────────────────────────────────────────────────────────────────

Start_Check:				; CODE XREF: Title_Screen_Loop+76j
					; Title_Screen_Loop+7Aj
		LDA	Joypad1_Differ
		AND	#8		; проверка на старт
		Bne	++++
		JMP 	Begin_Title_Screen_Loop
++++:
		LDA	Construction_Flag ; Выставляется, если зашли в Construction
		CMP	#7
		BNE	Start_Pressed
Start_Pressed:				; CODE XREF: Title_Screen_Loop+87j
					; Title_Screen_Loop+8Dj
		LDA	#0
		STA	BkgPal_Number
		PLA
		PLA			; чтобы	не переполнить стек при	рекурсии
		LDA	CursorPos	; В зависимости	от позиции курсора выполняем команды
		ASL	A		; х2 (указатели	двухбайтовые)
		TAY
		LDA	Title_JumpTable,Y
		STA	LowPtr_Byte
		LDA	Title_JumpTable+1,Y
		STA	HighPtr_Byte
		LDA	#$1C
		STA     PPU_Addr_Ptr
		JMP	(LowPtr_Byte)
; End of function Title_Screen_Loop

; ───────────────────────────────────────────────────────────────────────────
;Загружается командами сверху
Title_JumpTable:.WORD Selected_1player	; DATA XREF: Title_Screen_Loop+9Cr
					; Title_Screen_Loop+A1r
					; Если игрок 1,	то на экране может быть	4 врага
		.WORD Selected_2players	; Если игроков двое, то	на экране может	быть 6 врагов
		.WORD Selected_Construction
		.WORD Title_Loaded ; При нажатии на старт на выборе режима, прыгаем к 1player
; ───────────────────────────────────────────────────────────────────────────

Selected_1player:			; DATA XREF: ROM:Title_JumpTableo
		LDA	#5		; Если игрок 1,	то на экране может быть	4 врага
		JMP	accept
; ───────────────────────────────────────────────────────────────────────────

Selected_2players:			; DATA XREF: ROM:CA6Bo
		LDA	#7		; Если игроков двое, то	на экране может	быть 6 врагов

accept:					; CODE XREF: ROM:CA71j
		STA	TanksOnScreen	; Максимальное количество всех танков на экране
		JSR	Null_both_HiScore
		JMP	Start_StageSelScrn
; ───────────────────────────────────────────────────────────────────────────

Selected_Construction:			; DATA XREF: ROM:CA6Do
		LDA	#7
		STA	TanksOnScreen	; ? к чему бы это - на экране только игрок...
		JMP	Construction

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


CurPos_To_PixelCoord:			; CODE XREF: Title_Screen_Loop+Bp
					; Title_Screen_Loop:Plusp
		LDA	CursorPos
		ASL	A
		ASL	A
		ASL	A
		ASL	A		; Умножаем на 16 (между	пунктами меню 2	тайла по 8 пикселей)
		CLC
		ADC	#$8B ; 'Л'      ; От верхней границы экрана до первого пункта меню по вертикали $88 пикселей
		STA	Tank_Y
		RTS
; End of function CurPos_To_PixelCoord


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_StageNumString:			; CODE XREF: ROM:StageSelect_Loopp
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDX	#$C		; Координаты в тайлах размещения строки	на экране
		LDY	#$E
		JSR	CoordTo_PPUaddress
		LDX	ScrBuffer_Pos
		CLC
		ADC	#$1C
		STA	Screen_Buffer,X	; Старший байт адреса в	PPU
		INX
		TYA
		STA	Screen_Buffer,X	; Младший байт
		INX
		LDY	#0
;Если нужно, выводим надпись Boss Stage

		LDA Boss_Mode
		BEQ Skip_Draw_BossStage
-:		
		LDA 	aBoss,y
		STA	Screen_Buffer,X	
		INY
		INX
		CMP 	#$FF
		BNE -	

		STX	ScrBuffer_Pos
		LDA	#$6E ; 'n'      ; С $6E в Pattern Table начинается графика цифр
		STA	Char_Index_Base
		LDA	Level_Number;
		LSR
		LSR
		LSR
		
		JSR	ByteTo_Num_String
		LDY	#Num_String+1
		LDX	#$12		; Координата Х выводимой цифры
		JMP	End_Stage_Draw	



Skip_Draw_BossStage:

--:		
		LDA 	aStageScr,y
		STA	Screen_Buffer,X	
		INY
		INX
		CMP 	#$FF
		BNE --	

		STX	ScrBuffer_Pos
		LDA	#$6E ; 'n'      ; С $6E в Pattern Table начинается графика цифр
		STA	Char_Index_Base
		LDA	Level_Number;! номер уровня
		JSR	ByteTo_Num_String
		LDY	#Num_String+1
		LDX	#$E		; Координата Х выводимой цифры
End_Stage_Draw:
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#$E		; Координата Y выводимой цифры
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDA	#0
		STA	Char_Index_Base
		RTS
; End of function Draw_StageNumString



; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует штаб с	кирпичами

DraW_Normal_HQ:				; CODE XREF: ROM:C0E7p	ROM:C1DCp
					; Load_DemoLevel+5Dp
					; HQ_Handle:Normal_HQ_Handlep
		LDA	#>Normal_HQ_TSA
		STA	HighPtr_Byte
		LDA	#<Normal_HQ_TSA
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$18
		JSR	String_to_Screen_Buffer
		LDA	#>NormalLine2
		STA	HighPtr_Byte
		LDA	#<NormalLine2
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$19
		JSR	String_to_Screen_Buffer
		LDA	#>NormalLine3
		STA	HighPtr_Byte
		LDA	#<NormalLine3
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$1A
		JSR	String_to_Screen_Buffer
		LDA	#>Normalline4
		STA	HighPtr_Byte
		LDA	#<Normalline4
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$1B
		JSR	String_to_Screen_Buffer	; Выводим штаб через Строковый Буффер
		LDX	ScrBuffer_Pos
		LDA	#$23 ; '#'
		STA	Screen_Buffer,X
		INX
		LDA	#$F3 ; 'є'
		STA	Screen_Buffer,X	; Запись в память PPU $23F3 (атрибуты штаба)
		INX
		LDA	#0
		STA	NT_Buffer+$3F3
		STA	Screen_Buffer,X
		INX
		LDA	NT_Buffer+$3F4
		AND	#$CC ; '╠'
		STA	NT_Buffer+$3F4
		STA	Screen_Buffer,X	; Выставляем атрибуты штаба
		INX
		LDA	#$FF
		STA	Screen_Buffer,X	; Конец	строки
		INX
		STX	ScrBuffer_Pos
		RTS
; End of function DraW_Normal_HQ


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_Naked_HQ:				; CODE XREF: ROM:Skip_Lvl_Loadp
		LDA	#>Naked_HQ_TSA_FirstLine
		STA	HighPtr_Byte
		LDA	#<Naked_HQ_TSA_FirstLine
		STA	LowPtr_Byte
		LDX	#$E
		LDY	#$1A		; Координаты верхней линии голого штаба
		JSR	String_to_Screen_Buffer
		LDA	#>Naked_HQ_TSA_SecndLine
		STA	HighPtr_Byte
		LDA	#<Naked_HQ_TSA_SecndLine
		STA	LowPtr_Byte
		LDX	#$E
		LDY	#$1B		; Координаты нижней линии голого штаба
		JSR	String_to_Screen_Buffer

		LDX	ScrBuffer_Pos
		LDA	#$23 ; '#'
		STA	Screen_Buffer,X
		INX
		LDA	#$F3 ; 'є'
		STA	Screen_Buffer,X	; Запись следующего стринга будет в адрес PPU $23F3
					; (атрибут верхней карты тайлов)
		INX
		LDA	NT_Buffer+$3F3
		AND	#111111b
		STA	NT_Buffer+$3F3	; Штаб использует нулевую палитру, поэтому старшие
					; три бита обнуляют, хотя достаточно обнулить и	два
					; (адрес байта атрибута	вписан в операнды жестко,
					; но для отладки сойдёт)
		STA	Screen_Buffer,X
		INX
		LDA	#$FF
		STA	Screen_Buffer,X	; Конец	строки
		INX
		STX	ScrBuffer_Pos
		RTS
; End of function Draw_Naked_HQ


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует штаб с	броней

Draw_ArmourHQ:				; CODE XREF: HQ_Handle+20p ROM:E9FFp
		LDA	#>Armour_HQ_TSA_Line1
		STA	HighPtr_Byte
		LDA	#<Armour_HQ_TSA_Line1
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$18
		JSR	String_to_Screen_Buffer
		LDA	#>Armour_HQ_TSA_Line2
		STA	HighPtr_Byte
		LDA	#<Armour_HQ_TSA_Line2
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$19
		JSR	String_to_Screen_Buffer
		LDA	#>Armour_HQ_TSA_Line3
		STA	HighPtr_Byte
		LDA	#<Armour_HQ_TSA_Line3
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$1A
		JSR	String_to_Screen_Buffer
		LDA	#>Armour_HQ_TSA_Line4
		STA	HighPtr_Byte
		LDA	#<Armour_HQ_TSA_Line4
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$1B
		JSR	String_to_Screen_Buffer
		LDX	ScrBuffer_Pos	; Выводим бронированый штаб через строковый буффер
		LDA	#$23 ; '#'
		STA	Screen_Buffer,X
		INX
		LDA	#$F3 ; 'є'
		STA	Screen_Buffer,X	; Будем	писать в область атрибутов ($23F3)
		INX
		LDA	#$3F ; '?'
		STA	NT_Buffer+$3F3
		STA	Screen_Buffer,X
		INX
		LDA	NT_Buffer+$3F4
		AND	#$CC ; '╠'
		ORA	#$33 ; '3'
		STA	NT_Buffer+$3F4
		STA	Screen_Buffer,X
		INX
		LDA	#$FF
		STA	Screen_Buffer,X	; Конец	строки атрибутов
		INX
		STX	ScrBuffer_Pos
		RTS
; End of function Draw_ArmourHQ


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует разрушенный штаб

Draw_Destroyed_HQ:			; CODE XREF: BulletToObject_Impact_Handle+20p
		LDA	#>DestroyedHQ_TSA_Line1
		STA	HighPtr_Byte
		LDA	#<DestroyedHQ_TSA_Line1
		STA	LowPtr_Byte
		LDX	#$E
		LDY	#$1A
		JSR	String_to_Screen_Buffer
		LDA	#>DestroyedHQ_TSA_Line2
		STA	HighPtr_Byte
		LDA	#<DestroyedHQ_TSA_Line2
		STA	LowPtr_Byte
		LDX	#$E
		LDY	#$1B
		JSR	String_to_Screen_Buffer
		RTS
; End of function Draw_Destroyed_HQ

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

;! Рисует штаб после взятия врагом лопаты

Draw_ShovelHQ:				
		LDA	#>Shovel_HQ_TSA_Line1
		STA	HighPtr_Byte
		LDA	#<Shovel_HQ_TSA_Line1
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$18
		JSR	String_to_Screen_Buffer
		LDA	#>Shovel_HQ_TSA_Line2
		STA	HighPtr_Byte
		LDA	#<Shovel_HQ_TSA_Line2
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$19
		JSR	String_to_Screen_Buffer
		LDA	#>Shovel_HQ_TSA_Line3
		STA	HighPtr_Byte
		LDA	#<Shovel_HQ_TSA_Line3
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$1A
		JSR	String_to_Screen_Buffer
		LDA	#>Shovel_HQ_TSA_Line4
		STA	HighPtr_Byte
		LDA	#<Shovel_HQ_TSA_Line4
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$1B
		JSR	String_to_Screen_Buffer
		LDX	ScrBuffer_Pos	; Выводим бронированый штаб через строковый буффер
		RTS
; End of function Draw_ShovelHQ


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Copy_AttribToScrnBuff:			; CODE XREF: ROM:C1E9p
		LDY	#0
;Процедура копирует атрибуты из	NTBuffer в ScreenBuffer, переводя в соответствующий фромат
		LDA	#$23 ; '#'
		STA	HighPtr_Byte
		LDA	#$C0 ; '└'
		STA	LowPtr_Byte	; Запись будет вестись в область атрибутов верхней NT

-:					; CODE XREF: Copy_AttribToScrnBuff+32j
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDX	ScrBuffer_Pos
		LDA	HighPtr_Byte
		STA	Screen_Buffer,X
		INX
		LDA	LowPtr_Byte
		STA	Screen_Buffer,X	; Сначала сохраняем в буффер строк адрес PPU,
					; куда будет вестить запись
		INX
		LDA	NT_Buffer+$3C0,Y
		INY
		STA	Screen_Buffer,X
		INX
		LDA	#$FF
		STA	Screen_Buffer,X	; Сохраняем каждый байт	атрибута в виде	строки
					; в спрайтовый буффер
		INX
		STX	ScrBuffer_Pos
		LDA	#1
		JSR	Inc_Ptr_on_A
		CPY	#$40 ; '@'      ; Количество байт в таблице атрибутов
		BNE	-
		RTS
; End of function Copy_AttribToScrnBuff


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Заполняет один ряд тайлов Iterative_Byte'ом

FillScr_Single_Row:			; CODE XREF: FillNT_with_Grey+Dp
					; FillNT_with_Grey+16p
					; FillNT_with_Black+Dp
					; FillNT_with_Black+16p
		LDX	#0
		JSR	CoordTo_PPUaddress
		STA	HighPtr_Byte
		STY	LowPtr_Byte
		LDX	ScrBuffer_Pos
		LDA	HighPtr_Byte
		CLC
		ADC	#$1C
		STA	Screen_Buffer,X
		INX
		LDA	LowPtr_Byte
		STA	Screen_Buffer,X
		INX
		LDY	#0

-:					; CODE XREF: FillScr_Single_Row+29j
		LDA	Iterative_Byte	; Байт,	заполняющий большие массивы данных
		BNE	+
		LDA	(LowPtr_Byte),Y

+:					; CODE XREF: FillScr_Single_Row+1Ej
		STA	Screen_Buffer,X
		INX
		INY
		CPY	#$20 ; ' '
		BNE	-
		LDA	#$FF
		STA	Screen_Buffer,X
		INX
		STX	ScrBuffer_Pos
		RTS
; End of function FillScr_Single_Row


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; создаёт эффект сходящихся вертикальных створок

FillNT_with_Grey:			; CODE XREF: ROM:C16Fp
		LDA	#$11
		STA	Iterative_Byte	; Пустой серый тайл
		LDA	#0
		STA	Block_Y		; Начинаем заполнять экран с начала

-:					; CODE XREF: FillNT_with_Grey+1Fj
		JSR	NMI_Wait	; Задержка до отрисовки	экрана:	благодаря ей, игрок
					; успевает увидеть процесс заполнения экрана.
		LDY	Block_Y
		JSR	FillScr_Single_Row ; Заполняет один ряд	тайлов Iterative_Byte'ом
		LDA	#$1D		; Экран	240 пикселей (или $1E тайлов) в	высоту
		SEC
		SBC	Block_Y		; Заполняем экран по одному ряду тайлов	сверху и снизу,
					; создавая эффект сходящихся вертикальных створок
		TAY
		JSR	FillScr_Single_Row ; Заполняет один ряд	тайлов Iterative_Byte'ом
		INC	Block_Y
		LDA	Block_Y
		CMP	#$10		; $10 проходов заполняют $20 рядов тайлов
					; или $400 байт	(т.е. и	атрибуты тайловых карт тоже)
		BNE	-		; Задержка до отрисовки	экрана:	благодаря ей, игрок
					; успевает увидеть процесс заполнения экрана.
		RTS
; End of function FillNT_with_Grey


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Создаёт эффект расходящихся вертикальных створок

FillNT_with_Black:			; CODE XREF: ROM:C1ECp
		LDA	#0
		STA	Iterative_Byte	; Пустой чёрный	тайл
		LDA	#$F
		STA	Block_Y		; Начинаем заполнять экран с середины (от надписи 'STAGE XX')

-:					; CODE XREF: FillNT_with_Black+1Fj
		JSR	NMI_Wait	; Задержка до отрисовки	экрана:	благодаря ей, игрок
					; успевает увидеть процесс заполнения экрана.
		LDY	Block_Y
		JSR	FillScr_Single_Row ; Заполняет один ряд	тайлов Iterative_Byte'ом
		LDA	#$1D		; Экран	240 пикселей (или $1E тайлов) в	высоту
		SEC
		SBC	Block_Y		; Заполняем экран по одному ряду тайлов	сверху и снизу,
					; создавая эффект расходящихся вертикальных створок
		TAY
		JSR	FillScr_Single_Row ; Заполняет один ряд	тайлов Iterative_Byte'ом
		DEC	Block_Y
		LDA	Block_Y
		CMP	#$FF		; Доходим до конца экрана
		BNE	-		; Задержка до отрисовки	экрана:	благодаря ей, игрок
					; успевает увидеть процесс заполнения экрана.
		RTS
; End of function FillNT_with_Black


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_Pts_Screen:			; CODE XREF: ROM:C256p
		JSR	Draw_Pts_Screen_Template ; Рисует общий	для всех уровней экран очков
		LDX	#$1E
		JSR	DrawTankColumn_XTimes ;	Рисует колонку из 4-х вражеских	танков X раз (задержка в Х фреймов)
		LDA	Enmy_KlledBy1P_Count
		CLC
		ADC	Enmy_KlledBy1P_Count+1
		CLC
		ADC	Enmy_KlledBy1P_Count+2
		CLC
		ADC	Enmy_KlledBy1P_Count+3
		STA	TotalEnmy_KilledBy1P
		LDA	Enmy_KlledBy2P_Count
		CLC
		ADC	Enmy_KlledBy2P_Count+1
		CLC
		ADC	Enmy_KlledBy2P_Count+2
		CLC
		ADC	Enmy_KlledBy2P_Count+3
		STA	TotalEnmy_KilledBy2P ; Вычисляем общее количество очков
		LDA	#0
		STA	Counter

DrawPtsScrn_NxtTank:			; CODE XREF: Draw_Pts_Screen+11Dj
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		JSR	Draw_Tank_Column ; Рисует колонку из 4-х вражеских танков
		LDX	#Temp_1PPts_String ; Строка при	подсчете очков за текущий вид танка
		JSR	Null_8Bytes_String
		LDX	#Temp_2PPts_String
		JSR	Null_8Bytes_String
		LDA	#0
		STA	BrickChar_X
		STA	BrickChar_Y

DrawPtsScrn_NxtCount:			; CODE XREF: Draw_Pts_Screen+10Dj
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		JSR	Draw_Tank_Column ; Рисует колонку из 4-х вражеских танков
		LDA	#0
		STA	EndCount_Flag	; Если 0, завершить подсчет очков для текущего врага
		LDX	Counter
		LDA	TankKill_Pts,X	; Количество очков за каждый тип убитого врага
		JSR	Num_To_NumString ; Переводит число из А	в строку NumString
		LDX	Counter
		LDA	Enmy_KlledBy1P_Count,X
		BEQ	++
		LDA	#1
		STA	Snd_PtsCount1
		STA	Snd_PtsCount2
		DEC	Enmy_KlledBy1P_Count,X
		INC	BrickChar_X
		LDX	#2
		JSR	Add_Score	; Прибавляет число из NumString	к очкам	игрока №Х
		LDA	#1
		STA	EndCount_Flag	; Если 0, завершить подсчет очков для текущего врага
		JSR	Add_Life	; Прибавляет одну жизнь, если игрок заработал 200К очков

++:					; CODE XREF: Draw_Pts_Screen+52j
		LDX	Counter
		LDA	Enmy_KlledBy2P_Count,X
		BEQ	+++
		LDA	#1
		STA	Snd_PtsCount1
		STA	Snd_PtsCount2
		DEC	Enmy_KlledBy2P_Count,X
		INC	BrickChar_Y
		LDX	#3
		JSR	Add_Score	; Прибавляет число из NumString	к очкам	игрока №Х
		LDA	#1
		STA	EndCount_Flag	; Если 0, завершить подсчет очков для текущего врага
		JSR	Add_Life	; Прибавляет одну жизнь, если игрок заработал 200К очков

+++:					; CODE XREF: Draw_Pts_Screen+70j
		LDY	#HiScore_1P_String+1
		LDX	#5
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDX	#1
		LDY	#Temp_1PPts_String+1 ; Строка при подсчете очков за текущий вид	танка
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDA	Counter
		ASL	A
		CLC
		ADC	Counter
		CLC
		ADC	#$C
		TAY
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDX	Counter
		LDA	BrickChar_X
		JSR	ByteTo_Num_String
		LDX	#8
		LDY	#Num_String+1
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDA	Counter
		ASL	A
		CLC
		ADC	Counter
		CLC
		ADC	#$C
		TAY
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDA	CursorPos
		BEQ	+		; Если игрок один, очки	не выводим
		LDY	#HiScore_2P_String+1
		LDX	#$17
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDX	#$13
		LDY	#Temp_2PPts_String+1
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDA	Counter
		ASL	A
		CLC
		ADC	Counter
		CLC
		ADC	#$C
		TAY
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDX	Counter
		LDA	BrickChar_Y
		JSR	ByteTo_Num_String
		LDX	#$E
		LDY	#Num_String+1
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDA	Counter
		ASL	A
		CLC
		ADC	Counter
		CLC
		ADC	#$C
		TAY
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер

+:					; CODE XREF: Draw_Pts_Screen+C7j
		LDX	#8
		JSR	DrawTankColumn_XTimes ;	Рисует колонку из 4-х вражеских	танков X раз (задержка в Х фреймов)

loc_CDDD:				; Если 0, завершить подсчет очков для текущего врага
		LDA	EndCount_Flag
		BEQ	++++
		JMP	DrawPtsScrn_NxtCount
; ───────────────────────────────────────────────────────────────────────────

++++:					; CODE XREF: Draw_Pts_Screen+10Bj
		INC	Counter
		LDA	Counter
		CMP	#4		; 4 типа танков
		BEQ	loc_CDF4
		LDX	#$14
		JSR	DrawTankColumn_XTimes ;	Рисует колонку из 4-х вражеских	танков X раз (задержка в Х фреймов)
		JMP	DrawPtsScrn_NxtTank
; ───────────────────────────────────────────────────────────────────────────

loc_CDF4:				; CODE XREF: Draw_Pts_Screen+116j
		LDX	#$1E
		JSR	DrawTankColumn_XTimes ;	Рисует колонку из 4-х вражеских	танков X раз (задержка в Х фреймов)
		LDA	TotalEnmy_KilledBy1P
		JSR	ByteTo_Num_String
		LDY	#Num_String+1
		LDX	#8
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#$17
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDA	CursorPos
		BEQ	+++++
		LDA	TotalEnmy_KilledBy2P
		JSR	ByteTo_Num_String
		LDY	#Num_String+1
		LDX	#$E
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#$17
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер

+++++:					; CODE XREF: Draw_Pts_Screen+138j
		LDX	#$F
		JSR	DrawTankColumn_XTimes ;	Рисует колонку из 4-х вражеских	танков X раз (задержка в Х фреймов)

;! Если победили босса, в любом случае рисуем бонус у одного из игроков даже если он играл один.
		LDA	Boss_Mode
		BNE	DrawPtsScrn_CheckHQ:

Skip_Boss_Bonus:
		LDA	CursorPos
		BNE	DrawPtsScrn_CheckHQ
		JMP	End_Draw_Pts_Screen
; ───────────────────────────────────────────────────────────────────────────

DrawPtsScrn_CheckHQ:			; CODE XREF: Draw_Pts_Screen+152j
		LDA	HQ_Status	; 80=штаб цел, если ноль то уничтожен
		BNE	DrawPtsScrn_CheckNum
		JMP	End_Draw_Pts_Screen
; ───────────────────────────────────────────────────────────────────────────

DrawPtsScrn_CheckNum:			; CODE XREF: Draw_Pts_Screen+159j

		LDA	TotalEnmy_KilledBy2P
		CMP	TotalEnmy_KilledBy1P
		BCS	DrawPtsScrn_CheckLives
Chk_Lives:
		LDA	Player1_Lives
		BEQ	DrawPtsScrn_CheckLives
		LDA	#0		; Рисуем под IP	слово BONUS! 1000PTS
					; Если количество очков	1 игрока больше, и
					; он остался жив

Draw_IP_Bonus:
		JSR	Num_To_NumString ; Переводит число из А	в строку NumString
		LDX	#0
		JSR	Add_Score	; Прибавляет число из NumString	к очкам	игрока №Х
		LDY	#HiScore_1P_String+1
		LDX	#5
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDY	#Num_String+1
		LDX	#1
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#$1A
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDA	#>aBonus	; "BONUS\x15\xFF"
		STA	HighPtr_Byte
		LDA	#<aBonus	; "BONUS\x15\xFF"
		STA	LowPtr_Byte
		LDX	#3
		LDY	#$19
		JSR	String_to_Screen_Buffer
		LDA	#>aPts		; "PTS\xFF"
		STA	HighPtr_Byte
		LDA	#<aPts		; "PTS\xFF"
		STA	LowPtr_Byte
		LDX	#8
		LDY	#$1A
		JSR	String_to_Screen_Buffer
		LDA	#1
		STA	Snd_BonusPts
		STA	byte_31C
		STA	byte_31D
		JSR	Add_Life	; Прибавляет одну жизнь, если игрок заработал 200К очков
		JMP	End_Draw_Pts_Screen
; ───────────────────────────────────────────────────────────────────────────

DrawPtsScrn_CheckLives:			; CODE XREF: Draw_Pts_Screen+162j
					; Draw_Pts_Screen+166j
		LDA	TotalEnmy_KilledBy1P
		CMP	TotalEnmy_KilledBy2P
		BCS	End_Draw_Pts_Screen
		LDA	Player2_Lives
		BEQ	End_Draw_Pts_Screen
		LDA	#0		; Рисуем под IIP слово BONUS! 1000PTS
					; Если количество очков	2 игрока больше, и
					; он остался жив
		JSR	Num_To_NumString ; Переводит число из А	в строку NumString
		LDX	#1
		JSR	Add_Score	; Прибавляет число из NumString	к очкам	игрока №Х
		LDY	#HiScore_2P_String+1
		LDX	#$17
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDY	#Num_String+1
		LDX	#$14
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#$1A
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDA	#>aBonus	; "BONUS\x15\xFF"
		STA	HighPtr_Byte
		LDA	#<aBonus	; "BONUS\x15\xFF"
		STA	LowPtr_Byte
		LDX	#$16
		LDY	#$19
		JSR	String_to_Screen_Buffer
		LDA	#>aPts		; "PTS\xFF"
		STA	HighPtr_Byte
		LDA	#<aPts		; "PTS\xFF"
		STA	LowPtr_Byte
		LDX	#$1B
		LDY	#$1A
		JSR	String_to_Screen_Buffer
		LDA	#1
		STA	Snd_BonusPts	; Играем музыку	бонуса
		STA	byte_31C
		STA	byte_31D
		JSR	Add_Life	; Прибавляет одну жизнь, если игрок заработал 200К очков

End_Draw_Pts_Screen:			; CODE XREF: Draw_Pts_Screen+154j
					; Draw_Pts_Screen+15Bj
					; Draw_Pts_Screen+1B6j
					; Draw_Pts_Screen+1BDj
					; Draw_Pts_Screen+1C1j
		LDX	#Enmy_KlledBy2P_Count+1
		JSR	DrawTankColumn_XTimes ;	Рисует колонку из 4-х вражеских	танков X раз (задержка в Х фреймов)
		LDA	#0		; Начало загрузки экрана выбора	уровня
		STA	PPU_REG1_Stts
		STA	Char_Index_Base
		STA	byte_6B
		LDA	#0
		STA	BkgPal_Number
		RTS
; End of function Draw_Pts_Screen


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует общий для всех	уровней	экран очков

Draw_Pts_Screen_Template:		; CODE XREF: Draw_Pts_Screenp
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	#1
		STA	byte_6B
		LDA	#$24 ; '$'
		STA	PPU_Addr_Ptr
		LDA	#0
		STA	Scroll_Byte
		LDA	#10b
		STA	PPU_REG1_Stts
		LDA	#$30 ; '0'
		STA	Char_Index_Base	; Начало графики цифр
		LDA	#3
		STA	BkgPal_Number
		JSR	Screen_Off
		JSR	Null_NT_Buffer
		JSR	Fill_Attrib_Table ; Сохраняет определенные атрибуты в NT_Buffer
		JSR	Store_NT_Buffer_InVRAM ; Сбрасывает на экран содержимое	NT_Buffer
		JSR	Set_PPU
		LDA	#>aHikscore	; k=тире
		STA	HighPtr_Byte
		LDA	#<aHikscore	; k=тире
		STA	LowPtr_Byte
		LDX	#8
		LDY	#3
		JSR	String_to_Screen_Buffer
		LDY	#HiScore_String+1
		LDX	#$12
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#3
		JSR	Save_Str_To_ScrBuffer ;	Выводим	Hi-score
		LDA	#>aStage	; "STAGE\xFF"
		STA	HighPtr_Byte
		LDA	#<aStage	; "STAGE\xFF"
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#5
		JSR	String_to_Screen_Buffer
		LDA	Level_Number
		JSR	ByteTo_Num_String
		LDY	#Num_String+1
		LDX	#$E
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#5
		JSR	Save_Str_To_ScrBuffer ;	Рисуем номер уровня
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	#>aKplayer	; 'I-PLAYER'
		STA	HighPtr_Byte
		LDA	#<aKplayer	; 'I-PLAYER'
		STA	LowPtr_Byte
		LDX	#3
		LDY	#7
		JSR	String_to_Screen_Buffer
		LDY	#HiScore_1P_String+1
		LDX	#5
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	Рисуем очки первого игрока
		LDA	#>Arrow_Left
		STA	HighPtr_Byte
		LDA	#<Arrow_Left
		STA	LowPtr_Byte
		LDX	#$E
		LDY	#$C
		JSR	String_to_Screen_Buffer	; Рисуем стрелку влево 4 раза
		LDA	#>Arrow_Left
		STA	HighPtr_Byte
		LDA	#<Arrow_Left
		STA	LowPtr_Byte
		LDX	#$E
		LDY	#$F
		JSR	String_to_Screen_Buffer
		LDA	#>Arrow_Left
		STA	HighPtr_Byte
		LDA	#<Arrow_Left
		STA	LowPtr_Byte
		LDX	#$E
		LDY	#$12
		JSR	String_to_Screen_Buffer
		LDA	#>Arrow_Left
		STA	HighPtr_Byte
		LDA	#<Arrow_Left
		STA	LowPtr_Byte
		LDX	#$E
		LDY	#$15
		JSR	String_to_Screen_Buffer
		LDA	CursorPos
		BEQ	Skip_ScndPlayerDraw ; Если игрок один, стрелку вправо и	II-Player не рисуем
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	#>a_kplayer	; 'II-PLAYER'
		STA	HighPtr_Byte
		LDA	#<a_kplayer	; 'II-PLAYER'
		STA	LowPtr_Byte
		LDX	#$15
		LDY	#7
		JSR	String_to_Screen_Buffer
		LDY	#HiScore_2P_String+1
		LDX	#$17
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDA	#>Arrow_Right	; Используются при подсчёте очков
		STA	HighPtr_Byte
		LDA	#<Arrow_Right	; Используются при подсчёте очков
		STA	LowPtr_Byte
		LDX	#$11
		LDY	#$C
		JSR	String_to_Screen_Buffer
		LDA	#>Arrow_Right	; Используются при подсчёте очков
		STA	HighPtr_Byte
		LDA	#<Arrow_Right	; Используются при подсчёте очков
		STA	LowPtr_Byte
		LDX	#$11
		LDY	#$F
		JSR	String_to_Screen_Buffer
		LDA	#>Arrow_Right	; Используются при подсчёте очков
		STA	HighPtr_Byte
		LDA	#<Arrow_Right	; Используются при подсчёте очков
		STA	LowPtr_Byte
		LDX	#$11
		LDY	#$12
		JSR	String_to_Screen_Buffer
		LDA	#>Arrow_Right	; Используются при подсчёте очков
		STA	HighPtr_Byte
		LDA	#<Arrow_Right	; Используются при подсчёте очков
		STA	LowPtr_Byte
		LDX	#$11
		LDY	#$15
		JSR	String_to_Screen_Buffer

Skip_ScndPlayerDraw:			; CODE XREF: Draw_Pts_Screen_Template+C1j
		JSR	NMI_Wait	; Рисуем PTS перед выводом очков за каждый вид танка
		LDA	#>aPts		; "PTS\xFF"
		STA	HighPtr_Byte
		LDA	#<aPts		; "PTS\xFF"
		STA	LowPtr_Byte
		LDX	#8
		LDY	#$C
		JSR	String_to_Screen_Buffer
		LDA	#>aPts		; "PTS\xFF"
		STA	HighPtr_Byte
		LDA	#<aPts		; "PTS\xFF"
		STA	LowPtr_Byte
		LDX	#8
		LDY	#$F
		JSR	String_to_Screen_Buffer
		LDA	#>aPts		; "PTS\xFF"
		STA	HighPtr_Byte
		LDA	#<aPts		; "PTS\xFF"
		STA	LowPtr_Byte
		LDX	#8
		LDY	#$12
		JSR	String_to_Screen_Buffer
		LDA	#>aPts		; "PTS\xFF"
		STA	HighPtr_Byte
		LDA	#<aPts		; "PTS\xFF"
		STA	LowPtr_Byte
		LDX	#8
		LDY	#$15
		JSR	String_to_Screen_Buffer
		LDA	CursorPos
		BEQ	Skip_ScndPlayerPtsDraw ; Если игрок один, PTS не рисуем
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	#>aPts		; "PTS\xFF"
		STA	HighPtr_Byte
		LDA	#<aPts		; "PTS\xFF"
		STA	LowPtr_Byte
		LDX	#$1A
		LDY	#$C
		JSR	String_to_Screen_Buffer
		LDA	#>aPts		; "PTS\xFF"
		STA	HighPtr_Byte
		LDA	#<aPts		; "PTS\xFF"
		STA	LowPtr_Byte
		LDX	#$1A
		LDY	#$F
		JSR	String_to_Screen_Buffer
		LDA	#>aPts		; "PTS\xFF"
		STA	HighPtr_Byte
		LDA	#<aPts		; "PTS\xFF"
		STA	LowPtr_Byte
		LDX	#$1A
		LDY	#$12
		JSR	String_to_Screen_Buffer
		LDA	#>aPts		; "PTS\xFF"
		STA	HighPtr_Byte
		LDA	#<aPts		; "PTS\xFF"
		STA	LowPtr_Byte
		LDX	#$1A
		LDY	#$15
		JSR	String_to_Screen_Buffer

Skip_ScndPlayerPtsDraw:			; CODE XREF: Draw_Pts_Screen_Template+15Ej
		JSR	NMI_Wait	; Рисуем Total и линию
		LDA	#>aLine		; Полоска над 'TOTAL' при подсчёте очков
		STA	HighPtr_Byte
		LDA	#<aLine		; Полоска над 'TOTAL' при подсчёте очков
		STA	LowPtr_Byte
		LDX	#$C
		LDY	#$16
		JSR	String_to_Screen_Buffer
		LDA	#>aTotal	; "TOTAL\xFF"
		STA	HighPtr_Byte
		LDA	#<aTotal	; "TOTAL\xFF"
		STA	LowPtr_Byte
		LDX	#6
		LDY	#$17
		JSR	String_to_Screen_Buffer
		RTS
; End of function Draw_Pts_Screen_Template


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует колонку из 4-х	вражеских танков

Draw_Tank_Column:			; CODE XREF: Draw_Pts_Screen+29p
					; Draw_Pts_Screen+3Fp
					; DrawTankColumn_XTimes+5p
		LDA	#2
		STA	TSA_Pal		; Танки	будут на спрайтовой палитре 2
		LDY	#$64 ; 'd'      ; Будет меняться только Y и вид танка (начальный индекс тайла в Pattern Table)
		LDA	#$80 ; 'А'      ; 1 вид танка врага
		JSR	Draw_Spr_InColumn ; Рисует 16х16 спрайт	с фиксированной	координатой Х
		LDY	#$7C ; '|'
		LDA	#$A0 ; 'а'      ; 2 вид танка врага
		JSR	Draw_Spr_InColumn ; Рисует 16х16 спрайт	с фиксированной	координатой Х
		LDY	#$94 ; 'Ф'
		LDA	#$C0 ; '└'      ; 3 вид танка врага
		JSR	Draw_Spr_InColumn ; Рисует 16х16 спрайт	с фиксированной	координатой Х
		LDY	#$AC ; 'м'
		LDA	#$E0 ; 'р'      ; 4 вид танка врага
		JSR	Draw_Spr_InColumn ; Рисует 16х16 спрайт	с фиксированной	координатой Х
		RTS
; End of function Draw_Tank_Column


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Сохраняет определенные атрибуты в NT_Buffer

Fill_Attrib_Table:			; CODE XREF: Draw_Pts_Screen_Template+21p
		LDA	#$50 ; 'P'
		STA	NT_Buffer+$3C0
		STA	NT_Buffer+$3C1
		STA	NT_Buffer+$3C2
		STA	NT_Buffer+$3C3
		STA	NT_Buffer+$3C8
		STA	NT_Buffer+$3C9
		STA	NT_Buffer+$3CA
		STA	NT_Buffer+$3CD
		STA	NT_Buffer+$3CE
		STA	NT_Buffer+$3CF
		LDA	#$A0
		STA	NT_Buffer+$3C4
		STA	NT_Buffer+$3C5
		STA	NT_Buffer+$3C6
		STA	NT_Buffer+$3C7
		LDA	#$A
		STA	NT_Buffer+$3D0
		STA	NT_Buffer+$3D1
		STA	NT_Buffer+$3D2
		STA	NT_Buffer+$3D5
		STA	NT_Buffer+$3D6
		STA	NT_Buffer+$3D7
		LDA	#5
		STA	NT_Buffer+$3F0
		STA	NT_Buffer+$3F1
		STA	NT_Buffer+$3F2
		STA	NT_Buffer+$3F5
		STA	NT_Buffer+$3F6
		STA	NT_Buffer+$3F7
		RTS
; End of function Fill_Attrib_Table


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует 16х16 спрайт с	фиксированной координатой Х

Draw_Spr_InColumn:			; CODE XREF: Draw_Tank_Column+8p
					; Draw_Tank_Column+Fp
					; Draw_Tank_Column+16p
					; Draw_Tank_Column+1Dp
		STA	Spr_TileIndex
		LDX	#$81
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)
		RTS
; End of function Draw_Spr_InColumn


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Прибавляет одну жизнь, если игрок заработал 200К очков

Add_Life:				; CODE XREF: Draw_Pts_Screen+69p
					; Draw_Pts_Screen+87p
					; Draw_Pts_Screen+1B3p
					; Draw_Pts_Screen+20Ep
					; BulletToTank_Impact_Handle+11Bp
					; Bonus_Handle+4Ep
		LDA	HQ_Status	; 80=штаб цел, если ноль то уничтожен
		CMP	#$80
		BNE	End_Add_Life	; Если штаб разрушен, не проверяем очки
		LDA	AddLife_Flag	;  <>0 - игрок получал дополнительную жизнь
		BNE	+
		LDA	HiScore_1P_String+2
		CMP	#2
		BCC	+
		INC	Player1_Lives
		INC	AddLife_Flag	;  <>0 - игрок получал дополнительную жизнь
		JMP	Play_SndAncillaryLife
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Add_Life+8j Add_Life+Ej
		LDA	CursorPos
		BEQ	End_Add_Life	; Если игрок один, не проверяем	очки второго
		LDA	AddLife_Flag+1	;  <>0 - игрок получал дополнительную жизнь
		BNE	End_Add_Life
		LDA	HiScore_2P_String+2
		CMP	#2
		BCC	End_Add_Life
		INC	Player2_Lives
		INC	AddLife_Flag+1	;  <>0 - игрок получал дополнительную жизнь

Play_SndAncillaryLife:			; CODE XREF: Add_Life+14j
		LDA	#1
		STA	Snd_Ancillary_Life1 ; Проигрываем звук
		STA	Snd_Ancillary_Life2

End_Add_Life:				; CODE XREF: Add_Life+4j Add_Life+19j
					; Add_Life+1Dj	Add_Life+23j
		RTS
; End of function Add_Life


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Null_Upper_NT:				; CODE XREF: BonusLevel_ButtonCheck:New_Scrollp
					; BonusLevel_ButtonCheck+28p
		JSR	Screen_Off
		LDA	#3
		STA	BkgPal_Number
		LDA	#$1C
		STA	PPU_Addr_Ptr
		JSR	Null_NT_Buffer
		JSR	Store_NT_Buffer_InVRAM ; Сбрасывает на экран содержимое	NT_Buffer
		JSR	Set_PPU
		RTS
; End of function Null_Upper_NT


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_TitleScreen:			; CODE XREF: ROM:BEGINp
		JSR	Screen_Off
		LDA	#$24 ; '$'
		STA	PPU_Addr_Ptr
		JSR	Null_NT_Buffer
		LDX	#$1A
		STX	Block_X
		LDY	#$1E ; '.'
		STY	Block_Y
		LDA	#>aBattle	; Загрузка указателя на	string 'BATTLE'
		STA	HighStrPtr_Byte
		LDA	#<aBattle	; "BATTLE\xFF"
		STA	LowStrPtr_Byte
		JSR	Draw_BrickStr
		LDX	#$3C ; '<'
		STX	Block_X
		LDY	#$46 ; 'V'
		STY	Block_Y
		LDA	#>aCity:	; Загрузка указателя на	string 'CITY'
		STA	HighStrPtr_Byte
		LDA	#<aCity:	; "CITY\xFF"
		STA	LowStrPtr_Byte
		JSR	Draw_BrickStr
		JSR	Store_NT_Buffer_InVRAM ; Сбрасывает на экран содержимое	NT_Buffer
		JSR	Set_PPU
		LDA	#$30		; Цифры	в знакогенераторе начинаются по	адресу $30 (не ASCII)
		STA	Char_Index_Base
		LDA	#>aK		; Загрузка указателя на	string 'I-'
		STA	HighPtr_Byte
		LDA	#<aK		; Для экрана подсчёта очков: 'I-'
		STA	LowPtr_Byte
		LDX	#2		; Координата X будущей надписи
		LDY	#3		; Координата Y будущей надписи
		JSR	String_to_Screen_Buffer
		LDY	#$16
		LDX	#4
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#3
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDA	#>aHik		; Загрузка указателя на	string 'HI-'
		STA	HighPtr_Byte
		LDA	#<aHik		; HI-
		STA	LowPtr_Byte
		LDX	#$B
		LDY	#3
		JSR	String_to_Screen_Buffer
		LDY	#$3E ; '>'
		LDX	#$E
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#3
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер
		LDA	CursorPos
		BEQ	+
		LDA	#>a_k		; Если курсор на момент	RESET не был на	позиции	1 player,
					; значит нужно отрисовать данные об очках второго игрока.
					; (интересно, что это справедливо даже для construction)
		STA	HighPtr_Byte
		LDA	#<a_k		; Для экрана подсчёта очков: 'II-'
		STA	LowPtr_Byte
		LDX	#$15
		LDY	#3
		JSR	String_to_Screen_Buffer
		LDY	#$1E
		LDX	#$17
		JSR	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
		LDY	#3
		JSR	Save_Str_To_ScrBuffer ;	Сохраняет строку в строковый буффер

+:					; CODE XREF: Draw_TitleScreen+72j
		LDA	#0
		STA	Char_Index_Base
		JSR	NMI_Wait	; Рисуем нижнюю	часть титульника:
					;
		LDA	#>a1Player	; "1 PLAYER\xFF"
		STA	HighPtr_Byte
		LDA	#<a1Player	; "1 PLAYER\xFF"
		STA	LowPtr_Byte
		LDX	#$B
		LDY	#$11
		JSR	String_to_Screen_Buffer
		LDA	#>a2Players	; "2 PLAYERS\xFF"
		STA	HighPtr_Byte
		LDA	#<a2Players	; "2 PLAYERS\xFF"
		STA	LowPtr_Byte
		LDX	#$B
		LDY	#$13
		JSR	String_to_Screen_Buffer
		LDA	#>aConstruction	; "CONSTRUCTION\xFF"
		STA	HighPtr_Byte
		LDA	#<aConstruction	; "CONSTRUCTION\xFF"
		STA	LowPtr_Byte
		LDX	#$B
		LDY	#$15
		JSR	String_to_Screen_Buffer
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	#>aMAP_MODE	; Часть	тайловой карты для надписи NAMCOT
		STA	HighPtr_Byte
		LDA	#<aMAP_MODE	; Часть	тайловой карты для надписи NAMCOT
		STA	LowPtr_Byte
		LDX	#$B
		LDY	#$17
		JSR	String_to_Screen_Buffer
		LDA	#>Copyrights	; Кстати, в начале РОМа	первая цифра не	1980 а 1981
		STA	HighPtr_Byte
		LDA	#<Copyrights	; Кстати, в начале РОМа	первая цифра не	1980 а 1981
		STA	LowPtr_Byte
		LDX	#1
		LDY	#$19
		JSR	String_to_Screen_Buffer
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
;!Рисуем строчку Map_Mode
		LDA	Map_Mode_Pos	
		ASL	A		; х2 (указатели	двухбайтовые)
		TAY
		LDA	MAP_MODE_STRINGS,Y
		STA	LowPtr_Byte
		LDA	MAP_MODE_STRINGS+1,Y
		STA	HighPtr_Byte
		LDX	#$11
		LDY	#$17
		JSR	String_to_Screen_Buffer
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	#>aSite 
		STA	HighPtr_Byte
		LDA	#<aSite 
		STA	LowPtr_Byte
		LDX	#$A
		LDY	#$1B
		JSR	String_to_Screen_Buffer
		LDA	#>aBack 
		STA	HighPtr_Byte
		LDA	#<aBack 
		STA	LowPtr_Byte
		LDX	#8
		LDY	#$0D
		JSR	String_to_Screen_Buffer


		RTS
; End of function Draw_TitleScreen


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует колонку из 4-х	вражеских танков X раз (задержка в Х фреймов)

DrawTankColumn_XTimes:			; CODE XREF: Draw_Pts_Screen+5p
					; Draw_Pts_Screen+106p
					; Draw_Pts_Screen+11Ap
					; Draw_Pts_Screen+122p
					; Draw_Pts_Screen+14Dp
					; Draw_Pts_Screen+213p
					; DrawTankColumn_XTimes+Bj
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		TXA
		PHA
		JSR	Draw_Tank_Column ; Рисует колонку из 4-х вражеских танков
		PLA
		TAX
		DEX
		BNE	DrawTankColumn_XTimes ;	Рисует колонку из 4-х вражеских	танков X раз (задержка в Х фреймов)
		RTS
; End of function DrawTankColumn_XTimes



; ───────────────────────────────────────────────────────────────────────────

TankKill_Pts:	.BYTE $10, $20,	$30, $40 ; DATA	XREF: Draw_Pts_Screen+48r
					; Количество очков за каждый тип убитого врага
;Величины приращений координат надписи GameOver	и танка	в Construction:
;по 4 байта на X u Y - дают возможность	производить
;скроллинг в любом направлении
;В случае танка, это четыре возможных направления движения:
;вверх,	влево, вниз, вправо
;(Отрицательные	числа приведут к скроллингу в обратном направлении)
;Такие же массивы расположены по адресам $E46C,	$EA49
Coord_X_Increment:.BYTE	0, $FF,	0, 1	; DATA XREF: Move_Tank+33r
					; GameOver_Str_Move_Handle+26r
Coord_Y_Increment:.BYTE	$FF, 0,	1, 0	; DATA XREF: Move_Tank+3Fr
 					; GameOver_Str_Move_Handle+30r

; ───────────────────────────────────────────────────────────────────────────
INCLUDE COMMON.asm; Самые общие процедуры, используемые игрой вынесены в отдельный файл.
INCLUDE STRINGS.asm; Все строки, которые отрисовываются в игре вынесены в отдельный файл.
INCLUDE SOUND.asm ; Звуковой движок вынесен в отдельный файл.

; ───────────────────────────────────────────────────────────────────────────
PAD $FFFA
;Векторы прерываний:
		.WORD NMI		; Non-Maskable Interrupt Vector
		.WORD RESET		; RESET	Interrupt Vector
		.WORD RESET		; IRQ/BRK Interrupt Vector


; end of 'ROM'


		.END
