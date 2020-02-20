;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                HW3_TIMER.s                                 ;
;                            Timer Configurations                            ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains functions for initializing Timer0B, Timer1A and Timer1B as
; one-shot timers for counting time delays for LCD routines. This file also 
; contains functions to start timing delays and loop till delay is finished. 
;
; FUNCTION INDEX: 
;   InitOneShotTimer0B      - initialize Timer0B as a one-shot timer 
;   InitOneShotTimer1A      - initialize Timer1A as a one-shot timer 
;   InitOneShotTimer1B      - initialize Timer1B as a one-shot timer 
;   StartTimer0BCounter     - start down counting clocks to time delays in Timer0A  
;   StartTimer1ACounter     - start down counting clocks to time delays in Timer1A 
;   StartTimer1BCounter     - start down counting clocks to time delays in Timer1B
;   WaitTillCountingDoneT0B - loop till delay is up in Timer0B
;   WaitTillCountingDoneT1A - loop till delay is up in Timer1A
;   WaitTillCountingDoneT1B - loop till delay is up in Timer1B 
;
; REVISION HISTORY:
;     11/25/19  Di Hu      Initial Revision
;     12/27/19  Di Hu      Edited comments 

;   .include files 
    .include "HW3_CC26x2_DEFS.inc"
    .include "HW3_TIMER_DEFS.inc"
    .include "HW3_MACROS.inc"
;   public functions 
    .global InitOneShotTimer0B
    .global InitOneShotTimer1A
    .global InitOneShotTimer1B
    .global StartTimer0BCounter
    .global StartTimer1ACounter
    .global StartTimer1BCounter
    .global WaitTillCountingDoneT0B
    .global WaitTillCountingDoneT1A
    .global WaitTillCountingDoneT1B


    .text
; code starts 

; InitOneShotTimer0B
;
; Description:       This function configures Timer0B as a 16-bit one-shot  
;                    timer that counts down clocks with interrupt disabled. 
;
; Operation:         This function configures CFG, TBMR and IMR registers.
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
InitOneShotTimer0B:    ;config Timer0B as an one-shot timer for timing delays
    MV32 R2, #GPT0_BASE_ADDR
    
    MOV R12, #CFG_SETNS_16BIT            
    STR R12, [R2, #CFG_ADDR_OFFSET]      ;enable 16-bit counter 
    
    MOV R12, #GPT0_TBMR_SETN
    STR R12, [R2, #TBMR_ADDR_OFFSET]     ;set one-shot mode
                                         ; and set counter to count down
    
    LDR R12, [R2, #IMR_ADDR_OFFSET]
    MOV R3, #0
    AND R12, R12, R3
    STR R12, [R2, #IMR_ADDR_OFFSET]      ;disable interrupt for Timer0B
    BX LR 


; StartTimer0BCounter(clks, preclks)
;
; Description:       This function enables Timer0B to count down the passed-in
;                    clock counter size.      
;
; Operation:         This function starts delays by setting the passed-in clock 
;                    counter size to TAILR and TBPR registers, and enabling 
;                    Timer0B in CTL register. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None. 
; Shared Variables:  R0 - Timer0B clock counter size (low 16 bits).  
;                    R1 - Prescaler for Timer0B counter value (high 8 bits). 
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
StartTimer0BCounter:
    MV32 R2, #GPT0_BASE_ADDR
    ; passed in parameters: R0 -> counter value; R1 -> prescaler value                
    STR R0, [R2, #TBILR_ADDR_OFFSET] ;configure counter value for counting delay 
    STR R1, [R2, #TBPR_ADDR_OFFSET]     

    LDR R12, [R2, #CTL_ADDR_OFFSET]
    ORR R12, R12, #CTL_SETNS_T0B_EN
    STR R12, [R2, #CTL_ADDR_OFFSET]  ;enable Timer0B and start counting

    BX LR


; WaitTillCountingDoneT0B
;
; Description:       This function checks if counting is done in the one-shot
;                    Timer0B and loops till counting is done.      
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
WaitTillCountingDoneT0B: 
    MV32 R2, #GPT0_BASE_ADDR

CheckT0BCountingDone:
    LDR R12, [R2, #CTL_ADDR_OFFSET]
    ANDS R3, R12, #CTL_TBEN_MASK        ;check if counting is done 
    BNE CheckT0BCountingDone            ;still counting 
    ;BEQ CountingDone -> clear interrupt and return 
T0BCountingDone:
    MOV R0, #CLR_TBTOCINT
    STR R0, [R2, #ICLR_ADDR_OFFSET]

    BX LR 


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
    ORR R12, R12, #CTL_SETNS_T1A_EN
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


; InitOneShotTimer1B
;
; Description:       This function configures Timer1B as a 16-bit one-shot  
;                    timer that counts down clocks with interrupt disabled. 
;
; Operation:         This function configures CFG, TBMR and IMR registers.
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
InitOneShotTimer1B:  ;config Timer1B as an one-shot timer for counting delays
    MV32 R2, #GPT1_BASE_ADDR
    
    MOV R12, #CFG_SETNS_16BIT            
    STR R12, [R2, #CFG_ADDR_OFFSET]      ;enable 16-bit counter 
    
    MOV R12, #GPT1_TBMR_SETN                  
    STR R12, [R2, #TBMR_ADDR_OFFSET]     ;set one-shot mode and 
                                         ; set counter to count down
    
    LDR R12, [R2, #IMR_ADDR_OFFSET]
    MOV R3, #0
    AND R12, R12, R3
    STR R12, [R2, #IMR_ADDR_OFFSET]      ;disable interrupt for Timer1B
    BX LR 


; StartTimer1BCounter(clks, preclks)
;
; Description:       This function enables Timer1B to count down the passed-in
;                    clock counter size.      
;
; Operation:         This function starts delays by setting the passed-in clock 
;                    counter size to TAILR and TBPR registers, and enabling 
;                    Timer1B in CTL register. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None. 
; Shared Variables:  R0 - Timer1B clock counter size (low 16 bits).  
;                    R1 - Prescaler for Timer1B counter value (high 8 bits). 
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
StartTimer1BCounter:
    MV32 R2, #GPT1_BASE_ADDR
    ; passed in parameters: R0 -> counter value; R1 -> prescaler value                
    STR R0, [R2, #TBILR_ADDR_OFFSET] ;configure counter value for counting delays
    STR R1, [R2, #TBPR_ADDR_OFFSET]     
    
    LDR R12, [R2, #CTL_ADDR_OFFSET]
    ORR R12, R12, #CTL_SETNS_T1B_EN
    STR R12, [R2, #CTL_ADDR_OFFSET]  ;enable Timer1B and start counting

    BX LR


; WaitTillCountingDoneT1B
;
; Description:       This function checks if counting is done in the one-shot
;                    Timer1B and loops till counting is done.      
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
WaitTillCountingDoneT1B:
    MV32 R2, #GPT1_BASE_ADDR

CheckT1BCountingDone:
    LDR R12, [R2, #CTL_ADDR_OFFSET]
    ANDS R3, R12, #CTL_TBEN_MASK        ;check if counting is done 
    BNE CheckT1BCountingDone            ;still counting 
    ;BEQ CountingDone -> clear interrupt and return 
T1BCountingDone:
    MOV R0, #CLR_TBTOCINT
    STR R0, [R2, #ICLR_ADDR_OFFSET]

    BX LR 
