

#define lcd_cs1		portd, 5
#define lcd_res		portd, 6
#define lcd_a0		portd, 7
#define	lcd_scl		portd, 4
#define	lcd_si		portd, 1

#define LedOn		sbi portb, 3
#define LedOff		cbi portb, 3
#define LedToggle	sbi pinb, 3

#define BuzzerOn	sbi portb, 1
#define BuzzerOff	cbi portb, 1

#define OutputPin1	portc, 6
#define OutputPin2	portc, 4
#define OutputPin3	portc, 2
#define OutputPin4	portc, 3
#define OutputPin5	porta, 4
#define OutputPin6	porta, 5
#define OutputPin7	portc, 5
#define OutputPin8	portc, 7

//#define DebugOutputPin	portb, 0

#define LvaOutputPin	portb, 2

#define DigitalOutPin	portb, 0
