;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                HW4_TIMER.s                                 ;
;                            Timer Configurations                            ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains a function that initializes Timer2A as a PWM timer and 
; initializes servo motor's shaft to be at 0 degree. 
;
; FUNCTION INDEX: 
;   InitPWMTimer2A - initialize Timer2A as a PWM timer and sets servo motor's
;                    shaft at 0 degree
;
; REVISION HISTORY:
;     12/09/19  Di Hu      Initial Revision
;     12/14/19  Di Hu      Added immediate value for TAMATCHR, instead of having
;                          immediate value for ratation degrees
;     12/28/19  Di Hu      Edited comments 

;   .include files 
    .include "HW4_CC26x2_DEFS.inc"
    .include "HW4_TIMER_DEFS.inc"
    .include "HW4_MACROS.inc"

;   public functions 
    .global InitPWMTimer2A


    .text
; code starts 

; InitPWMTimer2A
;
; Description:       This function configures Timer2A as a PWM timer with time-
;                    out interrupt disabled and configured to count down. This
;                    function also initializes servo shaft to be at 0 position
;                    with TAILR, TAPR and TAMATCHR, TAPMR.
;
; Operation:         This function configures CFG, CTL, TAMR, TAILR and 
;                    TAPR and TAMATCHR, TAPMR registers of Timer 2. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None.
; Shared Variables:  None. 
;
; Input:             None. 
; Output:            Servo shaft is set to 0 degree position.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0, R1, R2
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Dec 09, 2019
InitPWMTimer2A:      
    MV32 R1, #GPT2_BASE_ADDR
    
    LDR R0, [R1, #CTL_ADDR_OFFSET]
    MV32 R2, #CTL_TAEN_CLR_MASK 
    AND R0, R0, R2     
    STR R0, [R1, #CTL_ADDR_OFFSET]      ;disable timer 2A for configuration 
    
    MOV R0, #CFG_SETNS_16BIT            
    STR R0, [R1, #CFG_ADDR_OFFSET]      ;enable 16-bit counter 

    MOV R0, #GPT2_TAMR_SETN
    STR R0, [R1, #TAMR_ADDR_OFFSET]     ;set PWM mode with interrupt disabled
                                        ; and set to count down 

    MV32 R0, #TOTAL_PWM_PULSE_FOR_SERVO 
    MOV R2, #LOWER_HALFWORD_MASK
    AND R0, R0, R2
    STR R0, [R1, #TAILR_ADDR_OFFSET]    ;set servo shaft movement frequency

    MV32 R0, #TOTAL_PWM_PULSE_FOR_SERVO
    LSR R0, R0, #LSR_SIXTEEN
    STR R0, [R1, #TAPR_ADDR_OFFSET]     ;prescaler for TAILR 

    MV32 R0, #PWM2A_MATCHR_BASE_VALUE
    MOV R2, #LOWER_HALFWORD_MASK
    AND R0, R0, R2
    STR R0, [R1, #TAMATCHR_ADDR_OFFSET] ;set servo shaft to be at 0 degree 

    LSR R0, R0, #LSR_SIXTEEN
    STR R0, [R1, #TAPMR_ADDR_OFFSET]    ;prescaler for TAPMR

    LDR R0, [R1, #CTL_ADDR_OFFSET]
    ORR R0, R0, #CTL_TAEN_SET_MASK
    STR R0, [R1, #CTL_ADDR_OFFSET]      ;enable PWM Timer2A

    BX LR 

