; Call wrappers for routines that are called from C

.include "bindwrappers.asm"

; Wrappers to migrated routines
gimbal_mode:
  nop
GimbalMode:
  safe_call_c gimbal_mode
  ret

esc_calibration_warning:
  nop
EscCalWarning:
  safe_call_c esc_calibration_warning;
  ret

show_confirmation_dlg:
  nop

ShowConfirmationDlg:
  push_for_call_return_value
  clr r1 ;avr-gcc assumes r1 is always 0
  movw r24, r30
  call show_confirmation_dlg
  pop_for_call_return_value
  mov t, r24
  ret

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

c_contrast:
  nop
Contrast:
  safe_call_c c_contrast
  ret

extra_features:
  nop
ExtraFeatures:
  safe_call_c extra_features
  ret


; Interface to original Assembly Routines

asm_PrintChar:
  push_all
  movw t, r24
  call PrintChar
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

asm_MotorCheck:
  safe_called_from_c MotorCheck
  ret  

asm_GimbalMode:
  safe_called_from_c GimbalMode
  ret

asm_SerialDebug:
  safe_called_from_c SerialDebug
  ret

asm_EnforceRestart:
  safe_called_from_c EnforceRestart
  ret
