

MainMenu:

men23:	ldy men1*2

	lds xl, MainMenuListYposSave
	lds xh, MainMenuCursorYposSave

	ldi t, 20			;number of menu items
	call Menu

	sts MainMenuListYposSave, yl
	sts MainMenuCursorYposSave, yh

	brcs men22			;BACK pressed?

	ret				;yes, return

men22:	lsl xl				;no, calculate index    Z = *men18 * 2 + xl * 2
	ldz men18*2
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
	rjmp men23



men1:	.dw mQTun*2			;Quick Tuning
	.dw mPIEd*2			;PI Editor
	.dw mSLvl*2			;Self-level Settings
	.dw mSS*2			;Stick Scaling
	.dw mMode*2			;Mode Settings
	.dw mMisc*2			;Misc. Settings
	.dw mServo*2			;Servo Settings
	.dw mGimbl*2			;Gimbal Settings
	.dw mAdv*2			;Advanced Settings
	.dw mExp*2			;Expert Settings
	.dw mAux*2			;AUX Switch Setup
	.dw mInit*2			;Initial Setup
	.dw mRxTst*2			;Receiver Test
	.dw mSensT*2			;Sensor Test
	.dw mMLay*2			;Show Motor Layout
	.dw mUserP*2			;User Profile
	.dw mExtra*2			;Extra Features
	.dw mECal*2			;ESC Calibration
	.dw mVer*2			;Version Information
	.dw mLcd*2			;LCD Contrast


men18:	.dw QuickTuning
	.dw PiEditor
	.dw SelflevelSettings
	.dw StickScaling
	.dw ModeSettings
	.dw MiscSettings
	.dw ServoSettings
	.dw GimbalSettings
	.dw AdvancedSettings
	.dw ExpertSettings
	.dw AuxSwitchSetup
	.dw InitialSetup
	.dw RxTest
	.dw SensorTest
	.dw MotorLayout
	.dw UserProfileSetup
	.dw ExtraFeatures
	.dw EscCalWarning
	.dw ShowVersion
	.dw Contrast


