


	;--- Put serial RX data into a buffer ---

IsrSerialRx:

	in SregSaver, sreg

  push tt
	push zh
	push zl

	;Read and store data
	lds treg, udr0			;read from USART buffer

	lds zl, RxBufferAddressL	;save the received data byte in the buffer
	lds zh, RxBufferAddressH
	st z+, treg

	;Update buffer index
	lds treg, RxFrameLength
	lds tt, RxBufferIndex
	inc tt
	cp tt, treg
	brlt isr20

	ldz RxBuffer0
	clr tt

isr20:	sts RxBufferIndex, tt

	;Save the buffer pointer
	sts RxBufferAddressL, zl
	sts RxBufferAddressH, zh

	;Exit
	pop zl
	pop zh
  pop tt
	out sreg, SregSaver
	reti



	;--- Clear buffer ---

ClearSerialBuffer:

	ldi t, 25
	ldi xl, 0
	ldz RxBuffer0

csb1:	st z+, xl
	dec t
	brne csb1

	ret
