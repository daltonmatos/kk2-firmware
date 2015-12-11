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

mode_settings:
  nop
ModeSettings:
  safe_call_c mode_settings
  ret

sensor_settings:
  nop
SensorSettings:
  safe_call_c sensor_settings
  ret

selflevel_settings:
  nop
SelflevelSettings:
  safe_call_c selflevel_settings
  ret

stick_scaling:
  nop
StickScaling:
  safe_call_c stick_scaling
  ret

misc_settings:
  nop
MiscSettings:
  safe_call_c misc_settings
  ret
; Interface to original Assembly Routines
asm_get_mpu_register:
  push_for_call_return_value
  mov t, r24
  sts TWI_address, t
  call i2c_read_adr
  clr r25
  mov r24, t
  pop_for_call_return_value
  ret

asm_setup_mpu6050:
  safe_called_from_c setup_mpu6050
  ret

asm_PrintChar:
  push_all
  movw t, r24
  call PrintChar
  pop_all
  ret

asm_GetButtonsBlocking:
  push_for_call_return_value
  call GetButtonsBlocking
  clr r25
  mov r24, t
  pop_for_call_return_value
  ret

asm_NumEdit:
; num=r25:r24
; min=r23:r22
; max=r21:r20
; NumEdit expects:
; num=xh:xl
; min=yh:yl
; max=zh:zl
; return in r1:r0
  push_r2_to_r17_r28_r29
  push_r18_to_r27_r30_r31

  mov xh, r25
  mov xl, r24
  mov yh, r23
  mov yl, r22
  mov zh, r21
  mov zl, r20
  call NumberEdit
  
  pop_r18_to_r27_r30_r31
  pop_r2_to_r17_r28_r29

  mov r25, r1
  mov r24, r0
  clr r1
  ret

asm_ReleaseButtons:
  safe_called_from_c ReleaseButtons
  ret

asm_HighlightRectangle:
  safe_called_from_c HilightRectangle
  ret

asm_Rectangle:
  safe_called_from_c Rectangle
  ret

asm_ChannelMapping:
  safe_called_from_c ChannelMapping
  ret

asm_MixerEditor:
  safe_called_from_c MixerEditor
  ret

asm_MotorCheck:
  safe_called_from_c MotorCheck
  ret  

asm_SerialDebug:
  safe_called_from_c SerialDebug
  ret

asm_EnforceRestart:
  safe_called_from_c EnforceRestart
  ret
