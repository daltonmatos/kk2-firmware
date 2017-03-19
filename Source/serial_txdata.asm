
	//************************************************************
	//* Serial data format (8-N-1/250kbps)
	//*
	//*   Byte1:	Status bits or button state
	//*
	//*
	//* FC status bits:	[F7 F6 F5 F4 F3 F2 F1 F0]
	//*
	//*   F0: Alarm/LVA buzzer (ON = 1).
	//*   F1: Flight mode - Acro (ON = 1).
	//*   F2: Flight mode - SL Mix (ON = 1).
	//*   F3: Flight mode - Normal SL (ON = 1).
	//*   F4: Armed (ON = 1).
	//*   F5: Always 0, Slave mode = OFF.
	//*   F6: Always 1.
	//*   F7: Always 0.
	//*
	//*
	//* FC button state:	[F7 F6 F5 F4 F3 F2 F1 F0]
	//*
	//*   F0: Button #4 (Pressed = 1).
	//*   F1: Button #3 (Pressed = 1).
	//*   F2: Button #2 (Pressed = 1).
	//*   F3: Button #1 (Pressed = 1).
	//*   F4: Always 0. Armed = OFF.
	//*   F5: Always 1. Slave mode = ON. FC will act as master.
	//*   F6: Always 1.
	//*   F7: Always 0.
	//*
	//************************************************************



	;--- Transmit FC status ---

TransmitStatus:

	lds xh, flagGeneralBuzzerOn		;alarm/LVA (must be cleared when the MENU button is held down to prevent constant beeping in menu)
	lds xl, flagLvaBuzzerOn
	or xl, xh
	load t, pinb
	swap t
	andi t, 0x01
	and xl, t

	lds xh, flagSlStickMixing		;acro
	lds t, flagSlOn
	or t, xh
	com t
	andi t, 0x02
	or xl, t

	andi xh, 0x04				;SL mix mode
	or xl, xh

	lds t, flagSlOn				;normal SL mode
	andi t, 0x08
	or xl, t

	lds t, flagArmed			;armed
	andi t, 0x10
	or xl, t

	ori xl, 0x40				;fixed bits

	store udr1, xl				;set USART buffer
	ret



	;--- Transmit FC button state ---

TransmitButtonState:

	mov xl, t				;register T (input parameter) holds the button status
	andi xl, 0x0F

	ori xl, 0x60				;fixed bits

	store udr1, xl				;set USART buffer
	ret



perc:	.db "Access Port Expander.", 0

perc1:	.db "No response from Port", 0
perc2:	.db "Expander! Check the", 0
perc3:	.db "wiring and try again.", 0

perc5:	.db "Port Expander access", 0, 0
perc6:	.db "ended.", 0, 0

perc7:	.db 0, 0, 127, 63

perc8:	.dw perc1*2, perc2*2, perc3*2
perc9:	.dw perc5*2, perc6*2



	;--- Control port expander remotely ---

PortExpanderRC:

	lds t, UserProfile			;refuse access unless user profile #1 is selected
	tst t
	breq perc16

	ldz nadtxt2*2
	call ShowNoAccessDlg
	ret

perc16:	ldz perc*2
	call ShowConfirmationDlg
	cpi t, 0x01
	breq perc10

	ret					;CANCEL was pressed

perc10:	ldi zl, 3				;re-transmission counter

perc11:	rcall PortExpanderIsrSetup

	ldi t, 0x01				;send button state (MENU button pushed) to Port Expander to enter SLAVE MODE
	rcall TransmitButtonState

	ldx 200					;wait for response
	call WaitXms
	rvbrflagtrue flagRxBufferFull, perc13

	dec zl					;no (or bad) response from port expander. Retry a few times before giving up
	brne perc11

	;warning
	call PrintWarningHeader

	ldi t, 3				;warning message
	ldz perc8*2
	rjmp perc20

	;remote control loop
perc12:	rvbrflagfalse flagRxBufferFull, perc15

perc13:	rcall PortExpanderIsrSetup		;buffer was filled. Prepare buffer for the next iteration and then update the LCD
	ldz perc7*2
	call PrintSelector
	call LcdUpdate

perc14:	call GetButtons				;send button state to Port Expander
	rcall TransmitButtonState
	rjmp perc12

perc15:	ldz LcdBuffer				;buffer is not full. Abort when port expander unit sends a termination message
	ld t, z+
	cpi t, RxStartByte
	brne perc14

	ld t, z+
	cpi t, RxSlaveEndByte
	brne perc14

	;exit slave mode
	call LcdClear12x16

	lrv X1, 40
	ldz info*2
	call PrintHeader

	ldi t, 2				;information
	ldz perc9*2

perc20:	call PrintStringArray

	call PrintOkFooter
	call LcdUpdate

	call WaitForOkButton

	cli					;restore USART RX buffer pointers
	ldz RxBuffer0
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh
	ldz RxBufferEnd
	sts RxBufferEndL, zl
	sts RxBufferEndH, zh
	sei
	ret



	;--- Set up USART RX interrupt for port expander RC ---

PortExpanderIsrSetup:

	clr xl

	cli
	sts flagRxBufferFull, xl
	ldx LcdBuffer				;use LCD buffer as RX buffer
	sts RxBufferAddressL, xl
	sts RxBufferAddressH, xh
	ldx RamMixerTable			;end of LCD buffer
	sts RxBufferEndL, xl
	sts RxBufferEndH, xh
	sei
	ret


