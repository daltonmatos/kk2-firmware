
HeightDampening:


	b16mul Temp, AccZfilter, HeightDampeningGain	;gain

	b16mov Temper, HeightDampeningLimit	;limit
	b16cmp Temp, Temper
	brlt hgt1
	b16mov Temp, Temper
hgt1:	b16neg Temper
	b16cmp Temp, Temper
	brge hgt2
	b16mov Temp, Temper
hgt2:	
	b16sub RxThrottle, RxThrottle, Temp	;command

	ret




