


RemoteTuning:

	rcall LoadTuningRate

	rcall CheckTuningMode			;set TuningMode to 1 (Aileron) if it currently is set to 2 (Elevator) with roll/pitch linked

tun10:	call GetRxChannels

	lds t, RxBufferState			;update the display only when we have new data
	cpi t, 3
	breq tun11

	ldi yl, 25				;wait 2.5ms
	call wms

	rvbrflagfalse RxFrameValid, tun11	;update the display also when no valid frames are received

	rjmp tun12				;skip update

tun11:	lds t, TuningMode			;is tuning mode active?
	tst t
	brne tun13

	call ScaleAuxInputValues

tun13:	b16mul Tuned6, RxAux2, TuningRateValue	;will display scaled RX values for channel 6 and 7 as default
	b16mul Tuned7, RxAux3, TuningRateValue
	rcall Tuning

	call LcdClear6x8

	ldz tun1*2				;tuning mode
	call PrintString

	lds t, TuningMode			;off, aileron, elevator, rudder, SL gain, ACC trim or gimbal gains
	ldz tunmode*2
	call PrintFromStringArray

tun20:	lrv X1, 0				;channel 6 label
	lrv Y1, 10
	lds t, TuningMode
	ldz ch6lbl*2
	call PrintFromStringArray
	b16load Tuned6
 	call Print16Signed

	lrv X1, 0				;channel 7 label
	lrv Y1, 19
	lds t, TuningMode
	ldz ch7lbl*2
	call PrintFromStringArray
	b16load Tuned7
 	call Print16Signed

	lrv X1, 0				;input rate
	lrv Y1, 28
	ldz tun4*2
	call PrintString
	lds t, TuningRate
	ldz lmh*2
	call PrintFromStringArray

	lds t, TuningMode			;linked with elevator
	cpi t, 1
	brne tun29

	rvbrflagfalse flagRollPitchLink, tun29

	lrv X1, 0
	lrv Y1, 41
	ldz tun5*2
	call PrintString

tun29:	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz tunrate*2
	call PrintString

	;print banner
	ldz tun7*2
	call PrintSelector

	call LcdUpdate

	lds t, RxMode				;use delay for CPPM mode only
	cpi t, RxModeSBus
	brge tun12

	call RxPollDelay

tun12:	call GetButtons

	cpi t, 0x08				;BACK?
	brne tun21
	ret

tun21:	cpi t, 0x04				;RATE?
	brne tun19

	call Beep
	rcall SetInputRate
	rjmp tun10

tun19:	cpi t, 0x02				;SAVE?
	brne tun24

	rcall SaveValues
	call Beep
	lds xl, TuningMode
	rcall ShowSavedStatus
	rjmp tun10

tun24:	cpi t, 0x01				;CHANGE?
	breq tun22
	rjmp tun10

tun22:	lds t, TuningMode
	inc t
	cpi t, 7
	brlt tun23

	clr t

tun23:	cpi t, 2				;skip elevator settings if linked with aileron
	brne tun30

	lds xl, flagRollPitchLink
	tst xl
	brpl tun30

	inc t

tun30:	sts TuningMode, t
	call Beep
	call ReleaseButtons
	rjmp tun10



tun1:	.db "Tuning Mode: ", 0
tun4:	.db "Input rate : ", 0
tun5:	.db "Linked with elevator.", 0

tun7:	.db 76, 0, 127, 9

chan6:	.db "Channel 6  : ", 0
chan7:	.db "Channel 7  : ", 0
pgain6:	.db "P Gain/Ch.6: ", 0
igain7:	.db "I Gain/Ch.7: ", 0
rgain7:	.db "R Gain/Ch.7: ", 0
ptrim6:	.db "P Trim/Ch.6: ", 0
rtrim7:	.db "R Trim/Ch.7: ", 0

ch6lbl:	.dw chan6*2, pgain6*2, pgain6*2, pgain6*2, pgain6*2, ptrim6*2, pgain6*2
ch7lbl:	.dw chan7*2, igain7*2, igain7*2, igain7*2, chan7*2, rtrim7*2, rgain7*2

rate1:	.db "LOW", 0
rate2:	.db "MEDIUM", 0, 0
rate3:	.db "HIGH", 0, 0

lmh:	.dw null*2, rate1*2, rate2*2, rate3*2

pst2:	.db "NOT", 0

pst3:	.db "Please center your TX", 0
pst4:	.db "tuning controls now.", 0, 0

pst5:	.db "A Tuning Mode must be", 0
pst6:	.db "selected first.", 0

pst10:	.dw pst3*2, pst4*2, pst5*2, pst6*2

sir1:	.db "SET INPUT RATE", 0, 0
sir2:	.db "Select input rate for", 0
sir3:	.db "all tuning modes. Use", 0
sir4:	.db "LOW for fine-tuning.", 0, 0
sir6:	.db "BACK  LOW MEDIUM HIGH", 0

sir8:	.dw sir1*2, sir2*2, sir3*2, sir4*2




	;--- Select input rate for tuning ---

SetInputRate:

sir10:	call LcdClear6x8

	lrv X1, 22				;print header and three more lines of text
	clr t

sir11:	ldz sir8*2
	push t
	call PrintFromStringArray
	lrv X1, 0
	rvadd Y1, 9
	pop t
	tst t
	brne sir12

	lrv Y1, 13				;use extra distance between the header and the first text line
	ldi t, 1
	rjmp sir11

sir12:	inc t
	cpi t, 4
	brne sir11

	;footer
	lrv X1, 0
	lrv Y1, 57
	ldz sir6*2
	call PrintString

	call LcdUpdate

	call GetButtonsBlocking
	andi t, 0x07				;BACK?
	breq sir15

	cpi t, 0x04				;LOW?
	brne sir13

	ldi xl, 1				;low rate
	rjmp sir14

sir13:	cpi t, 0x02				;MEDIUM?
	brne sir16

	ldi xl, 2				;medium rate
	rjmp sir14

sir16:	cpi t, 1				;HIGH?
	breq sir17

	rjmp sir10				;no, more than one button must have been pushed simultaneously

sir17:	ldi xl, 3				;high rate

sir14:	ldz eeTuningRate			;save tuning rate
	call StoreEePVariable8
	rcall LoadTuningRate			;set tuning rate value

sir15:	call ReleaseButtons
	ret



	;--- Load tuning rate from EEPROM ---

LoadTuningRate:

	ldz eeTuningRate
	call GetEePVariable8
	andi xl, 0x03

	tst xl					;invalid tuning rate?
	brne ltr1

	ldi xl, 2				;yes, use default tuning rate (i.e. MEDIUM)

ltr1:	cpi xl, 1				;low?
	brne ltr2

	b16ldi Temp, 0.15			;low rate
	rjmp ltr4

ltr2:	cpi xl, 2				;medium?
	brne ltr3

	b16ldi Temp, 0.45			;medium rate
	rjmp ltr4

ltr3:	b16ldi Temp, 0.75			;high rate

ltr4:	sts TuningRate, xl
	b16mov TuningRateValue, Temp
	ret



	;--- Show status after the tuned values have been saved (or not saved) ---

ShowSavedStatus:

	call LcdClear12x16
	lrv X1, 10

	tst xl					;input parameter (0=No data was saved)
	brne ps2

	ldz pst2*2				;print "NOT"
	call PrintString
	lrv X1, 58
	rjmp ps4

ps2:	lrv X1, 34				;print "SAVED"
ps4:	ldz saved*2
	call PrintString

	lrv FontSelector, f6x8

	ldi xh, 2				;print two lines of text selected by the input parameter (XL)
	lrv X1, 0
	lrv Y1, 17
	clr t					;t=0 will print "Please center your TX tuning controls now."
	tst xl
	brne ps3

	ldi t, 2				;t=2 will print "A Tuning Mode must be selected first."

ps3:	push xh
	push t
	ldz pst10*2
	call PrintFromStringArray
	lrv X1, 0
	rvadd Y1, 9
	pop t
	inc t
	pop xh
	dec xh
	brne ps3

	;footer
	call PrintOkFooter

	call LcdUpdate

ps1:	call GetButtonsBlocking
	cpi t, 0x01				;OK?
	brne ps1

	call ReleaseButtons
	ret



	;--- Save tuned value(s) ---

SaveValues:

	lds t, TuningMode			;is tuning mode active?
	tst t
	brne sav1
	ret					;no, abort

sav1:	b16load Tuned6

	cpi t, 1
	brne sav2

	b16store PGainRollOrg
	clr t					;aileron axis
	clr yl					;P-Gain parameter index
	rcall SaveParameter
	clr t
	ldi yl, 2				;I-Gain parameter index
	b16load Tuned7
	b16store IGainRollOrg
	rcall SaveParameter
	rvbrflagtrue flagRollPitchLink, sav6	;aileron and elevator settings linked?
	ret

sav2:	cpi t, 2
	brne sav3

sav6:	ldi t, 1				;elevator axis
	clr yl					;P-Gain parameter index
	b16load Tuned6
	b16store PGainPitchOrg
	rcall SaveParameter
	ldi t, 1
	ldi yl, 2				;I-Gain parameter index
	b16load Tuned7
	b16store IGainPitchOrg
	rcall SaveParameter
	ret

sav3:	cpi t, 3
	brne sav4

	b16store PGainYawOrg
	ldi t, 2				;rudder axis
	clr yl					;P-Gain parameter index
	rcall SaveParameter
	ldi t, 2
	ldi yl, 2				;I-Gain parameter index
	b16load Tuned7
	b16store IGainYawOrg
	rcall SaveParameter
	ret

sav4:	cpi t, 4
	brne sav5

	b16store SelfLevelPgainOrg		;SL P gain
	ldz eeSelflevelPgain
	call StoreEePVariable16
	ret

sav5:	cpi t, 5
	brne sav7

	b16store AccTrimPitchOrg		;ACC trim
	ldz eeAccTrimPitch
	call StoreEePVariable16
	b16load Tuned7
	b16store AccTrimRollOrg
	ldz eeAccTrimRoll
	call StoreEePVariable16
	ret

sav7:	b16store CamPitchGainOrg		;gimbal gains
	ldz eeCamPitchGain
	call StoreEePVariable16
	b16load Tuned7
	b16store CamRollGainOrg
	ldz eeCamRollGain
	call StoreEePVariable16
	ret



	;--- Save one 16 bit parameter ---

SaveParameter:

	ldz EeParameterTable			;Z = *EeParameterTable + Axis * 8 + ParameterIndex * 2
	lsl t					;Axis
	lsl t
	lsl t
	add zl, t
	clr t
	adc zh, t
	mov t, yl				;ParameterIndex
	lsl t
	add zl, t
	clr t
	adc zh, t
	mov t, xl				;Value
	call WriteEepromP
	adiw z, 1
	mov t, xh
	call WriteEepromP
	ret



	;--- Tuning (will run while armed also) ---

Tuning:

	lds t, TuningMode			;is tuning mode active?
	tst t
	brne tun50
	ret					;no, abort

tun50:	call ScaleAuxInputValues
	b16mul RxAux2, RxAux2, TuningRateValue	;yes, scale RX inputs further down
	b16mul RxAux3, RxAux3, TuningRateValue

	lds t, TuningMode
	cpi t, 1
	brne tun51

	b16mov Temper, PGainRollOrg		;aileron
	b16mov Temp, IGainRollOrg
	rcall AddRxOffset
	call TempDiv16				;Temp = Tuned7 / 16
	b16mov PGainRoll, Tuned6
	b16mov IGainRoll, Temp
	rvbrflagtrue flagRollPitchLink, tun55	;aileron and elevator settings linked?
	ret

tun51:	cpi t, 2
	brne tun52

	b16mov Temper, PGainPitchOrg		;elevator
	b16mov Temp, IGainPitchOrg
	rcall AddRxOffset
	call TempDiv16				;Temp = Tuned7 / 16
tun55:	b16mov PGainPitch, Tuned6
	b16mov IGainPitch, Temp
	ret

tun52:	cpi t, 3
	brne tun53

	b16mov Temper, PGainYawOrg		;rudder
	b16mov Temp, IGainYawOrg
	rcall AddRxOffset
	call TempDiv16				;Temp = Tuned7 / 16
	b16mov PGainYaw, Tuned6
	b16mov IGainYaw, Temp
	ret

tun53:	cpi t, 4
	brne tun54

	b16mov Temper, SelflevelPgainOrg	;SL gain
	rcall AddRxOffset
	b16clr Tuned7
	b16mov SelflevelPgain, Tuned6
	ret

tun54:	cpi t, 5
	breq tun56

	rjmp tun57

tun56:	b16add Tuned7, AccTrimRollOrg, RxAux3	;ACC trim (can be negative)
	b16sub Tuned6, AccTrimPitchOrg, RxAux2	;a positive RX value should make the model go forward
	b16mov AccTrimPitch, Tuned6
	b16mov AccTrimRoll, Tuned7
	b16fdiv AccTrimPitch, 2
	b16fdiv AccTrimRoll, 2
	ret

tun57:	b16add Tuned7, CamRollGainOrg, RxAux3	;gimbal gains (can be negative)
	b16add Tuned6, CamPitchGainOrg, RxAux2
	b16mov CamPitchGain, Tuned6
	b16mov CamRollGain, Tuned7
	b16fdiv CamPitchGain, 4
	b16fdiv CamRollGain, 4
	ret



	;--- Add offset from RX channels ---

AddRxOffset:

	b16add Tuned6, Temper, RxAux2
	brge tp1

	b16clr Tuned6				;cannot use negative values

tp1:	b16add Tuned7, Temp, RxAux3
	brge tp2

	b16clr Tuned7				;cannot use negative values

tp2:	b16mov Temp, Tuned7
	ret



	;--- Check and correct TuningMode ---

CheckTuningMode:

	lds t, TuningMode		;set TuningMode to 1 (Aileron) if it is currently set to 2 (Elevator) and roll/pitch are linked
	cpi t, 2
	brne ctm1

	rvbrflagfalse flagRollPitchLink, ctm1

	ldi t, 1
	sts TuningMode, t

ctm1:	ret



