;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                              HW2_TIMER_DEFS.inc                            ;
;                             Timer Configuration                            ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the setting values for configuring Timer0A. 
; 
; CONSTANT INDEX: 
;   CFG_SETNS - enable 16-bit counter 
;   CTL_SETNS - enable Timer0A and start counting 
;   IMR_SETNS - enable Timer0A interrupt
;   TAMR_SETN - enable time-out interrupt and count down setting for Timer0A 
;   TAILR_SETNS - configure Timer0A to have interrupt every 1 ms  
;
; REVISION HISTORY:
;     11/10/19  Di Hu      Initial Revision
;     11/22/19  Di Hu      Added comments;

    .data
;configure Timer0A for interrupt for keypad scan functions 
CFG_SETNS       .EQU    0x00000004
                                ;|
                                ;0100(CFG: 16BIT_TIMER)
CTL_SETNS       .EQU    0x00000001
                                ;|
                                ;0001(TAEN: Timer A is enabled
                                ;     and begins counting or the
                                ;     capture logic is enabled
                                ;     based on the CFG register.)
IMR_SETNS       .EQU    0x00000001
                                ;|
                                ;0001(TATOIM: Enabling this bit
                                ;     will make the RIS.TATORIS
                                ;     interrupt propagate to
                                ;     MIS.TATOMIS.)
TAMR_SETN       .EQU    0x00000002
                             ;| ||
                             ;0000(TACINTD: Time-out interrupt as normal)
                             ;  ||
                             ;  0000(TACDIR: The timer counts down.)
                             ;   |
                             ;   0010(TAMR: Periodic Timer mode)
TAILR_SETNS     .EQU    48000   ;for a 1KHz timer interrupt(every ms),
                                ; since the main system clock is 48MHz
                                ; and no prescaler is needed
TAPR_SETNS      .EQU    0       ;no prescaler is needed

