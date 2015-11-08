; Call wrappers for routines that are called from C

.include "bindwrappers.asm"


asm_PrintString:
  push_all
  movw r30, r24
  call PrintString
  pop_all
  ret

asm_LcdUpdate:
  safe_called_from_c LcdUpdate
  ret
  
