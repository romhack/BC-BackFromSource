;Данные	уровней. Теперь располагаются в верхнем окне.

Level_Data:
INCBIN Levels\1_level.bin
INCBIN Levels\2_level.bin
INCBIN Levels\3_level.bin
INCBIN Levels\4_level.bin
INCBIN Levels\5_level.bin
INCBIN Levels\6_level.bin
INCBIN Levels\7_level.bin
INCBIN Levels\8_level.bin
INCBIN Levels\9_level.bin
INCBIN Levels\10_level.bin
INCBIN Levels\11_level.bin
INCBIN Levels\12_level.bin
INCBIN Levels\13_level.bin
INCBIN Levels\14_level.bin
INCBIN Levels\15_level.bin
INCBIN Levels\16_level.bin
INCBIN Levels\17_level.bin
INCBIN Levels\18_level.bin
INCBIN Levels\19_level.bin
INCBIN Levels\20_level.bin
INCBIN Levels\21_level.bin
INCBIN Levels\22_level.bin
INCBIN Levels\23_level.bin
INCBIN Levels\24_level.bin
INCBIN Levels\25_level.bin
INCBIN Levels\26_level.bin
INCBIN Levels\27_level.bin
INCBIN Levels\28_level.bin
INCBIN Levels\29_level.bin
INCBIN Levels\30_level.bin
INCBIN Levels\31_level.bin
INCBIN Levels\32_level.bin
INCBIN Levels\33_level.bin
INCBIN Levels\34_level.bin
INCBIN Levels\35_level.bin
INCBIN Levels\36_level.bin
INCBIN Levels\37_level.bin
INCBIN Levels\38_level.bin
INCBIN Levels\39_level.bin
INCBIN Levels\40_level.bin
INCBIN Levels\41_level.bin
INCBIN Levels\42_level.bin
INCBIN Levels\43_level.bin
INCBIN Levels\44_level.bin
INCBIN Levels\45_level.bin
INCBIN Levels\46_level.bin
INCBIN Levels\47_level.bin
INCBIN Levels\48_level.bin
INCBIN Levels\49_level.bin
INCBIN Levels\50_level.bin
INCBIN Levels\51_level.bin
INCBIN Levels\52_level.bin
INCBIN Levels\53_level.bin
INCBIN Levels\54_level.bin
INCBIN Levels\55_level.bin
INCBIN Levels\56_level.bin
INCBIN Levels\57_level.bin
INCBIN Levels\58_level.bin
INCBIN Levels\59_level.bin
INCBIN Levels\60_level.bin
INCBIN Levels\61_level.bin
INCBIN Levels\62_level.bin
INCBIN Levels\63_level.bin
INCBIN Levels\64_level.bin
INCBIN Levels\65_level.bin
INCBIN Levels\66_level.bin
INCBIN Levels\67_level.bin
INCBIN Levels\68_level.bin
INCBIN Levels\69_level.bin
INCBIN Levels\70_level.bin
INCBIN Levels\71_level.bin
INCBIN Levels\72_level.bin
INCBIN Levels\73_level.bin
INCBIN Levels\74_level.bin
INCBIN Levels\75_level.bin
INCBIN Levels\76_level.bin
INCBIN Levels\77_level.bin
INCBIN Levels\78_level.bin
INCBIN Levels\79_level.bin
INCBIN Levels\80_level.bin
INCBIN Levels\81_level.bin
INCBIN Levels\82_level.bin
INCBIN Levels\83_level.bin
INCBIN Levels\84_level.bin
INCBIN Levels\85_level.bin
INCBIN Levels\86_level.bin
INCBIN Levels\87_level.bin
INCBIN Levels\88_level.bin
INCBIN Levels\89_level.bin
INCBIN Levels\90_level.bin
INCBIN Levels\91_level.bin
INCBIN Levels\92_level.bin
INCBIN Levels\93_level.bin
INCBIN Levels\94_level.bin
INCBIN Levels\95_level.bin
INCBIN Levels\96_level.bin
INCBIN Levels\97_level.bin
INCBIN Levels\98_level.bin
INCBIN Levels\99_level.bin

INCBIN Levels\demo level.bin
INCBIN Levels\empty level.bin 

EnemyType_ROMArray:.BYTE $80, $A0, $C0,	$E0 ; DATA XREF: Load_New_Tank+39r
		.BYTE $E0, $A0,	$C0, $80 ; 2
		.BYTE $80, $A0,	$C0, $E0 ; 3
		.BYTE $C0, $A0,	$80, $E0 ; 4
		.BYTE $C0, $E0,	$80, $A0 ; 5
		.BYTE $C0, $A0,	$80, $E0 ; 6
		.BYTE $80, $A0,	$C0, $80 ; 7
		.BYTE $C0, $E0,	$A0, $80 ; 8
		.BYTE $80, $A0,	$C0, $E0 ; 9
		.BYTE $80, $A0,	$C0, $E0 ; 10
		.BYTE $A0, $E0,	$C0, $A0 ; 11
		.BYTE $C0, $A0,	$80, $E0 ; 12
		.BYTE $C0, $A0,	$80, $E0 ; 13
		.BYTE $C0, $A0,	$80, $E0 ; 14
		.BYTE $80, $C0,	$A0, $E0 ; 15
		.BYTE $80, $C0,	$A0, $E0 ; 16
		.BYTE $E0, $A0,	$C0, $80 ; 17
		.BYTE $E0, $80,	$C0, $A0 ; 18
		.BYTE $A0, $E0,	$80, $C0 ; 19
		.BYTE $A0, $80,	$C0, $E0 ; 20
		.BYTE $C0, $A0,	$80, $E0 ; 21
		.BYTE $A0, $80,	$C0, $E0 ; 22
		.BYTE $E0, $80,	$C0, $A0 ; 23
		.BYTE $C0, $E0,	$A0, $80 ; 24
		.BYTE $C0, $A0,	$80, $E0 ; 25
		.BYTE $A0, $E0,	$80, $C0 ; 26
		.BYTE $C0, $E0,	$A0, $80 ; 27
		.BYTE $A0, $E0,	$80, $C0 ; 28
		.BYTE $C0, $A0,	$80, $E0 ; 29
		.BYTE $80, $A0,	$C0, $E0 ; 30
		.BYTE $C0, $A0,	$E0, $C0 ; 31
		.BYTE $E0, $80,	$C0, $A0 ; 32
		.BYTE $A0, $E0,	$C0, $A0 ; 33
		.BYTE $C0, $A0,	$80, $E0 ; 34
		.BYTE $C0, $A0,	$80, $E0 ; 35 и	Демо-уровень



		.BYTE $80, $A0, $C0, $E0 
		.BYTE $E0, $A0,	$C0, $80 
		.BYTE $80, $A0,	$C0, $E0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $C0, $E0,	$80, $A0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $80, $A0,	$C0, $80 
		.BYTE $C0, $E0,	$A0, $80 
		.BYTE $80, $A0,	$C0, $E0 
		.BYTE $80, $A0,	$C0, $E0 
		.BYTE $A0, $E0,	$C0, $A0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $80, $C0,	$A0, $E0 
		.BYTE $80, $C0,	$A0, $E0 
		.BYTE $E0, $A0,	$C0, $80 
		.BYTE $E0, $80,	$C0, $A0 
		.BYTE $A0, $E0,	$80, $C0 
		.BYTE $A0, $80,	$C0, $E0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $A0, $80,	$C0, $E0 
		.BYTE $E0, $80,	$C0, $A0 
		.BYTE $C0, $E0,	$A0, $80 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $A0, $E0,	$80, $C0 
		.BYTE $C0, $E0,	$A0, $80 
		.BYTE $A0, $E0,	$80, $C0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $80, $A0,	$C0, $E0 
		.BYTE $C0, $A0,	$E0, $C0 
		.BYTE $E0, $80,	$C0, $A0 
		.BYTE $A0, $E0,	$C0, $A0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $C0, $A0,	$80, $E0  

		.BYTE $80, $A0, $C0, $E0 
		.BYTE $E0, $A0,	$C0, $80 
		.BYTE $80, $A0,	$C0, $E0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $C0, $E0,	$80, $A0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $80, $A0,	$C0, $80 
		.BYTE $C0, $E0,	$A0, $80 
		.BYTE $80, $A0,	$C0, $E0 
		.BYTE $80, $A0,	$C0, $E0 
		.BYTE $A0, $E0,	$C0, $A0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $80, $C0,	$A0, $E0 
		.BYTE $80, $C0,	$A0, $E0 
		.BYTE $E0, $A0,	$C0, $80 
		.BYTE $E0, $80,	$C0, $A0 
		.BYTE $A0, $E0,	$80, $C0 
		.BYTE $A0, $80,	$C0, $E0 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $A0, $80,	$C0, $E0 
		.BYTE $E0, $80,	$C0, $A0 
		.BYTE $C0, $E0,	$A0, $80 
		.BYTE $C0, $A0,	$80, $E0 
		.BYTE $A0, $E0,	$80, $C0 
		.BYTE $C0, $E0,	$A0, $80 
		.BYTE $A0, $E0,	$80, $C0 
		.BYTE $C0, $A0,	$80, $E0
		.BYTE $80, $A0,	$C0, $E0 
		.BYTE $C0, $A0,	$E0, $C0 
		.BYTE $E0, $80,	$C0, $A0 ; взяли с запасом на все уровни.

;
;Количество врагов (4 типа и не	более 20) по уровням:
Enemy_Amount_ROMArray:.BYTE $12, 2, 0, 0 ; DATA	XREF: Load_Enemy_Count+11r
					; Load_Enemy_Count+16r
					; Load_Enemy_Count+1Br
					; Load_Enemy_Count+20r
		.BYTE 2, 4, 0, $E	; 2
		.BYTE $E, 4, 0,	2	; 3
		.BYTE $A, 5, 2,	3	; 4
		.BYTE 5, 2, 8, 5	; 5
		.BYTE 7, 2, 9, 2	; 6
		.BYTE 3, 4, 6, 7	; 7
		.BYTE 7, 2, 4, 7	; 8
		.BYTE 6, 4, 7, 3	; 9
		.BYTE $C, 2, 4,	2	; 10
		.BYTE 5, 6, 4, 5	; 11
		.BYTE 8, 6, 0, 6	; 12
		.BYTE 8, 8, 0, 4	; 13
		.BYTE $A, 4, 0,	6	; 14
		.BYTE 2, 0, $A,	8	; 15
		.BYTE $10, 0, 2, 2	; 16
		.BYTE 2, 2, 8, 8	; 17
		.BYTE 4, 2, 6, 8	; 18
		.BYTE 4, 8, 4, 4	; 19
		.BYTE 8, 2, 2, 8	; 20
		.BYTE 8, 2, 6, 4	; 21
		.BYTE 8, 6, 2, 4	; 22
		.BYTE 6, 0, 4, $A	; 23
		.BYTE 4, 2, 4, $A	; 24
		.BYTE 2, 8, 0, $A	; 25
		.BYTE 6, 6, 4, 4	; 26
		.BYTE 2, 8, 8, 2	; 27
		.BYTE 2, 1, $F,	2	; 28
		.BYTE $A, 4, 0,	6	; 29
		.BYTE 4, 8, 4, 4	; 30
		.BYTE 3, 8, 6, 3	; 31
		.BYTE 8, 6, 2, 4	; 32
		.BYTE 4, 8, 4, 4	; 33
		.BYTE 4, $A, 0,	6	; 34
		.BYTE 4, 6, 0, $A	; 35 

		.BYTE $12, 2, 0, 0 
		.BYTE 2, 4, 0, $E	
		.BYTE $E, 4, 0,	2	
		.BYTE $A, 5, 2,	3	
		.BYTE 5, 2, 8, 5	
		.BYTE 7, 2, 9, 2	
		.BYTE 3, 4, 6, 7	
		.BYTE 7, 2, 4, 7	
		.BYTE 6, 4, 7, 3	
		.BYTE $C, 2, 4,	2	
		.BYTE 5, 6, 4, 5	
		.BYTE 8, 6, 0, 6	
		.BYTE 8, 8, 0, 4	
		.BYTE $A, 4, 0,	6	
		.BYTE 2, 0, $A,	8	
		.BYTE $10, 0, 2, 2	
		.BYTE 2, 2, 8, 8	
		.BYTE 4, 2, 6, 8	
		.BYTE 4, 8, 4, 4	
		.BYTE 8, 2, 2, 8	
		.BYTE 8, 2, 6, 4	
		.BYTE 8, 6, 2, 4	
		.BYTE 6, 0, 4, $A	
		.BYTE 4, 2, 4, $A	
		.BYTE 2, 8, 0, $A	
		.BYTE 6, 6, 4, 4	
		.BYTE 2, 8, 8, 2	
		.BYTE 2, 1, $F,	2	
		.BYTE $A, 4, 0,	6	
		.BYTE 4, 8, 4, 4	
		.BYTE 3, 8, 6, 3	
		.BYTE 8, 6, 2, 4	
		.BYTE 4, 8, 4, 4	
		.BYTE 4, $A, 0,	6	
		.BYTE 4, 6, 0, $A	

		.BYTE $12, 2, 0, 0 
		.BYTE 2, 4, 0, $E	
		.BYTE $E, 4, 0,	2	
		.BYTE $A, 5, 2,	3	
		.BYTE 5, 2, 8, 5	
		.BYTE 7, 2, 9, 2	
		.BYTE 3, 4, 6, 7	
		.BYTE 7, 2, 4, 7	
		.BYTE 6, 4, 7, 3	
		.BYTE $C, 2, 4,	2	
		.BYTE 5, 6, 4, 5	
		.BYTE 8, 6, 0, 6	
		.BYTE 8, 8, 0, 4	
		.BYTE $A, 4, 0,	6	
		.BYTE 2, 0, $A,	8	
		.BYTE $10, 0, 2, 2	
		.BYTE 2, 2, 8, 8	
		.BYTE 4, 2, 6, 8	
		.BYTE 4, 8, 4, 4	
		.BYTE 8, 2, 2, 8	
		.BYTE 8, 2, 6, 4	
		.BYTE 8, 6, 2, 4	
		.BYTE 6, 0, 4, $A	
		.BYTE 4, 2, 4, $A	
		.BYTE 2, 8, 0, $A	
		.BYTE 6, 6, 4, 4	
		.BYTE 2, 8, 8, 2	
		.BYTE 2, 1, $F,	2	
		.BYTE $A, 4, 0,	6	
		.BYTE 4, 8, 4, 4	
		.BYTE 3, 8, 6, 3	
		.BYTE 8, 6, 2, 4 ; взяли с запасом на все уровни.	
