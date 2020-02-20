;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                              HW4_TIMER_DEFS.inc                            ;
;                             Timer Configuration                            ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the setting values for configuring Timer1A as a PWM timer 
; to control servo motor. 
; 
; CONSTANT INDEX: 
;   CFG_SETNS                 - enable 16-bit counter 
;   CTL_TAEN_SET_MASK         - enable Timer2A and start counting 
;   CTL_TAEN_CLR_MASK         - disable Timer2A
;   IMR_SETNS                 - enable Timer0A interrupt
;   GPT2_TAMR_SETN            - disable time-out interrupt, set Timer2A as PWM
;                                mode and count down
;   TOTAL_PWM_PULSE_FOR_SERVO - for TAILR and TAPR, set servo freq at 50 hz 
;   PWM2A_MATCHR_BASE_VALUE   - for TAMATCHR and TAPMR, set servo shaft at 0 
;                               degree 
;
; REVISION HISTORY:
;     12/09/19  Di Hu      Initial Revision
;     12/28/19  Di Hu      Edited Comments 


    .data
;Timer2A registers 
CFG_SETNS_16BIT             .EQU    0x00000004
                                            ;|
                                            ;0100
                                            ; |
                                            ; CFG: 16BIT_TIMER
CTL_TAEN_CLR_MASK           .EQU    0xFFFFFFFE
                                            ;|
                                            ;1110
                                            ;   |
                                            ;   clear TAEN(Timer A is disabled)
CTL_TAEN_SET_MASK           .EQU    0x00000001
                                            ;|
                                            ;0001
                                            ;   |
                                            ;   set TAEN(Timer A is enabled)
GPT2_TAMR_SETN              .EQU    0x0000180A 
                                         ;||||
                                         ;|
                                         ;0001
                                         ;|  |
                                         ;disable compare operations
                                         ;   |
                                         ;   time-out interrupt are disabled 
                                         ;||||
                                         ; | 
                                         ; 1000
                                         ; |   
                                         ; CCP output pin is set to 1 on 
                                         ;  time-out, interrupt is disabled
                                         ;||||
                                         ;  |
                                         ;  0000
                                         ;  ||||
                                         ;  Snap-shot is disabled 
                                         ;   |||
                                         ;   timer A begins counting as soon as
                                         ;    it is enabled 
                                         ;    ||
                                         ;    match interrupt is disabled
                                         ;     |
                                         ;     the timer counts down 
                                         ;||||
                                         ;   |
                                         ;   1010
                                         ;   |||
                                         ;   PWM mode is enabled 
                                         ;    ||
                                         ;    Edge-count mode
                                         ;     |
                                         ;     Periodic Timer mode  
;constants to set PWM pulse width                                         
TOTAL_PWM_PULSE_FOR_SERVO   .EQU    960000 ; = 20 ms * 48k, 
                                           ; servo motor operates at 50hz freq
                                           ; and CC26x2's system clock is 48mhz
PWM2A_MATCHR_BASE_VALUE     .EQU    888000 ; = (20 - 1.5) ms * 48k, 
                                           ; low pulse width for motor shaft
                                           ; position at 0 degree
