;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                HW5_TIMER.s                                 ;
;                            Timer Configurations                            ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains functions for configuring
;
; FUNCTION INDEX: 
;     InitPeriodicTimer2B - configure Timer2B as a periodic timer to generate 
;                           interrupts for making micro steps one each interrupt
;     InitPWMTimer3A      - configure Timer3A as a PWM timer to control stepper
;                           with Timer3B 
;     InitPWMTimer3B      - configure Timer3B as a PWM timer to control stepper
;                           with Timer3A 
; REVISION HISTORY:
;     12/17/19  Di Hu      Initial Revision
;     12/31/19  Di Hu      Edited comments 

;   .include files 
    .include "HW5_CC26x2_DEFS.inc"
    .include "HW5_TIMER_DEFS.inc"
    .include "HW5_MACROS.inc"

;   public functions 
    .global InitOneShotTimer1A      ;for macro DELAY_ONE_SEC used in main
    .global StartTimer1ACounter     ;for macro DELAY_ONE_SEC used in main
    .global WaitTillCountingDoneT1A ;for macro DELAY_ONE_SEC used in main
    .global InitPeriodicTimer2B     ;for micro-stepping 
    .global InitPWMTimer3A          ;for controlling stepper 
    .global InitPWMTimer3B          ;for controlling stepper 


    .text
; code starts 


; InitOneShotTimer1A
;
; Description:       This function configures Timer0A as a 16-bit one-shot  
;                    timer that counts down clocks with interrupt disabled. 
;
; Operation:         This function configures CFG, TAMR and IMR registers.
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None.
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
; Registers Changed: R0, R1, R2
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Dec 27, 2019
InitOneShotTimer1A:   ;config Timer1A as an one-shot timer for counting delays
    MV32 R2, #GPT1_BASE_ADDR
    
    MOV R12, #CFG_SETNS_16BIT            
    STR R12, [R2, #CFG_ADDR_OFFSET]      ;enable 16-bit counter 
    
    MOV R12, #GPT1_TAMR_SETN                  
    STR R12, [R2, #TAMR_ADDR_OFFSET]     ;set one-shot mode and 
                                         ; set counter to count down
    
    LDR R12, [R2, #IMR_ADDR_OFFSET]
    MOV R3, #0
    AND R12, R12, R3
    STR R12, [R2, #IMR_ADDR_OFFSET]      ;disable interrupt for Timer1A
    BX LR 


; StartTimer1ACounter(clks, preclks)
;
; Description:       This function enables Timer1A to count down the passed-in
;                    clock counter size.      
;
; Operation:         This function starts delays by setting the passed-in clock 
;                    counter size to TAILR and TBPR registers, and enabling 
;                    Timer1A in CTL register. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None. 
; Shared Variables:  R0 - Timer1A clock counter size (low 16 bits).  
;                    R1 - Prescaler for Timer1A counter value (high 8 bits). 
;
; Input:             None. 
; Output:            None.
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
; Last Modified:     Nov 26, 2019
StartTimer1ACounter:
    MV32 R2, #GPT1_BASE_ADDR
    ; passed in parameters: R0 -> counter value; R1 -> prescaler value                
    STR R0, [R2, #TAILR_ADDR_OFFSET] ;configure counter value for counting delays
    STR R1, [R2, #TAPR_ADDR_OFFSET]     
    
    LDR R12, [R2, #CTL_ADDR_OFFSET]
    ORR R12, R12, #CTL_TAEN_SET_MASK
    STR R12, [R2, #CTL_ADDR_OFFSET]  ;enable Timer1A and start counting

    BX LR


; WaitTillCountingDoneT1A
;
; Description:       This function checks if counting is done in the one-shot
;                    Timer1A and loops till counting is done.      
;
; Operation:         This function checks if the timer enable bit is set in 
;                    CTL registers to check if counting is done, and clears the
;                    interrupt flag(set when counting is done) after  
;                    counting(/looping) is finished.
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None. 
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
; Registers Changed: R0, R1, R2
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Nov 26, 2019
WaitTillCountingDoneT1A:
    MV32 R2, #GPT1_BASE_ADDR

CheckT1ACountingDone:
    LDR R12, [R2, #CTL_ADDR_OFFSET]
    ANDS R3, R12, #CTL_TAEN_MASK        ;check if counting is done 
    BNE CheckT1ACountingDone            ;still counting 
    ;BEQ CountingDone -> clear interrupt and return 
T1ACountingDone:
    MOV R0, #CLR_TATOCINT
    STR R0, [R2, #ICLR_ADDR_OFFSET]

    BX LR 


; InitPeriodicTimer2B
;
; Description:       This function configures Timer2B to count down 
;                    periodically and generate interrupt to make one micro step.        
;
; Operation:         This function configures CFG, CTL, IMR, TBMR, TBILR and 
;                    TBPR registers of Timer 2 to configure Timer2B to generate
;                    interrupts. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   R1 - contains base address for GPT2 module 
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
; Registers Changed: R0, R1, R2 
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Dec 17, 2019
InitPeriodicTimer2B:                       
    MV32 R1, #GPT2_BASE_ADDR

    LDR R0, [R1, #CTL_ADDR_OFFSET]
    MV32 R2, #CTL_TBEN_CLR_MASK 
    AND R0, R0, R2     
    STR R0, [R1, #CTL_ADDR_OFFSET]      ;disable timer 2B
    
    MOV R0, #CFG_SETNS_16BIT                  
    STR R0, [R1, #CFG_ADDR_OFFSET]      ;enable 16-bit counter 

    MOV R0, #IMR_SETNS_TB2                  
    STR R0, [R1, #IMR_ADDR_OFFSET]      ;enable interrupt 

    MOV R0, #GPT2_TBMR_SETN                  
    STR R0, [R1, #TBMR_ADDR_OFFSET]     ;enable time out interrupt and 
                                        ;   set counter to count down 

    MV32 R0, #STEPPER_STEP_PERIOD       
    MOV R2, #BOTTOM_HALFWORD_MASK
    AND R0, R0, R2
    STR R0, [R1, #TBILR_ADDR_OFFSET]    ;configure interrupt rate(low 16 bits)

    MV32 R0, #STEPPER_STEP_PERIOD
    LSR R0, R0, #LSR_SIXTEEN
    STR R0, [R1, #TBPR_ADDR_OFFSET]     ;configure interrupt rate(high 8 bits)
    
    LDR R0, [R1, #CTL_ADDR_OFFSET]
    ORR R0, R0, #CTL_TBEN_SET_MASK
    STR R0, [R1, #CTL_ADDR_OFFSET]      ;enable PWM Timer2B

    BX LR


; InitPWMTimer3A
;
; Description:       This function configures Timer3A as a PWM timer with 
;                    time-out interrupt disabled and configured to count down. 
;                    PWM Timer3A controls step motor with PWM Timer3B. 
;
; Operation:         This function configures CFG, CTL, TAMR, TAILR and 
;                    TAPR registers of Timer 3. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None.
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
; Registers Changed: R0, R1, R2
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Dec 17, 2019
InitPWMTimer3A:                    
    MV32 R1, #GPT3_BASE_ADDR
        
    LDR R0, [R1, #CTL_ADDR_OFFSET]
    MV32 R2, #CTL_TAEN_CLR_MASK 
    AND R0, R0, R2     
    STR R0, [R1, #CTL_ADDR_OFFSET]      ;disable timer 3A
    
    MOV R0, #CFG_SETNS_16BIT            
    STR R0, [R1, #CFG_ADDR_OFFSET]      ;enable 16-bit counter 

    MOV R0, #GPT3_TAMR_SETN
    STR R0, [R1, #TAMR_ADDR_OFFSET]     ;disable time-out interrupt and set 
                                        ;   Timer3A as a count-down PWM timer 

    MV32 R0, #TOTAL_PWM_PULSE_FOR_STEPPER 
    MOV R2, #BOTTOM_HALFWORD_MASK
    AND R0, R0, R2
    STR R0, [R1, #TAILR_ADDR_OFFSET]    ;set stepper motor movement frequency
                                        ;   (low 16 bits)

    MV32 R0, #TOTAL_PWM_PULSE_FOR_STEPPER
    LSR R0, R0, #LSR_SIXTEEN
    STR R0, [R1, #TAPR_ADDR_OFFSET]     ;set stepper motor movement frequency
                                        ;   (high 8 bits, prescaler for TAILR)  

    LDR R0, [R1, #CTL_ADDR_OFFSET]
    ORR R0, R0, #CTL_TAEN_SET_MASK
    STR R0, [R1, #CTL_ADDR_OFFSET]      ;enable PWM Timer3A

    BX LR 


; InitPWMTimer3B
;
; Description:       This function configures Timer3B as a PWM timer with 
;                    time-out interrupt disabled and configured to count down. 
;                    PWM Timer3B controls step motor with PWM Timer3A. 
;
; Operation:         This function configures CFG, CTL, TBMR, TBILR and 
;                    TBPR registers of Timer 3. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None.
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
; Registers Changed: R0, R1, R2
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Dec 17, 2019
InitPWMTimer3B:                   
    MV32 R1, #GPT3_BASE_ADDR
    
    LDR R0, [R1, #CTL_ADDR_OFFSET]
    MV32 R2, #CTL_TBEN_CLR_MASK 
    AND R0, R0, R2     
    STR R0, [R1, #CTL_ADDR_OFFSET]      ;disable timer 3B
    
    MOV R0, #CFG_SETNS_16BIT            
    STR R0, [R1, #CFG_ADDR_OFFSET]      ;enable 16-bit counter 

    MOV R0, #GPT3_TBMR_SETN
    STR R0, [R1, #TBMR_ADDR_OFFSET]     ;disable time-out interrupt and set 
                                        ;   Timer3B as a count-down PWM timer 

    MV32 R0, #TOTAL_PWM_PULSE_FOR_STEPPER 
    MOV R2, #BOTTOM_HALFWORD_MASK
    AND R0, R0, R2
    STR R0, [R1, #TBILR_ADDR_OFFSET]    ;set stepper motor movement frequency
                                        ;   (low 16 bits)

    MV32 R0, #TOTAL_PWM_PULSE_FOR_STEPPER
    LSR R0, R0, #LSR_SIXTEEN
    STR R0, [R1, #TBPR_ADDR_OFFSET]     ;set stepper motor movement frequency
                                        ;   (high 8 bits, prescaler for TBILR)

    LDR R0, [R1, #CTL_ADDR_OFFSET]
    ORR R0, R0, #CTL_TBEN_SET_MASK
    STR R0, [R1, #CTL_ADDR_OFFSET]      ;enable PWM Timer3B

    BX LR 

