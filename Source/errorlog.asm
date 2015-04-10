

.def ErrCode = r17


ErrorLog:

	ldz eeErrorCode
	call ReadEeprom
	tst t
	brne el11

	rvbrflagfalse flagErrorLogSetup, el10

	rjmp ErrorLogSetup			;display setup screen

el10:	clc					;no error logged
	ret

el11:	LedToggle
	mov ErrCode, t
	andi ErrCode, 0x03

	;header
	lrv X1, 10
	ldz errlog*2
	call PrintHeader

	;logged data
	lrv X1, 0
	mov t, ErrCode
	ldz ecode*2
	call PrintFromStringArray

	call LineFeed
	lrv X1, 0
	ldz time*2
	call PrintString
	ldz eeErrorTimeSec
	call GetEeVariable8
	mov yl, xl
	call GetEeVariable8
	call PrintTime

	;footer
	lrv X1, 96
	lrv Y1, 57
	ldz clear*2
	call PrintString

	sec
	ret



	;--- Error log setup screen ---

ErrorLogSetup:

	;header
	lrv X1, 10
	ldz errlog*2
	call PrintHeader

	;status
	lrv X1, 0
	ldz status*2
	call PrintString
	ldz eeErrorLogState
	call ReadEeprom
	andi t, 0x01
	ldz estate*2
	call PrintFromStringArray

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz change*2
	call PrintString
	lrv X1, 96
	ldz abort*2
	call PrintString

	sec
	ret



errlog:	.db "ERROR LOG", 0
abort:	.db "ABORT", 0

time:	.db "Time: ", 0, 0
status:	.db "Status: ", 0, 0

elon:	.db "ENABLED", 0
eloff:	.db "DISABLED", 0, 0

estate:	.dw eloff*2, elon*2

csl1:	.db "CPPM sync was lost!", 0
;sta9:	.db "RX signal was lost!", 0
;sta32:	.db "FAILSAFE!", 0
;sta45:	.db "Sat protocol error!", 0
ecode:	.dw csl1*2, sta9*2, sta32*2, sta45*2



	;--- Log error to EEPROM ---

LogError:

	ldz eeErrorLogState			;skip logging if disabled
	call ReadEeprom
	brflagfalse t, le1

	ldz eeErrorCode				;will save the error code only if no error has been logged earlier
	call ReadEeprom
	tst t
	brne le1

	call StoreEeVariable8			;register XL (input parameter) holds the error code

	lds xl, Timer1sec			;save flight timer
	call StoreEeVariable8
	lds xl, Timer1min
	call StoreEeVariable8

le1:	ret



	;--- Clear error log ---

ClearLoggedError:

	ldz eeErrorCode				;check for existing error
	call ReadEeprom
	tst t
	brne cle1

	rvbrflagtrue flagErrorLogSetup, cle2	;jump when setup screen is active

	clc					;no error
	ret

cle1:	clr t					;clear error
	ldz eeErrorCode
	call WriteEeprom

cle2:	rvsetflagfalse flagErrorLogSetup
	LedOff
	sec
	ret



	;--- Toggle error logging state ---

ToggleErrorLogState:

	rvbrflagfalse flagErrorLogSetup, tel10

	ldz eeErrorLogState			;setup screen is active so we'll toggle the EEPROM setting
	call ReadEeprom
	com t
	call WriteEeprom

	rvsetflagfalse flagErrorLogSetup	;this will "close" the setup window

tel10:	ret



	;--- Reset settings for error logging ---

ResetErrorLogging:

	ser t					;set the EEPROM setting to ENABLED
	ldz eeErrorLogState
	call WriteEeprom
	rcall ClearLoggedError
	ret



.undef ErrCode

