; ───────────────────────────────────────────────────────────────────────────

NMI:					; DATA XREF: ROM:FFFAo
		PHA
		TXA
		PHA
		TYA
		PHA
		PHP			; Стандартное начало NMI
		LDA	#0
		STA	PPU_SPR_ADDR	; Инициализация	для записи в нулевой адрес SPR OAM
		LDA	#2
		STA	SPR_DMA		; Спрайтовый буффер будет по адресу $200
		LDA	PPU_STATUS	; Reset	VBlank Occurance
		JSR	Update_Screen	; Сборос из Screen_Buffer в память PPU
		LDA	BkgPal_Number
		BMI	Skip_PalLoad
		JSR	Load_Bkg_Pal

Skip_PalLoad:				; CODE XREF: ROM:D418j
		LDA	PPU_REG1_Stts
		ORA	#10110000b	; Типичная для BC конфигурация PPU (Спрайты всегда 8х16	(ширина	х высота))
		STA	PPU_CTRL_REG1	; PPU Control Register #1 (W)
		LDA	#0		; Обработка скроллинга
		STA	PPU_SCROLL_REG	; VRAM Address Register	#1 (W2)
		LDA	Scroll_Byte
		STA	PPU_SCROLL_REG	; VRAM Address Register	#1 (W2)
		LDA	#00011110b	; Включаем бэкграунд и спрайты
		STA	PPU_CTRL_REG2	; PPU Control Register #2 (W)
		JSR	Read_Joypads
		JSR	Spr_Invisible	; Вывод	Y координат спрайтов в $F0
		JSR	Play_Sound	; аналогично Play в NSF	формате
		INC	Frame_Counter
		LDA	Frame_Counter
		AND	#63		; В одной секунде 64 фрейма?
		BNE	End_Interrupt
		INC	Seconds_Counter

End_Interrupt:				; CODE XREF: ROM:D442j
		PLP
		PLA
		TAY
		PLA
		TAX
		PLA
		RTI

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; ГПСЧ,	в А случайное число

Get_Random_A:				; CODE XREF: ROM:DC8Cp	ROM:DD17p
					; ROM:Get_RandomStatusp ROM:DD4Fp
					; Load_AI_Status:Load_AIStatus_GetRandomp
					; Get_RandomDirection+12p
					; Make_Enemy_Shot+Fp
					; Bonus_Appear_Handle:-p
					; Bonus_Appear_Handle+Fp
					; Bonus_Appear_Handle+28p
		TXA
;ГПСЧ не основан на законах распределения,
;поэтому выдает	неслучайные числа. Использует два
;байта:	Random_Hi зависит в том	числе от таймера секунд,
;Random_Lo - основной байт
		PHA			; Сохраняем Х
		LDA	Random_Lo
		ASL	A
		ASL	A
		ASL	A
		SEC
		SBC	Random_Lo
		CLC
		ADC	Frame_Counter
		INC	Random_Hi
		LDX	Random_Hi
		ADC	Temp,X		; Выбирается случайная ячейка из Zero Page
					; с произвольным значением для большей "случайности"
		STA	Random_Lo
		PLA
		TAX			; Вытаскиваем Х
		LDA	Random_Lo
		RTS
; End of function Get_Random_A

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; ГПСЧ,	в А случайное число

Get_Blargg_Random_A:

	; rand = (rand * 5 + $3611) & $FFFF
	; return (rand >> 8) & $FF
		lda Random_Hi      ; multiply by 5
		sta Temp
		lda Random_Lo
		asl a           ; rand = rand << 2 + rand
		rol Temp
		asl a
		rol Temp
		clc
		adc Random_Lo
		pha
		lda Temp
		adc Random_Hi
		sta Random_Hi
		pla             ; rand = rand + $3611
		clc
		adc #$11
		sta Random_Lo
		lda Random_Hi
		adc #$36
		sta Random_Hi
		RTS
; End of function Get_Random_A


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Set_PPU:				; CODE XREF: ROM:C092p	ROM:C0BBp
					; Clear_NT+9p Load_DemoLevel+57p
					; Draw_Record_HiScore+29p
					; Show_Secret_Msg+13p
					; Show_Secret_Msg+C7p
					; Draw_Brick_GameOver+39p
					; Draw_Brick_GameOver+62p
					; Draw_Pts_Screen_Template+27p
					; Null_Upper_NT+11p
					; Draw_TitleScreen+33p
		JSR	VBlank_Wait
		LDA	#10110000b
		STA	PPU_CTRL_REG1	; Фоновый знакогенератор - второй;
					; спрайты 8х16;
					; выполнять NMI	при VBlank'е
		RTS
; End of function Set_PPU


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Screen_Off:				; CODE XREF: ROM:C0B2p	Clear_NTp
					; Load_DemoLevel+2Bp
					; Draw_Record_HiScorep
					; Show_Secret_Msgp Show_Secret_Msg+BEp
					; Draw_Brick_GameOverp
					; Draw_Brick_GameOver:End_Draw_Brick_GameOverp
					; Draw_Pts_Screen_Template+1Bp
					; Null_Upper_NTp Draw_TitleScreenp
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	#00010000b
		STA	PPU_CTRL_REG1	; Для бэкграунда назначен второй знакогенератор,
					; а для	спрайтов - первый
					;
		LDA	#00000110b
		STA	PPU_CTRL_REG2	; Фон и	спрайты	отключены
		RTS
; End of function Screen_Off


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Null_NT_Buffer:				; CODE XREF: Clear_NT+3p
					; Draw_Record_HiScore+Dp
					; Show_Secret_Msg+Dp
					; Draw_Brick_GameOver+Dp
					; Draw_Brick_GameOver+5Cp
					; Draw_Pts_Screen_Template+1Ep
					; Null_Upper_NT+Bp Draw_TitleScreen+7p
					; Reset_ScreenStuff+1Bp
		LDA	#0
		TAX

-:					; CODE XREF: Null_NT_Buffer+10j
		STA	NT_Buffer,X
		STA	NT_Buffer+$100,X
		STA	NT_Buffer+$200,X
		STA	NT_Buffer+$300,X
		INX
		BNE	-
		RTS
; End of function Null_NT_Buffer


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Reset_ScreenStuff:			; CODE XREF: ROM:C089p
		LDA	#0
		STA	Char_Index_Base
		STA	byte_6B
		STA	ScrBuffer_Pos
		STA	SprBuffer_Position
		STA	Pause_Flag
		LDA	#$FF
		STA	BkgPal_Number
		JSR	Load_Pals
		LDA	#4		; Спрайтовый Буффер заполняем через 4 байта
		STA	Gap
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		JSR	Null_NT_Buffer
		JSR	Spr_Invisible	; Уводим все спрайты за	экран
		LDX	#HiScore_1P_String
		JSR	Null_8Bytes_String
		LDX	#HiScore_2P_String
		JSR	Null_8Bytes_String
		JSR	StaffStr_Check	; 0=в RAM нет строки StaffString
					; 1=в RAM есть строка StaffString
		BNE	HotBoot		; Очистка обеих	тайловых карт

		LDX	#HiScore_String
		JSR	Null_8Bytes_String
		LDA	#2
		STA	HiScore_String+2 ; Записываем в	HiScore	число 20000
		LDA	#0
		STA	CursorPos	; Устанавливаем	курсор на надпись '1 player'
		STA     Map_Mode_Pos
		STA	Boss_Mode
;! Если загрузка холодная, инициируем номера уровней. При ресете они не должны сбрасываться.
		LDA	#1
		STA	Level_Number



HotBoot:				; CODE XREF: Reset_ScreenStuff+2Ej
		LDA	#$1C		; Очистка обеих	тайловых карт
		STA	PPU_Addr_Ptr	; 1c+04=20 (запись в $2000 VRAM)[NT#1]
		JSR	Store_NT_Buffer_InVRAM ; Сбрасывает на экран содержимое	NT_Buffer
		LDA	#$24 ; '$'
		STA	PPU_Addr_Ptr	; 24+4=28 (в 2800)[NT#2]
		JSR	Store_NT_Buffer_InVRAM ; Сбрасывает на экран содержимое	NT_Buffer
		JSR	StaffStr_Store	; Запоминаем, что игра была уже	включена
					; (на случай перезагрузки RESET'ом)
		JSR	Sound_Stop	; Останавливаем	звук, включаем каналы и	т.п. (аналогично Load в	NSF формате)
		RTS
; End of function Reset_ScreenStuff


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Запоминаем, что игра была уже	включена
; (на случай перезагрузки RESET'ом)

StaffStr_Store:				; CODE XREF: Reset_ScreenStuff+4Bp
		LDX	#$F

-:					; CODE XREF: StaffStr_Store+9j
		LDA	StaffString,X	; "RYOUITI OOKUBO  TAKEFUMI HYOUDOUJUNKO O"...
		STA	StaffString_RAM,X
		DEX
		BPL	-
		RTS
; End of function StaffStr_Store


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Если этой строки нет в RAM, то игра стартует первый раз
; (включена кнопкой POWER)

StaffStr_Check:				; CODE XREF: Reset_ScreenStuff+2Bp
		LDX	#$F

-:					; CODE XREF: StaffStr_Check+Bj
		LDA	StaffString_RAM,X
		CMP	StaffString,X	; "RYOUITI OOKUBO  TAKEFUMI HYOUDOUJUNKO O"...
		BNE	ColdBoot
		DEX
		BPL	-
		LDA	#1
		RTS
; ───────────────────────────────────────────────────────────────────────────

ColdBoot:				; CODE XREF: StaffStr_Check+8j
		LDA	#0
		RTS
; End of function StaffStr_Check


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Load_Pals:				; CODE XREF: Reset_ScreenStuff+10p
		JSR	VBlank_Wait
		JSR	Spr_Pal_Load
		LDA	#0		; Номер	16цветной FrameПалитры
		JSR	Load_Bkg_Pal
		RTS
; End of function Load_Pals


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Load_Bkg_Pal:				; CODE XREF: ROM:D41Ap	Load_Pals+8p
		ASL	A
		ASL	A
		ASL	A
		ASL	A		; A*10
		TAX
		LDY	#$10
		LDA	#$3F ; '?'      ; Подготовка к записи 16 цветной палитры в область Background палитр
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	#0
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)

-:					; CODE XREF: Load_Bkg_Pal+19j
		LDA	PaletteFrame2,X
		STA	PPU_DATA	; VRAM I/O Register (RW)
		INX
		DEY
		BNE	-
		LDA	#$FF
		STA	BkgPal_Number
		LDA	#$3F ; '?'
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	#0
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		STA	PPU_ADDRESS	; Обнуление адреса PPU?
		RTS
; End of function Load_Bkg_Pal


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Spr_Pal_Load:				; CODE XREF: Load_Pals+3p
		LDX	#0
		LDY	#$10
		LDA	#$3F ; '?'      ; Подготовка к записи 16 цветов в область спрайтовых палитр
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		STY	PPU_ADDRESS	; VRAM Address Register	#2 (W2)

-:					; CODE XREF: Spr_Pal_Load+14j
		LDA	SpritePalette,X
		STA	PPU_DATA	; VRAM I/O Register (RW)
		INX
		DEY
		BNE	-
		RTS
; End of function Spr_Pal_Load

; ───────────────────────────────────────────────────────────────────────────
;Палитры:
SpritePalette:	.BYTE  $F,$18,$27,$38, $F, $A,$1B,$3B, $F, $C,$10,$20, $F,  4,$16,$20
					; DATA XREF: Spr_Pal_Load:-r
PaletteFrame2:	.BYTE  $F,$17,	6,  0, $F,$3C,$10,$12, $F,$29,	9, $B, $F,  0,$10,$20
					; DATA XREF: Load_Bkg_Pal:-r
LevelPalette:	.BYTE  $F,$17,	6,  0, $F,$3C,$12,$12, $F,$29,	9, $B, $F,  0,$10,$20
PaletteFrame1:	.BYTE  $F,$17,	6,  0, $F,$12,$3C,$12, $F,$29,	9, $B, $F,  0,$10,$20
TitleScrPalette:.BYTE  $F,$16,$16,$30, $F,$3C,$10,$16, $F,$29,	9,$27, $F,  0,$10,$20
LevelSelPalette:.BYTE  $F,$17,	6,  0, $F,$3C,$10,  0, $F,$29,	9,  0, $F,  0,$10,  0
		.BYTE  $F, $F,	6,  0, $F,$3C,$10,  0, $F,$29,	9,  0, $F,  0,$10,  0
PaletteMisc1:	.BYTE  $F,$12,	6,  0, $F,$3C,$10,  0, $F,$29,	9,  0, $F,  0,$10,  0
		.BYTE  $F,  0,	6,  0, $F,$3C,$10,  0, $F,$29,	9,  0, $F,  0,$10,  0
PaletteMisc2:	.BYTE  $F,$30,	6,  0, $F,$3C,$10,  0, $F,$29,	9,  0, $F,  0,$10,  0

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


VBlank_Wait:				; CODE XREF: Set_PPUp Load_Palsp -+3j
-:					; PPU Status Register (R)
		LDA	PPU_STATUS
		BPL	-
		RTS
; End of function VBlank_Wait


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


CoordTo_PPUaddress:			; CODE XREF: Draw_StageNumString+7p
					; FillScr_Single_Row+2p
					; String_to_Screen_Bufferp
					; Save_Str_To_ScrBufferp
					; CoordsToRAMPosp Draw_GrayFrame+21p
		LDA	#0
		STA	Temp		; Экран	шириной	$20 тайлов. Старший байт адреса	в NT увеличится	на 1, если
					; от начала экрана будет $100 тайлов или 8 строк тайлов(Y=8).
					; Таким	образом, старший байт может быть вычислен по формуле: (Y div 8)	или (Y shr 3)
					; Затем	в старшем байте	выставляется бит №2 (старший байт теперь не меньше 4):
					; в дальнейшем,	к старшему байту будет прибавлено $1c, так что в итоге не должен
					; получиться адрес меньше $2000	(1-я NT).
					; Младший байт в этом случае, может быть вычислен по формуле: (X + Y*($20)) или	(X + (Y	shl 5)).
					; Или, другими словами,	три младших бита Y должны перейти в три	старших	бита X,
					; что и	реализовано в этой процедуре.
					; __________________________________________
					; На входе Х и Y: координаты тайла на экране
					; На выходе A: (старший	байт - $1c)
					;	    Y:	младший	байт
		TYA
		LSR	A
		ROR	Temp
		LSR	A
		ROR	Temp
		LSR	A		; Y div	8
		ROR	Temp
		PHA
		TXA
		ORA	Temp		; (X + (Y shl 5))
		TAY
		PLA
		ORA	#4		; выставляем второй бит
		RTS
; End of function CoordTo_PPUaddress


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Копируем атрибуты из NT_Buffer на экран

AttribToScrBuffer:			; CODE XREF: Draw_TSABlock+13p
		JSR	TSA_Pal_Ops
		LDX	ScrBuffer_Pos
		LDA	#$23 ; '#'
		STA	Screen_Buffer,X
		INX
		TYA
		CLC
		ADC	#$C0 ; '└'
		STA	Screen_Buffer,X	; В PPU	будем писать в атрибуты
		INX
		LDA	NT_Buffer+$3C0,Y
		STA	Screen_Buffer,X
		INX
		LDA	#$FF
		STA	Screen_Buffer,X	; Конец	строки
		INX
		STX	ScrBuffer_Pos
		RTS
; End of function AttribToScrBuffer


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


TSA_Pal_Ops:				; CODE XREF: AttribToScrBufferp
		LDA	TSA_Pal
		JSR	OR_Pal		; A := (A * 4) OR TSA_Pal
		JSR	OR_Pal		; A := (A * 4) OR TSA_Pal
		JSR	OR_Pal		; A := (A * 4) OR TSA_Pal
		STA	CHR_Byte
		TYA
		AND	#2
		BNE	+
		TXA
		AND	#2
		BEQ	++
		LDA	#$F3 ; 'є'
		JMP	End_TSA_Pal_Ops
; ───────────────────────────────────────────────────────────────────────────

++:					; CODE XREF: TSA_Pal_Ops+15j
		LDA	#$FC ; '№'
		JMP	End_TSA_Pal_Ops
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: TSA_Pal_Ops+10j
		TXA
		AND	#2
		BEQ	+++
		LDA	#$3F ; '?'
		JMP	End_TSA_Pal_Ops
; ───────────────────────────────────────────────────────────────────────────

+++:					; CODE XREF: TSA_Pal_Ops+24j
		LDA	#$CF ; '╧'

End_TSA_Pal_Ops:			; CODE XREF: TSA_Pal_Ops+19j
					; TSA_Pal_Ops+1Ej TSA_Pal_Ops+28j
		STA	byte_1
		TYA
		ASL	A
		AND	#$F8 ; '°'
		STA	Temp
		TXA
		LSR	A
		LSR	A
		CLC
		ADC	Temp
		TAY
		LDA	byte_1
		EOR	#$FF
		AND	CHR_Byte
		STA	CHR_Byte
		LDA	NT_Buffer+$3C0,Y ; Пишем в атрибуты
		AND	byte_1
		ORA	CHR_Byte
		STA	NT_Buffer+$3C0,Y
		RTS
; End of function TSA_Pal_Ops


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; A := (A * 4) OR TSA_Pal

OR_Pal:					; CODE XREF: TSA_Pal_Ops+2p
					; TSA_Pal_Ops+5p TSA_Pal_Ops+8p
		ASL	A
		ASL	A
		ORA	TSA_Pal
		RTS
; End of function OR_Pal


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Read_Joypads:				; CODE XREF: ROM:D433p
		LDX	#1
		STX	JOYPAD_PORT1	; Joypad #1 (RW)
		LDY	#0
		STY	JOYPAD_PORT1	; Строб

--:					; CODE XREF: Read_Joypads+27j
		STY	Temp
		LDY	#8		; 8 кнопок

-:					; CODE XREF: Read_Joypads+18j
		LDA	JOYPAD_PORT1,X	; Сначала опрашиваем второй джойстик, потом первый
		AND	#3
		CMP	#1
		ROR	Temp
		DEY
		BNE	-		; Сначала опрашиваем второй джойстик, потом первый
		LDA	Joypad1_Buttons,X
		EOR	#$FF
		AND	Temp
		STA	Joypad1_Differ,X
		LDA	Temp
		STA	Joypad1_Buttons,X
		DEX
		BPL	--
		RTS			; 1 = A
; End of function Read_Joypads		; 2 = B
					; 4 = SELECT
					; 8 = START
					; 10 = UP
					; 20 = DOWN
					; 40 = LEFT
					; 80 = RIGHT

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


String_to_Screen_Buffer:		; CODE XREF: Show_Secret_Msg+28p
					; Show_Secret_Msg+3Ap
					; Show_Secret_Msg+4Cp
					; Show_Secret_Msg+5Ep
					; Show_Secret_Msg+70p
					; Show_Secret_Msg+82p
					; Show_Secret_Msg+94p
					; Show_Secret_Msg+A6p
					; Show_Secret_Msg+B8p
					; Draw_Player_Lives+16p
					; Draw_Player_Lives+36p Draw_IP+Cp
					; Draw_IP+25p Draw_LevelFlag+Fp
					; Draw_LevelFlag+1Ep ReinforceToRAM+Bp
					; Draw_EmptyTile+Bp DraW_Normal_HQ+Cp
					; DraW_Normal_HQ+1Bp
					; DraW_Normal_HQ+2Ap
					; DraW_Normal_HQ+39p Draw_Naked_HQ+Cp
					; Draw_Naked_HQ+1Bp Draw_ArmourHQ+Cp
					; Draw_ArmourHQ+1Bp Draw_ArmourHQ+2Ap
					; Draw_ArmourHQ+39p
					; Draw_Destroyed_HQ+Cp
					; Draw_Destroyed_HQ+1Bp
					; Draw_Pts_Screen+196p
					; Draw_Pts_Screen+1A5p
					; Draw_Pts_Screen+1F1p
					; Draw_Pts_Screen+200p
					; Draw_Pts_Screen_Template+36p
					; Draw_Pts_Screen_Template+51p
					; Draw_Pts_Screen_Template+74p
					; Draw_Pts_Screen_Template+8Fp
					; Draw_Pts_Screen_Template+9Ep
					; Draw_Pts_Screen_Template+ADp
					; Draw_Pts_Screen_Template+BCp
					; Draw_Pts_Screen_Template+D2p
					; Draw_Pts_Screen_Template+EDp
					; Draw_Pts_Screen_Template+FCp
					; Draw_Pts_Screen_Template+10Bp
					; Draw_Pts_Screen_Template+11Ap
					; Draw_Pts_Screen_Template+12Cp
					; Draw_Pts_Screen_Template+13Bp
					; Draw_Pts_Screen_Template+14Ap
					; Draw_Pts_Screen_Template+159p
					; Draw_Pts_Screen_Template+16Fp
					; Draw_Pts_Screen_Template+17Ep
					; Draw_Pts_Screen_Template+18Dp
					; Draw_Pts_Screen_Template+19Cp
					; Draw_Pts_Screen_Template+1AEp
					; Draw_Pts_Screen_Template+1BDp
					; Draw_TitleScreen+46p
					; Draw_TitleScreen+61p
					; Draw_TitleScreen+80p
					; Draw_TitleScreen+A2p
					; Draw_TitleScreen+B1p
					; Draw_TitleScreen+C0p
					; Draw_TitleScreen+D2p
					; Draw_TitleScreen+E1p
					; Draw_TitleScreen+F3p
		JSR	CoordTo_PPUaddress
		STA	HighStrPtr_Byte
		CLC
		ADC	PPU_Addr_Ptr
		LDX	ScrBuffer_Pos
		STA	Screen_Buffer,X
		INX
		TYA
		STA	Screen_Buffer,X	; Сначала сохраняем адрес PPU, куда будет вписана эта строка
		INX
		STA	LowStrPtr_Byte
		LDY	#0

-:					; CODE XREF: String_to_Screen_Buffer+24j
		LDA	(LowPtr_Byte),Y	; Загружаем нужный стринг из РОМа
		STA	Screen_Buffer,X
		INX
		CMP	#$FF
		BEQ	+
		STA	(LowStrPtr_Byte),Y
		INY
		JMP	-		; Загружаем нужный стринг из РОМа
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: String_to_Screen_Buffer+1Fj
		STX	ScrBuffer_Pos
		RTS
; End of function String_to_Screen_Buffer


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Сохраняет строку в строковый буффер

Save_Str_To_ScrBuffer:			; CODE XREF: ROM:C76Bp	ROM:C782p
					; Draw_Player_Lives+5Ap
					; Draw_LevelFlag+33p
					; Draw_StageNumString+5Cp
					; Draw_Pts_Screen+93p
					; Draw_Pts_Screen+A7p
					; Draw_Pts_Screen+C2p
					; Draw_Pts_Screen+D2p
					; Draw_Pts_Screen+E6p
					; Draw_Pts_Screen+101p
					; Draw_Pts_Screen+133p
					; Draw_Pts_Screen+148p
					; Draw_Pts_Screen+17Bp
					; Draw_Pts_Screen+187p
					; Draw_Pts_Screen+1D6p
					; Draw_Pts_Screen+1E2p
					; Draw_Pts_Screen_Template+42p
					; Draw_Pts_Screen_Template+62p
					; Draw_Pts_Screen_Template+80p
					; Draw_Pts_Screen_Template+DEp
					; Draw_TitleScreen+52p
					; Draw_TitleScreen+6Dp
					; Draw_TitleScreen+8Cp
		JSR	CoordTo_PPUaddress
		CLC
		ADC	PPU_Addr_Ptr
		LDX	ScrBuffer_Pos
		STA	Screen_Buffer,X
		INX
		TYA
		STA	Screen_Buffer,X	; Сначала сохраняем в буффер адрес PPU (hi/lo)
		INX
		LDY	#0

-:					; CODE XREF: Save_Str_To_ScrBuffer+23j
		LDA	(LowPtr_Byte),Y
		BMI	+
		CLC
		ADC	Char_Index_Base

+:					; CODE XREF: Save_Str_To_ScrBuffer+15j
		STA	Screen_Buffer,X
		INX
		CMP	#$FF		; Сбрасываем в буффер, пока не появится	конец строки: $FF
		BEQ	++		; Сохраним позицию в буффере и выйдем
		INY
		JMP	-
; ───────────────────────────────────────────────────────────────────────────

++:					; CODE XREF: Save_Str_To_ScrBuffer+20j
		STX	ScrBuffer_Pos	; Сохраним позицию в буффере и выйдем
		RTS
; End of function Save_Str_To_ScrBuffer


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; В Х и	Y на выходе координаты в тайлах

GetCoord_InTiles:			; CODE XREF: Get_SprCoord_InTiles+4p
					; SaveSprTo_SprBuffer+Dp ROM:DCD2p
					; ROM:DCF7p Ice_Detect+1Ap
					; GetSprCoord_InTiles+4p
		JSR	XnY_div_8	; Делим	на 8 Y и X
; End of function GetCoord_InTiles


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


CoordsToRAMPos:				; CODE XREF: Draw_TSABlock+20p
		JSR	CoordTo_PPUaddress
		STA	HighPtr_Byte
		STY	LowPtr_Byte
		LDY	#0
		RTS
; End of function CoordsToRAMPos


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Делим	на 8 Y и X

XnY_div_8:				; CODE XREF: GetCoord_InTilesp
					; Draw_TSABlock+3p
		TYA
;Обычно	из координат в пикселях
;переводят в координаты	в тайлах
		LSR	A
		LSR	A
		LSR	A
		TAY
		TXA
		LSR	A
		LSR	A
		LSR	A
		TAX
		RTS
; End of function XnY_div_8


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Переводит SPR_XY в тайлы

Get_SprCoord_InTiles:			; CODE XREF: Draw_Char+44p
		STX	Spr_X
		STY	Spr_Y
		JSR	GetCoord_InTiles ; В Х и Y на выходе координаты	в тайлах
; End of function Get_SprCoord_InTiles


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Преобразует Temp в зависимости от Spr_Coord

Temp_Coord_shl:				; CODE XREF: BulletToObject_Impact_Handlep
		LDA	#1
		STA	Temp
		LDA	Spr_Y
		AND	#4
		BEQ	+
		ASL	Temp
		ASL	Temp

+:					; CODE XREF: Temp_Coord_shl+8j
		LDA	Spr_X
		AND	#4
		BEQ	++
		ASL	Temp

++:					; CODE XREF: Temp_Coord_shl+12j
		RTS
; End of function Temp_Coord_shl


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Возвращает ноль, если	нулевой	тайл

Check_Object:				; CODE XREF: BulletToObject_Impact_Handle+3p
		LDA	Temp
		ORA	#$F0 ; 'Ё'
		AND	(LowPtr_Byte),Y
		RTS
; End of function Check_Object


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует правильный вырыв в кирпичной стене

Draw_Destroyed_Brick:			; CODE XREF: BulletToObject_Impact_Handle:BulletToObject_Return1p
		LDA	Temp
		EOR	#$FF
		AND	(LowPtr_Byte),Y
		JSR	Draw_Tile
		RTS
; End of function Draw_Destroyed_Brick


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


NT_Buffer_Process_XOR:			; CODE XREF: Draw_Char:Empty_Pixelp
		LDA	(LowPtr_Byte),Y
		AND	#11110000b
		BNE	+
		LDA	Temp
		EOR	#$FF
		AND	(LowPtr_Byte),Y
		STA	(LowPtr_Byte),Y

+:					; CODE XREF: NT_Buffer_Process_XOR+4j
		RTS
; End of function NT_Buffer_Process_XOR

; ───────────────────────────────────────────────────────────────────────────
		LDA	Temp		; Это не испольняется никогда
		ORA	($11),Y
		JSR	Draw_Tile
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


NT_Buffer_Process_OR:			; CODE XREF: Draw_Char+4Dp
		LDA	(LowPtr_Byte),Y
		AND	#11110000b
		BNE	+
		LDA	Temp
		ORA	(LowPtr_Byte),Y
		STA	(LowPtr_Byte),Y

+:					; CODE XREF: NT_Buffer_Process_OR+4j
		RTS
; End of function NT_Buffer_Process_OR


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Save_to_VRAM:				; CODE XREF: Store_NT_Buffer_InVRAM:-p
		LDA	HighPtr_Byte
		CLC
		ADC	PPU_Addr_Ptr
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	LowPtr_Byte
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	(LowPtr_Byte),Y	; Таким	образом, массив	RAM'a выводится в Name Table,
					; в это	время всё пространство оперативной памяти
					; $400-$7FFзаполнено только тайловой картой надписи 'Battle City',
					; составленной из кирпичей
		STA	PPU_DATA	; используется при выводе титульника
		RTS
; End of function Save_to_VRAM


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_Tile:				; CODE XREF: Draw_Destroyed_Brick+6p
					; ROM:D760p Draw_TSABlock+2Bp
					; Draw_TSABlock+37p Draw_TSABlock+43p
					; Draw_TSABlock+4Fp
					; BulletToObject_Impact_Handle+46p
		STA	(LowPtr_Byte),Y
		STX	Spr_X
		LDX	ScrBuffer_Pos
		LDA	HighPtr_Byte
		CLC
		ADC	#$1C
		STA	Screen_Buffer,X
		INX
		LDA	LowPtr_Byte
		STA	Screen_Buffer,X
		INX
		LDA	(LowPtr_Byte),Y
		STA	Screen_Buffer,X
		INX
		LDA	#$FF
		STA	Screen_Buffer,X
		INX
		STX	ScrBuffer_Pos
		LDX	Spr_X
		RTS
; End of function Draw_Tile


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Inc_Ptr_on_A:				; CODE XREF: Copy_AttribToScrnBuff+2Dp
					; Store_NT_Buffer_InVRAM+Ep
					; Draw_GrayFrame+38p Draw_TSABlock+30p
					; Draw_TSABlock+3Cp Draw_TSABlock+48p
					; Draw_Char+16p Load_Level+20p
		CLC
		ADC	LowPtr_Byte
		STA	LowPtr_Byte
		BCC	+
		INC	HighPtr_Byte

+:					; CODE XREF: Inc_Ptr_on_A+5j
		RTS
; End of function Inc_Ptr_on_A


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Сбрасывает на	экран содержимое NT_Buffer

Store_NT_Buffer_InVRAM:			; CODE XREF: ROM:C0B8p	Clear_NT+6p
					; Load_DemoLevel+54p
					; Draw_Record_HiScore+26p
					; Show_Secret_Msg+10p
					; Show_Secret_Msg+C4p
					; Draw_Brick_GameOver+36p
					; Draw_Brick_GameOver+5Fp
					; Draw_Pts_Screen_Template+24p
					; Null_Upper_NT+Ep
					; Draw_TitleScreen+30p
					; Reset_ScreenStuff+41p
					; Reset_ScreenStuff+48p
		LDA	#0
		STA	LowPtr_Byte
		TAY
		LDA	#4		; Область тайловой карты в RAM начинается с $400
		STA	HighPtr_Byte

-:					; CODE XREF: Store_NT_Buffer_InVRAM+15j
		JSR	Save_to_VRAM
		LDA	#1
		JSR	Inc_Ptr_on_A
		LDA	HighPtr_Byte
		CMP	#8		; Не зашли ли мы за пределы области $400-$7FF?
		BNE	-
		RTS
; End of function Store_NT_Buffer_InVRAM


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_GrayFrame:				; CODE XREF: Make_GrayFrame+Cp
		LDX	#0
		LDA	#$11		; $11 -	серый тайл в Pattern Table (рамка серого цвета)

Fill_NTBuffer:				; CODE XREF: Draw_GrayFrame+11j
		STA	NT_Buffer,X
		STA	NT_Buffer+$100,X
		STA	NT_Buffer+$200,X
		STA	NT_Buffer+$300,X
		INX
		BNE	Fill_NTBuffer
		LDA	#0		; Весь экран использует	0-ю палитру.
		LDX	#$C0		; Последние $40	байт Name Table	отданы под атрибуты

Fill_NTAttribBuffer:			; CODE XREF: Draw_GrayFrame+1Bj
		STA	NT_Buffer+$300,X
		INX
		BNE	Fill_NTAttribBuffer
		LDX	Block_X
		LDY	Block_Y
		JSR	CoordTo_PPUaddress
		STA	HighPtr_Byte
		STY	LowPtr_Byte	; Начинаем рисовать черное игровое поле	от границы рамки, а не экрана.

Draw_BlackRow:				; CODE XREF: Draw_GrayFrame+3Bj
		LDY	Counter2
		DEY

--:					; CODE XREF: Draw_GrayFrame+30j
		LDA	#0		; Черный пустой	тайл игрового поля
		STA	(LowPtr_Byte),Y
		DEY			; Заполняем поле черным	тайлом справа налево
		BPL	--		; Черный пустой	тайл игрового поля
		DEC	Counter
		BEQ	+
		LDA	#$20 ; ' '      ; Переходим к следующему ряду тайлов
		JSR	Inc_Ptr_on_A
		JMP	Draw_BlackRow
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Draw_GrayFrame+34j
		RTS
; End of function Draw_GrayFrame


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_TSABlock:				; CODE XREF: Draw_TSA_On_Tank+8p
					; Make_Respawn+51p Load_Level+58p
		PHA
		STA	Temp
		JSR	XnY_div_8	; Делим	на 8 Y и X
		STX	Spr_X
		STY	Spr_Y
		LDY	Temp
		LDA	TSABlock_PalNumber,Y
		STA	TSA_Pal
		LDY	Spr_Y
		JSR	AttribToScrBuffer ; Копируем атрибуты из NT_Buffer на экран
		LDA	Spr_Y
		AND	#$FE
		TAY
		LDA	Spr_X
		AND	#$FE ; '■'
		TAX
		JSR	CoordsToRAMPos
		PLA
		ASL	A
		ASL	A		; Умножаем на 4	(на количество тайлов в	одном блоке)
		TAX
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		LDA	#1		; Переходим на тайл правее
		JSR	Inc_Ptr_on_A
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		LDA	#$1F		; Одна строка Name Table размером в $20	тайлов
					; т.е. переходим на строку ниже	и на тайл левее
		JSR	Inc_Ptr_on_A
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		LDA	#1		; Переходим на тайл правее
		JSR	Inc_Ptr_on_A
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		RTS
; End of function Draw_TSABlock


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_Char:				; CODE XREF: Draw_BrickStr+14p
		STX	BrickChar_X
		TAX
		TYA
		CLC
		ADC	#$20 ; ' '
		STA	BrickChar_Y
		LDA	#0
		STA	LowPtr_Byte	; Очистка младшего байта указателя
		LDA	#$10
		STA	HighPtr_Byte	; Установка старшего байта, чтобы
					; дальнейшее чтение производилось
					; из второго знакогенератора (который
					; установлен для бэкграунда)

Add_10:					; CODE XREF: Draw_Char+19j
		DEX			; Умножение ASCII кода буквы на	$10
		BMI	+
		LDA	#$10
		JSR	Inc_Ptr_on_A
		JMP	Add_10		; после	завершения этой	процедурки
					; условным переходом в Ptr_Byte	будет
					; код буквы в ASCII*$10+$1000;
					; Например, для	A=$41: $1410
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Draw_Char+12j
		LDA	HighPtr_Byte
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	LowPtr_Byte
		STA	PPU_ADDRESS	; Установка указателя на чтение
					; из области второго знакогенератора
					;
		LDA	PPU_DATA	; Первое чтение	из PPU "нелегально"
		LDA	#8
		STA	Counter

Read_CHRByte:				; CODE XREF: Draw_Char+33j
		LDA	PPU_DATA	; VRAM I/O Register (RW)
		PHA
		DEC	Counter
		BNE	Read_CHRByte	; Читаем восемь	байт из	области
					; Pattern Table, что соответствует сбросу
					; в стек графики отдельной буквы в
					; формате 1bpp
					;
					;
		LDA	#8
		STA	Counter		; 8 раз	будем тащить из	стека графику

NextByte:				; CODE XREF: Draw_Char+71j
		PLA
		STA	CHR_Byte
		LDA	#$80 ; 'А'
		STA	Mask_CHR_Byte

Next_Bit:				; CODE XREF: Draw_Char+5Fj
		LDX	BrickChar_X	; сначала в $005D всегда $1A
		LDY	BrickChar_Y	; сначала в $005e всегда $2e+$20=$4E
		JSR	Get_SprCoord_InTiles ; Переводит SPR_XY	в тайлы
		LDA	CHR_Byte
		AND	Mask_CHR_Byte
		BEQ	Empty_Pixel	; Этот пиксель чёрный
		JSR	NT_Buffer_Process_OR
		JMP	++
; ───────────────────────────────────────────────────────────────────────────

Empty_Pixel:				; CODE XREF: Draw_Char+4Bj
		JSR	NT_Buffer_Process_XOR ;	Этот пиксель чёрный

++:					; CODE XREF: Draw_Char+50j
		LDA	BrickChar_X
		CLC
		ADC	#4
		STA	BrickChar_X
		LSR	Mask_CHR_Byte	; переходим к следующему биту
		BCC	Next_Bit	; сначала в $005D всегда $1A
		LDA	BrickChar_X
		SEC
		SBC	#$20 ; ' '
		STA	BrickChar_X
		LDA	BrickChar_Y
		SEC
		SBC	#4
		STA	BrickChar_Y
		DEC	Counter
		BNE	NextByte
		RTS
; End of function Draw_Char


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Draw_BrickStr:				; CODE XREF: Load_DemoLevel+3Ep
					; Load_DemoLevel+51p
					; Draw_Record_HiScore+20p
					; Draw_Brick_GameOver+20p
					; Draw_Brick_GameOver+33p
					; Draw_TitleScreen+1Ap
					; Draw_TitleScreen+2Dp
					; Draw_RecordDigit+24p
		LDY	#0
		STY	String_Position

New_Char:				; CODE XREF: Draw_BrickStr+20j
		LDA	(LowStrPtr_Byte),Y ; Стринги загружаются
		CMP	#$FF
		BEQ	EOS
		INY
		STY	String_Position
		LDX	Block_X
		LDY	Block_Y
		CLC
		ADC	Char_Index_Base
		JSR	Draw_Char
		LDA	Block_X
		CLC
		ADC	#$20 ; ' '
		STA	Block_X
		LDY	String_Position
		JMP	New_Char	; Стринги загружаются
; ───────────────────────────────────────────────────────────────────────────

EOS:					; CODE XREF: Draw_BrickStr+8j
		RTS
; End of function Draw_BrickStr


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Ожидает немаскируемого прерывания

NMI_Wait:				; CODE XREF: ROM:Construction_Loopp
					; ROM:Start_StageSelScrnp ROM:C1F3p
					; ROM:Battle_Enginep
					; ROM:AfterDeath_BattleRunp
					; SetUp_LevelVARs+49p
					; Load_DemoLevel+60p
					; BonusLevel_ButtonCheckp
					; Draw_Record_HiScore:-p
					; Wait_1Second:loc_C56Bp Draw_Drop:--p
					; Draw_RespawnPicp
					; Draw_Brick_GameOver:Next_Framep
					; Scroll_TitleScrn:-p Draw_LevelFlagp
					; Title_Screen_Loop:-p
					; Draw_StageNumStringp
					; Copy_AttribToScrnBuff:-p
					; FillNT_with_Grey:-p
					; FillNT_with_Black:-p
					; Draw_Pts_Screen:DrawPtsScrn_NxtTankp
					; Draw_Pts_Screen:DrawPtsScrn_NxtCountp
					; Draw_Pts_Screen_Templatep
					; Draw_Pts_Screen_Template+65p
					; Draw_Pts_Screen_Template+C3p
					; Draw_Pts_Screen_Template:Skip_ScndPlayerDrawp
					; Draw_Pts_Screen_Template+160p
					; Draw_Pts_Screen_Template:Skip_ScndPlayerPtsDrawp
					; Draw_TitleScreen+93p
					; Draw_TitleScreen+C3p
					; Draw_TitleScreen+E4p
					; DrawTankColumn_XTimesp Screen_Offp
					; Load_Level:--p
		LDA	Frame_Counter

-:					; CODE XREF: NMI_Wait+4j
		CMP	Frame_Counter
		BEQ	-
		RTS
; End of function NMI_Wait


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Сборос из Screen_Buffer в память PPU

Update_Screen:				; CODE XREF: ROM:D413p
		LDX	ScrBuffer_Pos
		LDA	#0
		STA	Screen_Buffer,X
		TAX

-:					; CODE XREF: Update_Screen+27j
		CPX	ScrBuffer_Pos	; Достигнут ли конец строкового	буффера?
		BEQ	Update_Screen_End
		LDA	Screen_Buffer,X
		INX
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	Screen_Buffer,X
		INX
		STA	PPU_ADDRESS	; В начале каждой строки в Screen_Buffer стоят
					; hi/lo	адреса,	куда будет вестись запись

--:					; CODE XREF: Update_Screen+2Fj
		LDA	Screen_Buffer,X
		INX
		CMP	#$FF		; Проверка на конец строки
		BNE	++		; Непосредственно запись в память PPU
		LDA	Screen_Buffer,X
		CMP	#$FF
		BNE	-		; Достигнут ли конец строкового	буффера?
		LDA	$17F,X

++:					; CODE XREF: Update_Screen+20j
		STA	PPU_DATA	; Непосредственно запись в память PPU
		JMP	--
; ───────────────────────────────────────────────────────────────────────────

Update_Screen_End:			; CODE XREF: Update_Screen+Aj
		LDA	#0
		STA	ScrBuffer_Pos
		RTS
; End of function Update_Screen


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Установка указателя на ненулевой элемент строки

PtrToNonzeroStrElem:			; CODE XREF: Draw_Player_Lives+4Bp
					; Draw_LevelFlag+2Ep
					; Draw_StageNumString+57p
					; Draw_Pts_Screen+8Ep
					; Draw_Pts_Screen+9Ap
					; Draw_Pts_Screen+B5p
					; Draw_Pts_Screen+CDp
					; Draw_Pts_Screen+D9p
					; Draw_Pts_Screen+F4p
					; Draw_Pts_Screen+12Ep
					; Draw_Pts_Screen+143p
					; Draw_Pts_Screen+176p
					; Draw_Pts_Screen+182p
					; Draw_Pts_Screen+1D1p
					; Draw_Pts_Screen+1DDp
					; Draw_Pts_Screen_Template+3Dp
					; Draw_Pts_Screen_Template+5Dp
					; Draw_Pts_Screen_Template+7Bp
					; Draw_Pts_Screen_Template+D9p
					; Draw_TitleScreen+4Dp
					; Draw_TitleScreen+68p
					; Draw_TitleScreen+87p
					; PtrToNonzeroStrElem+7j
		LDA	0,Y
		BNE	+
		INY
		INX
		JMP	PtrToNonzeroStrElem ; Установка	указателя на ненулевой элемент строки
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: PtrToNonzeroStrElem+3j
		CMP	#$FF
		BNE	+++
		LDA	byte_6B
		BNE	++
		DEX
		DEY

++:					; CODE XREF: PtrToNonzeroStrElem+10j
		DEX
		DEY

+++:					; CODE XREF: PtrToNonzeroStrElem+Cj
		LDA	#0
		STA	HighPtr_Byte	; Строки располагаются в пределах нулевой
					; страницы RAM - старший байт всегда равен 0
		STY	LowPtr_Byte	; Теперь указатель адресует первый ненулевой элемент строки
		RTS
; End of function PtrToNonzeroStrElem


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Выводит на экран цифру рекорда

Draw_RecordDigit:			; CODE XREF: Draw_Record_HiScore+23p
		LDA	#$10
		STA	Block_X
		LDA	#$64 ; 'd'
		STA	Block_Y
		LDA	#$30 ; '0'      ; Начало графики цифр
		STA	Char_Index_Base
		LDY	#HiScore_String

-:					; CODE XREF: Draw_RecordDigit+1Bj
		LDA	0,Y
		BNE	+
		INY
		LDA	Block_X
		CLC
		ADC	#$20 ; ' '      ; $20 тайлов в одной строке
		STA	Block_X
		JMP	-
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Draw_RecordDigit+11j
		LDA	#0
		STA	HighStrPtr_Byte
		STY	LowStrPtr_Byte
		JSR	Draw_BrickStr
		LDA	#0
		STA	Char_Index_Base
		RTS
; End of function Draw_RecordDigit


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; На выходе A =	$FF, значит есть рекорд

Update_HiScore:				; CODE XREF: ROM:C286p
		LDX	#0
		LDY	#0

loc_D981:				; CODE XREF: Update_HiScore+Fj
		LDA	HiScore_1P_String,X
		CMP	HiScore_String,X
		BNE	loc_D98F
		INX
		CPX	#7
		BEQ	loc_D99E
		JMP	loc_D981
; ───────────────────────────────────────────────────────────────────────────

loc_D98F:				; CODE XREF: Update_HiScore+8j
		BMI	loc_D99E
		LDX	#0		; не выполнилось

loc_D993:				; CODE XREF: Update_HiScore+1Dj
		LDA	HiScore_1P_String,X
		STA	HiScore_String,X
		INX
		CPX	#7
		BNE	loc_D993
		LDY	#1

loc_D99E:				; CODE XREF: Update_HiScore+Dj
					; Update_HiScore:loc_D98Fj
		LDX	#0

loc_D9A0:				; CODE XREF: Update_HiScore+2Ej
		LDA	HiScore_2P_String,X
		CMP	HiScore_String,X
		BNE	loc_D9AE
		INX
		CPX	#7
		BEQ	locret_D9BD
		JMP	loc_D9A0
; ───────────────────────────────────────────────────────────────────────────

loc_D9AE:				; CODE XREF: Update_HiScore+27j
		BMI	locret_D9BD
		LDX	#0		; Не выполнилось

loc_D9B2:				; CODE XREF: Update_HiScore+3Cj
		LDA	HiScore_2P_String,X
		STA	HiScore_String,X
		INX
		CPX	#7
		BNE	loc_D9B2
		LDY	#$FF

locret_D9BD:				; CODE XREF: Update_HiScore+2Cj
					; Update_HiScore:loc_D9AEj
		RTS
; End of function Update_HiScore


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Прибавляет число из NumString	к очкам	игрока №Х

Add_Score:				; CODE XREF: Draw_Pts_Screen+62p
					; Draw_Pts_Screen+80p
					; Draw_Pts_Screen+16Fp
					; Draw_Pts_Screen+1CAp
					; BulletToTank_Impact_Handle+118p
					; Bonus_Handle+4Bp
;! не прибавляем очки, если бонус взял враг.
		CPX	#2
		BCS	+++
		TXA
		ASL	A
		ASL	A
		ASL	A		; Умножаем на $10
		CLC
		ADC	#6
		TAX
		LDY	#6
		CLC

-:					; CODE XREF: Add_Score+20j
		LDA	Num_String,Y
		ADC	HiScore_1P_String,X
		CMP	#$A		; Если > 10, то	переходим в следующий разряд
		BMI	+
		SEC
		SBC	#$A
		SEC
		JMP	++
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Add_Score+12j
		CLC

++:					; CODE XREF: Add_Score+18j
		STA	HiScore_1P_String,X
		DEX
		DEY
		BPL	-
+++:
		RTS
; End of function Add_Score


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Переводит число из А в строку	NumString

Num_To_NumString:			; CODE XREF: ROM:C758p	ROM:C773p
					; Draw_Pts_Screen+4Bp
					; Draw_Pts_Screen+16Ap
					; Draw_Pts_Screen+1C5p
					; BulletToTank_Impact_Handle+112p
					; Bonus_Handle+46p
		STA	Temp
		LDX	#Num_String
		JSR	Null_8Bytes_String
		LDA	Temp
		BEQ	+		; Если передается 0, выставляем	1000 очков
		AND	#$F
		STA	Num_String+5
		LDA	Temp
		LSR	A
		LSR	A
		LSR	A
		LSR	A
		STA	Num_String+4
		RTS
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Num_To_NumString+9j
		LDA	#1		; Если передается 0, выставляем	1000 очков
		STA	Num_String+3	; Переходим в следующий	разряд
		RTS
; End of function Num_To_NumString


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Null_8Bytes_String:			; CODE XREF: Null_both_HiScore+2p
					; Null_both_HiScore+7p
					; Draw_Pts_Screen+2Ep
					; Draw_Pts_Screen+33p
					; Reset_ScreenStuff+23p
					; Reset_ScreenStuff+28p
					; Reset_ScreenStuff+32p
					; Num_To_NumString+4p
					; ByteTo_Num_String+4p
		LDA	#0
		STA	0,X
		STA	1,X
		STA	2,X
		STA	3,X
		STA	4,X
		STA	5,X
		STA	6,X
		LDA	#$FF
		STA	7,X
		RTS
; End of function Null_8Bytes_String


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


ByteTo_Num_String:			; CODE XREF: Draw_Player_Lives:Draw_LivesDigitp
					; Draw_LevelFlag+27p
					; Draw_StageNumString+50p
					; Draw_Pts_Screen+AEp
					; Draw_Pts_Screen+EDp
					; Draw_Pts_Screen+127p
					; Draw_Pts_Screen+13Cp
					; Draw_Pts_Screen_Template+56p
		STA	Temp
		LDX	#Num_String
		JSR	Null_8Bytes_String
		LDA	Temp

Check_Max:				; CODE XREF: ByteTo_Num_String+12j
		CMP	#10		; Числа	хранятся в десятичной системе -	один знак 0-9.
					; Если число >=	10, то появляется второй знак.
		BCC	loc_DA28
		SEC
		SBC	#10
		INC	Num_String+5
		JMP	Check_Max	; Числа	хранятся в десятичной системе -	один знак 0-9.
					; Если число >=	10, то появляется второй знак.
; ───────────────────────────────────────────────────────────────────────────

loc_DA28:				; CODE XREF: ByteTo_Num_String+Bj
		STA	Num_String+6
		RTS
; End of function ByteTo_Num_String


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Сбрасывает в спрайтовый буффер один спрайт 8х16

SaveSprTo_SprBuffer:			; CODE XREF: Draw_Pause+1Ap
					; Draw_Pause+25p Draw_Pause+30p
					; Draw_Pause+3Bp Draw_Pause+46p
					; Indexed_SaveSpr+Bp Draw_WholeSpr+9p
					; Draw_WholeSpr+14p
		TXA
; В X и	Y координаты выводимого	спрайта
		STA	Spr_X
		CLC
		ADC	#3
		TAX
		TYA
		SEC
		SBC	#8
		STA	Spr_Y
		JSR	GetCoord_InTiles ; Переводим из	координат в пикселях в координаты в тайлах
		LDA	(LowPtr_Byte),Y
		CMP	#$22 ; '"'      ; Проверка на пересечение спрайта танка с лесом: $22 в Pattern Table - тайл леса
					; в атрибуте спрайта в этом случае бит p = Background Priority
					; должен быть выставлен	в 1
		BNE	Skip_Attrib
		LDA	TSA_Pal
		ORA	Spr_Attrib
		STA	TSA_Pal		; Добавляем к палитрам еще и атрибуты

Skip_Attrib:				; CODE XREF: SaveSprTo_SprBuffer+14j
		LDX	SprBuffer_Position
		LDA	Spr_Y
		STA	SprBuffer,X
		LDA	Spr_TileIndex
		STA	SprBuffer+1,X
		LDA	TSA_Pal
		STA	SprBuffer+2,X
		LDA	Spr_X
		STA	SprBuffer+3,X
		TXA
		CLC
		ADC	Gap		; Переходим к следующему спрайту
		STA	SprBuffer_Position
		RTS
; End of function SaveSprTo_SprBuffer


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Сбрасывает в SprBuffer спрайт	8х16 со	смещением в А

Indexed_SaveSpr:			; CODE XREF: ROM:E10Ep
		ASL	A
		CLC
		ADC	Spr_TileIndex
		STA	Spr_TileIndex
		TXA
		SEC
		SBC	#5
		TAX
		JSR	SaveSprTo_SprBuffer ; Сбрасывает в спрайтовый буффер один спрайт 8х16
		RTS
; End of function Indexed_SaveSpr


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Spr_TileIndex	+ (A * 8)

Spr_TileIndex_Add:			; CODE XREF: ROM:DFFFp
		ASL	A
		ASL	A
		ASL	A
		CLC
		ADC	Spr_TileIndex
		STA	Spr_TileIndex
; End of function Spr_TileIndex_Add


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)

Draw_WholeSpr:				; CODE XREF: Draw_Drop+31p
					; Draw_RespawnPic+25p
					; Draw_Fixed_GameOver+12p
					; Draw_Fixed_GameOver+23p
					; Draw_Spr_InColumn+4p
					; Draw_Bullet_Ricochet+17p ROM:DF1Dp
					; ROM:DF5Bp ROM:DF6Dp	ROM:DF7Fp
					; ROM:DF91p ROM:E02Ap	Bonus_Draw+39p
					; Invisible_Timer_Handle+25p
					; Add_ExplodeSprBase-4p
		STX	Temp_X
		STY	Temp_Y
		TXA
		SEC
		SBC	#8		; Cмещаемся на тайл влево
		TAX
		JSR	SaveSprTo_SprBuffer ; Сбрасывает в спрайтовый буффер один спрайт 8х16
		INC	Spr_TileIndex
		INC	Spr_TileIndex	; В Pattern Table тайлы	спрайтов хранятся в Raw	Interleaved
					; формате:
					;
					;		     13
					;		     24
					;
					; Это обусловлено тем, что PPU работает	в режиме тайлов,
					; размерностью 8х16. В РОМе между соседними тайлами в линии лежит еще один
					; тайл - поэтому увеличиваем индекс на 2
		LDX	Temp_X		; Восстанавливаем Х - переходим	на тайл	правее
		LDY	Temp_Y
		JSR	SaveSprTo_SprBuffer ; Сбрасывает в спрайтовый буффер один спрайт 8х16
		RTS
; End of function Draw_WholeSpr


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Вывод	Y координат спрайтов в $F0

Spr_Invisible:				; CODE XREF: ROM:D436p
					; Reset_ScreenStuff+1Ep
		LDX	SprBuffer_Position
		LDA	Gap
		EOR	#$FF
		CLC
		ADC	#1		; Gap := -Gap
		STA	Gap

-:					; CODE XREF: Spr_Invisible+17j
		TXA
		CLC
		ADC	Gap		; заполнять начинаем с конца
		TAX
		LDA	#$F0 ; 'Ё'
		STA	SprBuffer,X
		CPX	#4
		BNE	-
		STX	SprBuffer_Position
		RTS
; End of function Spr_Invisible


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Если >0 возвращает $1. <0 возвращает $FF

Relation_To_Byte:			; CODE XREF: Load_AI_Status+5p
					; Load_AI_Status+12p
		BEQ	End_RelationToByte
		BCS	+
		LDA	#$FF
		JMP	End_RelationToByte
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Relation_To_Byte+2j
		LDA	#1

End_RelationToByte:			; CODE XREF: Relation_To_Bytej
					; Relation_To_Byte+6j
		RTS
; End of function Relation_To_Byte

; ───────────────────────────────────────────────────────────────────────────
TSABlock_PalNumber:.BYTE 0, 0, 0, 0, 0,	3, 3, 3, 3, 3, 1, 2, 3,	0, 0, 0
					; DATA XREF: Draw_TSABlock+Cr
;Палитры на каждый TSA блок (всего 16)
;00 - цвет кирпичей
;01 - цвет воды
;02 - цвет леса
;03 - цвет брони
;
TSA_data_start:	.BYTE	0, $F,	0, $F	; DATA XREF: Draw_TSABlock+27r
					; Draw_TSABlock+33r Draw_TSABlock+3Fr
					; Draw_TSABlock+4Br
		.BYTE	0,  0, $F, $F
		.BYTE  $F,  0, $F,  0
		.BYTE  $F, $F,	0,  0
		.BYTE  $F, $F, $F, $F
		.BYTE $20,$10,$20,$10
		.BYTE $20,$20,$10,$10
		.BYTE $10,$20,$10,$20
		.BYTE $10,$10,$20,$20
		.BYTE $10,$10,$10,$10
		.BYTE $12,$12,$12,$12
		.BYTE $22,$22,$22,$22
		.BYTE $21,$21,$21,$21
		.BYTE	0,  0,	0,  0
		.BYTE	0,  0,	0,  0
		.BYTE	0,  0,	0,  0
;Содержит индексы тайлов на каждый TSA блок.
;Например, блок	льда (по счёту $0C) cодержит все 4
;тайла с индексами $21 (тайл с таким индексом в
;Pattern Table - это тайл льда)
;
;Номерация следующая:
;1 2
;3 4
;
;16 возможных TSA блоков.Три последних TSA блока пустые	(по счёту $0D-$0F)


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Играет и гасит звук движения когда нужно

Play_Snd_Move:				; CODE XREF: Battle_Loop+2Dp
		LDA	Snd_Move
		BEQ	No_MoveSound	; Первый игрок
		LDX	#0		; Первый игрок
		JSR	Detect_Motion	; Если танк должен двигаться, 1
		BNE	End_Play_Snd_Move
		LDX	#1		; Второй игрок
		JSR	Detect_Motion	; Если танк должен двигаться, 1
		BNE	End_Play_Snd_Move
		LDA	#0
		STA	Snd_Move	; Гасим	звук движения
		RTS
; ───────────────────────────────────────────────────────────────────────────

No_MoveSound:				; CODE XREF: Play_Snd_Move+3j
		LDX	#0		; Первый игрок
		JSR	Detect_Motion	; Если танк должен двигаться, 1
		BNE	+
		LDX	#1		; Второй игрок
		JSR	Detect_Motion	; Если танк должен двигаться, 1
		BEQ	End_Play_Snd_Move

+:					; CODE XREF: Play_Snd_Move+1Ej
		LDA	#1
		STA	Snd_Move	; Играем звук движения

End_Play_Snd_Move:			; CODE XREF: Play_Snd_Move+Aj
					; Play_Snd_Move+11j Play_Snd_Move+25j
		RTS
; End of function Play_Snd_Move


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Если танк должен двигаться, 1

Detect_Motion:				; CODE XREF: Play_Snd_Move+7p
					; Play_Snd_Move+Ep Play_Snd_Move+1Bp
					; Play_Snd_Move+22p
		LDA	Joypad1_Buttons,X
		AND	#$F0 ; 'Ё'
		BEQ	End_Detect_Motion ; Если клавиши управления не нажаты, возвращаем ноль
		LDA	Tank_Status,X
		BEQ	End_Detect_Motion ; Если танка нет, возвращаем ноль
		LDA	#1
		RTS
; ───────────────────────────────────────────────────────────────────────────

End_Detect_Motion:			; CODE XREF: Detect_Motion+4j
					; Detect_Motion+8j
		LDA	#0
		RTS
; End of function Detect_Motion


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Respawn_Handle:				; CODE XREF: Battle_Loop+1Bp
		LDA	Respawn_Timer	; Время	до следующего респауна
		BEQ	+		; Если время следующего	респауна не пришло, выходим
		DEC	Respawn_Timer	; Время	до следующего респауна
		RTS
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Respawn_Handle+2j
		LDA	Enemy_Reinforce_Count ;	Количество врагов в запасе
		BEQ	End_Respawn_Handle ; Если врагов в запасе не осталось, выходим
		LDA	TanksOnScreen	; Максимальное количество всех танков на экране
		STA	Counter

-:					; CODE XREF: Respawn_Handle+2Aj
		LDX	Counter
		LDA	Tank_Status,X
		BNE	++		; Рисуем респауны тем танкам, которых уже нет на экране
		LDA	Respawn_Delay	; Задержка между респаунами врагов
		STA	Respawn_Timer	; Восстанавливаем таймер
		JSR	Make_Respawn
		DEC	Enemy_Reinforce_Count ;	Количество врагов в запасе
		LDA	Enemy_Reinforce_Count ;	Количество врагов в запасе
		JSR	Draw_EmptyTile	; Рисует пустой	тайл в колонке запасов врагов, когда они выходят
		RTS
; ───────────────────────────────────────────────────────────────────────────

++:					; CODE XREF: Respawn_Handle+13j
		DEC	Counter
		LDA	Counter
		CMP	#1		; Не обрабатываем обоих	игроков
		BNE	-

End_Respawn_Handle:			; CODE XREF: Respawn_Handle+9j
		RTS
; End of function Respawn_Handle


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Выполняет скольжение,	если танк двигается на льду

Ice_Move:				; CODE XREF: Battle_Loop+3p
		LDA	Frame_Counter
		AND	#1
		BNE	+		; Обрабатываем только игроков
		LDA	Frame_Counter
		AND	#3
		BNE	End_Ice_Move	; Логика, не производящая обработку на каждом 4-м фрейме:
					; т.е. если номер фрейма 2, 4, 10, 14, 18

+:					; CODE XREF: Ice_Move+4j
		LDX	#1		; Обрабатываем только игроков

-:					; CODE XREF: Ice_Move+79j
		LDA	Tank_Status,X
		BPL	++++++		; Если танк взорван, переходим к следующему
		CMP	#$E0 ; 'р'
		BCS	++++++		; Если танк зарождается, переходим к следующему
		LDA	Player_Blink_Timer,X ; Таймер мигания friendly fire
		BEQ	+++++
		DEC	Player_Blink_Timer,X ; Таймер мигания friendly fire
		JMP	Usual_Tank
; ───────────────────────────────────────────────────────────────────────────

+++++:					; CODE XREF: Ice_Move+18j
		LDA	Player_Ice_Status,X
		BPL	++++		; Либо танк не на льду,	либо
					; он закончил катиться
		AND	#$10
		BNE	Usual_Tank

++++:					; CODE XREF: Ice_Move+22j
		LDA	Joypad1_Buttons,X ; Либо танк не на льду, либо
					; он закончил катиться
		JSR	Button_To_DirectionIndex ; $FF = кнопки	управления не нажаты
		STA	Temp
		BPL	loc_DBB4

Usual_Tank:				; CODE XREF: Ice_Move+1Cj Ice_Move+26j
		LDA	#$80 ; 'А'
		JSR	Rise_TankStatus_Bit ; Tank_Status OR А
		LDA	#8
		ORA	Tank_Status,X
		STA	Tank_Status,X
		JMP	++++++		; Переходим к следующему танку
; ───────────────────────────────────────────────────────────────────────────

loc_DBB4:				; CODE XREF: Ice_Move+2Fj
		LDA	Player_Ice_Status,X
		BPL	++
		AND	#$1F
		BNE	++		; Если таймер скольжения не
					; кончился, не восстанавливаем его
		LDA	#$9C		; $1c фреймов будет скользить танк
		STA	Player_Ice_Status,X
		LDA	#1
		STA	Snd_Ice		; Проигрываем звук скольжения

++:					; CODE XREF: Ice_Move+42j Ice_Move+46j
		LDA	Tank_Status,X
		AND	#3
		CMP	Temp
		BEQ	+++
		EOR	#2
		CMP	Temp
		BEQ	+++
		LDA	Tank_X,X
		CLC
		ADC	#4
		AND	#$F8 ; '°'
		STA	Tank_X,X
		LDA	Tank_Y,X
		CLC
		ADC	#4
		AND	#$F8 ; '°'
		STA	Tank_Y,X

+++:					; CODE XREF: Ice_Move+58j Ice_Move+5Ej
		LDA	Temp
		ORA	#$A0
		STA	Tank_Status,X

++++++:					; CODE XREF: Ice_Move+10j Ice_Move+14j
					; Ice_Move+3Cj
		DEX			; Переходим к следующему танку
		BPL	-

End_Ice_Move:				; CODE XREF: Ice_Move+Aj
					; DATA XREF: ROM:HQExplode_JumpTableo
					; ROM:TankStatus_JumpTableo
					; ROM:TankDraw_JumpTableo
					; ROM:Bullet_Status_JumpTableo
					; ROM:BulletGFX_JumpTableo
		RTS			; возвращаемся по RTS
; End of function Ice_Move


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Замораживает врагов, если нужно (обработка движения)

Motion_Handle:				; CODE XREF: Battle_Loop+6p
		LDA	#7
		STA	Counter		; Всего	возможно 8 танков
		LDA	EnemyFreeze_Timer
		BEQ	Skip_TimerOps
		LDA	Frame_Counter
		AND	#63		; Каждую секунду уменьшаем таймер заморозки
		BNE	Skip_TimerOps
		DEC	EnemyFreeze_Timer

Skip_TimerOps:				; CODE XREF: Motion_Handle+7j
					; Motion_Handle+Dj Motion_Handle+49j
		LDX	Counter
		CPX	#2
		BCS	Enemy		; Если > 2, то это враг
		LDA	Frame_Counter
		AND	#1
		BNE	JumpToStatusHandle
		LDA	Frame_Counter
		AND	#3
		BNE	Motion_Handle_Next ; Обрабатываем статусы в
					; определенные фреймы
		JMP	JumpToStatusHandle
; ───────────────────────────────────────────────────────────────────────────

Enemy:					; CODE XREF: Motion_Handle+16j
		LDA	EnemyFreeze_Timer
		BEQ	+
		LDA	Tank_Status,X
		BPL	+
		CMP	#$E0 ; 'р'
		BCC	Motion_Handle_Next

+:					; CODE XREF: Motion_Handle+2Aj
					; Motion_Handle+2Ej
		LDA	Tank_Type,X
		AND	#$F0 ; 'Ё'
		CMP	#$A0		; У БТР	(враг №2) статус обрабатывается	в 2
					; раза чаще, поэтому он	быстрее	ездит
		BEQ	JumpToStatusHandle
		LDA	Counter
		EOR	Frame_Counter
		AND	#1
		BEQ	Motion_Handle_Next

JumpToStatusHandle:			; CODE XREF: Motion_Handle+1Cj
					; Motion_Handle+24j Motion_Handle+3Aj
		JSR	Status_Core	; Выполняет команды jumptable в	зависимости от статуса

Motion_Handle_Next:			; CODE XREF: Motion_Handle+22j
					; Motion_Handle+32j Motion_Handle+42j
		DEC	Counter
		BPL	Skip_TimerOps
		RTS
; End of function Motion_Handle


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Выполняет команды jumptable в	зависимости от статуса

Status_Core:				; CODE XREF: Motion_Handle:JumpToStatusHandlep
		LDA	Tank_Status,X
		LSR	A
		LSR	A
		LSR	A
		AND	#11111110b
		TAY
		LDA	TankStatus_JumpTable,Y
		STA	LowPtr_Byte
		LDA	TankStatus_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; End of function Status_Core

; ───────────────────────────────────────────────────────────────────────────

Misc_Status_Handle:			; DATA XREF: ROM:E4A8o
		CPX	#2		; Обрабатывает статусы льда, позицию трека и т.п.
		BCS	LoadStts_Misc_Status_Handle
		LDA	Player_Ice_Status,X
		BPL	LoadStts_Misc_Status_Handle
		AND	#$7F ; ''
		BEQ	LoadStts_Misc_Status_Handle
		DEC	Player_Ice_Status,X
		LDA	Track_Pos,X
		EOR	#4
		STA	Track_Pos,X
		JMP	Check_Obj
; ───────────────────────────────────────────────────────────────────────────

LoadStts_Misc_Status_Handle:		; CODE XREF: ROM:DC54j	ROM:DC59j
					; ROM:DC5Dj
		LDA	Tank_Status,X
		SEC
		SBC	#4
		STA	Tank_Status,X
		AND	#$C
		BNE	End_Misc_Status_Handle
		LDA	#Tank_Status
		JSR	Rise_TankStatus_Bit ; Tank_Status OR А

End_Misc_Status_Handle:			; CODE XREF: ROM:DC74j
		RTS
; ───────────────────────────────────────────────────────────────────────────

Check_TileReach:			; DATA XREF: ROM:E4ACo
		CPX	#2		; Проверяет у врага, достиг ли он конца	тайла
		BCC	Check_Obj
		LDA	Tank_X,X
		AND	#7
		BNE	Check_Obj
		LDA	Tank_Y,X
		AND	#7
		BNE	Check_Obj
		JSR	Get_Random_A	; ГПСЧ,	в А случайное число
		AND	#$F
		BNE	Check_Obj
		JSR	Get_RandomDirection ; Получает случайное направление и сохраняет в статус
		RTS
; ───────────────────────────────────────────────────────────────────────────

Check_Obj:				; CODE XREF: ROM:DC68j	ROM:DC7Ej
					; ROM:DC84j ROM:DC8Aj	ROM:DC91j
		LDA	Tank_Status,X
		AND	#3
		TAY
		LDA	Bullet_Coord_Y_Increment_1,Y
		ASL	A
		ASL	A
		ASL	A
		STA	byte_59
		LDA	Bullet_Coord_Y_Increment_1,Y
		CLC
		ADC	Tank_Y,X
		STA	Block_Y
		LDA	Bullet_Coord_X_Increment_1,Y
		ASL	A
		ASL	A
		ASL	A
		STA	byte_58
		LDA	Bullet_Coord_X_Increment_1,Y
		CLC
		ADC	Tank_X,X
		STA	Block_X
		CLC
		ADC	byte_58
		CLC
		ADC	byte_59
		JSR	Compare_Block_X	; Сравнивает А и BlockX	и если больше, вычитает	1
		TAX
		LDA	Block_Y
		CLC
		ADC	byte_58
		CLC
		ADC	byte_59
		JSR	Compare_Block_Y	; Сравнивает А и BlockY	и если больше, вычитает	1
		TAY
		JSR	GetCoord_InTiles ; В Х и Y на выходе координаты	в тайлах
		LDA	(LowPtr_Byte),Y
		BMI	GetRnd_CheckObj
		BEQ	CheckX_Check_Obj
		CMP	#$20 ; ' '
		BCC	GetRnd_CheckObj

CheckX_Check_Obj:			; CODE XREF: ROM:DCD9j
		LDA	Block_X
		CLC
		ADC	byte_58
		SEC
		SBC	byte_59
		JSR	Compare_Block_X	; Сравнивает А и BlockX	и если больше, вычитает	1
		TAX
		LDA	Block_Y
		CLC
		ADC	byte_59
		SEC
		SBC	byte_58
		JSR	Compare_Block_Y	; Сравнивает А и BlockY	и если больше, вычитает	1
		TAY
		JSR	GetCoord_InTiles ; В Х и Y на выходе координаты	в тайлах
		LDA	(LowPtr_Byte),Y
		BMI	GetRnd_CheckObj
		BEQ	SaveCoord_Check_Obj
		CMP	#$20 ; ' '
		BCC	GetRnd_CheckObj

SaveCoord_Check_Obj:			; CODE XREF: ROM:DCFEj
		LDX	Counter
		LDA	Block_X
		STA	Tank_X,X
		LDA	Block_Y
		STA	Tank_Y,X
		JMP	TrackHandle_CheckObj
; ───────────────────────────────────────────────────────────────────────────

GetRnd_CheckObj:			; CODE XREF: ROM:DCD7j	ROM:DCDDj
					; ROM:DCFCj ROM:DD02j
		LDX	Counter
		CPX	#2
		BCC	TrackHandle_CheckObj
		JSR	Get_Random_A	; ГПСЧ,	в А случайное число
		AND	#3
		BEQ	CheckTile_Check_Obj
		LDA	#$80 ; 'А'
		JSR	Rise_TankStatus_Bit ; Tank_Status OR А
		LDA	#8
		ORA	Tank_Status,X
		STA	Tank_Status,X

TrackHandle_CheckObj:			; CODE XREF: ROM:DD0Ej	ROM:DD15j
		LDA	Track_Pos,X
		EOR	#4
		STA	Track_Pos,X
		RTS
; ───────────────────────────────────────────────────────────────────────────

CheckTile_Check_Obj:			; CODE XREF: ROM:DD1Cj
		LDA	Tank_X,X
		AND	#7
		BNE	Change_Direction_Check_Obj
		LDA	Tank_Y,X
		AND	#7
		BNE	Change_Direction_Check_Obj
		LDA	#$90 ; 'Р'
		JSR	Rise_TankStatus_Bit ; Tank_Status OR А

Change_Direction_Check_Obj:		; CODE XREF: ROM:DD34j	ROM:DD3Aj
		LDA	Tank_Status,X
		EOR	#2
		STA	Tank_Status,X
		RTS
; ───────────────────────────────────────────────────────────────────────────

Get_RandomStatus:			; DATA XREF: ROM:E4AAo
		JSR	Get_Random_A	; В основном, получает случайный статус
		AND	#1
		BEQ	End_Get_RandomStatus
		JSR	Get_Random_A	; ГПСЧ,	в А случайное число
		AND	#1
		BEQ	Sbc_Get_RandomStatus
		LDA	Tank_Status,X
		CLC
		ADC	#1		; Меняем направление на	большее
		JMP	Save_Get_RandomStatus ;	Выделяем направление и сохраняем его в статус
; ───────────────────────────────────────────────────────────────────────────

Sbc_Get_RandomStatus:			; CODE XREF: ROM:DD54j
		LDA	Tank_Status,X
		SEC
		SBC	#1		; Меняем направление на	меньшее

Save_Get_RandomStatus:			; CODE XREF: ROM:DD5Bj
		AND	#3		; Выделяем направление и сохраняем его в статус
		ORA	#Tank_Status
		STA	Tank_Status,X
		RTS
; ───────────────────────────────────────────────────────────────────────────

End_Get_RandomStatus:			; CODE XREF: ROM:DD4Dj
		JSR	Get_RandomDirection ; Получает случайное направление и сохраняет в статус
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Сравнивает А и BlockX	и если больше, вычитает	1

Compare_Block_X:			; CODE XREF: ROM:DCC2p	ROM:DCE7p
		CMP	Block_X
		BCC	+
		SEC
		SBC	#1

+:					; CODE XREF: Compare_Block_X+2j
		RTS
; End of function Compare_Block_X


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Сравнивает А и BlockY	и если больше, вычитает	1

Compare_Block_Y:			; CODE XREF: ROM:DCCEp	ROM:DCF3p
		CMP	Block_Y
		BCC	+
		SEC
		SBC	#1

+:					; CODE XREF: Compare_Block_Y+2j
		RTS
; End of function Compare_Block_Y

; ───────────────────────────────────────────────────────────────────────────

Aim_FirstPlayer:			; DATA XREF: ROM:E4B2o
		LDA	Tank_X		; Устанавливает	в качестве цели	врага второго игрока
		STA	AI_X_Aim
		LDA	Tank_Y
		STA	AI_Y_Aim
		JMP	Save_AI_ToStatus
; ───────────────────────────────────────────────────────────────────────────

Aim_ScndPlayer:				; DATA XREF: ROM:E4B0o
		LDA	Tank_X+1	; Устанавливает	в качестве цели	врага первого игрока
		STA	AI_X_Aim
		LDA	Tank_Y+1
		STA	AI_Y_Aim
		JMP	Save_AI_ToStatus
; ───────────────────────────────────────────────────────────────────────────

Aim_HQ:					; DATA XREF: ROM:E4AEo
		LDA	#$78 ; 'x'      ; Устанавливает в качестве целевой координаты штаб
		STA	AI_X_Aim
		LDA	#$D8 ; '╪'
		STA	AI_Y_Aim

Save_AI_ToStatus:			; CODE XREF: ROM:DD86j	ROM:DD91j
		JSR	Load_AI_Status
		STA	Tank_Status,X
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Load_AI_Status:				; CODE XREF: Demo_AI+16p Demo_AI+2Cp
					; Demo_AI+42p Demo_AI+58p
					; ROM:Save_AI_ToStatusp
		LDA	AI_X_Aim
;Загружает статус из таблицы в зависимости от расстояния до цели
		SEC
		SBC	Tank_X,X
		JSR	Relation_To_Byte ; Если	>0 возвращает $1. <0 возвращает	$FF
		CLC
		ADC	#1
		STA	AI_X_DifferFlag
		LDA	AI_Y_Aim
		SEC
		SBC	Tank_Y,X
		JSR	Relation_To_Byte ; Если	>0 возвращает $1. <0 возвращает	$FF
		CLC
		ADC	#1
		STA	AI_Y_DifferFlag
		ASL	A
		CLC
		ADC	AI_Y_DifferFlag
		CLC
		ADC	AI_X_DifferFlag
		STA	AI_X_DifferFlag	; X = Y*3 + X
		CPX	#2
		BCS	Load_AIStatus_GetRandom	; Если это враг, получаем его команду из первой
					; или второй части в зависимости от ГПСЧ
		TXA			; У игрока загружать из	первой или из второй части
					; зависит только от времени
		ASL	A
		EOR	Seconds_Counter
		AND	#2
		BEQ	loc_DDE4
		JMP	LoadSecondPart
; ───────────────────────────────────────────────────────────────────────────

Load_AIStatus_GetRandom:		; CODE XREF: Load_AI_Status+25j
		JSR	Get_Random_A	; ГПСЧ,	в А случайное число
		AND	#1
		BEQ	loc_DDE4

LoadSecondPart:				; CODE XREF: Load_AI_Status+2Fj
		LDA	#9
		CLC
		ADC	AI_X_DifferFlag	; Переходим во вторую часть таблицы
		TAY
		JMP	End_Load_AIStatus
; ───────────────────────────────────────────────────────────────────────────

loc_DDE4:				; CODE XREF: Load_AI_Status+2Dj
					; Load_AI_Status+37j
		LDY	AI_X_DifferFlag

End_Load_AIStatus:			; CODE XREF: Load_AI_Status+3Fj
		LDA	AI_Status,Y
		RTS
; End of function Load_AI_Status

; ───────────────────────────────────────────────────────────────────────────

Explode_Handle:				; DATA XREF: ROM:E49Ao	ROM:E49Co
					; ROM:E49Eo ROM:E4A0o	ROM:E4A2o
					; ROM:E4A4o ROM:E4A6o
		DEC	Tank_Status,X	; Обрабатывает взрыв танка (уменьшает число жизней, GameOver...)
		LDA	Tank_Status,X
		AND	#$F
		BNE	End_Explode_Handle
		LDA	Tank_Status,X
		SEC
		SBC	#$10
		BEQ	Skip_Explode_Handle
		CMP	#$10
		BNE	SkipRiseBit_Explode_Handle
		ORA	#6
		JMP	SaveStts_Explode_Handle
; ───────────────────────────────────────────────────────────────────────────

SkipRiseBit_Explode_Handle:		; CODE XREF: ROM:DDFBj
		ORA	#3

SaveStts_Explode_Handle:		; CODE XREF: ROM:DDFFj
		STA	Tank_Status,X
		RTS
; ───────────────────────────────────────────────────────────────────────────

Skip_Explode_Handle:			; CODE XREF: ROM:DDF7j
		STA	Tank_Status,X
		CPX	#2
		BCS	Dec_Enemy_Explode_Handle
		DEC	Player1_Lives,X
		BEQ	CheckHQ_Explode_Handle
		JSR	Make_Respawn
		RTS
; ───────────────────────────────────────────────────────────────────────────

Dec_Enemy_Explode_Handle:		; CODE XREF: ROM:DE0Bj
		DEC	Enemy_Counter	; Количество врагов на экране и	в запасе
		RTS
; ───────────────────────────────────────────────────────────────────────────

CheckHQ_Explode_Handle:			; CODE XREF: ROM:DE0Fj
		LDA	HQ_Status	; 80=штаб цел, если ноль то уничтожен
		CMP	#$80 ; 'А'      ; Штаб цел? $80=цел
		BNE	End_Explode_Handle ; нет
		CPX	#1		; да
		BEQ	Check1pLives_Explode_Handle
		LDA	Player2_Lives
		BEQ	End_Explode_Handle
		LDA	#3		; Если первого игрока уже нет, а у второго остались жизни,
					; Game Over вылезает слева направо
		STA	GameOverScroll_Type ; Определяет вид перемещения надписи(0..3)
		LDA	#$20 ; ' '
		STA	GameOverStr_X
		JSR	Init_GameOver_Properties
		RTS
; ───────────────────────────────────────────────────────────────────────────

Check1pLives_Explode_Handle:		; CODE XREF: ROM:DE20j
		LDA	Player1_Lives
		BEQ	End_Explode_Handle
		LDA	#1		; Если второго игрока нет, а у первого игрока остались жизни,
					; Game Over вылезает справа налево
		STA	GameOverScroll_Type ; Определяет вид перемещения надписи(0..3)
		LDA	#$C0 ; '└'
		STA	GameOverStr_X
		JSR	Init_GameOver_Properties

End_Explode_Handle:			; CODE XREF: ROM:DDF0j	ROM:DE1Cj
					; ROM:DE24j ROM:DE36j
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Init_GameOver_Properties:		; CODE XREF: ROM:DE30p	ROM:DE42p
		LDA	#$D
		STA	GameOverStr_Timer ; Инициализируем таймер
		LDA	#$D8 ; '╪'      ; Начинаем выдвигаться снизу
		STA	GameOverStr_Y
		LDA	#0
		STA	Frame_Counter
		RTS
; End of function Init_GameOver_Properties

; ───────────────────────────────────────────────────────────────────────────

Set_Respawn:				; DATA XREF: ROM:E4B6o
		INC	Tank_Status,X	; Устанавливает	в статусе Респаун
		LDA	Tank_Status,X
		AND	#$F
		CMP	#$E
		BNE	End_Set_Respawn
		LDA	#$E0 ; 'р'
		STA	Tank_Status,X

End_Set_Respawn:			; CODE XREF: ROM:DE5Dj
		RTS
; ───────────────────────────────────────────────────────────────────────────

Load_Tank:				; DATA XREF: ROM:E4B4o
		INC	Tank_Status,X	; Загружает нужный тип нового танка, если нужно
		LDA	Tank_Status,X
		AND	#$F
		CMP	#$E
		BNE	End_Load_Tank
		JSR	Load_New_Tank	; Загружает нужный тип нового танка

End_Load_Tank:				; CODE XREF: ROM:DE6Cj
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Получает случайное направление и сохраняет в статус

Get_RandomDirection:			; CODE XREF: ROM:DC93p
					; ROM:End_Get_RandomStatusp
		LDA	Respawn_Delay	; Задержка между респаунами врагов
		LSR	A
		LSR	A
		CMP	Seconds_Counter
		BCS	loc_DE7F
		LDA	#$B0 ; '░'
		JMP	loc_DEA2
; ───────────────────────────────────────────────────────────────────────────

loc_DE7F:				; CODE XREF: Get_RandomDirection+6j
		LSR	A
		CMP	Seconds_Counter
		BCC	loc_DE8E
		JSR	Get_Random_A	; ГПСЧ,	в А случайное число
		AND	#3
		ORA	#$A0 ; 'а'      ; Получаем случайное направление и
					; устанавливаем	рабочий	танк
		STA	Tank_Status,X
		RTS
; ───────────────────────────────────────────────────────────────────────────

loc_DE8E:				; CODE XREF: Get_RandomDirection+10j
		LDA	Tank_Status
		BEQ	loc_DE9B
		TXA
		AND	#1
		BEQ	loc_DEA0
		LDA	Tank_Status+1
		BEQ	loc_DEA0

loc_DE9B:				; CODE XREF: Get_RandomDirection+1Ej
		LDA	#$C0 ; '└'
		JMP	loc_DEA2
; ───────────────────────────────────────────────────────────────────────────

loc_DEA0:				; CODE XREF: Get_RandomDirection+23j
					; Get_RandomDirection+27j
		LDA	#$D0 ; '╨'

loc_DEA2:				; CODE XREF: Get_RandomDirection+Aj
					; Get_RandomDirection+2Bj
		JSR	Rise_TankStatus_Bit ; Tank_Status OR А
		RTS
; End of function Get_RandomDirection


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Обрабатывает статусы всех 8-ми танков

TanksStatus_Handle:			; CODE XREF: ROM:C0F9p	ROM:C209p
					; ROM:C244p BonusLevel_ButtonCheck+12p
					; Title_Screen_Loop:+p
		LDA	#0
		STA	Counter

-:					; CODE XREF: TanksStatus_Handle+Fj
		LDX	Counter
		JSR	SingleTankStatus_Handle	; Обрабатывает статус одного танка
		INC	Counter
		LDA	Counter
		CMP	#8		; Всего	на экране может	быть 8 танков
		BNE	-
		RTS
; End of function TanksStatus_Handle


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Обрабатывает статус одного танка

SingleTankStatus_Handle:		; CODE XREF: TanksStatus_Handle+6p
		LDA	Tank_Status,X
		LSR	A
		LSR	A
		LSR	A		; Убираем три младших бита (направление	движения танка)
		AND	#$FE ; '■'      ;  и обнуляем четвертый, чтобы выровнять на 2
					; для дальшейшей адресации в таблице указателей	команд.
					; Таким	образом	4 оставшихся используемых бита статусного байта
					; дают нам 16 возможных	команд
		TAY
		LDA	TankDraw_JumpTable,Y
		STA	LowPtr_Byte
		LDA	TankDraw_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; End of function SingleTankStatus_Handle

; ───────────────────────────────────────────────────────────────────────────

Draw_Small_Explode2:			; DATA XREF: ROM:E4C2o	ROM:E4C4o
					; ROM:E4C6o
		LDA	#0		; Сбрасывает в Spr_Buffer 16х16	спрайт взрыва
		STA	Spr_Attrib
		LDA	Tank_Status,X
		PHA
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		PLA
		JSR	Draw_Bullet_Ricochet ; Сбрасывает в спрайтовый буффер 16х16 спрайт рикошета
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Сбрасывает в спрайтовый буффер 16х16 спрайт рикошета

Draw_Bullet_Ricochet:			; CODE XREF: ROM:DEDAp	ROM:E11Ep
		LSR	A
;В А = Bullet_Status + $40
		LSR	A
		LSR	A
		LSR	A
		SEC
		SBC	#7
		EOR	#$FF
		CLC
		ADC	#1
		ASL	A
		ASL	A		; Получаем смещение на нужный тайл рикошета

Draw_Ricochet:				; CODE XREF: ROM:DF2Bp	ROM:DF3Ep
		CLC			; Непосредственно рисует взрыв 16х16
		ADC	#$F1 ; 'ё'      ; Начало графики рикошета
		STA	Spr_TileIndex
		LDA	#3
		STA	TSA_Pal
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)
		RTS
; End of function Draw_Bullet_Ricochet

; ───────────────────────────────────────────────────────────────────────────

Draw_Kill_Points:			; DATA XREF: ROM:E4BAo
		LDA	#0		; Рисует очки на месте взрыва врага
		STA	Spr_Attrib
		LDA	Tank_Type,X
		BEQ	Draw_PlayerKill	; За убийство игрока, очки не рисуют
		LDA	Tank_Type,X
		LSR	A
		LSR	A
		LSR	A
		AND	#$FC ; '№'
		SEC
		SBC	#$10
		CLC			; Определяем количество	очков в
					; зависимости от типа убитого врага
		ADC	#$B9 ; '╣'      ; Начало графики очков
		STA	Spr_TileIndex
		LDA	#3
		STA	TSA_Pal
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)
		JMP	Draw_Kill_Points_Skip
; ───────────────────────────────────────────────────────────────────────────

Draw_PlayerKill:			; CODE XREF: ROM:DF03j
		LDA	Tank_Y,X
		TAY
		LDA	Tank_X,X
		TAX
		LDA	#0
		JSR	Draw_Ricochet	; Рисуем самый первый тип взрыва

Draw_Kill_Points_Skip:			; CODE XREF: ROM:DF20j
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		RTS
; ───────────────────────────────────────────────────────────────────────────

Draw_Small_Explode1:			; DATA XREF: ROM:E4BCo
		LDA	#0		; Взрыв	16х16
		STA	Spr_Attrib
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		LDA	#8
		JSR	Draw_Ricochet	; Непосредственно рисует взрыв 16х16
		LDA	#$20 ; ' '
		STA	Spr_Attrib	; Танк за фоном	(случай, когда спрайт пересекается с лесом)
		RTS
; ───────────────────────────────────────────────────────────────────────────

Draw_Big_Explode:			; DATA XREF: ROM:E4BEo	ROM:E4C0o
		LDA	#3		; Сбрасывает в Spr_Buffer большой взрыв
		STA	TSA_Pal
		LDA	#0
		STA	Spr_Attrib
		JSR	Set_SprIndex
		TXA
		SEC
		SBC	#8
		TAX
		TYA
		SEC
		SBC	#8
		TAY
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)
		LDA	#1
		JSR	Set_SprIndex
		TXA
		CLC
		ADC	#8
		TAX
		TYA
		SEC
		SBC	#8
		TAY
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)
		LDA	#2
		JSR	Set_SprIndex
		TXA
		SEC
		SBC	#8
		TAX
		TYA
		CLC
		ADC	#8
		TAY
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)
		LDA	#3
		JSR	Set_SprIndex
		TXA
		CLC
		ADC	#8
		TAX
		TYA
		CLC
		ADC	#8
		TAY
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Set_SprIndex:				; CODE XREF: ROM:DF4Ep	ROM:DF60p
					; ROM:DF72p ROM:DF84p
		LDX	Counter
		ASL	A
		ASL	A
		CLC
		ADC	#$D1 ; '╤'
		STA	Temp
		LDA	Tank_Status,X
		AND	#$F0 ; 'Ё'
		SEC
		SBC	#$30 ; '0'
		EOR	#$10
		CLC
		ADC	Temp
		STA	Spr_TileIndex
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		RTS
; End of function Set_SprIndex

; ───────────────────────────────────────────────────────────────────────────

OperatingTank:				; DATA XREF: ROM:E4C8o	ROM:E4CAo
					; ROM:E4CCo ROM:E4CEo	ROM:E4D0o
					; ROM:E4D2o
		CPX	#2		; Непосредственно устанавливает	в Spr_Tile_Index нужный	танк
		BCC	OperTank_Player
		LDA	Tank_Type,X	; Танк вражеский
		AND	#4		; Выделяем флаг	бонуса
		BEQ	OperTank_NotBonus
		LDA	Frame_Counter
		LSR	A
		LSR	A
		LSR	A
		AND	#1
		CLC
		ADC	#2
		JMP	OperTank_Draw	; Обеспечивает смену палитры для бонусного танка
; ───────────────────────────────────────────────────────────────────────────

OperTank_NotBonus:			; CODE XREF: ROM:DFBEj
		LDA	Frame_Counter
		ASL	A
		ASL	A
		CLC
		ADC	Tank_Type,X
		AND	#7
		TAY			; Вычисляет палитру для	текущего танка
		LDA	TankType_Pal,Y	; 8 типов танков используют соответствующие спрайтовые палитры
		JMP	OperTank_Draw
; ───────────────────────────────────────────────────────────────────────────

OperTank_Player:			; CODE XREF: ROM:DFB8j
		LDA	Player_Blink_Timer,X ; Таймер мигания friendly fire
		BEQ	OperTank_Skip
		LDA	Frame_Counter
		AND	#8		; Мигание 4 раза в секунду
		BEQ	OperTank_Skip
		RTS
; ───────────────────────────────────────────────────────────────────────────

OperTank_Skip:				; CODE XREF: ROM:DFDFj	ROM:DFE5j
		TXA

OperTank_Draw:				; CODE XREF: ROM:DFCAj	ROM:DFDAj
		STA	TSA_Pal
		LDA	Tank_Status,X
		AND	#3
		PHA
		LDA	Tank_Type,X
		AND	#$F0 ; 'Ё'
		CLC
		ADC	Track_Pos,X
		STA	Spr_TileIndex
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		PLA
		JSR	Spr_TileIndex_Add ; Spr_TileIndex + (A * 8)
		RTS
; ───────────────────────────────────────────────────────────────────────────
TankType_Pal:	.BYTE 2, 0, 0, 1, 2, 1,	2, 2 ; DATA XREF: ROM:DFD7r
					; 8 типов танков используют соответствующие спрайтовые палитры
; ───────────────────────────────────────────────────────────────────────────

Respawn:				; DATA XREF: ROM:E4D4o	ROM:E4D6o
		LDA	Tank_Status,X
		AND	#$F
		SEC
		SBC	#7
		BPL	loc_E019
		EOR	#$FF
		CLC
		ADC	#1

loc_E019:				; CODE XREF: ROM:E012j
		ASL	A
		AND	#$FC ; '№'
		CLC
		ADC	#$A1 ; 'б'      ; C $A0 в Pattern Table начинается графика респауна
		STA	Spr_TileIndex
		LDA	#3
		STA	TSA_Pal		; Респаун будет	на 03 палитре
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Обрабатывает статусы всех пуль

AllBulletsStatus_Handle:		; CODE XREF: Battle_Loop+Cp
		LDA	#9
		STA	Counter		; Обрабатываем 10 пуль (8 + 2дополнительных)

-:					; CODE XREF: AllBulletsStatus_Handle+Bj
		LDX	Counter
		JSR	BulletStatus_Handle ; Изменяет статусы пули под	её состояние
		DEC	Counter
		BPL	-
		RTS
; End of function AllBulletsStatus_Handle


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Изменяет статусы пули	под её состояние

BulletStatus_Handle:			; CODE XREF: AllBulletsStatus_Handle+6p
		LDA	Bullet_Status,X
		LSR	A
		LSR	A
		LSR	A
		AND	#$FE ; '■'      ; убираем три младших бита и обнуляем четвертый
		TAY
		LDA	Bullet_Status_JumpTable,Y
		STA	LowPtr_Byte
		LDA	Bullet_Status_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; End of function BulletStatus_Handle

; ───────────────────────────────────────────────────────────────────────────

Bullet_Move:				; DATA XREF: ROM:E4E0o
		LDA	Bullet_Status,X	; Двигает пулю в соответствии с	Bullet_Status
		AND	#3		; Выделяем направление
		TAY
		JSR	Change_BulletCoord ; Изменяет координату пули в	соответствии с направлением
		LDA	Bullet_Property,X ; Скорость и бронебойность
		AND	#1
		BEQ	End_Bullet_Move	; Если выставлен флаг, меняем координату два раза
		JSR	Change_BulletCoord ; Изменяет координату пули в	соответствии с направлением

End_Bullet_Move:			; CODE XREF: ROM:E05Dj
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Изменяет координату пули в соответствии с направлением

Change_BulletCoord:			; CODE XREF: ROM:E056p	ROM:E05Fp
		LDA	Bullet_Coord_X_Increment_1,Y
;в Y номер направления
		ASL	A
		CLC
		ADC	Bullet_X,X
		STA	Bullet_X,X
		LDA	Bullet_Coord_Y_Increment_1,Y
		ASL	A
		CLC
		ADC	Bullet_Y,X
		STA	Bullet_Y,X
		RTS
; End of function Change_BulletCoord

; ───────────────────────────────────────────────────────────────────────────

Make_Ricochet:				; DATA XREF: ROM:E4DAo	ROM:E4DCo
					; ROM:E4DEo
		DEC	Bullet_Status,X	; Меняет статус	пули под анимацию рикошета
		LDA	Bullet_Status,X	; Уменьшаем счетчик фреймов одного кадра
		AND	#$F
		BNE	End_Animate_Ricochet ; Если текущий кадр еще не	надо обновлять,	выходим
		LDA	Bullet_Status,X
		AND	#$F0 ; 'Ё'
		SEC
		SBC	#$10		; Переходим к следующему кадру рикошета
		BEQ	Skip_Animate_Ricochet
		ORA	#3		; 3 фрейма будет держаться новый кадр

Skip_Animate_Ricochet:			; CODE XREF: ROM:E085j
		STA	Bullet_Status,X

End_Animate_Ricochet:			; CODE XREF: ROM:E07Cj
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Выпускает пулю (меняет её статус и свойства)

Make_Shot:				; CODE XREF: Make_Player_Shot:+p
					; Make_Enemy_Shot+16p
		LDA	Bullet_Status,X
		BNE	End_Make_Shot	; Если пуля уже	выпущена, выходим
		CPX	#2
		BCS	+		; Выстрелы врагов не звучат
		LDA	#1
		STA	Snd_Shoot

+:					; CODE XREF: Make_Shot+6j
		LDA	Tank_Status,X
		AND	#3
		TAY
		ORA	#$40 ; '@'
		STA	Bullet_Status,X	; Выставляем в статусе пули направление
					; танка	и статус полета
		LDA	Bullet_Coord_X_Increment_1,Y
		ASL	A
		ASL	A
		ASL	A
		CLC
		ADC	Tank_X,X
		STA	Bullet_X,X
		LDA	Bullet_Coord_Y_Increment_1,Y
		ASL	A
		ASL	A
		ASL	A
		CLC
		ADC	Tank_Y,X
		STA	Bullet_Y,X	; Пуля рисуется	вне танка
		LDA	#0
		STA	Bullet_Property,X ; Скорость и бронебойность
		LDA	Tank_Type,X
		AND	#$F0 ; 'Ё'
		BEQ	End_Make_Shot	; Если танк простой, выходим сразу
		

		

		CMP	#$C0 ; '└'
		BEQ	QuickBullet_End_Make_Shot ; 6-й	тип танка (враг) быстро	стреляет
		CMP	#$60 ; '`'
		BEQ	++
		AND	#$80 ; 'А'      ; Если танк игрока бонусный,
					; у него быстрые пули
		BNE	End_Make_Shot

QuickBullet_End_Make_Shot:		; CODE XREF: Make_Shot+38j
		LDA	#1
		STA	Bullet_Property,X ; Скорость и бронебойность
		RTS
; ───────────────────────────────────────────────────────────────────────────

++:					; CODE XREF: Make_Shot+3Cj
		LDA	#3
		STA	Bullet_Property,X ; Если игрок стал танком последнего типа,
					; у него быстрые бронебойные пули

End_Make_Shot:				; CODE XREF: Make_Shot+2j
					; Make_Shot+34j Make_Shot+40j
		RTS
; End of function Make_Shot


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует все пули

Draw_All_BulletGFX:			; CODE XREF: ROM:C206p	ROM:C247p
					; BonusLevel_ButtonCheck+15p
		LDA	#9
		STA	Counter		; 10 пуль

-:					; CODE XREF: Draw_All_BulletGFX+Bj
		LDX	Counter
		JSR	Draw_BulletGFX	; Рисует пулю в	зависимости от статуса
		DEC	Counter
		BPL	-
		RTS
; End of function Draw_All_BulletGFX


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует пулю в	зависимости от статуса

Draw_BulletGFX:				; CODE XREF: Draw_All_BulletGFX+6p
		LDA	Bullet_Status,X
		LSR	A
		LSR	A
		LSR	A
		AND	#$FE ; '■'
		TAY
		LDA	BulletGFX_JumpTable,Y
		STA	LowPtr_Byte
		LDA	BulletGFX_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; End of function Draw_BulletGFX

; ───────────────────────────────────────────────────────────────────────────

Draw_Bullet:				; DATA XREF: ROM:E4EAo
		LDA	Bullet_Status,X	; Сбрасывает в буффер спрайт пули
		AND	#3
		PHA			; Выделяем направление
		LDY	Bullet_Y,X
		LDA	Bullet_X,X
		TAX
		LDA	#2
		STA	TSA_Pal
		LDA	#$B1 ; '▒'      ; Начало графики пули
		STA	Spr_TileIndex
		PLA
		JSR	Indexed_SaveSpr	; Сбрасывает в SprBuffer спрайт	8х16 со	смещением в А
		RTS
; ───────────────────────────────────────────────────────────────────────────

Update_Ricochet:			; DATA XREF: ROM:E4E4o	ROM:E4E6o
					; ROM:E4E8o
		LDA	Bullet_Status,X	; Рисует рикошет в нужном месте
		PHA
		LDY	Bullet_Y,X
		LDA	Bullet_X,X
		TAX
		PLA
		CLC
		ADC	#$40 ; '@'
		JSR	Draw_Bullet_Ricochet ; Сбрасывает в спрайтовый буффер 16х16 спрайт рикошета
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Делает выстрел игрока, если нажата кнопка

Make_Player_Shot:			; CODE XREF: Battle_Loop+15p
		LDA	#1
;Учитывает свойство бонусного танка
;стрелять двумя	пулями подряд
		STA	Counter		; Обрабатываем только игроков

-:					; CODE XREF: Make_Player_Shot+3Dj
		LDX	Counter
		LDA	Tank_Status,X
		BPL	Next_Jump_Make_Shot ; Если танк	взорван, не обрабатываем его
		CMP	#$E0 ; 'р'
		BCS	Next_Jump_Make_Shot ; Если танк	респаунится, не	обрабатываем его
		LDA	Joypad1_Differ,X
		AND	#11b
		BEQ	Next_Jump_Make_Shot ; Если не нажата кнопка огня, не обрабатываем игрока
		LDA	Tank_Type,X
		AND	#$C0 ; '└'
		CMP	#$40 ; '@'
		BNE	+		; Если танк игрока не второй бонусный,
					; делаем простой выстрел
		LDA	Bullet_Status,X
		BEQ	+		; Если пули на экране нет,
					; делаем простой выстрел
		LDA	Bullet_Status+8,X
		BNE	Next_Jump_Make_Shot ; Если дополнительная пуля уже выпущена,
					; еще одну не выпускаем
		LDA	Bullet_Status,X
		STA	Bullet_Status+8,X
		LDA	Bullet_X,X
		STA	Bullet_X+8,X
		LDA	Bullet_Y,X
		STA	Bullet_Y+8,X
		LDA	Bullet_Property,X ; Скорость и бронебойность
		STA	Bullet_Property+8,X ; Копируем все свойства пули в
					; ячейку для дополнительной пули
		LDA	#0
		STA	Bullet_Status,X

+:					; CODE XREF: Make_Player_Shot+1Aj
					; Make_Player_Shot+1Ej
		JSR	Make_Shot	; Выпускает пулю (меняет её статус и свойства)

Next_Jump_Make_Shot:			; CODE XREF: Make_Player_Shot+8j
					; Make_Player_Shot+Cj
					; Make_Player_Shot+12j
					; Make_Player_Shot+22j
		DEC	Counter
		BPL	-
		RTS
; End of function Make_Player_Shot


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Производит выстрел, используя	случайные числа

Make_Enemy_Shot:			; CODE XREF: Battle_Loop+18p
		LDA	EnemyFreeze_Timer
		BNE	End_Make_Enemy_Shot
		LDX	#7		; Начинаем с первого вражеского	танка

loc_E169:				; CODE XREF: Make_Enemy_Shot+1Cj
		LDA	Tank_Status,X
		BPL	Next_Make_Enemy_Shot
		CMP	#$E0 ; 'р'      ; Если танк взорван или респаунится,
					; не обрабатываем его
		BCS	Next_Make_Enemy_Shot
		JSR	Get_Random_A	; ГПСЧ,	в А случайное число
		AND	#$1F
		BNE	Next_Make_Enemy_Shot
		JSR	Make_Shot	; Выпускает пулю (меняет её статус и свойства)

Next_Make_Enemy_Shot:			; CODE XREF: Make_Enemy_Shot+9j
					; Make_Enemy_Shot+Dj
					; Make_Enemy_Shot+14j
		DEX
		CPX	#1		; Игроков не обрабатываем
		BNE	loc_E169

End_Make_Enemy_Shot:			; CODE XREF: Make_Enemy_Shot+3j
		RTS
; End of function Make_Enemy_Shot


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Обрабатывает игрока, если тот	на льду

Ice_Detect:				; CODE XREF: Battle_Loopp
		LDA	#7
		STA	Counter		; Будет	обработано 8 танков

-:					; CODE XREF: Ice_Detect+6Fj
		LDX	Counter
		LDA	Tank_Status,X	; Если танк взорван, не	обрабатываем его
		BPL	Next_Tank
		CMP	#$E0 ; 'р'
		BCS	Next_Tank	; Если танк зарождается, не обрабатываем его
		LDA	Tank_Y,X
		SEC
		SBC	#8
		TAY
		LDA	Tank_X,X
		SEC
		SBC	#8
		TAX
		JSR	GetCoord_InTiles ; В Х и Y на выходе координаты	в тайлах
		LDX	Counter
		LDA	LowPtr_Byte
		STA	NTAddr_Coord_Lo,X
		LDA	HighPtr_Byte
		AND	#3
		STA	NTAddr_Coord_Hi,X
		LDY	#$21 ; '!'
		CPX	#2
		BCS	++		; Если это враг, ледовые свойства не обрабатываем
		LDA	(LowPtr_Byte),Y
		CMP	#$21 ; '!'      ; Проверка на лёд под танком (чтение из NT_Buffer)
		BNE	+
		LDA	#$80 ; 'А'
		ORA	Player_Ice_Status,X
		STA	Player_Ice_Status,X ; Выставляем флаг льда
		JMP	++
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Ice_Detect+33j
		LDA	Player_Ice_Status,X
		AND	#$7F ; ''
		STA	Player_Ice_Status,X ; Убираем флаг льда

++:					; CODE XREF: Ice_Detect+2Dj
					; Ice_Detect+3Dj
		JSR	Rise_Nt_HighBit	; Выcтавляет старший бит у индекса тайла в NT_Buffer
		LDA	Tank_X,X
		AND	#7
		BNE	loc_E1DD
		LDA	NTAddr_Coord_Hi,X
		ORA	#$80 ; 'А'      ; Каждый тайл переключается старший бит
		STA	NTAddr_Coord_Hi,X
		LDY	#$20 ; ' '
		JSR	Rise_Nt_HighBit	; Выcтавляет старший бит у индекса тайла в NT_Buffer

loc_E1DD:				; CODE XREF: Ice_Detect+4Fj
		LDA	Tank_Y,X
		AND	#7
		BNE	Next_Tank
		LDA	NTAddr_Coord_Hi,X
		ORA	#$40 ; '@'
		STA	NTAddr_Coord_Hi,X
		LDY	#1
		JSR	Rise_Nt_HighBit	; Выcтавляет старший бит у индекса тайла в NT_Buffer

Next_Tank:				; CODE XREF: Ice_Detect+8j
					; Ice_Detect+Cj Ice_Detect+60j
		DEC	Counter
		BPL	-
		RTS
; End of function Ice_Detect


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Выcтавляет старший бит у индекса тайла в NT_Buffer

Rise_Nt_HighBit:			; CODE XREF: Ice_Detect:++p
					; Ice_Detect+59p Ice_Detect+6Ap
		LDA	(LowPtr_Byte),Y
		ORA	#$80 ; 'А'
		STA	(LowPtr_Byte),Y
		RTS
; End of function Rise_Nt_HighBit


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


HideHiBit_Under_Tank:			; CODE XREF: Battle_Loop+9p
		LDA	#7
		STA	Counter		; Обрабатывается 8 танков

-:					; CODE XREF: HideHiBit_Under_Tank+37j
		LDX	Counter
		LDA	Tank_Status,X
		BPL	++
		CMP	#$E0 ; 'р'
		BCS	++		; Если танк взорван или	респаунится,
					; переходим к следующему
		LDA	NTAddr_Coord_Lo,X
		STA	LowPtr_Byte
		LDA	NTAddr_Coord_Hi,X
		AND	#3
		ORA	#4
		STA	HighPtr_Byte
		LDY	#$21 ; '!'
		JSR	HideHiBit_InBuffer ; Убирает старший бит из (LowPtrByte)
		LDA	NTAddr_Coord_Hi,X
		AND	#$80 ; 'А'
		BEQ	+
		LDY	#$20 ; ' '
		JSR	HideHiBit_InBuffer ; Убирает старший бит из (LowPtrByte)

+:					; CODE XREF: HideHiBit_Under_Tank+23j
		LDA	NTAddr_Coord_Hi,X
		AND	#$40 ; '@'
		BEQ	++
		LDY	#1
		JSR	HideHiBit_InBuffer ; Убирает старший бит из (LowPtrByte)

++:					; CODE XREF: HideHiBit_Under_Tank+8j
					; HideHiBit_Under_Tank+Cj
					; HideHiBit_Under_Tank+2Ej
		DEC	Counter
		BPL	-
		RTS
; End of function HideHiBit_Under_Tank


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Убирает старший бит из (LowPtrByte)

HideHiBit_InBuffer:			; CODE XREF: HideHiBit_Under_Tank+1Cp
					; HideHiBit_Under_Tank+27p
					; HideHiBit_Under_Tank+32p
		LDA	(LowPtr_Byte),Y
		AND	#$7F ; ''
		STA	(LowPtr_Byte),Y
		RTS
; End of function HideHiBit_InBuffer


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует или пустоту или бонус или очки	за бонус

Bonus_Draw:				; CODE XREF: ROM:Skip_Battle_Loopp
					; ROM:C241p BonusLevel_ButtonCheck+Fp
		LDA	Bonus_X
		BEQ	End_Bonus_Draw	; Если бонуса нет, выходим
					;
					; В процедуре: если бонус не взят (показан
					; бонус) счетчик времени обнулён, если
					; бонус	взят (показываются очки), счетчик
					; снижается с $32 до нуля
		LDA	BonusPts_TimeCounter
		BEQ	Bonus_NotTaken	; бонус	пока не	взят
		DEC	BonusPts_TimeCounter ; Бонус взят и появились
					; очки за него
		BNE	NotZeroCounter
		LDA	#0
		STA	Bonus_X		; Убираем очки за
					; бонус	с экрана
		JMP	End_Bonus_Draw
; ───────────────────────────────────────────────────────────────────────────

NotZeroCounter:				; CODE XREF: Bonus_Draw+Aj
		LDA	#2
		STA	TSA_Pal		; Очки используют палитру спрайтов 2
		LDA	#$3B ; ';'      ; Тайлы очков за бонус
					; (500)	равен $3A
		STA	Spr_TileIndex
		JMP	Draw_Bonus
; ───────────────────────────────────────────────────────────────────────────

Bonus_NotTaken:				; CODE XREF: Bonus_Draw+6j
		LDA	Frame_Counter	; бонус	пока не	взят
		AND	#8
		BEQ	End_Bonus_Draw
		LDA	#2
		STA	TSA_Pal		; Бонус	использует палитру спрайтов 2
		LDA	Bonus_Number	; Определяет тип бонуса
		ASL	A
		ASL	A		; Умножаем на 4	(бонус из 4 тайлов)
		CLC
		ADC	#$81 ; 'Б'      ; первый индекс тайла бонуса равен $80
		STA	Spr_TileIndex

Draw_Bonus:				; CODE XREF: Bonus_Draw+1Bj
		LDX	Bonus_X
		LDY	Bonus_Y
		LDA	#0
		STA	Spr_Attrib
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)
		LDA	#$20 ; ' '
		STA	Spr_Attrib

End_Bonus_Draw:				; CODE XREF: Bonus_Draw+2j
					; Bonus_Draw+10j Bonus_Draw+22j
		RTS
; End of function Bonus_Draw


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует силовое поле, если нужно

Invisible_Timer_Handle:			; CODE XREF: Battle_Loop+12p
		LDA	#1
		STA	Counter		; Обрабатываем только игроков

-:					; CODE XREF: Invisible_Timer_Handle+2Aj
		LDX	Counter
		LDA	Invisible_Timer,X ; Силовое поле вокруг	игрока после рождения
		BEQ	Next_Invisible_Timer_Handle ; Если у танка нет поля, не	обрабатываем
		LDA	Frame_Counter
		AND	#63
		BNE	+		; Каждую секунду уменьшаем таймер
		DEC	Invisible_Timer,X ; Силовое поле вокруг	игрока после рождения

+:					; CODE XREF: Invisible_Timer_Handle+Ej
		LDA	#2
		STA	TSA_Pal
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		LDA	Frame_Counter
		AND	#2
		ASL	A		; Каждые 2 фрейма меняем кадр поля
					; (преобразует номер фрейма в первый индекс
					; 16х16	тайла силового поля)
		CLC
		ADC	#$29 ; ')'      ; Начальный индекс тайла графики силового поля
		STA	Spr_TileIndex
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)

Next_Invisible_Timer_Handle:		; CODE XREF: Invisible_Timer_Handle+8j
		DEC	Counter
		BPL	-
		RTS
; End of function Invisible_Timer_Handle


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Обрабатывает статус и	броню штаба

HQ_Handle:				; CODE XREF: Battle_Loop+Fp
		LDA	HQArmour_Timer	; Таймер брони вокруг штаба
		BEQ	HQ_Explode_Handle
		LDA	Frame_Counter
		AND	#$F
		BNE	HQ_Explode_Handle ; Обрабатываем 4 раза	в секунду
		LDA	Frame_Counter
		AND	#63
		BNE	Skip_DecHQTimer	; Каждую секунду уменьшаем
					; таймер брони штаба
		DEC	HQArmour_Timer	; Таймер брони вокруг штаба
		BEQ	Normal_HQ_Handle ; Если	таймер кончился, рисуем	простой	штаб

Skip_DecHQTimer:			; CODE XREF: HQ_Handle+Ej
		LDA	HQArmour_Timer	; Таймер брони вокруг штаба
		CMP	#4
		BCS	HQ_Explode_Handle ; За 4 секунды до истечения таймера брони штаба,
					; броня	начинает мигать
		LDA	Frame_Counter
		AND	#$10		; Мигание с частотой в 16 фреймов
					; (4 раза в секунду)
		BEQ	Normal_HQ_Handle
		JSR	Draw_ArmourHQ	; Рисует штаб с	броней
		JMP	HQ_Explode_Handle
; ───────────────────────────────────────────────────────────────────────────

Normal_HQ_Handle:			; CODE XREF: HQ_Handle+12j
					; HQ_Handle+1Ej
		JSR	DraW_Normal_HQ	; Рисует штаб с	кирпичами

HQ_Explode_Handle:			; CODE XREF: HQ_Handle+2j HQ_Handle+8j
					; HQ_Handle+18j HQ_Handle+23j
		LDA	HQ_Status	; 80=штаб цел, если ноль то уничтожен
		BEQ	End_HQ_Handle	; Если штаба уже нет, не обрабатываем его взрыв
		BMI	End_HQ_Handle	; Если штаб цел, не обрабатываем его взрыв
		LDA	#3
		STA	TSA_Pal
		DEC	HQ_Status	; 80=штаб цел, если ноль то уничтожен
		LDA	HQ_Status	; 80=штаб цел, если ноль то уничтожен
		LSR	A
		LSR	A		; 4 фрейма держится каждый кадр	анимации взрыва
		SEC
		SBC	#5
		BPL	+
		EOR	#$FF
		CLC
		ADC	#1

+:					; CODE XREF: HQ_Handle+3Cj
		SEC
		SBC	#5
		BPL	++		; Указатели двухбайтовые
		EOR	#$FF
		CLC
		ADC	#1		; Кадры	анимации увеличиваются до 5, а затем снижаются

++:					; CODE XREF: HQ_Handle+46j
		ASL	A		; Указатели двухбайтовые
		TAY
		LDA	HQExplode_JumpTable,Y
		STA	LowPtr_Byte
		LDA	HQExplode_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; ───────────────────────────────────────────────────────────────────────────

End_HQ_Handle:				; CODE XREF: HQ_Handle+2Bj
					; HQ_Handle+2Dj
		RTS
; End of function HQ_Handle

; ───────────────────────────────────────────────────────────────────────────
;Таблица выводов спрайтов взрыва штаба (всего пять кадров анимации)
HQExplode_JumpTable:.WORD End_Ice_Move	; DATA XREF: HQ_Handle+4Fr
					; HQ_Handle+54r
					; возвращаемся по RTS
		.WORD FirstExplode_Pic	; Первый кадр 16х16 взрыва
		.WORD SecondExplode_Pic	; Второй кадр 16х16 взрыва
		.WORD ThirdExplode_Pic	; Третий кадр 16х16 взрыва
		.WORD FourthExplode_Pic	; Взрыв	32х32 поменьше
		.WORD FifthExplode_Pic	; Самый	большой	32х32 взрыв
; ───────────────────────────────────────────────────────────────────────────

FirstExplode_Pic:			; DATA XREF: ROM:E308o
		LDA	#$F1 ; 'ё'      ; Первый кадр 16х16 взрыва
		JMP	Draw_HQSmallExplode
; ───────────────────────────────────────────────────────────────────────────

SecondExplode_Pic:			; DATA XREF: ROM:E30Ao
		LDA	#$F5 ; 'ї'      ; Второй кадр 16х16 взрыва
		JMP	Draw_HQSmallExplode
; ───────────────────────────────────────────────────────────────────────────

ThirdExplode_Pic:			; DATA XREF: ROM:E30Co
		LDA	#$F9 ; '∙'      ; Третий кадр 16х16 взрыва

Draw_HQSmallExplode:			; CODE XREF: ROM:E314j	ROM:E319j
		LDX	#$78 ; 'x'
		LDY	#$D8 ; '╪'      ; Координаты места взрыва штаба
; START	OF FUNCTION CHUNK FOR Add_ExplodeSprBase

Draw_SmallExplode:			; CODE XREF: Add_ExplodeSprBase+3j
		STA	Spr_TileIndex
		JSR	Draw_WholeSpr	; Cбрасывает в спрайтовый буффер спрайт	16х16. (в Х, Y - координаты)
		RTS
; END OF FUNCTION CHUNK	FOR Add_ExplodeSprBase

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Add_ExplodeSprBase:			; CODE XREF: Draw_BigExplode+6p
					; Draw_BigExplode+Fp
					; Draw_BigExplode+18p
					; Draw_BigExplode+21p

; FUNCTION CHUNK AT E322 SIZE 00000006 BYTES

		CLC
		ADC	HQExplode_SprBase
		JMP	Draw_SmallExplode
; End of function Add_ExplodeSprBase

; ───────────────────────────────────────────────────────────────────────────

FourthExplode_Pic:			; DATA XREF: ROM:E30Eo
		LDA	#0		; Взрыв	32х32 поменьше
		STA	HQExplode_SprBase
		JSR	Draw_BigExplode	; Рисует 32х32 спрайт взрыва
		RTS
; ───────────────────────────────────────────────────────────────────────────

FifthExplode_Pic:			; DATA XREF: ROM:E310o
		LDA	#$10		; Самый	большой	32х32 взрыв
		STA	HQExplode_SprBase
		JSR	Draw_BigExplode	; Рисует 32х32 спрайт взрыва
		RTS

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Рисует 32х32 спрайт взрыва

Draw_BigExplode:			; CODE XREF: ROM:E332p	ROM:E33Ap
		LDX	#$70 ; 'p'
		LDY	#$D0 ; '╨'
		LDA	#$D1 ; '╤'
		JSR	Add_ExplodeSprBase
		LDX	#$80 ; 'А'
		LDY	#$D0 ; '╨'
		LDA	#$D5 ; '╒'
		JSR	Add_ExplodeSprBase
		LDX	#$70 ; 'p'
		LDY	#$E0 ; 'р'
		LDA	#$D9 ; '┘'
		JSR	Add_ExplodeSprBase
		LDX	#$80 ; 'А'
		LDY	#$E0 ; 'р'
		LDA	#$DD ; '▌'
		JSR	Add_ExplodeSprBase
		RTS
; End of function Draw_BigExplode


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Make_Respawn:				; CODE XREF: SetUp_LevelVARs+16p
					; SetUp_LevelVARs+1Fp
					; Respawn_Handle+19p ROM:DE11p
		LDA	#0
;Изначально танк игрока	обычный
		STA	Tank_Type,X	; x = 0..1 - рассматривается тип игрока
					;    x = 2..5 -	рассматриваются	вражеские типы
		CPX	#2
		BCS	Enemy_Operations ; Если	>= 2, то это враг
		LDA	X_Player_Respawn,X
		STA	Tank_X,X
		LDA	Y_Player_Respawn,X
		STA	Tank_Y,X
		LDA	#0		; Игрок	не должен мигать
					; во время респауна
		STA	Player_Blink_Timer,X ; Таймер мигания friendly fire
		JMP	++		; Танк будет зарождаться
; ───────────────────────────────────────────────────────────────────────────

Enemy_Operations:			; CODE XREF: Make_Respawn+6j
		INC	EnemyRespawn_PlaceIndex
		LDY	EnemyRespawn_PlaceIndex
		CPY	#3		; 3 возможных места респауна
		BNE	+
		LDA	#0
		STA	EnemyRespawn_PlaceIndex
		TAY

+:					; CODE XREF: Make_Respawn+1Fj
		LDA	X_Enemy_Respawn,Y
		STA	Tank_X,X
		LDA	Y_Enemy_Respawn,Y
		STA	Tank_Y,X
		LDA	Enemy_Reinforce_Count ;	Количество врагов в запасе
		CMP	#3		; Бонусный танк	появится, когда	в запасе
					; останется: 17, 10 или	3 вражеских танка.
		BEQ	Make_BonusEnemy
		CMP	#10
		BEQ	Make_BonusEnemy
		CMP	#17
		BNE	++		; Танк будет зарождаться

Make_BonusEnemy:			; CODE XREF: Make_Respawn+34j
					; Make_Respawn+38j
		LDA	#4
		STA	Tank_Type,X	; Делаем врага бонусным
					; (ORA $80 будет потом)

++:					; CODE XREF: Make_Respawn+16j
					; Make_Respawn+3Cj
		LDA	#$F0		; Танк будет зарождаться
		STA	Tank_Status,X
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		LDA	#$F
		JSR	Draw_TSABlock	; Отрисовываем под танком будет	пустое место. На
					; случай, если уровень был создан из-под
					; Construction и на месте респауна игроков
					; или врагов есть какие-то блоки.
		RTS
; End of function Make_Respawn


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Загружает нужный тип нового танка

Load_New_Tank:				; CODE XREF: ROM:DE6Ep
		LDA	Respawn_Status,X
		STA	Tank_Status,X
		CPX	#2
		BCS	Load_NewEnemy	; Враг
		LDA	#3
		STA	Invisible_Timer,X ; Силовое поле вокруг	игрока после рождения
		LDA	Player_Type,X	; Вид танка игрока
		CMP	#$0
		BEQ	Start_With_One_Star
		JMP	++
; ───────────────────────────────────────────────────────────────────────────

Start_With_One_Star:
		LDA #$20
		STA	Player_Type,X
		STA	Tank_Type,X
		JMP	++
; ───────────────────────────────────────────────────────────────────────────

Load_NewEnemy:				; CODE XREF: Load_New_Tank+7j
					; Load_New_Tank+1Cj
		LDY	Enemy_TypeNumber ; Враг
		LDA	Enemy_Count,Y
		BNE	+
		INC	Enemy_TypeNumber
		JMP	Load_NewEnemy	; Если текущий тип (один из 4 на уровень) кончился,
					; начинаем респаунить следующий	тип.
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Load_New_Tank+18j
		SEC
		SBC	#1
		STA	Enemy_Count,Y
		LDA	Level_Mode
		BEQ	+++		; Если уровни пошли по 2-му кругу, набор врагов
					; всегда из 35 уровня
		LDA	#35
		JMP	++++
; ───────────────────────────────────────────────────────────────────────────

+++:					; CODE XREF: Load_New_Tank+27j
		LDA	Level_Number

++++:					; CODE XREF: Load_New_Tank+2Bj
		SEC
		SBC	#1
		ASL	A
		ASL	A		; На уровне 4 типа врагов
		CLC
		ADC	Enemy_TypeNumber
		TAY			; Вычисляем набор врагов в зависимости от номера уровня
		LDA	EnemyType_ROMArray,Y
		CMP	#$E0
		BNE	++		; Если враг последнего типа,
					; у него самая мощная броня
		ORA	#3

++:					; CODE XREF: Load_New_Tank+10j
					; Load_New_Tank+3Ej
		ORA	Tank_Type,X
		CMP	#$E7
		BNE	End_Load_New_Tank
		LDA	#$E4

End_Load_New_Tank:			; CODE XREF: Load_New_Tank+46j
		STA	Tank_Type,X

		LDA	Boss_Mode	;!Если босс, то загружаем танк в зависимости от номера уровня.
		BEQ	Skip_Load_Boss_Tank

		TXA ; проверяем, чтобы тип игрока не менялся
		CMP 	#2
		BCC	Skip_Load_Boss_Tank
		
		JSR	Get_Random_A
		AND	#7
		ASL
		ASL
		ASL
		ASL
		ASL   ;ставим тип
		ORA #3;Ставим броню
		STA	Tank_Type,X		

Skip_Load_Boss_Tank:
		LDA	#0
		STA	Track_Pos,X
		RTS
; End of function Load_New_Tank


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Уводим с экраны все пули

Hide_All_Bullets:			; CODE XREF: SetUp_LevelVARsp
		LDX	#9
		LDA	#0

-:					; CODE XREF: Hide_All_Bullets+7j
		STA	Bullet_Status,X
		DEX
		BPL	-
		RTS
; End of function Hide_All_Bullets


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Null_Status:				; CODE XREF: ROM:Skip_LoadFramep
					; SetUp_LevelVARs+3p
					; Title_Screen_Loop+4p
		LDA	#0
		LDX	#7

-:					; CODE XREF: Null_Status+Aj
		STA	Tank_Status,X
		STA	$103,X
		DEX
		BPL	-
		RTS
; End of function Null_Status


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Tank_Status OR А

Rise_TankStatus_Bit:			; CODE XREF: Ice_Move+33p ROM:DC78p
					; ROM:DD20p ROM:DD3Ep
					; Get_RandomDirection:loc_DEA2p
		STA	Temp
		LDA	Tank_Status,X
		AND	#$F
		ORA	Temp
		STA	Tank_Status,X
		RTS
; End of function Rise_TankStatus_Bit


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Load_Enemy_Count:			; CODE XREF: SetUp_LevelVARs+52p
		LDA	Level_Mode
		BEQ	+
		LDA	#35		; В бонус-уровне всегда	внутренности 35-го
		JMP	++
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Load_Enemy_Count+2j
		LDA	Level_Number

++:					; CODE XREF: Load_Enemy_Count+6j
		SEC
		SBC	#1
		ASL	A
		ASL	A		; Умножаем на 4	(количество типов врагов в уровне)
		TAY
		LDA	Enemy_Amount_ROMArray,Y
		STA	Enemy_Count
		LDA	Enemy_Amount_ROMArray+1,Y
		STA	Enemy_Count+1
		LDA	Enemy_Amount_ROMArray+2,Y
		STA	Enemy_Count+2
		LDA	Enemy_Amount_ROMArray+3,Y
		STA	Enemy_Count+3
		RTS
; End of function Load_Enemy_Count


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; $FF =	кнопки управления не нажаты

Button_To_DirectionIndex:		; CODE XREF: Move_Tank+21p
					; Move_Tank+2Fp Ice_Move+2Ap
		ASL	A
;Переводит А в число в соответствии с 3	старшими битами	(3,1,2,0,FF)
;используется для получения индекса направления	перемещения танка
;в зависимости от нажатых кнопок управления на джойстике
;Если клавиши управления не нажаты, возвращает $FF
		BCC	+
		LDA	#3		; Вправо
		RTS
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Button_To_DirectionIndex+1j
		ASL	A
		BCC	++
		LDA	#1		; Влево
		RTS
; ───────────────────────────────────────────────────────────────────────────

++:					; CODE XREF: Button_To_DirectionIndex+7j
		ASL	A
		BCC	+++
		LDA	#2		; Вниз
		RTS
; ───────────────────────────────────────────────────────────────────────────

+++:					; CODE XREF: Button_To_DirectionIndex+Dj
		ASL	A
		BCC	++++		; Клавиши направления не нажаты
		LDA	#0		; Вверх
		RTS
; ───────────────────────────────────────────────────────────────────────────

++++:					; CODE XREF: Button_To_DirectionIndex+13j
		LDA	#$FF		; Клавиши направления не нажаты
		RTS
; End of function Button_To_DirectionIndex

; ───────────────────────────────────────────────────────────────────────────
;Загружается $DCAC,$E063,$E0A2 (такой же массив	по адресу $D3D5)
Bullet_Coord_X_Increment_1:.BYTE 0, $FF, 0, 1 ;	DATA XREF: ROM:DCACr ROM:DCB4r
					; Change_BulletCoordr Make_Shot+16r
;Загружается $DC9C,$E06C,$E0AD
Bullet_Coord_Y_Increment_1:.BYTE $FF, 0, 1, 0 ;	DATA XREF: ROM:DC9Cr ROM:DCA4r
					; Change_BulletCoord+9r Make_Shot+21r
X_Enemy_Respawn:.BYTE $18, $78,	$D8	; DATA XREF: Make_Respawn:+r
;X координата соответственно левого, среднего и	правого	респауна врага
Y_Enemy_Respawn:.BYTE $18, $18,	$18	; DATA XREF: Make_Respawn+2Br
;Y координата соответственно левого, среднего и	правого	респауна врага
X_Player_Respawn:.BYTE $58, $98		; DATA XREF: Make_Respawn+8r
;X координата  респауна	соответственно первого и второго игрока
Y_Player_Respawn:.BYTE $D8, $D8		; DATA XREF: Make_Respawn+Dr
;Y координата респауна соответственно первого и	второго	игрока

Respawn_Status:	.BYTE $A0, $A0,	$A2, $A2, $A2, $A2, $A2, $A2 ; DATA XREF: Load_New_Tankr
;Статусы игроков и врагов при респауне (игроки начинают	дулом вверх, враги - вниз)

AI_Status:	.BYTE $A0,$A0,$A0,$A1,$A0,$A3,$A2,$A2,$A2
					; DATA XREF: Load_AI_Status:End_Load_AIStatusr
		.BYTE $A1,$A0,$A3,$A1,$A0,$A3,$A1,$A2,$A3

TankStatus_JumpTable:.WORD End_Ice_Move	; DATA XREF: Status_Core+8r
					; Status_Core+Dr
					; возвращаемся по RTS
		.WORD Explode_Handle	; Обрабатывает взрыв танка (уменьшает число жизней, GameOver...)
		.WORD Explode_Handle	; Обрабатывает взрыв танка (уменьшает число жизней, GameOver...)
		.WORD Explode_Handle	; Обрабатывает взрыв танка (уменьшает число жизней, GameOver...)
		.WORD Explode_Handle	; Обрабатывает взрыв танка (уменьшает число жизней, GameOver...)
		.WORD Explode_Handle	; Обрабатывает взрыв танка (уменьшает число жизней, GameOver...)
		.WORD Explode_Handle	; Обрабатывает взрыв танка (уменьшает число жизней, GameOver...)
		.WORD Explode_Handle	; Обрабатывает взрыв танка (уменьшает число жизней, GameOver...)
		.WORD Misc_Status_Handle ; Обрабатывает	статусы	льда, позицию трека и т.п.
		.WORD Get_RandomStatus	; В основном, получает случайный статус
		.WORD Check_TileReach	; Проверяет у врага, достиг ли он конца	тайла
		.WORD Aim_HQ		; Устанавливает	в качестве целевой координаты штаб
		.WORD Aim_ScndPlayer	; Устанавливает	в качестве цели	врага первого игрока
		.WORD Aim_FirstPlayer	; Устанавливает	в качестве цели	врага второго игрока
		.WORD Load_Tank		; Загружает нужный тип нового танка, если нужно
		.WORD Set_Respawn	; Устанавливает	в статусе Респаун

TankDraw_JumpTable:.WORD End_Ice_Move	; DATA XREF: SingleTankStatus_Handle+8r
					; SingleTankStatus_Handle+Dr
					; возвращаемся по RTS
		.WORD Draw_Kill_Points	; Рисует очки на месте взрыва врага
		.WORD Draw_Small_Explode1 ; Взрыв 16х16
		.WORD Draw_Big_Explode	; Сбрасывает в Spr_Buffer большой взрыв
		.WORD Draw_Big_Explode	; Сбрасывает в Spr_Buffer большой взрыв
		.WORD Draw_Small_Explode2 ; Сбрасывает в Spr_Buffer 16х16 спрайт взрыва
		.WORD Draw_Small_Explode2 ; Сбрасывает в Spr_Buffer 16х16 спрайт взрыва
		.WORD Draw_Small_Explode2 ; Сбрасывает в Spr_Buffer 16х16 спрайт взрыва
		.WORD OperatingTank	; Непосредственно устанавливает	в Spr_Tile_Index нужный	танк
		.WORD OperatingTank	; Непосредственно устанавливает	в Spr_Tile_Index нужный	танк
		.WORD OperatingTank	; Непосредственно устанавливает	в Spr_Tile_Index нужный	танк
		.WORD OperatingTank	; Непосредственно устанавливает	в Spr_Tile_Index нужный	танк
		.WORD OperatingTank	; Непосредственно устанавливает	в Spr_Tile_Index нужный	танк
		.WORD OperatingTank	; Непосредственно устанавливает	в Spr_Tile_Index нужный	танк
		.WORD Respawn
		.WORD Respawn
Bullet_Status_JumpTable:.WORD End_Ice_Move ; DATA XREF:	BulletStatus_Handle+8r
					; BulletStatus_Handle+Dr
					; возвращаемся по RTS
		.WORD Make_Ricochet	; Меняет статус	пули под анимацию рикошета
		.WORD Make_Ricochet	; Меняет статус	пули под анимацию рикошета
		.WORD Make_Ricochet	; Будет	три кадра рикошета
		.WORD Bullet_Move	; Двигает пулю в соответствии с	Bullet_Status
BulletGFX_JumpTable:.WORD End_Ice_Move	; DATA XREF: Draw_BulletGFX+8r
					; Draw_BulletGFX+Dr
					; возвращаемся по RTS
		.WORD Update_Ricochet	; Рисует рикошет в нужном месте
		.WORD Update_Ricochet	; Рисует рикошет в нужном месте
		.WORD Update_Ricochet	; Рисует рикошет в нужном месте
		.WORD Draw_Bullet	; Сбрасывает в буффер спрайт пули
;Типы врагов (4	типа на	одном уровне и всего 8 типов) по уровням
;Формат	байта:
;Биты:
;0,1 - уровень брони
;2   - флаг бонусного танка
;3,4 - не используются
;5,6,7 - тип танка (возможно 8 типов)
;

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Обрабатывает полет пули (столкновение	и т.п.)

Bullet_Fly_Handle:			; CODE XREF: Battle_Loop+1Ep
		LDA	#9
		STA	Counter		; Обрабатываем 10 пуль

-:					; CODE XREF: Bullet_Fly_Handle+8Bj
		LDX	Counter
		LDA	Bullet_Status,X
		AND	#$F0 ; 'Ё'
		CMP	#$40 ; '@'
		BNE	Next_Bullet_Fly_Handle ; Если пуля не летит, переходим к следующей
		LDA	Bullet_Property,X ; Скорость и бронебойность
		BNE	+
		TXA
		EOR	Frame_Counter
		AND	#1		; Медленные пули обрабатываем через фрейм
		BEQ	Next_Bullet_Fly_Handle

+:					; CODE XREF: Bullet_Fly_Handle+10j
		LDA	Bullet_Status,X
		AND	#3
		TAY
		LDA	Bullet_Coord_X_Increment_2,Y
		BPL	++
		EOR	#$FF
		CLC
		ADC	#1

++:					; CODE XREF: Bullet_Fly_Handle+21j
		STA	Temp_X
		ASL	A
		ASL	A
		STA	AI_X_DifferFlag
		LDA	Bullet_Coord_Y_Increment_2,Y
		BPL	+++
		EOR	#$FF
		CLC
		ADC	#1

+++:					; CODE XREF: Bullet_Fly_Handle+31j
		STA	Temp_Y
		ASL	A
		ASL	A
		STA	AI_Y_DifferFlag
		LDY	Bullet_Y,X
		LDA	Bullet_X,X
		TAX
		JSR	GetSprCoord_InTiles ; Переводит	Spr_coord в тайлы
		BEQ	GetCoord_Bullet_Fly_Handle
		LDX	Counter
		LDA	Bullet_Y,X
		CLC
		ADC	AI_X_DifferFlag
		STA	Spr_Y
		LDA	Bullet_X,X
		CLC
		ADC	AI_Y_DifferFlag
		STA	Spr_X
		JSR	BulletToObject_Impact_Handle ; Обрабатывает столкновение пули с	объектом

GetCoord_Bullet_Fly_Handle:		; CODE XREF: Bullet_Fly_Handle+46j
		LDX	Counter
		LDA	Bullet_Y,X
		SEC
		SBC	Temp_X
		TAY
		LDA	Bullet_X,X
		SEC
		SBC	Temp_Y
		TAX
		JSR	GetSprCoord_InTiles ; Переводит	Spr_coord в тайлы
		BEQ	Next_Bullet_Fly_Handle
		LDX	Counter
		LDA	Bullet_Y,X
		SEC
		SBC	AI_X_DifferFlag
		SEC
		SBC	Temp_X
		STA	Spr_Y
		LDA	Bullet_X,X
		SEC
		SBC	AI_Y_DifferFlag
		SEC
		SBC	Temp_Y
		STA	Spr_X
		JSR	BulletToObject_Impact_Handle ; Обрабатывает столкновение пули с	объектом

Next_Bullet_Fly_Handle:			; CODE XREF: Bullet_Fly_Handle+Cj
					; Bullet_Fly_Handle+17j
					; Bullet_Fly_Handle+6Cj
		DEC	Counter
		BMI	End_Bullet_Fly_Handle
		JMP	-
; ───────────────────────────────────────────────────────────────────────────

End_Bullet_Fly_Handle:			; CODE XREF: Bullet_Fly_Handle+89j
		RTS
; End of function Bullet_Fly_Handle


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Переводит Spr_coord в	тайлы

GetSprCoord_InTiles:			; CODE XREF: Bullet_Fly_Handle+43p
					; Bullet_Fly_Handle+69p
		STX	Spr_X
		STY	Spr_Y
		JSR	GetCoord_InTiles ; В Х и Y на выходе координаты	в тайлах
; End of function GetSprCoord_InTiles


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Обрабатывает столкновение пули с объектом

BulletToObject_Impact_Handle:		; CODE XREF: Bullet_Fly_Handle+58p
					; Bullet_Fly_Handle+84p
		JSR	Temp_Coord_shl	; Преобразует Temp в зависимости от Spr_Coord
		JSR	Check_Object	; Возвращает ноль, если	нулевой	тайл
		BEQ	BulletToObject_Return0 ; Если перед пулей пустота, выходим с 0
		LDA	(LowPtr_Byte),Y
		AND	#$FC ; '№'
		CMP	#$C8 ; '╚'      ; Сравниваем с индексом тайла штаба
		BNE	+
		LDA	HQ_Status	; 80=штаб цел, если ноль то уничтожен
		BEQ	+		; Если 0, взрываем штаб
		LDA	#$27 ; '''      ; Взрываем штаб
		STA	HQ_Status	; Начальный кадр анимации взрыва
					; (7 кадров по 4 фрейма)
		LDA	#1
		STA	Sns_HQExplode
		STA	Snd_PlayerExplode
		JSR	Draw_Destroyed_HQ ; Рисует разрушенный штаб
		LDX	Counter
		LDA	#$33 ; '3'      ; Делаем рикошет на пулю
		STA	Bullet_Status,X
		JMP	BulletToObject_Return0
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: BulletToObject_Impact_Handle+Ej
					; BulletToObject_Impact_Handle+12j
		LDA	(LowPtr_Byte),Y
		CMP	#$12		; Если >$12 (вода, лес,	лёд и т.п.), пули
					; проходят насквозь (завершаем обработку)
		BCS	BulletToObject_Return0
		LDX	Counter
		LDA	#$33 ; '3'
		STA	Bullet_Status,X	; 3 кадра анимации рикошета,
					; которые держатся по 3	фрейма
		LDA	(LowPtr_Byte),Y
		CMP	#$11		; Граница экрана
		BEQ	Armored_Wall
		LDA	Bullet_Property,X ; Скорость и бронебойность
		AND	#2
		BEQ	++		; Если бронебойная, разрушаем объект
		LDA	#0
		JSR	Draw_Tile	; Рисуем вместо	кирпича
					; пустой тайл
		LDA	#1
		STA	Snd_Brick_Ricochet
		JMP	BulletToObject_Return0
; ───────────────────────────────────────────────────────────────────────────

++:					; CODE XREF: BulletToObject_Impact_Handle+42j
		LDA	(LowPtr_Byte),Y
		CMP	#$10		; Тайл брони
		BEQ	Armored_Wall
		CPX	#2		; Столкновение с кирпичной стеной
		BCS	BulletToObject_Return1 ; Звучит	только попадание игроков
		LDA	#1
		STA	Snd_Brick_Ricochet

BulletToObject_Return1:			; CODE XREF: BulletToObject_Impact_Handle+59j
		JSR	Draw_Destroyed_Brick ; Рисует правильный вырыв в кирпичной стене
		LDA	#1
		RTS
; ───────────────────────────────────────────────────────────────────────────

Armored_Wall:				; CODE XREF: BulletToObject_Impact_Handle+3Cj
					; BulletToObject_Impact_Handle+55j
		CPX	#2
		BCS	BulletToObject_Return0 ; Звучать только	рикошеты игроков
		LDA	#1
		STA	Snd_ArmorRicochetWall

BulletToObject_Return0:			; CODE XREF: BulletToObject_Impact_Handle+6j
					; BulletToObject_Impact_Handle+29j
					; BulletToObject_Impact_Handle+30j
					; BulletToObject_Impact_Handle+4Ej
					; BulletToObject_Impact_Handle+68j
		LDA	#0
		RTS
; End of function BulletToObject_Impact_Handle


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Обрабатывает столкновение пули с танком

BulletToTank_Impact_Handle:		; CODE XREF: Battle_Loop+24p
		LDA	#1
		STA	Counter		; Сначала обрабатываем только игроков
					; (враг	попадает в игрока)

-:					; CODE XREF: BulletToTank_Impact_Handle+70j
		LDX	Counter
		LDA	Tank_Status,X
		BPL	Jump_Next_Player_Tank_Impact ; Если танк взрывается,
					; переходим к следующему
		CMP	#$E0 ; 'р'
		BCC	+		; Если танк не респаунится,
					; переходим к следующему

Jump_Next_Player_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+8j
		JMP	Next_Player_Tank_Impact
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: BulletToTank_Impact_Handle+Cj
		LDA	#7
		STA	Counter2	; 8 возможных пуль у врага

--:					; CODE XREF: BulletToTank_Impact_Handle+6Cj
		LDY	Counter2
		LDA	Bullet_Status,Y
		AND	#$F0 ; 'Ё'
		CMP	#$40 ; '@'
		BNE	Next_Bullet_Tank_Impact
		LDA	Bullet_X,Y
		SEC
		SBC	Tank_X,X
		BPL	CheckMinX_TankImpact
		EOR	#$FF
		CLC
		ADC	#1		; Вычисляем расстояние между танком и пулей по Х

CheckMinX_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+26j
		CMP	#$A
		BCS	Next_Bullet_Tank_Impact
		LDA	Bullet_Y,Y
		SEC
		SBC	Tank_Y,X
		BPL	CheckMinY_TankImpact
		EOR	#$FF
		CLC
		ADC	#1		; Вычисляем расстояние по Y

CheckMinY_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+37j
		CMP	#$A
		BCS	Next_Bullet_Tank_Impact
		LDA	#$33 ; '3'
		STA	Bullet_Status,Y	; Устанавливаем	статус в рикошет
		LDA	Invisible_Timer,X ; Силовое поле вокруг	игрока после рождения
		BEQ	Explode_Player_Tank_Impact
		LDA	#0
		STA	Bullet_Status,Y	; Убираем пулю
		JMP	Next_Bullet_Tank_Impact
; ───────────────────────────────────────────────────────────────────────────

Explode_Player_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+49j
		LDA	#$73 ; 's'
		STA	Tank_Status,X
		LDA	#1
		STA	Snd_PlayerExplode
		LDA	#0
		STA	Player_Type,X	; Вид танка игрока
		STA	Tank_Type,X
		JMP	Next_Player_Tank_Impact
; ───────────────────────────────────────────────────────────────────────────

Next_Bullet_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+1Ej
					; BulletToTank_Impact_Handle+2Fj
					; BulletToTank_Impact_Handle+40j
					; BulletToTank_Impact_Handle+50j
		DEC	Counter2
		LDA	Counter2
		CMP	#1		; Переходим к следующей	пуле
		BNE	--

Next_Player_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle:Jump_Next_Player_Tank_Impactj
					; BulletToTank_Impact_Handle+63j
		DEC	Counter
		BPL	-
		LDA	#7
		STA	Counter		; После	обработки попадания в игрока,
					; начинаем обрабатывать	врагов
					; (игрок попадает во врага)

---:					; CODE XREF: BulletToTank_Impact_Handle+130j
		LDX	Counter
		LDA	Tank_Status,X
		BPL	JumpNext_Enemy_Tank_Impact
		CMP	#$E0 ; 'р'      ; Если танк взорван или респаунится, переходим к следующему
		BCC	++

JumpNext_Enemy_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+7Aj
		JMP	Next_Enemy_Tank_Impact
; ───────────────────────────────────────────────────────────────────────────

++:					; CODE XREF: BulletToTank_Impact_Handle+7Ej
		LDA	#9
		STA	Counter2	; 10 пуль

----:					; CODE XREF: BulletToTank_Impact_Handle+125j
		LDA	Counter2
		AND	#6
		BEQ	+++
		JMP	Next_Bullet2_Tank_Impact
; ───────────────────────────────────────────────────────────────────────────

+++:					; CODE XREF: BulletToTank_Impact_Handle+8Bj
		LDY	Counter2
		LDA	Bullet_Status,Y
		AND	#$F0 ; 'Ё'
		CMP	#$40 ; '@'
		BEQ	Load_X_TankImpact
		JMP	Next_Bullet2_Tank_Impact
; ───────────────────────────────────────────────────────────────────────────

Load_X_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+99j
		LDA	Bullet_X,Y
		SEC
		SBC	Tank_X,X
		BPL	CheckMinX2_TankImpact
		EOR	#$FF
		CLC
		ADC	#1

CheckMinX2_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+A4j
		CMP	#$A
		BCC	+
		JMP	Next_Bullet2_Tank_Impact

+:
		LDA	Bullet_Y,Y
		SEC
		SBC	Tank_Y,X
		BPL	CheckMinY2_TankImpact
		EOR	#$FF
		CLC
		ADC	#1		; Вычисляем расстояние между танком и
					; пулей	по обеим осям

CheckMinY2_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+B5j
		CMP	#$A
		BCS	Next_Bullet2_Tank_Impact
		LDA	#$33 ; '3'      ; Делаем рикошет
		STA	Bullet_Status,Y
		LDA	Tank_Type,X
		AND	#4
		BEQ	Skip_BonusHandle_TankImpact ; Если танк	был бонусным, выводим бонус
		JSR	Bonus_Appear_Handle ; Выводит случайный	бонус на экран
		LDA	Tank_Type,X
		CMP	#$E4 ; 'ф'
		BNE	Skip_BonusHandle_TankImpact
		DEC	Tank_Type,X	; Если танк бронирован,	при
					; попадании пули уменьшаем броню

Skip_BonusHandle_TankImpact:		; CODE XREF: BulletToTank_Impact_Handle+C9j
					; BulletToTank_Impact_Handle+D2j
		LDA	Tank_Type,X
		AND	#3
		BEQ	Explode_Enemy_Tank_Impact
;! Проверяем броню босса:
		DEC	Boss_Armour
		LDA	Boss_Armour
		Bpl	Skip_Armour_Decrement

		DEC	Tank_Type,X
		LDA Boss_Mode
		BEQ Skip_Armour_Decrement
		LDA #Init_Boss_Armour
		STA Boss_Armour 
Skip_Armour_Decrement:
		LDA	#1
		STA	Snd_ArmorRicochetTank ;	Танк бронирован
		JMP	Next_Bullet2_Tank_Impact
; ───────────────────────────────────────────────────────────────────────────

Explode_Enemy_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+DAj
		LDA	#$73 ; 's'
		STA	Tank_Status,X	; Подрываем танк
		LDA	#1
		STA	Snd_EnemyExplode
		LDA	Tank_Type,X
		LSR	A
		LSR	A
		LSR	A
		LSR	A
		LSR	A
;! на боссовых уровнях в качестве врага может быть тип танка игрока, проверим это и если что, не отнимаем четверку:
		CMP	#$4
		BCC	Skip_EnemyType_Decrement
		SEC
		SBC	#4
Skip_EnemyType_Decrement:
		TAX
		LDA	Counter2
		AND	#1
		STA	Spr_X
		BNE	ScndPlayerKll_Tank_Impact
		INC	Enmy_KlledBy1P_Count,X
		JMP	Score_TankImpact
; ───────────────────────────────────────────────────────────────────────────

ScndPlayerKll_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+100j
		INC	Enmy_KlledBy2P_Count,X

Score_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+104j
		LDA	Level_Mode
		CMP	#2
		BEQ	Next_Enemy_Tank_Impact ; Во время демо-уровня, очки не прибавляются
		LDA	EnemyKill_Score,X ; Очки*10 за убийство	каждого	из 4 видов врагов
		JSR	Num_To_NumString ; Переводит число из А	в строку NumString
		LDA	Spr_X
		TAX
		JSR	Add_Score	; Прибавляет число из NumString	к очкам	игрока №Х
		JSR	Add_Life	; После	фрага, начисляем очки
		JMP	Next_Enemy_Tank_Impact
; ───────────────────────────────────────────────────────────────────────────

Next_Bullet2_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+8Dj
					; BulletToTank_Impact_Handle+9Bj
					; BulletToTank_Impact_Handle+ADj
					; BulletToTank_Impact_Handle+BEj
					; BulletToTank_Impact_Handle+E3j
		DEC	Counter2
		BMI	Next_Enemy_Tank_Impact
		JMP	----
; ───────────────────────────────────────────────────────────────────────────

Next_Enemy_Tank_Impact:			; CODE XREF: BulletToTank_Impact_Handle:JumpNext_Enemy_Tank_Impactj
					; BulletToTank_Impact_Handle+10Dj
					; BulletToTank_Impact_Handle+11Ej
					; BulletToTank_Impact_Handle+123j
		DEC	Counter
		LDA	Counter
		CMP	#1
		BEQ	++++
		JMP	---
; ───────────────────────────────────────────────────────────────────────────

++++:					; CODE XREF: BulletToTank_Impact_Handle+12Ej
		LDA	#1
		STA	Counter		; На этот раз рассматриваем попадание игроком в	игрока

-----:					; CODE XREF: BulletToTank_Impact_Handle+1ABj
		LDX	Counter
		LDA	Tank_Status,X
		BPL	Jump_Next_Player2_Tank_Impact
		CMP	#$E0 ; 'р'      ; Если игрок респаунится, или взорван, переходим к другому
		BCC	+++++

Jump_Next_Player2_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+13Bj
		JMP	Next_Player2_Tank_Impact
; ───────────────────────────────────────────────────────────────────────────

+++++:					; CODE XREF: BulletToTank_Impact_Handle+13Fj
		LDA	#9
		STA	Counter2	; 10 пуль

------:					; CODE XREF: BulletToTank_Impact_Handle+1A7j
		LDA	Counter2
		AND	#6
		BNE	Next_Bullet3_Tank_Impact
		LDY	Counter2
		LDA	Bullet_Status,Y
		AND	#$F0 ; 'Ё'
		CMP	#$40 ; '@'
		BNE	Next_Bullet3_Tank_Impact
		LDA	Counter
		EOR	Counter2
		AND	#1
		BEQ	Next_Bullet3_Tank_Impact
		LDA	Bullet_X,Y
		SEC
		SBC	Tank_X,X
		BPL	CheckMinX3_TankImpact
		EOR	#$FF
		CLC
		ADC	#1

CheckMinX3_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+167j
		CMP	#$A
		BCS	Next_Bullet3_Tank_Impact
		LDA	Bullet_Y,Y
		SEC
		SBC	Tank_Y,X
		BPL	CheckMinY3_TankImpact ;	Вычисляем расстояния по	обеим осям между танком	и пулей
		EOR	#$FF
		CLC
		ADC	#1

CheckMinY3_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+178j
		CMP	#$A		; Вычисляем расстояния по обеим	осям между танком и пулей
		BCS	Next_Bullet3_Tank_Impact
		LDA	#$33 ; '3'
		STA	Bullet_Status,Y	; Делаем рикошет
		LDA	Invisible_Timer,X ; Силовое поле вокруг	игрока после рождения
		BEQ	CheckBlink_TankImpact
		LDA	#0
		STA	Bullet_Status,Y	; Убираем пулю
		JMP	Next_Bullet3_Tank_Impact
; ───────────────────────────────────────────────────────────────────────────

CheckBlink_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+18Aj
		LDA	Player_Blink_Timer,X ; Таймер мигания friendly fire
		BNE	Next_Bullet3_Tank_Impact
		LDA	Level_Mode
		CMP	#2
		BEQ	Next_Bullet3_Tank_Impact ; На демо уровне Friendly Fire	нет
		LDA	#$C8 ; '╚'
		STA	Player_Blink_Timer,X ; Обновляем таймер
		JMP	Next_Player2_Tank_Impact
; ───────────────────────────────────────────────────────────────────────────

Next_Bullet3_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+14Cj
					; BulletToTank_Impact_Handle+157j
					; BulletToTank_Impact_Handle+15Fj
					; BulletToTank_Impact_Handle+170j
					; BulletToTank_Impact_Handle+181j
					; BulletToTank_Impact_Handle+191j
					; BulletToTank_Impact_Handle+196j
					; BulletToTank_Impact_Handle+19Cj
		DEC	Counter2
		BPL	------

Next_Player2_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle:Jump_Next_Player2_Tank_Impactj
					; BulletToTank_Impact_Handle+1A2j
		DEC	Counter
		BPL	-----
		RTS
; End of function BulletToTank_Impact_Handle

; ───────────────────────────────────────────────────────────────────────────
EnemyKill_Score:.BYTE $10, $20,	$30, $40 ; DATA	XREF: BulletToTank_Impact_Handle+10Fr
					; Очки*10 за убийство каждого из 4 видов врагов

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Выводит случайный бонус на экран

Bonus_Appear_Handle:			; CODE XREF: BulletToTank_Impact_Handle+CBp
		LDA	#1
		STA	Snd_BonusAppears ; Играем музыку появления бонуса

-:					; CODE XREF: Bonus_Appear_Handle+26j
		JSR	Get_Random_A	; ГПСЧ,	в А случайное число
		AND	#3		; 3 возможных координаты Х появления
		JSR	Multiply_Bonus_Coord ; A := ((A	* 6) + 6) * 8
		STA	Bonus_X
		JSR	Get_Random_A	; ГПСЧ,	в А случайное число
		AND	#3		; 3 возможных координаты Y появления
		JSR	Multiply_Bonus_Coord ; A := ((A	* 6) + 6) * 8
		STA	Bonus_Y		; Бонус	появляется в случайном месте
		LDA	#$FF
		STA	Bonus_Number	; Определяет тип бонуса
		LDA	#0
		STA	BonusPts_TimeCounter
		JSR	Bonus_Handle	; Обрабатывает взятие бонуса, если таковое есть
		LDA	BonusPts_TimeCounter
		BNE	-
		JSR	Get_Random_A	; ГПСЧ,	в А случайное число
		AND	#7		; 8 видов бонусов
		TAY
		LDA	BonusNumber_ROM_Array,Y	; Номера бонусов (идут по порядку)
		STA	Bonus_Number	; Определяет тип бонуса
		LDA	#0
		STA	BonusPts_TimeCounter ; Бонус пока не взят
		LDX	Counter
		LDY	Counter2
		RTS
; End of function Bonus_Appear_Handle

; ───────────────────────────────────────────────────────────────────────────
;!Индексы апгрейдов. 6 и 7 не добавлены.

BonusNumber_ROM_Array:.BYTE 0, 1, 2, 3,	4, 5, 4, 3 ; DATA XREF:	Bonus_Appear_Handle+2Er
					; Номера бонусов (идут по порядку)

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; A := ((A * 6)	+ 6) * 8

Multiply_Bonus_Coord:			; CODE XREF: Bonus_Appear_Handle+Ap
					; Bonus_Appear_Handle+14p
		STA	Temp
		ASL	A
		CLC
		ADC	Temp
		ASL	A
		CLC
		ADC	#6
		ASL	A
		ASL	A
		ASL	A
		RTS
; End of function Multiply_Bonus_Coord


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Обрабатывает столкновение двух пуль, если оно	есть

BulletToBullet_Impact_Handle:		; CODE XREF: Battle_Loop+21p
		LDA	#9
		STA	Counter		; 10 пуль

-:					; CODE XREF: BulletToBullet_Impact_Handle+5Fj
		LDA	Counter
		AND	#6
		BNE	Next_Bullet_Bulllet_Impact
		LDX	Counter
		LDA	Bullet_Status,X
		AND	#$F0 ; 'Ё'
		CMP	#$40 ; '@'
		BNE	Next_Bullet_Bulllet_Impact ; Если пуля не летит,
					; обрабатываем следующую
		LDA	#9
		STA	Counter2	; 10 пуль

--:					; CODE XREF: BulletToBullet_Impact_Handle+5Bj
		LDA	Counter2
		TAY
		AND	#7
		STA	Temp
		LDA	Counter
		AND	#7
		CMP	Temp
		BEQ	Next_Bullet2_Bulllet_Impact ; Саму с собой пулю	на столкновение
					; не проверяем
		LDA	Bullet_Status,Y
		AND	#$F0 ; 'Ё'
		CMP	#$40 ; '@'
		BNE	Next_Bullet2_Bulllet_Impact ; Если пуля	не летит,
					; переходим к следующей
		LDA	Bullet_X,Y
		SEC
		SBC	Bullet_X,X
		BPL	CheckMinX_BulletImpact ; Определяем расстояние по Х
					; между	2-мя пулями
		EOR	#$FF
		CLC
		ADC	#1

CheckMinX_BulletImpact:			; CODE XREF: BulletToBullet_Impact_Handle+36j
		CMP	#6
		BCS	Next_Bullet2_Bulllet_Impact ; Если >6, Переходим к следующей
		LDA	Bullet_Y,Y
		SEC
		SBC	Bullet_Y,X
		BPL	CheckMinY_BulletImpact ; Если <	6 , то проверяем расстояние по Y
					; между	двумя пулями
		EOR	#$FF
		CLC
		ADC	#1

CheckMinY_BulletImpact:			; CODE XREF: BulletToBullet_Impact_Handle+47j
		CMP	#6
		BCS	Next_Bullet2_Bulllet_Impact ; Если >6, то переходим к следующей
		LDA	#0
		STA	Bullet_Status,X
		STA	Bullet_Status,Y	; Уничтожаем обе пули

Next_Bullet2_Bulllet_Impact:		; CODE XREF: BulletToBullet_Impact_Handle+25j
					; BulletToBullet_Impact_Handle+2Ej
					; BulletToBullet_Impact_Handle+3Fj
					; BulletToBullet_Impact_Handle+50j
		DEC	Counter2
		BPL	--

Next_Bullet_Bulllet_Impact:		; CODE XREF: BulletToBullet_Impact_Handle+8j
					; BulletToBullet_Impact_Handle+12j
		DEC	Counter
		BPL	-
		RTS
; End of function BulletToBullet_Impact_Handle


; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

; Обрабатывает взятие бонуса, если таковое есть

Bonus_Handle:				; CODE XREF: Battle_Loop+27p
					; Bonus_Appear_Handle+21p
		LDA	Bonus_X
		BEQ	End_Bonus_Handle
		LDA	BonusPts_TimeCounter
		BNE	End_Bonus_Handle
		LDA	#7		;! Начинаем с последнего вражеского танка (добавлена обработка взятия вражескими танками бонуса)
		STA	Tank_Num	; Номер	танка игрока, при обработке взятия бонуса

-:					; CODE XREF: Bonus_Handle+6Dj
		LDX	Tank_Num	; Номер	танка игрока, при обработке взятия бонуса
		LDA	Tank_Status,X
		BPL	+		; Переходим к следующему танку
		CMP	#$E0 ; 'р'
		BCS	+		; Если танк взорван или	респаунится,
					; не рассматриваем его
		LDA	Tank_X,X
		SEC
		SBC	Bonus_X
		BPL	+++
		EOR	#$FF
		CLC
		ADC	#1		; Вычисление расстояния	от
					; танка	до бонуса по Х

+++:					; CODE XREF: Bonus_Handle+1Bj
		CMP	#$C
		BCS	+		; Переходим к следующему танку
		LDA	Tank_Y,X
		SEC
		SBC	Bonus_Y
		BPL	++
		EOR	#$FF
		CLC
		ADC	#1		; Вычисление расстояния	от
					; танка	до бонуса по Y

++:					; CODE XREF: Bonus_Handle+2Bj
		CMP	#$C
		BCS	+		; Переходим к следующему танку
		LDA	#$32 ; '2'      ; время отображения очков за бонус (фреймы)
		STA	BonusPts_TimeCounter
		LDA	Bonus_Number	; Определяет тип бонуса
		BMI	End_Bonus_Handle
		LDA	Level_Mode
		CMP	#2		; В режиме демо	уровня очки не прибавляются
		BEQ	Bonus_Command	; Производит действия бонуса
		LDA	#$50 ; 'P'      ; 500 очков дается за бонус
		JSR	Num_To_NumString ; Переводит число из А	в строку NumString
		LDX	Tank_Num	; Номер	танка игрока, при обработке взятия бонуса
		JSR	Add_Score	; Прибавляет число из NumString	к очкам	игрока №Х
		JSR	Add_Life	; Прибавляет одну жизнь, если игрок заработал 200К очков
		LDX	Tank_Num	; Номер	танка игрока, при обработке взятия бонуса
		LDA	#1
		STA	Snd_BonusTaken	; Проигрываем мелодию за взятие	бонуса

Bonus_Command:				; CODE XREF: Bonus_Handle+42j
		LDA	Bonus_Number	; Производит действия бонуса
		ASL	A		; Указатель двухбайтовый
		TAY
		LDA	Bonus_JumpTable,Y
		STA	LowPtr_Byte
		LDA	Bonus_JumpTable+1,Y
		STA	HighPtr_Byte
		PLA
		PLA
		JMP	(LowPtr_Byte)
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Bonus_Handle+10j
					; Bonus_Handle+14j Bonus_Handle+24j
					; Bonus_Handle+34j
		DEC	Tank_Num	; Переходим к следующему танку
		BPL	-

End_Bonus_Handle:			; CODE XREF: Bonus_Handle+2j
					; Bonus_Handle+6j Bonus_Handle+3Cj
		RTS
; End of function Bonus_Handle

; ───────────────────────────────────────────────────────────────────────────
Bonus_JumpTable:.WORD Bonus_Helmet	; DATA XREF: Bonus_Handle+5Cr
					; Bonus_Handle+61r
					; Создает поле вокруг танка, а если взял враг, выставляет полную броню и инвертирует бонусность.
		.WORD Bonus_Watch	; Останавливает	всех врагов, а если взял враг, останавливает игроков.
		.WORD Bonus_Shovel	; Строит броню вокруг штаба или убирает даже кирпичи
		.WORD Bonus_Star	; Переводит игрока или всех врагов в следующий вид
		.WORD Bonus_Grenade	; Взрывает всех	врагов или игроков
		.WORD Bonus_Life	; Имеет	вид танка. Прибавляет одну жизнь или пять вражеских танков в запас
		.WORD Bonus_Pistol	; Не используется и ничего не делает, однако имеет свою	иконку бонуса
; ───────────────────────────────────────────────────────────────────────────

Bonus_Helmet:				; DATA XREF: ROM:Bonus_JumpTableo
					; Создает поле вокруг танка, а если взял враг, выставляет полную броню и инвертирует бонусность.
		CPX     #2
                BCC     Players_Helmet
                TXA
                PHA
                LDX     #7

-:                              
                LDA     Tank_Type,X
                ORA     #3
                EOR     #4
                STA     Tank_Type,X
                DEX
                CPX     #1; на второго игрока не залезаем (1<x<8)
                BNE     -
                PLA
                TAX
                RTS

Players_Helmet:
		LDA	#10		
		STA	Invisible_Timer,X ; Силовое поле вокруг	игрока после рождения
		RTS
; ───────────────────────────────────────────────────────────────────────────

Bonus_Watch:				; DATA XREF: ROM:E9E4o
					; Останавливает	всех врагов, а если взял враг, останавливает игроков.
                CPX     #2
		BCC     Players_Watch


                LDA     #$C8 ; 'L'
                STA     Player_Blink_Timer
                STA     Player_Blink_Timer+1
                RTS

Players_Watch:				
		LDA	#10		
		STA	EnemyFreeze_Timer
		RTS
; ───────────────────────────────────────────────────────────────────────────

Bonus_Shovel:	; Строит броню вокруг штаба или убирает даже кирпичи

		LDA	HQ_Status	
		BPL	End_Bonus_Shovel
                CPX     #2
		BCC     Players_Shovel

		JSR	Draw_ShovelHQ		
		RTS


Players_Shovel:			
		JSR	Draw_ArmourHQ	; Рисует штаб с	броней
		LDA	#20
		STA	HQArmour_Timer	; Таймер брони вокруг штаба

End_Bonus_Shovel:			; CODE XREF: ROM:E9FDj
		RTS
; ───────────────────────────────────────────────────────────────────────────

Bonus_Star:		;Переводит игрока в следующий вид, если взял враг, апгрейдит всех врагов на экране и добавляет один хит брони.	


                CPX     #2
		BCC     Players_Star
		TXA
		PHA
		LDX	#7
-:
		LDA	Tank_Type,X
		CMP	#$E0
		Bcs	Nxt_Enemy_Star
		ADC	#$20 ;
		ORA	#1
		STA	Tank_Type,X
Nxt_Enemy_Star:
		DEX
		CPX #1
		BNE -

		PLA
		TAX
		RTS

Players_Star:			
		LDA	Player_Type,X	
		CMP	#$60 ; '`'
		BEQ	End_Bonus_Star	; Если достигнут максимальный вид, выходим
		CLC
		ADC	#$20 ; ' '      ; Делаем танк следующим видом
		STA	Player_Type,X	; Вид танка игрока
		STA	Tank_Type,X

End_Bonus_Star:				; CODE XREF: ROM:EA0Cj
		RTS
; ───────────────────────────────────────────────────────────────────────────

Bonus_Grenade:
		LDA	#1
		STA	Snd_EnemyExplode
		CPX	#2
		BCC	Players_Grenade

		LDA	#1
		STA	Counter
		LDA	#$FF
		STA	Counter2	;останавливаемся когда взорвем всех игроков
		JMP 	Bonus_Grenade_Loop
    




Players_Grenade:
		LDA	#7		; Взрывает всех	врагов
		STA	Counter		; Начинаем с последнего	врага
		LDA	#1
		STA	Counter2	;останавливаемся на игроках

Bonus_Grenade_Loop:			; CODE XREF: ROM:EA3Bj
		LDY	Counter
		LDA	Tank_Status,Y
		BPL	Explode_Next
		CMP	#$E0 ; 'р'
		BCS	Explode_Next	; Если враг взрывается или респаунится,	не взрываем его
		LDA	#$73 ; 's'      ; Взрываем танк
		STA	Tank_Status,Y
		LDA	#0
		STA	Tank_Type,Y

Explode_Next:				; CODE XREF: ROM:EA25j	ROM:EA29j
		DEC	Counter
		LDA	Counter
		CMP	Counter2	; Игроков не взрываем
		BNE	Bonus_Grenade_Loop
		RTS
; ───────────────────────────────────────────────────────────────────────────

Bonus_Life:		;добавляет жизнь игроку, если взял враг, увеличивает количество врагов в запасе на пять.

		CPX #2
		BCC Players_Life

		CLC	; !следующий ADC образовывал лишний танк без очистки переноса, bugfix
		LDA	Enemy_Reinforce_Count
		ADC	#5		
		STA	Enemy_Reinforce_Count
		LDA	Enemy_Counter
		ADC	#5		
		STA	Enemy_Counter
		JSR	Draw_Reinforcemets
		
		
		RTS

Players_Life:				
		INC	Player1_Lives,X	; Имеет	вид танка. Прибавляет одну жизнь
		LDA	#1
		STA	Snd_Ancillary_Life1
		STA	Snd_Ancillary_Life2 ; Проигрываем звук через оба канала

Bonus_Pistol:				; DATA XREF: ROM:E9EEo
		RTS			; Не используется и ничего не делает, однако имеет свою	иконку бонуса
; ───────────────────────────────────────────────────────────────────────────
;Данные, связанные с отрисовкой	пули
;Загружается $E622 (такой же массив по адресу $D3D5)
Bullet_Coord_X_Increment_2:.BYTE 0, $FF, 0, 1 ;	DATA XREF: Bullet_Fly_Handle+1Er
;Загружается $E632
Bullet_Coord_Y_Increment_2:.BYTE $FF, 0, 1, 0 ;	DATA XREF: Bullet_Fly_Handle+2Er



; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████


Load_Level:				; CODE XREF: ROM:C1D9p
					; Load_DemoLevel+20p

;! Проверяем нужен ли случайный уровень и, если да, загружаем пустой (номер 101)
		ldx Random_Level_Flag
		Beq ++++
		Lda #101
		jmp Begin
++++
				
		CMP	#$FF
		BNE	Begin
		LDA	#100 ; '$'      ; Демо-уровень
		JMP	Begin
; ───────────────────────────────────────────────────────────────────────────


Begin:					; CODE XREF: Load_Level+6j
					; Load_Level+Bj
		STA	Temp
		LDA	#>Level_Data
		STA	HighPtr_Byte
		LDA	#<Level_Data	; Старший и младший байты указателя
					; на начало блока уровней
		STA	LowPtr_Byte

-:					; CODE XREF: Load_Level+23j
		DEC	Temp
		BEQ	+
		LDA	#$5B ; '['      ; 5b-размер данных одного уровня
		JSR	Inc_Ptr_on_A
		JMP	-
; ───────────────────────────────────────────────────────────────────────────

+:					; CODE XREF: Load_Level+1Cj
		LDA	#0
		STA	Counter
		LDA	LowPtr_Byte
		STA	LowStrPtr_Byte
		LDA	HighPtr_Byte
		STA	HighStrPtr_Byte
		LDA	#$10
		STA	Block_Y

--:					; CODE XREF: Load_Level+77j
		JSR	NMI_Wait	; Ожидает немаскируемого прерывания
		LDA	#$10
		STA	Block_X

---:					; CODE XREF: Load_Level+6Aj
		LDA	Counter
		LSR	A
		TAY
		LDA	Counter
		AND	#1
		BEQ	++
		LDA	(LowStrPtr_Byte),Y
		AND	#$F
		JMP	+++
; ───────────────────────────────────────────────────────────────────────────

++:					; CODE XREF: Load_Level+45j
		LDA	(LowStrPtr_Byte),Y
		LSR	A
		LSR	A
		LSR	A
		LSR	A

+++:					; CODE XREF: Load_Level+4Bj
		LDX	Block_X
		LDY	Block_Y
		JSR	Draw_TSABlock
		LDA	#0
		STA	ScrBuffer_Pos
		INC	Counter
		LDA	Block_X
		CLC
		ADC	#$10
		STA	Block_X
		CMP	#$E0 ; 'р'
		BNE	---
		INC	Counter
		LDA	Block_Y
		CLC
		ADC	#$10
		STA	Block_Y
		CMP	#$E0 ; 'р'
		BNE	--
		RTS
; End of function Load_Level

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████

Draw_Random_Level:;! Вносит изменения в пустой уровень (рисует лабиринт по кирпичам)
;Идея такая: существует два типа лабиринтов:
;1) Натуральный лабиринт, который реализован за счет постановки пустого блока на случайное место. Очень красиво, но враги почти никогда
; не смогут добраться до штаба и бой превращается просто в отстрел врагов
;2) карта с большой "танцплощадкой" посередине, реализованная за счет отрисовки пустыми блоками линий фиксированной ширины по
;случайным направлениям
;Данный тип выбирается случайно, а затем после его реализации, производится декоративная дорисовка случайными блоками по всей карте.


Line_TSA_Count_Begin = 5; количество TSA в одной линии лабиринта
Space_Count = $FF; количество пустых TSA в лабиринте
Misc_Count = $12; количество декорирующих блоков в лабиринте

	jsr NMI_Wait
	LDA	#00110000b ; отключаем NMI при VBlank'е - иначе, уровень будет прорисован поверх экрана выбора уровня.
	STA	PPU_CTRL_REG1

	Lda #Space_Count
	Sta Counter; лабиринт будет состоять из Counter блоков

	Lda #$80
	Sta Block_X
	Sta Block_Y
	
	jsr Get_Random_A
	And #$80
	Bne Draw_Lab; Определяем какой тип карты будем рисовать
-
	JSR Draw_DanceFloor
	; после всех проверок и вычислений координат, рисуем.
	Lda #$F; пустое место
	LDX	Block_X
	LDY	Block_Y
	Jsr Draw_TSABlock
	Dec Counter
	Bne -
	JMP Decorate
Draw_Lab:
	JSR Draw_Labyrinth
	; после всех проверок и вычислений координат, рисуем.
	Lda #$F; пустое место
	LDX	Block_X
	LDY	Block_Y
	Jsr Draw_TSABlock
	Dec Counter
	Bne Draw_Lab
	
	

Decorate
;После отрисовки определенного типа лабиринта, общее для всех декорирование уровня разными блоками:

	lda #Misc_Count
	sta Counter; количество декорирующих блоков в лабиринте
---
	JSR Draw_Labyrinth
--
	jsr Get_Random_A 
	And #$F
	cmp #$D; Случайный блок обязан быть #$9<x<=#$0C - чтобы не чинить препятствий в уже созданную карту
	BCS --
	cmp #$9
	Bcc --
	LDX	Block_X
	LDY	Block_Y
	Jsr Draw_TSABlock
	Dec Counter
	Bne ---

	Jsr Set_PPU
	RTS
; End of function Draw_Random_Level

; ───────────────────────────────────────────────────────────────────────────
Check_Bounds:; проверяет не вышло ли за границы экрана (10<X<E0), если нет, возвращает ноль.

ldx #0
-
LDA Block_X,x; Block_X и Block_Y идут друг за другом.
cmp #$10
Bcs +
lda #$FF
jmp End_Check_Bounds

+
cmp #$E0
bcc++
lda #$FF
jmp End_Check_Bounds

++
inx
cpx #2
Bne -
Lda #0

End_Check_Bounds:
RTS
; End of function Check_Bounds


; ───────────────────────────────────────────────────────────────────────────
Draw_DanceFloor:; Рисует танцплощадку

	lda #Line_TSA_Count_Begin
	Sta Line_TSA_Count; линия лабиринта будет состоять из Line_TSA_Count_Begin пустых блоков	

---
	Ldy #0; начинаем с координаты Х, потом перейдем к следующей ячейке (координате Y)

--
	lda Block_X,y
-
	Sta Block_X,y
	sta Old_Coord
	dec Line_TSA_Count
	lda Line_TSA_Count
	beq Draw_DanceFloor
	cmp #Line_TSA_Count_Begin-2
	bcc Skip_Random
	jsr Get_Random_A

Skip_Random:
	cmp #$AA
	bcc +
	lda Block_X,y ; Если > $AA, то увеличиваем координату
	clc
	adc #$10
	Sta Block_X,y
	jmp ++

+
	cmp #$55
	bcc ++
	lda Block_X,y; Если <$AA и >$55 , то уменьшаем координату
	clc
	sbc #$10
	Sta Block_X,y

++
	JSR Check_Bounds
	Beq +++
	lda Old_Coord
	jmp -

+++
	Lda Old_Coord
	iny
	cpy #2
	bne --

	RTS
; End of function Draw_DanceFloor


; ───────────────────────────────────────────────────────────────────────────
Draw_Labyrinth:; Рисует лабиринт

	Ldy #0; начинаем с координаты Х, потом перейдем к следующей ячейке (координате Y)

--
	lda Block_X,y
-
	Sta Block_X,y
	sta Old_Coord

	jsr Get_Random_A
	Sta Block_X,y

	JSR Check_Bounds
	Beq +++
	lda Old_Coord
	jmp -

+++
	Lda Old_Coord
	iny
	cpy #2
	bne --

	RTS
; End of function Draw_Labyrinth

; Рисует большую кирпичную надпись с рекордом

; ███████████████ S U B	R O U T	I N E ███████████████████████████████████████
Draw_Congrats:			
		JSR	Screen_Off
		LDA	#$1C
		STA	PPU_Addr_Ptr
		LDA	#0
		STA	Scroll_Byte
		STA	PPU_REG1_Stts
		JSR	Null_NT_Buffer
		LDX	#0
		STX	Block_X
		LDY	#$32 ; '2'
		STY	Block_Y
		LDA	#>aCongrats	; Выводится в виде кирпичной надписи, если рекорд
		STA	HighStrPtr_Byte
		LDA	#<aCongrats	; Выводится в виде кирпичной надписи, если рекорд
		STA	LowStrPtr_Byte
		JSR	Draw_BrickStr
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






