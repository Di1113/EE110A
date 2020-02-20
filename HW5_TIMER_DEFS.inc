;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                              HW5_TIMER_DEFS.inc                            ;
;                             Timer Configuration                            ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains setting values for configuring Timer2B as a periodic timer
; for generating interrupts and configuring Timer3A and Timer3B as PWM timers 
; for stepper control. 
; 
; CONSTANT INDEX: 
;   CFG_SETNS                 - enable 16-bit counter 
;   CTL_TAEN_SET_MASK         - enable Timer A and start counting 
;   CTL_TAEN_CLR_MASK         - disable Timer A
;   CTL_TBEN_SET_MASK         - enable Timer B and start counting 
;   CTL_TBEN_CLR_MASK         - disable Timer B
;   TBTOCINT_CLR_MASK         - clear time-out interrupt flag for next interrupt
;   GPT2_TBMR_SETN            - enable time-out interrupt, set Timer2B as a 
;                               periodic timer that counts down. 
;   GPT3_TAMR_SETN            - disable time-out interrupt, set Timer3A as PWM
;                               mode that counts down
;   GPT3_TBMR_SETN            - disable time-out interrupt, set Timer3B as PWM
;                               mode that counts down
;   IMR_SETNS_TB2             - enable Timer2B time-out interrupt
;   TOTAL_PWM_PULSE_FOR_STEPPER
;                             - for Timer3's TAILR and TAPR, and TBILR and TBPR
;                               set stepper freq at 50 hz 
;   STEPPER_STEP_PERIOD       - for Timer2's TBILR and TBPR, set interrupt rate 
;
; REVISION HISTORY:
;     12/17/19  Di Hu      Initial Revision
;     12/31/19  Di Hu      Edited comments 


    .data

;configure Timer2B for interrupt and Timer3A, Timer3B for stepper control. 
CFG_SETNS_16BIT                 .EQU    0x00000004
                                                ;|
                                                ;0100
                                                ; |
                                                ; CFG: 16BIT_TIMER
CTL_TAEN_MASK                   .EQU    0x00000001
                                                ;|
                                                ;0001
                                                ;   |
                                                ;   GPT timer A enable bit 
CTL_TAEN_CLR_MASK               .EQU    0xFFFFFFFE
                                                ;|
                                                ;1110
                                                ;   |
                                                ;   clear TAEN
                                                ;   Timer A is disabled
CTL_TAEN_SET_MASK               .EQU    0x00000001
                                                ;|
                                                ;0001
                                                ;   |
                                                ;   set TAEN
                                                ;   Timer A is enabled
CTL_TBEN_CLR_MASK               .EQU    0xFFFFFEFF
                                              ;|
                                              ;1110
                                              ;   |
                                              ;   clear TBEN
                                              ;   Timer B is disabled
CTL_TBEN_SET_MASK               .EQU    0x00000100
                                              ;|
                                              ;0001
                                              ;   |
                                              ;   set TBEN
                                              ;   Timer B is enabled
TBTOCINT_CLR_MASK               .EQU    0x00000100
                                              ;|
                                              ;0001
                                              ;   |
                                              ;   clear RIS.TBTORIS and
                                              ;   MIS.TBTOMIS
                                              ;   Timer B interrupt cleared
CLR_TATOCINT                    .EQU    0x00000001
                                                ;|
                                                ;0001
                                                ;   |
                                                ;   clear timer A interrupt (TATOCINT)
GPT1_TAMR_SETN                  .EQU    0x00000001
                                             ;   |
                                             ;   0001
                                             ;     |
                                             ;     TAMR: One-Shot Timer mode
                                             ;  interrupt is disabled 
GPT2_TBMR_SETN                  .EQU    0x00000002
                                                ;|
                                                ;0010
                                                ;  |
                                                ;  Periodic Timer mode 
                                                ;  sets up a periodic down counter
                                                ;  with interrupts enabled
GPT3_TAMR_SETN                  .EQU    0x0000180A
                                             ;|| |
                                             ;0001
                                             ; | |
                                             ; | Time-out interrupt are disabled
                                             ; 1000
                                             ; | |
                                             ; CCP output pin is set to 1 on
                                             ;  time-out
                                             ;   |
                                             ;   1010
                                             ;   |||
                                             ;   PWM mode is enabled
                                             ;    ||
                                             ;    Edge-Count mode
                                             ;     |
                                             ;     Periodic Timer mode 
                                             ; TAMR sets up a PWM down counter
                                             ; with the output starting high and
                                             ; with interrupts disabled.
GPT3_TBMR_SETN                  .EQU    0x0000180A 
                                             ;|| |
                                             ;0001
                                             ; | |
                                             ; | Time-out interrupt are disabled
                                             ; 1000
                                             ; | |
                                             ; CCP output pin is set to 1 on
                                             ;   time-out
                                             ;   |
                                             ;   1010
                                             ;   |||
                                             ;   PWM mode is enabled
                                             ;    ||
                                             ;    Edge-Count mode
                                             ;     |
                                             ;     Periodic Timer mode  
                                             ; TBMR sets up a PWM down counter
                                             ; with the output starting high
                                             ; and with interrupts disabled.
IMR_SETNS_TB2                   .EQU    0x00000100
                                              ;|
                                              ;0001(asserts interrupt when a
                                              ;     one-shot or periodic mode 
                                              ;     timer reaches its count 
                                              ;     limit TBTOIM: Enabling 
                                              ;     this bit will make the 
                                              ;     RIS.TBTORIS interrupt 
                                              ;     propagate to MIS.TBTOMIS.)
;constants for setting TAILR and TBILR                                               
TOTAL_PWM_PULSE_FOR_STEPPER     .EQU    960000  ;stepper moves at 50hz frequency
                                                ;   every full step takes 20ms
                                                ;   = 20 * 48000 clocks 
STEPPER_STEP_PERIOD             .EQU    320000  ;interrupt rate is 20/3 ms, 
                                                ;since 20 ms is a full step 
                                                ;                (18 degrees)
                                                ;and each micro step during 
                                                ;interrupt is 6 degrees 
