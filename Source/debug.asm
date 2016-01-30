.include "m644Pdef.inc"
.include "miscmacros.inc"
.include "168mathlib_macros.inc"
.include "168mathlib_subs.asm"
.include "variables.asm"
.include "bindwrappers.asm"

load_temp:
  push_all
  b16ldi Temp, -12.77
  pop_all
  ret

