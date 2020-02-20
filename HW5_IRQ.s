;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                HW5_IRQ.s                                   ;
;                        Interrupt Init and Handlers                         ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains functions for interrupt intialization and Timer2B
; interrupt handler which controls the step motor to make steps. 
; 
; FUNCTION INDEX: 
;   InterruptInit    - initialize interrupts by updating interrupt vector table
;   Timer2BIRHandler - set timer2B interrupt to step motor's MakeOneStep function 
;
; REVISION HISTORY:
;     12/18/19  Di Hu      Initial Revision
;     12/30/19  Di Hu      Edited comments 

;   include files 
    .include "HW5_CC26x2_DEFS.inc"
    .include "HW5_MACROS.inc"
    .include "HW5_TIMER_DEFS.inc"

;   public functions 
    .global InterruptInit
    .ref MakeOneStep


    .data
    .align 512
IRQVectors:                 ;points to the start of IR vector table 
    .SPACE IR_VTABLE_SIZE   ;allocate space for IR vector table 


    .text
; code starts 

; InterruptInit
;
; Description:       This function initializes interrupt vector table and 
;                    update handler addresses in the table. 
;
; Operation:         This function duplicates the old IR vector table into 
;                    a new address, and update the Timer0A handler's address
;                    in the new table, since the old IR vector in SRAM is
;                    read only. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   R3 - contains base address for CPU_SCS module 
;                    addr_IRQVectors - contains new IR vector table address
; Shared Variables:  None. 
;
; Input:             None. 
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   Vector table, one word each entry. 
;
; Registers Changed: R0, R1, R2, R3, R12
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Dec 18, 2019  
InterruptInit:

    MV32 R3, #CPU_SCS_BASE_ADDR     ;for accessing interrupt registers
                                    ;   in CPU_SCS

InitNewVectorTable:                 ;to change the handler address offset,
                                    ;   duplicate a new vector table in RAM 
    LDR R2, [R3, #VTOR_ADDR_OFFSET] ;load old VTOR address into R2
    LDR R1, addr_IRQVectors         ;load new vector table address to R1
    MOV R0, #IR_VTABLE_SIZE         ;set a counter with total table entry count

CopyTableEntry:                     ;copy the old table's value to the new one 
    LDR R12, [R2], #4               ;update value stored in R2 into R1 first, 
                                    ;   then increment address in R2, R1 by a  
    STR R12, [R1], #4               ;   word to move to next table entry 
    SUB R0, #1                      ;update table entry counter 
    TST R0, R0                      ;check if has copied all table entries
    BEQ ChangeTimer2BHandler        ;if copied all, update handler address in
                                    ;   vector table 
    BNE CopyTableEntry              ;else, keep copying 

ChangeTimer2BHandler:               ;update Timer2B handler's address in table
    LDR R1, addr_IRQVectors         ;load Timer2B handler's address into R1 
    ADR.W R0, Timer2BIRHandler      ;load Timer2B handler function's PC address
                                    ;   to R0
    ADD R0, #1                      ;add 1 to handler's addr bc of Thumb mode 
    STR R0, [R1, #Timer2B_ADDR_OFFSET];update Timer2B handler's address in VTOR 

UpdateVTOROffset:                   ;change VTOR's address to the new table 
    LDR R0, addr_IRQVectors         
    STR R0, [R3, #VTOR_ADDR_OFFSET] ;update VTOR address in CPU_SCS.VTOR 

EnableInterruptInSCS:                        
    MOV R0, #ENABLE_TIMER2B_IRQ     ;enable interrupt for Timer2B
    STR R0, [R3, #NVIC_ISER0_ADDR_OFFSET] ;save config to CPU_SCS.NVIC_ISER0 

    BX LR


; Timer2BIRHandler
;
; Description:       This function calls stepper function MakeOneStep 
;                    to handle interrupt from Timer2B, which occurs every 1ms.
;                    In every interrupt, the steppper makes one step forward 
;                    or backward. 
;
; Operation:         This function pushes all registers used on to the stack
;                    before interrupt, and branch to MakeOneStep to control
;                    stepper make a step during the interrupt call, and
;                    finally pop all registers pushed.   
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
; Registers Changed: R0, R1, R2, R3, LR 
; Stack Depth:       7 words.
;
; Author:            Di Hu
; Last Modified:     Dec 18, 2019  
Timer2BIRHandler:

    PUSH {R0, R1, R2, R3, R12, LR}  ;push registers used before interrupt
                                    ;   onto stack 

ResetInterrupt:

    BL MakeOneStep                  ;call stepper function to make a step 

    MV32 R3, #GPT2_BASE_ADDR
    MOV R0, #TBTOCINT_CLR_MASK      ;acknowledge interrupt handled by clearing 
    STR R0, [R3, #ICLR_ADDR_OFFSET] ;   Timer2B(TBTOCINT)'s interrupt in GPT2.ICLR

    NOP                             ;wait some clocks for 
    NOP                             ;   interrupt set flag to be cleard 
    NOP
    NOP
    NOP

    POP {R0, R1, R2, R3, R12, LR}   ;pop old value back to used registers

InterruptDone:
    BX LR                           ;return from interrupt 


;code ends

;address of shared variables 
addr_IRQVectors: .word IRQVectors

