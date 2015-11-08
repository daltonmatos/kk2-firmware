
show_version:
  nop

ShowVersion:

  safe_call_c show_version
  ret

;	call LcdClear12x16
;
;	lrv X1, 22				;Header
;	ldz ver1*2
;	call PrintHeader
;
;	ldi t, 4				;print version information
;	ldz ver10*2
;	call PrintStringArray
;
;	lrv X1, 36				;print RX mode
;	lrv Y1, 26
;	lds t, RxMode
;	ldz modes*2
;	call PrintFromStringArray
;
;	;footer
;	call PrintBackFooter
;
;	call LcdUpdate
;
;ver12:	call GetButtonsBlocking
;	cpi t, 0x08				;BACK?
;	brne ver12
;	ret

	

ver1:	.db "VERSION", 0
ver2:	.db "KK2.1.x AiO", 0

;ver10:	.dw ver2*2, srm2*2, null*2, motto*2
