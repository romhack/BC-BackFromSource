; ���������������������������������������������������������������������������

NMI:					; DATA XREF: ROM:FFFAo
		PHA
		TXA
		PHA
		TYA
		PHA
		PHP			; �⠭���⭮� ��砫� NMI
		LDA	#0
		STA	PPU_SPR_ADDR	; ���樠������	��� ����� � �㫥��� ���� SPR OAM
		LDA	#2
		STA	SPR_DMA		; ��ࠩ⮢� ����� �㤥� �� ����� $200
		LDA	PPU_STATUS	; Reset	VBlank Occurance
		JSR	Update_Screen	; ����� �� Screen_Buffer � ������ PPU
		LDA	BkgPal_Number
		BMI	Skip_PalLoad
		JSR	Load_Bkg_Pal

Skip_PalLoad:				; CODE XREF: ROM:D418j
		LDA	PPU_REG1_Stts
		ORA	#10110000b	; ����筠� ��� BC ���䨣���� PPU (��ࠩ�� �ᥣ�� 8�16	(�ਭ�	� ����))
		STA	PPU_CTRL_REG1	; PPU Control Register #1 (W)
		LDA	#0		; ��ࠡ�⪠ �஫�����
		STA	PPU_SCROLL_REG	; VRAM Address Register	#1 (W2)
		LDA	Scroll_Byte
		STA	PPU_SCROLL_REG	; VRAM Address Register	#1 (W2)
		LDA	#00011110b	; ����砥� ���㭤 � �ࠩ��
		STA	PPU_CTRL_REG2	; PPU Control Register #2 (W)
		JSR	Read_Joypads
		JSR	Spr_Invisible	; �뢮�	Y ���न��� �ࠩ⮢ � $F0
		JSR	Play_Sound	; �������筮 Play � NSF	�ଠ�
		INC	Frame_Counter
		LDA	Frame_Counter
		AND	#63		; � ����� ᥪ㭤� 64 �३��?
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

; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����,	� � ��砩��� �᫮

Get_Random_A:				; CODE XREF: ROM:DC8Cp	ROM:DD17p
					; ROM:Get_RandomStatusp ROM:DD4Fp
					; Load_AI_Status:Load_AIStatus_GetRandomp
					; Get_RandomDirection+12p
					; Make_Enemy_Shot+Fp
					; Bonus_Appear_Handle:-p
					; Bonus_Appear_Handle+Fp
					; Bonus_Appear_Handle+28p
		TXA
;���� �� �᭮��� �� ������� ��।������,
;���⮬� �뤠��	����砩�� �᫠. �ᯮ���� ���
;����:	Random_Hi ������ � ⮬	�᫥ �� ⠩��� ᥪ㭤,
;Random_Lo - �᭮���� ����
		PHA			; ���࠭塞 �
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
		ADC	Temp,X		; �롨ࠥ��� ��砩��� �祩�� �� Zero Page
					; � �ந������ ���祭��� ��� ����襩 "��砩����"
		STA	Random_Lo
		PLA
		TAX			; ���᪨���� �
		LDA	Random_Lo
		RTS
; End of function Get_Random_A

; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����,	� � ��砩��� �᫮

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


; ��������������� S U B	R O U T	I N E ���������������������������������������


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
		STA	PPU_CTRL_REG1	; ������ ������������ - ��ன;
					; �ࠩ�� 8�16;
					; �믮����� NMI	�� VBlank'�
		RTS
; End of function Set_PPU


; ��������������� S U B	R O U T	I N E ���������������������������������������


Screen_Off:				; CODE XREF: ROM:C0B2p	Clear_NTp
					; Load_DemoLevel+2Bp
					; Draw_Record_HiScorep
					; Show_Secret_Msgp Show_Secret_Msg+BEp
					; Draw_Brick_GameOverp
					; Draw_Brick_GameOver:End_Draw_Brick_GameOverp
					; Draw_Pts_Screen_Template+1Bp
					; Null_Upper_NTp Draw_TitleScreenp
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	#00010000b
		STA	PPU_CTRL_REG1	; ��� ���㭤� �����祭 ��ன ������������,
					; � ���	�ࠩ⮢ - ����
					;
		LDA	#00000110b
		STA	PPU_CTRL_REG2	; ��� �	�ࠩ��	�⪫�祭�
		RTS
; End of function Screen_Off


; ��������������� S U B	R O U T	I N E ���������������������������������������


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


; ��������������� S U B	R O U T	I N E ���������������������������������������


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
		LDA	#4		; ��ࠩ⮢� ����� ������塞 �१ 4 ����
		STA	Gap
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		JSR	Null_NT_Buffer
		JSR	Spr_Invisible	; ������ �� �ࠩ�� ��	�࠭
		LDX	#HiScore_1P_String
		JSR	Null_8Bytes_String
		LDX	#HiScore_2P_String
		JSR	Null_8Bytes_String
		JSR	StaffStr_Check	; 0=� RAM ��� ��ப� StaffString
					; 1=� RAM ���� ��ப� StaffString
		BNE	HotBoot		; ���⪠ �����	⠩����� ����

		LDX	#HiScore_String
		JSR	Null_8Bytes_String
		LDA	#2
		STA	HiScore_String+2 ; �����뢠�� �	HiScore	�᫮ 20000
		LDA	#0
		STA	CursorPos	; ��⠭��������	����� �� ������� '1 player'
		STA     Map_Mode_Pos
		STA	Boss_Mode
;! �᫨ ����㧪� 宫�����, ���樨�㥬 ����� �஢���. �� ��� ��� �� ������ ���뢠����.
		LDA	#1
		STA	Level_Number



HotBoot:				; CODE XREF: Reset_ScreenStuff+2Ej
		LDA	#$1C		; ���⪠ �����	⠩����� ����
		STA	PPU_Addr_Ptr	; 1c+04=20 (������ � $2000 VRAM)[NT#1]
		JSR	Store_NT_Buffer_InVRAM ; ����뢠�� �� �࠭ ᮤ�ন���	NT_Buffer
		LDA	#$24 ; '$'
		STA	PPU_Addr_Ptr	; 24+4=28 (� 2800)[NT#2]
		JSR	Store_NT_Buffer_InVRAM ; ����뢠�� �� �࠭ ᮤ�ন���	NT_Buffer
		JSR	StaffStr_Store	; ����������, �� ��� �뫠 㦥	����祭�
					; (�� ��砩 ��१���㧪� RESET'��)
		JSR	Sound_Stop	; ��⠭��������	���, ����砥� ������ �	�.�. (�������筮 Load �	NSF �ଠ�)
		RTS
; End of function Reset_ScreenStuff


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����������, �� ��� �뫠 㦥	����祭�
; (�� ��砩 ��१���㧪� RESET'��)

StaffStr_Store:				; CODE XREF: Reset_ScreenStuff+4Bp
		LDX	#$F

-:					; CODE XREF: StaffStr_Store+9j
		LDA	StaffString,X	; "RYOUITI OOKUBO  TAKEFUMI HYOUDOUJUNKO O"...
		STA	StaffString_RAM,X
		DEX
		BPL	-
		RTS
; End of function StaffStr_Store


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �᫨ �⮩ ��ப� ��� � RAM, � ��� ������ ���� ࠧ
; (����祭� ������� POWER)

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
; ���������������������������������������������������������������������������

ColdBoot:				; CODE XREF: StaffStr_Check+8j
		LDA	#0
		RTS
; End of function StaffStr_Check


; ��������������� S U B	R O U T	I N E ���������������������������������������


Load_Pals:				; CODE XREF: Reset_ScreenStuff+10p
		JSR	VBlank_Wait
		JSR	Spr_Pal_Load
		LDA	#0		; �����	16梥⭮� Frame�������
		JSR	Load_Bkg_Pal
		RTS
; End of function Load_Pals


; ��������������� S U B	R O U T	I N E ���������������������������������������


Load_Bkg_Pal:				; CODE XREF: ROM:D41Ap	Load_Pals+8p
		ASL	A
		ASL	A
		ASL	A
		ASL	A		; A*10
		TAX
		LDY	#$10
		LDA	#$3F ; '?'      ; �����⮢�� � ����� 16 梥⭮� ������� � ������� Background ������
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
		STA	PPU_ADDRESS	; ���㫥��� ���� PPU?
		RTS
; End of function Load_Bkg_Pal


; ��������������� S U B	R O U T	I N E ���������������������������������������


Spr_Pal_Load:				; CODE XREF: Load_Pals+3p
		LDX	#0
		LDY	#$10
		LDA	#$3F ; '?'      ; �����⮢�� � ����� 16 梥⮢ � ������� �ࠩ⮢�� ������
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

; ���������������������������������������������������������������������������
;�������:
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

; ��������������� S U B	R O U T	I N E ���������������������������������������


VBlank_Wait:				; CODE XREF: Set_PPUp Load_Palsp -+3j
-:					; PPU Status Register (R)
		LDA	PPU_STATUS
		BPL	-
		RTS
; End of function VBlank_Wait


; ��������������� S U B	R O U T	I N E ���������������������������������������


CoordTo_PPUaddress:			; CODE XREF: Draw_StageNumString+7p
					; FillScr_Single_Row+2p
					; String_to_Screen_Bufferp
					; Save_Str_To_ScrBufferp
					; CoordsToRAMPosp Draw_GrayFrame+21p
		LDA	#0
		STA	Temp		; ��࠭	�ਭ��	$20 ⠩���. ���訩 ���� ����	� NT 㢥������	�� 1, �᫨
					; �� ��砫� �࠭� �㤥� $100 ⠩��� ��� 8 ��ப ⠩���(Y=8).
					; �����	��ࠧ��, ���訩 ���� ����� ���� ���᫥� �� ��㫥: (Y div 8)	��� (Y shr 3)
					; ��⥬	� ���襬 ����	���⠢����� ��� �2 (���訩 ���� ⥯��� �� ����� 4):
					; � ���쭥�襬,	� ���襬� ����� �㤥� �ਡ������ $1c, ⠪ �� � �⮣� �� ������
					; ��������� ���� ����� $2000	(1-� NT).
					; ����訩 ���� � �⮬ ��砥, ����� ���� ���᫥� �� ��㫥: (X + Y*($20)) ���	(X + (Y	shl 5)).
					; ���, ��㣨�� ᫮����,	�� ������ ��� Y ������ ��३� � ��	�����	��� X,
					; �� �	ॠ�������� � �⮩ ��楤��.
					; __________________________________________
					; �� �室� � � Y: ���न���� ⠩�� �� �࠭�
					; �� ��室� A: (���訩	���� - $1c)
					;	    Y:	����訩	����
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
		ORA	#4		; ���⠢�塞 ��ன ���
		RTS
; End of function CoordTo_PPUaddress


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �����㥬 ��ਡ��� �� NT_Buffer �� �࠭

AttribToScrBuffer:			; CODE XREF: Draw_TSABlock+13p
		JSR	TSA_Pal_Ops
		LDX	ScrBuffer_Pos
		LDA	#$23 ; '#'
		STA	Screen_Buffer,X
		INX
		TYA
		CLC
		ADC	#$C0 ; '�'
		STA	Screen_Buffer,X	; � PPU	�㤥� ����� � ��ਡ���
		INX
		LDA	NT_Buffer+$3C0,Y
		STA	Screen_Buffer,X
		INX
		LDA	#$FF
		STA	Screen_Buffer,X	; �����	��ப�
		INX
		STX	ScrBuffer_Pos
		RTS
; End of function AttribToScrBuffer


; ��������������� S U B	R O U T	I N E ���������������������������������������


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
		LDA	#$F3 ; '�'
		JMP	End_TSA_Pal_Ops
; ���������������������������������������������������������������������������

++:					; CODE XREF: TSA_Pal_Ops+15j
		LDA	#$FC ; '�'
		JMP	End_TSA_Pal_Ops
; ���������������������������������������������������������������������������

+:					; CODE XREF: TSA_Pal_Ops+10j
		TXA
		AND	#2
		BEQ	+++
		LDA	#$3F ; '?'
		JMP	End_TSA_Pal_Ops
; ���������������������������������������������������������������������������

+++:					; CODE XREF: TSA_Pal_Ops+24j
		LDA	#$CF ; '�'

End_TSA_Pal_Ops:			; CODE XREF: TSA_Pal_Ops+19j
					; TSA_Pal_Ops+1Ej TSA_Pal_Ops+28j
		STA	byte_1
		TYA
		ASL	A
		AND	#$F8 ; '�'
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
		LDA	NT_Buffer+$3C0,Y ; ��襬 � ��ਡ���
		AND	byte_1
		ORA	CHR_Byte
		STA	NT_Buffer+$3C0,Y
		RTS
; End of function TSA_Pal_Ops


; ��������������� S U B	R O U T	I N E ���������������������������������������

; A := (A * 4) OR TSA_Pal

OR_Pal:					; CODE XREF: TSA_Pal_Ops+2p
					; TSA_Pal_Ops+5p TSA_Pal_Ops+8p
		ASL	A
		ASL	A
		ORA	TSA_Pal
		RTS
; End of function OR_Pal


; ��������������� S U B	R O U T	I N E ���������������������������������������


Read_Joypads:				; CODE XREF: ROM:D433p
		LDX	#1
		STX	JOYPAD_PORT1	; Joypad #1 (RW)
		LDY	#0
		STY	JOYPAD_PORT1	; ��஡

--:					; CODE XREF: Read_Joypads+27j
		STY	Temp
		LDY	#8		; 8 ������

-:					; CODE XREF: Read_Joypads+18j
		LDA	JOYPAD_PORT1,X	; ���砫� ���訢��� ��ன �����⨪, ��⮬ ����
		AND	#3
		CMP	#1
		ROR	Temp
		DEY
		BNE	-		; ���砫� ���訢��� ��ன �����⨪, ��⮬ ����
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

; ��������������� S U B	R O U T	I N E ���������������������������������������


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
		STA	Screen_Buffer,X	; ���砫� ��࠭塞 ���� PPU, �㤠 �㤥� ���ᠭ� �� ��ப�
		INX
		STA	LowStrPtr_Byte
		LDY	#0

-:					; CODE XREF: String_to_Screen_Buffer+24j
		LDA	(LowPtr_Byte),Y	; ����㦠�� �㦭� ��ਭ� �� ����
		STA	Screen_Buffer,X
		INX
		CMP	#$FF
		BEQ	+
		STA	(LowStrPtr_Byte),Y
		INY
		JMP	-		; ����㦠�� �㦭� ��ਭ� �� ����
; ���������������������������������������������������������������������������

+:					; CODE XREF: String_to_Screen_Buffer+1Fj
		STX	ScrBuffer_Pos
		RTS
; End of function String_to_Screen_Buffer


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ���࠭�� ��ப� � ��ப��� �����

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
		STA	Screen_Buffer,X	; ���砫� ��࠭塞 � ����� ���� PPU (hi/lo)
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
		CMP	#$FF		; ����뢠�� � �����, ���� �� �����	����� ��ப�: $FF
		BEQ	++		; ���࠭�� ������ � ����� � �멤��
		INY
		JMP	-
; ���������������������������������������������������������������������������

++:					; CODE XREF: Save_Str_To_ScrBuffer+20j
		STX	ScrBuffer_Pos	; ���࠭�� ������ � ����� � �멤��
		RTS
; End of function Save_Str_To_ScrBuffer


; ��������������� S U B	R O U T	I N E ���������������������������������������

; � � �	Y �� ��室� ���न���� � ⠩���

GetCoord_InTiles:			; CODE XREF: Get_SprCoord_InTiles+4p
					; SaveSprTo_SprBuffer+Dp ROM:DCD2p
					; ROM:DCF7p Ice_Detect+1Ap
					; GetSprCoord_InTiles+4p
		JSR	XnY_div_8	; �����	�� 8 Y � X
; End of function GetCoord_InTiles


; ��������������� S U B	R O U T	I N E ���������������������������������������


CoordsToRAMPos:				; CODE XREF: Draw_TSABlock+20p
		JSR	CoordTo_PPUaddress
		STA	HighPtr_Byte
		STY	LowPtr_Byte
		LDY	#0
		RTS
; End of function CoordsToRAMPos


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �����	�� 8 Y � X

XnY_div_8:				; CODE XREF: GetCoord_InTilesp
					; Draw_TSABlock+3p
		TYA
;���筮	�� ���न��� � ���ᥫ��
;��ॢ���� � ���न����	� ⠩���
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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ॢ���� SPR_XY � ⠩��

Get_SprCoord_InTiles:			; CODE XREF: Draw_Char+44p
		STX	Spr_X
		STY	Spr_Y
		JSR	GetCoord_InTiles ; � � � Y �� ��室� ���न����	� ⠩���
; End of function Get_SprCoord_InTiles


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �८�ࠧ�� Temp � ����ᨬ��� �� Spr_Coord

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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �����頥� ����, �᫨	�㫥���	⠩�

Check_Object:				; CODE XREF: BulletToObject_Impact_Handle+3p
		LDA	Temp
		ORA	#$F0 ; '�'
		AND	(LowPtr_Byte),Y
		RTS
; End of function Check_Object


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� �ࠢ���� ���� � ��௨筮� �⥭�

Draw_Destroyed_Brick:			; CODE XREF: BulletToObject_Impact_Handle:BulletToObject_Return1p
		LDA	Temp
		EOR	#$FF
		AND	(LowPtr_Byte),Y
		JSR	Draw_Tile
		RTS
; End of function Draw_Destroyed_Brick


; ��������������� S U B	R O U T	I N E ���������������������������������������


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

; ���������������������������������������������������������������������������
		LDA	Temp		; �� �� �ᯮ������ �������
		ORA	($11),Y
		JSR	Draw_Tile
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������


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


; ��������������� S U B	R O U T	I N E ���������������������������������������


Save_to_VRAM:				; CODE XREF: Store_NT_Buffer_InVRAM:-p
		LDA	HighPtr_Byte
		CLC
		ADC	PPU_Addr_Ptr
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	LowPtr_Byte
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	(LowPtr_Byte),Y	; �����	��ࠧ��, ���ᨢ	RAM'a �뢮����� � Name Table,
					; � ��	�६� ��� ����࠭�⢮ ����⨢��� �����
					; $400-$7FF��������� ⮫쪮 ⠩����� ���⮩ ������ 'Battle City',
					; ��⠢������ �� ��௨祩
		STA	PPU_DATA	; �ᯮ������ �� �뢮�� ���쭨��
		RTS
; End of function Save_to_VRAM


; ��������������� S U B	R O U T	I N E ���������������������������������������


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


; ��������������� S U B	R O U T	I N E ���������������������������������������


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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����뢠�� ��	�࠭ ᮤ�ন��� NT_Buffer

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
		LDA	#4		; ������� ⠩����� ����� � RAM ��稭����� � $400
		STA	HighPtr_Byte

-:					; CODE XREF: Store_NT_Buffer_InVRAM+15j
		JSR	Save_to_VRAM
		LDA	#1
		JSR	Inc_Ptr_on_A
		LDA	HighPtr_Byte
		CMP	#8		; �� ��諨 �� �� �� �।��� ������ $400-$7FF?
		BNE	-
		RTS
; End of function Store_NT_Buffer_InVRAM


; ��������������� S U B	R O U T	I N E ���������������������������������������


Draw_GrayFrame:				; CODE XREF: Make_GrayFrame+Cp
		LDX	#0
		LDA	#$11		; $11 -	��� ⠩� � Pattern Table (ࠬ�� �ண� 梥�)

Fill_NTBuffer:				; CODE XREF: Draw_GrayFrame+11j
		STA	NT_Buffer,X
		STA	NT_Buffer+$100,X
		STA	NT_Buffer+$200,X
		STA	NT_Buffer+$300,X
		INX
		BNE	Fill_NTBuffer
		LDA	#0		; ���� �࠭ �ᯮ����	0-� �������.
		LDX	#$C0		; ��᫥���� $40	���� Name Table	�⤠�� ��� ��ਡ���

Fill_NTAttribBuffer:			; CODE XREF: Draw_GrayFrame+1Bj
		STA	NT_Buffer+$300,X
		INX
		BNE	Fill_NTAttribBuffer
		LDX	Block_X
		LDY	Block_Y
		JSR	CoordTo_PPUaddress
		STA	HighPtr_Byte
		STY	LowPtr_Byte	; ��稭��� �ᮢ��� �୮� ��஢�� ����	�� �࠭��� ࠬ��, � �� �࠭�.

Draw_BlackRow:				; CODE XREF: Draw_GrayFrame+3Bj
		LDY	Counter2
		DEY

--:					; CODE XREF: Draw_GrayFrame+30j
		LDA	#0		; ���� ���⮩	⠩� ��஢��� ����
		STA	(LowPtr_Byte),Y
		DEY			; ������塞 ���� ���	⠩��� �ࠢ� ������
		BPL	--		; ���� ���⮩	⠩� ��஢��� ����
		DEC	Counter
		BEQ	+
		LDA	#$20 ; ' '      ; ���室�� � ᫥���饬� ��� ⠩���
		JSR	Inc_Ptr_on_A
		JMP	Draw_BlackRow
; ���������������������������������������������������������������������������

+:					; CODE XREF: Draw_GrayFrame+34j
		RTS
; End of function Draw_GrayFrame


; ��������������� S U B	R O U T	I N E ���������������������������������������


Draw_TSABlock:				; CODE XREF: Draw_TSA_On_Tank+8p
					; Make_Respawn+51p Load_Level+58p
		PHA
		STA	Temp
		JSR	XnY_div_8	; �����	�� 8 Y � X
		STX	Spr_X
		STY	Spr_Y
		LDY	Temp
		LDA	TSABlock_PalNumber,Y
		STA	TSA_Pal
		LDY	Spr_Y
		JSR	AttribToScrBuffer ; �����㥬 ��ਡ��� �� NT_Buffer �� �࠭
		LDA	Spr_Y
		AND	#$FE
		TAY
		LDA	Spr_X
		AND	#$FE ; '�'
		TAX
		JSR	CoordsToRAMPos
		PLA
		ASL	A
		ASL	A		; �������� �� 4	(�� ������⢮ ⠩��� �	����� �����)
		TAX
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		LDA	#1		; ���室�� �� ⠩� �ࠢ��
		JSR	Inc_Ptr_on_A
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		LDA	#$1F		; ���� ��ப� Name Table ࠧ��஬ � $20	⠩���
					; �.�. ���室�� �� ��ப� ����	� �� ⠩� �����
		JSR	Inc_Ptr_on_A
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		LDA	#1		; ���室�� �� ⠩� �ࠢ��
		JSR	Inc_Ptr_on_A
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		RTS
; End of function Draw_TSABlock


; ��������������� S U B	R O U T	I N E ���������������������������������������


Draw_Char:				; CODE XREF: Draw_BrickStr+14p
		STX	BrickChar_X
		TAX
		TYA
		CLC
		ADC	#$20 ; ' '
		STA	BrickChar_Y
		LDA	#0
		STA	LowPtr_Byte	; ���⪠ ����襣� ���� 㪠��⥫�
		LDA	#$10
		STA	HighPtr_Byte	; ��⠭���� ���襣� ����, �⮡�
					; ���쭥�襥 �⥭�� �ந���������
					; �� ��ண� ������������ (�����
					; ��⠭����� ��� ���㭤�)

Add_10:					; CODE XREF: Draw_Char+19j
		DEX			; ��������� ASCII ���� �㪢� ��	$10
		BMI	+
		LDA	#$10
		JSR	Inc_Ptr_on_A
		JMP	Add_10		; ��᫥	�����襭�� �⮩	��楤�ન
					; �᫮��� ���室�� � Ptr_Byte	�㤥�
					; ��� �㪢� � ASCII*$10+$1000;
					; ���ਬ��, ���	A=$41: $1410
; ���������������������������������������������������������������������������

+:					; CODE XREF: Draw_Char+12j
		LDA	HighPtr_Byte
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	LowPtr_Byte
		STA	PPU_ADDRESS	; ��⠭���� 㪠��⥫� �� �⥭��
					; �� ������ ��ண� ������������
					;
		LDA	PPU_DATA	; ��ࢮ� �⥭��	�� PPU "�������쭮"
		LDA	#8
		STA	Counter

Read_CHRByte:				; CODE XREF: Draw_Char+33j
		LDA	PPU_DATA	; VRAM I/O Register (RW)
		PHA
		DEC	Counter
		BNE	Read_CHRByte	; ��⠥� ��ᥬ�	���� ��	������
					; Pattern Table, �� ᮮ⢥����� ����
					; � �⥪ ��䨪� �⤥�쭮� �㪢� �
					; �ଠ� 1bpp
					;
					;
		LDA	#8
		STA	Counter		; 8 ࠧ	�㤥� ���� ��	�⥪� ��䨪�

NextByte:				; CODE XREF: Draw_Char+71j
		PLA
		STA	CHR_Byte
		LDA	#$80 ; '�'
		STA	Mask_CHR_Byte

Next_Bit:				; CODE XREF: Draw_Char+5Fj
		LDX	BrickChar_X	; ᭠砫� � $005D �ᥣ�� $1A
		LDY	BrickChar_Y	; ᭠砫� � $005e �ᥣ�� $2e+$20=$4E
		JSR	Get_SprCoord_InTiles ; ��ॢ���� SPR_XY	� ⠩��
		LDA	CHR_Byte
		AND	Mask_CHR_Byte
		BEQ	Empty_Pixel	; ��� ���ᥫ� ����
		JSR	NT_Buffer_Process_OR
		JMP	++
; ���������������������������������������������������������������������������

Empty_Pixel:				; CODE XREF: Draw_Char+4Bj
		JSR	NT_Buffer_Process_XOR ;	��� ���ᥫ� ����

++:					; CODE XREF: Draw_Char+50j
		LDA	BrickChar_X
		CLC
		ADC	#4
		STA	BrickChar_X
		LSR	Mask_CHR_Byte	; ���室�� � ᫥���饬� ����
		BCC	Next_Bit	; ᭠砫� � $005D �ᥣ�� $1A
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


; ��������������� S U B	R O U T	I N E ���������������������������������������


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
		LDA	(LowStrPtr_Byte),Y ; ��ਭ�� ����㦠����
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
		JMP	New_Char	; ��ਭ�� ����㦠����
; ���������������������������������������������������������������������������

EOS:					; CODE XREF: Draw_BrickStr+8j
		RTS
; End of function Draw_BrickStr


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ������� ����᪨�㥬��� ���뢠���

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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� �� Screen_Buffer � ������ PPU

Update_Screen:				; CODE XREF: ROM:D413p
		LDX	ScrBuffer_Pos
		LDA	#0
		STA	Screen_Buffer,X
		TAX

-:					; CODE XREF: Update_Screen+27j
		CPX	ScrBuffer_Pos	; ���⨣��� �� ����� ��ப�����	�����?
		BEQ	Update_Screen_End
		LDA	Screen_Buffer,X
		INX
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	Screen_Buffer,X
		INX
		STA	PPU_ADDRESS	; � ��砫� ������ ��ப� � Screen_Buffer ����
					; hi/lo	����,	�㤠 �㤥� ������ ������

--:					; CODE XREF: Update_Screen+2Fj
		LDA	Screen_Buffer,X
		INX
		CMP	#$FF		; �஢�ઠ �� ����� ��ப�
		BNE	++		; �����।�⢥��� ������ � ������ PPU
		LDA	Screen_Buffer,X
		CMP	#$FF
		BNE	-		; ���⨣��� �� ����� ��ப�����	�����?
		LDA	$17F,X

++:					; CODE XREF: Update_Screen+20j
		STA	PPU_DATA	; �����।�⢥��� ������ � ������ PPU
		JMP	--
; ���������������������������������������������������������������������������

Update_Screen_End:			; CODE XREF: Update_Screen+Aj
		LDA	#0
		STA	ScrBuffer_Pos
		RTS
; End of function Update_Screen


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��⠭���� 㪠��⥫� �� ���㫥��� ����� ��ப�

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
		JMP	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
; ���������������������������������������������������������������������������

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
		STA	HighPtr_Byte	; ��ப� �ᯮ�������� � �।���� �㫥���
					; ��࠭��� RAM - ���訩 ���� �ᥣ�� ࠢ�� 0
		STY	LowPtr_Byte	; ������ 㪠��⥫� ������ ���� ���㫥��� ����� ��ப�
		RTS
; End of function PtrToNonzeroStrElem


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �뢮��� �� �࠭ ���� ४�ठ

Draw_RecordDigit:			; CODE XREF: Draw_Record_HiScore+23p
		LDA	#$10
		STA	Block_X
		LDA	#$64 ; 'd'
		STA	Block_Y
		LDA	#$30 ; '0'      ; ��砫� ��䨪� ���
		STA	Char_Index_Base
		LDY	#HiScore_String

-:					; CODE XREF: Draw_RecordDigit+1Bj
		LDA	0,Y
		BNE	+
		INY
		LDA	Block_X
		CLC
		ADC	#$20 ; ' '      ; $20 ⠩��� � ����� ��ப�
		STA	Block_X
		JMP	-
; ���������������������������������������������������������������������������

+:					; CODE XREF: Draw_RecordDigit+11j
		LDA	#0
		STA	HighStrPtr_Byte
		STY	LowStrPtr_Byte
		JSR	Draw_BrickStr
		LDA	#0
		STA	Char_Index_Base
		RTS
; End of function Draw_RecordDigit


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �� ��室� A =	$FF, ����� ���� ४��

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
; ���������������������������������������������������������������������������

loc_D98F:				; CODE XREF: Update_HiScore+8j
		BMI	loc_D99E
		LDX	#0		; �� �믮�������

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
; ���������������������������������������������������������������������������

loc_D9AE:				; CODE XREF: Update_HiScore+27j
		BMI	locret_D9BD
		LDX	#0		; �� �믮�������

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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �ਡ����� �᫮ �� NumString	� �窠�	��ப� ��

Add_Score:				; CODE XREF: Draw_Pts_Screen+62p
					; Draw_Pts_Screen+80p
					; Draw_Pts_Screen+16Fp
					; Draw_Pts_Screen+1CAp
					; BulletToTank_Impact_Handle+118p
					; Bonus_Handle+4Bp
;! �� �ਡ���塞 �窨, �᫨ ����� ��� �ࠣ.
		CPX	#2
		BCS	+++
		TXA
		ASL	A
		ASL	A
		ASL	A		; �������� �� $10
		CLC
		ADC	#6
		TAX
		LDY	#6
		CLC

-:					; CODE XREF: Add_Score+20j
		LDA	Num_String,Y
		ADC	HiScore_1P_String,X
		CMP	#$A		; �᫨ > 10, �	���室�� � ᫥���騩 ࠧ��
		BMI	+
		SEC
		SBC	#$A
		SEC
		JMP	++
; ���������������������������������������������������������������������������

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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ॢ���� �᫮ �� � � ��ப�	NumString

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
		BEQ	+		; �᫨ ��।����� 0, ���⠢�塞	1000 �窮�
		AND	#$F
		STA	Num_String+5
		LDA	Temp
		LSR	A
		LSR	A
		LSR	A
		LSR	A
		STA	Num_String+4
		RTS
; ���������������������������������������������������������������������������

+:					; CODE XREF: Num_To_NumString+9j
		LDA	#1		; �᫨ ��।����� 0, ���⠢�塞	1000 �窮�
		STA	Num_String+3	; ���室�� � ᫥���騩	ࠧ��
		RTS
; End of function Num_To_NumString


; ��������������� S U B	R O U T	I N E ���������������������������������������


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


; ��������������� S U B	R O U T	I N E ���������������������������������������


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
		CMP	#10		; ��᫠	�࠭���� � �����筮� ��⥬� -	���� ���� 0-9.
					; �᫨ �᫮ >=	10, � ������ ��ன ����.
		BCC	loc_DA28
		SEC
		SBC	#10
		INC	Num_String+5
		JMP	Check_Max	; ��᫠	�࠭���� � �����筮� ��⥬� -	���� ���� 0-9.
					; �᫨ �᫮ >=	10, � ������ ��ன ����.
; ���������������������������������������������������������������������������

loc_DA28:				; CODE XREF: ByteTo_Num_String+Bj
		STA	Num_String+6
		RTS
; End of function ByteTo_Num_String


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����뢠�� � �ࠩ⮢� ����� ���� �ࠩ� 8�16

SaveSprTo_SprBuffer:			; CODE XREF: Draw_Pause+1Ap
					; Draw_Pause+25p Draw_Pause+30p
					; Draw_Pause+3Bp Draw_Pause+46p
					; Indexed_SaveSpr+Bp Draw_WholeSpr+9p
					; Draw_WholeSpr+14p
		TXA
; � X �	Y ���न���� �뢮������	�ࠩ�
		STA	Spr_X
		CLC
		ADC	#3
		TAX
		TYA
		SEC
		SBC	#8
		STA	Spr_Y
		JSR	GetCoord_InTiles ; ��ॢ���� ��	���न��� � ���ᥫ�� � ���न���� � ⠩���
		LDA	(LowPtr_Byte),Y
		CMP	#$22 ; '"'      ; �஢�ઠ �� ����祭�� �ࠩ� ⠭�� � ��ᮬ: $22 � Pattern Table - ⠩� ���
					; � ��ਡ�� �ࠩ� � �⮬ ��砥 ��� p = Background Priority
					; ������ ���� ���⠢���	� 1
		BNE	Skip_Attrib
		LDA	TSA_Pal
		ORA	Spr_Attrib
		STA	TSA_Pal		; ������塞 � �����ࠬ �� � ��ਡ���

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
		ADC	Gap		; ���室�� � ᫥���饬� �ࠩ��
		STA	SprBuffer_Position
		RTS
; End of function SaveSprTo_SprBuffer


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����뢠�� � SprBuffer �ࠩ�	8�16 �	ᬥ饭��� � �

Indexed_SaveSpr:			; CODE XREF: ROM:E10Ep
		ASL	A
		CLC
		ADC	Spr_TileIndex
		STA	Spr_TileIndex
		TXA
		SEC
		SBC	#5
		TAX
		JSR	SaveSprTo_SprBuffer ; ����뢠�� � �ࠩ⮢� ����� ���� �ࠩ� 8�16
		RTS
; End of function Indexed_SaveSpr


; ��������������� S U B	R O U T	I N E ���������������������������������������

; Spr_TileIndex	+ (A * 8)

Spr_TileIndex_Add:			; CODE XREF: ROM:DFFFp
		ASL	A
		ASL	A
		ASL	A
		CLC
		ADC	Spr_TileIndex
		STA	Spr_TileIndex
; End of function Spr_TileIndex_Add


; ��������������� S U B	R O U T	I N E ���������������������������������������

; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)

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
		SBC	#8		; C��頥��� �� ⠩� �����
		TAX
		JSR	SaveSprTo_SprBuffer ; ����뢠�� � �ࠩ⮢� ����� ���� �ࠩ� 8�16
		INC	Spr_TileIndex
		INC	Spr_TileIndex	; � Pattern Table ⠩��	�ࠩ⮢ �࠭���� � Raw	Interleaved
					; �ଠ�:
					;
					;		     13
					;		     24
					;
					; �� ���᫮����� ⥬, �� PPU ࠡ�⠥�	� ०��� ⠩���,
					; ࠧ��୮���� 8�16. � ���� ����� �ᥤ���� ⠩���� � ����� ����� �� ����
					; ⠩� - ���⮬� 㢥��稢��� ������ �� 2
		LDX	Temp_X		; ����⠭�������� � - ���室��	�� ⠩�	�ࠢ��
		LDY	Temp_Y
		JSR	SaveSprTo_SprBuffer ; ����뢠�� � �ࠩ⮢� ����� ���� �ࠩ� 8�16
		RTS
; End of function Draw_WholeSpr


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �뢮�	Y ���न��� �ࠩ⮢ � $F0

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
		ADC	Gap		; ��������� ��稭��� � ����
		TAX
		LDA	#$F0 ; '�'
		STA	SprBuffer,X
		CPX	#4
		BNE	-
		STX	SprBuffer_Position
		RTS
; End of function Spr_Invisible


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �᫨ >0 �����頥� $1. <0 �����頥� $FF

Relation_To_Byte:			; CODE XREF: Load_AI_Status+5p
					; Load_AI_Status+12p
		BEQ	End_RelationToByte
		BCS	+
		LDA	#$FF
		JMP	End_RelationToByte
; ���������������������������������������������������������������������������

+:					; CODE XREF: Relation_To_Byte+2j
		LDA	#1

End_RelationToByte:			; CODE XREF: Relation_To_Bytej
					; Relation_To_Byte+6j
		RTS
; End of function Relation_To_Byte

; ���������������������������������������������������������������������������
TSABlock_PalNumber:.BYTE 0, 0, 0, 0, 0,	3, 3, 3, 3, 3, 1, 2, 3,	0, 0, 0
					; DATA XREF: Draw_TSABlock+Cr
;������� �� ����� TSA ���� (�ᥣ� 16)
;00 - 梥� ��௨祩
;01 - 梥� ����
;02 - 梥� ���
;03 - 梥� �஭�
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
;����ন� ������� ⠩��� �� ����� TSA ����.
;���ਬ��, ����	�줠 (�� ����� $0C) c���ন� �� 4
;⠩�� � �����ᠬ� $21 (⠩� � ⠪�� �����ᮬ �
;Pattern Table - �� ⠩� �줠)
;
;������� ᫥�����:
;1 2
;3 4
;
;16 ��������� TSA ������.�� ��᫥���� TSA ����� �����	(�� ����� $0D-$0F)


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠥ� � ���� ��� �������� ����� �㦭�

Play_Snd_Move:				; CODE XREF: Battle_Loop+2Dp
		LDA	Snd_Move
		BEQ	No_MoveSound	; ���� ��ப
		LDX	#0		; ���� ��ப
		JSR	Detect_Motion	; �᫨ ⠭� ������ ���������, 1
		BNE	End_Play_Snd_Move
		LDX	#1		; ��ன ��ப
		JSR	Detect_Motion	; �᫨ ⠭� ������ ���������, 1
		BNE	End_Play_Snd_Move
		LDA	#0
		STA	Snd_Move	; ��ᨬ	��� ��������
		RTS
; ���������������������������������������������������������������������������

No_MoveSound:				; CODE XREF: Play_Snd_Move+3j
		LDX	#0		; ���� ��ப
		JSR	Detect_Motion	; �᫨ ⠭� ������ ���������, 1
		BNE	+
		LDX	#1		; ��ன ��ப
		JSR	Detect_Motion	; �᫨ ⠭� ������ ���������, 1
		BEQ	End_Play_Snd_Move

+:					; CODE XREF: Play_Snd_Move+1Ej
		LDA	#1
		STA	Snd_Move	; ��ࠥ� ��� ��������

End_Play_Snd_Move:			; CODE XREF: Play_Snd_Move+Aj
					; Play_Snd_Move+11j Play_Snd_Move+25j
		RTS
; End of function Play_Snd_Move


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �᫨ ⠭� ������ ���������, 1

Detect_Motion:				; CODE XREF: Play_Snd_Move+7p
					; Play_Snd_Move+Ep Play_Snd_Move+1Bp
					; Play_Snd_Move+22p
		LDA	Joypad1_Buttons,X
		AND	#$F0 ; '�'
		BEQ	End_Detect_Motion ; �᫨ ������ �ࠢ����� �� ������, �����頥� ����
		LDA	Tank_Status,X
		BEQ	End_Detect_Motion ; �᫨ ⠭�� ���, �����頥� ����
		LDA	#1
		RTS
; ���������������������������������������������������������������������������

End_Detect_Motion:			; CODE XREF: Detect_Motion+4j
					; Detect_Motion+8j
		LDA	#0
		RTS
; End of function Detect_Motion


; ��������������� S U B	R O U T	I N E ���������������������������������������


Respawn_Handle:				; CODE XREF: Battle_Loop+1Bp
		LDA	Respawn_Timer	; �६�	�� ᫥���饣� �ᯠ㭠
		BEQ	+		; �᫨ �६� ᫥���饣�	�ᯠ㭠 �� ��諮, ��室��
		DEC	Respawn_Timer	; �६�	�� ᫥���饣� �ᯠ㭠
		RTS
; ���������������������������������������������������������������������������

+:					; CODE XREF: Respawn_Handle+2j
		LDA	Enemy_Reinforce_Count ;	������⢮ �ࠣ�� � �����
		BEQ	End_Respawn_Handle ; �᫨ �ࠣ�� � ����� �� ��⠫���, ��室��
		LDA	TanksOnScreen	; ���ᨬ��쭮� ������⢮ ��� ⠭��� �� �࠭�
		STA	Counter

-:					; CODE XREF: Respawn_Handle+2Aj
		LDX	Counter
		LDA	Tank_Status,X
		BNE	++		; ���㥬 �ᯠ�� ⥬ ⠭���, ������ 㦥 ��� �� �࠭�
		LDA	Respawn_Delay	; ����প� ����� �ᯠ㭠�� �ࠣ��
		STA	Respawn_Timer	; ����⠭�������� ⠩���
		JSR	Make_Respawn
		DEC	Enemy_Reinforce_Count ;	������⢮ �ࠣ�� � �����
		LDA	Enemy_Reinforce_Count ;	������⢮ �ࠣ�� � �����
		JSR	Draw_EmptyTile	; ����� ���⮩	⠩� � ������� ����ᮢ �ࠣ��, ����� ��� ��室��
		RTS
; ���������������������������������������������������������������������������

++:					; CODE XREF: Respawn_Handle+13j
		DEC	Counter
		LDA	Counter
		CMP	#1		; �� ��ࠡ��뢠�� �����	��ப��
		BNE	-

End_Respawn_Handle:			; CODE XREF: Respawn_Handle+9j
		RTS
; End of function Respawn_Handle


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �믮���� ᪮�즥���,	�᫨ ⠭� ��������� �� ���

Ice_Move:				; CODE XREF: Battle_Loop+3p
		LDA	Frame_Counter
		AND	#1
		BNE	+		; ��ࠡ��뢠�� ⮫쪮 ��ப��
		LDA	Frame_Counter
		AND	#3
		BNE	End_Ice_Move	; ������, �� �ந������� ��ࠡ��� �� ������ 4-� �३��:
					; �.�. �᫨ ����� �३�� 2, 4, 10, 14, 18

+:					; CODE XREF: Ice_Move+4j
		LDX	#1		; ��ࠡ��뢠�� ⮫쪮 ��ப��

-:					; CODE XREF: Ice_Move+79j
		LDA	Tank_Status,X
		BPL	++++++		; �᫨ ⠭� ���ࢠ�, ���室�� � ᫥���饬�
		CMP	#$E0 ; '�'
		BCS	++++++		; �᫨ ⠭� ��஦������, ���室�� � ᫥���饬�
		LDA	Player_Blink_Timer,X ; ������ ������� friendly fire
		BEQ	+++++
		DEC	Player_Blink_Timer,X ; ������ ������� friendly fire
		JMP	Usual_Tank
; ���������������������������������������������������������������������������

+++++:					; CODE XREF: Ice_Move+18j
		LDA	Player_Ice_Status,X
		BPL	++++		; ���� ⠭� �� �� ���,	����
					; �� �����稫 �������
		AND	#$10
		BNE	Usual_Tank

++++:					; CODE XREF: Ice_Move+22j
		LDA	Joypad1_Buttons,X ; ���� ⠭� �� �� ���, ����
					; �� �����稫 �������
		JSR	Button_To_DirectionIndex ; $FF = ������	�ࠢ����� �� ������
		STA	Temp
		BPL	loc_DBB4

Usual_Tank:				; CODE XREF: Ice_Move+1Cj Ice_Move+26j
		LDA	#$80 ; '�'
		JSR	Rise_TankStatus_Bit ; Tank_Status OR �
		LDA	#8
		ORA	Tank_Status,X
		STA	Tank_Status,X
		JMP	++++++		; ���室�� � ᫥���饬� ⠭��
; ���������������������������������������������������������������������������

loc_DBB4:				; CODE XREF: Ice_Move+2Fj
		LDA	Player_Ice_Status,X
		BPL	++
		AND	#$1F
		BNE	++		; �᫨ ⠩��� ᪮�즥��� ��
					; ���稫��, �� ����⠭�������� ���
		LDA	#$9C		; $1c �३��� �㤥� ᪮�짨�� ⠭�
		STA	Player_Ice_Status,X
		LDA	#1
		STA	Snd_Ice		; �ந��뢠�� ��� ᪮�즥���

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
		AND	#$F8 ; '�'
		STA	Tank_X,X
		LDA	Tank_Y,X
		CLC
		ADC	#4
		AND	#$F8 ; '�'
		STA	Tank_Y,X

+++:					; CODE XREF: Ice_Move+58j Ice_Move+5Ej
		LDA	Temp
		ORA	#$A0
		STA	Tank_Status,X

++++++:					; CODE XREF: Ice_Move+10j Ice_Move+14j
					; Ice_Move+3Cj
		DEX			; ���室�� � ᫥���饬� ⠭��
		BPL	-

End_Ice_Move:				; CODE XREF: Ice_Move+Aj
					; DATA XREF: ROM:HQExplode_JumpTableo
					; ROM:TankStatus_JumpTableo
					; ROM:TankDraw_JumpTableo
					; ROM:Bullet_Status_JumpTableo
					; ROM:BulletGFX_JumpTableo
		RTS			; �����頥��� �� RTS
; End of function Ice_Move


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����ࠦ����� �ࠣ��, �᫨ �㦭� (��ࠡ�⪠ ��������)

Motion_Handle:				; CODE XREF: Battle_Loop+6p
		LDA	#7
		STA	Counter		; �ᥣ�	�������� 8 ⠭���
		LDA	EnemyFreeze_Timer
		BEQ	Skip_TimerOps
		LDA	Frame_Counter
		AND	#63		; ������ ᥪ㭤� 㬥��蠥� ⠩��� ����஧��
		BNE	Skip_TimerOps
		DEC	EnemyFreeze_Timer

Skip_TimerOps:				; CODE XREF: Motion_Handle+7j
					; Motion_Handle+Dj Motion_Handle+49j
		LDX	Counter
		CPX	#2
		BCS	Enemy		; �᫨ > 2, � �� �ࠣ
		LDA	Frame_Counter
		AND	#1
		BNE	JumpToStatusHandle
		LDA	Frame_Counter
		AND	#3
		BNE	Motion_Handle_Next ; ��ࠡ��뢠�� ������ �
					; ��।������ �३��
		JMP	JumpToStatusHandle
; ���������������������������������������������������������������������������

Enemy:					; CODE XREF: Motion_Handle+16j
		LDA	EnemyFreeze_Timer
		BEQ	+
		LDA	Tank_Status,X
		BPL	+
		CMP	#$E0 ; '�'
		BCC	Motion_Handle_Next

+:					; CODE XREF: Motion_Handle+2Aj
					; Motion_Handle+2Ej
		LDA	Tank_Type,X
		AND	#$F0 ; '�'
		CMP	#$A0		; � ���	(�ࠣ �2) ����� ��ࠡ��뢠����	� 2
					; ࠧ� ��, ���⮬� ��	����॥	�����
		BEQ	JumpToStatusHandle
		LDA	Counter
		EOR	Frame_Counter
		AND	#1
		BEQ	Motion_Handle_Next

JumpToStatusHandle:			; CODE XREF: Motion_Handle+1Cj
					; Motion_Handle+24j Motion_Handle+3Aj
		JSR	Status_Core	; �믮���� ������� jumptable �	����ᨬ��� �� �����

Motion_Handle_Next:			; CODE XREF: Motion_Handle+22j
					; Motion_Handle+32j Motion_Handle+42j
		DEC	Counter
		BPL	Skip_TimerOps
		RTS
; End of function Motion_Handle


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �믮���� ������� jumptable �	����ᨬ��� �� �����

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

; ���������������������������������������������������������������������������

Misc_Status_Handle:			; DATA XREF: ROM:E4A8o
		CPX	#2		; ��ࠡ��뢠�� ������ �줠, ������ �४� � �.�.
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
; ���������������������������������������������������������������������������

LoadStts_Misc_Status_Handle:		; CODE XREF: ROM:DC54j	ROM:DC59j
					; ROM:DC5Dj
		LDA	Tank_Status,X
		SEC
		SBC	#4
		STA	Tank_Status,X
		AND	#$C
		BNE	End_Misc_Status_Handle
		LDA	#Tank_Status
		JSR	Rise_TankStatus_Bit ; Tank_Status OR �

End_Misc_Status_Handle:			; CODE XREF: ROM:DC74j
		RTS
; ���������������������������������������������������������������������������

Check_TileReach:			; DATA XREF: ROM:E4ACo
		CPX	#2		; �஢���� � �ࠣ�, ���⨣ �� �� ����	⠩��
		BCC	Check_Obj
		LDA	Tank_X,X
		AND	#7
		BNE	Check_Obj
		LDA	Tank_Y,X
		AND	#7
		BNE	Check_Obj
		JSR	Get_Random_A	; ����,	� � ��砩��� �᫮
		AND	#$F
		BNE	Check_Obj
		JSR	Get_RandomDirection ; ����砥� ��砩��� ���ࠢ����� � ��࠭�� � �����
		RTS
; ���������������������������������������������������������������������������

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
		JSR	Compare_Block_X	; �ࠢ������ � � BlockX	� �᫨ �����, ���⠥�	1
		TAX
		LDA	Block_Y
		CLC
		ADC	byte_58
		CLC
		ADC	byte_59
		JSR	Compare_Block_Y	; �ࠢ������ � � BlockY	� �᫨ �����, ���⠥�	1
		TAY
		JSR	GetCoord_InTiles ; � � � Y �� ��室� ���न����	� ⠩���
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
		JSR	Compare_Block_X	; �ࠢ������ � � BlockX	� �᫨ �����, ���⠥�	1
		TAX
		LDA	Block_Y
		CLC
		ADC	byte_59
		SEC
		SBC	byte_58
		JSR	Compare_Block_Y	; �ࠢ������ � � BlockY	� �᫨ �����, ���⠥�	1
		TAY
		JSR	GetCoord_InTiles ; � � � Y �� ��室� ���न����	� ⠩���
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
; ���������������������������������������������������������������������������

GetRnd_CheckObj:			; CODE XREF: ROM:DCD7j	ROM:DCDDj
					; ROM:DCFCj ROM:DD02j
		LDX	Counter
		CPX	#2
		BCC	TrackHandle_CheckObj
		JSR	Get_Random_A	; ����,	� � ��砩��� �᫮
		AND	#3
		BEQ	CheckTile_Check_Obj
		LDA	#$80 ; '�'
		JSR	Rise_TankStatus_Bit ; Tank_Status OR �
		LDA	#8
		ORA	Tank_Status,X
		STA	Tank_Status,X

TrackHandle_CheckObj:			; CODE XREF: ROM:DD0Ej	ROM:DD15j
		LDA	Track_Pos,X
		EOR	#4
		STA	Track_Pos,X
		RTS
; ���������������������������������������������������������������������������

CheckTile_Check_Obj:			; CODE XREF: ROM:DD1Cj
		LDA	Tank_X,X
		AND	#7
		BNE	Change_Direction_Check_Obj
		LDA	Tank_Y,X
		AND	#7
		BNE	Change_Direction_Check_Obj
		LDA	#$90 ; '�'
		JSR	Rise_TankStatus_Bit ; Tank_Status OR �

Change_Direction_Check_Obj:		; CODE XREF: ROM:DD34j	ROM:DD3Aj
		LDA	Tank_Status,X
		EOR	#2
		STA	Tank_Status,X
		RTS
; ���������������������������������������������������������������������������

Get_RandomStatus:			; DATA XREF: ROM:E4AAo
		JSR	Get_Random_A	; � �᭮����, ����砥� ��砩�� �����
		AND	#1
		BEQ	End_Get_RandomStatus
		JSR	Get_Random_A	; ����,	� � ��砩��� �᫮
		AND	#1
		BEQ	Sbc_Get_RandomStatus
		LDA	Tank_Status,X
		CLC
		ADC	#1		; ���塞 ���ࠢ����� ��	����襥
		JMP	Save_Get_RandomStatus ;	�뤥�塞 ���ࠢ����� � ��࠭塞 ��� � �����
; ���������������������������������������������������������������������������

Sbc_Get_RandomStatus:			; CODE XREF: ROM:DD54j
		LDA	Tank_Status,X
		SEC
		SBC	#1		; ���塞 ���ࠢ����� ��	����襥

Save_Get_RandomStatus:			; CODE XREF: ROM:DD5Bj
		AND	#3		; �뤥�塞 ���ࠢ����� � ��࠭塞 ��� � �����
		ORA	#Tank_Status
		STA	Tank_Status,X
		RTS
; ���������������������������������������������������������������������������

End_Get_RandomStatus:			; CODE XREF: ROM:DD4Dj
		JSR	Get_RandomDirection ; ����砥� ��砩��� ���ࠢ����� � ��࠭�� � �����
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������

; �ࠢ������ � � BlockX	� �᫨ �����, ���⠥�	1

Compare_Block_X:			; CODE XREF: ROM:DCC2p	ROM:DCE7p
		CMP	Block_X
		BCC	+
		SEC
		SBC	#1

+:					; CODE XREF: Compare_Block_X+2j
		RTS
; End of function Compare_Block_X


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �ࠢ������ � � BlockY	� �᫨ �����, ���⠥�	1

Compare_Block_Y:			; CODE XREF: ROM:DCCEp	ROM:DCF3p
		CMP	Block_Y
		BCC	+
		SEC
		SBC	#1

+:					; CODE XREF: Compare_Block_Y+2j
		RTS
; End of function Compare_Block_Y

; ���������������������������������������������������������������������������

Aim_FirstPlayer:			; DATA XREF: ROM:E4B2o
		LDA	Tank_X		; ��⠭��������	� ����⢥ 楫�	�ࠣ� ��ண� ��ப�
		STA	AI_X_Aim
		LDA	Tank_Y
		STA	AI_Y_Aim
		JMP	Save_AI_ToStatus
; ���������������������������������������������������������������������������

Aim_ScndPlayer:				; DATA XREF: ROM:E4B0o
		LDA	Tank_X+1	; ��⠭��������	� ����⢥ 楫�	�ࠣ� ��ࢮ�� ��ப�
		STA	AI_X_Aim
		LDA	Tank_Y+1
		STA	AI_Y_Aim
		JMP	Save_AI_ToStatus
; ���������������������������������������������������������������������������

Aim_HQ:					; DATA XREF: ROM:E4AEo
		LDA	#$78 ; 'x'      ; ��⠭�������� � ����⢥ 楫���� ���न���� �⠡
		STA	AI_X_Aim
		LDA	#$D8 ; '�'
		STA	AI_Y_Aim

Save_AI_ToStatus:			; CODE XREF: ROM:DD86j	ROM:DD91j
		JSR	Load_AI_Status
		STA	Tank_Status,X
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������


Load_AI_Status:				; CODE XREF: Demo_AI+16p Demo_AI+2Cp
					; Demo_AI+42p Demo_AI+58p
					; ROM:Save_AI_ToStatusp
		LDA	AI_X_Aim
;����㦠�� ����� �� ⠡���� � ����ᨬ��� �� ����ﭨ� �� 楫�
		SEC
		SBC	Tank_X,X
		JSR	Relation_To_Byte ; �᫨	>0 �����頥� $1. <0 �����頥�	$FF
		CLC
		ADC	#1
		STA	AI_X_DifferFlag
		LDA	AI_Y_Aim
		SEC
		SBC	Tank_Y,X
		JSR	Relation_To_Byte ; �᫨	>0 �����頥� $1. <0 �����頥�	$FF
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
		BCS	Load_AIStatus_GetRandom	; �᫨ �� �ࠣ, ����砥� ��� ������� �� ��ࢮ�
					; ��� ��ன ��� � ����ᨬ��� �� ����
		TXA			; � ��ப� ����㦠�� ��	��ࢮ� ��� �� ��ன ���
					; ������ ⮫쪮 �� �६���
		ASL	A
		EOR	Seconds_Counter
		AND	#2
		BEQ	loc_DDE4
		JMP	LoadSecondPart
; ���������������������������������������������������������������������������

Load_AIStatus_GetRandom:		; CODE XREF: Load_AI_Status+25j
		JSR	Get_Random_A	; ����,	� � ��砩��� �᫮
		AND	#1
		BEQ	loc_DDE4

LoadSecondPart:				; CODE XREF: Load_AI_Status+2Fj
		LDA	#9
		CLC
		ADC	AI_X_DifferFlag	; ���室�� �� ����� ���� ⠡����
		TAY
		JMP	End_Load_AIStatus
; ���������������������������������������������������������������������������

loc_DDE4:				; CODE XREF: Load_AI_Status+2Dj
					; Load_AI_Status+37j
		LDY	AI_X_DifferFlag

End_Load_AIStatus:			; CODE XREF: Load_AI_Status+3Fj
		LDA	AI_Status,Y
		RTS
; End of function Load_AI_Status

; ���������������������������������������������������������������������������

Explode_Handle:				; DATA XREF: ROM:E49Ao	ROM:E49Co
					; ROM:E49Eo ROM:E4A0o	ROM:E4A2o
					; ROM:E4A4o ROM:E4A6o
		DEC	Tank_Status,X	; ��ࠡ��뢠�� ���� ⠭�� (㬥��蠥� �᫮ ������, GameOver...)
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
; ���������������������������������������������������������������������������

SkipRiseBit_Explode_Handle:		; CODE XREF: ROM:DDFBj
		ORA	#3

SaveStts_Explode_Handle:		; CODE XREF: ROM:DDFFj
		STA	Tank_Status,X
		RTS
; ���������������������������������������������������������������������������

Skip_Explode_Handle:			; CODE XREF: ROM:DDF7j
		STA	Tank_Status,X
		CPX	#2
		BCS	Dec_Enemy_Explode_Handle
		DEC	Player1_Lives,X
		BEQ	CheckHQ_Explode_Handle
		JSR	Make_Respawn
		RTS
; ���������������������������������������������������������������������������

Dec_Enemy_Explode_Handle:		; CODE XREF: ROM:DE0Bj
		DEC	Enemy_Counter	; ������⢮ �ࠣ�� �� �࠭� �	� �����
		RTS
; ���������������������������������������������������������������������������

CheckHQ_Explode_Handle:			; CODE XREF: ROM:DE0Fj
		LDA	HQ_Status	; 80=�⠡ 楫, �᫨ ���� � 㭨�⮦��
		CMP	#$80 ; '�'      ; �⠡ 楫? $80=楫
		BNE	End_Explode_Handle ; ���
		CPX	#1		; ��
		BEQ	Check1pLives_Explode_Handle
		LDA	Player2_Lives
		BEQ	End_Explode_Handle
		LDA	#3		; �᫨ ��ࢮ�� ��ப� 㦥 ���, � � ��ண� ��⠫��� �����,
					; Game Over �뫥���� ᫥�� ���ࠢ�
		STA	GameOverScroll_Type ; ��।���� ��� ��६�饭�� ������(0..3)
		LDA	#$20 ; ' '
		STA	GameOverStr_X
		JSR	Init_GameOver_Properties
		RTS
; ���������������������������������������������������������������������������

Check1pLives_Explode_Handle:		; CODE XREF: ROM:DE20j
		LDA	Player1_Lives
		BEQ	End_Explode_Handle
		LDA	#1		; �᫨ ��ண� ��ப� ���, � � ��ࢮ�� ��ப� ��⠫��� �����,
					; Game Over �뫥���� �ࠢ� ������
		STA	GameOverScroll_Type ; ��।���� ��� ��६�饭�� ������(0..3)
		LDA	#$C0 ; '�'
		STA	GameOverStr_X
		JSR	Init_GameOver_Properties

End_Explode_Handle:			; CODE XREF: ROM:DDF0j	ROM:DE1Cj
					; ROM:DE24j ROM:DE36j
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������


Init_GameOver_Properties:		; CODE XREF: ROM:DE30p	ROM:DE42p
		LDA	#$D
		STA	GameOverStr_Timer ; ���樠�����㥬 ⠩���
		LDA	#$D8 ; '�'      ; ��稭��� �뤢������� ᭨��
		STA	GameOverStr_Y
		LDA	#0
		STA	Frame_Counter
		RTS
; End of function Init_GameOver_Properties

; ���������������������������������������������������������������������������

Set_Respawn:				; DATA XREF: ROM:E4B6o
		INC	Tank_Status,X	; ��⠭��������	� ����� ��ᯠ�
		LDA	Tank_Status,X
		AND	#$F
		CMP	#$E
		BNE	End_Set_Respawn
		LDA	#$E0 ; '�'
		STA	Tank_Status,X

End_Set_Respawn:			; CODE XREF: ROM:DE5Dj
		RTS
; ���������������������������������������������������������������������������

Load_Tank:				; DATA XREF: ROM:E4B4o
		INC	Tank_Status,X	; ����㦠�� �㦭� ⨯ ������ ⠭��, �᫨ �㦭�
		LDA	Tank_Status,X
		AND	#$F
		CMP	#$E
		BNE	End_Load_Tank
		JSR	Load_New_Tank	; ����㦠�� �㦭� ⨯ ������ ⠭��

End_Load_Tank:				; CODE XREF: ROM:DE6Cj
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����砥� ��砩��� ���ࠢ����� � ��࠭�� � �����

Get_RandomDirection:			; CODE XREF: ROM:DC93p
					; ROM:End_Get_RandomStatusp
		LDA	Respawn_Delay	; ����প� ����� �ᯠ㭠�� �ࠣ��
		LSR	A
		LSR	A
		CMP	Seconds_Counter
		BCS	loc_DE7F
		LDA	#$B0 ; '�'
		JMP	loc_DEA2
; ���������������������������������������������������������������������������

loc_DE7F:				; CODE XREF: Get_RandomDirection+6j
		LSR	A
		CMP	Seconds_Counter
		BCC	loc_DE8E
		JSR	Get_Random_A	; ����,	� � ��砩��� �᫮
		AND	#3
		ORA	#$A0 ; '�'      ; ����砥� ��砩��� ���ࠢ����� �
					; ��⠭��������	ࠡ�稩	⠭�
		STA	Tank_Status,X
		RTS
; ���������������������������������������������������������������������������

loc_DE8E:				; CODE XREF: Get_RandomDirection+10j
		LDA	Tank_Status
		BEQ	loc_DE9B
		TXA
		AND	#1
		BEQ	loc_DEA0
		LDA	Tank_Status+1
		BEQ	loc_DEA0

loc_DE9B:				; CODE XREF: Get_RandomDirection+1Ej
		LDA	#$C0 ; '�'
		JMP	loc_DEA2
; ���������������������������������������������������������������������������

loc_DEA0:				; CODE XREF: Get_RandomDirection+23j
					; Get_RandomDirection+27j
		LDA	#$D0 ; '�'

loc_DEA2:				; CODE XREF: Get_RandomDirection+Aj
					; Get_RandomDirection+2Bj
		JSR	Rise_TankStatus_Bit ; Tank_Status OR �
		RTS
; End of function Get_RandomDirection


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠡ��뢠�� ������ ��� 8-�� ⠭���

TanksStatus_Handle:			; CODE XREF: ROM:C0F9p	ROM:C209p
					; ROM:C244p BonusLevel_ButtonCheck+12p
					; Title_Screen_Loop:+p
		LDA	#0
		STA	Counter

-:					; CODE XREF: TanksStatus_Handle+Fj
		LDX	Counter
		JSR	SingleTankStatus_Handle	; ��ࠡ��뢠�� ����� ������ ⠭��
		INC	Counter
		LDA	Counter
		CMP	#8		; �ᥣ�	�� �࠭� �����	���� 8 ⠭���
		BNE	-
		RTS
; End of function TanksStatus_Handle


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠡ��뢠�� ����� ������ ⠭��

SingleTankStatus_Handle:		; CODE XREF: TanksStatus_Handle+6p
		LDA	Tank_Status,X
		LSR	A
		LSR	A
		LSR	A		; ���ࠥ� �� ������ ��� (���ࠢ�����	�������� ⠭��)
		AND	#$FE ; '�'      ;  � ����塞 �⢥���, �⮡� ��஢���� �� 2
					; ��� ����襩襩 ����樨 � ⠡��� 㪠��⥫��	������.
					; �����	��ࠧ��	4 ��⠢���� �ᯮ��㥬�� ��� ����᭮�� ����
					; ���� ��� 16 ���������	������
		TAY
		LDA	TankDraw_JumpTable,Y
		STA	LowPtr_Byte
		LDA	TankDraw_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; End of function SingleTankStatus_Handle

; ���������������������������������������������������������������������������

Draw_Small_Explode2:			; DATA XREF: ROM:E4C2o	ROM:E4C4o
					; ROM:E4C6o
		LDA	#0		; ����뢠�� � Spr_Buffer 16�16	�ࠩ� ���뢠
		STA	Spr_Attrib
		LDA	Tank_Status,X
		PHA
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		PLA
		JSR	Draw_Bullet_Ricochet ; ����뢠�� � �ࠩ⮢� ����� 16�16 �ࠩ� ਪ���
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����뢠�� � �ࠩ⮢� ����� 16�16 �ࠩ� ਪ���

Draw_Bullet_Ricochet:			; CODE XREF: ROM:DEDAp	ROM:E11Ep
		LSR	A
;� � = Bullet_Status + $40
		LSR	A
		LSR	A
		LSR	A
		SEC
		SBC	#7
		EOR	#$FF
		CLC
		ADC	#1
		ASL	A
		ASL	A		; ����砥� ᬥ饭�� �� �㦭� ⠩� ਪ���

Draw_Ricochet:				; CODE XREF: ROM:DF2Bp	ROM:DF3Ep
		CLC			; �����।�⢥��� ���� ���� 16�16
		ADC	#$F1 ; '�'      ; ��砫� ��䨪� ਪ���
		STA	Spr_TileIndex
		LDA	#3
		STA	TSA_Pal
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)
		RTS
; End of function Draw_Bullet_Ricochet

; ���������������������������������������������������������������������������

Draw_Kill_Points:			; DATA XREF: ROM:E4BAo
		LDA	#0		; ����� �窨 �� ���� ���뢠 �ࠣ�
		STA	Spr_Attrib
		LDA	Tank_Type,X
		BEQ	Draw_PlayerKill	; �� 㡨��⢮ ��ப�, �窨 �� �����
		LDA	Tank_Type,X
		LSR	A
		LSR	A
		LSR	A
		AND	#$FC ; '�'
		SEC
		SBC	#$10
		CLC			; ��।��塞 ������⢮	�窮� �
					; ����ᨬ��� �� ⨯� 㡨⮣� �ࠣ�
		ADC	#$B9 ; '�'      ; ��砫� ��䨪� �窮�
		STA	Spr_TileIndex
		LDA	#3
		STA	TSA_Pal
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)
		JMP	Draw_Kill_Points_Skip
; ���������������������������������������������������������������������������

Draw_PlayerKill:			; CODE XREF: ROM:DF03j
		LDA	Tank_Y,X
		TAY
		LDA	Tank_X,X
		TAX
		LDA	#0
		JSR	Draw_Ricochet	; ���㥬 ᠬ� ���� ⨯ ���뢠

Draw_Kill_Points_Skip:			; CODE XREF: ROM:DF20j
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		RTS
; ���������������������������������������������������������������������������

Draw_Small_Explode1:			; DATA XREF: ROM:E4BCo
		LDA	#0		; ����	16�16
		STA	Spr_Attrib
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		LDA	#8
		JSR	Draw_Ricochet	; �����।�⢥��� ���� ���� 16�16
		LDA	#$20 ; ' '
		STA	Spr_Attrib	; ���� �� 䮭��	(��砩, ����� �ࠩ� ���ᥪ����� � ��ᮬ)
		RTS
; ���������������������������������������������������������������������������

Draw_Big_Explode:			; DATA XREF: ROM:E4BEo	ROM:E4C0o
		LDA	#3		; ����뢠�� � Spr_Buffer ����让 ����
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
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)
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
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)
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
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)
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
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������


Set_SprIndex:				; CODE XREF: ROM:DF4Ep	ROM:DF60p
					; ROM:DF72p ROM:DF84p
		LDX	Counter
		ASL	A
		ASL	A
		CLC
		ADC	#$D1 ; '�'
		STA	Temp
		LDA	Tank_Status,X
		AND	#$F0 ; '�'
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

; ���������������������������������������������������������������������������

OperatingTank:				; DATA XREF: ROM:E4C8o	ROM:E4CAo
					; ROM:E4CCo ROM:E4CEo	ROM:E4D0o
					; ROM:E4D2o
		CPX	#2		; �����।�⢥��� ��⠭��������	� Spr_Tile_Index �㦭�	⠭�
		BCC	OperTank_Player
		LDA	Tank_Type,X	; ���� �ࠦ�᪨�
		AND	#4		; �뤥�塞 䫠�	�����
		BEQ	OperTank_NotBonus
		LDA	Frame_Counter
		LSR	A
		LSR	A
		LSR	A
		AND	#1
		CLC
		ADC	#2
		JMP	OperTank_Draw	; ���ᯥ稢��� ᬥ�� ������� ��� ����᭮�� ⠭��
; ���������������������������������������������������������������������������

OperTank_NotBonus:			; CODE XREF: ROM:DFBEj
		LDA	Frame_Counter
		ASL	A
		ASL	A
		CLC
		ADC	Tank_Type,X
		AND	#7
		TAY			; ������ ������� ���	⥪�饣� ⠭��
		LDA	TankType_Pal,Y	; 8 ⨯�� ⠭��� �ᯮ����� ᮮ⢥�����騥 �ࠩ⮢� �������
		JMP	OperTank_Draw
; ���������������������������������������������������������������������������

OperTank_Player:			; CODE XREF: ROM:DFB8j
		LDA	Player_Blink_Timer,X ; ������ ������� friendly fire
		BEQ	OperTank_Skip
		LDA	Frame_Counter
		AND	#8		; ������� 4 ࠧ� � ᥪ㭤�
		BEQ	OperTank_Skip
		RTS
; ���������������������������������������������������������������������������

OperTank_Skip:				; CODE XREF: ROM:DFDFj	ROM:DFE5j
		TXA

OperTank_Draw:				; CODE XREF: ROM:DFCAj	ROM:DFDAj
		STA	TSA_Pal
		LDA	Tank_Status,X
		AND	#3
		PHA
		LDA	Tank_Type,X
		AND	#$F0 ; '�'
		CLC
		ADC	Track_Pos,X
		STA	Spr_TileIndex
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		PLA
		JSR	Spr_TileIndex_Add ; Spr_TileIndex + (A * 8)
		RTS
; ���������������������������������������������������������������������������
TankType_Pal:	.BYTE 2, 0, 0, 1, 2, 1,	2, 2 ; DATA XREF: ROM:DFD7r
					; 8 ⨯�� ⠭��� �ᯮ����� ᮮ⢥�����騥 �ࠩ⮢� �������
; ���������������������������������������������������������������������������

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
		AND	#$FC ; '�'
		CLC
		ADC	#$A1 ; '�'      ; C $A0 � Pattern Table ��稭����� ��䨪� �ᯠ㭠
		STA	Spr_TileIndex
		LDA	#3
		STA	TSA_Pal		; ��ᯠ� �㤥�	�� 03 ������
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠡ��뢠�� ������ ��� ���

AllBulletsStatus_Handle:		; CODE XREF: Battle_Loop+Cp
		LDA	#9
		STA	Counter		; ��ࠡ��뢠�� 10 ��� (8 + 2�������⥫���)

-:					; CODE XREF: AllBulletsStatus_Handle+Bj
		LDX	Counter
		JSR	BulletStatus_Handle ; ������� ������ �㫨 ���	�� ���ﭨ�
		DEC	Counter
		BPL	-
		RTS
; End of function AllBulletsStatus_Handle


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ������� ������ �㫨	��� �� ���ﭨ�

BulletStatus_Handle:			; CODE XREF: AllBulletsStatus_Handle+6p
		LDA	Bullet_Status,X
		LSR	A
		LSR	A
		LSR	A
		AND	#$FE ; '�'      ; 㡨ࠥ� �� ������ ��� � ����塞 �⢥���
		TAY
		LDA	Bullet_Status_JumpTable,Y
		STA	LowPtr_Byte
		LDA	Bullet_Status_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; End of function BulletStatus_Handle

; ���������������������������������������������������������������������������

Bullet_Move:				; DATA XREF: ROM:E4E0o
		LDA	Bullet_Status,X	; ������� ��� � ᮮ⢥��⢨� �	Bullet_Status
		AND	#3		; �뤥�塞 ���ࠢ�����
		TAY
		JSR	Change_BulletCoord ; ������� ���न���� �㫨 �	ᮮ⢥��⢨� � ���ࠢ������
		LDA	Bullet_Property,X ; ������� � �஭���������
		AND	#1
		BEQ	End_Bullet_Move	; �᫨ ���⠢��� 䫠�, ���塞 ���न���� ��� ࠧ�
		JSR	Change_BulletCoord ; ������� ���न���� �㫨 �	ᮮ⢥��⢨� � ���ࠢ������

End_Bullet_Move:			; CODE XREF: ROM:E05Dj
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������

; ������� ���न���� �㫨 � ᮮ⢥��⢨� � ���ࠢ������

Change_BulletCoord:			; CODE XREF: ROM:E056p	ROM:E05Fp
		LDA	Bullet_Coord_X_Increment_1,Y
;� Y ����� ���ࠢ�����
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

; ���������������������������������������������������������������������������

Make_Ricochet:				; DATA XREF: ROM:E4DAo	ROM:E4DCo
					; ROM:E4DEo
		DEC	Bullet_Status,X	; ����� �����	�㫨 ��� ������� ਪ���
		LDA	Bullet_Status,X	; �����蠥� ���稪 �३��� ������ ����
		AND	#$F
		BNE	End_Animate_Ricochet ; �᫨ ⥪�騩 ���� �� ��	���� ���������,	��室��
		LDA	Bullet_Status,X
		AND	#$F0 ; '�'
		SEC
		SBC	#$10		; ���室�� � ᫥���饬� ����� ਪ���
		BEQ	Skip_Animate_Ricochet
		ORA	#3		; 3 �३�� �㤥� ��ঠ���� ���� ����

Skip_Animate_Ricochet:			; CODE XREF: ROM:E085j
		STA	Bullet_Status,X

End_Animate_Ricochet:			; CODE XREF: ROM:E07Cj
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������

; ���᪠�� ��� (����� �� ����� � ᢮��⢠)

Make_Shot:				; CODE XREF: Make_Player_Shot:+p
					; Make_Enemy_Shot+16p
		LDA	Bullet_Status,X
		BNE	End_Make_Shot	; �᫨ ��� 㦥	���饭�, ��室��
		CPX	#2
		BCS	+		; ����५� �ࠣ�� �� �����
		LDA	#1
		STA	Snd_Shoot

+:					; CODE XREF: Make_Shot+6j
		LDA	Tank_Status,X
		AND	#3
		TAY
		ORA	#$40 ; '@'
		STA	Bullet_Status,X	; ���⠢�塞 � ����� �㫨 ���ࠢ�����
					; ⠭��	� ����� �����
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
		STA	Bullet_Y,X	; ��� ������	��� ⠭��
		LDA	#0
		STA	Bullet_Property,X ; ������� � �஭���������
		LDA	Tank_Type,X
		AND	#$F0 ; '�'
		BEQ	End_Make_Shot	; �᫨ ⠭� ���⮩, ��室�� �ࠧ�
		

		

		CMP	#$C0 ; '�'
		BEQ	QuickBullet_End_Make_Shot ; 6-�	⨯ ⠭�� (�ࠣ) �����	��५��
		CMP	#$60 ; '`'
		BEQ	++
		AND	#$80 ; '�'      ; �᫨ ⠭� ��ப� ������,
					; � ���� ������ �㫨
		BNE	End_Make_Shot

QuickBullet_End_Make_Shot:		; CODE XREF: Make_Shot+38j
		LDA	#1
		STA	Bullet_Property,X ; ������� � �஭���������
		RTS
; ���������������������������������������������������������������������������

++:					; CODE XREF: Make_Shot+3Cj
		LDA	#3
		STA	Bullet_Property,X ; �᫨ ��ப �⠫ ⠭��� ��᫥����� ⨯�,
					; � ���� ������ �஭������ �㫨

End_Make_Shot:				; CODE XREF: Make_Shot+2j
					; Make_Shot+34j Make_Shot+40j
		RTS
; End of function Make_Shot


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� �� �㫨

Draw_All_BulletGFX:			; CODE XREF: ROM:C206p	ROM:C247p
					; BonusLevel_ButtonCheck+15p
		LDA	#9
		STA	Counter		; 10 ���

-:					; CODE XREF: Draw_All_BulletGFX+Bj
		LDX	Counter
		JSR	Draw_BulletGFX	; ����� ��� �	����ᨬ��� �� �����
		DEC	Counter
		BPL	-
		RTS
; End of function Draw_All_BulletGFX


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� ��� �	����ᨬ��� �� �����

Draw_BulletGFX:				; CODE XREF: Draw_All_BulletGFX+6p
		LDA	Bullet_Status,X
		LSR	A
		LSR	A
		LSR	A
		AND	#$FE ; '�'
		TAY
		LDA	BulletGFX_JumpTable,Y
		STA	LowPtr_Byte
		LDA	BulletGFX_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; End of function Draw_BulletGFX

; ���������������������������������������������������������������������������

Draw_Bullet:				; DATA XREF: ROM:E4EAo
		LDA	Bullet_Status,X	; ����뢠�� � ����� �ࠩ� �㫨
		AND	#3
		PHA			; �뤥�塞 ���ࠢ�����
		LDY	Bullet_Y,X
		LDA	Bullet_X,X
		TAX
		LDA	#2
		STA	TSA_Pal
		LDA	#$B1 ; '�'      ; ��砫� ��䨪� �㫨
		STA	Spr_TileIndex
		PLA
		JSR	Indexed_SaveSpr	; ����뢠�� � SprBuffer �ࠩ�	8�16 �	ᬥ饭��� � �
		RTS
; ���������������������������������������������������������������������������

Update_Ricochet:			; DATA XREF: ROM:E4E4o	ROM:E4E6o
					; ROM:E4E8o
		LDA	Bullet_Status,X	; ����� ਪ��� � �㦭�� ����
		PHA
		LDY	Bullet_Y,X
		LDA	Bullet_X,X
		TAX
		PLA
		CLC
		ADC	#$40 ; '@'
		JSR	Draw_Bullet_Ricochet ; ����뢠�� � �ࠩ⮢� ����� 16�16 �ࠩ� ਪ���
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������

; ������ ����५ ��ப�, �᫨ ����� ������

Make_Player_Shot:			; CODE XREF: Battle_Loop+15p
		LDA	#1
;���뢠�� ᢮��⢮ ����᭮�� ⠭��
;��५��� ����	��ﬨ �����
		STA	Counter		; ��ࠡ��뢠�� ⮫쪮 ��ப��

-:					; CODE XREF: Make_Player_Shot+3Dj
		LDX	Counter
		LDA	Tank_Status,X
		BPL	Next_Jump_Make_Shot ; �᫨ ⠭�	���ࢠ�, �� ��ࠡ��뢠�� ���
		CMP	#$E0 ; '�'
		BCS	Next_Jump_Make_Shot ; �᫨ ⠭�	�ᯠ㭨���, ��	��ࠡ��뢠�� ���
		LDA	Joypad1_Differ,X
		AND	#11b
		BEQ	Next_Jump_Make_Shot ; �᫨ �� ����� ������ ����, �� ��ࠡ��뢠�� ��ப�
		LDA	Tank_Type,X
		AND	#$C0 ; '�'
		CMP	#$40 ; '@'
		BNE	+		; �᫨ ⠭� ��ப� �� ��ன ������,
					; ������ ���⮩ ����५
		LDA	Bullet_Status,X
		BEQ	+		; �᫨ �㫨 �� �࠭� ���,
					; ������ ���⮩ ����५
		LDA	Bullet_Status+8,X
		BNE	Next_Jump_Make_Shot ; �᫨ �������⥫쭠� ��� 㦥 ���饭�,
					; �� ���� �� ���᪠��
		LDA	Bullet_Status,X
		STA	Bullet_Status+8,X
		LDA	Bullet_X,X
		STA	Bullet_X+8,X
		LDA	Bullet_Y,X
		STA	Bullet_Y+8,X
		LDA	Bullet_Property,X ; ������� � �஭���������
		STA	Bullet_Property+8,X ; �����㥬 �� ᢮��⢠ �㫨 �
					; �祩�� ��� �������⥫쭮� �㫨
		LDA	#0
		STA	Bullet_Status,X

+:					; CODE XREF: Make_Player_Shot+1Aj
					; Make_Player_Shot+1Ej
		JSR	Make_Shot	; ���᪠�� ��� (����� �� ����� � ᢮��⢠)

Next_Jump_Make_Shot:			; CODE XREF: Make_Player_Shot+8j
					; Make_Player_Shot+Cj
					; Make_Player_Shot+12j
					; Make_Player_Shot+22j
		DEC	Counter
		BPL	-
		RTS
; End of function Make_Player_Shot


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �ந������ ����५, �ᯮ����	��砩�� �᫠

Make_Enemy_Shot:			; CODE XREF: Battle_Loop+18p
		LDA	EnemyFreeze_Timer
		BNE	End_Make_Enemy_Shot
		LDX	#7		; ��稭��� � ��ࢮ�� �ࠦ�᪮��	⠭��

loc_E169:				; CODE XREF: Make_Enemy_Shot+1Cj
		LDA	Tank_Status,X
		BPL	Next_Make_Enemy_Shot
		CMP	#$E0 ; '�'      ; �᫨ ⠭� ���ࢠ� ��� �ᯠ㭨���,
					; �� ��ࠡ��뢠�� ���
		BCS	Next_Make_Enemy_Shot
		JSR	Get_Random_A	; ����,	� � ��砩��� �᫮
		AND	#$1F
		BNE	Next_Make_Enemy_Shot
		JSR	Make_Shot	; ���᪠�� ��� (����� �� ����� � ᢮��⢠)

Next_Make_Enemy_Shot:			; CODE XREF: Make_Enemy_Shot+9j
					; Make_Enemy_Shot+Dj
					; Make_Enemy_Shot+14j
		DEX
		CPX	#1		; ��ப�� �� ��ࠡ��뢠��
		BNE	loc_E169

End_Make_Enemy_Shot:			; CODE XREF: Make_Enemy_Shot+3j
		RTS
; End of function Make_Enemy_Shot


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠡ��뢠�� ��ப�, �᫨ ��	�� ���

Ice_Detect:				; CODE XREF: Battle_Loopp
		LDA	#7
		STA	Counter		; �㤥�	��ࠡ�⠭� 8 ⠭���

-:					; CODE XREF: Ice_Detect+6Fj
		LDX	Counter
		LDA	Tank_Status,X	; �᫨ ⠭� ���ࢠ�, ��	��ࠡ��뢠�� ���
		BPL	Next_Tank
		CMP	#$E0 ; '�'
		BCS	Next_Tank	; �᫨ ⠭� ��஦������, �� ��ࠡ��뢠�� ���
		LDA	Tank_Y,X
		SEC
		SBC	#8
		TAY
		LDA	Tank_X,X
		SEC
		SBC	#8
		TAX
		JSR	GetCoord_InTiles ; � � � Y �� ��室� ���न����	� ⠩���
		LDX	Counter
		LDA	LowPtr_Byte
		STA	NTAddr_Coord_Lo,X
		LDA	HighPtr_Byte
		AND	#3
		STA	NTAddr_Coord_Hi,X
		LDY	#$21 ; '!'
		CPX	#2
		BCS	++		; �᫨ �� �ࠣ, ������ ᢮��⢠ �� ��ࠡ��뢠��
		LDA	(LowPtr_Byte),Y
		CMP	#$21 ; '!'      ; �஢�ઠ �� �� ��� ⠭��� (�⥭�� �� NT_Buffer)
		BNE	+
		LDA	#$80 ; '�'
		ORA	Player_Ice_Status,X
		STA	Player_Ice_Status,X ; ���⠢�塞 䫠� �줠
		JMP	++
; ���������������������������������������������������������������������������

+:					; CODE XREF: Ice_Detect+33j
		LDA	Player_Ice_Status,X
		AND	#$7F ; ''
		STA	Player_Ice_Status,X ; ���ࠥ� 䫠� �줠

++:					; CODE XREF: Ice_Detect+2Dj
					; Ice_Detect+3Dj
		JSR	Rise_Nt_HighBit	; ��c⠢��� ���訩 ��� � ������ ⠩�� � NT_Buffer
		LDA	Tank_X,X
		AND	#7
		BNE	loc_E1DD
		LDA	NTAddr_Coord_Hi,X
		ORA	#$80 ; '�'      ; ����� ⠩� ��४��砥��� ���訩 ���
		STA	NTAddr_Coord_Hi,X
		LDY	#$20 ; ' '
		JSR	Rise_Nt_HighBit	; ��c⠢��� ���訩 ��� � ������ ⠩�� � NT_Buffer

loc_E1DD:				; CODE XREF: Ice_Detect+4Fj
		LDA	Tank_Y,X
		AND	#7
		BNE	Next_Tank
		LDA	NTAddr_Coord_Hi,X
		ORA	#$40 ; '@'
		STA	NTAddr_Coord_Hi,X
		LDY	#1
		JSR	Rise_Nt_HighBit	; ��c⠢��� ���訩 ��� � ������ ⠩�� � NT_Buffer

Next_Tank:				; CODE XREF: Ice_Detect+8j
					; Ice_Detect+Cj Ice_Detect+60j
		DEC	Counter
		BPL	-
		RTS
; End of function Ice_Detect


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��c⠢��� ���訩 ��� � ������ ⠩�� � NT_Buffer

Rise_Nt_HighBit:			; CODE XREF: Ice_Detect:++p
					; Ice_Detect+59p Ice_Detect+6Ap
		LDA	(LowPtr_Byte),Y
		ORA	#$80 ; '�'
		STA	(LowPtr_Byte),Y
		RTS
; End of function Rise_Nt_HighBit


; ��������������� S U B	R O U T	I N E ���������������������������������������


HideHiBit_Under_Tank:			; CODE XREF: Battle_Loop+9p
		LDA	#7
		STA	Counter		; ��ࠡ��뢠���� 8 ⠭���

-:					; CODE XREF: HideHiBit_Under_Tank+37j
		LDX	Counter
		LDA	Tank_Status,X
		BPL	++
		CMP	#$E0 ; '�'
		BCS	++		; �᫨ ⠭� ���ࢠ� ���	�ᯠ㭨���,
					; ���室�� � ᫥���饬�
		LDA	NTAddr_Coord_Lo,X
		STA	LowPtr_Byte
		LDA	NTAddr_Coord_Hi,X
		AND	#3
		ORA	#4
		STA	HighPtr_Byte
		LDY	#$21 ; '!'
		JSR	HideHiBit_InBuffer ; ���ࠥ� ���訩 ��� �� (LowPtrByte)
		LDA	NTAddr_Coord_Hi,X
		AND	#$80 ; '�'
		BEQ	+
		LDY	#$20 ; ' '
		JSR	HideHiBit_InBuffer ; ���ࠥ� ���訩 ��� �� (LowPtrByte)

+:					; CODE XREF: HideHiBit_Under_Tank+23j
		LDA	NTAddr_Coord_Hi,X
		AND	#$40 ; '@'
		BEQ	++
		LDY	#1
		JSR	HideHiBit_InBuffer ; ���ࠥ� ���訩 ��� �� (LowPtrByte)

++:					; CODE XREF: HideHiBit_Under_Tank+8j
					; HideHiBit_Under_Tank+Cj
					; HideHiBit_Under_Tank+2Ej
		DEC	Counter
		BPL	-
		RTS
; End of function HideHiBit_Under_Tank


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ���ࠥ� ���訩 ��� �� (LowPtrByte)

HideHiBit_InBuffer:			; CODE XREF: HideHiBit_Under_Tank+1Cp
					; HideHiBit_Under_Tank+27p
					; HideHiBit_Under_Tank+32p
		LDA	(LowPtr_Byte),Y
		AND	#$7F ; ''
		STA	(LowPtr_Byte),Y
		RTS
; End of function HideHiBit_InBuffer


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� ��� ������ ��� ����� ��� �窨	�� �����

Bonus_Draw:				; CODE XREF: ROM:Skip_Battle_Loopp
					; ROM:C241p BonusLevel_ButtonCheck+Fp
		LDA	Bonus_X
		BEQ	End_Bonus_Draw	; �᫨ ����� ���, ��室��
					;
					; � ��楤��: �᫨ ����� �� ���� (�������
					; �����) ���稪 �६��� �����, �᫨
					; �����	���� (�����뢠���� �窨), ���稪
					; ᭨������ � $32 �� ���
		LDA	BonusPts_TimeCounter
		BEQ	Bonus_NotTaken	; �����	���� ��	����
		DEC	BonusPts_TimeCounter ; ����� ���� � ������
					; �窨 �� ����
		BNE	NotZeroCounter
		LDA	#0
		STA	Bonus_X		; ���ࠥ� �窨 ��
					; �����	� �࠭�
		JMP	End_Bonus_Draw
; ���������������������������������������������������������������������������

NotZeroCounter:				; CODE XREF: Bonus_Draw+Aj
		LDA	#2
		STA	TSA_Pal		; �窨 �ᯮ����� ������� �ࠩ⮢ 2
		LDA	#$3B ; ';'      ; ����� �窮� �� �����
					; (500)	ࠢ�� $3A
		STA	Spr_TileIndex
		JMP	Draw_Bonus
; ���������������������������������������������������������������������������

Bonus_NotTaken:				; CODE XREF: Bonus_Draw+6j
		LDA	Frame_Counter	; �����	���� ��	����
		AND	#8
		BEQ	End_Bonus_Draw
		LDA	#2
		STA	TSA_Pal		; �����	�ᯮ���� ������� �ࠩ⮢ 2
		LDA	Bonus_Number	; ��।���� ⨯ �����
		ASL	A
		ASL	A		; �������� �� 4	(����� �� 4 ⠩���)
		CLC
		ADC	#$81 ; '�'      ; ���� ������ ⠩�� ����� ࠢ�� $80
		STA	Spr_TileIndex

Draw_Bonus:				; CODE XREF: Bonus_Draw+1Bj
		LDX	Bonus_X
		LDY	Bonus_Y
		LDA	#0
		STA	Spr_Attrib
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)
		LDA	#$20 ; ' '
		STA	Spr_Attrib

End_Bonus_Draw:				; CODE XREF: Bonus_Draw+2j
					; Bonus_Draw+10j Bonus_Draw+22j
		RTS
; End of function Bonus_Draw


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� ᨫ���� ����, �᫨ �㦭�

Invisible_Timer_Handle:			; CODE XREF: Battle_Loop+12p
		LDA	#1
		STA	Counter		; ��ࠡ��뢠�� ⮫쪮 ��ப��

-:					; CODE XREF: Invisible_Timer_Handle+2Aj
		LDX	Counter
		LDA	Invisible_Timer,X ; ������� ���� �����	��ப� ��᫥ ஦�����
		BEQ	Next_Invisible_Timer_Handle ; �᫨ � ⠭�� ��� ����, ��	��ࠡ��뢠��
		LDA	Frame_Counter
		AND	#63
		BNE	+		; ������ ᥪ㭤� 㬥��蠥� ⠩���
		DEC	Invisible_Timer,X ; ������� ���� �����	��ப� ��᫥ ஦�����

+:					; CODE XREF: Invisible_Timer_Handle+Ej
		LDA	#2
		STA	TSA_Pal
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		LDA	Frame_Counter
		AND	#2
		ASL	A		; ����� 2 �३�� ���塞 ���� ����
					; (�८�ࠧ�� ����� �३�� � ���� ������
					; 16�16	⠩�� ᨫ����� ����)
		CLC
		ADC	#$29 ; ')'      ; ��砫�� ������ ⠩�� ��䨪� ᨫ����� ����
		STA	Spr_TileIndex
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)

Next_Invisible_Timer_Handle:		; CODE XREF: Invisible_Timer_Handle+8j
		DEC	Counter
		BPL	-
		RTS
; End of function Invisible_Timer_Handle


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠡ��뢠�� ����� �	�஭� �⠡�

HQ_Handle:				; CODE XREF: Battle_Loop+Fp
		LDA	HQArmour_Timer	; ������ �஭� ����� �⠡�
		BEQ	HQ_Explode_Handle
		LDA	Frame_Counter
		AND	#$F
		BNE	HQ_Explode_Handle ; ��ࠡ��뢠�� 4 ࠧ�	� ᥪ㭤�
		LDA	Frame_Counter
		AND	#63
		BNE	Skip_DecHQTimer	; ������ ᥪ㭤� 㬥��蠥�
					; ⠩��� �஭� �⠡�
		DEC	HQArmour_Timer	; ������ �஭� ����� �⠡�
		BEQ	Normal_HQ_Handle ; �᫨	⠩��� ���稫��, ��㥬	���⮩	�⠡

Skip_DecHQTimer:			; CODE XREF: HQ_Handle+Ej
		LDA	HQArmour_Timer	; ������ �஭� ����� �⠡�
		CMP	#4
		BCS	HQ_Explode_Handle ; �� 4 ᥪ㭤� �� ���祭�� ⠩��� �஭� �⠡�,
					; �஭�	��稭��� ������
		LDA	Frame_Counter
		AND	#$10		; ������� � ���⮩ � 16 �३���
					; (4 ࠧ� � ᥪ㭤�)
		BEQ	Normal_HQ_Handle
		JSR	Draw_ArmourHQ	; ����� �⠡ �	�஭��
		JMP	HQ_Explode_Handle
; ���������������������������������������������������������������������������

Normal_HQ_Handle:			; CODE XREF: HQ_Handle+12j
					; HQ_Handle+1Ej
		JSR	DraW_Normal_HQ	; ����� �⠡ �	��௨砬�

HQ_Explode_Handle:			; CODE XREF: HQ_Handle+2j HQ_Handle+8j
					; HQ_Handle+18j HQ_Handle+23j
		LDA	HQ_Status	; 80=�⠡ 楫, �᫨ ���� � 㭨�⮦��
		BEQ	End_HQ_Handle	; �᫨ �⠡� 㦥 ���, �� ��ࠡ��뢠�� ��� ����
		BMI	End_HQ_Handle	; �᫨ �⠡ 楫, �� ��ࠡ��뢠�� ��� ����
		LDA	#3
		STA	TSA_Pal
		DEC	HQ_Status	; 80=�⠡ 楫, �᫨ ���� � 㭨�⮦��
		LDA	HQ_Status	; 80=�⠡ 楫, �᫨ ���� � 㭨�⮦��
		LSR	A
		LSR	A		; 4 �३�� ��ন��� ����� ����	�����樨 ���뢠
		SEC
		SBC	#5
		BPL	+
		EOR	#$FF
		CLC
		ADC	#1

+:					; CODE XREF: HQ_Handle+3Cj
		SEC
		SBC	#5
		BPL	++		; �����⥫� ���塠�⮢�
		EOR	#$FF
		CLC
		ADC	#1		; �����	�����樨 㢥��稢����� �� 5, � ��⥬ ᭨������

++:					; CODE XREF: HQ_Handle+46j
		ASL	A		; �����⥫� ���塠�⮢�
		TAY
		LDA	HQExplode_JumpTable,Y
		STA	LowPtr_Byte
		LDA	HQExplode_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; ���������������������������������������������������������������������������

End_HQ_Handle:				; CODE XREF: HQ_Handle+2Bj
					; HQ_Handle+2Dj
		RTS
; End of function HQ_Handle

; ���������������������������������������������������������������������������
;������ �뢮��� �ࠩ⮢ ���뢠 �⠡� (�ᥣ� ���� ���஢ �����樨)
HQExplode_JumpTable:.WORD End_Ice_Move	; DATA XREF: HQ_Handle+4Fr
					; HQ_Handle+54r
					; �����頥��� �� RTS
		.WORD FirstExplode_Pic	; ���� ���� 16�16 ���뢠
		.WORD SecondExplode_Pic	; ��ன ���� 16�16 ���뢠
		.WORD ThirdExplode_Pic	; ��⨩ ���� 16�16 ���뢠
		.WORD FourthExplode_Pic	; ����	32�32 �������
		.WORD FifthExplode_Pic	; ����	����让	32�32 ����
; ���������������������������������������������������������������������������

FirstExplode_Pic:			; DATA XREF: ROM:E308o
		LDA	#$F1 ; '�'      ; ���� ���� 16�16 ���뢠
		JMP	Draw_HQSmallExplode
; ���������������������������������������������������������������������������

SecondExplode_Pic:			; DATA XREF: ROM:E30Ao
		LDA	#$F5 ; '�'      ; ��ன ���� 16�16 ���뢠
		JMP	Draw_HQSmallExplode
; ���������������������������������������������������������������������������

ThirdExplode_Pic:			; DATA XREF: ROM:E30Co
		LDA	#$F9 ; '�'      ; ��⨩ ���� 16�16 ���뢠

Draw_HQSmallExplode:			; CODE XREF: ROM:E314j	ROM:E319j
		LDX	#$78 ; 'x'
		LDY	#$D8 ; '�'      ; ���न���� ���� ���뢠 �⠡�
; START	OF FUNCTION CHUNK FOR Add_ExplodeSprBase

Draw_SmallExplode:			; CODE XREF: Add_ExplodeSprBase+3j
		STA	Spr_TileIndex
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)
		RTS
; END OF FUNCTION CHUNK	FOR Add_ExplodeSprBase

; ��������������� S U B	R O U T	I N E ���������������������������������������


Add_ExplodeSprBase:			; CODE XREF: Draw_BigExplode+6p
					; Draw_BigExplode+Fp
					; Draw_BigExplode+18p
					; Draw_BigExplode+21p

; FUNCTION CHUNK AT E322 SIZE 00000006 BYTES

		CLC
		ADC	HQExplode_SprBase
		JMP	Draw_SmallExplode
; End of function Add_ExplodeSprBase

; ���������������������������������������������������������������������������

FourthExplode_Pic:			; DATA XREF: ROM:E30Eo
		LDA	#0		; ����	32�32 �������
		STA	HQExplode_SprBase
		JSR	Draw_BigExplode	; ����� 32�32 �ࠩ� ���뢠
		RTS
; ���������������������������������������������������������������������������

FifthExplode_Pic:			; DATA XREF: ROM:E310o
		LDA	#$10		; ����	����让	32�32 ����
		STA	HQExplode_SprBase
		JSR	Draw_BigExplode	; ����� 32�32 �ࠩ� ���뢠
		RTS

; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� 32�32 �ࠩ� ���뢠

Draw_BigExplode:			; CODE XREF: ROM:E332p	ROM:E33Ap
		LDX	#$70 ; 'p'
		LDY	#$D0 ; '�'
		LDA	#$D1 ; '�'
		JSR	Add_ExplodeSprBase
		LDX	#$80 ; '�'
		LDY	#$D0 ; '�'
		LDA	#$D5 ; '�'
		JSR	Add_ExplodeSprBase
		LDX	#$70 ; 'p'
		LDY	#$E0 ; '�'
		LDA	#$D9 ; '�'
		JSR	Add_ExplodeSprBase
		LDX	#$80 ; '�'
		LDY	#$E0 ; '�'
		LDA	#$DD ; '�'
		JSR	Add_ExplodeSprBase
		RTS
; End of function Draw_BigExplode


; ��������������� S U B	R O U T	I N E ���������������������������������������


Make_Respawn:				; CODE XREF: SetUp_LevelVARs+16p
					; SetUp_LevelVARs+1Fp
					; Respawn_Handle+19p ROM:DE11p
		LDA	#0
;����砫쭮 ⠭� ��ப�	�����
		STA	Tank_Type,X	; x = 0..1 - ��ᬠ�ਢ����� ⨯ ��ப�
					;    x = 2..5 -	��ᬠ�ਢ�����	�ࠦ�᪨� ⨯�
		CPX	#2
		BCS	Enemy_Operations ; �᫨	>= 2, � �� �ࠣ
		LDA	X_Player_Respawn,X
		STA	Tank_X,X
		LDA	Y_Player_Respawn,X
		STA	Tank_Y,X
		LDA	#0		; ��ப	�� ������ ������
					; �� �६� �ᯠ㭠
		STA	Player_Blink_Timer,X ; ������ ������� friendly fire
		JMP	++		; ���� �㤥� ��஦������
; ���������������������������������������������������������������������������

Enemy_Operations:			; CODE XREF: Make_Respawn+6j
		INC	EnemyRespawn_PlaceIndex
		LDY	EnemyRespawn_PlaceIndex
		CPY	#3		; 3 ��������� ���� �ᯠ㭠
		BNE	+
		LDA	#0
		STA	EnemyRespawn_PlaceIndex
		TAY

+:					; CODE XREF: Make_Respawn+1Fj
		LDA	X_Enemy_Respawn,Y
		STA	Tank_X,X
		LDA	Y_Enemy_Respawn,Y
		STA	Tank_Y,X
		LDA	Enemy_Reinforce_Count ;	������⢮ �ࠣ�� � �����
		CMP	#3		; ������ ⠭�	�����, �����	� �����
					; ��⠭����: 17, 10 ���	3 �ࠦ�᪨� ⠭��.
		BEQ	Make_BonusEnemy
		CMP	#10
		BEQ	Make_BonusEnemy
		CMP	#17
		BNE	++		; ���� �㤥� ��஦������

Make_BonusEnemy:			; CODE XREF: Make_Respawn+34j
					; Make_Respawn+38j
		LDA	#4
		STA	Tank_Type,X	; ������ �ࠣ� ������
					; (ORA $80 �㤥� ��⮬)

++:					; CODE XREF: Make_Respawn+16j
					; Make_Respawn+3Cj
		LDA	#$F0		; ���� �㤥� ��஦������
		STA	Tank_Status,X
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		LDA	#$F
		JSR	Draw_TSABlock	; ���ᮢ뢠�� ��� ⠭��� �㤥�	���⮥ ����. ��
					; ��砩, �᫨ �஢��� �� ᮧ��� ��-���
					; Construction � �� ���� �ᯠ㭠 ��ப��
					; ��� �ࠣ�� ���� �����-� �����.
		RTS
; End of function Make_Respawn


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����㦠�� �㦭� ⨯ ������ ⠭��

Load_New_Tank:				; CODE XREF: ROM:DE6Ep
		LDA	Respawn_Status,X
		STA	Tank_Status,X
		CPX	#2
		BCS	Load_NewEnemy	; �ࠣ
		LDA	#3
		STA	Invisible_Timer,X ; ������� ���� �����	��ப� ��᫥ ஦�����
		LDA	Player_Type,X	; ��� ⠭�� ��ப�
		CMP	#$0
		BEQ	Start_With_One_Star
		JMP	++
; ���������������������������������������������������������������������������

Start_With_One_Star:
		LDA #$20
		STA	Player_Type,X
		STA	Tank_Type,X
		JMP	++
; ���������������������������������������������������������������������������

Load_NewEnemy:				; CODE XREF: Load_New_Tank+7j
					; Load_New_Tank+1Cj
		LDY	Enemy_TypeNumber ; �ࠣ
		LDA	Enemy_Count,Y
		BNE	+
		INC	Enemy_TypeNumber
		JMP	Load_NewEnemy	; �᫨ ⥪�騩 ⨯ (���� �� 4 �� �஢���) ���稫��,
					; ��稭��� �ᯠ㭨�� ᫥���騩	⨯.
; ���������������������������������������������������������������������������

+:					; CODE XREF: Load_New_Tank+18j
		SEC
		SBC	#1
		STA	Enemy_Count,Y
		LDA	Level_Mode
		BEQ	+++		; �᫨ �஢�� ��諨 �� 2-�� ����, ����� �ࠣ��
					; �ᥣ�� �� 35 �஢��
		LDA	#35
		JMP	++++
; ���������������������������������������������������������������������������

+++:					; CODE XREF: Load_New_Tank+27j
		LDA	Level_Number

++++:					; CODE XREF: Load_New_Tank+2Bj
		SEC
		SBC	#1
		ASL	A
		ASL	A		; �� �஢�� 4 ⨯� �ࠣ��
		CLC
		ADC	Enemy_TypeNumber
		TAY			; ����塞 ����� �ࠣ�� � ����ᨬ��� �� ����� �஢��
		LDA	EnemyType_ROMArray,Y
		CMP	#$E0
		BNE	++		; �᫨ �ࠣ ��᫥����� ⨯�,
					; � ���� ᠬ�� ��魠� �஭�
		ORA	#3

++:					; CODE XREF: Load_New_Tank+10j
					; Load_New_Tank+3Ej
		ORA	Tank_Type,X
		CMP	#$E7
		BNE	End_Load_New_Tank
		LDA	#$E4

End_Load_New_Tank:			; CODE XREF: Load_New_Tank+46j
		STA	Tank_Type,X

		LDA	Boss_Mode	;!�᫨ ����, � ����㦠�� ⠭� � ����ᨬ��� �� ����� �஢��.
		BEQ	Skip_Load_Boss_Tank

		TXA ; �஢��塞, �⮡� ⨯ ��ப� �� ������
		CMP 	#2
		BCC	Skip_Load_Boss_Tank
		
		JSR	Get_Random_A
		AND	#7
		ASL
		ASL
		ASL
		ASL
		ASL   ;�⠢�� ⨯
		ORA #3;�⠢�� �஭�
		STA	Tank_Type,X		

Skip_Load_Boss_Tank:
		LDA	#0
		STA	Track_Pos,X
		RTS
; End of function Load_New_Tank


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ������ � �࠭� �� �㫨

Hide_All_Bullets:			; CODE XREF: SetUp_LevelVARsp
		LDX	#9
		LDA	#0

-:					; CODE XREF: Hide_All_Bullets+7j
		STA	Bullet_Status,X
		DEX
		BPL	-
		RTS
; End of function Hide_All_Bullets


; ��������������� S U B	R O U T	I N E ���������������������������������������


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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; Tank_Status OR �

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


; ��������������� S U B	R O U T	I N E ���������������������������������������


Load_Enemy_Count:			; CODE XREF: SetUp_LevelVARs+52p
		LDA	Level_Mode
		BEQ	+
		LDA	#35		; � �����-�஢�� �ᥣ��	����७���� 35-��
		JMP	++
; ���������������������������������������������������������������������������

+:					; CODE XREF: Load_Enemy_Count+2j
		LDA	Level_Number

++:					; CODE XREF: Load_Enemy_Count+6j
		SEC
		SBC	#1
		ASL	A
		ASL	A		; �������� �� 4	(������⢮ ⨯�� �ࠣ�� � �஢��)
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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; $FF =	������ �ࠢ����� �� ������

Button_To_DirectionIndex:		; CODE XREF: Move_Tank+21p
					; Move_Tank+2Fp Ice_Move+2Ap
		ASL	A
;��ॢ���� � � �᫮ � ᮮ⢥��⢨� � 3	���訬� ��⠬�	(3,1,2,0,FF)
;�ᯮ������ ��� ����祭�� ������ ���ࠢ�����	��६�饭�� ⠭��
;� ����ᨬ��� �� ������� ������ �ࠢ����� �� �����⨪�
;�᫨ ������ �ࠢ����� �� ������, �����頥� $FF
		BCC	+
		LDA	#3		; ��ࠢ�
		RTS
; ���������������������������������������������������������������������������

+:					; CODE XREF: Button_To_DirectionIndex+1j
		ASL	A
		BCC	++
		LDA	#1		; �����
		RTS
; ���������������������������������������������������������������������������

++:					; CODE XREF: Button_To_DirectionIndex+7j
		ASL	A
		BCC	+++
		LDA	#2		; ����
		RTS
; ���������������������������������������������������������������������������

+++:					; CODE XREF: Button_To_DirectionIndex+Dj
		ASL	A
		BCC	++++		; ������ ���ࠢ����� �� ������
		LDA	#0		; �����
		RTS
; ���������������������������������������������������������������������������

++++:					; CODE XREF: Button_To_DirectionIndex+13j
		LDA	#$FF		; ������ ���ࠢ����� �� ������
		RTS
; End of function Button_To_DirectionIndex

; ���������������������������������������������������������������������������
;����㦠���� $DCAC,$E063,$E0A2 (⠪�� �� ���ᨢ	�� ����� $D3D5)
Bullet_Coord_X_Increment_1:.BYTE 0, $FF, 0, 1 ;	DATA XREF: ROM:DCACr ROM:DCB4r
					; Change_BulletCoordr Make_Shot+16r
;����㦠���� $DC9C,$E06C,$E0AD
Bullet_Coord_Y_Increment_1:.BYTE $FF, 0, 1, 0 ;	DATA XREF: ROM:DC9Cr ROM:DCA4r
					; Change_BulletCoord+9r Make_Shot+21r
X_Enemy_Respawn:.BYTE $18, $78,	$D8	; DATA XREF: Make_Respawn:+r
;X ���न��� ᮮ⢥��⢥��� ������, �।���� �	�ࠢ���	�ᯠ㭠 �ࠣ�
Y_Enemy_Respawn:.BYTE $18, $18,	$18	; DATA XREF: Make_Respawn+2Br
;Y ���न��� ᮮ⢥��⢥��� ������, �।���� �	�ࠢ���	�ᯠ㭠 �ࠣ�
X_Player_Respawn:.BYTE $58, $98		; DATA XREF: Make_Respawn+8r
;X ���न���  �ᯠ㭠	ᮮ⢥��⢥��� ��ࢮ�� � ��ண� ��ப�
Y_Player_Respawn:.BYTE $D8, $D8		; DATA XREF: Make_Respawn+Dr
;Y ���न��� �ᯠ㭠 ᮮ⢥��⢥��� ��ࢮ�� �	��ண�	��ப�

Respawn_Status:	.BYTE $A0, $A0,	$A2, $A2, $A2, $A2, $A2, $A2 ; DATA XREF: Load_New_Tankr
;������ ��ப�� � �ࠣ�� �� �ᯠ㭥 (��ப� ��稭���	�㫮� �����, �ࠣ� - ����)

AI_Status:	.BYTE $A0,$A0,$A0,$A1,$A0,$A3,$A2,$A2,$A2
					; DATA XREF: Load_AI_Status:End_Load_AIStatusr
		.BYTE $A1,$A0,$A3,$A1,$A0,$A3,$A1,$A2,$A3

TankStatus_JumpTable:.WORD End_Ice_Move	; DATA XREF: Status_Core+8r
					; Status_Core+Dr
					; �����頥��� �� RTS
		.WORD Explode_Handle	; ��ࠡ��뢠�� ���� ⠭�� (㬥��蠥� �᫮ ������, GameOver...)
		.WORD Explode_Handle	; ��ࠡ��뢠�� ���� ⠭�� (㬥��蠥� �᫮ ������, GameOver...)
		.WORD Explode_Handle	; ��ࠡ��뢠�� ���� ⠭�� (㬥��蠥� �᫮ ������, GameOver...)
		.WORD Explode_Handle	; ��ࠡ��뢠�� ���� ⠭�� (㬥��蠥� �᫮ ������, GameOver...)
		.WORD Explode_Handle	; ��ࠡ��뢠�� ���� ⠭�� (㬥��蠥� �᫮ ������, GameOver...)
		.WORD Explode_Handle	; ��ࠡ��뢠�� ���� ⠭�� (㬥��蠥� �᫮ ������, GameOver...)
		.WORD Explode_Handle	; ��ࠡ��뢠�� ���� ⠭�� (㬥��蠥� �᫮ ������, GameOver...)
		.WORD Misc_Status_Handle ; ��ࠡ��뢠��	������	�줠, ������ �४� � �.�.
		.WORD Get_RandomStatus	; � �᭮����, ����砥� ��砩�� �����
		.WORD Check_TileReach	; �஢���� � �ࠣ�, ���⨣ �� �� ����	⠩��
		.WORD Aim_HQ		; ��⠭��������	� ����⢥ 楫���� ���न���� �⠡
		.WORD Aim_ScndPlayer	; ��⠭��������	� ����⢥ 楫�	�ࠣ� ��ࢮ�� ��ப�
		.WORD Aim_FirstPlayer	; ��⠭��������	� ����⢥ 楫�	�ࠣ� ��ண� ��ப�
		.WORD Load_Tank		; ����㦠�� �㦭� ⨯ ������ ⠭��, �᫨ �㦭�
		.WORD Set_Respawn	; ��⠭��������	� ����� ��ᯠ�

TankDraw_JumpTable:.WORD End_Ice_Move	; DATA XREF: SingleTankStatus_Handle+8r
					; SingleTankStatus_Handle+Dr
					; �����頥��� �� RTS
		.WORD Draw_Kill_Points	; ����� �窨 �� ���� ���뢠 �ࠣ�
		.WORD Draw_Small_Explode1 ; ���� 16�16
		.WORD Draw_Big_Explode	; ����뢠�� � Spr_Buffer ����让 ����
		.WORD Draw_Big_Explode	; ����뢠�� � Spr_Buffer ����让 ����
		.WORD Draw_Small_Explode2 ; ����뢠�� � Spr_Buffer 16�16 �ࠩ� ���뢠
		.WORD Draw_Small_Explode2 ; ����뢠�� � Spr_Buffer 16�16 �ࠩ� ���뢠
		.WORD Draw_Small_Explode2 ; ����뢠�� � Spr_Buffer 16�16 �ࠩ� ���뢠
		.WORD OperatingTank	; �����।�⢥��� ��⠭��������	� Spr_Tile_Index �㦭�	⠭�
		.WORD OperatingTank	; �����।�⢥��� ��⠭��������	� Spr_Tile_Index �㦭�	⠭�
		.WORD OperatingTank	; �����।�⢥��� ��⠭��������	� Spr_Tile_Index �㦭�	⠭�
		.WORD OperatingTank	; �����।�⢥��� ��⠭��������	� Spr_Tile_Index �㦭�	⠭�
		.WORD OperatingTank	; �����।�⢥��� ��⠭��������	� Spr_Tile_Index �㦭�	⠭�
		.WORD OperatingTank	; �����।�⢥��� ��⠭��������	� Spr_Tile_Index �㦭�	⠭�
		.WORD Respawn
		.WORD Respawn
Bullet_Status_JumpTable:.WORD End_Ice_Move ; DATA XREF:	BulletStatus_Handle+8r
					; BulletStatus_Handle+Dr
					; �����頥��� �� RTS
		.WORD Make_Ricochet	; ����� �����	�㫨 ��� ������� ਪ���
		.WORD Make_Ricochet	; ����� �����	�㫨 ��� ������� ਪ���
		.WORD Make_Ricochet	; �㤥�	�� ���� ਪ���
		.WORD Bullet_Move	; ������� ��� � ᮮ⢥��⢨� �	Bullet_Status
BulletGFX_JumpTable:.WORD End_Ice_Move	; DATA XREF: Draw_BulletGFX+8r
					; Draw_BulletGFX+Dr
					; �����頥��� �� RTS
		.WORD Update_Ricochet	; ����� ਪ��� � �㦭�� ����
		.WORD Update_Ricochet	; ����� ਪ��� � �㦭�� ����
		.WORD Update_Ricochet	; ����� ਪ��� � �㦭�� ����
		.WORD Draw_Bullet	; ����뢠�� � ����� �ࠩ� �㫨
;���� �ࠣ�� (4	⨯� ��	����� �஢�� � �ᥣ� 8 ⨯��) �� �஢��
;��ଠ�	����:
;����:
;0,1 - �஢��� �஭�
;2   - 䫠� ����᭮�� ⠭��
;3,4 - �� �ᯮ�������
;5,6,7 - ⨯ ⠭�� (�������� 8 ⨯��)
;

; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠡ��뢠�� ����� �㫨 (�⮫��������	� �.�.)

Bullet_Fly_Handle:			; CODE XREF: Battle_Loop+1Ep
		LDA	#9
		STA	Counter		; ��ࠡ��뢠�� 10 ���

-:					; CODE XREF: Bullet_Fly_Handle+8Bj
		LDX	Counter
		LDA	Bullet_Status,X
		AND	#$F0 ; '�'
		CMP	#$40 ; '@'
		BNE	Next_Bullet_Fly_Handle ; �᫨ ��� �� ����, ���室�� � ᫥���饩
		LDA	Bullet_Property,X ; ������� � �஭���������
		BNE	+
		TXA
		EOR	Frame_Counter
		AND	#1		; �������� �㫨 ��ࠡ��뢠�� �१ �३�
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
		JSR	GetSprCoord_InTiles ; ��ॢ����	Spr_coord � ⠩��
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
		JSR	BulletToObject_Impact_Handle ; ��ࠡ��뢠�� �⮫�������� �㫨 �	��ꥪ⮬

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
		JSR	GetSprCoord_InTiles ; ��ॢ����	Spr_coord � ⠩��
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
		JSR	BulletToObject_Impact_Handle ; ��ࠡ��뢠�� �⮫�������� �㫨 �	��ꥪ⮬

Next_Bullet_Fly_Handle:			; CODE XREF: Bullet_Fly_Handle+Cj
					; Bullet_Fly_Handle+17j
					; Bullet_Fly_Handle+6Cj
		DEC	Counter
		BMI	End_Bullet_Fly_Handle
		JMP	-
; ���������������������������������������������������������������������������

End_Bullet_Fly_Handle:			; CODE XREF: Bullet_Fly_Handle+89j
		RTS
; End of function Bullet_Fly_Handle


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ॢ���� Spr_coord �	⠩��

GetSprCoord_InTiles:			; CODE XREF: Bullet_Fly_Handle+43p
					; Bullet_Fly_Handle+69p
		STX	Spr_X
		STY	Spr_Y
		JSR	GetCoord_InTiles ; � � � Y �� ��室� ���न����	� ⠩���
; End of function GetSprCoord_InTiles


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠡ��뢠�� �⮫�������� �㫨 � ��ꥪ⮬

BulletToObject_Impact_Handle:		; CODE XREF: Bullet_Fly_Handle+58p
					; Bullet_Fly_Handle+84p
		JSR	Temp_Coord_shl	; �८�ࠧ�� Temp � ����ᨬ��� �� Spr_Coord
		JSR	Check_Object	; �����頥� ����, �᫨	�㫥���	⠩�
		BEQ	BulletToObject_Return0 ; �᫨ ��। �㫥� �����, ��室�� � 0
		LDA	(LowPtr_Byte),Y
		AND	#$FC ; '�'
		CMP	#$C8 ; '�'      ; �ࠢ������ � �����ᮬ ⠩�� �⠡�
		BNE	+
		LDA	HQ_Status	; 80=�⠡ 楫, �᫨ ���� � 㭨�⮦��
		BEQ	+		; �᫨ 0, ���뢠�� �⠡
		LDA	#$27 ; '''      ; ���뢠�� �⠡
		STA	HQ_Status	; ��砫�� ���� �����樨 ���뢠
					; (7 ���஢ �� 4 �३��)
		LDA	#1
		STA	Sns_HQExplode
		STA	Snd_PlayerExplode
		JSR	Draw_Destroyed_HQ ; ����� ࠧ��襭�� �⠡
		LDX	Counter
		LDA	#$33 ; '3'      ; ������ ਪ��� �� ���
		STA	Bullet_Status,X
		JMP	BulletToObject_Return0
; ���������������������������������������������������������������������������

+:					; CODE XREF: BulletToObject_Impact_Handle+Ej
					; BulletToObject_Impact_Handle+12j
		LDA	(LowPtr_Byte),Y
		CMP	#$12		; �᫨ >$12 (����, ���,	�� � �.�.), �㫨
					; ��室�� ��᪢��� (�����蠥� ��ࠡ���)
		BCS	BulletToObject_Return0
		LDX	Counter
		LDA	#$33 ; '3'
		STA	Bullet_Status,X	; 3 ���� �����樨 ਪ���,
					; ����� ��ঠ��� �� 3	�३��
		LDA	(LowPtr_Byte),Y
		CMP	#$11		; �࠭�� �࠭�
		BEQ	Armored_Wall
		LDA	Bullet_Property,X ; ������� � �஭���������
		AND	#2
		BEQ	++		; �᫨ �஭�������, ࠧ��蠥� ��ꥪ�
		LDA	#0
		JSR	Draw_Tile	; ���㥬 �����	��௨�
					; ���⮩ ⠩�
		LDA	#1
		STA	Snd_Brick_Ricochet
		JMP	BulletToObject_Return0
; ���������������������������������������������������������������������������

++:					; CODE XREF: BulletToObject_Impact_Handle+42j
		LDA	(LowPtr_Byte),Y
		CMP	#$10		; ���� �஭�
		BEQ	Armored_Wall
		CPX	#2		; �⮫�������� � ��௨筮� �⥭��
		BCS	BulletToObject_Return1 ; �����	⮫쪮 ��������� ��ப��
		LDA	#1
		STA	Snd_Brick_Ricochet

BulletToObject_Return1:			; CODE XREF: BulletToObject_Impact_Handle+59j
		JSR	Draw_Destroyed_Brick ; ����� �ࠢ���� ���� � ��௨筮� �⥭�
		LDA	#1
		RTS
; ���������������������������������������������������������������������������

Armored_Wall:				; CODE XREF: BulletToObject_Impact_Handle+3Cj
					; BulletToObject_Impact_Handle+55j
		CPX	#2
		BCS	BulletToObject_Return0 ; ������ ⮫쪮	ਪ���� ��ப��
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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠡ��뢠�� �⮫�������� �㫨 � ⠭���

BulletToTank_Impact_Handle:		; CODE XREF: Battle_Loop+24p
		LDA	#1
		STA	Counter		; ���砫� ��ࠡ��뢠�� ⮫쪮 ��ப��
					; (�ࠣ	�������� � ��ப�)

-:					; CODE XREF: BulletToTank_Impact_Handle+70j
		LDX	Counter
		LDA	Tank_Status,X
		BPL	Jump_Next_Player_Tank_Impact ; �᫨ ⠭� ���뢠����,
					; ���室�� � ᫥���饬�
		CMP	#$E0 ; '�'
		BCC	+		; �᫨ ⠭� �� �ᯠ㭨���,
					; ���室�� � ᫥���饬�

Jump_Next_Player_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+8j
		JMP	Next_Player_Tank_Impact
; ���������������������������������������������������������������������������

+:					; CODE XREF: BulletToTank_Impact_Handle+Cj
		LDA	#7
		STA	Counter2	; 8 ��������� ��� � �ࠣ�

--:					; CODE XREF: BulletToTank_Impact_Handle+6Cj
		LDY	Counter2
		LDA	Bullet_Status,Y
		AND	#$F0 ; '�'
		CMP	#$40 ; '@'
		BNE	Next_Bullet_Tank_Impact
		LDA	Bullet_X,Y
		SEC
		SBC	Tank_X,X
		BPL	CheckMinX_TankImpact
		EOR	#$FF
		CLC
		ADC	#1		; ����塞 ����ﭨ� ����� ⠭��� � �㫥� �� �

CheckMinX_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+26j
		CMP	#$A
		BCS	Next_Bullet_Tank_Impact
		LDA	Bullet_Y,Y
		SEC
		SBC	Tank_Y,X
		BPL	CheckMinY_TankImpact
		EOR	#$FF
		CLC
		ADC	#1		; ����塞 ����ﭨ� �� Y

CheckMinY_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+37j
		CMP	#$A
		BCS	Next_Bullet_Tank_Impact
		LDA	#$33 ; '3'
		STA	Bullet_Status,Y	; ��⠭��������	����� � ਪ���
		LDA	Invisible_Timer,X ; ������� ���� �����	��ப� ��᫥ ஦�����
		BEQ	Explode_Player_Tank_Impact
		LDA	#0
		STA	Bullet_Status,Y	; ���ࠥ� ���
		JMP	Next_Bullet_Tank_Impact
; ���������������������������������������������������������������������������

Explode_Player_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+49j
		LDA	#$73 ; 's'
		STA	Tank_Status,X
		LDA	#1
		STA	Snd_PlayerExplode
		LDA	#0
		STA	Player_Type,X	; ��� ⠭�� ��ப�
		STA	Tank_Type,X
		JMP	Next_Player_Tank_Impact
; ���������������������������������������������������������������������������

Next_Bullet_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+1Ej
					; BulletToTank_Impact_Handle+2Fj
					; BulletToTank_Impact_Handle+40j
					; BulletToTank_Impact_Handle+50j
		DEC	Counter2
		LDA	Counter2
		CMP	#1		; ���室�� � ᫥���饩	�㫥
		BNE	--

Next_Player_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle:Jump_Next_Player_Tank_Impactj
					; BulletToTank_Impact_Handle+63j
		DEC	Counter
		BPL	-
		LDA	#7
		STA	Counter		; ��᫥	��ࠡ�⪨ ��������� � ��ப�,
					; ��稭��� ��ࠡ��뢠��	�ࠣ��
					; (��ப �������� �� �ࠣ�)

---:					; CODE XREF: BulletToTank_Impact_Handle+130j
		LDX	Counter
		LDA	Tank_Status,X
		BPL	JumpNext_Enemy_Tank_Impact
		CMP	#$E0 ; '�'      ; �᫨ ⠭� ���ࢠ� ��� �ᯠ㭨���, ���室�� � ᫥���饬�
		BCC	++

JumpNext_Enemy_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+7Aj
		JMP	Next_Enemy_Tank_Impact
; ���������������������������������������������������������������������������

++:					; CODE XREF: BulletToTank_Impact_Handle+7Ej
		LDA	#9
		STA	Counter2	; 10 ���

----:					; CODE XREF: BulletToTank_Impact_Handle+125j
		LDA	Counter2
		AND	#6
		BEQ	+++
		JMP	Next_Bullet2_Tank_Impact
; ���������������������������������������������������������������������������

+++:					; CODE XREF: BulletToTank_Impact_Handle+8Bj
		LDY	Counter2
		LDA	Bullet_Status,Y
		AND	#$F0 ; '�'
		CMP	#$40 ; '@'
		BEQ	Load_X_TankImpact
		JMP	Next_Bullet2_Tank_Impact
; ���������������������������������������������������������������������������

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
		ADC	#1		; ����塞 ����ﭨ� ����� ⠭��� �
					; �㫥�	�� ����� ���

CheckMinY2_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+B5j
		CMP	#$A
		BCS	Next_Bullet2_Tank_Impact
		LDA	#$33 ; '3'      ; ������ ਪ���
		STA	Bullet_Status,Y
		LDA	Tank_Type,X
		AND	#4
		BEQ	Skip_BonusHandle_TankImpact ; �᫨ ⠭�	�� ������, �뢮��� �����
		JSR	Bonus_Appear_Handle ; �뢮��� ��砩��	����� �� �࠭
		LDA	Tank_Type,X
		CMP	#$E4 ; '�'
		BNE	Skip_BonusHandle_TankImpact
		DEC	Tank_Type,X	; �᫨ ⠭� �஭�஢��,	��
					; ��������� �㫨 㬥��蠥� �஭�

Skip_BonusHandle_TankImpact:		; CODE XREF: BulletToTank_Impact_Handle+C9j
					; BulletToTank_Impact_Handle+D2j
		LDA	Tank_Type,X
		AND	#3
		BEQ	Explode_Enemy_Tank_Impact
;! �஢��塞 �஭� ����:
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
		STA	Snd_ArmorRicochetTank ;	���� �஭�஢��
		JMP	Next_Bullet2_Tank_Impact
; ���������������������������������������������������������������������������

Explode_Enemy_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+DAj
		LDA	#$73 ; 's'
		STA	Tank_Status,X	; ����뢠�� ⠭�
		LDA	#1
		STA	Snd_EnemyExplode
		LDA	Tank_Type,X
		LSR	A
		LSR	A
		LSR	A
		LSR	A
		LSR	A
;! �� ���ᮢ�� �஢��� � ����⢥ �ࠣ� ����� ���� ⨯ ⠭�� ��ப�, �஢�ਬ �� � �᫨ ��, �� �⭨���� �⢥��:
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
; ���������������������������������������������������������������������������

ScndPlayerKll_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+100j
		INC	Enmy_KlledBy2P_Count,X

Score_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+104j
		LDA	Level_Mode
		CMP	#2
		BEQ	Next_Enemy_Tank_Impact ; �� �६� ����-�஢��, �窨 �� �ਡ��������
		LDA	EnemyKill_Score,X ; �窨*10 �� 㡨��⢮	�������	�� 4 ����� �ࠣ��
		JSR	Num_To_NumString ; ��ॢ���� �᫮ �� �	� ��ப� NumString
		LDA	Spr_X
		TAX
		JSR	Add_Score	; �ਡ����� �᫮ �� NumString	� �窠�	��ப� ��
		JSR	Add_Life	; ��᫥	�ࠣ�, ����塞 �窨
		JMP	Next_Enemy_Tank_Impact
; ���������������������������������������������������������������������������

Next_Bullet2_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+8Dj
					; BulletToTank_Impact_Handle+9Bj
					; BulletToTank_Impact_Handle+ADj
					; BulletToTank_Impact_Handle+BEj
					; BulletToTank_Impact_Handle+E3j
		DEC	Counter2
		BMI	Next_Enemy_Tank_Impact
		JMP	----
; ���������������������������������������������������������������������������

Next_Enemy_Tank_Impact:			; CODE XREF: BulletToTank_Impact_Handle:JumpNext_Enemy_Tank_Impactj
					; BulletToTank_Impact_Handle+10Dj
					; BulletToTank_Impact_Handle+11Ej
					; BulletToTank_Impact_Handle+123j
		DEC	Counter
		LDA	Counter
		CMP	#1
		BEQ	++++
		JMP	---
; ���������������������������������������������������������������������������

++++:					; CODE XREF: BulletToTank_Impact_Handle+12Ej
		LDA	#1
		STA	Counter		; �� ��� ࠧ ��ᬠ�ਢ��� ��������� ��ப�� �	��ப�

-----:					; CODE XREF: BulletToTank_Impact_Handle+1ABj
		LDX	Counter
		LDA	Tank_Status,X
		BPL	Jump_Next_Player2_Tank_Impact
		CMP	#$E0 ; '�'      ; �᫨ ��ப �ᯠ㭨���, ��� ���ࢠ�, ���室�� � ��㣮��
		BCC	+++++

Jump_Next_Player2_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+13Bj
		JMP	Next_Player2_Tank_Impact
; ���������������������������������������������������������������������������

+++++:					; CODE XREF: BulletToTank_Impact_Handle+13Fj
		LDA	#9
		STA	Counter2	; 10 ���

------:					; CODE XREF: BulletToTank_Impact_Handle+1A7j
		LDA	Counter2
		AND	#6
		BNE	Next_Bullet3_Tank_Impact
		LDY	Counter2
		LDA	Bullet_Status,Y
		AND	#$F0 ; '�'
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
		BPL	CheckMinY3_TankImpact ;	����塞 ����ﭨ� ��	����� ��� ����� ⠭���	� �㫥�
		EOR	#$FF
		CLC
		ADC	#1

CheckMinY3_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+178j
		CMP	#$A		; ����塞 ����ﭨ� �� �����	��� ����� ⠭��� � �㫥�
		BCS	Next_Bullet3_Tank_Impact
		LDA	#$33 ; '3'
		STA	Bullet_Status,Y	; ������ ਪ���
		LDA	Invisible_Timer,X ; ������� ���� �����	��ப� ��᫥ ஦�����
		BEQ	CheckBlink_TankImpact
		LDA	#0
		STA	Bullet_Status,Y	; ���ࠥ� ���
		JMP	Next_Bullet3_Tank_Impact
; ���������������������������������������������������������������������������

CheckBlink_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+18Aj
		LDA	Player_Blink_Timer,X ; ������ ������� friendly fire
		BNE	Next_Bullet3_Tank_Impact
		LDA	Level_Mode
		CMP	#2
		BEQ	Next_Bullet3_Tank_Impact ; �� ���� �஢�� Friendly Fire	���
		LDA	#$C8 ; '�'
		STA	Player_Blink_Timer,X ; ������塞 ⠩���
		JMP	Next_Player2_Tank_Impact
; ���������������������������������������������������������������������������

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

; ���������������������������������������������������������������������������
EnemyKill_Score:.BYTE $10, $20,	$30, $40 ; DATA	XREF: BulletToTank_Impact_Handle+10Fr
					; �窨*10 �� 㡨��⢮ ������� �� 4 ����� �ࠣ��

; ��������������� S U B	R O U T	I N E ���������������������������������������

; �뢮��� ��砩�� ����� �� �࠭

Bonus_Appear_Handle:			; CODE XREF: BulletToTank_Impact_Handle+CBp
		LDA	#1
		STA	Snd_BonusAppears ; ��ࠥ� ���� ������ �����

-:					; CODE XREF: Bonus_Appear_Handle+26j
		JSR	Get_Random_A	; ����,	� � ��砩��� �᫮
		AND	#3		; 3 ��������� ���न���� � ������
		JSR	Multiply_Bonus_Coord ; A := ((A	* 6) + 6) * 8
		STA	Bonus_X
		JSR	Get_Random_A	; ����,	� � ��砩��� �᫮
		AND	#3		; 3 ��������� ���न���� Y ������
		JSR	Multiply_Bonus_Coord ; A := ((A	* 6) + 6) * 8
		STA	Bonus_Y		; �����	������ � ��砩��� ����
		LDA	#$FF
		STA	Bonus_Number	; ��।���� ⨯ �����
		LDA	#0
		STA	BonusPts_TimeCounter
		JSR	Bonus_Handle	; ��ࠡ��뢠�� ���⨥ �����, �᫨ ⠪���� ����
		LDA	BonusPts_TimeCounter
		BNE	-
		JSR	Get_Random_A	; ����,	� � ��砩��� �᫮
		AND	#7		; 8 ����� ����ᮢ
		TAY
		LDA	BonusNumber_ROM_Array,Y	; ����� ����ᮢ (���� �� ���浪�)
		STA	Bonus_Number	; ��।���� ⨯ �����
		LDA	#0
		STA	BonusPts_TimeCounter ; ����� ���� �� ����
		LDX	Counter
		LDY	Counter2
		RTS
; End of function Bonus_Appear_Handle

; ���������������������������������������������������������������������������
;!������� ���३���. 6 � 7 �� ���������.

BonusNumber_ROM_Array:.BYTE 0, 1, 2, 3,	4, 5, 4, 3 ; DATA XREF:	Bonus_Appear_Handle+2Er
					; ����� ����ᮢ (���� �� ���浪�)

; ��������������� S U B	R O U T	I N E ���������������������������������������

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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠡ��뢠�� �⮫�������� ���� ���, �᫨ ���	����

BulletToBullet_Impact_Handle:		; CODE XREF: Battle_Loop+21p
		LDA	#9
		STA	Counter		; 10 ���

-:					; CODE XREF: BulletToBullet_Impact_Handle+5Fj
		LDA	Counter
		AND	#6
		BNE	Next_Bullet_Bulllet_Impact
		LDX	Counter
		LDA	Bullet_Status,X
		AND	#$F0 ; '�'
		CMP	#$40 ; '@'
		BNE	Next_Bullet_Bulllet_Impact ; �᫨ ��� �� ����,
					; ��ࠡ��뢠�� ᫥������
		LDA	#9
		STA	Counter2	; 10 ���

--:					; CODE XREF: BulletToBullet_Impact_Handle+5Bj
		LDA	Counter2
		TAY
		AND	#7
		STA	Temp
		LDA	Counter
		AND	#7
		CMP	Temp
		BEQ	Next_Bullet2_Bulllet_Impact ; ���� � ᮡ�� ���	�� �⮫��������
					; �� �஢��塞
		LDA	Bullet_Status,Y
		AND	#$F0 ; '�'
		CMP	#$40 ; '@'
		BNE	Next_Bullet2_Bulllet_Impact ; �᫨ ���	�� ����,
					; ���室�� � ᫥���饩
		LDA	Bullet_X,Y
		SEC
		SBC	Bullet_X,X
		BPL	CheckMinX_BulletImpact ; ��।��塞 ����ﭨ� �� �
					; �����	2-�� ��ﬨ
		EOR	#$FF
		CLC
		ADC	#1

CheckMinX_BulletImpact:			; CODE XREF: BulletToBullet_Impact_Handle+36j
		CMP	#6
		BCS	Next_Bullet2_Bulllet_Impact ; �᫨ >6, ���室�� � ᫥���饩
		LDA	Bullet_Y,Y
		SEC
		SBC	Bullet_Y,X
		BPL	CheckMinY_BulletImpact ; �᫨ <	6 , � �஢��塞 ����ﭨ� �� Y
					; �����	���� ��ﬨ
		EOR	#$FF
		CLC
		ADC	#1

CheckMinY_BulletImpact:			; CODE XREF: BulletToBullet_Impact_Handle+47j
		CMP	#6
		BCS	Next_Bullet2_Bulllet_Impact ; �᫨ >6, � ���室�� � ᫥���饩
		LDA	#0
		STA	Bullet_Status,X
		STA	Bullet_Status,Y	; ����⮦��� ��� �㫨

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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠡ��뢠�� ���⨥ �����, �᫨ ⠪���� ����

Bonus_Handle:				; CODE XREF: Battle_Loop+27p
					; Bonus_Appear_Handle+21p
		LDA	Bonus_X
		BEQ	End_Bonus_Handle
		LDA	BonusPts_TimeCounter
		BNE	End_Bonus_Handle
		LDA	#7		;! ��稭��� � ��᫥����� �ࠦ�᪮�� ⠭�� (��������� ��ࠡ�⪠ ����� �ࠦ�᪨�� ⠭���� �����)
		STA	Tank_Num	; �����	⠭�� ��ப�, �� ��ࠡ�⪥ ����� �����

-:					; CODE XREF: Bonus_Handle+6Dj
		LDX	Tank_Num	; �����	⠭�� ��ப�, �� ��ࠡ�⪥ ����� �����
		LDA	Tank_Status,X
		BPL	+		; ���室�� � ᫥���饬� ⠭��
		CMP	#$E0 ; '�'
		BCS	+		; �᫨ ⠭� ���ࢠ� ���	�ᯠ㭨���,
					; �� ��ᬠ�ਢ��� ���
		LDA	Tank_X,X
		SEC
		SBC	Bonus_X
		BPL	+++
		EOR	#$FF
		CLC
		ADC	#1		; ���᫥��� ����ﭨ�	��
					; ⠭��	�� ����� �� �

+++:					; CODE XREF: Bonus_Handle+1Bj
		CMP	#$C
		BCS	+		; ���室�� � ᫥���饬� ⠭��
		LDA	Tank_Y,X
		SEC
		SBC	Bonus_Y
		BPL	++
		EOR	#$FF
		CLC
		ADC	#1		; ���᫥��� ����ﭨ�	��
					; ⠭��	�� ����� �� Y

++:					; CODE XREF: Bonus_Handle+2Bj
		CMP	#$C
		BCS	+		; ���室�� � ᫥���饬� ⠭��
		LDA	#$32 ; '2'      ; �६� �⮡ࠦ���� �窮� �� ����� (�३��)
		STA	BonusPts_TimeCounter
		LDA	Bonus_Number	; ��।���� ⨯ �����
		BMI	End_Bonus_Handle
		LDA	Level_Mode
		CMP	#2		; � ०��� ����	�஢�� �窨 �� �ਡ��������
		BEQ	Bonus_Command	; �ந������ ����⢨� �����
		LDA	#$50 ; 'P'      ; 500 �窮� ������ �� �����
		JSR	Num_To_NumString ; ��ॢ���� �᫮ �� �	� ��ப� NumString
		LDX	Tank_Num	; �����	⠭�� ��ப�, �� ��ࠡ�⪥ ����� �����
		JSR	Add_Score	; �ਡ����� �᫮ �� NumString	� �窠�	��ப� ��
		JSR	Add_Life	; �ਡ����� ���� �����, �᫨ ��ப ��ࠡ�⠫ 200� �窮�
		LDX	Tank_Num	; �����	⠭�� ��ப�, �� ��ࠡ�⪥ ����� �����
		LDA	#1
		STA	Snd_BonusTaken	; �ந��뢠�� ������� �� ���⨥	�����

Bonus_Command:				; CODE XREF: Bonus_Handle+42j
		LDA	Bonus_Number	; �ந������ ����⢨� �����
		ASL	A		; �����⥫� ���塠�⮢�
		TAY
		LDA	Bonus_JumpTable,Y
		STA	LowPtr_Byte
		LDA	Bonus_JumpTable+1,Y
		STA	HighPtr_Byte
		PLA
		PLA
		JMP	(LowPtr_Byte)
; ���������������������������������������������������������������������������

+:					; CODE XREF: Bonus_Handle+10j
					; Bonus_Handle+14j Bonus_Handle+24j
					; Bonus_Handle+34j
		DEC	Tank_Num	; ���室�� � ᫥���饬� ⠭��
		BPL	-

End_Bonus_Handle:			; CODE XREF: Bonus_Handle+2j
					; Bonus_Handle+6j Bonus_Handle+3Cj
		RTS
; End of function Bonus_Handle

; ���������������������������������������������������������������������������
Bonus_JumpTable:.WORD Bonus_Helmet	; DATA XREF: Bonus_Handle+5Cr
					; Bonus_Handle+61r
					; ������� ���� ����� ⠭��, � �᫨ ��� �ࠣ, ���⠢��� ������ �஭� � ��������� ����᭮���.
		.WORD Bonus_Watch	; ��⠭��������	��� �ࠣ��, � �᫨ ��� �ࠣ, ��⠭�������� ��ப��.
		.WORD Bonus_Shovel	; ��ந� �஭� ����� �⠡� ��� 㡨ࠥ� ���� ��௨�
		.WORD Bonus_Star	; ��ॢ���� ��ப� ��� ��� �ࠣ�� � ᫥���騩 ���
		.WORD Bonus_Grenade	; ���뢠�� ���	�ࠣ�� ��� ��ப��
		.WORD Bonus_Life	; �����	��� ⠭��. �ਡ����� ���� ����� ��� ���� �ࠦ�᪨� ⠭��� � �����
		.WORD Bonus_Pistol	; �� �ᯮ������ � ��祣� �� ������, ������ ����� ᢮�	������ �����
; ���������������������������������������������������������������������������

Bonus_Helmet:				; DATA XREF: ROM:Bonus_JumpTableo
					; ������� ���� ����� ⠭��, � �᫨ ��� �ࠣ, ���⠢��� ������ �஭� � ��������� ����᭮���.
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
                CPX     #1; �� ��ண� ��ப� �� �������� (1<x<8)
                BNE     -
                PLA
                TAX
                RTS

Players_Helmet:
		LDA	#10		
		STA	Invisible_Timer,X ; ������� ���� �����	��ப� ��᫥ ஦�����
		RTS
; ���������������������������������������������������������������������������

Bonus_Watch:				; DATA XREF: ROM:E9E4o
					; ��⠭��������	��� �ࠣ��, � �᫨ ��� �ࠣ, ��⠭�������� ��ப��.
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
; ���������������������������������������������������������������������������

Bonus_Shovel:	; ��ந� �஭� ����� �⠡� ��� 㡨ࠥ� ���� ��௨�

		LDA	HQ_Status	
		BPL	End_Bonus_Shovel
                CPX     #2
		BCC     Players_Shovel

		JSR	Draw_ShovelHQ		
		RTS


Players_Shovel:			
		JSR	Draw_ArmourHQ	; ����� �⠡ �	�஭��
		LDA	#20
		STA	HQArmour_Timer	; ������ �஭� ����� �⠡�

End_Bonus_Shovel:			; CODE XREF: ROM:E9FDj
		RTS
; ���������������������������������������������������������������������������

Bonus_Star:		;��ॢ���� ��ப� � ᫥���騩 ���, �᫨ ��� �ࠣ, ���३��� ��� �ࠣ�� �� �࠭� � �������� ���� �� �஭�.	


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
		BEQ	End_Bonus_Star	; �᫨ ���⨣��� ���ᨬ���� ���, ��室��
		CLC
		ADC	#$20 ; ' '      ; ������ ⠭� ᫥���騬 �����
		STA	Player_Type,X	; ��� ⠭�� ��ப�
		STA	Tank_Type,X

End_Bonus_Star:				; CODE XREF: ROM:EA0Cj
		RTS
; ���������������������������������������������������������������������������

Bonus_Grenade:
		LDA	#1
		STA	Snd_EnemyExplode
		CPX	#2
		BCC	Players_Grenade

		LDA	#1
		STA	Counter
		LDA	#$FF
		STA	Counter2	;��⠭���������� ����� ���ࢥ� ��� ��ப��
		JMP 	Bonus_Grenade_Loop
    




Players_Grenade:
		LDA	#7		; ���뢠�� ���	�ࠣ��
		STA	Counter		; ��稭��� � ��᫥�����	�ࠣ�
		LDA	#1
		STA	Counter2	;��⠭���������� �� ��ப��

Bonus_Grenade_Loop:			; CODE XREF: ROM:EA3Bj
		LDY	Counter
		LDA	Tank_Status,Y
		BPL	Explode_Next
		CMP	#$E0 ; '�'
		BCS	Explode_Next	; �᫨ �ࠣ ���뢠���� ��� �ᯠ㭨���,	�� ���뢠�� ���
		LDA	#$73 ; 's'      ; ���뢠�� ⠭�
		STA	Tank_Status,Y
		LDA	#0
		STA	Tank_Type,Y

Explode_Next:				; CODE XREF: ROM:EA25j	ROM:EA29j
		DEC	Counter
		LDA	Counter
		CMP	Counter2	; ��ப�� �� ���뢠��
		BNE	Bonus_Grenade_Loop
		RTS
; ���������������������������������������������������������������������������

Bonus_Life:		;�������� ����� ��ப�, �᫨ ��� �ࠣ, 㢥��稢��� ������⢮ �ࠣ�� � ����� �� ����.

		CPX #2
		BCC Players_Life

		CLC	; !᫥���騩 ADC ��ࠧ��뢠� ��譨� ⠭� ��� ���⪨ ��७��, bugfix
		LDA	Enemy_Reinforce_Count
		ADC	#5		
		STA	Enemy_Reinforce_Count
		LDA	Enemy_Counter
		ADC	#5		
		STA	Enemy_Counter
		JSR	Draw_Reinforcemets
		
		
		RTS

Players_Life:				
		INC	Player1_Lives,X	; �����	��� ⠭��. �ਡ����� ���� �����
		LDA	#1
		STA	Snd_Ancillary_Life1
		STA	Snd_Ancillary_Life2 ; �ந��뢠�� ��� �१ ��� ������

Bonus_Pistol:				; DATA XREF: ROM:E9EEo
		RTS			; �� �ᯮ������ � ��祣� �� ������, ������ ����� ᢮�	������ �����
; ���������������������������������������������������������������������������
;�����, �易��� � ���ᮢ���	�㫨
;����㦠���� $E622 (⠪�� �� ���ᨢ �� ����� $D3D5)
Bullet_Coord_X_Increment_2:.BYTE 0, $FF, 0, 1 ;	DATA XREF: Bullet_Fly_Handle+1Er
;����㦠���� $E632
Bullet_Coord_Y_Increment_2:.BYTE $FF, 0, 1, 0 ;	DATA XREF: Bullet_Fly_Handle+2Er



; ��������������� S U B	R O U T	I N E ���������������������������������������


Load_Level:				; CODE XREF: ROM:C1D9p
					; Load_DemoLevel+20p

;! �஢��塞 �㦥� �� ��砩�� �஢��� �, �᫨ ��, ����㦠�� ���⮩ (����� 101)
		ldx Random_Level_Flag
		Beq ++++
		Lda #101
		jmp Begin
++++
				
		CMP	#$FF
		BNE	Begin
		LDA	#100 ; '$'      ; ����-�஢���
		JMP	Begin
; ���������������������������������������������������������������������������


Begin:					; CODE XREF: Load_Level+6j
					; Load_Level+Bj
		STA	Temp
		LDA	#>Level_Data
		STA	HighPtr_Byte
		LDA	#<Level_Data	; ���訩 � ����訩 ����� 㪠��⥫�
					; �� ��砫� ����� �஢���
		STA	LowPtr_Byte

-:					; CODE XREF: Load_Level+23j
		DEC	Temp
		BEQ	+
		LDA	#$5B ; '['      ; 5b-ࠧ��� ������ ������ �஢��
		JSR	Inc_Ptr_on_A
		JMP	-
; ���������������������������������������������������������������������������

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
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
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
; ���������������������������������������������������������������������������

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
		CMP	#$E0 ; '�'
		BNE	---
		INC	Counter
		LDA	Block_Y
		CLC
		ADC	#$10
		STA	Block_Y
		CMP	#$E0 ; '�'
		BNE	--
		RTS
; End of function Load_Level

; ��������������� S U B	R O U T	I N E ���������������������������������������

Draw_Random_Level:;! ����� ��������� � ���⮩ �஢��� (���� ����ਭ� �� ��௨砬)
;���� ⠪��: ������� ��� ⨯� ����ਭ⮢:
;1) ����ࠫ�� ����ਭ�, ����� ॠ������� �� ��� ���⠭���� ���⮣� ����� �� ��砩��� ����. �祭� ��ᨢ�, �� �ࠣ� ���� �������
; �� ᬮ��� �������� �� �⠡� � ��� �ॢ�頥��� ���� � ����५ �ࠣ��
;2) ���� � ����让 "⠭毫�頤���" ���।���, ॠ���������� �� ��� ���ᮢ�� ����묨 ������� ����� 䨪�஢����� �ਭ� ��
;��砩�� ���ࠢ�����
;����� ⨯ �롨ࠥ��� ��砩��, � ��⥬ ��᫥ ��� ॠ����樨, �ந�������� �����⨢��� ���ᮢ�� ��砩�묨 ������� �� �ᥩ ����.


Line_TSA_Count_Begin = 5; ������⢮ TSA � ����� ����� ����ਭ�
Space_Count = $FF; ������⢮ ������ TSA � ����ਭ�
Misc_Count = $12; ������⢮ ���������� ������ � ����ਭ�

	jsr NMI_Wait
	LDA	#00110000b ; �⪫�砥� NMI �� VBlank'� - ����, �஢��� �㤥� ���ᮢ�� ������ �࠭� �롮� �஢��.
	STA	PPU_CTRL_REG1

	Lda #Space_Count
	Sta Counter; ����ਭ� �㤥� ������ �� Counter ������

	Lda #$80
	Sta Block_X
	Sta Block_Y
	
	jsr Get_Random_A
	And #$80
	Bne Draw_Lab; ��।��塞 ����� ⨯ ����� �㤥� �ᮢ���
-
	JSR Draw_DanceFloor
	; ��᫥ ��� �஢�ப � ���᫥��� ���न���, ��㥬.
	Lda #$F; ���⮥ ����
	LDX	Block_X
	LDY	Block_Y
	Jsr Draw_TSABlock
	Dec Counter
	Bne -
	JMP Decorate
Draw_Lab:
	JSR Draw_Labyrinth
	; ��᫥ ��� �஢�ப � ���᫥��� ���न���, ��㥬.
	Lda #$F; ���⮥ ����
	LDX	Block_X
	LDY	Block_Y
	Jsr Draw_TSABlock
	Dec Counter
	Bne Draw_Lab
	
	

Decorate
;��᫥ ���ᮢ�� ��।�������� ⨯� ����ਭ�, ��饥 ��� ��� �����஢���� �஢�� ࠧ�묨 �������:

	lda #Misc_Count
	sta Counter; ������⢮ ���������� ������ � ����ਭ�
---
	JSR Draw_Labyrinth
--
	jsr Get_Random_A 
	And #$F
	cmp #$D; ���砩�� ���� ��易� ���� #$9<x<=#$0C - �⮡� �� 稭��� �९���⢨� � 㦥 ᮧ������ �����
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

; ���������������������������������������������������������������������������
Check_Bounds:; �஢���� �� ��諮 �� �� �࠭��� �࠭� (10<X<E0), �᫨ ���, �����頥� ����.

ldx #0
-
LDA Block_X,x; Block_X � Block_Y ���� ��� �� ��㣮�.
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


; ���������������������������������������������������������������������������
Draw_DanceFloor:; ����� ⠭毫�頤��

	lda #Line_TSA_Count_Begin
	Sta Line_TSA_Count; ����� ����ਭ� �㤥� ������ �� Line_TSA_Count_Begin ������ ������	

---
	Ldy #0; ��稭��� � ���न���� �, ��⮬ ��३��� � ᫥���饩 �祩�� (���न��� Y)

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
	lda Block_X,y ; �᫨ > $AA, � 㢥��稢��� ���न����
	clc
	adc #$10
	Sta Block_X,y
	jmp ++

+
	cmp #$55
	bcc ++
	lda Block_X,y; �᫨ <$AA � >$55 , � 㬥��蠥� ���न����
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


; ���������������������������������������������������������������������������
Draw_Labyrinth:; ����� ����ਭ�

	Ldy #0; ��稭��� � ���न���� �, ��⮬ ��३��� � ᫥���饩 �祩�� (���न��� Y)

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

; ����� ������� ��௨��� ������� � ४�म�

; ��������������� S U B	R O U T	I N E ���������������������������������������
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
		LDA	#>aCongrats	; �뢮����� � ���� ��௨筮� ������, �᫨ ४��
		STA	HighStrPtr_Byte
		LDA	#<aCongrats	; �뢮����� � ���� ��௨筮� ������, �᫨ ४��
		STA	LowStrPtr_Byte
		JSR	Draw_BrickStr
		JSR	Store_NT_Buffer_InVRAM ; ����뢠�� �� �࠭ ᮤ�ন���	NT_Buffer
		JSR	Set_PPU
		LDA	#0
		STA	Seconds_Counter
		LDA	#1
		STA	Snd_RecordPts1
		STA	Snd_RecordPts2
		STA	Snd_RecordPts3

-:					; CODE XREF: Draw_Record_HiScore+4Aj
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	Frame_Counter
		AND	#3
		CLC
		ADC	#5
		STA	BkgPal_Number	; ������� ������
		LDA	Snd_RecordPts1
		BNE	-		; ���,	���� ��	������� �����	�������	४�ठ
		LDA	#0
		STA	BkgPal_Number
		RTS
; End of function Draw_Record_HiScore






