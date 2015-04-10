
FactoryReset:

	ldz fac2*2
	call ShowConfirmationDlg

	cpi t, 0x01		;YES?
	breq fac1

	ret			;CANCEL was pressed

fac1:	clr t			;destroy first byte in EEPROM
	ldz 0
	call WriteEeprom

	jmp reset		;restart



fac2:	.db "Reset all settings.", 0

