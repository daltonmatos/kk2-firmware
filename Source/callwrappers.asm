; Call wrappers for routines that are called from C

.include "bindwrappers.asm"

; Wrappers to migrated routines

SetDefaultLcdContrast:
  nop

show_version:
  nop
ShowVersion:
  safe_call_c show_version
  ret

advanced_settings:
  nop
AdvancedSettings:
  safe_call_c advanced_settings
  ret

board_rotation:
  nop
BoardRotation:
  safe_call_c board_rotation
  ret

c_contrast:
  nop
Contrast:
  safe_call_c c_contrast
  ret
; Interface to original Assembly Routines

asm_PrintString:
  push_all
  movw r30, r24
  call PrintString
  pop_all
  ret

asm_LcdUpdate:
  safe_called_from_c LcdUpdate
  ret

asm_GetButtonsBlocking:
  push_for_call_return_value
  call GetButtonsBlocking
  clr r25
  mov r24, t
  pop_for_call_return_value
  ret

asm_ShowNoAccessDlg:
  push_all
  movw r30, r24
  call ShowNoAccessDlg
  pop_all
  ret

asm_Print16Signed:
  push_all
  clr xh
  clr yh
  clr r25
  mov xl, r24
  call Print16Signed
  pop_all
  ret

asm_HighlightRectangle:
  lrv PixelType, 0
  safe_called_from_c HilightRectangle
  ret

asm_ChannelMapping:
  safe_called_from_c ChannelMapping
  ret

asm_SensorSettings:
  safe_called_from_c SensorSettings
  ret

asm_MixerEditor:
  safe_called_from_c MixerEditor
  ret

asm_BoardRotation:
  safe_called_from_c BoardRotation
  ret

