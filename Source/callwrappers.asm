; Call wrappers for routines that are called from C

.include "bindwrappers.asm"

safe_Main:
  safe_called_from_c Main
  ret

safe_CppmMain:
  safe_called_from_c CppmMain
  ret

safe_SBusMain:
  safe_called_from_c SBusMain
  ret

safe_SatelliteMain:
  safe_called_from_c SatelliteMain
  ret
