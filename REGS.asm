;Здесь описаны регистры NES

Enum $2000
; ===========================================================================
		;.segment PPU_Registers

PPU_CTRL_REG1:	.BYTE 0	; (uninited)	; PPU Control Register #1 (W)
PPU_CTRL_REG2:	.BYTE 0	; (uninited)	; PPU Control Register #2 (W)
PPU_STATUS:	.BYTE 0	; (uninited)	; PPU Status Register (R)
PPU_SPR_ADDR:	.BYTE 0	; (uninited)	; SPR-RAM Address Register (W)
PPU_SPR_DATA:	.BYTE 0	; (uninited)	; SPR-RAM I/O Register (W)
PPU_SCROLL_REG:	.BYTE 0	; (uninited)	; VRAM Address Register	#1 (W2)
PPU_ADDRESS:	.BYTE 0	; (uninited)	; VRAM Address Register	#2 (W2)
PPU_DATA:	.BYTE 0	; (uninited)	; VRAM I/O Register (RW)
; end of 'PPU_Registers'

Ende

Enum $4000
; ===========================================================================
		;.segment Misc_Registers

SND_SQUARE1_REG:.BYTE 0	; (uninited)	; DATA XREF: Play_Sound+5Dw
					; Play_Sound+89w
					; pAPU Pulse #1	Control	Register (W)
pAPU_Pulse1_Ramp_Control_Reg:.BYTE 0 ; (uninited) ; pAPU Pulse #1 Ramp Control Register	(W)
pAPU_Pulse1__FT__Reg:.BYTE 0 ; (uninited) ; pAPU Pulse #1 Fine Tune (FT) Register (W)
pAPU_Pulse1__CT__Reg:.BYTE 0 ; (uninited) ; pAPU Pulse #1 Coarse Tune (CT) Register (W)
SND_SQUARE2_REG:.BYTE 0	; (uninited)	; pAPU Pulse #2	Control	Register (W)
pAPU_Pulse2_Ramp_Control_Reg:.BYTE 0 ; (uninited) ; pAPU Pulse #2 Ramp Control Register	(W)
pAPU_Pulse2__FT__Reg:.BYTE 0 ; (uninited) ; pAPU Pulse #2 Fine Tune Register (W)
pAPU_Pulse2__CT__Reg:.BYTE 0 ; (uninited) ; pAPU Pulse #2 Coarse Tune Register (W)
SND_TRIANGLE_REG:.BYTE 0 ; (uninited)	; pAPU Triangle	Control	Register #1 (W)
pAPU_Triangle_Control_Reg2:.BYTE 0 ; (uninited)	; pAPU Triangle	Control	Register #2 (?)
pAPU_Triangle_Frequency_Reg1:.BYTE 0 ; (uninited) ; pAPU Triangle Frequency Register #1	(W)
pAPU_Triangle_Frequency_Reg2:.BYTE 0 ; (uninited) ; pAPU Triangle Frequency Register #2	(W)
SND_NOISE_REG:	.BYTE 0	; (uninited)	; pAPU Noise Control Register #1 (W)
Unused:		.BYTE 0	; (uninited)	; Unused (???)
pAPU_Noise_Frequency_Reg1:.BYTE	0 ; (uninited) ; pAPU Noise Frequency Register #1 (W)
pAPU_Noise_Frequency_Reg2:.BYTE	0 ; (uninited) ; pAPU Noise Frequency Register #2 (W)
SND_DELTA_REG:	.BYTE 0	; (uninited)	; pAPU Delta Modulation	Control	Register (W)
pAPU_Delta_Modulation_DA_Reg:.BYTE 0 ; (uninited) ; pAPU Delta Modulation D/A Register (W)
pAPU_Delta_Modulation_Address_Reg:.BYTE	0 ; (uninited) ; pAPU Delta Modulation Address Register	(W)
pAPU_Delta_Modulation_Data_Length_Reg:.BYTE 0 ;	(uninited) ; pAPU Delta	Modulation Data	Length Register	(W)
SPR_DMA:	.BYTE 0	; (uninited)	; Sprite DMA Register (W)
SND_MASTERCTRL_REG:.BYTE 0 ; (uninited)	; DATA XREF: Sound_Stop+2w
					; pAPU Sound/Vertical Clock Signal Register (R)
JOYPAD_PORT1:	.BYTE 0	; (uninited)	; DATA XREF: Read_Joypads+2w
					; Read_Joypads+7w Read_Joypads:-r
					; Joypad #1 (RW)
JOYPAD_PORT2:	.BYTE 0	; (uninited)	; DATA XREF: Sound_Stop+7w
; end of 'Misc_Registers'               ; Joypad #2/SOFTCLK (RW)


Ende
