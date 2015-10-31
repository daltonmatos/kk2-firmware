
;Original code by Rolf R Bakke 2011, 2012, 2013

;best viewed with a TAB-setting of 8 and monospace font.



.include "m644Pdef.inc"

.equ offset = 0x00

.include "macros.inc"
.include "miscmacros.inc"
.include "variables.asm"
.include "hardware.asm"
.include "168mathlib_macros.inc"
.include "832mathlib_macros.inc"
.include "constants.asm"
.include "bindwrappers.asm"

.org 0x0000

	jmp reset		; Reset
	jmp IsrPitch		; External Interrupt Request 0
	jmp IsrRoll		; External Interrupt Request 1
	jmp unused		; External Interrupt Request 2
	jmp unused		; Pin Change Interrupt Request 0
	jmp IsrYawAux		; Pin Change Interrupt Request 1
	jmp unused		; Pin Change Interrupt Request 2
	jmp IsrThrottleCppm	; Pin Change Interrupt Request 3
	jmp unused		; Watchdog Time-out Interrupt
	jmp unused		; Timer/Counter2 Compare Match A
	jmp unused		; Timer/Counter2 Compare Match B
	jmp IsrPwmQuiet		; Timer/Counter2 Overflow
	jmp unused		; Timer/Counter1 Capture Event
	jmp IsrPwmStart		; Timer/Counter1 Compare Match A
	jmp IsrPwmEnd		; Timer/Counter1 Compare Match B
	jmp unused		; Timer/Counter1 Overflow
	jmp unused		; Timer/Counter0 Compare Match A
	jmp unused		; Timer/Counter0 Compare Match B
	jmp IsrLed		; Timer/Counter0 Overflow
	jmp unused		; SPI Serial Transfer Complete
	jmp IsrSerialRx		; USART0, Rx Complete
	jmp unused		; USART0 Data register Empty
	jmp unused		; USART0, Tx Complete
	jmp unused		; Analog Comparator
	jmp unused		; ADC Conversion Complete
	jmp unused		; EEPROM Ready
	jmp unused		; 2-wire Serial Interface
	jmp unused		; Store Program Memory Read
	jmp unused		; USART1 RX complete
	jmp unused		; USART1 Data Register Empty
	jmp unused		; USART1 TX complete

unused:	reti



	;--- Common initialization ---

c_main:
  ret

reset:

	ldi t, low(ramend)	;initalize stack pointer
	out spl, t
	ldi t, high(ramend)
	out sph, t

  safe_call_c c_main

.include "rxmode.asm"
.include "batteryvoltage.asm"

.include "serial_readrx.asm"
.include "serial_rxtest.asm"
.include "serial_checkrx.asm"
.include "serial_debug.asm"

.include "cppm_main.asm"
.include "cppm_hwsetup.asm"
.include "cppm_mainmenu.asm"
.include "cppm_readrx.asm"
.include "cppm_checkrx.asm"

.include "sbus_main.asm"
.include "sbus_hwsetup.asm"
.include "sbus_mainmenu.asm"
.include "sbus_status.asm"
.include "sbus_readrx.asm"
.include "sbus_dg2settings.asm"

.include "sat_main.asm"
.include "sat_hwsetup.asm"
.include "sat_mainmenu.asm"
.include "sat_misc.asm"
.include "sat_readrx.asm"

.include "gimbal.asm"
.include "gimbal_mode.asm"
.include "gimbal_main.asm"
.include "gimbal_mainmenu.asm"

.include "advanced.asm"
.include "extra.asm"
.include "motorcheck.asm"
.include "boardrotation.asm"
.include "channelmapping.asm"
.include "errorlog.asm"
.include "main.asm"
.include "tuning.asm"
.include "quicktuning.asm"
.include "userprofile.asm"
.include "trigonometry.asm"
.include "setuphw.asm"
.include "version.asm"
.include "beeper.asm"
.include "menu.asm"
.include "lva.asm"
.include "logic.asm"
.include "contrast.asm"
.include "auxsettings.asm"
.include "loader.asm"
.include "selflevel.asm"
.include "layout.asm"
.include "throttlecal.asm"
.include "eeinit.asm"
.include "sensorcal.asm"
.include "settingsc.asm"
.include "settingsb.asm"
.include "settingsa.asm"
.include "flightdisplay.asm"
.include "arm.asm"
.include "flightinit.asm"
.include "pieditor.asm"
.include "numedit.asm"
.include "mixedit.asm"
.include "mixer2.asm"
.include "imu.asm"
.include "pwmgen.asm"
.include "rxtest.asm"
.include "readrx.asm"
.include "mainmenu.asm"
.include "sensortest.asm"
.include "sensorreading.asm"
.include "sensorsettings.asm"
.include "ST7565.asm"
.include "miscsubs.asm"
.include "168mathlib_subs.asm"
.include "832mathlib_subs.asm"
font6x8:
.include "font6x8.asm"
font8x12:
;.include "font8x12.asm"
font12x16:
.include "font12x16.asm"
symbols16x16:
.include "symbols16x16.asm"
font4x6:
.include "font4x6.asm"


.include "callwrappers.asm"


