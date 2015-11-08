; Call wrappers for routines that are called from C

.include "bindwrappers.asm"


asm_PrintString:
  safe_called_from_c PrintString
  ret

asm_LcdUpdate:
  safe_called_from_c LcdUpdate
  ret
