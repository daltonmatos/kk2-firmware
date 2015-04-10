
.macro RamVariableEnumerate8

.if RamVariables > 0x0fff
.error "?Out of memory."
.endif

.equ @0 = RamVariables
.set RamVariables=RamVariables+1

.endmacro

.macro setstatusbit
	lds t, StatusBits
	ori t, @0
	sts StatusBits, t
.endmacro

.macro lrv		;load RAM variable immediate
	ldi t, @1
	sts @0, t
.endmacro

.macro PushAll
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8

	push r17
	push r18
	push r19
	push r20
	push r21
	push r22
	push r23
	push r24
	push r25

	push xl
	push xh

	push yl
	push yh

	push zl
	push zh
.endmacro

.macro PopAll
	pop zh
	pop zl

	pop yh
	pop yl

	pop xh
	pop xl

	pop r25
	pop r24
	pop r23
	pop r22
	pop r21
	pop r20
	pop r19
	pop r18
	pop r17

	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
.endmacro

.macro ldx
	ldi xl, low(@0)
	ldi xh, high(@0)
.endmacro
.macro ldy
	ldi yl, low(@0)
	ldi yh, high(@0)
.endmacro
.macro ldz
	ldi zl, low(@0)
	ldi zh, high(@0)
.endmacro

.macro FixedPointVariableEnumerate168

.if RamVariables > 0x0fff
.error "?Out of memory."
.endif

.equ @0 = RamVariables
.set RamVariables = RamVariables + 3

.endmacro

.macro FixedPointVariableEnumerate824

.if RamVariables > 0x0fff
.error "?Out of memory."
.endif

.equ @0 = RamVariables
.set RamVariables = RamVariables + 4

.endmacro

.macro FixedPointVariableEnumerate832

.if RamVariables > 0x0fff
.error "?Out of memory."
.endif

.equ @0 = RamVariables
.set RamVariables = RamVariables + 5

.endmacro

.macro FixedPointVariableEnumerate840

.if RamVariables > 0x0fff
.error "?Out of memory."
.endif

.equ @0 = RamVariables
.set RamVariables = RamVariables + 6

.endmacro

.macro EEVariableEnumerate16

.if EeRegisters > 0x0178
.error "?Out of EEmemory."
.endif

.equ @0 = EeRegisters
.set EeRegisters = EeRegisters + 2

.endmacro

.macro EEVariableEnumerate8

.if EeRegisters > 0x0178
.error "?Out of EEmemory."
.endif

.equ @0 = EeRegisters
.set EeRegisters = EeRegisters + 1

.endmacro

.macro mPrintString
	push zl
	push zh
	ldi zl, low(@0*2)
	ldi zh, high(@0*2)
	call PrintString
	pop zh
	pop zl
.endmacro

.macro brflagtrue
	tst @0
	brmi @1
.endmacro

.macro brflagfalse
	tst @0
	brpl @1
.endmacro



.macro rvbrflagtrue		;RAM Variable macros
	lds t, @0
	tst t
	brmi @1
.endmacro

.macro rvbrflagfalse
	lds t, @0
	tst t
	brpl @1
.endmacro

.macro rvsetflagtrue
	ser t
	sts @0, t
.endmacro

.macro rvsetflagfalse
	clr t
	sts @0, t
.endmacro

.macro setflagtrue
	ser t
	mov @0, t
.endmacro

.macro setflagfalse
	clr @0
.endmacro

.macro rvtest
	lds t, @0
	tst t
.endmacro

.macro rvcpi
	lds t, @0
	cpi t, @1
.endmacro

.macro rvdec
	lds t, @0
	dec t
	sts @0, t
.endmacro

.macro rvinc
	lds t, @0
	inc t
	sts @0, t
.endmacro

.macro rvcp
	lds r0, @0
	lds r1, @1
	cp r0, r1
.endmacro

.macro rvadd
	lds r0, @0
	ldi t, @1
	add r0, t
	sts @0, r0
.endmacro

.macro rvsub
	lds t, @0
	subi t, @1
	sts @0, t
.endmacro

.macro rvmov
	lds t, @1
	sts @0, t
.endmacro

.macro rvflagand
	lds r0, @1
	lds r1, @2
	and r0, r1
	sts @0, r0
.endmacro

.macro rvflagor
	lds r0, @1
	lds r1, @2
	or  r0, r1
	sts @0, r0
.endmacro

.macro rvflageor
	lds r0, @1
	lds r1, @2
	eor r0, r1
	sts @0, r0
.endmacro

.macro rvflagnot
	lds r0, @1
	com r0
	sts @0, r0
.endmacro



.macro longbrlt
	brge pc + 2
	rjmp @0
.endmacro

.macro longbrge
	brlt pc + 2
	rjmp @0
.endmacro



.macro ldzarray			;calculate array address.    @0=array name  @1=cell size  @2=index
	ldi zl, low(@0)
	ldi zh, high(@0)
	ldi t, @1
	mul t, @2
	add zl, r0
	adc zh, r1
.endmacro



.macro debug16
	b16load @0
	call SerOut16
	ldi xl, 0x0d
	call SerByteOut
.endmacro


.macro CheckLimit
	b16load @0
	ldy @1
	ldz @2
	call Limit
	brcc pc + 2
	rjmp @3
.endmacro


.macro pushx
	push xl
	push xh
.endmacro

.macro popx
	pop xh
	pop xl
.endmacro

.macro pushy
	push yl
	push yh
.endmacro

.macro popy
	pop yh
	pop yl
.endmacro

.macro pushz
	push zl
	push zh
.endmacro

.macro popz
	pop zh
	pop zl
.endmacro
