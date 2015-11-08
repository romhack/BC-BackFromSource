; Здесь содержится звуковой движок игры.


; --------------- S U B	R O U T	I N E ---------------------------------------

; Останавливаем	звук, включаем каналы и	т.п. (аналогично Load в	NSF формате)

Sound_Stop:				; CODE XREF: ROM:C15Cp	ROM:C253p
					; Draw_Brick_GameOver+65p
					; Reset_ScreenStuff+4Ep
		LDA	#00001111b
		STA	SND_MASTERCTRL_REG ; Включаем аудиоканалы 0,1,2,3
		LDA	#11000000b
		STA	JOYPAD_PORT2	; Включение Vertical Clock Signal (внешнего) и выключение внутреннего
		LDA	#$1C		;
					; Заполнение нулями области 300-31С (каждый байт)
					; и 31С-3FC (через 8 байт)
		STA	Low_Ptr_byte2
		LDA	#3		; Будем	читать из RAM звуков ($300)
		STA	High_Ptr_byte2
		LDX	#0
		LDY	#0

-:					; CODE XREF: Sound_Stop+2Aj
		TYA
		STA	(Low_Ptr_byte2),Y
		STA	Snd_Pause,X
		CLC
		LDA	Low_Ptr_byte2
		ADC	#8
		STA	Low_Ptr_byte2
		BCC	+
		INC	High_Ptr_byte2

+:					; CODE XREF: Sound_Stop+23j
		INX
		CPX	#$1C
		BNE	-
		RTS
; End of function Sound_Stop


; --------------- S U B	R O U T	I N E ---------------------------------------

; аналогично Play в NSF	формате

Play_Sound:				; CODE XREF: ROM:D439p
		LDA	Pause_Flag
		BNE	loc_EA88
		LDA	#$1C
		STA	byte_F5
		BPL	loc_EA8C

loc_EA88:				; CODE XREF: Play_Sound+2j
		LDA	#1
		STA	byte_F5

loc_EA8C:				; CODE XREF: Play_Sound+8j
		LDA	#0
		LDX	#3

loc_EA90:				; CODE XREF: Play_Sound+15j
		STA	$F9,X
		DEX
		BPL	loc_EA90
		LDA	#0
		STA	Sound_Number
		LDA	#$1C
		STA	Low_Ptr_byte2
		LDA	#3
		STA	High_Ptr_byte2

loc_EAA1:				; CODE XREF: Play_Sound+76j
		LDX	Sound_Number
		LDA	Snd_Pause,X
		BEQ	loc_EAE3
		LDY	#0
		LDA	(Low_Ptr_byte2),Y
		BEQ	loc_EAE3
		CMP	#5
		BCC	loc_EABD
		SEC
		SBC	#5
		TAX
		LDA	#1
		STA	$F9,X
		JMP	loc_EAE3
; ---------------------------------------------------------------------------

loc_EABD:				; CODE XREF: Play_Sound+32j
		TAX
		DEX
		LDA	$F9,X
		BNE	loc_EAE3
		LDA	#1
		STA	$F9,X
		TXA
		TAY
		CLC
		ADC	#5
		LDY	#0
		STA	(Low_Ptr_byte2),Y
		TXA
		ASL	A
		ASL	A
		TAX
		LDA	#4
		STA	byte_FD

loc_EAD8:				; CODE XREF: Play_Sound+63j
		INY
		LDA	(Low_Ptr_byte2),Y
		STA	SND_SQUARE1_REG,X ; pAPU Pulse #1 Control Register (W)
		INX
		DEC	byte_FD
		BNE	loc_EAD8

loc_EAE3:				; CODE XREF: Play_Sound+28j
					; Play_Sound+2Ej Play_Sound+3Cj
					; Play_Sound+43j
		CLC
		LDA	Low_Ptr_byte2
		ADC	#8
		STA	Low_Ptr_byte2
		BCC	loc_EAEE
		INC	High_Ptr_byte2

loc_EAEE:				; CODE XREF: Play_Sound+6Cj
		INC	Sound_Number
		LDA	Sound_Number
		CMP	byte_F5
		BCC	loc_EAA1
		LDX	#0

loc_EAF8:				; CODE XREF: Play_Sound+91j
		STX	byte_FD
		LDA	$F9,X
		BNE	loc_EB0A
		TXA
		ASL	A
		ASL	A
		TAX
		ASL	A
		AND	#$10
		EOR	#$10
		STA	SND_SQUARE1_REG,X ; pAPU Pulse #1 Control Register (W)

loc_EB0A:				; CODE XREF: Play_Sound+7Ej
		LDX	byte_FD
		INX
		CPX	#4
		BCC	loc_EAF8
		LDY	#0
		STY	Sound_Number
		LDA	#$1C
		STA	Low_Ptr_byte2
		LDA	#3
		STA	High_Ptr_byte2

loc_EB1D:				; CODE XREF: Play_Sound+C1j
		LDX	Sound_Number
		LDA	Snd_Pause,X
		BEQ	loc_EB2E
		CMP	#1
		BNE	loc_EB42
		INC	Snd_Pause,X
		JMP	loc_EB4F
; ---------------------------------------------------------------------------

loc_EB2E:				; CODE XREF: Play_Sound+A4j
					; Play_Sound+CFj Play_Sound+160j
					; Play_Sound+1A0j
		CLC
		LDA	Low_Ptr_byte2
		ADC	#8
		STA	Low_Ptr_byte2
		BCC	loc_EB39
		INC	High_Ptr_byte2

loc_EB39:				; CODE XREF: Play_Sound+B7j
		INC	Sound_Number
		LDA	Sound_Number
		CMP	byte_F5
		BCC	loc_EB1D
		RTS
; ---------------------------------------------------------------------------

loc_EB42:				; CODE XREF: Play_Sound+A8j
		LDY	#7
		LDA	(Low_Ptr_byte2),Y
		SEC
		SBC	#1
		STA	(Low_Ptr_byte2),Y
		BEQ	loc_EB85
		BNE	loc_EB2E

loc_EB4F:				; CODE XREF: Play_Sound+ADj
		LDA	#0
		LDY	#5
		STA	(Low_Ptr_byte2),Y
		JSR	Load_Snd_Ptr
		JSR	sub_ECBE
		LDY	#0
		STA	(Low_Ptr_byte2),Y
		JSR	sub_ECBE
		LDY	#1
		STA	(Low_Ptr_byte2),Y
		JSR	sub_ECBE
		LDY	#2
		STA	(Low_Ptr_byte2),Y
		JSR	sub_ECBE
		LDY	#4
		STA	(Low_Ptr_byte2),Y
		LDY	#0
		LDA	(Low_Ptr_byte2),Y
		CMP	#4
		BNE	loc_EB88
		JSR	sub_ECBE
		LDY	#3
		STA	(Low_Ptr_byte2),Y
		BPL	loc_EB88

loc_EB85:				; CODE XREF: Play_Sound+CDj
		JSR	Load_Snd_Ptr

loc_EB88:				; CODE XREF: Play_Sound+FCj
					; Play_Sound+105j Play_Sound+11Dj
					; ROM:EC30j ROM:EC42j	ROM:EC54j
					; ROM:EC5Ej ROM:EC68j	ROM:EC72j
					; ROM:EC7Ej ROM:ECA2j	ROM:ECACj
		JSR	sub_ECBE
		CMP	#$E8 ; 'ш'
		BCS	loc_EBE1
		CMP	#$60 ; '`'
		BEQ	loc_EBD7
		BCC	loc_EB9E
		SBC	#$60 ; '`'
		LDY	#6
		STA	(Low_Ptr_byte2),Y
		JMP	loc_EB88
; ---------------------------------------------------------------------------

loc_EB9E:				; CODE XREF: Play_Sound+115j
		PHA
		AND	#$F8 ; '°'
		LSR	A
		LSR	A
		TAX
		LDA	Snd_Beep,X	; Похоже на
					; звуковые данные(отвечают за отдельные	звуки?)
		STA	byte_FD
		LDA	Snd_Beep+1,X	; Похоже на
					; звуковые данные(отвечают за отдельные	звуки?)
		STA	byte_FE
		PLA
		AND	#7
		BEQ	loc_EBBB
		TAX

loc_EBB4:				; CODE XREF: Play_Sound+13Bj
		LSR	byte_FD
		ROR	byte_FE
		DEX
		BNE	loc_EBB4

loc_EBBB:				; CODE XREF: Play_Sound+133j
		LDY	#4
		LDA	(Low_Ptr_byte2),Y
		AND	#$F8 ; '°'
		ORA	byte_FD
		STA	(Low_Ptr_byte2),Y
		LDA	byte_FE
		DEY
		STA	(Low_Ptr_byte2),Y
		LDY	#0
		LDA	(Low_Ptr_byte2),Y
		CMP	#5
		BCC	loc_EBD7
		SEC
		SBC	#4
		STA	(Low_Ptr_byte2),Y

loc_EBD7:				; CODE XREF: Play_Sound+113j
					; Play_Sound+152j
		LDY	#6
		LDA	(Low_Ptr_byte2),Y
		INY
		STA	(Low_Ptr_byte2),Y
		JMP	loc_EB2E
; ---------------------------------------------------------------------------

loc_EBE1:				; CODE XREF: Play_Sound+10Fj
		SBC	#$E8 ; 'ш'
		JSR	sub_ECD0
; ---------------------------------------------------------------------------
;Указатели?
Sound_Com_JumpTable:.WORD Sound_Com1	; Указатели на косвенный прыжок	в подпрограммы ниже
					; (при взрыве врага $ECD9)
		.WORD Sound_Com2	; Не выполнилось
		.WORD Sound_Com3
		.WORD Sound_Com4	; Не выполнилось
		.WORD Sound_Com5
		.WORD Sound_Com6
		.WORD Sound_Com7
		.WORD Sound_Com8
		.WORD Sound_Com9
		.WORD Sound_Com10
		.WORD Sound_Com11
		.WORD Sound_Com12
		.WORD Sound_Com12
		.WORD Sound_Com12
		.WORD Sound_Com12
		.WORD Sound_Com12
		.WORD Sound_Com12
		.WORD Sound_Com13
; ---------------------------------------------------------------------------

Sound_Com1:				; DATA XREF: Play_Sound:Sound_Com_JumpTableo
		LDX	Sound_Number
		LDA	#0
		STA	Snd_Pause,X
		LDY	#0
		STA	(Low_Ptr_byte2),Y
		LDY	#5
		LDA	(Low_Ptr_byte2),Y
		SEC
		SBC	#1
		STA	(Low_Ptr_byte2),Y
		JMP	loc_EB2E
; End of function Play_Sound

; ---------------------------------------------------------------------------

Sound_Com2:				; DATA XREF: Play_Sound+16Ao
		JSR	sub_ECBE	; Не выполнилось
		STA	byte_FD
		LDY	#1
		LDA	(Low_Ptr_byte2),Y
		AND	#$3F ; '?'
		ORA	byte_FD
		STA	(Low_Ptr_byte2),Y
		JMP	loc_EB88
; ---------------------------------------------------------------------------

Sound_Com3:				; DATA XREF: Play_Sound+16Co
		JSR	sub_ECBE
		STA	byte_FD
		LDY	#1
		LDA	(Low_Ptr_byte2),Y
		AND	#$C0 ; 'L'
		ORA	byte_FD
		STA	(Low_Ptr_byte2),Y
		JMP	loc_EB88
; ---------------------------------------------------------------------------

Sound_Com4:				; DATA XREF: Play_Sound+16Eo
		JSR	sub_ECBE	; Не выполнилось
		STA	byte_FD
		LDY	#1
		LDA	(Low_Ptr_byte2),Y
		AND	#Low_Ptr_byte2
		ORA	byte_FD
		STA	(Low_Ptr_byte2),Y
		JMP	loc_EB88
; ---------------------------------------------------------------------------

Sound_Com5:				; DATA XREF: Play_Sound+170o
		JSR	sub_ECBE
		LDY	#2
		STA	(Low_Ptr_byte2),Y
		JMP	loc_EB88
; ---------------------------------------------------------------------------

Sound_Com6:				; DATA XREF: Play_Sound+172o
		JSR	sub_ECBE
		LDY	#4
		STA	(Low_Ptr_byte2),Y
		JMP	loc_EB88
; ---------------------------------------------------------------------------

Sound_Com7:				; DATA XREF: Play_Sound+174o
		JSR	sub_ECBE
		LDY	#1
		STA	(Low_Ptr_byte2),Y
		JMP	loc_EB88
; ---------------------------------------------------------------------------

Sound_Com8:				; DATA XREF: Play_Sound+176o
		LDA	#0
		LDX	#2

loc_EC79:				; CODE XREF: ROM:EC7Cj
		STA	$F6,X
		DEX
		BPL	loc_EC79
		JMP	loc_EB88
; ---------------------------------------------------------------------------

Sound_Com9:				; DATA XREF: Play_Sound+178o
		LDX	#0
		BEQ	loc_EC8A

Sound_Com10:				; DATA XREF: Play_Sound+17Ao
		LDX	#1
; ---------------------------------------------------------------------------
		.BYTE $2C ; ,
; ---------------------------------------------------------------------------

Sound_Com11:				; DATA XREF: Play_Sound+17Co
		LDX	#2

loc_EC8A:				; CODE XREF: ROM:EC83j
		JSR	sub_ECBE
		INC	$F6,X
		CMP	$F6,X
		BNE	Sound_Com13
		LDA	#0
		STA	$F6,X
		BEQ	Sound_Com12

Sound_Com12:				; DATA XREF: Play_Sound+17Eo
					; Play_Sound+180o Play_Sound+182o
					; Play_Sound+184o Play_Sound+186o
					; Play_Sound+188o
		LDY	#5
		LDA	(Low_Ptr_byte2),Y
		CLC
		ADC	#1
		STA	(Low_Ptr_byte2),Y
		JMP	loc_EB88
; ---------------------------------------------------------------------------

Sound_Com13:				; CODE XREF: ROM:EC91j
					; DATA XREF: Play_Sound+18Ao
		JSR	sub_ECBE
		LDY	#5
		STA	(Low_Ptr_byte2),Y
		JMP	loc_EB88

; --------------- S U B	R O U T	I N E ---------------------------------------


Load_Snd_Ptr:				; CODE XREF: Play_Sound+D7p
					; Play_Sound:loc_EB85p
		LDA	Sound_Number
		ASL	A		; Т.к. указатель двухбайтовый
		TAX
		LDA	Sound_PtrTbl,X
		STA	Low_SndPtr
		LDA	Sound_PtrTbl+1,X
		STA	High_SndPtr
		RTS
; End of function Load_Snd_Ptr


; --------------- S U B	R O U T	I N E ---------------------------------------


sub_ECBE:				; CODE XREF: Play_Sound+DAp
					; Play_Sound+E1p Play_Sound+E8p
					; Play_Sound+EFp Play_Sound+FEp
					; Play_Sound:loc_EB88p	ROM:Sound_Com2p
					; ROM:Sound_Com3p ROM:Sound_Com4p
					; ROM:Sound_Com5p ROM:Sound_Com6p
					; ROM:Sound_Com7p ROM:loc_EC8Ap
					; ROM:Sound_Com13p
		LDA	Sound_Number
		LDY	#5
		LDA	(Low_Ptr_byte2),Y
		TAY
		LDA	(Low_SndPtr),Y
		PHA
		INY
		TYA
		LDY	#5
		STA	(Low_Ptr_byte2),Y
		PLA
		RTS
; End of function sub_ECBE


; --------------- S U B	R O U T	I N E ---------------------------------------


sub_ECD0:				; CODE XREF: Play_Sound+165p
		ASL	A
		TAY
		INY
		PLA
		STA	byte_FD
		PLA
		STA	byte_FE
		LDA	($FD),Y
		TAX
		INY
		LDA	($FD),Y
		STA	byte_FE
		STX	byte_FD
		JMP	(byte_FD)
; End of function sub_ECD0

; ---------------------------------------------------------------------------
; Звук?
;Загружается $EBA4
Snd_Beep:	.BYTE 7, $F2, 7, $80, 7, $14, 6, $AE, 6, $43, 5, $F4, 5
					; DATA XREF: Play_Sound+126r
					; Play_Sound+12Br
		.BYTE $9E, 5, $4E, 5, 2, 4, $BA, 4, $76, 4, $36	; Похоже на
					; звуковые данные(отвечают за отдельные	звуки?)

;Указатели на звуковые данные (28 звуков)
Sound_PtrTbl:	.WORD Sound_Pause	; DATA XREF: Load_Snd_Ptr+4r
					; Load_Snd_Ptr+9r
		.WORD Sound_Battle1
		.WORD Sound_Battle2
		.WORD sound_Battle3
		.WORD sound_Ancillary_Life1
		.WORD sound_Ancillary_Life2
		.WORD sound_BonusTaken
		.WORD sound_PlayerExplode
		.WORD sound_Unknown1
		.WORD sound_BonusAppears
		.WORD sound_EnemyExplode
		.WORD sound_HQExplode
		.WORD sound_BrickRicochet
		.WORD sound_ArmorRicochetWall
		.WORD sound_ArmorRicochetTank
		.WORD sound_Shoot
		.WORD sound_Ice
		.WORD sound_Move
		.WORD sound_Engine
		.WORD sound_PtsCount1
		.WORD sound_PtsCount2
		.WORD sound_RecordPts1
		.WORD sound_RecordPts2
		.WORD sound_RecordPts3
		.WORD sound_GameOver1
		.WORD sound_GameOver2
		.WORD sound_GameOver3
		.WORD sound_BonusPts

;Звуковые данные:
;$E8 - конец звука
;Если звук зациклен (move, engine), байта конца	нет
Sound_Battle1:	.BYTE	1,$81,$7F,$40,$EF,$68,$1B,$2B,$33,$F0,	2,  6,$33,$43,$53,$F0
					; DATA XREF: ROM:ED00o
		.BYTE	2, $C,$43,$53,	4,$F0,	2,$12,$5B, $C,$1C,$F0,	2,$18,$78,$1C
		.BYTE $68,$1C,$1C,$1C,$78,$1C,$E8
Sound_Battle2:	.BYTE 3,$10,$7F,8,$78,$1A,$68,$1A,$F1,3,7,$78,$32,$68,$32,$F1
					; DATA XREF: ROM:ED02o
		.BYTE 3,$E,$78,$42,$68,$42,$F1,3,$15,$5A,$F1,3,$19,$B,$F1,3
		.BYTE $1D,$78,$52,$68,$52,$F1,3,$24,$78,$52,$E8
sound_Battle3:	.BYTE	2,$81,$7F,$40,$78,$51,$68,$51,$F2,  3,	7,$78, $A,$68, $A,$F2
					; DATA XREF: ROM:ED04o
		.BYTE	3, $E,$78,$1A,$68,$1A,$F2,  3,$15,$32,$F2,  3,$19,$42,$F2,  3
		.BYTE $1D,$78,$3A,$68,$3A,$F2,	3,$24,$78,$3A,$E8
sound_PlayerExplode:.BYTE   4,$1F,$7F,$30, $A,$62,$49,$49,$EA,$1E,$49,$49,$EA,$1D,$49,$49
					; DATA XREF: ROM:ED0Co
		.BYTE $EA,$1C,$49,$49,$EA,$1B,$49,$49,$EA,$1A,$49,$EA,$19,$49,$EA,$18
		.BYTE $49,$E8
sound_Unknown1:	.BYTE	2,$1F,$7F,$30,$62,  0,	1,  0,$EA,$1E,	1,  0,$EA,$1D,	1,  0
					; DATA XREF: ROM:ED0Eo
		.BYTE	1,  0,$EA,$1C,	1,$EA,$1B,  0,$EA,$1A,	1,$EA,$19,  0,$E8
sound_HQExplode:.BYTE	2,$20,$7F,$30,$63,$1A,$12,$51,$31,$19,$11,$50,$30,$18,$E8
					; DATA XREF: ROM:ED14o
sound_EnemyExplode:.BYTE   4,$1F,$7F,$40, $A,$62,$51,$EA,$1E,$51,$EA,  8,$6A,$51,$E8
					; DATA XREF: ROM:ED12o
sound_Shoot:	.BYTE	1,$8F,$82,$10,$6F,$2C,$E8 ; DATA XREF: ROM:ED1Co
sound_BonusTaken:.BYTE	 2,$80,$7F,$40,$63,$52,$1B,$3B,$53,$4A,$13,$33,$4B,$1B,$3B,$53
					; DATA XREF: ROM:ED0Ao
		.BYTE $1C,$3C,$E8
Sound_Pause:	.BYTE	2,$82,$7F,$40,$64,$1B,$2B,$3B,$1C,$2C,$3C,$6C,$53,$E8
					; DATA XREF: ROM:Sound_PtrTblo
sound_BonusPts:	.BYTE	2,$82,$7F,$40,$63,$53,$1B,$1C,$3B,$3C,$53,$6A,$54,$E8
					; DATA XREF: ROM:ED34o
sound_BonusAppears:.BYTE   2,$60,$7F,$40,$64,$52,$3A,$52,  3,$52,  3,$13,$1B,$E8
					; DATA XREF: ROM:ED10o
sound_ArmorRicochetWall:.BYTE	2,$D5,$7F,  0,$62,$1C,$1D,$E8 ;	DATA XREF: ROM:ED18o
sound_BrickRicochet:.BYTE   3,	7,$7F,	8,$61,$3A,$13,$22,$E8 ;	DATA XREF: ROM:ED16o
sound_ArmorRicochetTank:.BYTE	2,$40,$7F,  0,$61,$3D,$62,$45,$EA,$10,$28,$E8
					; DATA XREF: ROM:ED1Ao
sound_PtsCount1:.BYTE	2,$80,$7F,$18,$61,$39,$E8 ; DATA XREF: ROM:ED24o
sound_PtsCount2:.BYTE	4,  0,$7F,$28, $A,$61,$28,$E8 ;	DATA XREF: ROM:ED26o
sound_Engine:	.BYTE	2,$8C,$94,$40,$61,$10,$64,$18,$F9,  5 ;	DATA XREF: ROM:ED22o
sound_Move:	.BYTE	2,$80,$94,$48,$62,$40,$48,$F9,	5 ; DATA XREF: ROM:ED20o
sound_Ice:	.BYTE	1,$1F,$7F,$28,$61,$22,$42,$5A,$1B,$E8 ;	DATA XREF: ROM:ED1Eo
sound_Ancillary_Life1:.BYTE   1,$A0,$7F,$40,$66,$1C,$3C,$1C,$53,$1C,$3C,  5,$72,$54,$E8
					; DATA XREF: ROM:ED06o
sound_Ancillary_Life2:.BYTE   2,$90,$7F,$40,$62,$38,$66,$EA,$20,$3B,$53,$3B,$1B,$3B,$53,$1C
					; DATA XREF: ROM:ED08o
		.BYTE $6A,$14,$E8
sound_RecordPts1:.BYTE	 1,$B8,$7F,$40,$EF,$65,	$C,$53,$F0, $C,	 5, $C,$53,$F0,	$C, $B
					; DATA XREF: ROM:ED28o
		.BYTE $34,$24,$F0,  8,$10,$EA,$30,$B0,$50,$EA,$20,$9C,$54,$E8
sound_RecordPts2:.BYTE	 2,$B8,$7F,$40,$65,$43,$33,$F1,	$C,  4,$43,$33,$F1, $C,	$A,$14
					; DATA XREF: ROM:ED2Ao
		.BYTE $4B,$F1,	8, $F,$EA,$3A,$30,$50,	9,$29,$31,$51, $A,$2A,$32,$52
		.BYTE  $B,$2B,$33,$53, $C,$2C,$9C,$EA,$20,$2C,$E8
sound_RecordPts3:.BYTE	 3,  0,$7F,  8,$A1,  1,	 1,$EE,$15,$6A,	$B, $B,	$B,$EE,$22,$6F
					; DATA XREF: ROM:ED2Co
		.BYTE $33,$65,$43,$7E,$EE,$33,$53,$6A,$EE,$15,$43,$33,$53,$6F,$EE,$22
		.BYTE $13,$65,$23,$7E,$EE,$33,$33,$6A,$EE,$15,$23,$13,$4A,$9C,$EE,$FF
		.BYTE $32,$E8
sound_GameOver1:.BYTE	1,$42,$7F,$40,$66,$1B, $B,$78,$1B,$68,$52,$42,$32,$1A,$1A,$1A
					; DATA XREF: ROM:ED2Eo
		.BYTE $78,$1A,$E8
sound_GameOver2:.BYTE	2,$82,$7F,$40,$66,$52,$52,$78,$52,$68,$32,$2A,$12,$1A,$1A,$1A
					; DATA XREF: ROM:ED30o
		.BYTE $78,$1A,$E8
sound_GameOver3:.BYTE	3,$10,$7F,  8,$66,$3B,$33,$78,$3B,$68,$1B, $B,$52,$52,$52,$52
					; DATA XREF: ROM:ED32o
		.BYTE $78,$52,$E8
