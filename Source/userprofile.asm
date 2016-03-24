
.def DefaultUserProfile = r17
.def Item = r18

UserProfileSetup:

	clr Item

ups10:	ldz eeUserProfile		;get default user profile value (from user profile #1)
	call ReadEeprom
	mov DefaultUserProfile, t

	call LcdClear6x8

	ldi t, 5			;print all text labels first
	ldz ups8*2
	call PrintStringArray

	lrv X1, 102			;default user profile
	lrv Y1, 1
	clr xh
	mov xl, DefaultUserProfile
	inc xl
	clr yh
	call Print16Signed

	;footer
	tst Item
	brne ups12

	call PrintStdFooter
	rjmp ups13

ups12:	call PrintSelectFooter

ups13:	;print selector
	ldzarray ups7*2, 4, Item
	call PrintSelector

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08			;BACK?
	brne ups15

	ret

ups15:	cpi t, 0x04			;PREV?
	brne ups16

	dec Item
	brpl ups19

	ldi Item, 2
	rjmp ups10

ups16:	cpi t, 0x02			;NEXT?
	brne ups17

	inc Item
	cpi Item, 3
	brlt ups19

	clr Item

ups19:	rjmp ups10

ups17:	cpi t, 0x01			;CHANGE/SELECT?
	brne ups19

	cpi Item, 0
	brne ups20

	mov xl, DefaultUserProfile	;set default user profile
	inc xl
	clr xh
	ldy 1				;lower limit
	ldz 4				;upper limit
	call NumberEdit
	mov xl, r0
	dec xl
	mov DefaultUserProfile, xl
	ldz eeUserProfile
	call StoreEeVariable8		;save in profile #1 only
	clr Item
	rjmp ups10

ups20:	cpi Item, 1
	brne ups21

	rcall CopyUserProfile		;import user profile
	ldi Item, 1
	rjmp ups10

ups21:	ldz ups5*2			;reset the active user profile
	call ShowConfirmationDlg
	cpi t, 0x01
	breq ups18

	ldi Item, 2			;CANCEL was pressed
	rjmp ups10

ups18:	call InitUserProfile		;YES was pressed. Resetting parameters
	call setup_mpu6050		;update the MPU
	call InitialSetup		;display initial setup menu
	ret



	;--- Show status after copying EEPROM data ---

ShowCopyStatus:

	call LcdClear12x16

	tst xl					;input parameter (0=Success)
	brne scs12

	lrv X1, 40				;print "DONE"
	ldz scs1*2
	call PrintString
	rjmp scs13

scs12:	lrv X1, 34				;print "ERROR"
	ldz cerror*2
	call PrintString

scs13:	lrv FontSelector, f6x8

	ldi xh, 2				;print two lines of text selected by the input parameter (XL)
	lrv X1, 0				;- XL=0 will print "All data copied from the selected profile."
	lrv Y1, 17				;- XL=2 will print "The selected profiles must be different."
	mov t, xl				;- XL=4 will print "Profile #1 can only be edited manually."

scs14:	push xh
	push t
	ldz scs10*2
	call PrintFromStringArray
	lrv X1, 0
	call LineFeed
	pop t
	inc t
	pop xh
	dec xh
	brne scs14

	;footer
	call PrintOkFooter

	call LcdUpdate

	call WaitForOkButton
	ret




ups1:	.db "Default Profile: ", 0
ups3:	.db "Functions:", 0, 0
ups4:	.db "Import user profile.", 0, 0
ups5:	.db "Reset active profile.", 0

ups7:	.db 101, 0, 109, 9
	.db 0, 27, 127, 36
	.db 0, 36, 127, 45

ups8:	.dw ups1*2, null*2, ups3*2, ups4*2, ups5*2

scs1:	.db "DONE", 0, 0

scs3:	.db "All data copied from", 0, 0
scs4:	.db "the selected profile.", 0

scs5:	.db "The selected profiles", 0
scs6:	.db "must be different.", 0, 0

scs7:	.db "Profile #1 can only", 0
scs8:	.db "be edited manually.", 0

scs10:	.dw scs3*2, scs4*2, scs5*2, scs6*2, scs7*2, scs8*2


.undef DefaultUserProfile
.undef Item



	;--- Copy EEPROM data from a different profile ---

CopyUserProfile:

	lds t, UserProfile		;will not overwrite user profile #1
	tst t
	brne cup7

	ldi xl, 4			;XL=4 means that profile #1 was selected as target
	rjmp cup8

cup7:	ldi xl, 1			;select user profile to copy EEPROM data from
	clr xh
	ldy 1				;lower limit
	ldz 4				;upper limit
	call NumberEdit
	mov xl, r0
	dec xl

	lds t, UserProfile		;source==target?
	cp t, xl
	brne cup9

	ldi xl, 2			;yes, display error message and exit

cup8:	rcall ShowCopyStatus
	ret

cup9:	push xl				;no, ask for confirmation
	ldz ups4*2
	call ShowConfirmationDlg
	cpi t, 0x01
	breq cup10

	pop xl				;CANCEL was pressed
	ret

cup10:	clr zl				;YES was pressed
	pop yl				;selected profile
	BuzzerOn

cup11:	mov zh, yl
	call ReadEeprom			;read from selected profile
	mov xl, t
	call StoreEePVariable8		;write to current profile
	tst zl				;256 bytes written?
	brne cup11

	BuzzerOff			;yes
	call setup_mpu6050		;update the MPU

	clr xl				;show status dialogue (XL=0 means Success)
	rjmp cup8



	;--- Change user profile ---

ChangeUserProfile:

	cpi yl, 0x02			;register YL holds button input
	breq cup2

	cpi yl, 0x04
	breq cup2

	ret				;incorrect button input

cup2:	lsr yl
	andi yl, 0x01
	brne cup1

	ser yl				;will decrease the user profile value

cup1:	lds xl, UserProfile
	add yl, xl
	andi yl, 0x03
	sts UserProfile, yl
	call EeInit			;initialize profile data when selected for the first time
	call setup_mpu6050		;update the MPU
	ret



	;--- Start the LED flashing sequence ---

StartLedSeq:

	lds t, UserProfile	;LED will flash twice for profile #2, three times for profile #3 and four times for profile #4
	tst t
	brne sls1

	ret			;will not flash when user profile #1 is selected

sls1:	inc t
	sts LedSequence, t

	ldi t, 100		;set initial LED flashing delay
	sts LedCounter, t

	clr t			;start with LED in 'off' state
	sts LedState, t

	;       76543210
	ldi t,0b00000000	;set timer0 to normal mode
	store tccr0a, t

	;       76543210
	ldi t,0b00000101	;clk/1024 prescaler
	store tccr0b, t

	;       76543210
	ldi t,0b00000001	;enable timer0 overflow interrupt
	store timsk0, t
	ret



	;--- End the LED flashing sequence --- 

StopLedSeq:

	;       76543210
	ldi t,0b00000000	;disable timer0 overflow interrupt
	store timsk0, t

	LedOff
	ret



	;--- Interrupt routine making the LED flash while navigating the KK2's menu screens ---

IsrLed:

	in SregSaver, sreg		;check delay counter
	lds tt, LedCounter
	dec tt
	brne isr10

	lds treg, LedState		;check LED state
	tst treg
	brne isr11

	LedOn
	ldi tt, 15
	rjmp isr12

isr11:	LedOff

	lds tt, LedSequence		;check LED sequence
	dec tt
	breq isr13

	sts LedSequence, tt		;update the LED sequence
	ldi tt, 15
	rjmp isr12

isr13:	lds tt, UserProfile		;reset the LED sequence
	inc tt
	sts LedSequence, tt
	ldi tt, 200

isr12:	com treg			;toggle the LED state
	sts LedState, treg

isr10:	sts LedCounter, tt
	out sreg, SregSaver		;exit	
	reti
