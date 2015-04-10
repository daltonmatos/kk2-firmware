

CppmMainMenu:

cmm23:	ldy cmm1 * 2

	lds xl, MainMenuListYposSave
	lds xh, MainMenuCursorYposSave

	ldi t, 19		;number of menu items

	call Menu

	sts MainMenuListYposSave, yl
	sts MainMenuCursorYposSave, yh

	brcs cmm22		;BACK pressed?
	ret			;Yes, return
	
cmm22:	lsl xl			;No, calculate index    Z = *mem18 * 2 + xl * 2
	ldz cmm18 * 2
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

cmm20:	call GetButtons		;wait until buttons relesed
	cpi t, 0
	brne cmm20	
	
	jmp cmm23




cmm1:	.db "Remote Tuning       "
	.db "PI Editor           "
	.db "Self-level Settings "
	.db "Stick Scaling       "
	.db "Mode Settings       "
	.db "Misc. Settings      "
	.db "Gimbal Settings     "
	.db "Sensor Settings     "
	.db "AUX Switch Setup    "
	.db "Initial Setup       "
	.db "CPPM settings       "
	.db "Receiver Test       "
	.db "Sensor Test         "
	.db "Mixer Editor        "
	.db "Show Motor Layout   "
	.db "User Profile        "
	.db "ESC Calibration     "
	.db "Version Information "
	.db "LCD Contrast        "


cmm18:	.dw RemoteTuning
	.dw PiEditor
	.dw SelflevelSettings
	.dw StickScaling
	.dw ModeSettings
	.dw MiscSettings
	.dw GimbalSettings
	.dw SensorSettings
	.dw AuxSwitchSetup
	.dw InitialSetup
	.dw CppmSettings
	.dw CppmRxTest
	.dw SensorTest
	.dw MixerEditor
	.dw MotorLayout
	.dw UserProfileSetup
	.dw EscCalWarning
	.dw ShowVersion
	.dw Contrast


