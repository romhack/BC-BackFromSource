;                               Griever's Stuff
;                    -=#Battle City - Back From Source#=-


	INCLUDE RAM.asm; ���ᠭ�� ��� ��६����� �뭥ᥭ� � �⤥��� 䠩�.
	INCLUDE REGS.asm; �������� �뭥ᥭ� � �⤥��� 䠩�.

; ���������������������������������������������������������������������������
; ��������� �ଠ� iNES:
	.BYTE 'NES',$1A ;String "NES^Z" used to recognize .NES files
	.BYTE	2       ;Number of 16kB ROM banks.
	.BYTE	1       ;Number of 8kB VROM banks.
	 DSB 10,0   


; ���������������������������������������������������������������������������
$ = $8000

INCLUDE Level.asm; � ���孥� ���� ���� �஢��.

PAD $C000; � ������ ����  - ���.
; ���������������������������������������������������������������������������

; Segment type:	Pure code

StaffString:	.BYTE 'RYOUITI OOKUBO  TAKEFUMI HYOUDOUJUNKO OZAWA     '
					; DATA XREF: StaffStr_Store:-r
					; StaffStr_Check+5r
; ���������������������������������������������������������������������������

RESET:					; DATA XREF: ROM:FFFCo	ROM:FFFEo
		SEI
		LDA	#00010000b
		STA	PPU_CTRL_REG1	; ���㭤� ��ன ������������
		CLD
		LDX	#2

Wait:					; CODE XREF: ROM:C07Cj	ROM:C084j
		LDA	PPU_STATUS	; PPU Status Register (R)
		BPL	Wait
		LDA	#00000110b
		STA	PPU_CTRL_REG2	; PPU Control Register #2 (W)
		DEX
		BNE	Wait
		LDX	#$7F ; ''      ; ���設� �⥪�
		TXS
		JSR	Reset_ScreenStuff
		LDA	#0
		STA	Scroll_Byte
		STA	PPU_REG1_Stts
		JSR	Set_PPU

BEGIN:					; CODE XREF: ROM:Skip_RecordShowj
		JSR	Draw_TitleScreen
		LDA	#0
		STA	Construction_Flag ; ���� � Construction	�� ��室���

; START	OF FUNCTION CHUNK FOR BonusLevel_ButtonCheck

New_Scroll:				; CODE XREF: BonusLevel_ButtonCheck-372j
		JSR	Null_Upper_NT
		JSR	Scroll_TitleScrn ; ���ࠥ� �� ���孥� (0(1)) ⠩����� ����� �஢��� �
					; �஫��� �� ���쭨�	� ������ (2(3))⠩�����	����.

Title_Loaded:				; CODE XREF: ROM:C156j
					; BonusLevel_ButtonCheck+2Bj
					; Scroll_TitleScrn+1Aj
		JSR	Title_Screen_Loop
		JSR	Load_DemoLevel
		JSR	BonusLevel_ButtonCheck ; �������.
		JMP	New_Scroll	; ��᫥	����砭�� �����	�஢��,	������ �஫���㥬 ���쭨�.
; END OF FUNCTION CHUNK	FOR BonusLevel_ButtonCheck
; ���������������������������������������������������������������������������

Construction:				; CODE XREF: ROM:CA82j
		LDA	Construction_Flag ; ���⠢�����, �᫨ ��諨 � Construction
		BNE	Skip_LoadFrame	; �᫨ 㦥 ��室��� � Construction, ࠬ�� 㦥 ���ᮢ���
		JSR	Screen_Off
		JSR	Make_GrayFrame
		JSR	Store_NT_Buffer_InVRAM ; ����뢠�� �� �࠭ ᮤ�ন���	NT_Buffer
		JSR	Set_PPU

Skip_LoadFrame:				; CODE XREF: ROM:C0B0j
		JSR	Null_Status
		LDA	#$10
		STA	Tank_X
		LDA	#$18
		STA	Tank_Y		; ��砫쭠� ������ ⠭�� �� �࠭�
		LDA	#$84 ; '�'
		STA	Tank_Status	; �㫮�	�����
		LDA	#0
		STA	Tank_Type
		STA	Spr_Attrib
		STA	Track_Pos
		STA	BkgOccurence_Flag
		STA	byte_7B
		STA	TSA_BlockNumber
		STA	Scroll_Byte
		STA	PPU_REG1_Stts
		STA	Player_Blink_Timer ; ������ ������� friendly fire
		STA	Player_Blink_Timer+1 ; ������ ������� friendly fire
		LDA	Construction_Flag ; ���⠢�����, �᫨ ��諨 � Construction
		BNE	Construction_Loop
		JSR	DraW_Normal_HQ	; �᫨ 㦥 ��室��� � Construction, �⠡ 㦥 ���ᮢ��

Construction_Loop:			; CODE XREF: ROM:C0E5j	ROM:C14Dj
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		JSR	Move_Tank	; ������� ⠭� � ����ᨬ��� ��	�������	������
		JSR	Check_BorderReach ; �� ���� ⠭�� ���	�� �࠭��� �ன ࠬ��
		LDA	Frame_Counter
		AND	#$10
		BEQ	Skip_Status_Handle
		JSR	TanksStatus_Handle ; ��ࠡ��뢠�� ������ ��� 8-�� ⠭���

Skip_Status_Handle:			; CODE XREF: ROM:C0F7j
		LDA	Joypad1_Buttons
		AND	#$F0 ; '�'
		BNE	loc_C13E
		LDA	Joypad1_Differ
		AND	#1
		BEQ	loc_C120
		LDA	BkgOccurence_Flag
		BNE	loc_C111
		INC	BkgOccurence_Flag
		JMP	Construct_Draw_TSA
; ���������������������������������������������������������������������������

loc_C111:				; CODE XREF: ROM:C10Aj
		INC	TSA_BlockNumber
		LDA	TSA_BlockNumber
		CMP	#$E
		BNE	Construct_Draw_TSA
		LDA	#0
		STA	TSA_BlockNumber
		JMP	Construct_Draw_TSA
; ���������������������������������������������������������������������������

loc_C120:				; CODE XREF: ROM:C106j
		LDA	Joypad1_Differ
		AND	#2
		BEQ	loc_C13E
		LDA	BkgOccurence_Flag
		BNE	loc_C12F
		INC	BkgOccurence_Flag
		JMP	Construct_Draw_TSA
; ���������������������������������������������������������������������������

loc_C12F:				; CODE XREF: ROM:C128j
		DEC	TSA_BlockNumber
		LDA	TSA_BlockNumber
		CMP	#$FF
		BNE	Construct_Draw_TSA
		LDA	#$D		; $D - ���� ���⮩ ����
		STA	TSA_BlockNumber
		JMP	Construct_Draw_TSA
; ���������������������������������������������������������������������������

loc_C13E:				; CODE XREF: ROM:C100j	ROM:C124j
		LDA	Joypad1_Buttons
		AND	#3		; �� ����⨨ �	��� � ������ ���� ���	⠭���
		BEQ	Construct_StartCheck

Construct_Draw_TSA:			; CODE XREF: ROM:C10Ej	ROM:C117j
					; ROM:C11Dj ROM:C12Cj	ROM:C135j
					; ROM:C13Bj
		JSR	Draw_TSA_On_Tank ; ����� TSA ���� ��� ⠭���

Construct_StartCheck:			; CODE XREF: ROM:C142j
		LDA	Joypad1_Differ
		AND	#8
		BNE	End_Construction ; �᫨	����� ����, ��室��
		JMP	Construction_Loop
; ���������������������������������������������������������������������������

End_Construction:			; CODE XREF: ROM:C14Bj
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		INC	Construction_Flag ; ����砥�, �� ��諨	� Construction
		JMP	Title_Loaded

; ���������������������������������������������������������������������������

Start_StageSelScrn:			; CODE XREF: ROM:C280j	ROM:CA7Bj
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		JSR	Sound_Stop	; ��⠭��������	���, ����砥� ������ �	�.�. (�������筮 Load �	NSF �ଠ�)
		LDA	#$1C
		STA	PPU_Addr_Ptr	; ������ �㤥� � ������ NT
		LDA	#0
		STA	Scroll_Byte
		STA	PPU_REG1_Stts
		STA	Pause_Flag
		LDA	#4
		STA	BkgPal_Number


		JSR	FillNT_with_Grey ; ᮧ���� ��䥪� �室����� ���⨪����� �⢮ப

StageSelect_Loop:			; CODE XREF: ROM:C19Bj	ROM:C1A1j
					; ROM:C1AEj ROM:C1B4j	ROM:C1BCj
					; ROM:C1C2j
;!��।��塞 �㦥� �� ��� �஢��� � ���ᮬ (����� ���쬮� �஢���)
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
;! �ࠧ� ��稭��� �஢��� - ���� ��直� �஢�ப �� ������ ��� 䫠�� ��砫� ����.

; ���������������������������������������������������������������������������
Start_Level:				; CODE XREF: ROM:C177j	ROM:C17Dj
Init_Boss_Armour = #10



		LDA	Construction_Flag ; ���⠢�����, �᫨ ��諨 � Construction
		BNE	Skip_Lvl_Load	; �᫨ ���뢠��	� Construction,	�
					; ����� �஢��	����㦠���� �� ���� (��� 㦥 �	NT_Buffer)
					; (⮫쪮 ⠭��	� �⠡)


;! ��।��塞 ����� �஢��� �㦭� ����㧨��: ����� ��� ��砩��.
Get_Map_Mode:
		Lda Map_Mode_Pos
		BEQ Orig_Map
		CMP #2			
		BCC Random_Map
		
		JSR Get_Random_A	;��࠭ �㭪� Mixed
		AND #1
		JMP Make_Gray_Frame
		
Orig_Map:
		LDA #0			;��࠭ �㭪� Original
		JMP Make_Gray_Frame
Random_Map:
		LDA #1			;��࠭ �㭪� Random
		


Make_Gray_Frame:
		STA Random_Level_Flag
		JSR	Make_GrayFrame
		LDA	Level_Number
		JSR	Load_Level; ��� �㤥� �஢�७ 䫠� ��砩���� � �᫨ �㦭�, ����㦥� ���⮩ �஢���
;!�஢��塞 䫠� � �᫨ ���� ��㥬 �� ���⮬ �஢�� ����ਭ�.
		ldx Random_Level_Flag
		Beq ++++
		jsr Draw_Random_Level
++++



		JSR	DraW_Normal_HQ	; ����� �⠡ �	��௨砬�
		JMP	+
; ���������������������������������������������������������������������������

Skip_Lvl_Load:				; CODE XREF: ROM:C1D2j
		JSR	Draw_Naked_HQ	; ���� �᫨ �⠡ �� ���ᮢ�� � Construction, �� �㤥�	������

+:
		LDA	#1
		STA	Snd_Battle1
		STA	Snd_Battle2
		STA	Snd_Battle3	; �ந��뢠�� ������� ���

					; CODE XREF: ROM:C1DFj
		LDA	#0
		STA	ScrBuffer_Pos
		JSR	Copy_AttribToScrnBuff
		JSR	FillNT_with_Black ; ������� ��䥪� ��室�����	���⨪����� �⢮ப
		LDA	#0
		STA	BkgPal_Number
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		JSR	SetUp_LevelVARs

Battle_Engine:				; CODE XREF: ROM:C221j
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	Pause_Flag
		BNE	Skip_Battle_Loop ; � ०��� ���� �� �㦭� ��ࠡ��뢠��	⠭��, ����� � �.�.
		JSR	Battle_Loop	; �᭮��� ����樨 � ⠭���� �	��ﬨ

Skip_Battle_Loop:			; CODE XREF: ROM:C1FEj
		JSR	Bonus_Draw	; ����� ��� ������ ��� ����� ��� �窨	�� �����
		JSR	Draw_All_BulletGFX ; ����� ��	�㫨
		JSR	TanksStatus_Handle ; ��ࠡ��뢠�� ������ ��� 8-�� ⠭���
		LDA	Joypad1_Differ
		AND	#8		; �஢�ઠ �� ����⨥ ����
		BEQ	Skip_Pause_Switch
		LDA	#1
		EOR	Pause_Flag
		STA	Pause_Flag	; ��४��砥� 䫠� ���� �� ��⨢��������
		STA	Snd_Pause

Skip_Pause_Switch:			; CODE XREF: ROM:C210j
		JSR	Draw_Pause	; ����� �������� �������, � ��砥 �᫨ ���⠢���� ��㧠
		JSR	LevelEnd_Check	; if ExitLevel then A=1
		BEQ	Battle_Engine
		LDA	#0
		STA	Seconds_Counter
		STA	Frame_Counter	; ��⠭��������	⠩����
		STA	Snd_Move
		STA	Snd_Engine	; ��⠭��������	��㪨
		LDA	GameOverStr_Timer
		BEQ	AfterDeath_BattleRun
		LDA	#$FE ; '�'
		STA	Seconds_Counter

AfterDeath_BattleRun:			; CODE XREF: ROM:C232j	ROM:C251j
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		JSR	FreezePlayer_OnHQDestroy ; ��蠥� ��ப� ����������, �᫨ �⠡	ࠧ��襭
		JSR	Battle_Loop	; �᭮��� ����樨 � ⠭���� �	��ﬨ
		JSR	Bonus_Draw	; ����� ��� ������ ��� ����� ��� �窨	�� �����
		JSR	TanksStatus_Handle ; ��ࠡ��뢠�� ������ ��� 8-�� ⠭���
		JSR	Draw_All_BulletGFX ; ����� ��	�㫨
		JSR	Swap_Pal_Colors	; ��ਮ���᪮�	�������	- ��䥪� ���� �� 01 ������
		LDA	Seconds_Counter
		CMP	#2		; 2 ���㭤� ��ন��� ����������� ������� GameOver c ����஦���� ��ப��
		BNE	AfterDeath_BattleRun
		JSR	Sound_Stop	; ��⠭��������	���, ����砥� ������ �	�.�. (�������筮 Load �	NSF �ଠ�)
		JSR	Draw_Pts_Screen



 
Check_GameOver:				; CODE XREF: ROM:C26Dj
		LDA	Player1_Lives
		CLC
		ADC	Player2_Lives
		BEQ	Make_GameOver	; �᫨ ������ �� � ����	�� ��⠫���, ��������
		LDA	HQ_Status	; 80=�⠡ 楫, �᫨ ���� � 㭨�⮦��
		CMP	#$80 ; '�'
		BNE	Make_GameOver	; �᫨ �⠡ ࠧ��襭, ��������
		INC Level_Number   ;! �����稢��� �ᥢ������� �஢�� (�� 99-�)

		LDA Level_Number
		Cmp #51
		BCC Skip_Make_Hard
		LDA	#1
		STA	Level_Mode

Skip_Make_Hard:
		LDA Level_Number
		CMP #100
		BCC Continue_Game
		Lda #1                ;�⮡ࠦ��� 䨭���� �࠭.
		STA Level_Number
		LDA	#0
		STA	Level_Mode

                JSR     Draw_Congrats ; ����� ������� ��௨��� ������� � ����ࠢ������
                JSR     Clear_NT        ; ��頥� ������ ����� ⠩��� (���쭨� �㤥� � ������)
                JMP     BEGIN

Continue_Game:		
		JMP	Start_StageSelScrn ; �᫨ �� ��諨 �� �஢�� ������⥫ﬨ, � ���室��	� ᫥���饬� �஢��
; ���������������������������������������������������������������������������

Make_GameOver:
		LDA #0
		STA Boss_Mode				; CODE XREF: ROM:C278j	ROM:C27Ej
		JSR	Draw_Brick_GameOver ; ����� ������� ��௨��� ������� GameOver

;! �᫨ �ந��襫 ��������, � �⪠�뢠���� �� 5 �஢��� �����, �।���⥫쭮 �஢�ਢ ᠬ ����� �஢��.
		Lda Level_Number
		CMP #6
		BCC +; �᫨ ����� �஢�� ����� 6, � �⭨���� 5 �஢��� �����.
		SEC
		SBC #5
		STA Level_Number

+
		JSR	Update_HiScore	; �� ��室� A =	$FF, ����� ���� ४��
		TYA
		BEQ	Skip_RecordShow
		JSR	Draw_Record_HiScore ; ����� ������� ��௨��� ������� � ४�म�
		JSR	Clear_NT	; ��頥� ������ �����	⠩��� (���쭨� �㤥�	� ������)

Skip_RecordShow:			; CODE XREF: ROM:C28Aj
		JMP	BEGIN

; ��������������� S U B	R O U T	I N E ���������������������������������������


Clear_NT:				; CODE XREF: ROM:C28Fp
		JSR	Screen_Off
		JSR	Null_NT_Buffer
		JSR	Store_NT_Buffer_InVRAM ; ����뢠�� �� �࠭ ᮤ�ন���	NT_Buffer
		JSR	Set_PPU
		RTS
; End of function Clear_NT


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��蠥� ��ப�	����������, �᫨ �⠡ ࠧ��襭

FreezePlayer_OnHQDestroy:		; CODE XREF: ROM:C23Bp
		LDA	HQ_Status	; 80=�⠡ 楫, �᫨ ���� � 㭨�⮦��
		CMP	#$80 ; '�'
		BEQ	+
		LDA	#0
		STA	Joypad1_Buttons
		STA	Joypad2_Buttons
		STA	Joypad1_Differ
		STA	Joypad2_Differ

+:					; CODE XREF: FreezePlayer_OnHQDestroy+4j
		RTS
; End of function FreezePlayer_OnHQDestroy


; ��������������� S U B	R O U T	I N E ���������������������������������������


Null_both_HiScore:			; CODE XREF: ROM:CA78p
		LDX	#HiScore_1P_String
		JSR	Null_8Bytes_String
		LDX	#HiScore_2P_String
		JSR	Null_8Bytes_String
; End of function Null_both_HiScore


; ��������������� S U B	R O U T	I N E ���������������������������������������


Init_Level_VARs:			; CODE XREF: Load_DemoLevel+8p
		LDA	#0
		STA	Player_Type	; ��� ⠭�� ��ப�
		STA	Player_Type+1	; ��� ⠭�� ��ப�
		LDA	#0
		STA	AddLife_Flag	;  <>0 - ��ப ����砫 �������⥫��� �����
		STA	AddLife_Flag+1	;  <>0 - ��ப ����砫 �������⥫��� �����
		STA	EnterGame_Flag	; �᫨ 0, � ����� ����� �஢���
		LDA	#6		; ��砫쭮� ������⢮ ������
		STA	Player1_Lives
		STA	Player2_Lives
		STA	EnemyRespawn_PlaceIndex
		LDA	CursorPos
		BNE	+
		LDA	#0		; �᫨ 2 ��ப�	���, ����塞 ��� �����
		STA	Player2_Lives

+:					; CODE XREF: Init_Level_VARs+1Aj

		
		LDA	#0		; Game Over �㤥� �⮡ࠦ�����
		STA	Level_Mode
		RTS
; End of function Init_Level_VARs


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �᭮��� ����樨 � ⠭���� �	��ﬨ

Battle_Loop:				; CODE XREF: ROM:C200p	ROM:C23Ep
					; BonusLevel_ButtonCheck+Cp
		JSR	Ice_Detect	; ��ࠡ��뢠�� ��ப�, �᫨ ��	�� ���
		JSR	Ice_Move	; �믮���� ᪮�즥���,	�᫨ ⠭� ��������� �� ���
		JSR	Motion_Handle	; ����ࠦ����� �ࠣ��, �᫨ �㦭� (��ࠡ�⪠ ��������)
		JSR	HideHiBit_Under_Tank
		JSR	AllBulletsStatus_Handle	; ��ࠡ��뢠�� ������ ��� ���
		JSR	HQ_Handle	; ��ࠡ��뢠�� ����� �	�஭� �⠡�
		JSR	Invisible_Timer_Handle ; �����	ᨫ����	����, �᫨ �㦭�
		JSR	Make_Player_Shot ; ������ ����५ ��ப�, �᫨ ����� ������
		JSR	Make_Enemy_Shot	; �ந������ ����५, �ᯮ����	��砩�� �᫠
		JSR	Respawn_Handle
		JSR	Bullet_Fly_Handle ; ��ࠡ��뢠�� ����� �㫨 (�⮫�������� � �.�.)
		JSR	BulletToBullet_Impact_Handle ; ��ࠡ��뢠�� �⮫�������� ���� ���, �᫨ ��� ����
		JSR	BulletToTank_Impact_Handle ; ��ࠡ��뢠�� �⮫�������� �㫨 � ⠭���
		JSR	Bonus_Handle	; ��ࠡ��뢠�� ���⨥ �����, �᫨ ⠪���� ����
		JSR	GameOver_Str_Move_Handle ; �뢮��� ������� Game	Over �᫨ �㦭�
		JSR	Play_Snd_Move	; ��ࠥ� � ���� ��� �������� ����� �㦭�
		JSR	Draw_Player_Lives ; ����� IP/IIP � �᫮ ������ � �ࠢ�� 㣫�
		JSR	Swap_Pal_Colors	; ��ਮ���᪮�	�������	- ��䥪� ���� �� 01 ������
		RTS
; End of function Battle_Loop


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ਮ���᪮�	�������	- ��䥪� ���� �� 01 ������

Swap_Pal_Colors:			; CODE XREF: ROM:C24Ap	Battle_Loop+33p
		LDA	Frame_Counter
		AND	#$3F ; '?'
		BEQ	switch
		CMP	#$20 ; ' '
		BNE	exit
		LDA	#1
		STA	BkgPal_Number
		RTS
; ���������������������������������������������������������������������������

switch:					; CODE XREF: Swap_Pal_Colors+4j
		LDA	#2
		STA	BkgPal_Number

exit:					; CODE XREF: Swap_Pal_Colors+8j
		RTS
; End of function Swap_Pal_Colors


; ��������������� S U B	R O U T	I N E ���������������������������������������


SetUp_LevelVARs:			; CODE XREF: ROM:C1F6p
					; Load_DemoLevel+5Ap
		JSR	Hide_All_Bullets ; ������ � �࠭� �� �㫨
		JSR	Null_Status
		LDA	#$F0 ; '�'
		STA	GameOverStr_Y	; ������ �� �࠭ �������
		LDA	#0
		STA	GameOverStr_Timer
		LDA	Player1_Lives	; �᫨ ������ ���,
					; ����� �� �ᯠ㭨���
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
		CMP #80;! ��᫥ 80 �஢�� ��� ����
		BCC Low_Levels
		LDA #2
		JMP Save_Enemy_Counter
Low_Levels:
		LDA #1
		JMP Save_Enemy_Counter;! ���� �㤥� ����, � ��᫥ 80-�� �஢�� �� �⠭�� ���.

Skip_Boss_Mode:				
		LDA	#20 ;20 �ࠣ�� � ������ �஢��

Save_Enemy_Counter:
		STA	Enemy_Reinforce_Count ;	������⢮ �ࠣ�� � �����
		STA	Enemy_Counter	; ������⢮ �ࠣ�� �� �࠭� �	� �����
		LDA	#0
		STA	Enemy_TypeNumber
		STA	Seconds_Counter
		STA	Construction_Flag ; ���⠢�����, �᫨ ��諨 � Construction
		STA	HQArmour_Timer	; ������ �஭� ����� �⠡�
		STA	Player_Blink_Timer ; ������ ������� friendly fire
		STA	Player_Blink_Timer+1 ; ������ ������� friendly fire
		STA	Invisible_Timer	; ������� ���� ����� ��ப� ��᫥ ஦�����
		STA	byte_8A
		STA	Respawn_Timer	; �६�	�� ᫥���饣� �ᯠ㭠
		STA	Bonus_X
		STA	EnemyFreeze_Timer
		STA	EnemyRespawn_PlaceIndex	; ��稭��� �ᯠ㭨����	᫥��
		JSR	Null_KilledEnms_Count ;	������ ���ᨢ	����稪�� 㡨��� �ࠣ��
		JSR	Draw_Reinforcemets
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		JSR	Draw_IP
		JSR	Draw_LevelFlag

		LDA Boss_Mode
		BEQ Skip_Boss_Mode2
		JSR Get_Random_A ; � ०��� ���� �����뢠�� ������� � ���� �� ⨯�� �ࠣ��
		AND #3
		TAY
		LDA #1
		STA Enemy_Count,Y
		JMP Init_HQ_Stat

Skip_Boss_Mode2:
		JSR	Load_Enemy_Count
Init_HQ_Stat:
		LDA	#$80 ; '�'
		STA	HQ_Status	; 80=�⠡ 楫, �᫨ ���� � 㭨�⮦��
		LDA	#1
		STA	Snd_Engine
		STA	EnterGame_Flag	; �᫨ 0, � ����� ����� �஢���
		LDA	Level_Mode
		CMP	#1
		BNE	++
		LDA	#35
		JMP	Respawn_Delay_Calc
; ���������������������������������������������������������������������������

++:					; CODE XREF: SetUp_LevelVARs+64j
		LDA	Level_Number

Respawn_Delay_Calc:			; CODE XREF: SetUp_LevelVARs+68j
		CMP	#43		;! �� �஢��� ��� 42, ��⠢�塞 �६� �� �ᯠ� ���������
		BCC	Level_Small
		LDA	#42
Level_Small:
		ASL	A
		ASL	A
		STA	Temp
		LDA	#190
		SEC
		SBC	Temp
		STA	Respawn_Delay	; ����প� ����� �ᯠ㭠�� �ࠣ��
		LDA	CursorPos
		BEQ	+++
		LDA	Respawn_Delay	; ����প� ����� �ᯠ㭠�� �ࠣ��
		SEC
		SBC	#20
		STA	Respawn_Delay	; ����প� ����� �ᯠ㭠�� �� �३��� ����� ���� ���᫥�� �� ��㫥:
					; 190 -	(��஢��)*4 - (������⢮_��ப�� - 1)*20

+++:					; CODE XREF: SetUp_LevelVARs+7Aj
		RTS
; End of function SetUp_LevelVARs


; ��������������� S U B	R O U T	I N E ���������������������������������������


Load_DemoLevel:				; CODE XREF: BonusLevel_ButtonCheck-378p
		LDA	#1
		STA	Pause_Flag
		LDA	#0
		STA	BkgPal_Number
		JSR	Init_Level_VARs
		LDA	#3
		STA	Player2_Lives	; ��� ����ᨬ��� �� �롮� ��ப�,
					; ����� ��ன ⠭�.
		LDA	#0
		STA	Scroll_Byte	; �����	��ࠧ��	�� �࠭� �㤥�	ᮤ�ন��� 0(1)
					; ⠩����� �����. �� 2(3) �ᥣ�� ��室���� ���쭨�,
					; �� ��������	�� ����㦠�� ��� �����	ࠧ, �����
					; �㦭�	�������� (� �⮬ ��砥 ������� 0(1)
					; ⠩���� ����� � �ந�室�� �஫� ��	2(3), �����
					; ⠪��	����⥭	����� ��ப�)
		STA	PPU_REG1_Stts
		STA	Seconds_Counter
		STA	Frame_Counter
		JSR	Make_GrayFrame
		LDA	#$FF
		STA	Level_Number
		JSR	Load_Level
		LDA	#1
		STA	Level_Number	; � �ࠢ�� 㣫�	�� �६� ����� �஢�� 㪠���
					; ������ 30-� ����� �஢��, ��� ��
					; ᮤ�ন���� �� � �� ��
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
		STA	LowStrPtr_Byte	; ����㧪� 㪠��⥫� ��� "��௨筮��" ᫮�� 'BATTLE'
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
		STA	LowStrPtr_Byte	; ����㧪� 㪠��⥫� ��� "��௨筮��" ᫮�� 'CITY'
					;
		JSR	Draw_BrickStr
		JSR	Store_NT_Buffer_InVRAM ; ����뢠�� �� �࠭ ᮤ�ন���	NT_Buffer
		JSR	Set_PPU
		JSR	SetUp_LevelVARs
		JSR	DraW_Normal_HQ	; ����� �⠡ �	��௨砬�
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	#5
		STA	TanksOnScreen	; ���ᨬ��쭮� ������⢮ ��� ⠭��� �� �࠭�
		RTS
; End of function Load_DemoLevel


; ��������������� S U B	R O U T	I N E ���������������������������������������


BonusLevel_ButtonCheck:			; CODE XREF: BonusLevel_ButtonCheck-375p
					; BonusLevel_ButtonCheck+1Bj

; FUNCTION CHUNK AT C09C SIZE 00000012 BYTES

		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	Joypad1_Differ
		AND	#1100b		; �஢�ઠ �� select(4)	��� start(8)
					; �� �६� �஫����� ���쭨�� ���
					; �����	�஢��.
		BNE	Button_Pressed

DemoLevel_Loop:				; ��ࠢ����� ⠭���� ��ப�� ��	�६� ���� �஢��
		JSR	Demo_AI
		JSR	Battle_Loop	; �᭮��� ����樨 � ⠭���� �	��ﬨ
		JSR	Bonus_Draw	; ����� ��� ������ ��� ����� ��� �窨	�� �����
		JSR	TanksStatus_Handle ; ��ࠡ��뢠�� ������ ��� 8-�� ⠭���
		JSR	Draw_All_BulletGFX ; ����� ��	�㫨
		JSR	LevelEnd_Check	; if ExitLevel then A=1
		BEQ	BonusLevel_ButtonCheck

End_Demo:
		LDA	#0
		STA	ScrBuffer_Pos
		RTS
; ���������������������������������������������������������������������������

Button_Pressed:				; CODE XREF: BonusLevel_ButtonCheck+7j
		PLA
		PLA			; ���ࠥ� �� �⥪� ��� ������
					; (�� RTS ��� ࠢ�� ��室��� ��	�㤥�),
					; �� ��楤�� � ���� ��뢠��	ᥡ�
					; ४��ᨢ�� - � �⥪ �⠫ ��
					; ����࠭�祭��	�����������
		LDA	#0
		STA	ScrBuffer_Pos
		JSR	Null_Upper_NT
		JMP	Title_Loaded
; End of function BonusLevel_ButtonCheck


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� ������� ��௨��� ������� � ४�म�

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
		LDA	#>aHiscore	; �뢮����� � ���� ��௨筮� ������, �᫨ ४��
		STA	HighStrPtr_Byte
		LDA	#<aHiscore	; �뢮����� � ���� ��௨筮� ������, �᫨ ४��
		STA	LowStrPtr_Byte
		JSR	Draw_BrickStr
		JSR	Draw_RecordDigit ; �뢮��� �� �࠭ ���� ४�ठ
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



; ��������������� S U B	R O U T	I N E ���������������������������������������


Draw_RespawnPic:			; CODE XREF: Draw_Drop:-p Draw_Drop+Fp
					; Draw_Drop+12p Draw_Drop+15p
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
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
		ADC	#$A1 ; '�'      ; ��砫� � Pattern Table ��䨪� �ᯠ㭠
		STA	Spr_TileIndex
		LDX	Block_X
		LDY	Block_Y
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)
		RTS
; End of function Draw_RespawnPic


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� ������� ��௨��� ������� GameOver

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
		LDA	#>aGame		; �뢮����� � ���� ��௨筮� ������ ��	���� �࠭
		STA	HighStrPtr_Byte
		LDA	#<aGame		; �뢮����� � ���� ��௨筮� ������ ��	���� �࠭
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
		JSR	Store_NT_Buffer_InVRAM ; ����뢠�� �� �࠭ ᮤ�ন���	NT_Buffer
		JSR	Set_PPU
		LDA	#0
		STA	Seconds_Counter
		LDA	#1
		STA	Snd_GameOver1
		STA	Snd_GameOver2
		STA	Snd_GameOver3

Next_Frame:				; CODE XREF: Draw_Brick_GameOver+57j
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	Joypad1_Differ
		AND	#$C
		BNE	End_Draw_Brick_GameOver	; �᫨ ����� Select ��� Start,	��室��
		LDA	Snd_GameOver1
		BNE	Next_Frame	; �᫨ ������� �����稫� �����, ��室��

End_Draw_Brick_GameOver:		; CODE XREF: Draw_Brick_GameOver+52j
		JSR	Screen_Off
		JSR	Null_NT_Buffer
		JSR	Store_NT_Buffer_InVRAM ; ����뢠�� �� �࠭ ᮤ�ন���	NT_Buffer
		JSR	Set_PPU
		JSR	Sound_Stop	; ��⠭��������	���, ����砥� ������ �	�.�. (�������筮 Load �	NSF �ଠ�)
		RTS
; End of function Draw_Brick_GameOver


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ��ࠢ����� ⠭���� ��ப�� ��	�६� ���� �஢��

Demo_AI:				; CODE XREF: BonusLevel_ButtonCheck:DemoLevel_Loopp
		LDA	#1
		STA	Counter		; ��ࠡ��뢠�� ���� ��ப��

-:					; CODE XREF: Demo_AI+7Dj
		LDX	Counter
		LDA	Bonus_X
		BEQ	NoBonus		; Bonus_X=0 - ����� �뢥��� �� �࠭
		LDA	BonusPts_TimeCounter
		BNE	NoBonus		; �᫨ ⠩��� !=0, ����� ����
					; � �⮡ࠦ����� �窨 �� ����
					; �᫨ ����� ��	�࠭�,	� ����� ��।� ����ࠥ� ���

Take_Bonus:
		LDA	Bonus_X
		STA	AI_X_Aim
		LDA	Bonus_Y
		STA	AI_Y_Aim
		JSR	Load_AI_Status
		JMP	Load_Direction_DemoAI ;	4 ���ࠢ�����
; ���������������������������������������������������������������������������

NoBonus:				; CODE XREF: Demo_AI+8j Demo_AI+Cj
		LDA	Tank_Status+2,X	; ���� ����� ���,
					; ���� �� 㦥 ����
					; �����	�ந�������� �஢�ન ⠭��� �ࠣ�� �� �����ᯮᮡ�����,
					; � �᫨ ��� ����, �ந�室�� ��७�楫������ �� ���
		BPL	+		; �᫨ <$80, �ࠣ 㬨ࠥ�
		CMP	#$E0 ; '�'
		BCS	+		; A>$E0	(�᫨ �����,
					; �ࠣ ��஦������)
		LDA	Tank_X+2,X
		STA	AI_X_Aim
		LDA	Tank_Y+2,X
		STA	AI_Y_Aim
		JSR	Load_AI_Status
		JMP	Load_Direction_DemoAI ;	4 ���ࠢ�����
; ���������������������������������������������������������������������������

+:					; CODE XREF: Demo_AI+1Ej Demo_AI+22j
		LDA	Tank_Status+4,X
		BPL	++		; �᫨ <$80, �ࠣ 㬨ࠥ�
		CMP	#$E0 ; '�'
		BCS	++		; A>$E0	(�᫨ �����,
					; �ࠣ ��஦������)
		LDA	Tank_X+4,X
		STA	AI_X_Aim
		LDA	Tank_Y+4,X
		STA	AI_Y_Aim
		JSR	Load_AI_Status
		JMP	Load_Direction_DemoAI ;	4 ���ࠢ�����
; ���������������������������������������������������������������������������

++:					; CODE XREF: Demo_AI+34j Demo_AI+38j
		LDA	Tank_Status+3,X
		BPL	EnemiesNotActing ; �᫨	<$80, �ࠣ 㬨ࠥ�
		CMP	#$E0 ; '�'
		BCS	EnemiesNotActing ; A>$E0 (�᫨ �����,
					; �ࠣ ��஦������)
		LDA	Tank_X+3,X
		STA	AI_X_Aim
		LDA	Tank_Y+3,X
		STA	AI_Y_Aim
		JSR	Load_AI_Status
		JMP	Load_Direction_DemoAI ;	4 ���ࠢ�����
; ���������������������������������������������������������������������������

EnemiesNotActing:			; CODE XREF: Demo_AI+4Aj Demo_AI+4Ej
		LDA	#0		; �᫨ ⠭��� ���, ��祣� �� ������
		JMP	SaveButton_DemoAI
; ���������������������������������������������������������������������������

Load_Direction_DemoAI:			; CODE XREF: Demo_AI+19j Demo_AI+2Fj
					; Demo_AI+45j Demo_AI+5Bj
		AND	#3		; 4 ���ࠢ�����
		TAY
		LDA	Tank_Direction,Y ; ���ࠢ����� ⠭��� �	����-�஢�� (� �ଠ� ���� �����⨪�)

SaveButton_DemoAI:			; CODE XREF: Demo_AI+60j
		LDX	Counter
		STA	Joypad1_Buttons,X
		STA	Joypad1_Differ,X
		LDA	Tank_Y,X
		CMP	#$C8 ; '�'
		BCC	Next_Demo_AI
		LDA	Joypad1_Differ,X
		AND	#$F0 ; '�'
		STA	Joypad1_Differ,X

Next_Demo_AI:				; CODE XREF: Demo_AI+73j
		DEC	Counter
		BPL	-
		RTS
; End of function Demo_AI

; ���������������������������������������������������������������������������
Tank_Direction:	.BYTE $13,$43,$23,$83	; DATA XREF: Demo_AI+66r
					; ���ࠢ����� ⠭��� � ����-�஢�� (� �ଠ� ���� �����⨪�)

; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� TSA ���� ��� ⠭���

Draw_TSA_On_Tank:			; CODE XREF: ROM:Construct_Draw_TSAp
		LDA	TSA_BlockNumber
		AND	#$F
		LDX	Tank_X
		LDY	Tank_Y
		JSR	Draw_TSABlock
		RTS
; End of function Draw_TSA_On_Tank


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ������� ⠭� � ����ᨬ��� ��	�������	������

Move_Tank:				; CODE XREF: ROM:C0EDp
		LDA	Joypad1_Buttons
		AND	#$F0 ; '�'      ; �஢�ઠ �� ������ ������ �ࠢ�����
		BEQ	ArrowNotPressed
		INC	byte_7B
		LDA	#0
		STA	BkgOccurence_Flag
		JMP	+
; ���������������������������������������������������������������������������

ArrowNotPressed:			; CODE XREF: Move_Tank+4j
		LDA	#0
		STA	byte_7B

+:					; CODE XREF: Move_Tank+Cj
		LDA	byte_7B
		CMP	#$14
		BEQ	loc_C6FB
		LDA	Joypad1_Differ
		AND	#$F0 ; '�'      ; �᫨ ������ ���ࠢ����� ��
					; ������, ⠭� �� �������
		BEQ	End_Move_Tank
		LDA	Joypad1_Differ
		JSR	Button_To_DirectionIndex ; $FF = ������	�ࠢ����� �� ������
		BMI	End_Move_Tank	; ������客��, �� ��砠�, �᫨
					; ������ �ࠢ����� �� ������
		JMP	loc_C704
; ���������������������������������������������������������������������������

loc_C6FB:				; CODE XREF: Move_Tank+17j
		LDA	#$F
		STA	byte_7B
		LDA	Joypad1_Buttons
		JSR	Button_To_DirectionIndex ; $FF = ������	�ࠢ����� �� ������

loc_C704:				; CODE XREF: Move_Tank+26j
		TAY
		LDA	Coord_X_Increment,Y
		ASL	A
		ASL	A
		ASL	A
		ASL	A		; ��६�頥� ⠭� �� 16	���ᥫ��
					; (����� TSA ���� 16�16)
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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ������ ���ᨢ ����稪�� 㡨��� �ࠣ��

Null_KilledEnms_Count:			; CODE XREF: SetUp_LevelVARs+43p
		LDX	#7
;4 ⨯�	�ࠣ�� � 2 ��ப� = ���ᨢ �� 8	����
		LDA	#0

-:					; CODE XREF: Null_KilledEnms_Count+7j
		STA	Enmy_KlledBy1P_Count,X
		DEX
		BPL	-
		RTS
; End of function Null_KilledEnms_Count


; ��������������� S U B	R O U T	I N E ���������������������������������������

; if ExitLevel then A=1

LevelEnd_Check:				; CODE XREF: ROM:C21Ep
					; BonusLevel_ButtonCheck+18p
		LDA	HQ_Status	; 80=�⠡ 楫, �᫨ ���� � 㭨�⮦��
		BEQ	Init_GameOverStr ; ��楤�� �஢���� ������:	�⠡�, ������ ��ப��,
					; ������⢠ ��⠢����	�ࠣ�� � �᫨ �㦭� ��� ��
					; �஢��, �� ��室� � �	�뤠�� 1, �᫨ �㦭� �த������
					; ��楤��� �஢��, � 0
		LDA	Enemy_Counter	; �᫨ �ࠣ�� ���, ��室��
		BEQ	ExitLevel
		LDA	Player1_Lives
		CLC
		ADC	Player2_Lives	; �᫨ ������ �	��� ��ப�� ���, ��室��
		BNE	PlayLevel

Init_GameOverStr:			; CODE XREF: LevelEnd_Check+2j
		LDA	#$70 ; 'p'
		STA	GameOverStr_X
		LDA	#$F0 ; '�'
		STA	GameOverStr_Y
		LDA	#0
		STA	GameOverScroll_Type ; ��।���� ��� ��६�饭�� ������(0..3)
		LDA	#$11
		STA	GameOverStr_Timer
		LDA	#0		; ����塞 ���稪, �⮡� ���४⭮
					; ��ࠡ���� ⠩��� ������ Game Over
		STA	Frame_Counter

ExitLevel:				; CODE XREF: LevelEnd_Check+6j
		LDA	#1
		RTS
; ���������������������������������������������������������������������������

PlayLevel:				; CODE XREF: LevelEnd_Check+Dj
		LDA	#0
		RTS
; End of function LevelEnd_Check

; ���������������������������������������������������������������������������
		LDA	byte_109	; �� �ᯮ�짮�����
		JSR	Num_To_NumString ; ��ॢ���� �᫮ �� �	� ��ப� NumString
		LDA	#$30 ; '0'
		STA	Char_Index_Base
		LDA	#0
		STA	HighPtr_Byte
		LDA	#$39 ; '9'
		STA	LowPtr_Byte
		LDX	#9
		LDY	#2
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDX	byte_109
		LDA	0,X
		JSR	Num_To_NumString ; ��ॢ���� �᫮ �� �	� ��ப� NumString
		LDA	#0
		STA	HighPtr_Byte
		LDA	#$39 ; '9'
		STA	LowPtr_Byte
		LDX	#$D
		LDY	#2
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
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

; ��������������� S U B	R O U T	I N E ���������������������������������������


Scroll_TitleScrn:			; CODE XREF: BonusLevel_ButtonCheck-37Ep
		LDA	#0
		STA	Scroll_Byte
		STA	PPU_REG1_Stts

-:					; CODE XREF: Scroll_TitleScrn+15j
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		INC	Scroll_Byte
		LDA	Joypad1_Differ
		AND	#1100b		; �஢�ઠ �� Select ��� Start
		BNE	+		; �� ��	ᠬ��, �� RTS (?)
		LDA	Scroll_Byte
		CMP	#$F0 ; '�'
		BNE	-
		RTS
; ���������������������������������������������������������������������������

+:					; CODE XREF: Scroll_TitleScrn+Fj
		PLA			; �� ��	ᠬ��, �� RTS (?)
		PLA
		JMP	Title_Loaded
; End of function Scroll_TitleScrn


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� IP/IIP	� �᫮	������ � �ࠢ��	㣫�

Draw_Player_Lives:			; CODE XREF: Battle_Loop+30p
		LDA	#1
		STA	Counter		; �� 㬮�砭�� ���ᮢ뢠�� ����� �����	��ப��
		STA	byte_6B
		LDA	#$6E ; 'n'
		STA	Char_Index_Base	; c $6E	� VRAM ��稭����� ����
		LDA	#>PlayerLives_Icon ; ���箪 ������ ��ப�
		STA	HighPtr_Byte
		LDA	#<PlayerLives_Icon ; ���箪 ������ ��ப�
		STA	LowPtr_Byte
		LDX	#$1D
		LDY	#$12		; ���न���� ������
		JSR	String_to_Screen_Buffer
		LDA	Level_Mode
		CMP	#2
		BEQ	Draw_2P_Lives	; ���㥬 ���箪	������ ��ண� ��ப�
		LDA	CursorPos	; �᫨ ��࠭ ���� ��ப, �
					; �� ��㥬 ����� 2 ��ப�.
		BNE	Draw_2P_Lives	; ���㥬 ���箪	������ ��ண� ��ப�
		LDA	#0
		STA	Counter		; �����	��ண�	��ப� 㦥
					; �ᮢ��� �� �㤥�
		JMP	Draw_1P_Lives
; ���������������������������������������������������������������������������

Draw_2P_Lives:				; CODE XREF: Draw_Player_Lives+1Dj
					; Draw_Player_Lives+21j
		LDA	#>PlayerLives_Icon ; ���㥬 ���箪 ������ ��ண� ��ப�
		STA	HighPtr_Byte
		LDA	#<PlayerLives_Icon ; ���箪 ������ ��ப�
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
		LDA	#0		; �᫨ ����� ����⥫��, ��㥬 ����

Draw_LivesDigit:			; CODE XREF: Draw_Player_Lives+40j
		JSR	ByteTo_Num_String
		LDY	#$36 ; '6'
		LDX	#$19
		JSR	PtrToNonzeroStrElem ; �㤥� ���� �� �᫮��� ��ப�
		LDA	Counter
		STA	Temp
		ASL	A
		CLC
		ADC	Temp
		CLC
		ADC	#$12		; Y ���न��� ������ �� �࠭�
		TAY
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		DEC	Counter
		BPL	Draw_1P_Lives
		LDA	#0
		STA	Char_Index_Base
		STA	byte_6B
		RTS
; End of function Draw_Player_Lives


; ��������������� S U B	R O U T	I N E ���������������������������������������


Draw_IP:				; CODE XREF: SetUp_LevelVARs+4Cp
		LDA	#>I_p		; ������� IP ��אַ ��� ����ﬨ ��ப��
		STA	HighPtr_Byte
		LDA	#<I_p		; ������� IP ��אַ ��� ����ﬨ ��ப��
		STA	LowPtr_Byte
		LDX	#$1D
		LDY	#$11
		JSR	String_to_Screen_Buffer
		LDA	Level_Mode
		CMP	#2
		BEQ	Draw_IIP	; �᫨ ����� �஢���, � ��ப�� �ᥣ��	���
		LDA	CursorPos
		BEQ	+

Draw_IIP:				; CODE XREF: Draw_IP+13j
		LDA	#>II_p		; ������� IIP ��אַ ���	����ﬨ	��ப��
		STA	HighPtr_Byte
		LDA	#<II_p		; ������� IIP ��אַ ���	����ﬨ	��ப��
		STA	LowPtr_Byte
		LDX	#$1D
		LDY	#$14
		JSR	String_to_Screen_Buffer

+:					; CODE XREF: Draw_IP+17j
		RTS
; End of function Draw_IP


; ��������������� S U B	R O U T	I N E ���������������������������������������


Draw_LevelFlag:				; CODE XREF: SetUp_LevelVARs+4Fp
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	#>LevelFlag_Upper_Icons	; ������ ��� ����஬ �஢�� � �ࠢ�� ��� �࠭�
		STA	HighPtr_Byte
		LDA	#<LevelFlag_Upper_Icons	; ������ ��� ����஬ �஢�� � �ࠢ�� ��� �࠭�
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
		STA	Char_Index_Base	; C $6E	��稭����� ���� ������	� Pattern Table
		LDA	Level_Number
		JSR	ByteTo_Num_String
		LDY	#$36 ; '6'
		LDX	#$19
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#$19
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDA	#0
		STA	Char_Index_Base
		RTS
; End of function Draw_LevelFlag


; ��������������� S U B	R O U T	I N E ���������������������������������������


PointAt_RightScrnColumn:		; CODE XREF: ReinforceToRAMp
					; Draw_EmptyTilep
		PHA
		AND	#1
		CLC
		ADC	#29		; 29 ⠩��� �� ��砫� ��ப� �࠭� �� ��砫� �ࠢ��� ���ଠ樮����� �⮫��
		TAX
		PLA
		LSR	A		; �����	�� 2 (�	��ப� ���ଠ樮����� �⮫�� �ᥣ�� ��� ⠩��)
		CLC
		ADC	#3		; ���ଠ樮��� �⮫��� ���⮨� �� ���孥� �࠭��� �࠭� �� 3	⠩��
		TAY
;X � Y ⥯��� ���न���� � ⠩��� �㤠 �㤥�
;����ᠭ� ��।��� ������ ���ଠ樮����� �⮫��
		RTS
; End of function PointAt_RightScrnColumn


; ��������������� S U B	R O U T	I N E ���������������������������������������


ReinforceToRAM:				; CODE XREF: Draw_Reinforcemets+6p
		JSR	PointAt_RightScrnColumn
		LDA	#>Reinforcement_Icon ;	���⠢���� ����	��⠢���� �ࠣ��
		STA	HighPtr_Byte
		LDA	#<Reinforcement_Icon ;	���⠢���� ����	��⠢���� �ࠣ��
		STA	LowPtr_Byte
		JSR	String_to_Screen_Buffer
		RTS
; End of function ReinforceToRAM


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� ���⮩	⠩� � ������� ����ᮢ �ࠣ��, ����� ��� ��室��

Draw_EmptyTile:				; CODE XREF: Respawn_Handle+20p
		JSR	PointAt_RightScrnColumn
		LDA	#>Empty_Tile	; �������� ���箪 �ࠣ�, �����	�� ஦������
		STA	HighPtr_Byte
		LDA	#<Empty_Tile	; �������� ���箪 �ࠣ�, �����	�� ஦������
		STA	LowPtr_Byte
		JSR	String_to_Screen_Buffer
		RTS
; End of function Draw_EmptyTile


; ��������������� S U B	R O U T	I N E ���������������������������������������


Draw_Reinforcemets:
		LDA	Boss_Mode
		BNE	End_Draw_Reinforcemets			; CODE XREF: SetUp_LevelVARs+46p
		SEC
		LDA	Enemy_Reinforce_Count ;! ��⠥� �ࠣ�� - ��� ����� ����������, �᫨ �ࠣ ��� ����� �����
		SBC	#1
		;LDA #18
		STA	Counter		; � ���� ����ᮢ �ࠣ�� �㤥� 20 ������ �ࠣ��,
					; �����	横� � �����᫮����, ���⮬� 18

-:					; CODE XREF: Draw_Reinforcemets+Dj
		LDA	Counter
		JSR	ReinforceToRAM
		DEC	Counter
		;DEC	Counter		; �� ��� ������	� �����, ���⮬� 㬥��蠥� 2 ࠧ�
		BPL	-
End_Draw_Reinforcemets:
		RTS
; End of function Draw_Reinforcemets


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �� ���� ⠭��	��� �� �࠭��� �ன ࠬ��

Check_BorderReach:			; CODE XREF: ROM:C0F0p
		LDA	Tank_X
		CMP	#$D8 ; '�'
		BCC	+
		LDA	#$D8 ; '�'
		STA	Tank_X		; �᫨ �ࠢ�� ࠬ��, ��ᢠ����� ⠭��
					; �ࠩ��� �ࠢ�� ���न����

+:					; CODE XREF: Check_BorderReach+4j
		LDA	Tank_X
		CMP	#$18
		BCS	++
		LDA	#$18
		STA	Tank_X		; �᫨ ����� ࠬ��, ��ᢠ�����	⠭��
					; �ࠩ��� �����	���न����

++:					; CODE XREF: Check_BorderReach+Ej
		LDA	Tank_Y
		CMP	#$D8 ; '�'
		BCC	+++
		LDA	#$D8 ; '�'
		STA	Tank_Y		; �᫨ ��� ࠬ��, ��ᢠ����� ⠭��
					; �ࠩ��� ������ ���न����

+++:					; CODE XREF: Check_BorderReach+18j
		LDA	Tank_Y
		CMP	#$18
		BCS	End_Check_BorderReach
		LDA	#$18
		STA	Tank_Y		; �᫨ ���� ࠬ��, ��ᢠ����� ⠭��
					; �ࠩ��� ������ ���न����

End_Check_BorderReach:			; CODE XREF: Check_BorderReach+22j
		RTS
; End of function Check_BorderReach


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� �������� �������, � ��砥 �᫨ ���⠢���� ��㧠

Draw_Pause:				; CODE XREF: ROM:Skip_Pause_Switchp
		LDA	Pause_Flag
		BEQ	End_Draw_Pause	; �᫨ ��㧠 ��	���⠢����, ��室��
		LDA	Frame_Counter
		AND	#$10		; ������� ������� ������ ࠧ �	16 �३���
		BEQ	End_Draw_Pause
;������ ᯮᮡ �뢮��	������	"PAUSE"	�� �࠭
		LDA	#3
		STA	TSA_Pal		; ��㧠	�ᯮ���� �ࠩ⮢�� ������� 3
		LDA	#0
		STA	Spr_Attrib	; ������� ������ �ୠ
		LDX	#$64 ; 'd'      ; ���न��� � �㪢�
		LDY	#$80 ; '�'      ; ���न��� Y �㪢�
		LDA	#$17		; P
		STA	Spr_TileIndex
		JSR	SaveSprTo_SprBuffer ; ����뢠�� � �ࠩ⮢� ����� ���� �ࠩ� 8�16
		LDX	#$6C ; 'l'
		LDY	#$80 ; '�'
		LDA	#$19		; A
		STA	Spr_TileIndex
		JSR	SaveSprTo_SprBuffer ; ����뢠�� � �ࠩ⮢� ����� ���� �ࠩ� 8�16
		LDX	#$74 ; 't'
		LDY	#$80 ; '�'
		LDA	#$1B		; U
		STA	Spr_TileIndex
		JSR	SaveSprTo_SprBuffer ; ����뢠�� � �ࠩ⮢� ����� ���� �ࠩ� 8�16
		LDX	#$7C ; '|'
		LDY	#$80 ; '�'
		LDA	#$1D		; S
		STA	Spr_TileIndex
		JSR	SaveSprTo_SprBuffer ; ����뢠�� � �ࠩ⮢� ����� ���� �ࠩ� 8�16
		LDX	#$84 ; '�'
		LDY	#$80 ; '�'
		LDA	#$1F		; E
		STA	Spr_TileIndex
		JSR	SaveSprTo_SprBuffer ; ����뢠�� � �ࠩ⮢� ����� ���� �ࠩ� 8�16
		LDA	#$20 ; ' '
		STA	Spr_Attrib

End_Draw_Pause:				; CODE XREF: Draw_Pause+2j
					; Draw_Pause+8j
		RTS
; End of function Draw_Pause


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� ������� Game Over, ����� ��� ��⠭�������

Draw_Fixed_GameOver:			; CODE XREF: GameOver_Str_Move_Handle:Stopped_Motionp
		LDA	#3
		STA	TSA_Pal
		LDA	#0
		STA	Spr_Attrib
		LDX	GameOverStr_X
		LDY	GameOverStr_Y
		LDA	#$79 ; 'y'      ; ��砫� ��ࢮ�� �ࠩ� 16�16 ������ Game Over
		STA	Spr_TileIndex
		JSR	Draw_WholeSpr	; ���㥬 ����� ��������� ������
		LDA	GameOverStr_X
		CLC
		ADC	#$10		; ���頥��� �� ��� ⠩�� ��ࠢ�	(16 ���ᥫ��)
		TAX
		LDY	GameOverStr_Y
		LDA	#$7D ; '}'      ; ��砫� ��䨪� ��ன ��������� ������ � Pattern Table
		STA	Spr_TileIndex
		JSR	Draw_WholeSpr	; ���㥬 �����	��������
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		RTS
; End of function Draw_Fixed_GameOver


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �뢮��� ������� Game Over �᫨ �㦭�

GameOver_Str_Move_Handle:		; CODE XREF: Battle_Loop+2Ap
		LDA	GameOverStr_Timer
		BEQ	End_GameOver_Str_Move ;	�᫨ ������ ���, ��室��
		LDA	Level_Mode
		CMP	#2		; �� ����� �஢�� ������� Game Over �� �⮡ࠦ�����
		BEQ	End_GameOver_Str_Move
		LDA	Frame_Counter
		AND	#$F		; ����稪 㬥��蠥���
					; ����� 16 �३���
		BNE	Check_Motion
		DEC	GameOverStr_Timer
		BNE	Check_Motion

Hide_String:				; �᫨ �६� ���稫���,
		LDA	#$F0 ; '�'      ; ���祬 �������
		STA	GameOverStr_Y

Check_Motion:				; CODE XREF: GameOver_Str_Move_Handle+Fj
					; GameOver_Str_Move_Handle+14j
		LDA	GameOverStr_Timer
		CMP	#10		; �� 10	横��� �� ��祧�������
					; ������� ��⠭����������
		BCC	Stopped_Motion
		LDA	GameOverScroll_Type ; ��।���� ��� ��६�饭�� ������(0..3)
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
		JSR	Draw_Fixed_GameOver ; ����� ������� Game Over,	����� ��� ��⠭�������

End_GameOver_Str_Move:			; CODE XREF: GameOver_Str_Move_Handle+3j
					; GameOver_Str_Move_Handle+9j
		RTS
; End of function GameOver_Str_Move_Handle


; ��������������� S U B	R O U T	I N E ���������������������������������������


Make_GrayFrame:				; CODE XREF: ROM:C0B5p	ROM:C1D4p
					; Load_DemoLevel+19p
					; Show_Secret_Msg+C1p
		LDA	#2
		STA	Block_X
		STA	Block_Y		; ����窠 �ਭ�� 2 ⠩�� �� ���⨪��� � ��ਧ��⠫�
					; (��⮬ � ��� �ਡ������� �ࠢ� ���ଠ樮��� �⮫���)
					; �� ᠬ�� ����, ᭠砫� ���� �࠭ ����������	���, ��⮬
					; � ���	���ᮢ뢠���� ��� ������ ��஢��� ����
		LDA	#$1A
		STA	Counter		; $19 -	�ਭ� � ����	��஢��� ���� (� ��楤�� �� $1A �⭨������ ������)
					; Counter - �㤥� ����� ஫� �����
					; Counter2 - �ਭ�
		STA	Counter2
		JSR	Draw_GrayFrame
		RTS
; End of function Make_GrayFrame


; ��������������� S U B	R O U T	I N E ���������������������������������������


Title_Screen_Loop:			; CODE XREF: BonusLevel_ButtonCheck:Title_Loadedp ; ��室� �� JMP	�� ࠧ�� �������
		LDA	#3
		STA	BkgPal_Number	; �� RTS - ����㧪� ����-஫���
		LDA     #$24
		STA     PPU_Addr_Ptr;��襬 � ������ ⠩����� �����		

		JSR	Null_Status
		LDA	#$48 ; 'H'      ; X �� ���쭨�� ���������� �� �㤥�
		STA	Tank_X
		JSR	CurPos_To_PixelCoord
		LDA	#$83
		STA	Tank_Status	; ���� ���ࠢ��� �㫮� ��ࠢ�
		LDA	#0
		Sta	Random_Level_Flag
		STA	Seconds_Counter	; ���㫥��� ⠩���
		STA	Tank_Type
		STA	Track_Pos
		STA	Player_Blink_Timer ; ������ ������� friendly fire
		STA	Player_Blink_Timer+1 ; ������ ������� friendly fire
		STA	Scroll_Byte
		LDA	#2
		STA	PPU_REG1_Stts

Begin_Title_Screen_Loop:					; CODE XREF: Title_Screen_Loop+81j
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	Frame_Counter
		AND	#3
		BNE	+		; ����� 3 �३�� ᬥ頥� ��ᥭ���
		LDA	Track_Pos
		EOR	#4
		STA	Track_Pos

+:					; CODE XREF: Title_Screen_Loop+2Dj
		JSR	TanksStatus_Handle ; ��ࠡ��뢠�� ������ ��� 8-�� ⠭���

;�஢��塞 �� ��ࠢ�-�����:
		Lda	CursorPos
		Cmp	#3
		BNE	Check_Select

		LDA	Joypad1_Differ
		AND	#$40		; �஢�ઠ �� left
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
		AND	#$80		; �஢�ઠ �� right
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
		ASL	A		; �2 (㪠��⥫�	���塠�⮢�)
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
		AND	#4		; �஢�ઠ �� select
		BEQ	Check_Max_CurPos
		INC	CursorPos
		LDA	#0
		STA	Seconds_Counter

Check_Max_CurPos:			; CODE XREF: Title_Screen_Loop+5Bj
					; Title_Screen_Loop+61j
		LDA	CursorPos
		CMP	#4;! �������� �� ���� �㭪� ����
		BCC	++
		LDA	#0
		STA	CursorPos

++:					; CODE XREF: Title_Screen_Loop+69j
		JSR	CurPos_To_PixelCoord
		LDA	Seconds_Counter
		CMP	#10		; �஢�ઠ �� �६� ��砫� ����-஫���(10 ᥪ㭤)
		BNE	Start_Check
		LDA	Construction_Flag ; �᫨ �뫨 �	Construction, �� �����뢠�� ����-�஢���
		BNE	Start_Check
		LDA	#$1C
		STA     PPU_Addr_Ptr
		RTS			; ����㦠�� ����-஫��
; ���������������������������������������������������������������������������

Start_Check:				; CODE XREF: Title_Screen_Loop+76j
					; Title_Screen_Loop+7Aj
		LDA	Joypad1_Differ
		AND	#8		; �஢�ઠ �� ����
		Bne	++++
		JMP 	Begin_Title_Screen_Loop
++++:
		LDA	Construction_Flag ; ���⠢�����, �᫨ ��諨 � Construction
		CMP	#7
		BNE	Start_Pressed
Start_Pressed:				; CODE XREF: Title_Screen_Loop+87j
					; Title_Screen_Loop+8Dj
		LDA	#0
		STA	BkgPal_Number
		PLA
		PLA			; �⮡�	�� ��९������ �⥪ ��	४��ᨨ
		LDA	CursorPos	; � ����ᨬ���	�� ����樨 ����� �믮��塞 �������
		ASL	A		; �2 (㪠��⥫�	���塠�⮢�)
		TAY
		LDA	Title_JumpTable,Y
		STA	LowPtr_Byte
		LDA	Title_JumpTable+1,Y
		STA	HighPtr_Byte
		LDA	#$1C
		STA     PPU_Addr_Ptr
		JMP	(LowPtr_Byte)
; End of function Title_Screen_Loop

; ���������������������������������������������������������������������������
;����㦠���� ��������� ᢥ���
Title_JumpTable:.WORD Selected_1player	; DATA XREF: Title_Screen_Loop+9Cr
					; Title_Screen_Loop+A1r
					; �᫨ ��ப 1,	� �� �࠭� ����� ����	4 �ࠣ�
		.WORD Selected_2players	; �᫨ ��ப�� ����, �	�� �࠭� �����	���� 6 �ࠣ��
		.WORD Selected_Construction
		.WORD Title_Loaded ; �� ����⨨ �� ���� �� �롮� ०���, ��룠�� � 1player
; ���������������������������������������������������������������������������

Selected_1player:			; DATA XREF: ROM:Title_JumpTableo
		LDA	#5		; �᫨ ��ப 1,	� �� �࠭� ����� ����	4 �ࠣ�
		JMP	accept
; ���������������������������������������������������������������������������

Selected_2players:			; DATA XREF: ROM:CA6Bo
		LDA	#7		; �᫨ ��ப�� ����, �	�� �࠭� �����	���� 6 �ࠣ��

accept:					; CODE XREF: ROM:CA71j
		STA	TanksOnScreen	; ���ᨬ��쭮� ������⢮ ��� ⠭��� �� �࠭�
		JSR	Null_both_HiScore
		JMP	Start_StageSelScrn
; ���������������������������������������������������������������������������

Selected_Construction:			; DATA XREF: ROM:CA6Do
		LDA	#7
		STA	TanksOnScreen	; ? � 祬� �� �� - �� �࠭� ⮫쪮 ��ப...
		JMP	Construction

; ��������������� S U B	R O U T	I N E ���������������������������������������


CurPos_To_PixelCoord:			; CODE XREF: Title_Screen_Loop+Bp
					; Title_Screen_Loop:Plusp
		LDA	CursorPos
		ASL	A
		ASL	A
		ASL	A
		ASL	A		; �������� �� 16 (�����	�㭪⠬� ���� 2	⠩�� �� 8 ���ᥫ��)
		CLC
		ADC	#$8B ; '�'      ; �� ���孥� �࠭��� �࠭� �� ��ࢮ�� �㭪� ���� �� ���⨪��� $88 ���ᥫ��
		STA	Tank_Y
		RTS
; End of function CurPos_To_PixelCoord


; ��������������� S U B	R O U T	I N E ���������������������������������������


Draw_StageNumString:			; CODE XREF: ROM:StageSelect_Loopp
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDX	#$C		; ���न���� � ⠩��� ࠧ��饭�� ��ப�	�� �࠭�
		LDY	#$E
		JSR	CoordTo_PPUaddress
		LDX	ScrBuffer_Pos
		CLC
		ADC	#$1C
		STA	Screen_Buffer,X	; ���訩 ���� ���� �	PPU
		INX
		TYA
		STA	Screen_Buffer,X	; ����訩 ����
		INX
		LDY	#0
;�᫨ �㦭�, �뢮��� ������� Boss Stage

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
		LDA	#$6E ; 'n'      ; � $6E � Pattern Table ��稭����� ��䨪� ���
		STA	Char_Index_Base
		LDA	Level_Number;
		LSR
		LSR
		LSR
		
		JSR	ByteTo_Num_String
		LDY	#Num_String+1
		LDX	#$12		; ���न��� � �뢮����� ����
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
		LDA	#$6E ; 'n'      ; � $6E � Pattern Table ��稭����� ��䨪� ���
		STA	Char_Index_Base
		LDA	Level_Number;! ����� �஢��
		JSR	ByteTo_Num_String
		LDY	#Num_String+1
		LDX	#$E		; ���न��� � �뢮����� ����
End_Stage_Draw:
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#$E		; ���न��� Y �뢮����� ����
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDA	#0
		STA	Char_Index_Base
		RTS
; End of function Draw_StageNumString



; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� �⠡ �	��௨砬�

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
		JSR	String_to_Screen_Buffer	; �뢮��� �⠡ �१ ��ப��� �����
		LDX	ScrBuffer_Pos
		LDA	#$23 ; '#'
		STA	Screen_Buffer,X
		INX
		LDA	#$F3 ; '�'
		STA	Screen_Buffer,X	; ������ � ������ PPU $23F3 (��ਡ��� �⠡�)
		INX
		LDA	#0
		STA	NT_Buffer+$3F3
		STA	Screen_Buffer,X
		INX
		LDA	NT_Buffer+$3F4
		AND	#$CC ; '�'
		STA	NT_Buffer+$3F4
		STA	Screen_Buffer,X	; ���⠢�塞 ��ਡ��� �⠡�
		INX
		LDA	#$FF
		STA	Screen_Buffer,X	; �����	��ப�
		INX
		STX	ScrBuffer_Pos
		RTS
; End of function DraW_Normal_HQ


; ��������������� S U B	R O U T	I N E ���������������������������������������


Draw_Naked_HQ:				; CODE XREF: ROM:Skip_Lvl_Loadp
		LDA	#>Naked_HQ_TSA_FirstLine
		STA	HighPtr_Byte
		LDA	#<Naked_HQ_TSA_FirstLine
		STA	LowPtr_Byte
		LDX	#$E
		LDY	#$1A		; ���न���� ���孥� ����� ������ �⠡�
		JSR	String_to_Screen_Buffer
		LDA	#>Naked_HQ_TSA_SecndLine
		STA	HighPtr_Byte
		LDA	#<Naked_HQ_TSA_SecndLine
		STA	LowPtr_Byte
		LDX	#$E
		LDY	#$1B		; ���न���� ������ ����� ������ �⠡�
		JSR	String_to_Screen_Buffer

		LDX	ScrBuffer_Pos
		LDA	#$23 ; '#'
		STA	Screen_Buffer,X
		INX
		LDA	#$F3 ; '�'
		STA	Screen_Buffer,X	; ������ ᫥���饣� ��ਭ�� �㤥� � ���� PPU $23F3
					; (��ਡ�� ���孥� ����� ⠩���)
		INX
		LDA	NT_Buffer+$3F3
		AND	#111111b
		STA	NT_Buffer+$3F3	; �⠡ �ᯮ���� �㫥��� �������, ���⮬� ���訥
					; �� ��� �������, ��� �����筮 ���㫨�� �	���
					; (���� ���� ��ਡ��	���ᠭ � ���࠭�� ���⪮,
					; �� ��� �⫠��� ᮩ���)
		STA	Screen_Buffer,X
		INX
		LDA	#$FF
		STA	Screen_Buffer,X	; �����	��ப�
		INX
		STX	ScrBuffer_Pos
		RTS
; End of function Draw_Naked_HQ


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� �⠡ �	�஭��

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
		LDX	ScrBuffer_Pos	; �뢮��� �஭�஢��� �⠡ �१ ��ப��� �����
		LDA	#$23 ; '#'
		STA	Screen_Buffer,X
		INX
		LDA	#$F3 ; '�'
		STA	Screen_Buffer,X	; �㤥�	����� � ������� ��ਡ�⮢ ($23F3)
		INX
		LDA	#$3F ; '?'
		STA	NT_Buffer+$3F3
		STA	Screen_Buffer,X
		INX
		LDA	NT_Buffer+$3F4
		AND	#$CC ; '�'
		ORA	#$33 ; '3'
		STA	NT_Buffer+$3F4
		STA	Screen_Buffer,X
		INX
		LDA	#$FF
		STA	Screen_Buffer,X	; �����	��ப� ��ਡ�⮢
		INX
		STX	ScrBuffer_Pos
		RTS
; End of function Draw_ArmourHQ


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� ࠧ��襭�� �⠡

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

; ��������������� S U B	R O U T	I N E ���������������������������������������

;! ����� �⠡ ��᫥ ����� �ࠣ�� ������

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
		LDX	ScrBuffer_Pos	; �뢮��� �஭�஢��� �⠡ �१ ��ப��� �����
		RTS
; End of function Draw_ShovelHQ


; ��������������� S U B	R O U T	I N E ���������������������������������������


Copy_AttribToScrnBuff:			; CODE XREF: ROM:C1E9p
		LDY	#0
;��楤�� ������� ��ਡ��� ��	NTBuffer � ScreenBuffer, ��ॢ��� � ᮮ⢥�����騩 �஬��
		LDA	#$23 ; '#'
		STA	HighPtr_Byte
		LDA	#$C0 ; '�'
		STA	LowPtr_Byte	; ������ �㤥� ������ � ������� ��ਡ�⮢ ���孥� NT

-:					; CODE XREF: Copy_AttribToScrnBuff+32j
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDX	ScrBuffer_Pos
		LDA	HighPtr_Byte
		STA	Screen_Buffer,X
		INX
		LDA	LowPtr_Byte
		STA	Screen_Buffer,X	; ���砫� ��࠭塞 � ����� ��ப ���� PPU,
					; �㤠 �㤥� ������ ������
		INX
		LDA	NT_Buffer+$3C0,Y
		INY
		STA	Screen_Buffer,X
		INX
		LDA	#$FF
		STA	Screen_Buffer,X	; ���࠭塞 ����� ����	��ਡ�� � ����	��ப�
					; � �ࠩ⮢� �����
		INX
		STX	ScrBuffer_Pos
		LDA	#1
		JSR	Inc_Ptr_on_A
		CPY	#$40 ; '@'      ; ������⢮ ���� � ⠡��� ��ਡ�⮢
		BNE	-
		RTS
; End of function Copy_AttribToScrnBuff


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �������� ���� �� ⠩��� Iterative_Byte'��

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
		LDA	Iterative_Byte	; ����,	��������騩 ����訥 ���ᨢ� ������
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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ᮧ���� ��䥪� �室����� ���⨪����� �⢮ப

FillNT_with_Grey:			; CODE XREF: ROM:C16Fp
		LDA	#$11
		STA	Iterative_Byte	; ���⮩ ��� ⠩�
		LDA	#0
		STA	Block_Y		; ��稭��� ��������� �࠭ � ��砫�

-:					; CODE XREF: FillNT_with_Grey+1Fj
		JSR	NMI_Wait	; ����প� �� ���ᮢ��	�࠭�:	��������� ��, ��ப
					; �ᯥ���� 㢨���� ����� ���������� �࠭�.
		LDY	Block_Y
		JSR	FillScr_Single_Row ; �������� ���� ��	⠩��� Iterative_Byte'��
		LDA	#$1D		; ��࠭	240 ���ᥫ�� (��� $1E ⠩���) �	�����
		SEC
		SBC	Block_Y		; ������塞 �࠭ �� ������ ��� ⠩���	ᢥ��� � ᭨��,
					; ᮧ����� ��䥪� �室����� ���⨪����� �⢮ப
		TAY
		JSR	FillScr_Single_Row ; �������� ���� ��	⠩��� Iterative_Byte'��
		INC	Block_Y
		LDA	Block_Y
		CMP	#$10		; $10 ��室�� ��������� $20 �冷� ⠩���
					; ��� $400 ����	(�.�. �	��ਡ��� ⠩����� ���� ⮦�)
		BNE	-		; ����প� �� ���ᮢ��	�࠭�:	��������� ��, ��ப
					; �ᯥ���� 㢨���� ����� ���������� �࠭�.
		RTS
; End of function FillNT_with_Grey


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ������� ��䥪� ��室����� ���⨪����� �⢮ப

FillNT_with_Black:			; CODE XREF: ROM:C1ECp
		LDA	#0
		STA	Iterative_Byte	; ���⮩ ����	⠩�
		LDA	#$F
		STA	Block_Y		; ��稭��� ��������� �࠭ � �।��� (�� ������ 'STAGE XX')

-:					; CODE XREF: FillNT_with_Black+1Fj
		JSR	NMI_Wait	; ����প� �� ���ᮢ��	�࠭�:	��������� ��, ��ப
					; �ᯥ���� 㢨���� ����� ���������� �࠭�.
		LDY	Block_Y
		JSR	FillScr_Single_Row ; �������� ���� ��	⠩��� Iterative_Byte'��
		LDA	#$1D		; ��࠭	240 ���ᥫ�� (��� $1E ⠩���) �	�����
		SEC
		SBC	Block_Y		; ������塞 �࠭ �� ������ ��� ⠩���	ᢥ��� � ᭨��,
					; ᮧ����� ��䥪� ��室����� ���⨪����� �⢮ப
		TAY
		JSR	FillScr_Single_Row ; �������� ���� ��	⠩��� Iterative_Byte'��
		DEC	Block_Y
		LDA	Block_Y
		CMP	#$FF		; ��室�� �� ���� �࠭�
		BNE	-		; ����প� �� ���ᮢ��	�࠭�:	��������� ��, ��ப
					; �ᯥ���� 㢨���� ����� ���������� �࠭�.
		RTS
; End of function FillNT_with_Black


; ��������������� S U B	R O U T	I N E ���������������������������������������


Draw_Pts_Screen:			; CODE XREF: ROM:C256p
		JSR	Draw_Pts_Screen_Template ; ����� ��騩	��� ��� �஢��� �࠭ �窮�
		LDX	#$1E
		JSR	DrawTankColumn_XTimes ;	����� ������� �� 4-� �ࠦ�᪨�	⠭��� X ࠧ (����প� � � �३���)
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
		STA	TotalEnmy_KilledBy2P ; ����塞 ��饥 ������⢮ �窮�
		LDA	#0
		STA	Counter

DrawPtsScrn_NxtTank:			; CODE XREF: Draw_Pts_Screen+11Dj
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		JSR	Draw_Tank_Column ; ����� ������� �� 4-� �ࠦ�᪨� ⠭���
		LDX	#Temp_1PPts_String ; ��ப� ��	������ �窮� �� ⥪�騩 ��� ⠭��
		JSR	Null_8Bytes_String
		LDX	#Temp_2PPts_String
		JSR	Null_8Bytes_String
		LDA	#0
		STA	BrickChar_X
		STA	BrickChar_Y

DrawPtsScrn_NxtCount:			; CODE XREF: Draw_Pts_Screen+10Dj
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		JSR	Draw_Tank_Column ; ����� ������� �� 4-� �ࠦ�᪨� ⠭���
		LDA	#0
		STA	EndCount_Flag	; �᫨ 0, �������� ������ �窮� ��� ⥪�饣� �ࠣ�
		LDX	Counter
		LDA	TankKill_Pts,X	; ������⢮ �窮� �� ����� ⨯ 㡨⮣� �ࠣ�
		JSR	Num_To_NumString ; ��ॢ���� �᫮ �� �	� ��ப� NumString
		LDX	Counter
		LDA	Enmy_KlledBy1P_Count,X
		BEQ	++
		LDA	#1
		STA	Snd_PtsCount1
		STA	Snd_PtsCount2
		DEC	Enmy_KlledBy1P_Count,X
		INC	BrickChar_X
		LDX	#2
		JSR	Add_Score	; �ਡ����� �᫮ �� NumString	� �窠�	��ப� ��
		LDA	#1
		STA	EndCount_Flag	; �᫨ 0, �������� ������ �窮� ��� ⥪�饣� �ࠣ�
		JSR	Add_Life	; �ਡ����� ���� �����, �᫨ ��ப ��ࠡ�⠫ 200� �窮�

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
		JSR	Add_Score	; �ਡ����� �᫮ �� NumString	� �窠�	��ப� ��
		LDA	#1
		STA	EndCount_Flag	; �᫨ 0, �������� ������ �窮� ��� ⥪�饣� �ࠣ�
		JSR	Add_Life	; �ਡ����� ���� �����, �᫨ ��ப ��ࠡ�⠫ 200� �窮�

+++:					; CODE XREF: Draw_Pts_Screen+70j
		LDY	#HiScore_1P_String+1
		LDX	#5
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDX	#1
		LDY	#Temp_1PPts_String+1 ; ��ப� �� ������ �窮� �� ⥪�騩 ���	⠭��
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDA	Counter
		ASL	A
		CLC
		ADC	Counter
		CLC
		ADC	#$C
		TAY
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDX	Counter
		LDA	BrickChar_X
		JSR	ByteTo_Num_String
		LDX	#8
		LDY	#Num_String+1
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDA	Counter
		ASL	A
		CLC
		ADC	Counter
		CLC
		ADC	#$C
		TAY
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDA	CursorPos
		BEQ	+		; �᫨ ��ப ����, �窨	�� �뢮���
		LDY	#HiScore_2P_String+1
		LDX	#$17
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDX	#$13
		LDY	#Temp_2PPts_String+1
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDA	Counter
		ASL	A
		CLC
		ADC	Counter
		CLC
		ADC	#$C
		TAY
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDX	Counter
		LDA	BrickChar_Y
		JSR	ByteTo_Num_String
		LDX	#$E
		LDY	#Num_String+1
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDA	Counter
		ASL	A
		CLC
		ADC	Counter
		CLC
		ADC	#$C
		TAY
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����

+:					; CODE XREF: Draw_Pts_Screen+C7j
		LDX	#8
		JSR	DrawTankColumn_XTimes ;	����� ������� �� 4-� �ࠦ�᪨�	⠭��� X ࠧ (����প� � � �३���)

loc_CDDD:				; �᫨ 0, �������� ������ �窮� ��� ⥪�饣� �ࠣ�
		LDA	EndCount_Flag
		BEQ	++++
		JMP	DrawPtsScrn_NxtCount
; ���������������������������������������������������������������������������

++++:					; CODE XREF: Draw_Pts_Screen+10Bj
		INC	Counter
		LDA	Counter
		CMP	#4		; 4 ⨯� ⠭���
		BEQ	loc_CDF4
		LDX	#$14
		JSR	DrawTankColumn_XTimes ;	����� ������� �� 4-� �ࠦ�᪨�	⠭��� X ࠧ (����প� � � �३���)
		JMP	DrawPtsScrn_NxtTank
; ���������������������������������������������������������������������������

loc_CDF4:				; CODE XREF: Draw_Pts_Screen+116j
		LDX	#$1E
		JSR	DrawTankColumn_XTimes ;	����� ������� �� 4-� �ࠦ�᪨�	⠭��� X ࠧ (����প� � � �३���)
		LDA	TotalEnmy_KilledBy1P
		JSR	ByteTo_Num_String
		LDY	#Num_String+1
		LDX	#8
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#$17
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDA	CursorPos
		BEQ	+++++
		LDA	TotalEnmy_KilledBy2P
		JSR	ByteTo_Num_String
		LDY	#Num_String+1
		LDX	#$E
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#$17
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����

+++++:					; CODE XREF: Draw_Pts_Screen+138j
		LDX	#$F
		JSR	DrawTankColumn_XTimes ;	����� ������� �� 4-� �ࠦ�᪨�	⠭��� X ࠧ (����প� � � �३���)

;! �᫨ �������� ����, � �� ��砥 ��㥬 ����� � ������ �� ��ப�� ���� �᫨ �� ��ࠫ ����.
		LDA	Boss_Mode
		BNE	DrawPtsScrn_CheckHQ:

Skip_Boss_Bonus:
		LDA	CursorPos
		BNE	DrawPtsScrn_CheckHQ
		JMP	End_Draw_Pts_Screen
; ���������������������������������������������������������������������������

DrawPtsScrn_CheckHQ:			; CODE XREF: Draw_Pts_Screen+152j
		LDA	HQ_Status	; 80=�⠡ 楫, �᫨ ���� � 㭨�⮦��
		BNE	DrawPtsScrn_CheckNum
		JMP	End_Draw_Pts_Screen
; ���������������������������������������������������������������������������

DrawPtsScrn_CheckNum:			; CODE XREF: Draw_Pts_Screen+159j

		LDA	TotalEnmy_KilledBy2P
		CMP	TotalEnmy_KilledBy1P
		BCS	DrawPtsScrn_CheckLives
Chk_Lives:
		LDA	Player1_Lives
		BEQ	DrawPtsScrn_CheckLives
		LDA	#0		; ���㥬 ��� IP	᫮�� BONUS! 1000PTS
					; �᫨ ������⢮ �窮�	1 ��ப� �����, �
					; �� ��⠫�� ���

Draw_IP_Bonus:
		JSR	Num_To_NumString ; ��ॢ���� �᫮ �� �	� ��ப� NumString
		LDX	#0
		JSR	Add_Score	; �ਡ����� �᫮ �� NumString	� �窠�	��ப� ��
		LDY	#HiScore_1P_String+1
		LDX	#5
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDY	#Num_String+1
		LDX	#1
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#$1A
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
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
		JSR	Add_Life	; �ਡ����� ���� �����, �᫨ ��ப ��ࠡ�⠫ 200� �窮�
		JMP	End_Draw_Pts_Screen
; ���������������������������������������������������������������������������

DrawPtsScrn_CheckLives:			; CODE XREF: Draw_Pts_Screen+162j
					; Draw_Pts_Screen+166j
		LDA	TotalEnmy_KilledBy1P
		CMP	TotalEnmy_KilledBy2P
		BCS	End_Draw_Pts_Screen
		LDA	Player2_Lives
		BEQ	End_Draw_Pts_Screen
		LDA	#0		; ���㥬 ��� IIP ᫮�� BONUS! 1000PTS
					; �᫨ ������⢮ �窮�	2 ��ப� �����, �
					; �� ��⠫�� ���
		JSR	Num_To_NumString ; ��ॢ���� �᫮ �� �	� ��ப� NumString
		LDX	#1
		JSR	Add_Score	; �ਡ����� �᫮ �� NumString	� �窠�	��ப� ��
		LDY	#HiScore_2P_String+1
		LDX	#$17
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDY	#Num_String+1
		LDX	#$14
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#$1A
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
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
		STA	Snd_BonusPts	; ��ࠥ� ����	�����
		STA	byte_31C
		STA	byte_31D
		JSR	Add_Life	; �ਡ����� ���� �����, �᫨ ��ப ��ࠡ�⠫ 200� �窮�

End_Draw_Pts_Screen:			; CODE XREF: Draw_Pts_Screen+154j
					; Draw_Pts_Screen+15Bj
					; Draw_Pts_Screen+1B6j
					; Draw_Pts_Screen+1BDj
					; Draw_Pts_Screen+1C1j
		LDX	#Enmy_KlledBy2P_Count+1
		JSR	DrawTankColumn_XTimes ;	����� ������� �� 4-� �ࠦ�᪨�	⠭��� X ࠧ (����প� � � �३���)
		LDA	#0		; ��砫� ����㧪� �࠭� �롮�	�஢��
		STA	PPU_REG1_Stts
		STA	Char_Index_Base
		STA	byte_6B
		LDA	#0
		STA	BkgPal_Number
		RTS
; End of function Draw_Pts_Screen


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� ��騩 ��� ���	�஢���	�࠭ �窮�

Draw_Pts_Screen_Template:		; CODE XREF: Draw_Pts_Screenp
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	#1
		STA	byte_6B
		LDA	#$24 ; '$'
		STA	PPU_Addr_Ptr
		LDA	#0
		STA	Scroll_Byte
		LDA	#10b
		STA	PPU_REG1_Stts
		LDA	#$30 ; '0'
		STA	Char_Index_Base	; ��砫� ��䨪� ���
		LDA	#3
		STA	BkgPal_Number
		JSR	Screen_Off
		JSR	Null_NT_Buffer
		JSR	Fill_Attrib_Table ; ���࠭�� ��।������ ��ਡ��� � NT_Buffer
		JSR	Store_NT_Buffer_InVRAM ; ����뢠�� �� �࠭ ᮤ�ন���	NT_Buffer
		JSR	Set_PPU
		LDA	#>aHikscore	; k=��
		STA	HighPtr_Byte
		LDA	#<aHikscore	; k=��
		STA	LowPtr_Byte
		LDX	#8
		LDY	#3
		JSR	String_to_Screen_Buffer
		LDY	#HiScore_String+1
		LDX	#$12
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#3
		JSR	Save_Str_To_ScrBuffer ;	�뢮���	Hi-score
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
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#5
		JSR	Save_Str_To_ScrBuffer ;	���㥬 ����� �஢��
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	#>aKplayer	; 'I-PLAYER'
		STA	HighPtr_Byte
		LDA	#<aKplayer	; 'I-PLAYER'
		STA	LowPtr_Byte
		LDX	#3
		LDY	#7
		JSR	String_to_Screen_Buffer
		LDY	#HiScore_1P_String+1
		LDX	#5
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	���㥬 �窨 ��ࢮ�� ��ப�
		LDA	#>Arrow_Left
		STA	HighPtr_Byte
		LDA	#<Arrow_Left
		STA	LowPtr_Byte
		LDX	#$E
		LDY	#$C
		JSR	String_to_Screen_Buffer	; ���㥬 ��५�� ����� 4 ࠧ�
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
		BEQ	Skip_ScndPlayerDraw ; �᫨ ��ப ����, ��५�� ��ࠢ� �	II-Player �� ��㥬
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	#>a_kplayer	; 'II-PLAYER'
		STA	HighPtr_Byte
		LDA	#<a_kplayer	; 'II-PLAYER'
		STA	LowPtr_Byte
		LDX	#$15
		LDY	#7
		JSR	String_to_Screen_Buffer
		LDY	#HiScore_2P_String+1
		LDX	#$17
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#9
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDA	#>Arrow_Right	; �ᯮ������� �� ������� �窮�
		STA	HighPtr_Byte
		LDA	#<Arrow_Right	; �ᯮ������� �� ������� �窮�
		STA	LowPtr_Byte
		LDX	#$11
		LDY	#$C
		JSR	String_to_Screen_Buffer
		LDA	#>Arrow_Right	; �ᯮ������� �� ������� �窮�
		STA	HighPtr_Byte
		LDA	#<Arrow_Right	; �ᯮ������� �� ������� �窮�
		STA	LowPtr_Byte
		LDX	#$11
		LDY	#$F
		JSR	String_to_Screen_Buffer
		LDA	#>Arrow_Right	; �ᯮ������� �� ������� �窮�
		STA	HighPtr_Byte
		LDA	#<Arrow_Right	; �ᯮ������� �� ������� �窮�
		STA	LowPtr_Byte
		LDX	#$11
		LDY	#$12
		JSR	String_to_Screen_Buffer
		LDA	#>Arrow_Right	; �ᯮ������� �� ������� �窮�
		STA	HighPtr_Byte
		LDA	#<Arrow_Right	; �ᯮ������� �� ������� �窮�
		STA	LowPtr_Byte
		LDX	#$11
		LDY	#$15
		JSR	String_to_Screen_Buffer

Skip_ScndPlayerDraw:			; CODE XREF: Draw_Pts_Screen_Template+C1j
		JSR	NMI_Wait	; ���㥬 PTS ��। �뢮��� �窮� �� ����� ��� ⠭��
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
		BEQ	Skip_ScndPlayerPtsDraw ; �᫨ ��ப ����, PTS �� ��㥬
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
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
		JSR	NMI_Wait	; ���㥬 Total � �����
		LDA	#>aLine		; ����᪠ ��� 'TOTAL' �� ������� �窮�
		STA	HighPtr_Byte
		LDA	#<aLine		; ����᪠ ��� 'TOTAL' �� ������� �窮�
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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� ������� �� 4-�	�ࠦ�᪨� ⠭���

Draw_Tank_Column:			; CODE XREF: Draw_Pts_Screen+29p
					; Draw_Pts_Screen+3Fp
					; DrawTankColumn_XTimes+5p
		LDA	#2
		STA	TSA_Pal		; �����	���� �� �ࠩ⮢�� ������ 2
		LDY	#$64 ; 'd'      ; �㤥� �������� ⮫쪮 Y � ��� ⠭�� (��砫�� ������ ⠩�� � Pattern Table)
		LDA	#$80 ; '�'      ; 1 ��� ⠭�� �ࠣ�
		JSR	Draw_Spr_InColumn ; ����� 16�16 �ࠩ�	� 䨪�஢�����	���न��⮩ �
		LDY	#$7C ; '|'
		LDA	#$A0 ; '�'      ; 2 ��� ⠭�� �ࠣ�
		JSR	Draw_Spr_InColumn ; ����� 16�16 �ࠩ�	� 䨪�஢�����	���न��⮩ �
		LDY	#$94 ; '�'
		LDA	#$C0 ; '�'      ; 3 ��� ⠭�� �ࠣ�
		JSR	Draw_Spr_InColumn ; ����� 16�16 �ࠩ�	� 䨪�஢�����	���न��⮩ �
		LDY	#$AC ; '�'
		LDA	#$E0 ; '�'      ; 4 ��� ⠭�� �ࠣ�
		JSR	Draw_Spr_InColumn ; ����� 16�16 �ࠩ�	� 䨪�஢�����	���न��⮩ �
		RTS
; End of function Draw_Tank_Column


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ���࠭�� ��।������ ��ਡ��� � NT_Buffer

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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� 16�16 �ࠩ� �	䨪�஢����� ���न��⮩ �

Draw_Spr_InColumn:			; CODE XREF: Draw_Tank_Column+8p
					; Draw_Tank_Column+Fp
					; Draw_Tank_Column+16p
					; Draw_Tank_Column+1Dp
		STA	Spr_TileIndex
		LDX	#$81
		JSR	Draw_WholeSpr	; C���뢠�� � �ࠩ⮢� ����� �ࠩ�	16�16. (� �, Y - ���न����)
		RTS
; End of function Draw_Spr_InColumn


; ��������������� S U B	R O U T	I N E ���������������������������������������

; �ਡ����� ���� �����, �᫨ ��ப ��ࠡ�⠫ 200� �窮�

Add_Life:				; CODE XREF: Draw_Pts_Screen+69p
					; Draw_Pts_Screen+87p
					; Draw_Pts_Screen+1B3p
					; Draw_Pts_Screen+20Ep
					; BulletToTank_Impact_Handle+11Bp
					; Bonus_Handle+4Ep
		LDA	HQ_Status	; 80=�⠡ 楫, �᫨ ���� � 㭨�⮦��
		CMP	#$80
		BNE	End_Add_Life	; �᫨ �⠡ ࠧ��襭, �� �஢��塞 �窨
		LDA	AddLife_Flag	;  <>0 - ��ப ����砫 �������⥫��� �����
		BNE	+
		LDA	HiScore_1P_String+2
		CMP	#2
		BCC	+
		INC	Player1_Lives
		INC	AddLife_Flag	;  <>0 - ��ப ����砫 �������⥫��� �����
		JMP	Play_SndAncillaryLife
; ���������������������������������������������������������������������������

+:					; CODE XREF: Add_Life+8j Add_Life+Ej
		LDA	CursorPos
		BEQ	End_Add_Life	; �᫨ ��ப ����, �� �஢��塞	�窨 ��ண�
		LDA	AddLife_Flag+1	;  <>0 - ��ப ����砫 �������⥫��� �����
		BNE	End_Add_Life
		LDA	HiScore_2P_String+2
		CMP	#2
		BCC	End_Add_Life
		INC	Player2_Lives
		INC	AddLife_Flag+1	;  <>0 - ��ப ����砫 �������⥫��� �����

Play_SndAncillaryLife:			; CODE XREF: Add_Life+14j
		LDA	#1
		STA	Snd_Ancillary_Life1 ; �ந��뢠�� ���
		STA	Snd_Ancillary_Life2

End_Add_Life:				; CODE XREF: Add_Life+4j Add_Life+19j
					; Add_Life+1Dj	Add_Life+23j
		RTS
; End of function Add_Life


; ��������������� S U B	R O U T	I N E ���������������������������������������


Null_Upper_NT:				; CODE XREF: BonusLevel_ButtonCheck:New_Scrollp
					; BonusLevel_ButtonCheck+28p
		JSR	Screen_Off
		LDA	#3
		STA	BkgPal_Number
		LDA	#$1C
		STA	PPU_Addr_Ptr
		JSR	Null_NT_Buffer
		JSR	Store_NT_Buffer_InVRAM ; ����뢠�� �� �࠭ ᮤ�ন���	NT_Buffer
		JSR	Set_PPU
		RTS
; End of function Null_Upper_NT


; ��������������� S U B	R O U T	I N E ���������������������������������������


Draw_TitleScreen:			; CODE XREF: ROM:BEGINp
		JSR	Screen_Off
		LDA	#$24 ; '$'
		STA	PPU_Addr_Ptr
		JSR	Null_NT_Buffer
		LDX	#$1A
		STX	Block_X
		LDY	#$1E ; '.'
		STY	Block_Y
		LDA	#>aBattle	; ����㧪� 㪠��⥫� ��	string 'BATTLE'
		STA	HighStrPtr_Byte
		LDA	#<aBattle	; "BATTLE\xFF"
		STA	LowStrPtr_Byte
		JSR	Draw_BrickStr
		LDX	#$3C ; '<'
		STX	Block_X
		LDY	#$46 ; 'V'
		STY	Block_Y
		LDA	#>aCity:	; ����㧪� 㪠��⥫� ��	string 'CITY'
		STA	HighStrPtr_Byte
		LDA	#<aCity:	; "CITY\xFF"
		STA	LowStrPtr_Byte
		JSR	Draw_BrickStr
		JSR	Store_NT_Buffer_InVRAM ; ����뢠�� �� �࠭ ᮤ�ন���	NT_Buffer
		JSR	Set_PPU
		LDA	#$30		; �����	� ������������ ��稭����� ��	����� $30 (�� ASCII)
		STA	Char_Index_Base
		LDA	#>aK		; ����㧪� 㪠��⥫� ��	string 'I-'
		STA	HighPtr_Byte
		LDA	#<aK		; ��� �࠭� ������� �窮�: 'I-'
		STA	LowPtr_Byte
		LDX	#2		; ���न��� X ���饩 ������
		LDY	#3		; ���न��� Y ���饩 ������
		JSR	String_to_Screen_Buffer
		LDY	#$16
		LDX	#4
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#3
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDA	#>aHik		; ����㧪� 㪠��⥫� ��	string 'HI-'
		STA	HighPtr_Byte
		LDA	#<aHik		; HI-
		STA	LowPtr_Byte
		LDX	#$B
		LDY	#3
		JSR	String_to_Screen_Buffer
		LDY	#$3E ; '>'
		LDX	#$E
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#3
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����
		LDA	CursorPos
		BEQ	+
		LDA	#>a_k		; �᫨ ����� �� ������	RESET �� �� ��	����樨	1 player,
					; ����� �㦭� ���ᮢ��� ����� �� �窠� ��ண� ��ப�.
					; (����᭮, �� �� �ࠢ������ ���� ��� construction)
		STA	HighPtr_Byte
		LDA	#<a_k		; ��� �࠭� ������� �窮�: 'II-'
		STA	LowPtr_Byte
		LDX	#$15
		LDY	#3
		JSR	String_to_Screen_Buffer
		LDY	#$1E
		LDX	#$17
		JSR	PtrToNonzeroStrElem ; ��⠭����	㪠��⥫� �� ���㫥��� ����� ��ப�
		LDY	#3
		JSR	Save_Str_To_ScrBuffer ;	���࠭�� ��ப� � ��ப��� �����

+:					; CODE XREF: Draw_TitleScreen+72j
		LDA	#0
		STA	Char_Index_Base
		JSR	NMI_Wait	; ���㥬 ������	���� ���쭨��:
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
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		LDA	#>aMAP_MODE	; �����	⠩����� ����� ��� ������ NAMCOT
		STA	HighPtr_Byte
		LDA	#<aMAP_MODE	; �����	⠩����� ����� ��� ������ NAMCOT
		STA	LowPtr_Byte
		LDX	#$B
		LDY	#$17
		JSR	String_to_Screen_Buffer
		LDA	#>Copyrights	; ����, � ��砫� ����	��ࢠ� ��� ��	1980 � 1981
		STA	HighPtr_Byte
		LDA	#<Copyrights	; ����, � ��砫� ����	��ࢠ� ��� ��	1980 � 1981
		STA	LowPtr_Byte
		LDX	#1
		LDY	#$19
		JSR	String_to_Screen_Buffer
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
;!���㥬 ����� Map_Mode
		LDA	Map_Mode_Pos	
		ASL	A		; �2 (㪠��⥫�	���塠�⮢�)
		TAY
		LDA	MAP_MODE_STRINGS,Y
		STA	LowPtr_Byte
		LDA	MAP_MODE_STRINGS+1,Y
		STA	HighPtr_Byte
		LDX	#$11
		LDY	#$17
		JSR	String_to_Screen_Buffer
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
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


; ��������������� S U B	R O U T	I N E ���������������������������������������

; ����� ������� �� 4-�	�ࠦ�᪨� ⠭��� X ࠧ (����প� � � �३���)

DrawTankColumn_XTimes:			; CODE XREF: Draw_Pts_Screen+5p
					; Draw_Pts_Screen+106p
					; Draw_Pts_Screen+11Ap
					; Draw_Pts_Screen+122p
					; Draw_Pts_Screen+14Dp
					; Draw_Pts_Screen+213p
					; DrawTankColumn_XTimes+Bj
		JSR	NMI_Wait	; ������� ����᪨�㥬��� ���뢠���
		TXA
		PHA
		JSR	Draw_Tank_Column ; ����� ������� �� 4-� �ࠦ�᪨� ⠭���
		PLA
		TAX
		DEX
		BNE	DrawTankColumn_XTimes ;	����� ������� �� 4-� �ࠦ�᪨�	⠭��� X ࠧ (����প� � � �३���)
		RTS
; End of function DrawTankColumn_XTimes



; ���������������������������������������������������������������������������

TankKill_Pts:	.BYTE $10, $20,	$30, $40 ; DATA	XREF: Draw_Pts_Screen+48r
					; ������⢮ �窮� �� ����� ⨯ 㡨⮣� �ࠣ�
;����稭� ���饭�� ���न��� ������ GameOver	� ⠭��	� Construction:
;�� 4 ���� �� X u Y - ���� �����������	�ந�������
;�஫���� � �� ���ࠢ�����
;� ��砥 ⠭��, �� ���� ��������� ���ࠢ����� ��������:
;�����,	�����, ����, ��ࠢ�
;(����⥫��	�᫠ �ਢ���� � �஫����� � ���⭮� ���ࠢ�����)
;����� �� ���ᨢ� �ᯮ������ �� ���ᠬ $E46C,	$EA49
Coord_X_Increment:.BYTE	0, $FF,	0, 1	; DATA XREF: Move_Tank+33r
					; GameOver_Str_Move_Handle+26r
Coord_Y_Increment:.BYTE	$FF, 0,	1, 0	; DATA XREF: Move_Tank+3Fr
 					; GameOver_Str_Move_Handle+30r

; ���������������������������������������������������������������������������
INCLUDE COMMON.asm; ���� ��騥 ��楤���, �ᯮ��㥬� ��ன �뭥ᥭ� � �⤥��� 䠩�.
INCLUDE STRINGS.asm; �� ��ப�, ����� ���ᮢ뢠���� � ��� �뭥ᥭ� � �⤥��� 䠩�.
INCLUDE SOUND.asm ; ��㪮��� ������ �뭥ᥭ � �⤥��� 䠩�.

; ���������������������������������������������������������������������������
PAD $FFFA
;������ ���뢠���:
		.WORD NMI		; Non-Maskable Interrupt Vector
		.WORD RESET		; RESET	Interrupt Vector
		.WORD RESET		; IRQ/BRK Interrupt Vector


; end of 'ROM'


		.END
