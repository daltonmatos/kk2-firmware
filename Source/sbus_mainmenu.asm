

SBusMainMenu:

smm23:	ldy smm1 * 2

	lds xl, MainMenuListYposSave
	lds xh, MainMenuCursorYposSave

	ldi t, 18		;number of menu items

	call Menu

	sts MainMenuListYposSave, yl
	sts MainMenuCursorYposSave, yh

	brcs smm22		;BACK pressed?
	ret			;Yes, return
	
smm22:	lsl xl			;No, calculate index    Z = *mem18 * 2 + xl * 2
	ldz smm18 * 2
	add zl, xl
	clr t
	adc zh, t

	lpm xl, z+		;x = (Z)
	lpm xh, z
	
	movw z, x		;z = x
	
	icall			;go to choosen menu item code  (sound like an apple product!  lawlz)

	call Beep

	call LcdClear		;blank screen
	call LcdUpdate	

smm20:	call GetButtons		;wait until buttons relesed
	cpi t, 0
	brne smm20	
	
	jmp smm23




smm1:	.db "Remote Tuning       "
	.db "PI Editor           "
	.db "Self-level Settings "
	.db "Stick Scaling       "
	.db "Mode Settings       "
	.db "Misc. Settings      "
	.db "Gimbal Settings     "
	.db "Sensor Settings     "
	.db "AUX Switch Setup    "
	.db "Initial Setup       "
	.db "Receiver Test       "
	.db "Sensor Test         "
	.db "Mixer Editor        "
	.db "Show Motor Layout   "
	.db "User Profile        "
	.db "ESC Calibration     "
	.db "Version Information "
	.db "LCD Contrast        "


smm18:	.dw RemoteTuning
	.dw PiEditor
	.dw SelflevelSettings
	.dw StickScaling
	.dw ModeSettings
	.dw MiscSettings
	.dw GimbalSettings
	.dw SensorSettings
	.dw AuxSwitchSetup
	.dw InitialSetup
	.dw SBusRxTest
	.dw SensorTest
	.dw MixerEditor
	.dw MotorLayout
	.dw UserProfileSetup
	.dw EscCalWarning
	.dw ShowVersion
	.dw Contrast


