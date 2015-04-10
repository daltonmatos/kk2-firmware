

MainMenu:

men23:	ldy men1 * 2

	lds xl, MainMenuListYposSave
	lds xh, MainMenuCursorYposSave

	ldi t, 18		;number of menu items

	call Menu

	sts MainMenuListYposSave, yl
	sts MainMenuCursorYposSave, yh

	brcs men22		;BACK pressed?
	ret			;Yes, return
	
men22:	lsl xl			;No, calculate index    Z = *men18 * 2 + xl * 2
	ldz men18 * 2
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

	call ReleaseButtons
	
	jmp men23




men1:	.db "Quick Tuning        "
	.db "PI Editor           "
	.db "Self-level Settings "
	.db "Stick Scaling       "
	.db "Mode Settings       "
	.db "Misc. Settings      "
	.db "Gimbal Settings     "
	.db "AUX Switch Setup    "
	.db "Initial Setup       "
	.db "Channel Mapping     "
	.db "Receiver Test       "
	.db "Sensor Test         "
	.db "Mixer Editor        "
	.db "Show Motor Layout   "
	.db "User Profile        "
	.db "ESC Calibration     "
	.db "Version Information "
	.db "LCD Contrast        "


men18:	.dw QuickTuning
	.dw PiEditor
	.dw SelflevelSettings
	.dw StickScaling
	.dw ModeSettings
	.dw MiscSettings
	.dw GimbalSettings
	.dw AuxSwitchSetup
	.dw InitialSetup
	.dw ChannelMapping
	.dw RxTest
	.dw SensorTest
	.dw MixerEditor
	.dw MotorLayout
	.dw UserProfileSetup
	.dw EscCalWarning
	.dw ShowVersion
	.dw Contrast


