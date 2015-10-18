#include <avr/io.h>
#include <avr/interrupt.h>

//	jmp reset		; Reset                                     ; 0x7e <_binary_build_kk2___asm_bin_start+0x7e>
//	jmp IsrPitch		; External Interrupt Request 0          ; 0xfc <_binary_build_kk2___asm_bin_start+0xfc>
//	jmp IsrRoll		; External Interrupt Request 1            ; 0xbc <_binary_build_kk2___asm_bin_start+0xbc>
//	jmp unused		; External Interrupt Request 2            ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; Pin Change Interrupt Request 0          ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp IsrYawAux		; Pin Change Interrupt Request 1        ; 0x18e <_binary_build_kk2___asm_bin_start+0x18e>
//	jmp unused		; Pin Change Interrupt Request 2          ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp IsrThrottleCppm	; Pin Change Interrupt Request 3    ; 0x13c <_binary_build_kk2___asm_bin_start+0x13c>
//	jmp unused		; Watchdog Time-out Interrupt             ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; Timer/Counter2 Compare Match A          ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; Timer/Counter2 Compare Match B          ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp IsrPwmQuiet		; Timer/Counter2 Overflow             ; 0x9b2 <_binary_build_kk2___asm_bin_start+0x9b2>
//	jmp unused		; Timer/Counter1 Capture Event            ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp IsrPwmStart		; Timer/Counter1 Compare Match A      ; 0x53a <_binary_build_kk2___asm_bin_start+0x53a>
//	jmp IsrPwmEnd		; Timer/Counter1 Compare Match B        ; 0x5a0 <_binary_build_kk2___asm_bin_start+0x5a0>
//	jmp unused		; Timer/Counter1 Overflow                 ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; Timer/Counter0 Compare Match A          ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; Timer/Counter0 Compare Match B          ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp IsrLed		; Timer/Counter0 Overflow                 ; 0xa1a <_binary_build_kk2___asm_bin_start+0xa1a>
//	jmp unused		; SPI Serial Transfer Complete            ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp IsrSerialRx		; USART0, Rx Complete                 ; 0xd42 <_binary_build_kk2___asm_bin_start+0xd42>
//	jmp unused		; USART0 Data register Empty              ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; USART0, Tx Complete                     ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; Analog Comparator                       ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; ADC Conversion Complete                 ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; EEPROM Ready                            ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; 2-wire Serial Interface                 ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; Store Program Memory Read               ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; USART1 RX complete                      ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; USART1 Data Register Empty              ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>
//	jmp unused		; USART1 TX complete                      ; 0x7c <_binary_build_kk2___asm_bin_start+0x7c>

extern void IsrPitch();
extern void IsrRoll();
extern void IsrYawAux();
extern void IsrThrottleCppm();
extern void IsrPwmQuiet();
extern void IsrPwmStart();
extern void IsrPwmEnd();
extern void IsrLed();
extern void IsrSerialRx();
extern void reset();

ISR(INT0_vect, ISR_NAKED){
  IsrPitch();
}

ISR(INT1_vect, ISR_NAKED){
  IsrRoll();
}

ISR(PCINT1_vect, ISR_NAKED){
  IsrYawAux();
}

ISR(PCINT3_vect, ISR_NAKED){
  IsrThrottleCppm();
}

ISR(TIMER2_OVF_vect, ISR_NAKED){
  IsrPwmQuiet();
}

ISR(TIMER1_COMPA_vect, ISR_NAKED){
  IsrPwmStart();
}

ISR(TIMER1_COMPB_vect, ISR_NAKED){
  IsrPwmEnd();
}

ISR(TIMER0_OVF_vect, ISR_NAKED){
  IsrLed();
}

ISR(USART0_RX_vect, ISR_NAKED){
  IsrSerialRx();
}

int main(){
  reset();
}
