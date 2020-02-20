;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                              HW2_TIMER_DEFS.inc                            ;
;                             Timer Configuration                            ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the setting values for configuring Timer0B, Timer1A,
; and Timer1B to time delays for LCD routines.  
; 
; CONSTANT INDEX: 
;   CFG_SETNS - enable 16-bit counter 
;   CTL_SETNS - enable Timer0A and start counting 
;   IMR_SETNS - enable Timer0A interrupt
;   TAMR_SETN - enable time-out interrupt and count down setting for Timer0A 
;   TAILR_SETNS - configure Timer0A to have interrupt every 1 ms  
;
; REVISION HISTORY:
;     11/25/19  Di Hu      Initial Revision
;     12/27/19  Di Hu      Added comments

    .data

CFG_SETNS_16BIT         .EQU    0x00000004
                                        ;|
                                        ;0100
                                        ; |
                                        ; CFG: 16BIT_TIMER
CTL_TAEN_MASK           .EQU    0x00000001
                                        ;|
                                        ;0001
                                        ;   |
                                        ;   GPT timer A enable bit  
CTL_TBEN_MASK           .EQU    0x00000100
                                      ;|
                                      ;0001
                                      ;   |
                                      ;   GPT timer B enable 
CTL_SETNS_T0B_EN        .EQU    0x00000300
                                      ;|
                                      ;0011
                                      ;  ||
                                      ;  Freezes counting when processes is 
                                      ;  halted by the debugger  
                                      ;   |
                                      ;   Timer B is enabled and starts counting
CTL_SETNS_T1A_EN        .EQU    0x00000003
                                        ;|
                                        ;0011
                                        ;  ||
                                        ;  Freezes counting when processes is 
                                        ;  halted by the debugger  
                                        ;   |
                                        ;   Timer A is enabled and starts counting
CTL_SETNS_T1B_EN        .EQU    0x00000300
                                      ;|
                                      ;0011
                                      ;  ||
                                      ;  Freezes counting when processes is 
                                      ;  halted by the debugger  
                                      ;   |
                                      ;   Timer B is enabled and starts counting
GPT0_TBMR_SETN          .EQU    0x00000001
                                     ;   |
                                     ;   0001
                                     ;     |
                                     ;     TBMR: One-Shot Timer mode
                                     ;  interrupt is disabled 
GPT1_TAMR_SETN          .EQU    0x00000001
                                     ;   |
                                     ;   0001
                                     ;     |
                                     ;     TAMR: One-Shot Timer mode
                                     ;  interrupt is disabled 
GPT1_TBMR_SETN          .EQU    0x00000001
                                     ;   |
                                     ;   0001
                                     ;     |
                                     ;     TBMR: One-Shot Timer mode
                                     ;  interrupt is disabled 
CLR_TBTOCINT            .EQU    0x00000100
                                      ;|
                                      ;0001
                                      ;   |
                                      ;   clear timer B interrupt (TATOCINT)
CLR_TATOCINT            .EQU    0x00000001
                                        ;|
                                        ;0001
                                        ;   |
                                        ;   clear timer A interrupt (TATOCINT)