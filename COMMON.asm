; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

NMI:					; DATA XREF: ROM:FFFAo
		PHA
		TXA
		PHA
		TYA
		PHA
		PHP			; 묅젺쩆設��� 췅�젷� NMI
		LDA	#0
		STA	PPU_SPR_ADDR	; 댂ⓩ쯄エ쭬與�	ㄻ� 쭬�ⓤ� � �乘ⅱ�� 젮誓� SPR OAM
		LDA	#2
		STA	SPR_DMA		; 뫍�젵獸�硫 ▲狎�� ▲ㄵ� �� 젮誓率 $200
		LDA	PPU_STATUS	; Reset	VBlank Occurance
		JSR	Update_Screen	; 몼�昔� �� Screen_Buffer � 캙э筍 PPU
		LDA	BkgPal_Number
		BMI	Skip_PalLoad
		JSR	Load_Bkg_Pal

Skip_PalLoad:				; CODE XREF: ROM:D418j
		LDA	PPU_REG1_Stts
		ORA	#10110000b	; 뮜�①췅� ㄻ� BC ぎ�十ｃ�졿⑨ PPU (뫍�젵瞬 ㏇ⅲ쩆 8�16	(鼇黍췅	� �吟���))
		STA	PPU_CTRL_REG1	; PPU Control Register #1 (W)
		LDA	#0		; 렊�젩�洙� 稅昔カÞ짛
		STA	PPU_SCROLL_REG	; VRAM Address Register	#1 (W2)
		LDA	Scroll_Byte
		STA	PPU_SCROLL_REG	; VRAM Address Register	#1 (W2)
		LDA	#00011110b	; 궕ヮ�젰� ≫ぃ�졼�� � 召�젵瞬
		STA	PPU_CTRL_REG2	; PPU Control Register #2 (W)
		JSR	Read_Joypads
		JSR	Spr_Invisible	; 귣¡�	Y ぎ�西Þ졻 召�젵獸� � $F0
		JSR	Play_Sound	; 젺젷�（嶺� Play � NSF	兒席졻�
		INC	Frame_Counter
		LDA	Frame_Counter
		AND	#63		; � �ㄽ�� 醒ゃ�ㄵ 64 菴ⅸ쵟?
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

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 깗몭,	� � 笹晨젵��� 葉笹�

Get_Random_A:				; CODE XREF: ROM:DC8Cp	ROM:DD17p
					; ROM:Get_RandomStatusp ROM:DD4Fp
					; Load_AI_Status:Load_AIStatus_GetRandomp
					; Get_RandomDirection+12p
					; Make_Enemy_Shot+Fp
					; Bonus_Appear_Handle:-p
					; Bonus_Appear_Handle+Fp
					; Bonus_Appear_Handle+28p
		TXA
;깗몭 �� �說�쥯� 췅 쭬ぎ췅� �졹�誓ㄵゥ�⑨,
;��將�с �琉젰�	�αャ�젵�瑜 葉笹�. 댾��レ㎯β ㄲ�
;줎⒱�:	Random_Hi 쭬˘歲� � 獸�	葉笹� �� �젵Д�� 醒ゃ��,
;Random_Lo - �說�˛�� 줎⒱
		PHA			; 뫌魚젺畑� �
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
		ADC	Temp,X		; 귣〃�젰恂� 笹晨젵췅� 瀞ⅸ첓 �� Zero Page
					; � �昔�㎖�レ�臾 ㎛좂����� ㄻ� ‘レ蜈� "笹晨젵��飡�"
		STA	Random_Lo
		PLA
		TAX			; 귣�졹え쥯�� �
		LDA	Random_Lo
		RTS
; End of function Get_Random_A

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 깗몭,	� � 笹晨젵��� 葉笹�

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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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
		STA	PPU_CTRL_REG1	; 뵰���硫 ㎛젶�％���졻�� - ™�昔�;
					; 召�젵瞬 8�16;
					; �誘�キ汀� NMI	�黍 VBlank'�
		RTS
; End of function Set_PPU


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Screen_Off:				; CODE XREF: ROM:C0B2p	Clear_NTp
					; Load_DemoLevel+2Bp
					; Draw_Record_HiScorep
					; Show_Secret_Msgp Show_Secret_Msg+BEp
					; Draw_Brick_GameOverp
					; Draw_Brick_GameOver:End_Draw_Brick_GameOverp
					; Draw_Pts_Screen_Template+1Bp
					; Null_Upper_NTp Draw_TitleScreenp
		JSR	NMI_Wait	; 렑Ħ젰� ��쵟稅ⓣ濕М． �誓贍쥯�⑨
		LDA	#00010000b
		STA	PPU_CTRL_REG1	; 꽞� ≫ぃ�졼�쩆 췅㎛좂�� ™�昔� ㎛젶�％���졻��,
					; � ㄻ�	召�젵獸� - ��舒硫
					;
		LDA	#00000110b
		STA	PPU_CTRL_REG2	; 뵰� �	召�젵瞬	�洙ヮ曄��
		RTS
; End of function Screen_Off


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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
		LDA	#4		; 뫍�젵獸�硫 곥狎�� 쭬��キ畑� 曄誓� 4 줎⒱�
		STA	Gap
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		JSR	Null_NT_Buffer
		JSR	Spr_Invisible	; 뱼�ㄸ� ㏇� 召�젵瞬 쭬	咨�젺
		LDX	#HiScore_1P_String
		JSR	Null_8Bytes_String
		LDX	#HiScore_2P_String
		JSR	Null_8Bytes_String
		JSR	StaffStr_Check	; 0=� RAM �β 飡昔え StaffString
					; 1=� RAM α筍 飡昔첓 StaffString
		BNE	HotBoot		; 롧ⓤ洙� �‥ⓨ	�젵ギ�音 첓設

		LDX	#HiScore_String
		JSR	Null_8Bytes_String
		LDA	#2
		STA	HiScore_String+2 ; 뇿�ⓤ猶젰� �	HiScore	葉笹� 20000
		LDA	#0
		STA	CursorPos	; 볚�젺젪エ쥯��	ゃ褻�� 췅 췅ㄿⓤ� '1 player'
		STA     Map_Mode_Pos
		STA	Boss_Mode
;! 끷エ 쭬｀習첓 若ギㄽ좑, ÞⓩĿ說�� ��Д�� 侁�˛ⅸ. 뤲� 誓醒收 ��� �� ㄾウ�� 聖�졹猶졻藺�.
		LDA	#1
		STA	Level_Number



HotBoot:				; CODE XREF: Reset_ScreenStuff+2Ej
		LDA	#$1C		; 롧ⓤ洙� �‥ⓨ	�젵ギ�音 첓設
		STA	PPU_Addr_Ptr	; 1c+04=20 (쭬�ⓤ� � $2000 VRAM)[NT#1]
		JSR	Store_NT_Buffer_InVRAM ; 몼�졹猶젰� 췅 咨�젺 貰ㄵ逝º��	NT_Buffer
		LDA	#$24 ; '$'
		STA	PPU_Addr_Ptr	; 24+4=28 (� 2800)[NT#2]
		JSR	Store_NT_Buffer_InVRAM ; 몼�졹猶젰� 췅 咨�젺 貰ㄵ逝º��	NT_Buffer
		JSR	StaffStr_Store	; 뇿��Ж췅��, 譽� ª�� 〓쳽 拾�	˚ヮ曄췅
					; (췅 笹晨젵 ��誓쭬｀習え RESET'��)
		JSR	Sound_Stop	; 롟�젺젪エ쥯��	㎖丞, ˚ヮ�젰� 첓췅ル �	�.�. (젺젷�（嶺� Load �	NSF 兒席졻�)
		RTS
; End of function Reset_ScreenStuff


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 뇿��Ж췅��, 譽� ª�� 〓쳽 拾�	˚ヮ曄췅
; (췅 笹晨젵 ��誓쭬｀習え RESET'��)

StaffStr_Store:				; CODE XREF: Reset_ScreenStuff+4Bp
		LDX	#$F

-:					; CODE XREF: StaffStr_Store+9j
		LDA	StaffString,X	; "RYOUITI OOKUBO  TAKEFUMI HYOUDOUJUNKO O"...
		STA	StaffString_RAM,X
		DEX
		BPL	-
		RTS
; End of function StaffStr_Store


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 끷エ 將�� 飡昔え �β � RAM, 獸 ª�� 飡졷栒β ��舒硫 �젳
; (˚ヮ曄췅 き��ぎ� POWER)

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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

ColdBoot:				; CODE XREF: StaffStr_Check+8j
		LDA	#0
		RTS
; End of function StaffStr_Check


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Load_Pals:				; CODE XREF: Reset_ScreenStuff+10p
		JSR	VBlank_Wait
		JSR	Spr_Pal_Load
		LDA	#0		; 뜮Д�	16歟β��� Frame룧エ循�
		JSR	Load_Bkg_Pal
		RTS
; End of function Load_Pals


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Load_Bkg_Pal:				; CODE XREF: ROM:D41Ap	Load_Pals+8p
		ASL	A
		ASL	A
		ASL	A
		ASL	A		; A*10
		TAX
		LDY	#$10
		LDA	#$3F ; '?'      ; 룼ㄳ�獸˚� � 쭬�ⓤ� 16 歟β��� 캙エ循� � �∥졹筍 Background 캙エ循
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
		STA	PPU_ADDRESS	; 렊�乘���� 젮誓�� PPU?
		RTS
; End of function Load_Bkg_Pal


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Spr_Pal_Load:				; CODE XREF: Load_Pals+3p
		LDX	#0
		LDY	#$10
		LDA	#$3F ; '?'      ; 룼ㄳ�獸˚� � 쭬�ⓤ� 16 歟β�� � �∥졹筍 召�젵獸�音 캙エ循
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

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;룧エ循�:
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

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


VBlank_Wait:				; CODE XREF: Set_PPUp Load_Palsp -+3j
-:					; PPU Status Register (R)
		LDA	PPU_STATUS
		BPL	-
		RTS
; End of function VBlank_Wait


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


CoordTo_PPUaddress:			; CODE XREF: Draw_StageNumString+7p
					; FillScr_Single_Row+2p
					; String_to_Screen_Bufferp
					; Save_Str_To_ScrBufferp
					; CoordsToRAMPosp Draw_GrayFrame+21p
		LDA	#0
		STA	Temp		; 씕�젺	鼇黍���	$20 �젵ギ�. 묅졷鼇� 줎⒱ 젮誓��	� NT 瑟�エ葉恂�	췅 1, αエ
					; �� 췅�젷� 咨�젺� ▲ㄵ� $100 �젵ギ� Œ� 8 飡昔� �젵ギ�(Y=8).
					; 뮔え�	�□젳��, 飡졷鼇� 줎⒱ М┘� 〓筍 �揖ⓤゥ� �� 兒席乘�: (Y div 8)	Œ� (Y shr 3)
					; 뇿收�	� 飡졷蜈� 줎⒱�	�吟�젪ワβ碎 〃� �2 (飡졷鼇� 줎⒱ 收��閃 �� Д�麟� 4):
					; � 쩆レ�ⅸ蜈�,	� 飡졷蜈с 줎⒱� ▲ㄵ� �黍줎˙��� $1c, �젶 譽� � ⓥ�％ �� ㄾウ��
					; ��ャ葉筍碎 젮誓� Д�麟� $2000	(1-� NT).
					; 뙧젮鼇� 줎⒱ � 將�� 笹晨젰, М┘� 〓筍 �揖ⓤゥ� �� 兒席乘�: (X + Y*($20)) Œ�	(X + (Y	shl 5)).
					; 닽�, ㅰ膝º� 笹�쥯Ж,	循� Й젮鼇� 〃�� Y ㄾウ�� ��誓⒱� � 循�	飡졷鼇�	〃�� X,
					; 譽� �	誓젷�㎜쥯�� � 將�� �昔璵ㅳ誓.
					; __________________________________________
					; 뜝 ℡�ㄵ � � Y: ぎ�西Þ졻� �젵쳽 췅 咨�젺�
					; 뜝 �音�ㄵ A: (飡졷鼇�	줎⒱ - $1c)
					;	    Y:	Й젮鼇�	줎⒱
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
		ORA	#4		; �吟�젪ワ�� ™�昔� 〃�
		RTS
; End of function CoordTo_PPUaddress


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 뒶�ⓣ濕� 졻黍▲瞬 �� NT_Buffer 췅 咨�젺

AttribToScrBuffer:			; CODE XREF: Draw_TSABlock+13p
		JSR	TSA_Pal_Ops
		LDX	ScrBuffer_Pos
		LDA	#$23 ; '#'
		STA	Screen_Buffer,X
		INX
		TYA
		CLC
		ADC	#$C0 ; '�'
		STA	Screen_Buffer,X	; � PPU	▲ㄵ� �ⓤ졻� � 졻黍▲瞬
		INX
		LDA	NT_Buffer+$3C0,Y
		STA	Screen_Buffer,X
		INX
		LDA	#$FF
		STA	Screen_Buffer,X	; 뒶�ζ	飡昔え
		INX
		STX	ScrBuffer_Pos
		RTS
; End of function AttribToScrBuffer


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

++:					; CODE XREF: TSA_Pal_Ops+15j
		LDA	#$FC ; '�'
		JMP	End_TSA_Pal_Ops
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: TSA_Pal_Ops+10j
		TXA
		AND	#2
		BEQ	+++
		LDA	#$3F ; '?'
		JMP	End_TSA_Pal_Ops
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
		LDA	NT_Buffer+$3C0,Y ; 룳蜈� � 졻黍▲瞬
		AND	byte_1
		ORA	CHR_Byte
		STA	NT_Buffer+$3C0,Y
		RTS
; End of function TSA_Pal_Ops


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; A := (A * 4) OR TSA_Pal

OR_Pal:					; CODE XREF: TSA_Pal_Ops+2p
					; TSA_Pal_Ops+5p TSA_Pal_Ops+8p
		ASL	A
		ASL	A
		ORA	TSA_Pal
		RTS
; End of function OR_Pal


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Read_Joypads:				; CODE XREF: ROM:D433p
		LDX	#1
		STX	JOYPAD_PORT1	; Joypad #1 (RW)
		LDY	#0
		STY	JOYPAD_PORT1	; 묅昔�

--:					; CODE XREF: Read_Joypads+27j
		STY	Temp
		LDY	#8		; 8 き����

-:					; CODE XREF: Read_Joypads+18j
		LDA	JOYPAD_PORT1,X	; 뫋좂젷� ���좄Ð젰� ™�昔� ㄶ�⒰殊�, ��獸� ��舒硫
		AND	#3
		CMP	#1
		ROR	Temp
		DEY
		BNE	-		; 뫋좂젷� ���좄Ð젰� ™�昔� ㄶ�⒰殊�, ��獸� ��舒硫
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

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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
		STA	Screen_Buffer,X	; 뫋좂젷� 貰魚젺畑� 젮誓� PPU, ゃ쩆 ▲ㄵ� ¿ⓤ젺� 將� 飡昔첓
		INX
		STA	LowStrPtr_Byte
		LDY	#0

-:					; CODE XREF: String_to_Screen_Buffer+24j
		LDA	(LowPtr_Byte),Y	; 뇿｀拾젰� �拾�硫 飡黍�� �� 릮뙛
		STA	Screen_Buffer,X
		INX
		CMP	#$FF
		BEQ	+
		STA	(LowStrPtr_Byte),Y
		INY
		JMP	-		; 뇿｀拾젰� �拾�硫 飡黍�� �� 릮뙛
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: String_to_Screen_Buffer+1Fj
		STX	ScrBuffer_Pos
		RTS
; End of function String_to_Screen_Buffer


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 뫌魚젺畑� 飡昔ゃ � 飡昔ぎ�硫 ▲狎��

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
		STA	Screen_Buffer,X	; 뫋좂젷� 貰魚젺畑� � ▲狎�� 젮誓� PPU (hi/lo)
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
		CMP	#$FF		; 몼�졹猶젰� � ▲狎��, ��첓 �� ��琠ⓥ碎	ぎ�ζ 飡昔え: $FF
		BEQ	++		; 뫌魚젺º ��㎤與� � ▲狎�誓 � �硫ㄵ�
		INY
		JMP	-
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

++:					; CODE XREF: Save_Str_To_ScrBuffer+20j
		STX	ScrBuffer_Pos	; 뫌魚젺º ��㎤與� � ▲狎�誓 � �硫ㄵ�
		RTS
; End of function Save_Str_To_ScrBuffer


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; � � �	Y 췅 �音�ㄵ ぎ�西Þ졻� � �젵쳽�

GetCoord_InTiles:			; CODE XREF: Get_SprCoord_InTiles+4p
					; SaveSprTo_SprBuffer+Dp ROM:DCD2p
					; ROM:DCF7p Ice_Detect+1Ap
					; GetSprCoord_InTiles+4p
		JSR	XnY_div_8	; 꽖エ�	췅 8 Y � X
; End of function GetCoord_InTiles


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


CoordsToRAMPos:				; CODE XREF: Draw_TSABlock+20p
		JSR	CoordTo_PPUaddress
		STA	HighPtr_Byte
		STY	LowPtr_Byte
		LDY	#0
		RTS
; End of function CoordsToRAMPos


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 꽖エ�	췅 8 Y � X

XnY_div_8:				; CODE XREF: GetCoord_InTilesp
					; Draw_TSABlock+3p
		TYA
;렊揖��	�� ぎ�西Þ졻 � �Ø醒ワ�
;��誓¡ㅿ� � ぎ�西Þ졻�	� �젵쳽�
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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 룯誓¡ㄸ� SPR_XY � �젵ル

Get_SprCoord_InTiles:			; CODE XREF: Draw_Char+44p
		STX	Spr_X
		STY	Spr_Y
		JSR	GetCoord_InTiles ; � � � Y 췅 �音�ㄵ ぎ�西Þ졻�	� �젵쳽�
; End of function Get_SprCoord_InTiles


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 뤲��□젳濕� Temp � 쭬˘歲М飡� �� Spr_Coord

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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 궙㎖�좈젰� ��レ, αエ	�乘ⅱ��	�젵�

Check_Object:				; CODE XREF: BulletToObject_Impact_Handle+3p
		LDA	Temp
		ORA	#$F0 ; '�'
		AND	(LowPtr_Byte),Y
		RTS
; End of function Check_Object


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 맖率β ��젪Œ彛硫 �乙猶 � え晳①��� 飡���

Draw_Destroyed_Brick:			; CODE XREF: BulletToObject_Impact_Handle:BulletToObject_Return1p
		LDA	Temp
		EOR	#$FF
		AND	(LowPtr_Byte),Y
		JSR	Draw_Tile
		RTS
; End of function Draw_Destroyed_Brick


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		LDA	Temp		; 앪� �� ⓤ��レ�畑恂� �Ø�＄�
		ORA	($11),Y
		JSR	Draw_Tile
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Save_to_VRAM:				; CODE XREF: Store_NT_Buffer_InVRAM:-p
		LDA	HighPtr_Byte
		CLC
		ADC	PPU_Addr_Ptr
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	LowPtr_Byte
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	(LowPtr_Byte),Y	; 뮔え�	�□젳��, 쵟遜Ð	RAM'a �猶�ㄸ恂� � Name Table,
					; � 將�	№�э ㏇� �昔飡�젺飡¡ ����졻Ð��� 캙э殊
					; $400-$7FF쭬��キ��� 獸レぎ �젵ギ¡� 첓設�� 췅ㄿⓤ� 'Battle City',
					; 貰飡젪ゥ���� �� え晳①ⅸ
		STA	PPU_DATA	; ⓤ��レ㎯β碎 �黍 �猶�ㄵ 殊栒レ�Ø�
		RTS
; End of function Save_to_VRAM


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 몼�졹猶젰� 췅	咨�젺 貰ㄵ逝º�� NT_Buffer

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
		LDA	#4		; 렊쳽飡� �젵ギ¡� 첓設� � RAM 췅葉췅β碎 � $400
		STA	HighPtr_Byte

-:					; CODE XREF: Store_NT_Buffer_InVRAM+15j
		JSR	Save_to_VRAM
		LDA	#1
		JSR	Inc_Ptr_on_A
		LDA	HighPtr_Byte
		CMP	#8		; 뜢 쭬獄� エ щ 쭬 �誓ㄵル �∥졹殊 $400-$7FF?
		BNE	-
		RTS
; End of function Store_NT_Buffer_InVRAM


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Draw_GrayFrame:				; CODE XREF: Make_GrayFrame+Cp
		LDX	#0
		LDA	#$11		; $11 -	醒贍� �젵� � Pattern Table (�젹첓 醒昔． 歟β�)

Fill_NTBuffer:				; CODE XREF: Draw_GrayFrame+11j
		STA	NT_Buffer,X
		STA	NT_Buffer+$100,X
		STA	NT_Buffer+$200,X
		STA	NT_Buffer+$300,X
		INX
		BNE	Fill_NTBuffer
		LDA	#0		; 궏刷 咨�젺 ⓤ��レ㎯β	0-� 캙エ循�.
		LDX	#$C0		; 룼笹ⅳ��� $40	줎⒱ Name Table	�搜젺� ��� 졻黍▲瞬

Fill_NTAttribBuffer:			; CODE XREF: Draw_GrayFrame+1Bj
		STA	NT_Buffer+$300,X
		INX
		BNE	Fill_NTAttribBuffer
		LDX	Block_X
		LDY	Block_Y
		JSR	CoordTo_PPUaddress
		STA	HighPtr_Byte
		STY	LowPtr_Byte	; 뜝葉췅�� 黍貰쥯筍 曄惜�� ª昔¡� ��ゥ	�� ｀젺ⓩ� �젹え, � �� 咨�젺�.

Draw_BlackRow:				; CODE XREF: Draw_GrayFrame+3Bj
		LDY	Counter2
		DEY

--:					; CODE XREF: Draw_GrayFrame+30j
		LDA	#0		; 뿥惜硫 �信獸�	�젵� ª昔¡． ��ワ
		STA	(LowPtr_Byte),Y
		DEY			; 뇿��キ畑� ��ゥ 曄惜臾	�젵ギ� 召�젪� 췅ゥ¡
		BPL	--		; 뿥惜硫 �信獸�	�젵� ª昔¡． ��ワ
		DEC	Counter
		BEQ	+
		LDA	#$20 ; ' '      ; 룯誓若ㄸ� � 笹ⅳ莘耀с 涉ㅳ �젵ギ�
		JSR	Inc_Ptr_on_A
		JMP	Draw_BlackRow
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: Draw_GrayFrame+34j
		RTS
; End of function Draw_GrayFrame


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Draw_TSABlock:				; CODE XREF: Draw_TSA_On_Tank+8p
					; Make_Respawn+51p Load_Level+58p
		PHA
		STA	Temp
		JSR	XnY_div_8	; 꽖エ�	췅 8 Y � X
		STX	Spr_X
		STY	Spr_Y
		LDY	Temp
		LDA	TSABlock_PalNumber,Y
		STA	TSA_Pal
		LDY	Spr_Y
		JSR	AttribToScrBuffer ; 뒶�ⓣ濕� 졻黍▲瞬 �� NT_Buffer 췅 咨�젺
		LDA	Spr_Y
		AND	#$FE
		TAY
		LDA	Spr_X
		AND	#$FE ; '�'
		TAX
		JSR	CoordsToRAMPos
		PLA
		ASL	A
		ASL	A		; 벉��쬊�� 췅 4	(췅 ぎエ曄飡¡ �젵ギ� �	�ㄽ�� ∥�ぅ)
		TAX
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		LDA	#1		; 룯誓若ㄸ� 췅 �젵� ��젪ⅴ
		JSR	Inc_Ptr_on_A
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		LDA	#$1F		; 렎췅 飡昔첓 Name Table �젳Д昔� � $20	�젵ギ�
					; �.�. ��誓若ㄸ� 췅 飡昔ゃ �Ĳ�	� 췅 �젵� ゥ´�
		JSR	Inc_Ptr_on_A
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		LDA	#1		; 룯誓若ㄸ� 췅 �젵� ��젪ⅴ
		JSR	Inc_Ptr_on_A
		LDA	TSA_data_start,X
		INX
		JSR	Draw_Tile
		RTS
; End of function Draw_TSABlock


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Draw_Char:				; CODE XREF: Draw_BrickStr+14p
		STX	BrickChar_X
		TAX
		TYA
		CLC
		ADC	#$20 ; ' '
		STA	BrickChar_Y
		LDA	#0
		STA	LowPtr_Byte	; 롧ⓤ洙� Й젮蜈． 줎⒱� 丞젳졻�ワ
		LDA	#$10
		STA	HighPtr_Byte	; 볚�젺�˚� 飡졷蜈． 줎⒱�, 譽�〓
					; 쩆レ�ⅸ蜈� 譽���� �昔�㎖�ㄸギ刷
					; �� ™�昔． ㎛젶�％���졻��� (ぎ獸贍�
					; 信�젺�˙�� ㄻ� ≫ぃ�졼�쩆)

Add_10:					; CODE XREF: Draw_Char+19j
		DEX			; 벉��┘��� ASCII ぎ쩆 ▲あ� 췅	$10
		BMI	+
		LDA	#$10
		JSR	Inc_Ptr_on_A
		JMP	Add_10		; ��笹�	쭬´殲��⑨ 將��	�昔璵ㅳ夕�
					; 信ギ˛臾 ��誓若ㄾ� � Ptr_Byte	▲ㄵ�
					; ぎ� ▲あ� � ASCII*$10+$1000;
					; 뜝�黍Д�, ㄻ�	A=$41: $1410
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: Draw_Char+12j
		LDA	HighPtr_Byte
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	LowPtr_Byte
		STA	PPU_ADDRESS	; 볚�젺�˚� 丞젳졻�ワ 췅 譽����
					; �� �∥졹殊 ™�昔． ㎛젶�％���졻���
					;
		LDA	PPU_DATA	; 룯舒�� 譽����	�� PPU "��ゥ짛レ��"
		LDA	#8
		STA	Counter

Read_CHRByte:				; CODE XREF: Draw_Char+33j
		LDA	PPU_DATA	; VRAM I/O Register (RW)
		PHA
		DEC	Counter
		BNE	Read_CHRByte	; 뿨�젰� ¡醒ъ	줎⒱ ��	�∥졹殊
					; Pattern Table, 譽� 貰�手β飡㏂β 聖昔率
					; � 飡ⅹ ｀졽Ø� �搜�レ��� ▲あ� �
					; 兒席졻� 1bpp
					;
					;
		LDA	#8
		STA	Counter		; 8 �젳	▲ㄵ� �좈ⓥ� ��	飡ⅹ� ｀졽Ø�

NextByte:				; CODE XREF: Draw_Char+71j
		PLA
		STA	CHR_Byte
		LDA	#$80 ; '�'
		STA	Mask_CHR_Byte

Next_Bit:				; CODE XREF: Draw_Char+5Fj
		LDX	BrickChar_X	; 說좂젷� � $005D ㏇ⅲ쩆 $1A
		LDY	BrickChar_Y	; 說좂젷� � $005e ㏇ⅲ쩆 $2e+$20=$4E
		JSR	Get_SprCoord_InTiles ; 룯誓¡ㄸ� SPR_XY	� �젵ル
		LDA	CHR_Byte
		AND	Mask_CHR_Byte
		BEQ	Empty_Pixel	; 앪�� �Ø醒レ 塢惜硫
		JSR	NT_Buffer_Process_OR
		JMP	++
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Empty_Pixel:				; CODE XREF: Draw_Char+4Bj
		JSR	NT_Buffer_Process_XOR ;	앪�� �Ø醒レ 塢惜硫

++:					; CODE XREF: Draw_Char+50j
		LDA	BrickChar_X
		CLC
		ADC	#4
		STA	BrickChar_X
		LSR	Mask_CHR_Byte	; ��誓若ㄸ� � 笹ⅳ莘耀с 〃栒
		BCC	Next_Bit	; 說좂젷� � $005D ㏇ⅲ쩆 $1A
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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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
		LDA	(LowStrPtr_Byte),Y ; 묅黍�（ 쭬｀拾좐恂�
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
		JMP	New_Char	; 묅黍�（ 쭬｀拾좐恂�
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

EOS:					; CODE XREF: Draw_BrickStr+8j
		RTS
; End of function Draw_BrickStr


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 렑Ħ젰� ��쵟稅ⓣ濕М． �誓贍쥯�⑨

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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 몼�昔� �� Screen_Buffer � 캙э筍 PPU

Update_Screen:				; CODE XREF: ROM:D413p
		LDX	ScrBuffer_Pos
		LDA	#0
		STA	Screen_Buffer,X
		TAX

-:					; CODE XREF: Update_Screen+27j
		CPX	ScrBuffer_Pos	; 꽡飡ª�呻 エ ぎ�ζ 飡昔ぎ¡．	▲狎���?
		BEQ	Update_Screen_End
		LDA	Screen_Buffer,X
		INX
		STA	PPU_ADDRESS	; VRAM Address Register	#2 (W2)
		LDA	Screen_Buffer,X
		INX
		STA	PPU_ADDRESS	; � 췅�젷� 첓┐�� 飡昔え � Screen_Buffer 飡�汀
					; hi/lo	젮誓��,	ゃ쩆 ▲ㄵ� ´飡ⓤ� 쭬�ⓤ�

--:					; CODE XREF: Update_Screen+2Fj
		LDA	Screen_Buffer,X
		INX
		CMP	#$FF		; 뤲�´夕� 췅 ぎ�ζ 飡昔え
		BNE	++		; 뜢��蓀ⅳ飡´��� 쭬�ⓤ� � 캙э筍 PPU
		LDA	Screen_Buffer,X
		CMP	#$FF
		BNE	-		; 꽡飡ª�呻 エ ぎ�ζ 飡昔ぎ¡．	▲狎���?
		LDA	$17F,X

++:					; CODE XREF: Update_Screen+20j
		STA	PPU_DATA	; 뜢��蓀ⅳ飡´��� 쭬�ⓤ� � 캙э筍 PPU
		JMP	--
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Update_Screen_End:			; CODE XREF: Update_Screen+Aj
		LDA	#0
		STA	ScrBuffer_Pos
		RTS
; End of function Update_Screen


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 볚�젺�˚� 丞젳졻�ワ 췅 ���乘ⅱ�� 姉�Д�� 飡昔え

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
		JMP	PtrToNonzeroStrElem ; 볚�젺�˚�	丞젳졻�ワ 췅 ���乘ⅱ�� 姉�Д�� 飡昔え
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
		STA	HighPtr_Byte	; 묅昔え �졹��쳽짛荻碎 � �誓ㄵ쳽� �乘ⅱ��
					; 飡�젺ⓩ� RAM - 飡졷鼇� 줎⒱ ㏇ⅲ쩆 �젪�� 0
		STY	LowPtr_Byte	; 뮙��閃 丞젳졻�レ 젮誓率β ��舒硫 ���乘ⅱ�� 姉�Д�� 飡昔え
		RTS
; End of function PtrToNonzeroStrElem


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 귣¡ㄸ� 췅 咨�젺 與菴� 誓ぎ西�

Draw_RecordDigit:			; CODE XREF: Draw_Record_HiScore+23p
		LDA	#$10
		STA	Block_X
		LDA	#$64 ; 'd'
		STA	Block_Y
		LDA	#$30 ; '0'      ; 뜝�젷� ｀졽Ø� 與菴
		STA	Char_Index_Base
		LDY	#HiScore_String

-:					; CODE XREF: Draw_RecordDigit+1Bj
		LDA	0,Y
		BNE	+
		INY
		LDA	Block_X
		CLC
		ADC	#$20 ; ' '      ; $20 �젵ギ� � �ㄽ�� 飡昔ぅ
		STA	Block_X
		JMP	-
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: Draw_RecordDigit+11j
		LDA	#0
		STA	HighStrPtr_Byte
		STY	LowStrPtr_Byte
		JSR	Draw_BrickStr
		LDA	#0
		STA	Char_Index_Base
		RTS
; End of function Draw_RecordDigit


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 뜝 �音�ㄵ A =	$FF, ㎛좂ⓥ α筍 誓ぎ西

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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

loc_D98F:				; CODE XREF: Update_HiScore+8j
		BMI	loc_D99E
		LDX	#0		; �� �誘�キŒ�刷

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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

loc_D9AE:				; CODE XREF: Update_HiScore+27j
		BMI	locret_D9BD
		LDX	#0		; 뜢 �誘�キŒ�刷

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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 뤲Æ젪ワβ 葉笹� �� NumString	� �囹젹	ª昔첓 ��

Add_Score:				; CODE XREF: Draw_Pts_Screen+62p
					; Draw_Pts_Screen+80p
					; Draw_Pts_Screen+16Fp
					; Draw_Pts_Screen+1CAp
					; BulletToTank_Impact_Handle+118p
					; Bonus_Handle+4Bp
;! �� �黍줎˙畑� �囹�, αエ ‘�信 ˇ纏 №젫.
		CPX	#2
		BCS	+++
		TXA
		ASL	A
		ASL	A
		ASL	A		; 벉��쬊�� 췅 $10
		CLC
		ADC	#6
		TAX
		LDY	#6
		CLC

-:					; CODE XREF: Add_Score+20j
		LDA	Num_String,Y
		ADC	HiScore_1P_String,X
		CMP	#$A		; 끷エ > 10, 獸	��誓若ㄸ� � 笹ⅳ莘蟯� �젳涉�
		BMI	+
		SEC
		SBC	#$A
		SEC
		JMP	++
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 룯誓¡ㄸ� 葉笹� �� � � 飡昔ゃ	NumString

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
		BEQ	+		; 끷エ ��誓쩆β碎 0, �吟�젪ワ��	1000 �囹��
		AND	#$F
		STA	Num_String+5
		LDA	Temp
		LSR	A
		LSR	A
		LSR	A
		LSR	A
		STA	Num_String+4
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: Num_To_NumString+9j
		LDA	#1		; 끷エ ��誓쩆β碎 0, �吟�젪ワ��	1000 �囹��
		STA	Num_String+3	; 룯誓若ㄸ� � 笹ⅳ莘蟯�	�젳涉�
		RTS
; End of function Num_To_NumString


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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
		CMP	#10		; 뿨笹�	魚젺汀碎 � ㄵ碎殊嶺�� 歲飡�Д -	�ㄸ� ㎛젶 0-9.
					; 끷エ 葉笹� >=	10, 獸 ��琠ワβ碎 ™�昔� ㎛젶.
		BCC	loc_DA28
		SEC
		SBC	#10
		INC	Num_String+5
		JMP	Check_Max	; 뿨笹�	魚젺汀碎 � ㄵ碎殊嶺�� 歲飡�Д -	�ㄸ� ㎛젶 0-9.
					; 끷エ 葉笹� >=	10, 獸 ��琠ワβ碎 ™�昔� ㎛젶.
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

loc_DA28:				; CODE XREF: ByteTo_Num_String+Bj
		STA	Num_String+6
		RTS
; End of function ByteTo_Num_String


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 몼�졹猶젰� � 召�젵獸�硫 ▲狎�� �ㄸ� 召�젵� 8�16

SaveSprTo_SprBuffer:			; CODE XREF: Draw_Pause+1Ap
					; Draw_Pause+25p Draw_Pause+30p
					; Draw_Pause+3Bp Draw_Pause+46p
					; Indexed_SaveSpr+Bp Draw_WholeSpr+9p
					; Draw_WholeSpr+14p
		TXA
; � X �	Y ぎ�西Þ졻� �猶�ㄸМ．	召�젵��
		STA	Spr_X
		CLC
		ADC	#3
		TAX
		TYA
		SEC
		SBC	#8
		STA	Spr_Y
		JSR	GetCoord_InTiles ; 룯誓¡ㄸ� ��	ぎ�西Þ졻 � �Ø醒ワ� � ぎ�西Þ졻� � �젵쳽�
		LDA	(LowPtr_Byte),Y
		CMP	#$22 ; '"'      ; 뤲�´夕� 췅 ��誓醒曄��� 召�젵�� �젺첓 � ゥ貰�: $22 � Pattern Table - �젵� ゥ��
					; � 졻黍▲收 召�젵�� � 將�� 笹晨젰 〃� p = Background Priority
					; ㄾウ�� 〓筍 �吟�젪ゥ�	� 1
		BNE	Skip_Attrib
		LDA	TSA_Pal
		ORA	Spr_Attrib
		STA	TSA_Pal		; 꽡줎˙畑� � 캙エ循젹 ι� � 졻黍▲瞬

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
		ADC	Gap		; 룯誓若ㄸ� � 笹ⅳ莘耀с 召�젵栒
		STA	SprBuffer_Position
		RTS
; End of function SaveSprTo_SprBuffer


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 몼�졹猶젰� � SprBuffer 召�젵�	8�16 貰	細ι����� � �

Indexed_SaveSpr:			; CODE XREF: ROM:E10Ep
		ASL	A
		CLC
		ADC	Spr_TileIndex
		STA	Spr_TileIndex
		TXA
		SEC
		SBC	#5
		TAX
		JSR	SaveSprTo_SprBuffer ; 몼�졹猶젰� � 召�젵獸�硫 ▲狎�� �ㄸ� 召�젵� 8�16
		RTS
; End of function Indexed_SaveSpr


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; Spr_TileIndex	+ (A * 8)

Spr_TileIndex_Add:			; CODE XREF: ROM:DFFFp
		ASL	A
		ASL	A
		ASL	A
		CLC
		ADC	Spr_TileIndex
		STA	Spr_TileIndex
; End of function Spr_TileIndex_Add


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; C□졹猶젰� � 召�젵獸�硫 ▲狎�� 召�젵�	16�16. (� �, Y - ぎ�西Þ졻�)

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
		SBC	#8		; CД�젰п� 췅 �젵� ˙ⅱ�
		TAX
		JSR	SaveSprTo_SprBuffer ; 몼�졹猶젰� � 召�젵獸�硫 ▲狎�� �ㄸ� 召�젵� 8�16
		INC	Spr_TileIndex
		INC	Spr_TileIndex	; � Pattern Table �젵ル	召�젵獸� 魚젺汀碎 � Raw	Interleaved
					; 兒席졻�:
					;
					;		     13
					;		     24
					;
					; 앪� �▲笹�˙��� 收�, 譽� PPU �젩��젰�	� 誓┬Д �젵ギ�,
					; �젳Д惜�飡溢 8�16. � 릮뙠 Д┐� 貰醒ㄽº� �젵쳽Ж � エ�Ŀ ゥ┬� ι� �ㄸ�
					; �젵� - ��將�с 瑟�エ葉쥯�� Þㄵめ 췅 2
		LDX	Temp_X		; 궙遜�젺젪エ쥯�� � - ��誓若ㄸ�	췅 �젵�	��젪ⅴ
		LDY	Temp_Y
		JSR	SaveSprTo_SprBuffer ; 몼�졹猶젰� � 召�젵獸�硫 ▲狎�� �ㄸ� 召�젵� 8�16
		RTS
; End of function Draw_WholeSpr


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 귣¡�	Y ぎ�西Þ졻 召�젵獸� � $F0

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
		ADC	Gap		; 쭬��キ汀� 췅葉췅�� � ぎ���
		TAX
		LDA	#$F0 ; '�'
		STA	SprBuffer,X
		CPX	#4
		BNE	-
		STX	SprBuffer_Position
		RTS
; End of function Spr_Invisible


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 끷エ >0 ¡㎖�좈젰� $1. <0 ¡㎖�좈젰� $FF

Relation_To_Byte:			; CODE XREF: Load_AI_Status+5p
					; Load_AI_Status+12p
		BEQ	End_RelationToByte
		BCS	+
		LDA	#$FF
		JMP	End_RelationToByte
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: Relation_To_Byte+2j
		LDA	#1

End_RelationToByte:			; CODE XREF: Relation_To_Bytej
					; Relation_To_Byte+6j
		RTS
; End of function Relation_To_Byte

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
TSABlock_PalNumber:.BYTE 0, 0, 0, 0, 0,	3, 3, 3, 3, 3, 1, 2, 3,	0, 0, 0
					; DATA XREF: Draw_TSABlock+Cr
;룧エ循� 췅 첓┐硫 TSA ∥�� (㏇ⅲ� 16)
;00 - 歟β え晳①ⅸ
;01 - 歟β ¡ㅻ
;02 - 歟β ゥ��
;03 - 歟β □���
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
;뫌ㄵ逝ⓥ Þㄵめ� �젵ギ� 췅 첓┐硫 TSA ∥��.
;뜝�黍Д�, ∥��	レ쩆 (�� 淞竣� $0C) c�ㄵ逝ⓥ ㏇� 4
;�젵쳽 � Þㄵめ젹� $21 (�젵� � �젶º Þㄵめ�� �
;Pattern Table - 將� �젵� レ쩆)
;
;뜮Д�졿⑨ 笹ⅳ莘�좑:
;1 2
;3 4
;
;16 ¡㎚�┃音 TSA ∥�ぎ�.믞� ��笹ⅳ�ⓨ TSA ∥�첓 �信瞬�	(�� 淞竣� $0D-$0F)


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 닧�젰� � 짛歲� ㎖丞 ㄲĲ��⑨ ぎ＄� �拾��

Play_Snd_Move:				; CODE XREF: Battle_Loop+2Dp
		LDA	Snd_Move
		BEQ	No_MoveSound	; 룯舒硫 ª昔�
		LDX	#0		; 룯舒硫 ª昔�
		JSR	Detect_Motion	; 끷エ �젺� ㄾウ�� ㄲª졻藺�, 1
		BNE	End_Play_Snd_Move
		LDX	#1		; 귘�昔� ª昔�
		JSR	Detect_Motion	; 끷エ �젺� ㄾウ�� ㄲª졻藺�, 1
		BNE	End_Play_Snd_Move
		LDA	#0
		STA	Snd_Move	; 깲歲�	㎖丞 ㄲĲ��⑨
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

No_MoveSound:				; CODE XREF: Play_Snd_Move+3j
		LDX	#0		; 룯舒硫 ª昔�
		JSR	Detect_Motion	; 끷エ �젺� ㄾウ�� ㄲª졻藺�, 1
		BNE	+
		LDX	#1		; 귘�昔� ª昔�
		JSR	Detect_Motion	; 끷エ �젺� ㄾウ�� ㄲª졻藺�, 1
		BEQ	End_Play_Snd_Move

+:					; CODE XREF: Play_Snd_Move+1Ej
		LDA	#1
		STA	Snd_Move	; 닧�젰� ㎖丞 ㄲĲ��⑨

End_Play_Snd_Move:			; CODE XREF: Play_Snd_Move+Aj
					; Play_Snd_Move+11j Play_Snd_Move+25j
		RTS
; End of function Play_Snd_Move


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 끷エ �젺� ㄾウ�� ㄲª졻藺�, 1

Detect_Motion:				; CODE XREF: Play_Snd_Move+7p
					; Play_Snd_Move+Ep Play_Snd_Move+1Bp
					; Play_Snd_Move+22p
		LDA	Joypad1_Buttons,X
		AND	#$F0 ; '�'
		BEQ	End_Detect_Motion ; 끷エ か젪②� 承�젪ゥ�⑨ �� 췅쬊瞬, ¡㎖�좈젰� ��レ
		LDA	Tank_Status,X
		BEQ	End_Detect_Motion ; 끷エ �젺첓 �β, ¡㎖�좈젰� ��レ
		LDA	#1
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

End_Detect_Motion:			; CODE XREF: Detect_Motion+4j
					; Detect_Motion+8j
		LDA	#0
		RTS
; End of function Detect_Motion


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Respawn_Handle:				; CODE XREF: Battle_Loop+1Bp
		LDA	Respawn_Timer	; 귖�э	ㄾ 笹ⅳ莘耀． 誓召졼췅
		BEQ	+		; 끷エ №�э 笹ⅳ莘耀．	誓召졼췅 �� �黍獄�, �音�ㄸ�
		DEC	Respawn_Timer	; 귖�э	ㄾ 笹ⅳ莘耀． 誓召졼췅
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: Respawn_Handle+2j
		LDA	Enemy_Reinforce_Count ;	뒶エ曄飡¡ №젫�� � 쭬캙醒
		BEQ	End_Respawn_Handle ; 끷エ №젫�� � 쭬캙醒 �� �飡젷�刷, �音�ㄸ�
		LDA	TanksOnScreen	; 뙛めº젷彛�� ぎエ曄飡¡ ㏇ε �젺ぎ� 췅 咨�젺�
		STA	Counter

-:					; CODE XREF: Respawn_Handle+2Aj
		LDX	Counter
		LDA	Tank_Status,X
		BNE	++		; 맖率�� 誓召졼�� 收� �젺첓�, ぎ獸贍� 拾� �β 췅 咨�젺�
		LDA	Respawn_Delay	; 뇿ㄵ逝첓 Д┐� 誓召졼췅Ж №젫��
		STA	Respawn_Timer	; 궙遜�젺젪エ쥯�� �젵Д�
		JSR	Make_Respawn
		DEC	Enemy_Reinforce_Count ;	뒶エ曄飡¡ №젫�� � 쭬캙醒
		LDA	Enemy_Reinforce_Count ;	뒶エ曄飡¡ №젫�� � 쭬캙醒
		JSR	Draw_EmptyTile	; 맖率β �信獸�	�젵� � ぎギ�ぅ 쭬캙貰� №젫��, ぎ＄� ��� �音�ㅿ�
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

++:					; CODE XREF: Respawn_Handle+13j
		DEC	Counter
		LDA	Counter
		CMP	#1		; 뜢 �□젩졻猶젰� �‘ⓨ	ª昔ぎ�
		BNE	-

End_Respawn_Handle:			; CODE XREF: Respawn_Handle+9j
		RTS
; End of function Respawn_Handle


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 귣��キ畑� 稅�レ┘���,	αエ �젺� ㄲª젰恂� 췅 レㅳ

Ice_Move:				; CODE XREF: Battle_Loop+3p
		LDA	Frame_Counter
		AND	#1
		BNE	+		; 렊�젩졻猶젰� 獸レぎ ª昔ぎ�
		LDA	Frame_Counter
		AND	#3
		BNE	End_Ice_Move	; 떘（첓, �� �昔�㎖�ㅿ�좑 �□젩�洙� 췅 첓┐�� 4-� 菴ⅸД:
					; �.�. αエ ��Д� 菴ⅸ쵟 2, 4, 10, 14, 18

+:					; CODE XREF: Ice_Move+4j
		LDX	#1		; 렊�젩졻猶젰� 獸レぎ ª昔ぎ�

-:					; CODE XREF: Ice_Move+79j
		LDA	Tank_Status,X
		BPL	++++++		; 끷エ �젺� ˇ�舒젺, ��誓若ㄸ� � 笹ⅳ莘耀с
		CMP	#$E0 ; '�'
		BCS	++++++		; 끷エ �젺� 쭬昔┐젰恂�, ��誓若ㄸ� � 笹ⅳ莘耀с
		LDA	Player_Blink_Timer,X ; 뮔ß�� Ж짛�⑨ friendly fire
		BEQ	+++++
		DEC	Player_Blink_Timer,X ; 뮔ß�� Ж짛�⑨ friendly fire
		JMP	Usual_Tank
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+++++:					; CODE XREF: Ice_Move+18j
		LDA	Player_Ice_Status,X
		BPL	++++		; 떒‘ �젺� �� 췅 レㅳ,	エ‘
					; �� 쭬ぎ�葉� 첓殊筍碎
		AND	#$10
		BNE	Usual_Tank

++++:					; CODE XREF: Ice_Move+22j
		LDA	Joypad1_Buttons,X ; 떒‘ �젺� �� 췅 レㅳ, エ‘
					; �� 쭬ぎ�葉� 첓殊筍碎
		JSR	Button_To_DirectionIndex ; $FF = き��え	承�젪ゥ�⑨ �� 췅쬊瞬
		STA	Temp
		BPL	loc_DBB4

Usual_Tank:				; CODE XREF: Ice_Move+1Cj Ice_Move+26j
		LDA	#$80 ; '�'
		JSR	Rise_TankStatus_Bit ; Tank_Status OR �
		LDA	#8
		ORA	Tank_Status,X
		STA	Tank_Status,X
		JMP	++++++		; 룯誓若ㄸ� � 笹ⅳ莘耀с �젺ゃ
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

loc_DBB4:				; CODE XREF: Ice_Move+2Fj
		LDA	Player_Ice_Status,X
		BPL	++
		AND	#$1F
		BNE	++		; 끷エ �젵Д� 稅�レ┘�⑨ ��
					; ぎ�葉メ�, �� ¡遜�젺젪エ쥯�� ⅲ�
		LDA	#$9C		; $1c 菴ⅸМ� ▲ㄵ� 稅�レ㎤筍 �젺�
		STA	Player_Ice_Status,X
		LDA	#1
		STA	Snd_Ice		; 뤲�ª贍쥯�� ㎖丞 稅�レ┘�⑨

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
		DEX			; 룯誓若ㄸ� � 笹ⅳ莘耀с �젺ゃ
		BPL	-

End_Ice_Move:				; CODE XREF: Ice_Move+Aj
					; DATA XREF: ROM:HQExplode_JumpTableo
					; ROM:TankStatus_JumpTableo
					; ROM:TankDraw_JumpTableo
					; ROM:Bullet_Status_JumpTableo
					; ROM:BulletGFX_JumpTableo
		RTS			; ¡㎖�좈젰п� �� RTS
; End of function Ice_Move


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 뇿М�젲Ð젰� №젫��, αエ �拾�� (�□젩�洙� ㄲĲ��⑨)

Motion_Handle:				; CODE XREF: Battle_Loop+6p
		LDA	#7
		STA	Counter		; 귗ⅲ�	¡㎚�┃� 8 �젺ぎ�
		LDA	EnemyFreeze_Timer
		BEQ	Skip_TimerOps
		LDA	Frame_Counter
		AND	#63		; 뒥┐莘 醒ゃ�ㅳ 僧��麟젰� �젵Д� 쭬М昔㎦�
		BNE	Skip_TimerOps
		DEC	EnemyFreeze_Timer

Skip_TimerOps:				; CODE XREF: Motion_Handle+7j
					; Motion_Handle+Dj Motion_Handle+49j
		LDX	Counter
		CPX	#2
		BCS	Enemy		; 끷エ > 2, 獸 將� №젫
		LDA	Frame_Counter
		AND	#1
		BNE	JumpToStatusHandle
		LDA	Frame_Counter
		AND	#3
		BNE	Motion_Handle_Next ; 렊�젩졻猶젰� 飡졻信� �
					; ��誓ㄵゥ��瑜 菴ⅸщ
		JMP	JumpToStatusHandle
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
		CMP	#$A0		; � 걩�	(№젫 �2) 飡졻信 �□젩졻猶젰恂�	� 2
					; �젳� �좈�, ��將�с ��	〓飡誓�	ⅶㄸ�
		BEQ	JumpToStatusHandle
		LDA	Counter
		EOR	Frame_Counter
		AND	#1
		BEQ	Motion_Handle_Next

JumpToStatusHandle:			; CODE XREF: Motion_Handle+1Cj
					; Motion_Handle+24j Motion_Handle+3Aj
		JSR	Status_Core	; 귣��キ畑� ぎ쵟�ㅻ jumptable �	쭬˘歲М飡� �� 飡졻信�

Motion_Handle_Next:			; CODE XREF: Motion_Handle+22j
					; Motion_Handle+32j Motion_Handle+42j
		DEC	Counter
		BPL	Skip_TimerOps
		RTS
; End of function Motion_Handle


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 귣��キ畑� ぎ쵟�ㅻ jumptable �	쭬˘歲М飡� �� 飡졻信�

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

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Misc_Status_Handle:			; DATA XREF: ROM:E4A8o
		CPX	#2		; 렊�젩졻猶젰� 飡졻信� レ쩆, ��㎤與� 循ⅹ� � �.�.
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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Check_TileReach:			; DATA XREF: ROM:E4ACo
		CPX	#2		; 뤲�´涉β � №젫�, ㄾ飡ª エ �� ぎ���	�젵쳽
		BCC	Check_Obj
		LDA	Tank_X,X
		AND	#7
		BNE	Check_Obj
		LDA	Tank_Y,X
		AND	#7
		BNE	Check_Obj
		JSR	Get_Random_A	; 깗몭,	� � 笹晨젵��� 葉笹�
		AND	#$F
		BNE	Check_Obj
		JSR	Get_RandomDirection ; 룼ャ�젰� 笹晨젵��� 췅��젪ゥ��� � 貰魚젺畑� � 飡졻信
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
		JSR	Compare_Block_X	; 묂젪�Ð젰� � � BlockX	� αエ ‘レ蜈, �揖ⓥ젰�	1
		TAX
		LDA	Block_Y
		CLC
		ADC	byte_58
		CLC
		ADC	byte_59
		JSR	Compare_Block_Y	; 묂젪�Ð젰� � � BlockY	� αエ ‘レ蜈, �揖ⓥ젰�	1
		TAY
		JSR	GetCoord_InTiles ; � � � Y 췅 �音�ㄵ ぎ�西Þ졻�	� �젵쳽�
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
		JSR	Compare_Block_X	; 묂젪�Ð젰� � � BlockX	� αエ ‘レ蜈, �揖ⓥ젰�	1
		TAX
		LDA	Block_Y
		CLC
		ADC	byte_59
		SEC
		SBC	byte_58
		JSR	Compare_Block_Y	; 묂젪�Ð젰� � � BlockY	� αエ ‘レ蜈, �揖ⓥ젰�	1
		TAY
		JSR	GetCoord_InTiles ; � � � Y 췅 �音�ㄵ ぎ�西Þ졻�	� �젵쳽�
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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

GetRnd_CheckObj:			; CODE XREF: ROM:DCD7j	ROM:DCDDj
					; ROM:DCFCj ROM:DD02j
		LDX	Counter
		CPX	#2
		BCC	TrackHandle_CheckObj
		JSR	Get_Random_A	; 깗몭,	� � 笹晨젵��� 葉笹�
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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Get_RandomStatus:			; DATA XREF: ROM:E4AAo
		JSR	Get_Random_A	; � �說�˛��, ��ャ�젰� 笹晨젵�硫 飡졻信
		AND	#1
		BEQ	End_Get_RandomStatus
		JSR	Get_Random_A	; 깗몭,	� � 笹晨젵��� 葉笹�
		AND	#1
		BEQ	Sbc_Get_RandomStatus
		LDA	Tank_Status,X
		CLC
		ADC	#1		; 뙠�畑� 췅��젪ゥ��� 췅	‘レ蜈�
		JMP	Save_Get_RandomStatus ;	귣ㄵワ�� 췅��젪ゥ��� � 貰魚젺畑� ⅲ� � 飡졻信
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Sbc_Get_RandomStatus:			; CODE XREF: ROM:DD54j
		LDA	Tank_Status,X
		SEC
		SBC	#1		; 뙠�畑� 췅��젪ゥ��� 췅	Д�麟ⅴ

Save_Get_RandomStatus:			; CODE XREF: ROM:DD5Bj
		AND	#3		; 귣ㄵワ�� 췅��젪ゥ��� � 貰魚젺畑� ⅲ� � 飡졻信
		ORA	#Tank_Status
		STA	Tank_Status,X
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

End_Get_RandomStatus:			; CODE XREF: ROM:DD4Dj
		JSR	Get_RandomDirection ; 룼ャ�젰� 笹晨젵��� 췅��젪ゥ��� � 貰魚젺畑� � 飡졻信
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 묂젪�Ð젰� � � BlockX	� αエ ‘レ蜈, �揖ⓥ젰�	1

Compare_Block_X:			; CODE XREF: ROM:DCC2p	ROM:DCE7p
		CMP	Block_X
		BCC	+
		SEC
		SBC	#1

+:					; CODE XREF: Compare_Block_X+2j
		RTS
; End of function Compare_Block_X


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 묂젪�Ð젰� � � BlockY	� αエ ‘レ蜈, �揖ⓥ젰�	1

Compare_Block_Y:			; CODE XREF: ROM:DCCEp	ROM:DCF3p
		CMP	Block_Y
		BCC	+
		SEC
		SBC	#1

+:					; CODE XREF: Compare_Block_Y+2j
		RTS
; End of function Compare_Block_Y

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Aim_FirstPlayer:			; DATA XREF: ROM:E4B2o
		LDA	Tank_X		; 볚�젺젪エ쥯β	� 첓曄飡´ 璵エ	№젫� ™�昔． ª昔첓
		STA	AI_X_Aim
		LDA	Tank_Y
		STA	AI_Y_Aim
		JMP	Save_AI_ToStatus
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Aim_ScndPlayer:				; DATA XREF: ROM:E4B0o
		LDA	Tank_X+1	; 볚�젺젪エ쥯β	� 첓曄飡´ 璵エ	№젫� ��舒�． ª昔첓
		STA	AI_X_Aim
		LDA	Tank_Y+1
		STA	AI_Y_Aim
		JMP	Save_AI_ToStatus
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Aim_HQ:					; DATA XREF: ROM:E4AEo
		LDA	#$78 ; 'x'      ; 볚�젺젪エ쥯β � 첓曄飡´ 璵ゥ¡� ぎ�西Þ졻� 外젩
		STA	AI_X_Aim
		LDA	#$D8 ; '�'
		STA	AI_Y_Aim

Save_AI_ToStatus:			; CODE XREF: ROM:DD86j	ROM:DD91j
		JSR	Load_AI_Status
		STA	Tank_Status,X
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Load_AI_Status:				; CODE XREF: Demo_AI+16p Demo_AI+2Cp
					; Demo_AI+42p Demo_AI+58p
					; ROM:Save_AI_ToStatusp
		LDA	AI_X_Aim
;뇿｀拾젰� 飡졻信 �� �젩エ劣 � 쭬˘歲М飡� �� �졹飡�輾⑨ ㄾ 璵エ
		SEC
		SBC	Tank_X,X
		JSR	Relation_To_Byte ; 끷エ	>0 ¡㎖�좈젰� $1. <0 ¡㎖�좈젰�	$FF
		CLC
		ADC	#1
		STA	AI_X_DifferFlag
		LDA	AI_Y_Aim
		SEC
		SBC	Tank_Y,X
		JSR	Relation_To_Byte ; 끷エ	>0 ¡㎖�좈젰� $1. <0 ¡㎖�좈젰�	$FF
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
		BCS	Load_AIStatus_GetRandom	; 끷エ 將� №젫, ��ャ�젰� ⅲ� ぎ쵟�ㅳ �� ��舒��
					; Œ� ™�昔� �졹殊 � 쭬˘歲М飡� �� 깗몭
		TXA			; � ª昔첓 쭬｀拾졻� ��	��舒�� Œ� �� ™�昔� �졹殊
					; 쭬˘歲� 獸レぎ �� №�Д��
		ASL	A
		EOR	Seconds_Counter
		AND	#2
		BEQ	loc_DDE4
		JMP	LoadSecondPart
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Load_AIStatus_GetRandom:		; CODE XREF: Load_AI_Status+25j
		JSR	Get_Random_A	; 깗몭,	� � 笹晨젵��� 葉笹�
		AND	#1
		BEQ	loc_DDE4

LoadSecondPart:				; CODE XREF: Load_AI_Status+2Fj
		LDA	#9
		CLC
		ADC	AI_X_DifferFlag	; 룯誓若ㄸ� ¡ ™�說� �졹筍 �젩エ劣
		TAY
		JMP	End_Load_AIStatus
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

loc_DDE4:				; CODE XREF: Load_AI_Status+2Dj
					; Load_AI_Status+37j
		LDY	AI_X_DifferFlag

End_Load_AIStatus:			; CODE XREF: Load_AI_Status+3Fj
		LDA	AI_Status,Y
		RTS
; End of function Load_AI_Status

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Explode_Handle:				; DATA XREF: ROM:E49Ao	ROM:E49Co
					; ROM:E49Eo ROM:E4A0o	ROM:E4A2o
					; ROM:E4A4o ROM:E4A6o
		DEC	Tank_Status,X	; 렊�젩졻猶젰� ˇ贍� �젺첓 (僧��麟젰� 葉笹� ┬㎛ⅸ, GameOver...)
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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SkipRiseBit_Explode_Handle:		; CODE XREF: ROM:DDFBj
		ORA	#3

SaveStts_Explode_Handle:		; CODE XREF: ROM:DDFFj
		STA	Tank_Status,X
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Skip_Explode_Handle:			; CODE XREF: ROM:DDF7j
		STA	Tank_Status,X
		CPX	#2
		BCS	Dec_Enemy_Explode_Handle
		DEC	Player1_Lives,X
		BEQ	CheckHQ_Explode_Handle
		JSR	Make_Respawn
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Dec_Enemy_Explode_Handle:		; CODE XREF: ROM:DE0Bj
		DEC	Enemy_Counter	; 뒶エ曄飡¡ №젫�� 췅 咨�젺� �	� 쭬캙醒
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

CheckHQ_Explode_Handle:			; CODE XREF: ROM:DE0Fj
		LDA	HQ_Status	; 80=外젩 璵�, αエ ��レ 獸 勝①獸┘�
		CMP	#$80 ; '�'      ; 섃젩 璵�? $80=璵�
		BNE	End_Explode_Handle ; �β
		CPX	#1		; 쩆
		BEQ	Check1pLives_Explode_Handle
		LDA	Player2_Lives
		BEQ	End_Explode_Handle
		LDA	#3		; 끷エ ��舒�． ª昔첓 拾� �β, � � ™�昔． �飡젷ⓤ� ┬㎛�,
					; Game Over �維ⅶ젰� 笹ⅱ� 췅��젪�
		STA	GameOverScroll_Type ; 렞誓ㄵワβ ˘� ��誓Д耀�⑨ 췅ㄿⓤ�(0..3)
		LDA	#$20 ; ' '
		STA	GameOverStr_X
		JSR	Init_GameOver_Properties
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Check1pLives_Explode_Handle:		; CODE XREF: ROM:DE20j
		LDA	Player1_Lives
		BEQ	End_Explode_Handle
		LDA	#1		; 끷エ ™�昔． ª昔첓 �β, � � ��舒�． ª昔첓 �飡젷ⓤ� ┬㎛�,
					; Game Over �維ⅶ젰� 召�젪� 췅ゥ¡
		STA	GameOverScroll_Type ; 렞誓ㄵワβ ˘� ��誓Д耀�⑨ 췅ㄿⓤ�(0..3)
		LDA	#$C0 ; '�'
		STA	GameOverStr_X
		JSR	Init_GameOver_Properties

End_Explode_Handle:			; CODE XREF: ROM:DDF0j	ROM:DE1Cj
					; ROM:DE24j ROM:DE36j
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Init_GameOver_Properties:		; CODE XREF: ROM:DE30p	ROM:DE42p
		LDA	#$D
		STA	GameOverStr_Timer ; 댂ⓩ쯄エ㎤說�� �젵Д�
		LDA	#$D8 ; '�'      ; 뜝葉췅�� �琉˘짛筍碎 說�㎯
		STA	GameOverStr_Y
		LDA	#0
		STA	Frame_Counter
		RTS
; End of function Init_GameOver_Properties

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Set_Respawn:				; DATA XREF: ROM:E4B6o
		INC	Tank_Status,X	; 볚�젺젪エ쥯β	� 飡졻信� 맓召졼�
		LDA	Tank_Status,X
		AND	#$F
		CMP	#$E
		BNE	End_Set_Respawn
		LDA	#$E0 ; '�'
		STA	Tank_Status,X

End_Set_Respawn:			; CODE XREF: ROM:DE5Dj
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Load_Tank:				; DATA XREF: ROM:E4B4o
		INC	Tank_Status,X	; 뇿｀拾젰� �拾�硫 殊� ��¡． �젺첓, αエ �拾��
		LDA	Tank_Status,X
		AND	#$F
		CMP	#$E
		BNE	End_Load_Tank
		JSR	Load_New_Tank	; 뇿｀拾젰� �拾�硫 殊� ��¡． �젺첓

End_Load_Tank:				; CODE XREF: ROM:DE6Cj
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 룼ャ�젰� 笹晨젵��� 췅��젪ゥ��� � 貰魚젺畑� � 飡졻信

Get_RandomDirection:			; CODE XREF: ROM:DC93p
					; ROM:End_Get_RandomStatusp
		LDA	Respawn_Delay	; 뇿ㄵ逝첓 Д┐� 誓召졼췅Ж №젫��
		LSR	A
		LSR	A
		CMP	Seconds_Counter
		BCS	loc_DE7F
		LDA	#$B0 ; '�'
		JMP	loc_DEA2
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

loc_DE7F:				; CODE XREF: Get_RandomDirection+6j
		LSR	A
		CMP	Seconds_Counter
		BCC	loc_DE8E
		JSR	Get_Random_A	; 깗몭,	� � 笹晨젵��� 葉笹�
		AND	#3
		ORA	#$A0 ; '�'      ; 룼ャ�젰� 笹晨젵��� 췅��젪ゥ��� �
					; 信�젺젪エ쥯��	�젩�葉�	�젺�
		STA	Tank_Status,X
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

loc_DEA0:				; CODE XREF: Get_RandomDirection+23j
					; Get_RandomDirection+27j
		LDA	#$D0 ; '�'

loc_DEA2:				; CODE XREF: Get_RandomDirection+Aj
					; Get_RandomDirection+2Bj
		JSR	Rise_TankStatus_Bit ; Tank_Status OR �
		RTS
; End of function Get_RandomDirection


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 렊�젩졻猶젰� 飡졻信� ㏇ε 8-Ж �젺ぎ�

TanksStatus_Handle:			; CODE XREF: ROM:C0F9p	ROM:C209p
					; ROM:C244p BonusLevel_ButtonCheck+12p
					; Title_Screen_Loop:+p
		LDA	#0
		STA	Counter

-:					; CODE XREF: TanksStatus_Handle+Fj
		LDX	Counter
		JSR	SingleTankStatus_Handle	; 렊�젩졻猶젰� 飡졻信 �ㄽ�． �젺첓
		INC	Counter
		LDA	Counter
		CMP	#8		; 귗ⅲ�	췅 咨�젺� М┘�	〓筍 8 �젺ぎ�
		BNE	-
		RTS
; End of function TanksStatus_Handle


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 렊�젩졻猶젰� 飡졻信 �ㄽ�． �젺첓

SingleTankStatus_Handle:		; CODE XREF: TanksStatus_Handle+6p
		LDA	Tank_Status,X
		LSR	A
		LSR	A
		LSR	A		; 뱻ⓣ젰� 循� Й젮鼇� 〃�� (췅��젪ゥ���	ㄲĲ��⑨ �젺첓)
		AND	#$FE ; '�'      ;  � �∼乘畑� 曄手�設硫, 譽�〓 �乙�˛汀� 췅 2
					; ㄻ� 쩆レ蜈⑵ⅸ 젮誓�졿Ŀ � �젩エ璵 丞젳졻�ゥ�	ぎ쵟��.
					; 뮔え�	�□젳��	4 �飡젪鼇齬� ⓤ��レ㎯�щ� 〃�� 飡졻信��． 줎⒱�
					; 쩆荻 췅� 16 ¡㎚�┃音	ぎ쵟��
		TAY
		LDA	TankDraw_JumpTable,Y
		STA	LowPtr_Byte
		LDA	TankDraw_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; End of function SingleTankStatus_Handle

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Draw_Small_Explode2:			; DATA XREF: ROM:E4C2o	ROM:E4C4o
					; ROM:E4C6o
		LDA	#0		; 몼�졹猶젰� � Spr_Buffer 16�16	召�젵� ˇ贍쥯
		STA	Spr_Attrib
		LDA	Tank_Status,X
		PHA
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		PLA
		JSR	Draw_Bullet_Ricochet ; 몼�졹猶젰� � 召�젵獸�硫 ▲狎�� 16�16 召�젵� 黍ぎ蜈��
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 몼�졹猶젰� � 召�젵獸�硫 ▲狎�� 16�16 召�젵� 黍ぎ蜈��

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
		ASL	A		; 룼ャ�젰� 細ι���� 췅 �拾�硫 �젵� 黍ぎ蜈��

Draw_Ricochet:				; CODE XREF: ROM:DF2Bp	ROM:DF3Ep
		CLC			; 뜢��蓀ⅳ飡´��� 黍率β ˇ贍� 16�16
		ADC	#$F1 ; '�'      ; 뜝�젷� ｀졽Ø� 黍ぎ蜈��
		STA	Spr_TileIndex
		LDA	#3
		STA	TSA_Pal
		JSR	Draw_WholeSpr	; C□졹猶젰� � 召�젵獸�硫 ▲狎�� 召�젵�	16�16. (� �, Y - ぎ�西Þ졻�)
		RTS
; End of function Draw_Bullet_Ricochet

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Draw_Kill_Points:			; DATA XREF: ROM:E4BAo
		LDA	#0		; 맖率β �囹� 췅 Д飡� ˇ贍쥯 №젫�
		STA	Spr_Attrib
		LDA	Tank_Type,X
		BEQ	Draw_PlayerKill	; 뇿 嵩Ł飡¡ ª昔첓, �囹� �� 黍率荻
		LDA	Tank_Type,X
		LSR	A
		LSR	A
		LSR	A
		AND	#$FC ; '�'
		SEC
		SBC	#$10
		CLC			; 렞誓ㄵワ�� ぎエ曄飡¡	�囹�� �
					; 쭬˘歲М飡� �� 殊캙 嵩ⓥ�． №젫�
		ADC	#$B9 ; '�'      ; 뜝�젷� ｀졽Ø� �囹��
		STA	Spr_TileIndex
		LDA	#3
		STA	TSA_Pal
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		JSR	Draw_WholeSpr	; C□졹猶젰� � 召�젵獸�硫 ▲狎�� 召�젵�	16�16. (� �, Y - ぎ�西Þ졻�)
		JMP	Draw_Kill_Points_Skip
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Draw_PlayerKill:			; CODE XREF: ROM:DF03j
		LDA	Tank_Y,X
		TAY
		LDA	Tank_X,X
		TAX
		LDA	#0
		JSR	Draw_Ricochet	; 맖率�� �젹硫 ��舒硫 殊� ˇ贍쥯

Draw_Kill_Points_Skip:			; CODE XREF: ROM:DF20j
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Draw_Small_Explode1:			; DATA XREF: ROM:E4BCo
		LDA	#0		; 궒贍�	16�16
		STA	Spr_Attrib
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		LDA	#8
		JSR	Draw_Ricochet	; 뜢��蓀ⅳ飡´��� 黍率β ˇ贍� 16�16
		LDA	#$20 ; ' '
		STA	Spr_Attrib	; 뮔�� 쭬 兒���	(笹晨젵, ぎ＄� 召�젵� ��誓醒첓β碎 � ゥ貰�)
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Draw_Big_Explode:			; DATA XREF: ROM:E4BEo	ROM:E4C0o
		LDA	#3		; 몼�졹猶젰� � Spr_Buffer ‘レ溫� ˇ贍�
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
		JSR	Draw_WholeSpr	; C□졹猶젰� � 召�젵獸�硫 ▲狎�� 召�젵�	16�16. (� �, Y - ぎ�西Þ졻�)
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
		JSR	Draw_WholeSpr	; C□졹猶젰� � 召�젵獸�硫 ▲狎�� 召�젵�	16�16. (� �, Y - ぎ�西Þ졻�)
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
		JSR	Draw_WholeSpr	; C□졹猶젰� � 召�젵獸�硫 ▲狎�� 召�젵�	16�16. (� �, Y - ぎ�西Þ졻�)
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
		JSR	Draw_WholeSpr	; C□졹猶젰� � 召�젵獸�硫 ▲狎�� 召�젵�	16�16. (� �, Y - ぎ�西Þ졻�)
		LDA	#$20 ; ' '
		STA	Spr_Attrib
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

OperatingTank:				; DATA XREF: ROM:E4C8o	ROM:E4CAo
					; ROM:E4CCo ROM:E4CEo	ROM:E4D0o
					; ROM:E4D2o
		CPX	#2		; 뜢��蓀ⅳ飡´��� 信�젺젪エ쥯β	� Spr_Tile_Index �拾�硫	�젺�
		BCC	OperTank_Player
		LDA	Tank_Type,X	; 뮔�� №젲αえ�
		AND	#4		; 귣ㄵワ�� 氏젫	‘�信�
		BEQ	OperTank_NotBonus
		LDA	Frame_Counter
		LSR	A
		LSR	A
		LSR	A
		AND	#1
		CLC
		ADC	#2
		JMP	OperTank_Draw	; 렊α�ηÐ젰� 細��� 캙エ循� ㄻ� ‘�信��． �젺첓
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

OperTank_NotBonus:			; CODE XREF: ROM:DFBEj
		LDA	Frame_Counter
		ASL	A
		ASL	A
		CLC
		ADC	Tank_Type,X
		AND	#7
		TAY			; 귣葉笹畑� 캙エ循� ㄻ�	收ゃ耀． �젺첓
		LDA	TankType_Pal,Y	; 8 殊��� �젺ぎ� ⓤ��レ㎯荻 貰�手β飡㏂迹�� 召�젵獸�瑜 캙エ循�
		JMP	OperTank_Draw
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

OperTank_Player:			; CODE XREF: ROM:DFB8j
		LDA	Player_Blink_Timer,X ; 뮔ß�� Ж짛�⑨ friendly fire
		BEQ	OperTank_Skip
		LDA	Frame_Counter
		AND	#8		; 뙣짛��� 4 �젳� � 醒ゃ�ㅳ
		BEQ	OperTank_Skip
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
TankType_Pal:	.BYTE 2, 0, 0, 1, 2, 1,	2, 2 ; DATA XREF: ROM:DFD7r
					; 8 殊��� �젺ぎ� ⓤ��レ㎯荻 貰�手β飡㏂迹�� 召�젵獸�瑜 캙エ循�
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
		ADC	#$A1 ; '�'      ; C $A0 � Pattern Table 췅葉췅β碎 ｀졽Ø� 誓召졼췅
		STA	Spr_TileIndex
		LDA	#3
		STA	TSA_Pal		; 맓召졼� ▲ㄵ�	췅 03 캙エ循�
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		JSR	Draw_WholeSpr	; C□졹猶젰� � 召�젵獸�硫 ▲狎�� 召�젵�	16�16. (� �, Y - ぎ�西Þ졻�)
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 렊�젩졻猶젰� 飡졻信� ㏇ε �乘�

AllBulletsStatus_Handle:		; CODE XREF: Battle_Loop+Cp
		LDA	#9
		STA	Counter		; 렊�젩졻猶젰� 10 �乘� (8 + 2ㄾ��キⓥ�レ�音)

-:					; CODE XREF: AllBulletsStatus_Handle+Bj
		LDX	Counter
		JSR	BulletStatus_Handle ; 닱Д�畑� 飡졻信� �乘� ���	ρ 貰飡�輾��
		DEC	Counter
		BPL	-
		RTS
; End of function AllBulletsStatus_Handle


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 닱Д�畑� 飡졻信� �乘�	��� ρ 貰飡�輾��

BulletStatus_Handle:			; CODE XREF: AllBulletsStatus_Handle+6p
		LDA	Bullet_Status,X
		LSR	A
		LSR	A
		LSR	A
		AND	#$FE ; '�'      ; 嵩ⓣ젰� 循� Й젮鼇� 〃�� � �∼乘畑� 曄手�設硫
		TAY
		LDA	Bullet_Status_JumpTable,Y
		STA	LowPtr_Byte
		LDA	Bullet_Status_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; End of function BulletStatus_Handle

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Bullet_Move:				; DATA XREF: ROM:E4E0o
		LDA	Bullet_Status,X	; 꽓ª젰� �乘� � 貰�手β飡˘� �	Bullet_Status
		AND	#3		; 귣ㄵワ�� 췅��젪ゥ���
		TAY
		JSR	Change_BulletCoord ; 닱Д�畑� ぎ�西Þ졻� �乘� �	貰�手β飡˘� � 췅��젪ゥ����
		LDA	Bullet_Property,X ; 뫇�昔飡� � □��ⅰ�þ�飡�
		AND	#1
		BEQ	End_Bullet_Move	; 끷エ �吟�젪ゥ� 氏젫, Д�畑� ぎ�西Þ졻� ㄲ� �젳�
		JSR	Change_BulletCoord ; 닱Д�畑� ぎ�西Þ졻� �乘� �	貰�手β飡˘� � 췅��젪ゥ����

End_Bullet_Move:			; CODE XREF: ROM:E05Dj
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 닱Д�畑� ぎ�西Þ졻� �乘� � 貰�手β飡˘� � 췅��젪ゥ����

Change_BulletCoord:			; CODE XREF: ROM:E056p	ROM:E05Fp
		LDA	Bullet_Coord_X_Increment_1,Y
;� Y ��Д� 췅��젪ゥ�⑨
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

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Make_Ricochet:				; DATA XREF: ROM:E4DAo	ROM:E4DCo
					; ROM:E4DEo
		DEC	Bullet_Status,X	; 뙠�畑� 飡졻信	�乘� ��� 젺º졿⑧ 黍ぎ蜈��
		LDA	Bullet_Status,X	; 벉��麟젰� 淞β葉� 菴ⅸМ� �ㄽ�． 첓ㅰ�
		AND	#$F
		BNE	End_Animate_Ricochet ; 끷エ 收ゃ蟯� 첓ㅰ ι� ��	췅ㄾ �∼�˙汀�,	�音�ㄸ�
		LDA	Bullet_Status,X
		AND	#$F0 ; '�'
		SEC
		SBC	#$10		; 룯誓若ㄸ� � 笹ⅳ莘耀с 첓ㅰ� 黍ぎ蜈��
		BEQ	Skip_Animate_Ricochet
		ORA	#3		; 3 菴ⅸ쵟 ▲ㄵ� ㄵ逝졻藺� ���硫 첓ㅰ

Skip_Animate_Ricochet:			; CODE XREF: ROM:E085j
		STA	Bullet_Status,X

End_Animate_Ricochet:			; CODE XREF: ROM:E07Cj
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 귣�信첓β �乘� (Д�畑� ρ 飡졻信 � 聲�⒰手�)

Make_Shot:				; CODE XREF: Make_Player_Shot:+p
					; Make_Enemy_Shot+16p
		LDA	Bullet_Status,X
		BNE	End_Make_Shot	; 끷エ �乘� 拾�	�誘申�췅, �音�ㄸ�
		CPX	#2
		BCS	+		; 귣飡誓ル №젫�� �� ㎖晨졻
		LDA	#1
		STA	Snd_Shoot

+:					; CODE XREF: Make_Shot+6j
		LDA	Tank_Status,X
		AND	#3
		TAY
		ORA	#$40 ; '@'
		STA	Bullet_Status,X	; 귣飡젪ワ�� � 飡졻信� �乘� 췅��젪ゥ���
					; �젺첓	� 飡졻信 ��ゥ��
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
		STA	Bullet_Y,X	; 뤵ワ 黍率β碎	˛� �젺첓
		LDA	#0
		STA	Bullet_Property,X ; 뫇�昔飡� � □��ⅰ�þ�飡�
		LDA	Tank_Type,X
		AND	#$F0 ; '�'
		BEQ	End_Make_Shot	; 끷エ �젺� �昔飡��, �音�ㄸ� 蓀젳�
		

		

		CMP	#$C0 ; '�'
		BEQ	QuickBullet_End_Make_Shot ; 6-�	殊� �젺첓 (№젫) 〓飡昔	飡誓ワβ
		CMP	#$60 ; '`'
		BEQ	++
		AND	#$80 ; '�'      ; 끷エ �젺� ª昔첓 ‘�信�硫,
					; � �ⅲ� 〓飡贍� �乘�
		BNE	End_Make_Shot

QuickBullet_End_Make_Shot:		; CODE XREF: Make_Shot+38j
		LDA	#1
		STA	Bullet_Property,X ; 뫇�昔飡� � □��ⅰ�þ�飡�
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

++:					; CODE XREF: Make_Shot+3Cj
		LDA	#3
		STA	Bullet_Property,X ; 끷エ ª昔� 飡젷 �젺ぎ� ��笹ⅳ�ⅲ� 殊캙,
					; � �ⅲ� 〓飡贍� □��ⅰ�þ瑜 �乘�

End_Make_Shot:				; CODE XREF: Make_Shot+2j
					; Make_Shot+34j Make_Shot+40j
		RTS
; End of function Make_Shot


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 맖率β ㏇� �乘�

Draw_All_BulletGFX:			; CODE XREF: ROM:C206p	ROM:C247p
					; BonusLevel_ButtonCheck+15p
		LDA	#9
		STA	Counter		; 10 �乘�

-:					; CODE XREF: Draw_All_BulletGFX+Bj
		LDX	Counter
		JSR	Draw_BulletGFX	; 맖率β �乘� �	쭬˘歲М飡� �� 飡졻信�
		DEC	Counter
		BPL	-
		RTS
; End of function Draw_All_BulletGFX


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 맖率β �乘� �	쭬˘歲М飡� �� 飡졻信�

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

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Draw_Bullet:				; DATA XREF: ROM:E4EAo
		LDA	Bullet_Status,X	; 몼�졹猶젰� � ▲狎�� 召�젵� �乘�
		AND	#3
		PHA			; 귣ㄵワ�� 췅��젪ゥ���
		LDY	Bullet_Y,X
		LDA	Bullet_X,X
		TAX
		LDA	#2
		STA	TSA_Pal
		LDA	#$B1 ; '�'      ; 뜝�젷� ｀졽Ø� �乘�
		STA	Spr_TileIndex
		PLA
		JSR	Indexed_SaveSpr	; 몼�졹猶젰� � SprBuffer 召�젵�	8�16 貰	細ι����� � �
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Update_Ricochet:			; DATA XREF: ROM:E4E4o	ROM:E4E6o
					; ROM:E4E8o
		LDA	Bullet_Status,X	; 맖率β 黍ぎ蜈� � �拾��� Д飡�
		PHA
		LDY	Bullet_Y,X
		LDA	Bullet_X,X
		TAX
		PLA
		CLC
		ADC	#$40 ; '@'
		JSR	Draw_Bullet_Ricochet ; 몼�졹猶젰� � 召�젵獸�硫 ▲狎�� 16�16 召�젵� 黍ぎ蜈��
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 꽖쳽β �吟循�� ª昔첓, αエ 췅쬊�� き��첓

Make_Player_Shot:			; CODE XREF: Battle_Loop+15p
		LDA	#1
;볡ⓥ猶젰� 聲�⒰手� ‘�信��． �젺첓
;飡誓ワ筍 ㄲ僧�	�乘詮� ��ㅰ甸
		STA	Counter		; 렊�젩졻猶젰� 獸レぎ ª昔ぎ�

-:					; CODE XREF: Make_Player_Shot+3Dj
		LDX	Counter
		LDA	Tank_Status,X
		BPL	Next_Jump_Make_Shot ; 끷エ �젺�	ˇ�舒젺, �� �□젩졻猶젰� ⅲ�
		CMP	#$E0 ; '�'
		BCS	Next_Jump_Make_Shot ; 끷エ �젺�	誓召졼�ⓥ碎, ��	�□젩졻猶젰� ⅲ�
		LDA	Joypad1_Differ,X
		AND	#11b
		BEQ	Next_Jump_Make_Shot ; 끷エ �� 췅쬊�� き��첓 �－�, �� �□젩졻猶젰� ª昔첓
		LDA	Tank_Type,X
		AND	#$C0 ; '�'
		CMP	#$40 ; '@'
		BNE	+		; 끷エ �젺� ª昔첓 �� ™�昔� ‘�信�硫,
					; ㄵ쳽�� �昔飡�� �吟循��
		LDA	Bullet_Status,X
		BEQ	+		; 끷エ �乘� 췅 咨�젺� �β,
					; ㄵ쳽�� �昔飡�� �吟循��
		LDA	Bullet_Status+8,X
		BNE	Next_Jump_Make_Shot ; 끷エ ㄾ��キⓥ�レ췅� �乘� 拾� �誘申�췅,
					; ι� �ㄽ� �� �誘信첓��
		LDA	Bullet_Status,X
		STA	Bullet_Status+8,X
		LDA	Bullet_X,X
		STA	Bullet_X+8,X
		LDA	Bullet_Y,X
		STA	Bullet_Y+8,X
		LDA	Bullet_Property,X ; 뫇�昔飡� � □��ⅰ�þ�飡�
		STA	Bullet_Property+8,X ; 뒶�ⓣ濕� ㏇� 聲�⒰手� �乘� �
					; 瀞ⅸゃ ㄻ� ㄾ��キⓥ�レ��� �乘�
		LDA	#0
		STA	Bullet_Status,X

+:					; CODE XREF: Make_Player_Shot+1Aj
					; Make_Player_Shot+1Ej
		JSR	Make_Shot	; 귣�信첓β �乘� (Д�畑� ρ 飡졻信 � 聲�⒰手�)

Next_Jump_Make_Shot:			; CODE XREF: Make_Player_Shot+8j
					; Make_Player_Shot+Cj
					; Make_Player_Shot+12j
					; Make_Player_Shot+22j
		DEC	Counter
		BPL	-
		RTS
; End of function Make_Player_Shot


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 뤲��㎖�ㄸ� �吟循��, ⓤ��レ㎯�	笹晨젵�瑜 葉笹�

Make_Enemy_Shot:			; CODE XREF: Battle_Loop+18p
		LDA	EnemyFreeze_Timer
		BNE	End_Make_Enemy_Shot
		LDX	#7		; 뜝葉췅�� � ��舒�． №젲αぎ．	�젺첓

loc_E169:				; CODE XREF: Make_Enemy_Shot+1Cj
		LDA	Tank_Status,X
		BPL	Next_Make_Enemy_Shot
		CMP	#$E0 ; '�'      ; 끷エ �젺� ˇ�舒젺 Œ� 誓召졼�ⓥ碎,
					; �� �□젩졻猶젰� ⅲ�
		BCS	Next_Make_Enemy_Shot
		JSR	Get_Random_A	; 깗몭,	� � 笹晨젵��� 葉笹�
		AND	#$1F
		BNE	Next_Make_Enemy_Shot
		JSR	Make_Shot	; 귣�信첓β �乘� (Д�畑� ρ 飡졻信 � 聲�⒰手�)

Next_Make_Enemy_Shot:			; CODE XREF: Make_Enemy_Shot+9j
					; Make_Enemy_Shot+Dj
					; Make_Enemy_Shot+14j
		DEX
		CPX	#1		; 닧昔ぎ� �� �□젩졻猶젰�
		BNE	loc_E169

End_Make_Enemy_Shot:			; CODE XREF: Make_Enemy_Shot+3j
		RTS
; End of function Make_Enemy_Shot


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 렊�젩졻猶젰� ª昔첓, αエ 獸�	췅 レㅳ

Ice_Detect:				; CODE XREF: Battle_Loopp
		LDA	#7
		STA	Counter		; 곥ㄵ�	�□젩��젺� 8 �젺ぎ�

-:					; CODE XREF: Ice_Detect+6Fj
		LDX	Counter
		LDA	Tank_Status,X	; 끷エ �젺� ˇ�舒젺, ��	�□젩졻猶젰� ⅲ�
		BPL	Next_Tank
		CMP	#$E0 ; '�'
		BCS	Next_Tank	; 끷エ �젺� 쭬昔┐젰恂�, �� �□젩졻猶젰� ⅲ�
		LDA	Tank_Y,X
		SEC
		SBC	#8
		TAY
		LDA	Tank_X,X
		SEC
		SBC	#8
		TAX
		JSR	GetCoord_InTiles ; � � � Y 췅 �音�ㄵ ぎ�西Þ졻�	� �젵쳽�
		LDX	Counter
		LDA	LowPtr_Byte
		STA	NTAddr_Coord_Lo,X
		LDA	HighPtr_Byte
		AND	#3
		STA	NTAddr_Coord_Hi,X
		LDY	#$21 ; '!'
		CPX	#2
		BCS	++		; 끷エ 將� №젫, ゥㄾ�瑜 聲�⒰手� �� �□젩졻猶젰�
		LDA	(LowPtr_Byte),Y
		CMP	#$21 ; '!'      ; 뤲�´夕� 췅 ヱ� ��� �젺ぎ� (譽���� �� NT_Buffer)
		BNE	+
		LDA	#$80 ; '�'
		ORA	Player_Ice_Status,X
		STA	Player_Ice_Status,X ; 귣飡젪ワ�� 氏젫 レ쩆
		JMP	++
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: Ice_Detect+33j
		LDA	Player_Ice_Status,X
		AND	#$7F ; ''
		STA	Player_Ice_Status,X ; 뱻ⓣ젰� 氏젫 レ쩆

++:					; CODE XREF: Ice_Detect+2Dj
					; Ice_Detect+3Dj
		JSR	Rise_Nt_HighBit	; 귣c�젪ワβ 飡졷鼇� 〃� � Þㄵめ� �젵쳽 � NT_Buffer
		LDA	Tank_X,X
		AND	#7
		BNE	loc_E1DD
		LDA	NTAddr_Coord_Hi,X
		ORA	#$80 ; '�'      ; 뒥┐硫 �젵� ��誓か蹟젰恂� 飡졷鼇� 〃�
		STA	NTAddr_Coord_Hi,X
		LDY	#$20 ; ' '
		JSR	Rise_Nt_HighBit	; 귣c�젪ワβ 飡졷鼇� 〃� � Þㄵめ� �젵쳽 � NT_Buffer

loc_E1DD:				; CODE XREF: Ice_Detect+4Fj
		LDA	Tank_Y,X
		AND	#7
		BNE	Next_Tank
		LDA	NTAddr_Coord_Hi,X
		ORA	#$40 ; '@'
		STA	NTAddr_Coord_Hi,X
		LDY	#1
		JSR	Rise_Nt_HighBit	; 귣c�젪ワβ 飡졷鼇� 〃� � Þㄵめ� �젵쳽 � NT_Buffer

Next_Tank:				; CODE XREF: Ice_Detect+8j
					; Ice_Detect+Cj Ice_Detect+60j
		DEC	Counter
		BPL	-
		RTS
; End of function Ice_Detect


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 귣c�젪ワβ 飡졷鼇� 〃� � Þㄵめ� �젵쳽 � NT_Buffer

Rise_Nt_HighBit:			; CODE XREF: Ice_Detect:++p
					; Ice_Detect+59p Ice_Detect+6Ap
		LDA	(LowPtr_Byte),Y
		ORA	#$80 ; '�'
		STA	(LowPtr_Byte),Y
		RTS
; End of function Rise_Nt_HighBit


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


HideHiBit_Under_Tank:			; CODE XREF: Battle_Loop+9p
		LDA	#7
		STA	Counter		; 렊�젩졻猶젰恂� 8 �젺ぎ�

-:					; CODE XREF: HideHiBit_Under_Tank+37j
		LDX	Counter
		LDA	Tank_Status,X
		BPL	++
		CMP	#$E0 ; '�'
		BCS	++		; 끷エ �젺� ˇ�舒젺 Œ�	誓召졼�ⓥ碎,
					; ��誓若ㄸ� � 笹ⅳ莘耀с
		LDA	NTAddr_Coord_Lo,X
		STA	LowPtr_Byte
		LDA	NTAddr_Coord_Hi,X
		AND	#3
		ORA	#4
		STA	HighPtr_Byte
		LDY	#$21 ; '!'
		JSR	HideHiBit_InBuffer ; 뱻ⓣ젰� 飡졷鼇� 〃� �� (LowPtrByte)
		LDA	NTAddr_Coord_Hi,X
		AND	#$80 ; '�'
		BEQ	+
		LDY	#$20 ; ' '
		JSR	HideHiBit_InBuffer ; 뱻ⓣ젰� 飡졷鼇� 〃� �� (LowPtrByte)

+:					; CODE XREF: HideHiBit_Under_Tank+23j
		LDA	NTAddr_Coord_Hi,X
		AND	#$40 ; '@'
		BEQ	++
		LDY	#1
		JSR	HideHiBit_InBuffer ; 뱻ⓣ젰� 飡졷鼇� 〃� �� (LowPtrByte)

++:					; CODE XREF: HideHiBit_Under_Tank+8j
					; HideHiBit_Under_Tank+Cj
					; HideHiBit_Under_Tank+2Ej
		DEC	Counter
		BPL	-
		RTS
; End of function HideHiBit_Under_Tank


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 뱻ⓣ젰� 飡졷鼇� 〃� �� (LowPtrByte)

HideHiBit_InBuffer:			; CODE XREF: HideHiBit_Under_Tank+1Cp
					; HideHiBit_Under_Tank+27p
					; HideHiBit_Under_Tank+32p
		LDA	(LowPtr_Byte),Y
		AND	#$7F ; ''
		STA	(LowPtr_Byte),Y
		RTS
; End of function HideHiBit_InBuffer


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 맖率β Œ� �信獸栒 Œ� ‘�信 Œ� �囹�	쭬 ‘�信

Bonus_Draw:				; CODE XREF: ROM:Skip_Battle_Loopp
					; ROM:C241p BonusLevel_ButtonCheck+Fp
		LDA	Bonus_X
		BEQ	End_Bonus_Draw	; 끷エ ‘�信� �β, �音�ㄸ�
					;
					; � �昔璵ㅳ誓: αエ ‘�信 �� ˇ汀 (��첓쭬�
					; ‘�信) 淞β葉� №�Д�� �∼乘侏, αエ
					; ‘�信	ˇ汀 (��첓㏓쥯荻碎 �囹�), 淞β葉�
					; 說Ĳ젰恂� � $32 ㄾ �乘�
		LDA	BonusPts_TimeCounter
		BEQ	Bonus_NotTaken	; ‘�信	��첓 ��	ˇ汀
		DEC	BonusPts_TimeCounter ; 겗�信 ˇ汀 � ��琠Œⓤ�
					; �囹� 쭬 �ⅲ�
		BNE	NotZeroCounter
		LDA	#0
		STA	Bonus_X		; 뱻ⓣ젰� �囹� 쭬
					; ‘�信	� 咨�젺�
		JMP	End_Bonus_Draw
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

NotZeroCounter:				; CODE XREF: Bonus_Draw+Aj
		LDA	#2
		STA	TSA_Pal		; 롧え ⓤ��レ㎯荻 캙エ循� 召�젵獸� 2
		LDA	#$3B ; ';'      ; 뮔œ� �囹�� 쭬 ‘�信
					; (500)	�젪�� $3A
		STA	Spr_TileIndex
		JMP	Draw_Bonus
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Bonus_NotTaken:				; CODE XREF: Bonus_Draw+6j
		LDA	Frame_Counter	; ‘�信	��첓 ��	ˇ汀
		AND	#8
		BEQ	End_Bonus_Draw
		LDA	#2
		STA	TSA_Pal		; 겗�信	ⓤ��レ㎯β 캙エ循� 召�젵獸� 2
		LDA	Bonus_Number	; 렞誓ㄵワβ 殊� ‘�信�
		ASL	A
		ASL	A		; 벉��쬊�� 췅 4	(‘�信 �� 4 �젵ギ�)
		CLC
		ADC	#$81 ; '�'      ; ��舒硫 Þㄵめ �젵쳽 ‘�信� �젪�� $80
		STA	Spr_TileIndex

Draw_Bonus:				; CODE XREF: Bonus_Draw+1Bj
		LDX	Bonus_X
		LDY	Bonus_Y
		LDA	#0
		STA	Spr_Attrib
		JSR	Draw_WholeSpr	; C□졹猶젰� � 召�젵獸�硫 ▲狎�� 召�젵�	16�16. (� �, Y - ぎ�西Þ졻�)
		LDA	#$20 ; ' '
		STA	Spr_Attrib

End_Bonus_Draw:				; CODE XREF: Bonus_Draw+2j
					; Bonus_Draw+10j Bonus_Draw+22j
		RTS
; End of function Bonus_Draw


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 맖率β 歲ギ¡� ��ゥ, αエ �拾��

Invisible_Timer_Handle:			; CODE XREF: Battle_Loop+12p
		LDA	#1
		STA	Counter		; 렊�젩졻猶젰� 獸レぎ ª昔ぎ�

-:					; CODE XREF: Invisible_Timer_Handle+2Aj
		LDX	Counter
		LDA	Invisible_Timer,X ; 뫅ギ¡� ��ゥ ¡む膝	ª昔첓 ��笹� 昔┐��⑨
		BEQ	Next_Invisible_Timer_Handle ; 끷エ � �젺첓 �β ��ワ, ��	�□젩졻猶젰�
		LDA	Frame_Counter
		AND	#63
		BNE	+		; 뒥┐莘 醒ゃ�ㅳ 僧��麟젰� �젵Д�
		DEC	Invisible_Timer,X ; 뫅ギ¡� ��ゥ ¡む膝	ª昔첓 ��笹� 昔┐��⑨

+:					; CODE XREF: Invisible_Timer_Handle+Ej
		LDA	#2
		STA	TSA_Pal
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		LDA	Frame_Counter
		AND	#2
		ASL	A		; 뒥┐瑜 2 菴ⅸ쵟 Д�畑� 첓ㅰ ��ワ
					; (�誓�□젳濕� ��Д� 菴ⅸ쵟 � ��舒硫 Þㄵめ
					; 16�16	�젵쳽 歲ギ¡． ��ワ)
		CLC
		ADC	#$29 ; ')'      ; 뜝�젷彛硫 Þㄵめ �젵쳽 ｀졽Ø� 歲ギ¡． ��ワ
		STA	Spr_TileIndex
		JSR	Draw_WholeSpr	; C□졹猶젰� � 召�젵獸�硫 ▲狎�� 召�젵�	16�16. (� �, Y - ぎ�西Þ졻�)

Next_Invisible_Timer_Handle:		; CODE XREF: Invisible_Timer_Handle+8j
		DEC	Counter
		BPL	-
		RTS
; End of function Invisible_Timer_Handle


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 렊�젩졻猶젰� 飡졻信 �	□��� 外젩�

HQ_Handle:				; CODE XREF: Battle_Loop+Fp
		LDA	HQArmour_Timer	; 뮔ß�� □��� ¡む膝 外젩�
		BEQ	HQ_Explode_Handle
		LDA	Frame_Counter
		AND	#$F
		BNE	HQ_Explode_Handle ; 렊�젩졻猶젰� 4 �젳�	� 醒ゃ�ㅳ
		LDA	Frame_Counter
		AND	#63
		BNE	Skip_DecHQTimer	; 뒥┐莘 醒ゃ�ㅳ 僧��麟젰�
					; �젵Д� □��� 外젩�
		DEC	HQArmour_Timer	; 뮔ß�� □��� ¡む膝 外젩�
		BEQ	Normal_HQ_Handle ; 끷エ	�젵Д� ぎ�葉メ�, 黍率��	�昔飡��	外젩

Skip_DecHQTimer:			; CODE XREF: HQ_Handle+Ej
		LDA	HQArmour_Timer	; 뮔ß�� □��� ¡む膝 外젩�
		CMP	#4
		BCS	HQ_Explode_Handle ; 뇿 4 醒ゃ�ㅻ ㄾ ⓤ收曄�⑨ �젵Д�� □��� 外젩�,
					; □���	췅葉췅β Ж짛筍
		LDA	Frame_Counter
		AND	#$10		; 뙣짛��� � �졹獸獸� � 16 菴ⅸМ�
					; (4 �젳� � 醒ゃ�ㅳ)
		BEQ	Normal_HQ_Handle
		JSR	Draw_ArmourHQ	; 맖率β 外젩 �	□��ⅸ
		JMP	HQ_Explode_Handle
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Normal_HQ_Handle:			; CODE XREF: HQ_Handle+12j
					; HQ_Handle+1Ej
		JSR	DraW_Normal_HQ	; 맖率β 外젩 �	え晳①젹�

HQ_Explode_Handle:			; CODE XREF: HQ_Handle+2j HQ_Handle+8j
					; HQ_Handle+18j HQ_Handle+23j
		LDA	HQ_Status	; 80=外젩 璵�, αエ ��レ 獸 勝①獸┘�
		BEQ	End_HQ_Handle	; 끷エ 外젩� 拾� �β, �� �□젩졻猶젰� ⅲ� ˇ贍�
		BMI	End_HQ_Handle	; 끷エ 外젩 璵�, �� �□젩졻猶젰� ⅲ� ˇ贍�
		LDA	#3
		STA	TSA_Pal
		DEC	HQ_Status	; 80=外젩 璵�, αエ ��レ 獸 勝①獸┘�
		LDA	HQ_Status	; 80=外젩 璵�, αエ ��レ 獸 勝①獸┘�
		LSR	A
		LSR	A		; 4 菴ⅸ쵟 ㄵ逝ⓥ碎 첓┐硫 첓ㅰ	젺º졿Ŀ ˇ贍쥯
		SEC
		SBC	#5
		BPL	+
		EOR	#$FF
		CLC
		ADC	#1

+:					; CODE XREF: HQ_Handle+3Cj
		SEC
		SBC	#5
		BPL	++		; 벆젳졻�エ ㄲ愼줎⒱��瑜
		EOR	#$FF
		CLC
		ADC	#1		; 뒥ㅰ�	젺º졿Ŀ 瑟�エ葉쥯荻碎 ㄾ 5, � 쭬收� 說Ĳ좐恂�

++:					; CODE XREF: HQ_Handle+46j
		ASL	A		; 벆젳졻�エ ㄲ愼줎⒱��瑜
		TAY
		LDA	HQExplode_JumpTable,Y
		STA	LowPtr_Byte
		LDA	HQExplode_JumpTable+1,Y
		STA	HighPtr_Byte
		JMP	(LowPtr_Byte)
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

End_HQ_Handle:				; CODE XREF: HQ_Handle+2Bj
					; HQ_Handle+2Dj
		RTS
; End of function HQ_Handle

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;뮔∥ⓩ� �猶�ㄾ� 召�젵獸� ˇ贍쥯 外젩� (㏇ⅲ� �汀� 첓ㅰ�� 젺º졿Ŀ)
HQExplode_JumpTable:.WORD End_Ice_Move	; DATA XREF: HQ_Handle+4Fr
					; HQ_Handle+54r
					; ¡㎖�좈젰п� �� RTS
		.WORD FirstExplode_Pic	; 룯舒硫 첓ㅰ 16�16 ˇ贍쥯
		.WORD SecondExplode_Pic	; 귘�昔� 첓ㅰ 16�16 ˇ贍쥯
		.WORD ThirdExplode_Pic	; 믞βŁ 첓ㅰ 16�16 ˇ贍쥯
		.WORD FourthExplode_Pic	; 궒贍�	32�32 ��Д�麟�
		.WORD FifthExplode_Pic	; 몺щ�	‘レ溫�	32�32 ˇ贍�
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

FirstExplode_Pic:			; DATA XREF: ROM:E308o
		LDA	#$F1 ; '�'      ; 룯舒硫 첓ㅰ 16�16 ˇ贍쥯
		JMP	Draw_HQSmallExplode
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SecondExplode_Pic:			; DATA XREF: ROM:E30Ao
		LDA	#$F5 ; '�'      ; 귘�昔� 첓ㅰ 16�16 ˇ贍쥯
		JMP	Draw_HQSmallExplode
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

ThirdExplode_Pic:			; DATA XREF: ROM:E30Co
		LDA	#$F9 ; '�'      ; 믞βŁ 첓ㅰ 16�16 ˇ贍쥯

Draw_HQSmallExplode:			; CODE XREF: ROM:E314j	ROM:E319j
		LDX	#$78 ; 'x'
		LDY	#$D8 ; '�'      ; 뒶�西Þ졻� Д飡� ˇ贍쥯 外젩�
; START	OF FUNCTION CHUNK FOR Add_ExplodeSprBase

Draw_SmallExplode:			; CODE XREF: Add_ExplodeSprBase+3j
		STA	Spr_TileIndex
		JSR	Draw_WholeSpr	; C□졹猶젰� � 召�젵獸�硫 ▲狎�� 召�젵�	16�16. (� �, Y - ぎ�西Þ졻�)
		RTS
; END OF FUNCTION CHUNK	FOR Add_ExplodeSprBase

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Add_ExplodeSprBase:			; CODE XREF: Draw_BigExplode+6p
					; Draw_BigExplode+Fp
					; Draw_BigExplode+18p
					; Draw_BigExplode+21p

; FUNCTION CHUNK AT E322 SIZE 00000006 BYTES

		CLC
		ADC	HQExplode_SprBase
		JMP	Draw_SmallExplode
; End of function Add_ExplodeSprBase

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

FourthExplode_Pic:			; DATA XREF: ROM:E30Eo
		LDA	#0		; 궒贍�	32�32 ��Д�麟�
		STA	HQExplode_SprBase
		JSR	Draw_BigExplode	; 맖率β 32�32 召�젵� ˇ贍쥯
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

FifthExplode_Pic:			; DATA XREF: ROM:E310o
		LDA	#$10		; 몺щ�	‘レ溫�	32�32 ˇ贍�
		STA	HQExplode_SprBase
		JSR	Draw_BigExplode	; 맖率β 32�32 召�젵� ˇ贍쥯
		RTS

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 맖率β 32�32 召�젵� ˇ贍쥯

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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Make_Respawn:				; CODE XREF: SetUp_LevelVARs+16p
					; SetUp_LevelVARs+1Fp
					; Respawn_Handle+19p ROM:DE11p
		LDA	#0
;닱췅�젷彛� �젺� ª昔첓	�〓嶺硫
		STA	Tank_Type,X	; x = 0..1 - �졹細졻黍쥯β碎 殊� ª昔첓
					;    x = 2..5 -	�졹細졻黍쥯荻碎	№젲αえ� 殊��
		CPX	#2
		BCS	Enemy_Operations ; 끷エ	>= 2, 獸 將� №젫
		LDA	X_Player_Respawn,X
		STA	Tank_X,X
		LDA	Y_Player_Respawn,X
		STA	Tank_Y,X
		LDA	#0		; 닧昔�	�� ㄾウ�� Ж짛筍
					; ¡ №�э 誓召졼췅
		STA	Player_Blink_Timer,X ; 뮔ß�� Ж짛�⑨ friendly fire
		JMP	++		; 뮔�� ▲ㄵ� 쭬昔┐졻藺�
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Enemy_Operations:			; CODE XREF: Make_Respawn+6j
		INC	EnemyRespawn_PlaceIndex
		LDY	EnemyRespawn_PlaceIndex
		CPY	#3		; 3 ¡㎚�┃音 Д飡� 誓召졼췅
		BNE	+
		LDA	#0
		STA	EnemyRespawn_PlaceIndex
		TAY

+:					; CODE XREF: Make_Respawn+1Fj
		LDA	X_Enemy_Respawn,Y
		STA	Tank_X,X
		LDA	Y_Enemy_Respawn,Y
		STA	Tank_Y,X
		LDA	Enemy_Reinforce_Count ;	뒶エ曄飡¡ №젫�� � 쭬캙醒
		CMP	#3		; 겗�信�硫 �젺�	��琠ⓥ碎, ぎ＄�	� 쭬캙醒
					; �飡젺β碎: 17, 10 Œ�	3 №젲αえ� �젺첓.
		BEQ	Make_BonusEnemy
		CMP	#10
		BEQ	Make_BonusEnemy
		CMP	#17
		BNE	++		; 뮔�� ▲ㄵ� 쭬昔┐졻藺�

Make_BonusEnemy:			; CODE XREF: Make_Respawn+34j
					; Make_Respawn+38j
		LDA	#4
		STA	Tank_Type,X	; 꽖쳽�� №젫� ‘�信�臾
					; (ORA $80 ▲ㄵ� ��獸�)

++:					; CODE XREF: Make_Respawn+16j
					; Make_Respawn+3Cj
		LDA	#$F0		; 뮔�� ▲ㄵ� 쭬昔┐졻藺�
		STA	Tank_Status,X
		LDY	Tank_Y,X
		LDA	Tank_X,X
		TAX
		LDA	#$F
		JSR	Draw_TSABlock	; 롡黍貰�猶젰� ��� �젺ぎ� ▲ㄵ�	�信獸� Д飡�. 뜝
					; 笹晨젵, αエ 侁�´�� 〓� 貰ℓ젺 ��-���
					; Construction � 췅 Д飡� 誓召졼췅 ª昔ぎ�
					; Œ� №젫�� α筍 첓え�-獸 ∥�え.
		RTS
; End of function Make_Respawn


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 뇿｀拾젰� �拾�硫 殊� ��¡． �젺첓

Load_New_Tank:				; CODE XREF: ROM:DE6Ep
		LDA	Respawn_Status,X
		STA	Tank_Status,X
		CPX	#2
		BCS	Load_NewEnemy	; 귖젫
		LDA	#3
		STA	Invisible_Timer,X ; 뫅ギ¡� ��ゥ ¡む膝	ª昔첓 ��笹� 昔┐��⑨
		LDA	Player_Type,X	; 궓� �젺첓 ª昔첓
		CMP	#$0
		BEQ	Start_With_One_Star
		JMP	++
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Start_With_One_Star:
		LDA #$20
		STA	Player_Type,X
		STA	Tank_Type,X
		JMP	++
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Load_NewEnemy:				; CODE XREF: Load_New_Tank+7j
					; Load_New_Tank+1Cj
		LDY	Enemy_TypeNumber ; 귖젫
		LDA	Enemy_Count,Y
		BNE	+
		INC	Enemy_TypeNumber
		JMP	Load_NewEnemy	; 끷エ 收ゃ蟯� 殊� (�ㄸ� �� 4 췅 侁�´��) ぎ�葉メ�,
					; 췅葉췅�� 誓召졼�ⓥ� 笹ⅳ莘蟯�	殊�.
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: Load_New_Tank+18j
		SEC
		SBC	#1
		STA	Enemy_Count,Y
		LDA	Level_Mode
		BEQ	+++		; 끷エ 侁�˛� ��獄� �� 2-с む膝�, 췅‘� №젫��
					; ㏇ⅲ쩆 �� 35 侁�˛�
		LDA	#35
		JMP	++++
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+++:					; CODE XREF: Load_New_Tank+27j
		LDA	Level_Number

++++:					; CODE XREF: Load_New_Tank+2Bj
		SEC
		SBC	#1
		ASL	A
		ASL	A		; 뜝 侁�˛� 4 殊캙 №젫��
		CLC
		ADC	Enemy_TypeNumber
		TAY			; 귣葉笹畑� 췅‘� №젫�� � 쭬˘歲М飡� �� ��Д�� 侁�˛�
		LDA	EnemyType_ROMArray,Y
		CMP	#$E0
		BNE	++		; 끷エ №젫 ��笹ⅳ�ⅲ� 殊캙,
					; � �ⅲ� �젹좑 М邀좑 □���
		ORA	#3

++:					; CODE XREF: Load_New_Tank+10j
					; Load_New_Tank+3Ej
		ORA	Tank_Type,X
		CMP	#$E7
		BNE	End_Load_New_Tank
		LDA	#$E4

End_Load_New_Tank:			; CODE XREF: Load_New_Tank+46j
		STA	Tank_Type,X

		LDA	Boss_Mode	;!끷エ ‘遜, 獸 쭬｀拾젰� �젺� � 쭬˘歲М飡� �� ��Д�� 侁�˛�.
		BEQ	Skip_Load_Boss_Tank

		TXA ; �昔´涉��, 譽�〓 殊� ª昔첓 �� Д�纏碎
		CMP 	#2
		BCC	Skip_Load_Boss_Tank
		
		JSR	Get_Random_A
		AND	#7
		ASL
		ASL
		ASL
		ASL
		ASL   ;飡젪º 殊�
		ORA #3;묅젪º □���
		STA	Tank_Type,X		

Skip_Load_Boss_Tank:
		LDA	#0
		STA	Track_Pos,X
		RTS
; End of function Load_New_Tank


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 뱼�ㄸ� � 咨�젺� ㏇� �乘�

Hide_All_Bullets:			; CODE XREF: SetUp_LevelVARsp
		LDX	#9
		LDA	#0

-:					; CODE XREF: Hide_All_Bullets+7j
		STA	Bullet_Status,X
		DEX
		BPL	-
		RTS
; End of function Hide_All_Bullets


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Load_Enemy_Count:			; CODE XREF: SetUp_LevelVARs+52p
		LDA	Level_Mode
		BEQ	+
		LDA	#35		; � ‘�信-侁�˛� ㏇ⅲ쩆	˛呻誓���飡� 35-．
		JMP	++
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: Load_Enemy_Count+2j
		LDA	Level_Number

++:					; CODE XREF: Load_Enemy_Count+6j
		SEC
		SBC	#1
		ASL	A
		ASL	A		; 벉��쬊�� 췅 4	(ぎエ曄飡¡ 殊��� №젫�� � 侁�˛�)
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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; $FF =	き��え 承�젪ゥ�⑨ �� 췅쬊瞬

Button_To_DirectionIndex:		; CODE XREF: Move_Tank+21p
					; Move_Tank+2Fp Ice_Move+2Ap
		ASL	A
;룯誓¡ㄸ� � � 葉笹� � 貰�手β飡˘� � 3	飡졷鼇Ж 〃�젹�	(3,1,2,0,FF)
;ⓤ��レ㎯β碎 ㄻ� ��ャ曄�⑨ Þㄵめ� 췅��젪ゥ�⑨	��誓Д耀�⑨ �젺첓
;� 쭬˘歲М飡� �� 췅쬊瞬� き���� 承�젪ゥ�⑨ 췅 ㄶ�⒰殊ぅ
;끷エ か젪②� 承�젪ゥ�⑨ �� 췅쬊瞬, ¡㎖�좈젰� $FF
		BCC	+
		LDA	#3		; 궚�젪�
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: Button_To_DirectionIndex+1j
		ASL	A
		BCC	++
		LDA	#1		; 궖ⅱ�
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

++:					; CODE XREF: Button_To_DirectionIndex+7j
		ASL	A
		BCC	+++
		LDA	#2		; 궘��
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+++:					; CODE XREF: Button_To_DirectionIndex+Dj
		ASL	A
		BCC	++++		; 뒲젪②� 췅��젪ゥ�⑨ �� 췅쬊瞬
		LDA	#0		; 궋�齧
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

++++:					; CODE XREF: Button_To_DirectionIndex+13j
		LDA	#$FF		; 뒲젪②� 췅��젪ゥ�⑨ �� 췅쬊瞬
		RTS
; End of function Button_To_DirectionIndex

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;뇿｀拾젰恂� $DCAC,$E063,$E0A2 (�젶�� ┘ 쵟遜Ð	�� 젮誓率 $D3D5)
Bullet_Coord_X_Increment_1:.BYTE 0, $FF, 0, 1 ;	DATA XREF: ROM:DCACr ROM:DCB4r
					; Change_BulletCoordr Make_Shot+16r
;뇿｀拾젰恂� $DC9C,$E06C,$E0AD
Bullet_Coord_Y_Increment_1:.BYTE $FF, 0, 1, 0 ;	DATA XREF: ROM:DC9Cr ROM:DCA4r
					; Change_BulletCoord+9r Make_Shot+21r
X_Enemy_Respawn:.BYTE $18, $78,	$D8	; DATA XREF: Make_Respawn:+r
;X ぎ�西Þ졻� 貰�手β飡´��� ゥ¡．, 蓀ⅳ�ⅲ� �	��젪�．	誓召졼췅 №젫�
Y_Enemy_Respawn:.BYTE $18, $18,	$18	; DATA XREF: Make_Respawn+2Br
;Y ぎ�西Þ졻� 貰�手β飡´��� ゥ¡．, 蓀ⅳ�ⅲ� �	��젪�．	誓召졼췅 №젫�
X_Player_Respawn:.BYTE $58, $98		; DATA XREF: Make_Respawn+8r
;X ぎ�西Þ졻�  誓召졼췅	貰�手β飡´��� ��舒�． � ™�昔． ª昔첓
Y_Player_Respawn:.BYTE $D8, $D8		; DATA XREF: Make_Respawn+Dr
;Y ぎ�西Þ졻� 誓召졼췅 貰�手β飡´��� ��舒�． �	™�昔．	ª昔첓

Respawn_Status:	.BYTE $A0, $A0,	$A2, $A2, $A2, $A2, $A2, $A2 ; DATA XREF: Load_New_Tankr
;묅졻信� ª昔ぎ� � №젫�� �黍 誓召졼�� (ª昔え 췅葉췅荻	ㅳギ� ⇔�齧, №젫� - ˛��)

AI_Status:	.BYTE $A0,$A0,$A0,$A1,$A0,$A3,$A2,$A2,$A2
					; DATA XREF: Load_AI_Status:End_Load_AIStatusr
		.BYTE $A1,$A0,$A3,$A1,$A0,$A3,$A1,$A2,$A3

TankStatus_JumpTable:.WORD End_Ice_Move	; DATA XREF: Status_Core+8r
					; Status_Core+Dr
					; ¡㎖�좈젰п� �� RTS
		.WORD Explode_Handle	; 렊�젩졻猶젰� ˇ贍� �젺첓 (僧��麟젰� 葉笹� ┬㎛ⅸ, GameOver...)
		.WORD Explode_Handle	; 렊�젩졻猶젰� ˇ贍� �젺첓 (僧��麟젰� 葉笹� ┬㎛ⅸ, GameOver...)
		.WORD Explode_Handle	; 렊�젩졻猶젰� ˇ贍� �젺첓 (僧��麟젰� 葉笹� ┬㎛ⅸ, GameOver...)
		.WORD Explode_Handle	; 렊�젩졻猶젰� ˇ贍� �젺첓 (僧��麟젰� 葉笹� ┬㎛ⅸ, GameOver...)
		.WORD Explode_Handle	; 렊�젩졻猶젰� ˇ贍� �젺첓 (僧��麟젰� 葉笹� ┬㎛ⅸ, GameOver...)
		.WORD Explode_Handle	; 렊�젩졻猶젰� ˇ贍� �젺첓 (僧��麟젰� 葉笹� ┬㎛ⅸ, GameOver...)
		.WORD Explode_Handle	; 렊�젩졻猶젰� ˇ贍� �젺첓 (僧��麟젰� 葉笹� ┬㎛ⅸ, GameOver...)
		.WORD Misc_Status_Handle ; 렊�젩졻猶젰�	飡졻信�	レ쩆, ��㎤與� 循ⅹ� � �.�.
		.WORD Get_RandomStatus	; � �說�˛��, ��ャ�젰� 笹晨젵�硫 飡졻信
		.WORD Check_TileReach	; 뤲�´涉β � №젫�, ㄾ飡ª エ �� ぎ���	�젵쳽
		.WORD Aim_HQ		; 볚�젺젪エ쥯β	� 첓曄飡´ 璵ゥ¡� ぎ�西Þ졻� 外젩
		.WORD Aim_ScndPlayer	; 볚�젺젪エ쥯β	� 첓曄飡´ 璵エ	№젫� ��舒�． ª昔첓
		.WORD Aim_FirstPlayer	; 볚�젺젪エ쥯β	� 첓曄飡´ 璵エ	№젫� ™�昔． ª昔첓
		.WORD Load_Tank		; 뇿｀拾젰� �拾�硫 殊� ��¡． �젺첓, αエ �拾��
		.WORD Set_Respawn	; 볚�젺젪エ쥯β	� 飡졻信� 맓召졼�

TankDraw_JumpTable:.WORD End_Ice_Move	; DATA XREF: SingleTankStatus_Handle+8r
					; SingleTankStatus_Handle+Dr
					; ¡㎖�좈젰п� �� RTS
		.WORD Draw_Kill_Points	; 맖率β �囹� 췅 Д飡� ˇ贍쥯 №젫�
		.WORD Draw_Small_Explode1 ; 궒贍� 16�16
		.WORD Draw_Big_Explode	; 몼�졹猶젰� � Spr_Buffer ‘レ溫� ˇ贍�
		.WORD Draw_Big_Explode	; 몼�졹猶젰� � Spr_Buffer ‘レ溫� ˇ贍�
		.WORD Draw_Small_Explode2 ; 몼�졹猶젰� � Spr_Buffer 16�16 召�젵� ˇ贍쥯
		.WORD Draw_Small_Explode2 ; 몼�졹猶젰� � Spr_Buffer 16�16 召�젵� ˇ贍쥯
		.WORD Draw_Small_Explode2 ; 몼�졹猶젰� � Spr_Buffer 16�16 召�젵� ˇ贍쥯
		.WORD OperatingTank	; 뜢��蓀ⅳ飡´��� 信�젺젪エ쥯β	� Spr_Tile_Index �拾�硫	�젺�
		.WORD OperatingTank	; 뜢��蓀ⅳ飡´��� 信�젺젪エ쥯β	� Spr_Tile_Index �拾�硫	�젺�
		.WORD OperatingTank	; 뜢��蓀ⅳ飡´��� 信�젺젪エ쥯β	� Spr_Tile_Index �拾�硫	�젺�
		.WORD OperatingTank	; 뜢��蓀ⅳ飡´��� 信�젺젪エ쥯β	� Spr_Tile_Index �拾�硫	�젺�
		.WORD OperatingTank	; 뜢��蓀ⅳ飡´��� 信�젺젪エ쥯β	� Spr_Tile_Index �拾�硫	�젺�
		.WORD OperatingTank	; 뜢��蓀ⅳ飡´��� 信�젺젪エ쥯β	� Spr_Tile_Index �拾�硫	�젺�
		.WORD Respawn
		.WORD Respawn
Bullet_Status_JumpTable:.WORD End_Ice_Move ; DATA XREF:	BulletStatus_Handle+8r
					; BulletStatus_Handle+Dr
					; ¡㎖�좈젰п� �� RTS
		.WORD Make_Ricochet	; 뙠�畑� 飡졻信	�乘� ��� 젺º졿⑧ 黍ぎ蜈��
		.WORD Make_Ricochet	; 뙠�畑� 飡졻信	�乘� ��� 젺º졿⑧ 黍ぎ蜈��
		.WORD Make_Ricochet	; 곥ㄵ�	循� 첓ㅰ� 黍ぎ蜈��
		.WORD Bullet_Move	; 꽓ª젰� �乘� � 貰�手β飡˘� �	Bullet_Status
BulletGFX_JumpTable:.WORD End_Ice_Move	; DATA XREF: Draw_BulletGFX+8r
					; Draw_BulletGFX+Dr
					; ¡㎖�좈젰п� �� RTS
		.WORD Update_Ricochet	; 맖率β 黍ぎ蜈� � �拾��� Д飡�
		.WORD Update_Ricochet	; 맖率β 黍ぎ蜈� � �拾��� Д飡�
		.WORD Update_Ricochet	; 맖率β 黍ぎ蜈� � �拾��� Д飡�
		.WORD Draw_Bullet	; 몼�졹猶젰� � ▲狎�� 召�젵� �乘�
;뮜�� №젫�� (4	殊캙 췅	�ㄽ�� 侁�˛� � ㏇ⅲ� 8 殊���) �� 侁�˛詮
;뵰席졻	줎⒱�:
;겏瞬:
;0,1 - 侁�´�� □���
;2   - 氏젫 ‘�信��． �젺첓
;3,4 - �� ⓤ��レ㎯荻碎
;5,6,7 - 殊� �젺첓 (¡㎚�┃� 8 殊���)
;

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 렊�젩졻猶젰� ��ゥ� �乘� (飡�オ��´���	� �.�.)

Bullet_Fly_Handle:			; CODE XREF: Battle_Loop+1Ep
		LDA	#9
		STA	Counter		; 렊�젩졻猶젰� 10 �乘�

-:					; CODE XREF: Bullet_Fly_Handle+8Bj
		LDX	Counter
		LDA	Bullet_Status,X
		AND	#$F0 ; '�'
		CMP	#$40 ; '@'
		BNE	Next_Bullet_Fly_Handle ; 끷エ �乘� �� ゥ殊�, ��誓若ㄸ� � 笹ⅳ莘耀�
		LDA	Bullet_Property,X ; 뫇�昔飡� � □��ⅰ�þ�飡�
		BNE	+
		TXA
		EOR	Frame_Counter
		AND	#1		; 뙠ㄻ���瑜 �乘� �□젩졻猶젰� 曄誓� 菴ⅸ�
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
		JSR	GetSprCoord_InTiles ; 룯誓¡ㄸ�	Spr_coord � �젵ル
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
		JSR	BulletToObject_Impact_Handle ; 렊�젩졻猶젰� 飡�オ��´��� �乘� �	�↔ⅹ獸�

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
		JSR	GetSprCoord_InTiles ; 룯誓¡ㄸ�	Spr_coord � �젵ル
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
		JSR	BulletToObject_Impact_Handle ; 렊�젩졻猶젰� 飡�オ��´��� �乘� �	�↔ⅹ獸�

Next_Bullet_Fly_Handle:			; CODE XREF: Bullet_Fly_Handle+Cj
					; Bullet_Fly_Handle+17j
					; Bullet_Fly_Handle+6Cj
		DEC	Counter
		BMI	End_Bullet_Fly_Handle
		JMP	-
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

End_Bullet_Fly_Handle:			; CODE XREF: Bullet_Fly_Handle+89j
		RTS
; End of function Bullet_Fly_Handle


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 룯誓¡ㄸ� Spr_coord �	�젵ル

GetSprCoord_InTiles:			; CODE XREF: Bullet_Fly_Handle+43p
					; Bullet_Fly_Handle+69p
		STX	Spr_X
		STY	Spr_Y
		JSR	GetCoord_InTiles ; � � � Y 췅 �音�ㄵ ぎ�西Þ졻�	� �젵쳽�
; End of function GetSprCoord_InTiles


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 렊�젩졻猶젰� 飡�オ��´��� �乘� � �↔ⅹ獸�

BulletToObject_Impact_Handle:		; CODE XREF: Bullet_Fly_Handle+58p
					; Bullet_Fly_Handle+84p
		JSR	Temp_Coord_shl	; 뤲��□젳濕� Temp � 쭬˘歲М飡� �� Spr_Coord
		JSR	Check_Object	; 궙㎖�좈젰� ��レ, αエ	�乘ⅱ��	�젵�
		BEQ	BulletToObject_Return0 ; 끷エ ��誓� �乘ⅸ �信獸��, �音�ㄸ� � 0
		LDA	(LowPtr_Byte),Y
		AND	#$FC ; '�'
		CMP	#$C8 ; '�'      ; 묂젪�Ð젰� � Þㄵめ�� �젵쳽 外젩�
		BNE	+
		LDA	HQ_Status	; 80=外젩 璵�, αエ ��レ 獸 勝①獸┘�
		BEQ	+		; 끷エ 0, ˇ贍쥯�� 外젩
		LDA	#$27 ; '''      ; 궒贍쥯�� 外젩
		STA	HQ_Status	; 뜝�젷彛硫 첓ㅰ 젺º졿Ŀ ˇ贍쥯
					; (7 첓ㅰ�� �� 4 菴ⅸ쵟)
		LDA	#1
		STA	Sns_HQExplode
		STA	Snd_PlayerExplode
		JSR	Draw_Destroyed_HQ ; 맖率β �젳說蜈��硫 外젩
		LDX	Counter
		LDA	#$33 ; '3'      ; 꽖쳽�� 黍ぎ蜈� 췅 �乘�
		STA	Bullet_Status,X
		JMP	BulletToObject_Return0
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: BulletToObject_Impact_Handle+Ej
					; BulletToObject_Impact_Handle+12j
		LDA	(LowPtr_Byte),Y
		CMP	#$12		; 끷エ >$12 (¡쩆, ゥ�,	ヱ� � �.�.), �乘�
					; �昔若ㅿ� 췅稅¡㏃ (쭬´殲젰� �□젩�洙�)
		BCS	BulletToObject_Return0
		LDX	Counter
		LDA	#$33 ; '3'
		STA	Bullet_Status,X	; 3 첓ㅰ� 젺º졿Ŀ 黍ぎ蜈��,
					; ぎ獸贍� ㄵ逝졻碎 �� 3	菴ⅸ쵟
		LDA	(LowPtr_Byte),Y
		CMP	#$11		; 꺺젺ⓩ� 咨�젺�
		BEQ	Armored_Wall
		LDA	Bullet_Property,X ; 뫇�昔飡� � □��ⅰ�þ�飡�
		AND	#2
		BEQ	++		; 끷エ □��ⅰ�þ좑, �젳說�젰� �↔ⅹ�
		LDA	#0
		JSR	Draw_Tile	; 맖率�� ¸α獸	え晳①�
					; �信獸� �젵�
		LDA	#1
		STA	Snd_Brick_Ricochet
		JMP	BulletToObject_Return0
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

++:					; CODE XREF: BulletToObject_Impact_Handle+42j
		LDA	(LowPtr_Byte),Y
		CMP	#$10		; 뮔œ □���
		BEQ	Armored_Wall
		CPX	#2		; 묅�オ��´��� � え晳①��� 飡����
		BCS	BulletToObject_Return1 ; 눁晨ⓥ	獸レぎ ��캙쩆��� ª昔ぎ�
		LDA	#1
		STA	Snd_Brick_Ricochet

BulletToObject_Return1:			; CODE XREF: BulletToObject_Impact_Handle+59j
		JSR	Draw_Destroyed_Brick ; 맖率β ��젪Œ彛硫 �乙猶 � え晳①��� 飡���
		LDA	#1
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Armored_Wall:				; CODE XREF: BulletToObject_Impact_Handle+3Cj
					; BulletToObject_Impact_Handle+55j
		CPX	#2
		BCS	BulletToObject_Return0 ; 눁晨졻� 獸レぎ	黍ぎ蜈瞬 ª昔ぎ�
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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 렊�젩졻猶젰� 飡�オ��´��� �乘� � �젺ぎ�

BulletToTank_Impact_Handle:		; CODE XREF: Battle_Loop+24p
		LDA	#1
		STA	Counter		; 뫋좂젷� �□젩졻猶젰� 獸レぎ ª昔ぎ�
					; (№젫	��캙쩆β � ª昔첓)

-:					; CODE XREF: BulletToTank_Impact_Handle+70j
		LDX	Counter
		LDA	Tank_Status,X
		BPL	Jump_Next_Player_Tank_Impact ; 끷エ �젺� ˇ贍쥯β碎,
					; ��誓若ㄸ� � 笹ⅳ莘耀с
		CMP	#$E0 ; '�'
		BCC	+		; 끷エ �젺� �� 誓召졼�ⓥ碎,
					; ��誓若ㄸ� � 笹ⅳ莘耀с

Jump_Next_Player_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+8j
		JMP	Next_Player_Tank_Impact
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: BulletToTank_Impact_Handle+Cj
		LDA	#7
		STA	Counter2	; 8 ¡㎚�┃音 �乘� � №젫�

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
		ADC	#1		; 귣葉笹畑� �졹飡�輾�� Д┐� �젺ぎ� � �乘ⅸ �� �

CheckMinX_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+26j
		CMP	#$A
		BCS	Next_Bullet_Tank_Impact
		LDA	Bullet_Y,Y
		SEC
		SBC	Tank_Y,X
		BPL	CheckMinY_TankImpact
		EOR	#$FF
		CLC
		ADC	#1		; 귣葉笹畑� �졹飡�輾�� �� Y

CheckMinY_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+37j
		CMP	#$A
		BCS	Next_Bullet_Tank_Impact
		LDA	#$33 ; '3'
		STA	Bullet_Status,Y	; 볚�젺젪エ쥯��	飡졻信 � 黍ぎ蜈�
		LDA	Invisible_Timer,X ; 뫅ギ¡� ��ゥ ¡む膝	ª昔첓 ��笹� 昔┐��⑨
		BEQ	Explode_Player_Tank_Impact
		LDA	#0
		STA	Bullet_Status,Y	; 뱻ⓣ젰� �乘�
		JMP	Next_Bullet_Tank_Impact
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Explode_Player_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+49j
		LDA	#$73 ; 's'
		STA	Tank_Status,X
		LDA	#1
		STA	Snd_PlayerExplode
		LDA	#0
		STA	Player_Type,X	; 궓� �젺첓 ª昔첓
		STA	Tank_Type,X
		JMP	Next_Player_Tank_Impact
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Next_Bullet_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+1Ej
					; BulletToTank_Impact_Handle+2Fj
					; BulletToTank_Impact_Handle+40j
					; BulletToTank_Impact_Handle+50j
		DEC	Counter2
		LDA	Counter2
		CMP	#1		; 룯誓若ㄸ� � 笹ⅳ莘耀�	�乘�
		BNE	--

Next_Player_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle:Jump_Next_Player_Tank_Impactj
					; BulletToTank_Impact_Handle+63j
		DEC	Counter
		BPL	-
		LDA	#7
		STA	Counter		; 룼笹�	�□젩�洙� ��캙쩆�⑨ � ª昔첓,
					; 췅葉췅�� �□젩졻猶졻�	№젫��
					; (ª昔� ��캙쩆β ¡ №젫�)

---:					; CODE XREF: BulletToTank_Impact_Handle+130j
		LDX	Counter
		LDA	Tank_Status,X
		BPL	JumpNext_Enemy_Tank_Impact
		CMP	#$E0 ; '�'      ; 끷エ �젺� ˇ�舒젺 Œ� 誓召졼�ⓥ碎, ��誓若ㄸ� � 笹ⅳ莘耀с
		BCC	++

JumpNext_Enemy_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+7Aj
		JMP	Next_Enemy_Tank_Impact
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

++:					; CODE XREF: BulletToTank_Impact_Handle+7Ej
		LDA	#9
		STA	Counter2	; 10 �乘�

----:					; CODE XREF: BulletToTank_Impact_Handle+125j
		LDA	Counter2
		AND	#6
		BEQ	+++
		JMP	Next_Bullet2_Tank_Impact
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+++:					; CODE XREF: BulletToTank_Impact_Handle+8Bj
		LDY	Counter2
		LDA	Bullet_Status,Y
		AND	#$F0 ; '�'
		CMP	#$40 ; '@'
		BEQ	Load_X_TankImpact
		JMP	Next_Bullet2_Tank_Impact
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
		ADC	#1		; 귣葉笹畑� �졹飡�輾�� Д┐� �젺ぎ� �
					; �乘ⅸ	�� �‥º �碎�

CheckMinY2_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+B5j
		CMP	#$A
		BCS	Next_Bullet2_Tank_Impact
		LDA	#$33 ; '3'      ; 꽖쳽�� 黍ぎ蜈�
		STA	Bullet_Status,Y
		LDA	Tank_Type,X
		AND	#4
		BEQ	Skip_BonusHandle_TankImpact ; 끷エ �젺�	〓� ‘�信�臾, �猶�ㄸ� ‘�信
		JSR	Bonus_Appear_Handle ; 귣¡ㄸ� 笹晨젵�硫	‘�信 췅 咨�젺
		LDA	Tank_Type,X
		CMP	#$E4 ; '�'
		BNE	Skip_BonusHandle_TankImpact
		DEC	Tank_Type,X	; 끷エ �젺� □��ⓣ�쥯�,	�黍
					; ��캙쩆�Ŀ �乘� 僧��麟젰� □���

Skip_BonusHandle_TankImpact:		; CODE XREF: BulletToTank_Impact_Handle+C9j
					; BulletToTank_Impact_Handle+D2j
		LDA	Tank_Type,X
		AND	#3
		BEQ	Explode_Enemy_Tank_Impact
;! 뤲�´涉�� □��� ‘遜�:
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
		STA	Snd_ArmorRicochetTank ;	뮔�� □��ⓣ�쥯�
		JMP	Next_Bullet2_Tank_Impact
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Explode_Enemy_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+DAj
		LDA	#$73 ; 's'
		STA	Tank_Status,X	; 룼ㅰ猶젰� �젺�
		LDA	#1
		STA	Snd_EnemyExplode
		LDA	Tank_Type,X
		LSR	A
		LSR	A
		LSR	A
		LSR	A
		LSR	A
;! 췅 ‘遜��音 侁�˛渟 � 첓曄飡´ №젫� М┘� 〓筍 殊� �젺첓 ª昔첓, �昔´黍� 將� � αエ 譽�, �� �狩º젰� 曄手�夕�:
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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

ScndPlayerKll_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+100j
		INC	Enmy_KlledBy2P_Count,X

Score_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+104j
		LDA	Level_Mode
		CMP	#2
		BEQ	Next_Enemy_Tank_Impact ; 궙 №�э ㄵМ-侁�˛�, �囹� �� �黍줎˙禎恂�
		LDA	EnemyKill_Score,X ; 롧え*10 쭬 嵩Ł飡¡	첓┐�．	�� 4 ˘ㄾ� №젫��
		JSR	Num_To_NumString ; 룯誓¡ㄸ� 葉笹� �� �	� 飡昔ゃ NumString
		LDA	Spr_X
		TAX
		JSR	Add_Score	; 뤲Æ젪ワβ 葉笹� �� NumString	� �囹젹	ª昔첓 ��
		JSR	Add_Life	; 룼笹�	菴젫�, 췅葉笹畑� �囹�
		JMP	Next_Enemy_Tank_Impact
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Next_Bullet2_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+8Dj
					; BulletToTank_Impact_Handle+9Bj
					; BulletToTank_Impact_Handle+ADj
					; BulletToTank_Impact_Handle+BEj
					; BulletToTank_Impact_Handle+E3j
		DEC	Counter2
		BMI	Next_Enemy_Tank_Impact
		JMP	----
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Next_Enemy_Tank_Impact:			; CODE XREF: BulletToTank_Impact_Handle:JumpNext_Enemy_Tank_Impactj
					; BulletToTank_Impact_Handle+10Dj
					; BulletToTank_Impact_Handle+11Ej
					; BulletToTank_Impact_Handle+123j
		DEC	Counter
		LDA	Counter
		CMP	#1
		BEQ	++++
		JMP	---
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

++++:					; CODE XREF: BulletToTank_Impact_Handle+12Ej
		LDA	#1
		STA	Counter		; 뜝 將�� �젳 �졹細졻黍쥯�� ��캙쩆��� ª昔ぎ� �	ª昔첓

-----:					; CODE XREF: BulletToTank_Impact_Handle+1ABj
		LDX	Counter
		LDA	Tank_Status,X
		BPL	Jump_Next_Player2_Tank_Impact
		CMP	#$E0 ; '�'      ; 끷エ ª昔� 誓召졼�ⓥ碎, Œ� ˇ�舒젺, ��誓若ㄸ� � ㅰ膝�с
		BCC	+++++

Jump_Next_Player2_Tank_Impact:		; CODE XREF: BulletToTank_Impact_Handle+13Bj
		JMP	Next_Player2_Tank_Impact
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+++++:					; CODE XREF: BulletToTank_Impact_Handle+13Fj
		LDA	#9
		STA	Counter2	; 10 �乘�

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
		BPL	CheckMinY3_TankImpact ;	귣葉笹畑� �졹飡�輾⑨ ��	�‥º �碎� Д┐� �젺ぎ�	� �乘ⅸ
		EOR	#$FF
		CLC
		ADC	#1

CheckMinY3_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+178j
		CMP	#$A		; 귣葉笹畑� �졹飡�輾⑨ �� �‥º	�碎� Д┐� �젺ぎ� � �乘ⅸ
		BCS	Next_Bullet3_Tank_Impact
		LDA	#$33 ; '3'
		STA	Bullet_Status,Y	; 꽖쳽�� 黍ぎ蜈�
		LDA	Invisible_Timer,X ; 뫅ギ¡� ��ゥ ¡む膝	ª昔첓 ��笹� 昔┐��⑨
		BEQ	CheckBlink_TankImpact
		LDA	#0
		STA	Bullet_Status,Y	; 뱻ⓣ젰� �乘�
		JMP	Next_Bullet3_Tank_Impact
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

CheckBlink_TankImpact:			; CODE XREF: BulletToTank_Impact_Handle+18Aj
		LDA	Player_Blink_Timer,X ; 뮔ß�� Ж짛�⑨ friendly fire
		BNE	Next_Bullet3_Tank_Impact
		LDA	Level_Mode
		CMP	#2
		BEQ	Next_Bullet3_Tank_Impact ; 뜝 ㄵМ 侁�˛� Friendly Fire	�β
		LDA	#$C8 ; '�'
		STA	Player_Blink_Timer,X ; 렊��˙畑� �젵Д�
		JMP	Next_Player2_Tank_Impact
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
EnemyKill_Score:.BYTE $10, $20,	$30, $40 ; DATA	XREF: BulletToTank_Impact_Handle+10Fr
					; 롧え*10 쭬 嵩Ł飡¡ 첓┐�． �� 4 ˘ㄾ� №젫��

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 귣¡ㄸ� 笹晨젵�硫 ‘�信 췅 咨�젺

Bonus_Appear_Handle:			; CODE XREF: BulletToTank_Impact_Handle+CBp
		LDA	#1
		STA	Snd_BonusAppears ; 닧�젰� с㏓ゃ ��琠ゥ�⑨ ‘�信�

-:					; CODE XREF: Bonus_Appear_Handle+26j
		JSR	Get_Random_A	; 깗몭,	� � 笹晨젵��� 葉笹�
		AND	#3		; 3 ¡㎚�┃音 ぎ�西Þ졻� � ��琠ゥ�⑨
		JSR	Multiply_Bonus_Coord ; A := ((A	* 6) + 6) * 8
		STA	Bonus_X
		JSR	Get_Random_A	; 깗몭,	� � 笹晨젵��� 葉笹�
		AND	#3		; 3 ¡㎚�┃音 ぎ�西Þ졻� Y ��琠ゥ�⑨
		JSR	Multiply_Bonus_Coord ; A := ((A	* 6) + 6) * 8
		STA	Bonus_Y		; 겗�信	��琠ワβ碎 � 笹晨젵��� Д飡�
		LDA	#$FF
		STA	Bonus_Number	; 렞誓ㄵワβ 殊� ‘�信�
		LDA	#0
		STA	BonusPts_TimeCounter
		JSR	Bonus_Handle	; 렊�젩졻猶젰� ˇ汀�� ‘�信�, αエ �젶�¡� α筍
		LDA	BonusPts_TimeCounter
		BNE	-
		JSR	Get_Random_A	; 깗몭,	� � 笹晨젵��� 葉笹�
		AND	#7		; 8 ˘ㄾ� ‘�信��
		TAY
		LDA	BonusNumber_ROM_Array,Y	; 뜮Д�� ‘�信�� (Ħ呻 �� ��涉ㄺ�)
		STA	Bonus_Number	; 렞誓ㄵワβ 殊� ‘�信�
		LDA	#0
		STA	BonusPts_TimeCounter ; 겗�信 ��첓 �� ˇ汀
		LDX	Counter
		LDY	Counter2
		RTS
; End of function Bonus_Appear_Handle

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;!댂ㄵめ� 젽｀ⅸㄾ�. 6 � 7 �� ㄾ줎˙���.

BonusNumber_ROM_Array:.BYTE 0, 1, 2, 3,	4, 5, 4, 3 ; DATA XREF:	Bonus_Appear_Handle+2Er
					; 뜮Д�� ‘�信�� (Ħ呻 �� ��涉ㄺ�)

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 렊�젩졻猶젰� 飡�オ��´��� ㄲ愼 �乘�, αエ ���	α筍

BulletToBullet_Impact_Handle:		; CODE XREF: Battle_Loop+21p
		LDA	#9
		STA	Counter		; 10 �乘�

-:					; CODE XREF: BulletToBullet_Impact_Handle+5Fj
		LDA	Counter
		AND	#6
		BNE	Next_Bullet_Bulllet_Impact
		LDX	Counter
		LDA	Bullet_Status,X
		AND	#$F0 ; '�'
		CMP	#$40 ; '@'
		BNE	Next_Bullet_Bulllet_Impact ; 끷エ �乘� �� ゥ殊�,
					; �□젩졻猶젰� 笹ⅳ莘芋�
		LDA	#9
		STA	Counter2	; 10 �乘�

--:					; CODE XREF: BulletToBullet_Impact_Handle+5Bj
		LDA	Counter2
		TAY
		AND	#7
		STA	Temp
		LDA	Counter
		AND	#7
		CMP	Temp
		BEQ	Next_Bullet2_Bulllet_Impact ; 몺с � 貰‘� �乘�	췅 飡�オ��´���
					; �� �昔´涉��
		LDA	Bullet_Status,Y
		AND	#$F0 ; '�'
		CMP	#$40 ; '@'
		BNE	Next_Bullet2_Bulllet_Impact ; 끷エ �乘�	�� ゥ殊�,
					; ��誓若ㄸ� � 笹ⅳ莘耀�
		LDA	Bullet_X,Y
		SEC
		SBC	Bullet_X,X
		BPL	CheckMinX_BulletImpact ; 렞誓ㄵワ�� �졹飡�輾�� �� �
					; Д┐�	2-э �乘詮�
		EOR	#$FF
		CLC
		ADC	#1

CheckMinX_BulletImpact:			; CODE XREF: BulletToBullet_Impact_Handle+36j
		CMP	#6
		BCS	Next_Bullet2_Bulllet_Impact ; 끷エ >6, 룯誓若ㄸ� � 笹ⅳ莘耀�
		LDA	Bullet_Y,Y
		SEC
		SBC	Bullet_Y,X
		BPL	CheckMinY_BulletImpact ; 끷エ <	6 , 獸 �昔´涉�� �졹飡�輾�� �� Y
					; Д┐�	ㄲ僧� �乘詮�
		EOR	#$FF
		CLC
		ADC	#1

CheckMinY_BulletImpact:			; CODE XREF: BulletToBullet_Impact_Handle+47j
		CMP	#6
		BCS	Next_Bullet2_Bulllet_Impact ; 끷エ >6, 獸 ��誓若ㄸ� � 笹ⅳ莘耀�
		LDA	#0
		STA	Bullet_Status,X
		STA	Bullet_Status,Y	; 벊①獸쬊�� �‥ �乘�

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


; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

; 렊�젩졻猶젰� ˇ汀�� ‘�信�, αエ �젶�¡� α筍

Bonus_Handle:				; CODE XREF: Battle_Loop+27p
					; Bonus_Appear_Handle+21p
		LDA	Bonus_X
		BEQ	End_Bonus_Handle
		LDA	BonusPts_TimeCounter
		BNE	End_Bonus_Handle
		LDA	#7		;! 뜝葉췅�� � ��笹ⅳ�ⅲ� №젲αぎ． �젺첓 (ㄾ줎˙�췅 �□젩�洙� ˇ汀⑨ №젲αえЖ �젺첓Ж ‘�信�)
		STA	Tank_Num	; 뜮Д�	�젺첓 ª昔첓, �黍 �□젩�洙� ˇ汀⑨ ‘�信�

-:					; CODE XREF: Bonus_Handle+6Dj
		LDX	Tank_Num	; 뜮Д�	�젺첓 ª昔첓, �黍 �□젩�洙� ˇ汀⑨ ‘�信�
		LDA	Tank_Status,X
		BPL	+		; 룯誓若ㄸ� � 笹ⅳ莘耀с �젺ゃ
		CMP	#$E0 ; '�'
		BCS	+		; 끷エ �젺� ˇ�舒젺 Œ�	誓召졼�ⓥ碎,
					; �� �졹細졻黍쥯�� ⅲ�
		LDA	Tank_X,X
		SEC
		SBC	Bonus_X
		BPL	+++
		EOR	#$FF
		CLC
		ADC	#1		; 귣葉笹���� �졹飡�輾⑨	��
					; �젺첓	ㄾ ‘�信� �� �

+++:					; CODE XREF: Bonus_Handle+1Bj
		CMP	#$C
		BCS	+		; 룯誓若ㄸ� � 笹ⅳ莘耀с �젺ゃ
		LDA	Tank_Y,X
		SEC
		SBC	Bonus_Y
		BPL	++
		EOR	#$FF
		CLC
		ADC	#1		; 귣葉笹���� �졹飡�輾⑨	��
					; �젺첓	ㄾ ‘�信� �� Y

++:					; CODE XREF: Bonus_Handle+2Bj
		CMP	#$C
		BCS	+		; 룯誓若ㄸ� � 笹ⅳ莘耀с �젺ゃ
		LDA	#$32 ; '2'      ; №�э �獸□젲��⑨ �囹�� 쭬 ‘�信 (菴ⅸщ)
		STA	BonusPts_TimeCounter
		LDA	Bonus_Number	; 렞誓ㄵワβ 殊� ‘�信�
		BMI	End_Bonus_Handle
		LDA	Level_Mode
		CMP	#2		; � 誓┬Д ㄵМ	侁�˛� �囹� �� �黍줎˙禎恂�
		BEQ	Bonus_Command	; 뤲��㎖�ㄸ� ㄵ⒰手⑨ ‘�信�
		LDA	#$50 ; 'P'      ; 500 �囹�� 쩆β碎 쭬 ‘�信
		JSR	Num_To_NumString ; 룯誓¡ㄸ� 葉笹� �� �	� 飡昔ゃ NumString
		LDX	Tank_Num	; 뜮Д�	�젺첓 ª昔첓, �黍 �□젩�洙� ˇ汀⑨ ‘�信�
		JSR	Add_Score	; 뤲Æ젪ワβ 葉笹� �� NumString	� �囹젹	ª昔첓 ��
		JSR	Add_Life	; 뤲Æ젪ワβ �ㄽ� ┬㎛�, αエ ª昔� 쭬�젩��젷 200� �囹��
		LDX	Tank_Num	; 뜮Д�	�젺첓 ª昔첓, �黍 �□젩�洙� ˇ汀⑨ ‘�信�
		LDA	#1
		STA	Snd_BonusTaken	; 뤲�ª贍쥯�� Дギㄸ� 쭬 ˇ汀��	‘�信�

Bonus_Command:				; CODE XREF: Bonus_Handle+42j
		LDA	Bonus_Number	; 뤲��㎖�ㄸ� ㄵ⒰手⑨ ‘�信�
		ASL	A		; 벆젳졻�レ ㄲ愼줎⒱��硫
		TAY
		LDA	Bonus_JumpTable,Y
		STA	LowPtr_Byte
		LDA	Bonus_JumpTable+1,Y
		STA	HighPtr_Byte
		PLA
		PLA
		JMP	(LowPtr_Byte)
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

+:					; CODE XREF: Bonus_Handle+10j
					; Bonus_Handle+14j Bonus_Handle+24j
					; Bonus_Handle+34j
		DEC	Tank_Num	; 룯誓若ㄸ� � 笹ⅳ莘耀с �젺ゃ
		BPL	-

End_Bonus_Handle:			; CODE XREF: Bonus_Handle+2j
					; Bonus_Handle+6j Bonus_Handle+3Cj
		RTS
; End of function Bonus_Handle

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Bonus_JumpTable:.WORD Bonus_Helmet	; DATA XREF: Bonus_Handle+5Cr
					; Bonus_Handle+61r
					; 뫌ℓ젰� ��ゥ ¡む膝 �젺첓, � αエ ˇ纏 №젫, �吟�젪ワβ ��キ莘 □��� � Þ´設ⓣ濕� ‘�信��飡�.
		.WORD Bonus_Watch	; 롟�젺젪エ쥯β	㏇ε №젫��, � αエ ˇ纏 №젫, �飡젺젪エ쥯β ª昔ぎ�.
		.WORD Bonus_Shovel	; 묅昔ⓥ □��� ¡む膝 外젩� Œ� 嵩ⓣ젰� 쩆┘ え晳①�
		.WORD Bonus_Star	; 룯誓¡ㄸ� ª昔첓 Œ� ㏇ε №젫�� � 笹ⅳ莘蟯� ˘�
		.WORD Bonus_Grenade	; 궒贍쥯β ㏇ε	№젫�� Œ� ª昔ぎ�
		.WORD Bonus_Life	; 닾ⅴ�	˘� �젺첓. 뤲Æ젪ワβ �ㄽ� ┬㎛� Œ� �汀� №젲αえ� �젺ぎ� � 쭬캙�
		.WORD Bonus_Pistol	; 뜢 ⓤ��レ㎯β碎 � �①ⅲ� �� ㄵ쳽β, �ㄽ젶� ºⅴ� 聲��	Ø��ゃ ‘�信�
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Bonus_Helmet:				; DATA XREF: ROM:Bonus_JumpTableo
					; 뫌ℓ젰� ��ゥ ¡む膝 �젺첓, � αエ ˇ纏 №젫, �吟�젪ワβ ��キ莘 □��� � Þ´設ⓣ濕� ‘�信��飡�.
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
                CPX     #1; 췅 ™�昔． ª昔첓 �� 쭬ゥ쭬�� (1<x<8)
                BNE     -
                PLA
                TAX
                RTS

Players_Helmet:
		LDA	#10		
		STA	Invisible_Timer,X ; 뫅ギ¡� ��ゥ ¡む膝	ª昔첓 ��笹� 昔┐��⑨
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Bonus_Watch:				; DATA XREF: ROM:E9E4o
					; 롟�젺젪エ쥯β	㏇ε №젫��, � αエ ˇ纏 №젫, �飡젺젪エ쥯β ª昔ぎ�.
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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Bonus_Shovel:	; 묅昔ⓥ □��� ¡む膝 外젩� Œ� 嵩ⓣ젰� 쩆┘ え晳①�

		LDA	HQ_Status	
		BPL	End_Bonus_Shovel
                CPX     #2
		BCC     Players_Shovel

		JSR	Draw_ShovelHQ		
		RTS


Players_Shovel:			
		JSR	Draw_ArmourHQ	; 맖率β 外젩 �	□��ⅸ
		LDA	#20
		STA	HQArmour_Timer	; 뮔ß�� □��� ¡む膝 外젩�

End_Bonus_Shovel:			; CODE XREF: ROM:E9FDj
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Bonus_Star:		;룯誓¡ㄸ� ª昔첓 � 笹ⅳ莘蟯� ˘�, αエ ˇ纏 №젫, 젽｀ⅸㄸ� ㏇ε №젫�� 췅 咨�젺� � ㄾ줎˙畑� �ㄸ� 夜� □���.	


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
		BEQ	End_Bonus_Star	; 끷エ ㄾ飡ª�呻 쵟めº젷彛硫 ˘�, �音�ㄸ�
		CLC
		ADC	#$20 ; ' '      ; 꽖쳽�� �젺� 笹ⅳ莘蟯� ˘ㄾ�
		STA	Player_Type,X	; 궓� �젺첓 ª昔첓
		STA	Tank_Type,X

End_Bonus_Star:				; CODE XREF: ROM:EA0Cj
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Bonus_Grenade:
		LDA	#1
		STA	Snd_EnemyExplode
		CPX	#2
		BCC	Players_Grenade

		LDA	#1
		STA	Counter
		LDA	#$FF
		STA	Counter2	;�飡젺젪エ쥯�п� ぎ＄� ˇ�舒�� ㏇ε ª昔ぎ�
		JMP 	Bonus_Grenade_Loop
    




Players_Grenade:
		LDA	#7		; 궒贍쥯β ㏇ε	№젫��
		STA	Counter		; 뜝葉췅�� � ��笹ⅳ�ⅲ�	№젫�
		LDA	#1
		STA	Counter2	;�飡젺젪エ쥯�п� 췅 ª昔첓�

Bonus_Grenade_Loop:			; CODE XREF: ROM:EA3Bj
		LDY	Counter
		LDA	Tank_Status,Y
		BPL	Explode_Next
		CMP	#$E0 ; '�'
		BCS	Explode_Next	; 끷エ №젫 ˇ贍쥯β碎 Œ� 誓召졼�ⓥ碎,	�� ˇ贍쥯�� ⅲ�
		LDA	#$73 ; 's'      ; 궒贍쥯�� �젺�
		STA	Tank_Status,Y
		LDA	#0
		STA	Tank_Type,Y

Explode_Next:				; CODE XREF: ROM:EA25j	ROM:EA29j
		DEC	Counter
		LDA	Counter
		CMP	Counter2	; 닧昔ぎ� �� ˇ贍쥯��
		BNE	Bonus_Grenade_Loop
		RTS
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

Bonus_Life:		;ㄾ줎˙畑� ┬㎛� ª昔ゃ, αエ ˇ纏 №젫, 瑟�エ葉쥯β ぎエ曄飡¡ №젫�� � 쭬캙醒 췅 �汀�.

		CPX #2
		BCC Players_Life

		CLC	; !笹ⅳ莘蟯� ADC �□젳��猶젷 エ鈺Ł �젺� ‥� �葉飡え ��誓����, bugfix
		LDA	Enemy_Reinforce_Count
		ADC	#5		
		STA	Enemy_Reinforce_Count
		LDA	Enemy_Counter
		ADC	#5		
		STA	Enemy_Counter
		JSR	Draw_Reinforcemets
		
		
		RTS

Players_Life:				
		INC	Player1_Lives,X	; 닾ⅴ�	˘� �젺첓. 뤲Æ젪ワβ �ㄽ� ┬㎛�
		LDA	#1
		STA	Snd_Ancillary_Life1
		STA	Snd_Ancillary_Life2 ; 뤲�ª贍쥯�� ㎖丞 曄誓� �줎 첓췅쳽

Bonus_Pistol:				; DATA XREF: ROM:E9EEo
		RTS			; 뜢 ⓤ��レ㎯β碎 � �①ⅲ� �� ㄵ쳽β, �ㄽ젶� ºⅴ� 聲��	Ø��ゃ ‘�信�
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;꽑��瑜, 聲筌젺�瑜 � �循ⓤ�˚��	�乘�
;뇿｀拾젰恂� $E622 (�젶�� ┘ 쵟遜Ð �� 젮誓率 $D3D5)
Bullet_Coord_X_Increment_2:.BYTE 0, $FF, 0, 1 ;	DATA XREF: Bullet_Fly_Handle+1Er
;뇿｀拾젰恂� $E632
Bullet_Coord_Y_Increment_2:.BYTE $FF, 0, 1, 0 ;	DATA XREF: Bullet_Fly_Handle+2Er



; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�


Load_Level:				; CODE XREF: ROM:C1D9p
					; Load_DemoLevel+20p

;! 뤲�´涉�� �拾�� エ 笹晨젵�硫 侁�´�� �, αエ 쩆, 쭬｀拾젰� �信獸� (��Д� 101)
		ldx Random_Level_Flag
		Beq ++++
		Lda #101
		jmp Begin
++++
				
		CMP	#$FF
		BNE	Begin
		LDA	#100 ; '$'      ; 꽖М-侁�´��
		JMP	Begin
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�


Begin:					; CODE XREF: Load_Level+6j
					; Load_Level+Bj
		STA	Temp
		LDA	#>Level_Data
		STA	HighPtr_Byte
		LDA	#<Level_Data	; 묅졷鼇� � Й젮鼇� 줎⒱� 丞젳졻�ワ
					; 췅 췅�젷� ∥�첓 侁�˛ⅸ
		STA	LowPtr_Byte

-:					; CODE XREF: Load_Level+23j
		DEC	Temp
		BEQ	+
		LDA	#$5B ; '['      ; 5b-�젳Д� 쩆��音 �ㄽ�． 侁�˛�
		JSR	Inc_Ptr_on_A
		JMP	-
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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
		JSR	NMI_Wait	; 렑Ħ젰� ��쵟稅ⓣ濕М． �誓贍쥯�⑨
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
; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

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

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�

Draw_Random_Level:;! 궘�歲� �㎚����⑨ � �信獸� 侁�´�� (黍率β 쳽〃黍�� �� え晳①젹)
;닩ο �젶좑: 率耀飡㏂β ㄲ� 殊캙 쳽〃黍�獸�:
;1) 뜝栒�젷彛硫 쳽〃黍��, ぎ獸贍� 誓젷�㎜쥯� 쭬 淞β ��飡젺�˚� �信獸． ∥�첓 췅 笹晨젵��� Д飡�. 롧��� む졹Ð�, �� №젫� ��譽� �Ø�＄�
; �� 細�ｃ� ㄾ□졻藺� ㄾ 外젩� � ‘� �誓№좈젰恂� �昔飡� � �恂循�� №젫��
;2) 첓設� � ‘レ溫� "�젺驪ギ�젮ぎ�" ��醒誓ㄸ��, 誓젷�㎜쥯�췅� 쭬 淞β �循ⓤ�˚� �信瞬Ж ∥�첓Ж エ�Ł 十めⓣ�쥯���� 鼇黍�� ��
;笹晨젵�臾 췅��젪ゥ�⑨�
;꽑��硫 殊� �濡ⓣ젰恂� 笹晨젵��, � 쭬收� ��笹� ⅲ� 誓젷�쭬與�, �昔�㎖�ㄸ恂� ㄵぎ�졻Ð췅� ㄾ黍貰˚� 笹晨젵�臾� ∥�첓Ж �� ㏇ⅸ 첓設�.


Line_TSA_Count_Begin = 5; ぎエ曄飡¡ TSA � �ㄽ�� エ�Ŀ 쳽〃黍���
Space_Count = $FF; ぎエ曄飡¡ �信瞬� TSA � 쳽〃黍�收
Misc_Count = $12; ぎエ曄飡¡ ㄵぎ黍說迹ⓨ ∥�ぎ� � 쳽〃黍�收

	jsr NMI_Wait
	LDA	#00110000b ; �洙ヮ�젰� NMI �黍 VBlank'� - Þ좂�, 侁�´�� ▲ㄵ� �昔黍貰쥯� ��´齧 咨�젺� �濡��� 侁�˛�.
	STA	PPU_CTRL_REG1

	Lda #Space_Count
	Sta Counter; 쳽〃黍�� ▲ㄵ� 貰飡�汀� �� Counter ∥�ぎ�

	Lda #$80
	Sta Block_X
	Sta Block_Y
	
	jsr Get_Random_A
	And #$80
	Bne Draw_Lab; 렞誓ㄵワ�� 첓ぎ� 殊� 첓設� ▲ㄵ� 黍貰쥯筍
-
	JSR Draw_DanceFloor
	; ��笹� ㏇ε �昔´昔� � �揖ⓤゥ�Ł ぎ�西Þ졻, 黍率��.
	Lda #$F; �信獸� Д飡�
	LDX	Block_X
	LDY	Block_Y
	Jsr Draw_TSABlock
	Dec Counter
	Bne -
	JMP Decorate
Draw_Lab:
	JSR Draw_Labyrinth
	; ��笹� ㏇ε �昔´昔� � �揖ⓤゥ�Ł ぎ�西Þ졻, 黍率��.
	Lda #$F; �信獸� Д飡�
	LDX	Block_X
	LDY	Block_Y
	Jsr Draw_TSABlock
	Dec Counter
	Bne Draw_Lab
	
	

Decorate
;룼笹� �循ⓤ�˚� ��誓ㄵゥ���． 殊캙 쳽〃黍���, �↓ⅴ ㄻ� ㏇ε ㄵぎ黍昔쥯��� 侁�˛� �젳�臾� ∥�첓Ж:

	lda #Misc_Count
	sta Counter; ぎエ曄飡¡ ㄵぎ黍說迹ⓨ ∥�ぎ� � 쳽〃黍�收
---
	JSR Draw_Labyrinth
--
	jsr Get_Random_A 
	And #$F
	cmp #$D; 뫉晨젵�硫 ∥�� �∽쭬� 〓筍 #$9<x<=#$0C - 譽�〓 �� 葉�ⓥ� �誓�汀飡˘� � 拾� 貰ℓ젺�莘 첓設�
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

; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Check_Bounds:; �昔´涉β �� �泣ギ エ 쭬 ｀젺ⓩ� 咨�젺� (10<X<E0), αエ �β, ¡㎖�좈젰� ��レ.

ldx #0
-
LDA Block_X,x; Block_X � Block_Y Ħ呻 ㅰ膝 쭬 ㅰ膝��.
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


; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Draw_DanceFloor:; 맖率β �젺驪ギ�젮ゃ

	lda #Line_TSA_Count_Begin
	Sta Line_TSA_Count; エ�⑨ 쳽〃黍��� ▲ㄵ� 貰飡�汀� �� Line_TSA_Count_Begin �信瞬� ∥�ぎ�	

---
	Ldy #0; 췅葉췅�� � ぎ�西Þ졻� �, ��獸� ��誓ħ�� � 笹ⅳ莘耀� 瀞ⅸぅ (ぎ�西Þ졻� Y)

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
	lda Block_X,y ; 끷エ > $AA, 獸 瑟�エ葉쥯�� ぎ�西Þ졻�
	clc
	adc #$10
	Sta Block_X,y
	jmp ++

+
	cmp #$55
	bcc ++
	lda Block_X,y; 끷エ <$AA � >$55 , 獸 僧��麟젰� ぎ�西Þ졻�
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


; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Draw_Labyrinth:; 맖率β 쳽〃黍��

	Ldy #0; 췅葉췅�� � ぎ�西Þ졻� �, ��獸� ��誓ħ�� � 笹ⅳ莘耀� 瀞ⅸぅ (ぎ�西Þ졻� Y)

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

; 맖率β ‘レ嵬� え晳①�莘 췅ㄿⓤ� � 誓ぎ西��

; 栢栢栢栢栢栢栢� S U B	R O U T	I N E 栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢�
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
		LDA	#>aCongrats	; 귣¡ㄸ恂� � ˘ㄵ え晳①��� 췅ㄿⓤ�, αエ 誓ぎ西
		STA	HighStrPtr_Byte
		LDA	#<aCongrats	; 귣¡ㄸ恂� � ˘ㄵ え晳①��� 췅ㄿⓤ�, αエ 誓ぎ西
		STA	LowStrPtr_Byte
		JSR	Draw_BrickStr
		JSR	Store_NT_Buffer_InVRAM ; 몼�졹猶젰� 췅 咨�젺 貰ㄵ逝º��	NT_Buffer
		JSR	Set_PPU
		LDA	#0
		STA	Seconds_Counter
		LDA	#1
		STA	Snd_RecordPts1
		STA	Snd_RecordPts2
		STA	Snd_RecordPts3

-:					; CODE XREF: Draw_Record_HiScore+4Aj
		JSR	NMI_Wait	; 렑Ħ젰� ��쵟稅ⓣ濕М． �誓贍쥯�⑨
		LDA	Frame_Counter
		AND	#3
		CLC
		ADC	#5
		STA	BkgPal_Number	; 뙣짛��� 췅ㄿⓤ�
		LDA	Snd_RecordPts1
		BNE	-		; 넠住,	��첓 ��	쭬ぎ�葉� ª�졻�	Дギㄸ�	誓ぎ西�
		LDA	#0
		STA	BkgPal_Number
		RTS
; End of function Draw_Record_HiScore






