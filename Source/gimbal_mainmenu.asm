

GimbalMainMenu:

gmm23:	ldy gmm1 * 2

	lds xl, MainMenuListYposSave
	lds xh, MainMenuCursorYposSave

	ldi t, 11			;number of menu items

	call Menu

	sts MainMenuListYposSave, yl
	sts MainMenuCursorYposSave, yh

	brcs gmm22			;BACK pressed?
	ret				;yes, return
	
gmm22:	lsl xl				;no, calculate index    Z = *gmm18 * 2 + xl * 2
	ldz gmm18 * 2
	add zl, xl
	clr t
	adc zh, t

	lpm xl, z+			;x = (Z)
	lpm xh, z
	
	movw z, x			;z = x
	
	icall				;go to choosen menu item code  (sound like an apple product!  lawlz)

	call Beep

	call LcdClear			;blank screen
	call LcdUpdate	

	call ReleaseButtons
	
	jmp gmm23




gmm1:	.db "Mode Settings       "
	.db "Misc. Settings      "
	.db "Gimbal Settings     "
	.db "Advanced Settings   "
	.db "Initial Setup       "
	.db "Receiver Test       "
	.db "Sensor Test         "
	.db "User Profile        "
	.db "Exit Gimbal Mode    "
	.db "Version Information "
	.db "LCD Contrast        "


gmm18:	.dw ModeSettings
	.dw MiscSettings
	.dw GimbalSettings
	.dw AdvancedSettings
	.dw InitialSetup
	.dw RxTest2
	.dw SensorTest
	.dw UserProfileSetup
	.dw GimbalMode
	.dw ShowVersion
	.dw Contrast


