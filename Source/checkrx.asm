

CheckRx:

	b16clr Temp
	b16cmp CheckRxDelay, Temp
	breq che1

	b16dec CheckRxDelay
	ret

che1:	lds xl, StatusBits
	rvbrflagtrue flagRollValid, che2
	ori xl, NoAileronInput

che2:	rvbrflagtrue flagPitchValid, che3
	ori xl, NoElevatorInput

che3:	rvbrflagtrue flagThrottleValid, che4
	ori xl, NoThrottleInput

che4:	rvbrflagtrue flagYawValid, che5
	ori xl, NoRudderInput

che5:	sts StatusBits, xl
	ret

