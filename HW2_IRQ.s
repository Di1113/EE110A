;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                HW2_IRQ.s                                   ;
;                        Interrupt Init and Handlers                         ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains functions for initializing interrupts and interrupt
; for Timer0A handler 
; 
; FUNCTION INDEX: 
;   InterruptInit - initialize interrupts by updating interrupt(IR) vector table
;   Timer0AIRHandler - set timer0A interrupt to key press detection functions 
;
; REVISION HISTORY:
;     11/10/19  Di Hu      Initial Revision
;     11/21/19  Di Hu      - Added comments;
;                          - replaced usage of R4 to R12 for future C code 

;   include files 
    .include "HW2_CC26x2_DEFS.inc"
    .include "HW2_MACROS.inc"
;   public functions 
    .global InterruptInit
    .ref ScanPressedKey


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
;                    in the new table. 
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
; Last Modified:     Nov 21, 2019  
InterruptInit:

EnableInterruptInSCS:                        
    MV32 R3, #CPU_SCS_BASE_ADDR     ;for accessing interrupt registers
                                    ; in CPU_SCS
    MOV R0, #NVIC_ISER0_SETNS       ;enable interrupt for timer0A
    STR R0, [R3, #NVIC_ISER0_ADDR_OFFSET] ;save config to CPU_SCS.NVIC_ISER0 


InitNewVectorTable:                 ;to change the handler address offset,
                                    ; duplicate a new vector table in RAM 
    LDR R2, [R3, #VTOR_ADDR_OFFSET] ;load old VTOR address into R2
    LDR R1, addr_IRQVectors         ;load new vector table address to R1
    MOV R0, #IR_VTABLE_SIZE         ;set a counter with total table entry count

CopyTableEntry:                     ;copy the old table's value to the new one 
    LDR R12, [R2], #4               ;update value stored in R2 into R1 first, 
                                    ;   then increment address in R2, R1 by a  
    STR R12, [R1], #4               ;   word to move to next table entry 
    SUB R0, #1                      ;update table entry counter 
    TST R0, R0                      ;check if has copied all table entries
    BEQ ChangeTimer0AHandler        ;if copied all, update handler address in
                                    ;   vector table 
    BNE CopyTableEntry              ;else, keep copying 

ChangeTimer0AHandler:               ;update Timer0A handler's address in table
    LDR R1, addr_IRQVectors         ;load Timer0A handler's address into R1 
    ADD R1, #Timer0A_ADDR_OFFSET    
    ADR.W R0, Timer0AIRHandler      ;load Timer0A handler function's PC address
                                    ;   to R0
    ADD R0, #1                      ;add 1 to handler's addr bc of Thumb mode 
    STR R0, [R1]                    ;update Timer0A handler's address in VTOR 

UpdateVTOROffset:                   ;change VTOR's address to the new table 
    LDR R0, addr_IRQVectors         
    STR R0, [R3, #VTOR_ADDR_OFFSET] ;update VTOR address in CPU_SCS.VTOR 

    BX LR


; Timer0AIRHandler
;
; Description:       This function calls keypad function to handle interrupt 
;                    from Timer0A. 
;
; Operation:         This function pushes all registers used before interrupt 
;                    on to the stack, and call keypad scan function to handle
;                    the interrupt, and finally pop all registers pushed.   
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
; Registers Changed: R0, R3, LR 
; Stack Depth:       7 bytes.
;
; Author:            Di Hu
; Last Modified:     Nov 21, 2019  
Timer0AIRHandler:

    PUSH {R0, R1, R2, R3, R12, LR}  ;push registers used before interrupt
                                    ;   onto stack 

ResetInterrupt:
    MV32 R3, #GPT0_BASE_ADDR
    MOV R0, #1                      ;acknowledge interrupt handled by clearing 
    STR R0, [R3, #ICLR_ADDR_OFFSET] ; Timer0A(TATOCINT)'s interrupt in GPT0.ICLR

    BL ScanPressedKey               ;call keypad function to scan pressed key

    POP {R0, R1, R2, R3, R12, LR}   ;pop old value back to used registers

InterruptDone:
    BX LR                           ;return from interrupt 


;code ends

;Variables 
addr_IRQVectors: .word IRQVectors

