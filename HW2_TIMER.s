;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                HW2_Timer.s                                 ;
;                            Timer Configurations                            ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains functions for configuring Timer0A to call keypad scan 
; functions in timer interrupt every 1 ms. 
;
; FUNCTION INDEX: 
;   ConfigTimer0A - configure Timer0A to be in periodic mode with interrupt
;                   enabled  
;
; REVISION HISTORY:
;     11/10/19  Di Hu      Initial Revision
;     11/21/19  Di Hu      Added comments
;	  11/25/19  Di Hu 	   Added ".text" and debugged hard fault

;   .include files 
    .include "HW2_CC26x2_DEFS.inc"
    .include "HW2_TIMER_DEFS.inc"
    .include "HW2_MACROS.inc"
;   public functions 
    .global ConfigTimer0A

	.text
; ConfigTimer0A
;
; Description:       This function Configures Timer0A to count down 
;                    periodically and generate interrupt about every ms.        
;
; Operation:         This function configures CFG, CTL, IMR, TAMR, TAILR and 
;                    TAPR registers of Timer 0. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   R1 - contains base address for GPT0 module 
; Shared Variables:  None. 
;
; Input:             None. 
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0, R1
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Nov 22, 2019
ConfigTimer0A:                       ;config IO pins
    MV32 R1, #GPT0_BASE_ADDR
    MOV R0, #CFG_SETNS                  
    STR R0, [R1, #CFG_ADDR_OFFSET]      ;enable 16-bit counter 
    MOV R0, #CTL_SETNS                  
    STR R0, [R1, #CTL_ADDR_OFFSET]      ;enable Timer0A
    MOV R0, #IMR_SETNS                  
    STR R0, [R1, #IMR_ADDR_OFFSET]      ;enable interrupt 
    MOV R0, #TAMR_SETN                  
    STR R0, [R1, #TAMR_ADDR_OFFSET]     ;enable time out interrupt and 
                                        ;   set counter to count down 
    MV32 R0, #TAILR_SETNS               
    STR R0, [R1, #TAILR_ADDR_OFFSET]    ;configure interrupt rate 
    MOV R0, #TAPR_SETNS                 ;with load value in TAILR 
    STR R0, [R1, #TAPR_ADDR_OFFSET]     ;and prescaler value in TAPR
    
    BX LR

