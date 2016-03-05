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

adv2: .db "Channel Mapping", 0
adv3: .db "Sensor Settings", 0
adv4: .db "Mixer Editor", 0, 0
adv5: .db "Board Orientation", 0

_adv_options: .dw adv2*2, adv3*2, adv4*2, adv5*2
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

ef2: .db "Check Motor Outputs", 0
ef3: .db "Gimbal Controller", 0
ef4: .db "View Serial RX Data", 0

_extra_options: .dw ef2*2, ef3*2, ef4*2

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

sbus_dg2settings:
  ret
SBusDG2SwitchSetup:
  safe_call_c sbus_dg2settings
  ret

show_layout:
  ret
MotorLayout:
  safe_call_c show_layout
  ret

; Used in rxmode screen
stdrx:	.db "Standard RX", 0
cppm:	.db "CPPM (aka. PPM)", 0
sbus:	.db "S.Bus", 0
dsm2:	.db "Satellite DSM2", 0, 0
dsmx:	.db "Satellite DSMX", 0, 0

; Used in version screen
modes:	.dw stdrx*2, cppm*2, sbus*2, dsm2*2, dsmx*2

select_rx_mode:
  ret
SelectRxMode:
  safe_call_c select_rx_mode
  ret

/* Initial Setup Screen 
 * Could not make this work in C. Leave it here for now.
const char isp1[] PROGMEM = "INITIAL SETUP";
const char isp5[] PROGMEM = "Select RX Mode";
const char isp4[] PROGMEM = "Trim Battery Voltage";
const char isp3[] PROGMEM = "ACC Calibration";
const char isp2[] PROGMEM = "Load Motor Layout";

const isp10[4] PROGMEM = {
  isp2,
  isp3,
  isp4,
  isp5
};
*/

isp1:  .db "INITIAL SETUP", 0
isp2:  .db "Load Motor Layout", 0
isp3:  .db "ACC Calibration", 0
isp4:  .db "Trim Battery Voltage", 0, 0
isp5:  .db "Select RX Mode", 0, 0
isp10: .dw isp2*2, isp3*2, isp4*2, isp5*2

initial_setup:
  nop
InitialSetup:
  safe_call_c initial_setup
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


asm_LoadMixer:
  safe_called_from_c LoadMixer
  ret

asm_CalibrateSensors:
  safe_called_from_c CalibrateSensors
  ret

asm_AdjustBatteryVoltage:
  safe_called_from_c AdjustBatteryVoltage
  ret

asm_SelectRxMode:
  safe_called_from_c SelectRxMode
  ret
