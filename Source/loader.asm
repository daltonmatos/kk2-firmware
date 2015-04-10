
.def Counter = r17
.def MixerValue = r18
.def FlagIndex = r19
.def Flags = r20

LoadMixer:

	lds t, UserProfile		;refuse access unless user profile #1 is selected
	tst t
	breq loa13

	ldi t, 2
	call ShowNoAccessDlg
	ret

loa13:	ldy loa10*2

	lds xl, LoadMenuListYposSave
	lds xh, LoadMenuCursorYposSave

	ldi t, 20			;menu items (i.e. motor layouts)

	call Menu

	sts LoadMenuListYposSave, yl
	sts LoadMenuCursorYposSave, yh

	brcs loa22			;BACK pressed?
	ret				;Yes, return


loa22:	ldz loa1*2
	call ShowConfirmationDlg

	cpi t, 0x01			;YES?
	breq loa18

	rjmp loa13			;CANCEL was pressed


loa18:	call StopPwmQuiet		;stop PWM output while loading motor layout
	BuzzerOn

	ldzarray mod0*2, 24, xl		;get motor layout address based on menu selection
	movw x, z
	adiw z, 16			;pointer to flag array

	ldy FlagByte1			;copy flag array to RAM
	ldi Counter, 8

loa24:	lpm t, z+
	st y+, t
	dec Counter
	brne loa24

	movw z, x			;get pointer to motor layout
	ldy eeMixerTable		;register Y holds the EEPROM pointer
	clr FlagIndex			;flag byte index and loop counter for the outer loop

loa19:	lpm xl, z+			;get pointer to mixer value array
	lpm xh, z+
	pushz
	movw z, x			;register Z points to the first item in the current motor layout array
	ldi Counter, 6			;loop counter for the inner loop

	ldx FlagByte1			;get flags from RAM
	add xl, FlagIndex
	clr t
	adc xh, t
	ld Flags, x
	popx				;register X points to the next layout array

loa20:	lpm MixerValue, z+		;mixer value will be modified based on which flags are set

	mov t, Flags
	andi t, 0x80
	breq loa21

	neg MixerValue			;set negative mixer value

loa21:	mov t, Flags
	andi t, 0x08
	breq loa23

	ldi MixerValue, -1		;set mixer value to -1 (i.e. show CCW motor rotation)

loa23:	mov t, MixerValue		;save mixer value
	pushz
	movw z, y
	call WriteEeprom		;for user profile #1 only
	adiw y, 1
	popz

	lsl Flags
	dec Counter
	brne loa20			;inner loop

	adiw y, 2			;compensate for the two unused bytes

	movw z, x			;make register Z point to the next motor layout array
	inc FlagIndex
	cpi FlagIndex, 8
	brlt loa19			;outer loop

	setflagtrue xl			;set flag to indicate that a motor layout has been selected
	ldz eeMotorLayoutOK
	call StoreEeVariable8		;for user profile #1 only

	BuzzerOff

	call StartPwmQuiet		;enable PWM output again

	call MotorLayout		;display motor layout
	rjmp loa13


.undef Counter
.undef MixerValue
.undef FlagIndex
.undef Flags



loa1:	.db "Load motor layout.", 0, 0

loa10:	.db "SingleCopter 1M 4S  "
	.db "SingleCopter 2M 2S  "
	.db "DualCopter II       "
	.db "TriCopter II        "
	.db "QuadroCopter x mode "
	.db "QuadroCopter + mode "
	.db "V-Tail              "
	.db "V-Tail Hunter       "
	.db "Y4                  "
	.db "HexaCopter   x mode "
	.db "HexaCopter   + mode "
	.db "H6                  "
	.db "V6                  "
	.db "Y6                  "
	.db "OctoCopter   x mode "
	.db "OctoCopter   + mode "
	.db "H8                  "
	.db "V8                  "
	.db "X8           x mode "
	.db "X8           + mode "



	;--- Unique motor layout arrays (with unused bytes removed) ---

	;    thr roll pitch yaw ofs flags
lmd1:	.db  0  , 0  , 0  , 0  , 0  , 0
lmd2:	.db  0  , 0  , 0  , 100, 50 , 0
lmd3:	.db  0  , 0  , 100, 0  , 50 , 0
lmd4:	.db  0  , 0  , 100, 100, 0  , 0
lmd5:	.db  0  , 0  , 100, 100, 50 , 0
lmd6:	.db  0  , 100, 0  , 0  , 50 , 0
lmd7:	.db  0  , 100, 0  , 100, 50 , 0
lmd8:	.db  100, 0  , 0  , 0  , 0  , 3
lmd9:	.db  100, 0  , 0  , 100, 0  , 3
lmd10:	.db  100, 0  , 100, 0  , 0  , 3
lmd11:	.db  100, 0  , 100, 100, 0  , 3
lmd12:	.db  100, 38 , 92 , 100, 0  , 3
lmd13:	.db  100, 42 , 71 , 100, 0  , 3
lmd14:	.db  100, 50 , 87 , 100, 0  , 3
lmd15:	.db  100, 61 , 24 , 100, 0  , 3
lmd16:	.db  100, 71 , 0  , 100, 0  , 3
lmd17:	.db  100, 71 , 24 , 100, 0  , 3
lmd18:	.db  100, 71 , 71 , 0  , 0  , 3
;lmd19:	.db  100, 71 , 71 , 1  , 0  , 3
lmd20:	.db  100, 71 , 71 , 100, 0  , 3
lmd21:	.db  100, 81 , 24 , 100, 0  , 3
lmd22:	.db  100, 87 , 50 , 0  , 0  , 3
;lmd23:	.db  100, 87 , 50 , 1  , 0  , 3
lmd24:	.db  100, 87 , 50 , 100, 0  , 3
lmd25:	.db  100, 92 , 38 , 100, 0  , 3
lmd26:	.db  100, 100, 0  , 0  , 0  , 3
;lmd27:	.db  100, 100, 0  , 1  , 0  , 3
lmd28:	.db  100, 100, 0  , 100, 0  , 3
lmd29:	.db  100, 100, 71 , 100, 0  , 3
lmd30:	.db  120, 0  , 90 , 100, 0  , 3
lmd31:	.db  100, 100, 100, 40 , 0  , 3
lmd32:	.db  95 , 0  , 100, 100, 0  , 3



mod0:
	;--- SingleCopter 1M 4S ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 0  , 0  , 0  , 0  , 3  , 0  , 0	;m1
;	.db  0  , 100, 0  , 100, 50 , 0  , 0  , 0	;m2
;	.db  0  , 0  , 100, 100, 50 , 0  , 0  , 0	;m3
;	.db  0  ,-100, 0  , 100, 50 , 0  , 0  , 0	;m4
;	.db  0  , 0  ,-100, 100, 50 , 0  , 0  , 0	;m5
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1      M2      M3      M4      M5      M6      M7      M8
	.dw lmd8*2, lmd7*2, lmd5*2, lmd7*2, lmd5*2, lmd1*2, lmd1*2, lmd1*2
	.db 0x00,   0x00,   0x00,   0x40,   0x20,   0x00,   0x00,   0x00


	;--- SingleCopter 2M 2S ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 0  , 0  , 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 0  , 0  ,-100, 0  , 3  , 0  , 0	;m2
;	.db  0  , 100, 0  , 0  , 50 , 0  , 0  , 0	;m3
;	.db  0  , 0  , 100, 0  , 50 , 0  , 0  , 0	;m4
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1      M2      M3      M4      M5      M6      M7      M8
	.dw lmd9*2, lmd9*2, lmd6*2, lmd3*2, lmd1*2, lmd1*2, lmd1*2, lmd1*2
	.db 0x00,   0x10,   0x00,   0x00,   0x00,   0x00,   0x00,   0x00


	;--- DualCopter II ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 100, 0  , -1 , 0  , 3  , 0  , 0	;m1
;	.db  100,-100, 0  , 0  , 0  , 3  , 0  , 0	;m2
;	.db  0  , 0  , 100, 100, 0  , 0  , 0  , 0	;m3
;	.db  0  , 0  ,-100, 100, 0  , 0  , 0  , 0	;m4
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
;	.db  0  , 0  , 100, 100, 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  ,-100, 100, 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3      M4      M5      M6      M7      M8
	.dw lmd26*2, lmd26*2, lmd4*2, lmd4*2, lmd1*2, lmd1*2, lmd4*2, lmd4*2
	.db 0x01,    0x40,    0x00,   0x20,   0x00,   0x00,   0x00,   0x20


	;--- TriCopter II ---

	;    thr roll pitch yaw offs flags unused
;	.db  100,-87 , 50 , 0  , 0  , 3  , 0  , 0	;m1
;	.db  100, 87 , 50 ,-1  , 0  , 3  , 0  , 0	;m2
;	.db  100, 0  ,-100, 0  , 0  , 3  , 0  , 0	;m3
;	.db  0  , 0  , 0  , 100, 50 , 0  , 0  , 0	;m4
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 100,-50 , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3       M4      M5      M6      M7      M8
	.dw lmd22*2, lmd22*2, lmd10*2, lmd2*2, lmd1*2, lmd1*2, lmd2*2, lmd1*2
	.db 0x40,    0x01,    0x20,    0x00,   0x00,   0x00,   0x10,   0x00


	;--- QuadroCopter x mode ---

	;    thr roll pitch yaw offs flags unused
;	.db  100,-71 , 71 , 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 71 , 71 ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 71 ,-71 , 100, 0  , 3  , 0  , 0	;m3
;	.db  100,-71 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5      M6      M7      M8
	.dw lmd20*2, lmd20*2, lmd20*2, lmd20*2, lmd1*2, lmd1*2, lmd1*2, lmd1*2
	.db 0x40,    0x10,    0x20,    0x70,    0x00,   0x00,   0x00,   0x00


	;--- QuadroCopter + mode ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 0  , 100, 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 100, 0  ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 0  ,-100, 100, 0  , 3  , 0  , 0	;m3
;	.db  100,-100, 0  ,-100, 0  , 3  , 0  , 0	;m4
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5      M6      M7      M8
	.dw lmd11*2, lmd28*2, lmd11*2, lmd28*2, lmd1*2, lmd1*2, lmd1*2, lmd1*2
	.db 0x00,    0x10,    0x20,    0x50,    0x00,   0x00,   0x00,   0x00


	;--- V-Tail ---

	;    thr roll pitch yaw offs flags unused
;	.db  100,-71 , 71 , 0  , 0  , 3  , 0  , 0	;m1
;	.db  100, 71 , 71 ,-1  , 0  , 3  , 0  , 0	;m2
;	.db  120, 0  ,-90 , 100, 0  , 3  , 0  , 0	;m3
;	.db  120, 0  ,-90 ,-100, 0  , 3  , 0  , 0	;m4
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5      M6      M7      M8
	.dw lmd18*2, lmd18*2, lmd30*2, lmd30*2, lmd1*2, lmd1*2, lmd1*2, lmd1*2
	.db 0x40,    0x01,    0x20,    0x30,    0x00,   0x00,   0x00,   0x00


	;--- V-Tail Hunter ---

	;    thr roll pitch yaw offs flags unused
;	.db  100,-100, 100,-40,  0  , 3  , 0  , 0	;m1
;	.db  100, 100, 100, 40,  0  , 3  , 0  , 0	;m2
;	.db  95,  0  ,-100, 100, 0  , 3  , 0  , 0	;m3
;	.db  95,  0  ,-100,-100, 0  , 3  , 0  , 0	;m4
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5      M6      M7      M8
	.dw lmd31*2, lmd31*2, lmd32*2, lmd32*2, lmd1*2, lmd1*2, lmd1*2, lmd1*2
	.db 0x50,    0x00,    0x20,    0x30,    0x00,   0x00,   0x00,   0x00


	;--- Y4 ---

	;    thr roll pitch yaw offs flags unused
;	.db  100,-71 , 71 , 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 71 , 71 ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 0  ,-100, 100, 0  , 3  , 0  , 0	;m3
;	.db  100, 0  ,-100,-100, 0  , 3  , 0  , 0	;m4
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5      M6      M7      M8
	.dw lmd20*2, lmd20*2, lmd11*2, lmd11*2, lmd1*2, lmd1*2, lmd1*2, lmd1*2
	.db 0x40,    0x10,    0x20,    0x30,    0x00,   0x00,   0x00,   0x00


	;--- HexaCopter x mode ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 50 , 87 , 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 100, 0  ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 50 ,-87 , 100, 0  , 3  , 0  , 0	;m3
;	.db  100,-50 ,-87 ,-100, 0  , 3  , 0  , 0	;m4
;	.db  100,-100, 0  , 100, 0  , 3  , 0  , 0	;m5
;	.db  100,-50 , 87 ,-100, 0  , 3  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5       M6       M7      M8
	.dw lmd14*2, lmd28*2, lmd14*2, lmd14*2, lmd28*2, lmd14*2, lmd1*2, lmd1*2
	.db 0x00,    0x10,    0x20,    0x70,    0x40,    0x50,    0x00,   0x00


	;--- HexaCopter + mode ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 0  , 100, 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 87 , 50 ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 87 ,-50 , 100, 0  , 3  , 0  , 0	;m3
;	.db  100, 0  ,-100,-100, 0  , 3  , 0  , 0	;m4
;	.db  100,-87 ,-50 , 100, 0  , 3  , 0  , 0	;m5
;	.db  100,-87 , 50 ,-100, 0  , 3  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5       M6       M7      M8
	.dw lmd11*2, lmd24*2, lmd24*2, lmd11*2, lmd24*2, lmd24*2, lmd1*2, lmd1*2
	.db 0x00,    0x10,    0x20,    0x30,    0x60,    0x50,    0x00,   0x00


	;--- H6 ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 71 , 71 , 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 71 , 0  ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 71 ,-71 , 100, 0  , 3  , 0  , 0	;m3
;	.db  100,-71 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
;	.db  100,-71 , 0  , 100, 0  , 3  , 0  , 0	;m5
;	.db  100,-71 , 71 ,-100, 0  , 3  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5       M6       M7      M8
	.dw lmd20*2, lmd16*2, lmd20*2, lmd20*2, lmd16*2, lmd20*2, lmd1*2, lmd1*2
	.db 0x00,    0x10,    0x20,    0x70,    0x40,    0x50,    0x00,   0x00


	;--- V6 ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 100, 71 , 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 71 , 0  ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 42 ,-71 , 100, 0  , 3  , 0  , 0	;m3
;	.db  100,-42 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
;	.db  100,-71 , 0  , 100, 0  , 3  , 0  , 0	;m5
;	.db  100,-100, 71 ,-100, 0  , 3  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5       M6       M7      M8
	.dw lmd29*2, lmd16*2, lmd13*2, lmd13*2, lmd16*2, lmd29*2, lmd1*2, lmd1*2
	.db 0x00,    0x10,    0x20,    0x70,    0x40,    0x50,    0x00,   0x00


	;--- Y6 ---

	;    thr roll pitch yaw offs flags unused
;	.db  100,-87 , 50 , 100, 0  , 3  , 0  , 0	;m1
;	.db  100,-87 , 50 ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 87 , 50 , 100, 0  , 3  , 0  , 0	;m3
;	.db  100, 87 , 50 ,-100, 0  , 3  , 0  , 0	;m4
;	.db  100, 0  ,-100, 100, 0  , 3  , 0  , 0	;m5
;	.db  100, 0  ,-100,-100, 0  , 3  , 0  , 0	;m6
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
;	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5       M6       M7      M8
	.dw lmd24*2, lmd24*2, lmd24*2, lmd24*2, lmd11*2, lmd11*2, lmd1*2, lmd1*2
	.db 0x40,    0x50,    0x00,    0x10,    0x20,    0x30,    0x00,   0x00


	;--- OctoCopter x mode ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 38 , 92 , 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 92 , 38 ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 92 ,-38 , 100, 0  , 3  , 0  , 0	;m3
;	.db  100, 38 ,-92 ,-100, 0  , 3  , 0  , 0	;m4
;	.db  100,-38 ,-92 , 100, 0  , 3  , 0  , 0	;m5
;	.db  100,-92 ,-38 ,-100, 0  , 3  , 0  , 0	;m6
;	.dw  100,-92 , 38 , 100, 0  , 3  , 0  , 0	;m7
;	.db  100,-38 , 92 ,-100, 0  , 3  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5       M6       M7       M8
	.dw lmd12*2, lmd25*2, lmd25*2, lmd12*2, lmd12*2, lmd25*2, lmd25*2, lmd12*2
	.db 0x00,    0x10,    0x20,    0x30,    0x60,    0x70,    0x40,    0x50


	;--- OctoCopter + mode ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 0  , 100, 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 71 , 71 ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 100, 0  , 100, 0  , 3  , 0  , 0	;m3
;	.db  100, 71 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
;	.db  100, 0  ,-100, 100, 0  , 3  , 0  , 0	;m5
;	.db  100,-71 ,-71 ,-100, 0  , 3  , 0  , 0	;m6
;	.dw  100,-100, 0  , 100, 0  , 3  , 0  , 0	;m7
;	.db  100,-71 , 71 ,-100, 0  , 3  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5       M6       M7       M8
	.dw lmd11*2, lmd20*2, lmd28*2, lmd20*2, lmd11*2, lmd20*2, lmd28*2, lmd20*2
	.db 0x00,    0x10,    0x00,    0x30,    0x20,    0x70,    0x40,    0x50


	;--- H8 ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 71 , 71 , 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 71 , 24 ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 71 ,-24 , 100, 0  , 3  , 0  , 0	;m3
;	.db  100, 71 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
;	.db  100,-71 ,-71 , 100, 0  , 3  , 0  , 0	;m5
;	.db  100,-71 ,-24 ,-100, 0  , 3  , 0  , 0	;m6
;	.dw  100,-71 , 24 , 100, 0  , 3  , 0  , 0	;m7
;	.db  100,-71 , 71 ,-100, 0  , 3  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5       M6       M7       M8
	.dw lmd20*2, lmd17*2, lmd17*2, lmd20*2, lmd20*2, lmd17*2, lmd17*2, lmd20*2
	.db 0x00,    0x10,    0x20,    0x30,    0x60,    0x70,    0x40,    0x50


	;--- V8 ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 100, 71 , 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 81 , 24 ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 61 ,-24 , 100, 0  , 3  , 0  , 0	;m3
;	.db  100, 42 ,-71 ,-100, 0  , 3  , 0  , 0	;m4
;	.db  100,-42 ,-71 , 100, 0  , 3  , 0  , 0	;m5
;	.db  100,-61 ,-24 ,-100, 0  , 3  , 0  , 0	;m6
;	.dw  100,-81 , 24 , 100, 0  , 3  , 0  , 0	;m7
;	.db  100,-100, 71 ,-100, 0  , 3  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5       M6       M7       M8
	.dw lmd29*2, lmd21*2, lmd15*2, lmd13*2, lmd13*2, lmd15*2, lmd21*2, lmd29*2
	.db 0x00,    0x10,    0x20,    0x30,    0x60,    0x70,    0x40,    0x50


	;--- X8 x mode ---

	;    thr roll pitch yaw offs flags unused
;	.db  100,-71 , 71 , 100, 0  , 3  , 0  , 0	;m1
;	.db  100,-71 , 71 ,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 71 , 71 , 100, 0  , 3  , 0  , 0	;m3
;	.db  100, 71 , 71 ,-100, 0  , 3  , 0  , 0	;m4
;	.db  100, 71 ,-71 , 100, 0  , 3  , 0  , 0	;m5
;	.db  100, 71 ,-71 ,-100, 0  , 3  , 0  , 0	;m6
;	.dw  100,-71 ,-71 , 100, 0  , 3  , 0  , 0	;m7
;	.db  100,-71 ,-71 ,-100, 0  , 3  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5       M6       M7       M8
	.dw lmd20*2, lmd20*2, lmd20*2, lmd20*2, lmd20*2, lmd20*2, lmd20*2, lmd20*2
	.db 0x40,    0x50,    0x00,    0x10,    0x20,    0x30,    0x60,    0x70


	;-- X8 + mode ---

	;    thr roll pitch yaw offs flags unused
;	.db  100, 0  , 100, 100, 0  , 3  , 0  , 0	;m1
;	.db  100, 0  , 100,-100, 0  , 3  , 0  , 0	;m2
;	.db  100, 100, 0  , 100, 0  , 3  , 0  , 0	;m3
;	.db  100, 100, 0  ,-100, 0  , 3  , 0  , 0	;m4
;	.db  100, 0  ,-100, 100, 0  , 3  , 0  , 0	;m5
;	.db  100, 0  ,-100,-100, 0  , 3  , 0  , 0	;m6
;	.dw  100,-100, 0  , 100, 0  , 3  , 0  , 0	;m7
;	.db  100,-100, 0  ,-100, 0  , 3  , 0  , 0	;m8

	;     M1       M2       M3       M4       M5       M6       M7       M8
	.dw lmd11*2, lmd11*2, lmd28*2, lmd28*2, lmd11*2, lmd11*2, lmd28*2, lmd28*2
	.db 0x00,    0x10,    0x00,    0x10,    0x20,    0x30,    0x40,    0x50


	;--- Unused ---
/*
	;    thr roll pitch yaw offs flags unused
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m1
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m2
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m3
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m4
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m5
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m6
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m7
	.db  0  , 0  , 0  , 0  , 0  , 0  , 0  , 0	;m8

*/


