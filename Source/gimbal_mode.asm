
.def OldSetting = r17


	;--- Gimbal controller mode ---

GimbalMode:

	ldz eeGimbalMode		;get current setting
	call ReadEeprom
	mov OldSetting, t

	call LcdClear12x16

	;header
	lrv X1, 28
	ldz gbm1*2
	call PrintHeader

	;text
	ldi t, 3
	ldz gbm10*2
	call PrintStringArray

	;footer
	lrv X1, 42
	lrv Y1, 57
	ldz yn*2
	call PrintString

	call LcdUpdate

gbm11:	call GetButtonsBlocking

	cpi t, 0x04			;YES?
	brne gbm13

	ser t
	rjmp gbm15

gbm13:	cpi t, 0x02			;NO?
	brne gbm11

	clr t

gbm15:	cp t, OldSetting		;save setting, but only if it has changed
	breq gbm16

	ldz eeGimbalMode
	call WriteEeprom

	jmp EnforceRestart		;enforce restart

gbm16:	ret



gbm1:	.db "GIMBAL", 0, 0
gbm2:	.db "Use this board as a", 0
gbm3:	.db "stand-alone (servo)", 0
gbm4:	.db "gimbal controller?", 0, 0

gbm10:	.dw gbm2*2, gbm3*2, gbm4*2



	;--- Get gimbal controller mode from EEPROM ---

GetGimbalControllerMode:

	ldz eeGimbalMode
	call ReadEeprom			;read from profile #1 only
	sts flagGimbalMode, t
	ret



	;--- Reset gimbal controller mode ---

ResetGimbalControllerMode:

	clr t
	ldz eeGimbalMode
	call WriteEeprom		;save in profile #1 only
	ret



.undef OldSetting

