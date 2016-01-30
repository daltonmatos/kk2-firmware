.include "m644Pdef.inc"
.include "miscmacros.inc"
.include "168mathlib_macros.inc"
.include "168mathlib_subs.asm"
.include "variables.asm"
.include "bindwrappers.asm"

load_temp:
  push_all
  b16ldi Temp, 9.0
  pop_all
  ret

