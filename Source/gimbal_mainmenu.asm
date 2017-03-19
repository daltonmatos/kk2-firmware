

GimbalMainMenu:

gmm23:	ldy gmm1*2

	lds xl, MainMenuListYposSave
	lds xh, MainMenuCursorYposSave

	ldi t, 12			;number of menu items
	call Menu

	sts MainMenuListYposSave, yl
	sts MainMenuCursorYposSave, yh

	brcs gmm22			;BACK pressed?

	ret				;yes, return

gmm22:	lsl xl				;no, calculate index    Z = *gmm18 * 2 + xl * 2
	ldz gmm18*2
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
	rjmp gmm23



gmm1:	.dw mMode*2			;Mode Settings
	.dw mMisc*2			;Misc. Settings
	.dw mServo*2			;Servo Settings
	.dw mGimbl*2			;Gimbal Settings
	.dw mAdv*2			;Advanced Settings
	.dw mInit*2			;Initial Setup
	.dw mRxTst*2			;Receiver Test
	.dw mSensT*2			;Sensor Test
	.dw mUserP*2			;User Profile
	.dw mExGM*2			;Exit Gimbal Mode
	.dw mVer*2			;Version Information
	.dw mLcd*2			;LCD Contrast


gmm18:	.dw ModeSettings
	.dw MiscSettings
	.dw ServoSettings
	.dw GimbalSettings
	.dw AdvancedSettings
	.dw InitialSetup
	.dw RxTest2
	.dw SensorTest
	.dw UserProfileSetup
	.dw GimbalMode
	.dw ShowVersion
	.dw Contrast


