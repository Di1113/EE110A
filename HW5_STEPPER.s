;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                               HW5_STEPPER.s                                ;
;                          Stepper Control Routines                          ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains functions for initializing stepper control routines' shared
; variables, for controlling the stepper motor to change position and for
; reading the stepper motor's current position in absolute angle. 
;
; FUNCTION INDEX: 
;     StepperInit  - initialize shared variables used in stepper control routines
;                    and set stepper position to be at 0 degree 
;     StepOneStep  - update control A, B and PWM control values in GPIO and GPT3
;     MakeOneStep  - check if stepping is needed and call StepOneStep if needed 
;     SetRelAngle  - rotate the stepper motor by a relative angle(passed in R0)
;     SetAngle     - rotate the stepper motor to an absolute angle(passed in R0)
;     GetAngle     - return the current absolute angle of the stepper motor
;                    in R0 
;
; REVISION HISTORY:
;     12/18/19  Di Hu      Initial Revision
;     12/30/19  Di Hu      Edited comments;
;     01/11/20  Di Hu      Changed update order for stepper A, B controls and 
;                          PWM controls in StepOneStep function;
;     01/12/20  Di Hu      Edited comments;
;     01/15/20  Di Hu      Debugged the StepperStepTable to correct PWM control 
;                          values; 
;     01/18/20  Di Hu      Added shared variables stepper_pos_buffer, spb_empty
;                          and spb_overflow;
;     01/20/20  Di Hu      - Debugged negative arguments for SetRelAngle;
;                          - Added SetAngle function in StepperInit to set stepper 
;                            to 0 degree as initial position.


;   .include files 
    .include "HW5_CC26x2_DEFS.inc"
    .include "HW5_STEPPER_DEFS.inc"
    .include "HW5_MACROS.inc"
    .include "HW5_TIMER_DEFS.inc"

;   public functions 
    .global StepperInit
    .global MakeOneStep
    .global SetRelAngle
    .global SetAngle
    .global GetAngle


    .data
    .align 4
steps_to_make:          .space 4
stepper_pos_buffer:     .space 4    ;abbreviated as spb below
spb_empty:              .space 4    ;spb empty flag
spb_overflow:           .space 4    ;stepper_pos_buffer overflow flag 
total_angle:            .space 4
curr_table_entry_addr:  .space 4


    .text
;code starts 


; StepperInit
;
; Description:       This function initializes value of variable buffers used
;                    in stepper routines and sets stepper to be at 0 degree 
;                    absolute position.
;
; Operation:         This function clears steps_to_make, stepper_pos_buffer,
;                    spb_overflow and curr_table_entry_addr buffers' value to
;                    0; set spb_empty to constant TRUE, sets total_angle to be 
;                    negative-one-step degree for stepper routines and set 
;                    stepper to initial position by calling SetAngle. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None. 
; Shared Variables:  steps_to_make          - w - initialized to 0 for stepper
;                    (addr_steps_to_make)         routines SetRelAngle
;                    stepper_pos_buffer     - w - initialized to 0 for stepper
;                    (addr_stepper_pos_buffer)    routines SetRelAngle, 
;                                                 MakeOneStep
;                    spb_overflow           - w - initialized to FALSE for stepper
;                    (addr_spb_overflow)          routines SetRelAngle, 
;                                                 MakeOneStep
;                    spb_empty              - w - initialized to TRUE for stepper
;                    (addr_spb_empty)             routines SetRelAngle, 
;                                                 MakeOneStep
;                    curr_table_entry_addr  - w - initialized to 0 for traversing 
;                    (addr_curr_table_entry_addr) the stepper table 
;                    total_angle            - w - initialized to negative-one-
;                    (addr_total_angle)           step degree for SetAngle 
;                                                 and GetAngle 
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
; Stack Depth:       1 word
;
; Author:            Di Hu
; Last Modified:     Jan 20, 2020
StepperInit:
    PUSH {LR}
    
    MOV R1, #0
    WRVAR R1, addr_steps_to_make            ;clear steps_to_make's value 
    WRVAR R1, addr_stepper_pos_buffer       ;clear stepper_pos_buffer's value 
    WRVAR R1, addr_spb_overflow             ;set as FALSE 
    WRVAR R1, addr_curr_table_entry_addr 
                                    ;clear curr_table_entry_addr's value 

    MOV R1, #TRUE 
    WRVAR R1, addr_spb_empty        

    MOV R1, #0
    SUB R1, #MICRO_STEP_DEGREE      ;since the stepper table starts at 0 degree 
    WRVAR R1, addr_total_angle      ;   and total_angle is update in each 
                                    ;   interrupt(after reading a table row)

    MOV R0, #0
    BL SetAngle                     ;set stepper to 0 degree absolute position 

    POP {LR}
    BX LR 


; StepOneStep(table_offset)
;
; Description:       This function is passed in a table address offset
;                    (table_offset) in R0 to access a row in StepperStepTable 
;                    and use values in the row to update values of DOUT31_0 in
;                    GPIO and TAMATCHR, TAPMR, TBMATCHR, TBPMR in GPT3 to 
;                    control stepper to step forward or backward one micro step. 
;
; Operation:         This function updates GPT3 and GPIO's registers by accessing 
;                    one of StepperStepTable's row with the passed in table 
;                    address offset, then reading two bytes and four halfwords
;                    in the row, and writing them each to DOUT31_0 in GPIO
;                    (the first two bytes) and to TAMATCHR, TAPMR, TBMATCHR,  
;                    TBPMR in GPT3(the last four halfwords). 
;
; Arguments:         table_offset - R0 - by value - table address offset for
;                                                   adding on to 
;                                                   StepperStepTable's base 
;                                                   address to access a row in
;                                                   StepperStepTable 
;
; Return Value:      None. 
;
; Local Variables:   R1  - contains base address for GPIO and GPT3 module 
;                    R12 - contains base address for StepperStepTable 
; Shared Variables:  curr_table_entry_addr       - w - updated to current 
;                    (addr_curr_table_entry_addr)      traversing point in 
;                                                      StepperStepTable 
;
; Input:             None. 
; Output:            Step motor's shaft either moves one micro step forward or 
;                    backward. 
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   StepperStepTable, 5 halfwords each entry. 
;
; Registers Changed: R0, R1, R2, R3, R12
; Stack Depth:       1 word 
;
; Author:            Di Hu
; Last Modified:     Jan 11, 2020  
StepOneStep: 
    PUSH {R3}                   ;save R3 for continuing using R3 in MakeOneStep
    
    ADR R12, StepperStepTable   ;use R12 as a temporary StepperStepTable address
                                ;   holder   

    MV32 R1, #GPIO_BASE_ADDR

    LDR R2, [R1, #DOUT31_0_ADDR_OFFSET]
                                ;read data output value 
    MV32 R3, #SERVO_EN_CTL_MASK 
    AND R2, R2, R3              ;mask out stepper's control A and control B bits 
    
    ;R0 contains table entry address offset 
    LDRB R3, [R12, R0]          ;load control A value from the first byte in 
                                ;   the stepper table row 
    ORR R2, R2, R3              ;set control A's value 

    ADD R0, #1                  ;done with control A byte, update table offset
                                ;   to access next byte  
    LDRB R3, [R12, R0]          ;read second byte for control B 
    LSL R3, R3, #1              ;shift second byte value to control B's bit pos 
    ORR R2, R2, R3              ;set control B's value 
    STR R2, [R1, #DOUT31_0_ADDR_OFFSET]
                                ;update control A and control B's value in data
                                ;   output 

    MV32 R1, #GPT3_BASE_ADDR    ;use R1 as a temporary GPT3 address holder 

    ADD R0, #1                  ;done with control B byte, update table offset
                                ;   to access next byte  
    LDRH R2, [R12, R0]          ;load the halfword after two bytes
    STR R2, [R1, #TAMATCHR_ADDR_OFFSET]  
                                ;set it as Timer3A's low pulse width's lower 
                                ;   16 bits 

    ADD R0, #HALF_WORD_SIZE_IN_BYTE ;done with TAMATCHR for PWM A control 
                                ;update table offset to access next halfword 
    LDRH R2, [R12, R0]          ;load the second halfword
    STR R2, [R1, #TAPMR_ADDR_OFFSET]
                                ;set it as Timer3A's low pulse width's higher 
                                ;   8 bits 

    ADD R0, #HALF_WORD_SIZE_IN_BYTE ;done with TAPMR for PWM A control 
                                ;update table offset to access next halfword 
    LDRH R2, [R12, R0]          ;load the third halfword
    STR R2, [R1, #TBMATCHR_ADDR_OFFSET]  
                                ;set it as Timer3B's low pulse width's lower 
                                ;   16 bits

    ADD R0, #HALF_WORD_SIZE_IN_BYTE ;done with TBMATCHR for PWM B control 
                                ;update table offset to access next halfword 
    LDRH R2, [R12, R0]          ;load the fourth halfword
    STR R2, [R1, #TBPMR_ADDR_OFFSET]
                                ;set it as Timer3B's low pulse width's higher 
                                ;   8 bits

    ADD R0, #HALF_WORD_SIZE_IN_BYTE ;done with TBPMR for PWM B control  
                                ;update table offset for next stepping 
    MOV R1, R0                  ;since R0 is used in WRVAR, store R0 in R1 
    WRVAR R1, addr_curr_table_entry_addr
                                ;save table offset in curr_table_entry_addr

    POP {R3}                    ;done and return 
    BX LR 


; MakeOneStep
;
; Description:       This function is called by GPT2's time-out interrupt handler
;                    about every 20 milliseconds. This function checks if stepper  
;                    has finished stepping to current set position, if not, keep
;                    stepping, if yes, checks if a new position is requested and 
;                    begin to set to new position if so. This function also 
;                    checks and decides which direction the stepper steps to if 
;                    stepping is needed, and finally control the stepper to 
;                    make one micro step by calling StepOneStep. 
;
; Operation:         This function first checks if stepper needs to finish  
;                    stepping to set position by checking if steps_to_make equals
;                    zero: if steps_to_make equals zero, then function checks 
;                    if a new position is requested by checking if spb_empty 
;                    flag is false: if false, update steps_to_make to new 
;                    position step count stored in stepper_pos_buffer, set 
;                    spb_empty to true and start stepping; if true, no new 
;                    position is set, return. If needs to step(steps_to_make is
;                    nonzero), checks if needs to step forward
;                    or backward by checking if steps_to_make is positive(>0) or 
;                    negative(<0). To avoid pointing to non-table address, check if
;                    need to update table address pointer(curr_table_entry_addr)
;                    before reading values from the table: if steps_to_make
;                    is positive, then checks if table pointer is at the end 
;                    of the table, if steps_to_make is negative, then checks
;                    if the pointer is at the end of the first row of the table.
;                    If current table address is at those table boundary address,
;                    then updates to table start or table end, else, increment 
;                    or decrement table address to access next row or previous 
;                    row to step forward or step back. 
;                    Finally call StepOneStep to control step motor change 
;                    position and updates steps_to_make and total_angle's values. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None. 
; Shared Variables:  curr_table_entry_addr       - r - read current traversing
;                    (addr_curr_table_entry_addr)      point in StepperStepTable
;                    steps_to_make               - r/w - update steps stepper 
;                    (addr_steps_to_make)                needs to make     
;                    total_angle                 - r/w - update total angle 
;                    (addr_total_angle)                  stepper has stepped
;                                                        in degrees 
;                    stepper_pos_buffer          - r -   use its value to update
;                    (addr_stepper_pos_buffer)           steps_to_make
;                    spb_empty                   - r/w - read to check if new
;                    (addr_spb_empty)                    position is requested
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
; Stack Depth:       1 word 
;
; Author:            Di Hu
; Last Modified:     Jan 20, 2019  
MakeOneStep: 
    PUSH {LR}                           ;save LR for branching to StepOneStep 

    RDVAR R3, addr_steps_to_make        ;check if finished stepping to current 
                                        ;   set position 
    CMP R3, #0                          ;check steps_to_make is clear 
    BNE StartStepping                   ;if not continue stepping 
    ; BEQ continue to check if spb is empty 
    
    RDVAR R3, addr_spb_empty            ;check if a new position is requested 
    CMP R3, #TRUE                       ;check if spb is empty 
    BEQ MakeStepDone                    ;if spb is empty, no new position, return 
    ;BNE new position requested, continue to update steps_to_make 

    RDVAR R3, addr_stepper_pos_buffer   ;read new position requested 
    WRVAR R3, addr_steps_to_make        ;update spb value to steps_to_make   
    MOV R1, #TRUE 
    WRVAR R1, addr_spb_empty            ;spb value used, set empty flag
                                        ;    ready for a new value 

StartStepping:
    RDVAR R1, addr_curr_table_entry_addr;read current table offset address 

    ;R3 contains steps_to_make value    
    CMP R3, #0                          ;check if current set position needs 
                                        ;   stepping(non-zero relative degree) 
                                        ;if steps_to_make = 0, i.e. no stepping
    BEQ MakeStepDone                    ;   needed, then return
    ;BNE CheckStepDir                   ;else, check which direction to step to 
CheckStepDir:
    ;R3 contains steps_to_make value, and compared with 0 
    ;check steps_to_make < 0, 
    BMI CheckAtTableStart               ;if steps_to_make < 0,  check if at
                                        ;    table's first row 
    ;BPL CheckAtTableEnd                ;if steps_to_make >= 0, check if at
                                        ;    table's last row 

CheckAtTableEnd:
    MOV R2, #STEP_TAB_SIZE              ;load table size in bytes to compare 
                                        ;   with current table offset bytes 
    CMP R1, R2                          ;check if at the end of the table 
    BNE StepForward                     ;if not, prepare to step forward 
    ;BEQ:                               ;if yes (at the last entry of step table)
    MOV R1, #0                          ;update table offset to point to 
                                        ;   table's first row (circle back to
                                        ;   the beginning)
    ;B StepForward
StepForward: 
    ;R1 contains table entry address offset 
    MOV R0, R1                          ;save R1 in R0 to pass to StepOneStep 
    BL StepOneStep                      ;branch to StepOneStep to control stepper
                                        ;   to make one micro step forward 
    SUB R3, #1                          ;one step made, update step counter 
    WRVAR R3, addr_steps_to_make        ;save updated step counter 
    RDVAR R1, addr_total_angle
    ADD R1, #MICRO_STEP_DEGREE
    WRVAR R1, addr_total_angle          ;increase total angle stepped by one 
                                        ;   micro step 
    B MakeStepDone                      ;MakeOneStep finished 

CheckAtTableStart: 
    MOV R2, #STEP_TAB_ENTRY_SIZE        ;load one table row's(entry's) size in
                                        ;   bytes to compare with current
                                        ;   table offset in bytes 
    CMP R1, R2                          ;check if at the end of the first row
                                        ;   or at table start
    BHI StepBack                        ;if not, prepare to step backward
    ;BLS:                               ;if yes (at the first entry of step table)
    MOV R1, #STEP_TAB_SIZE              ;update table offset to point to end of 
                                        ;   table's last row 
    ADD R1, #STEP_TAB_ENTRY_SIZE        ;add to offset subtraction in next line 
    ;B StepBack
StepBack:
    SUB R1, #STEP_TAB_ENTRY_SIZE << 1   ;update table address offset to point to
                                        ;   start of the previous row 
    MOV R0, R1
    BL StepOneStep                      ;branch to StepOneStep to control stepper
                                        ;   to make one micro step backward  
    ADD R3, #1                          ;one step made, update step counter 
    WRVAR R3, addr_steps_to_make        ;save updated step counter 
    RDVAR R1, addr_total_angle
    SUB R1, #MICRO_STEP_DEGREE
    WRVAR R1, addr_total_angle          ;decrease total angle stepped by one 
                                        ;   micro step 
    ;B MakeStepDone                     ;MakeOneStep finished 

MakeStepDone:
    POP {LR}                            ;done and return 
    BX LR


; SetRelAngle(angle)
;
; Description:       The function is passed a single argument (angle) in R0 
;                    that is the relative angle (in degrees) through which to
;                    turn the stepper motor. A relative angle of zero (0)
;                    indicates no movement, positive relative angles indicate
;                    clockwise rotation, and negative relative angles indicate
;                    counterclockwise rotation. The angle is relative to the 
;                    current stepper motor position. The angle resolution must be 
;                    multiples of 6 degrees. The passed in relative angle is 
;                    converted to step counts to be accessed by MakeOneStep 
;                    function to set stepper to passed in position.
;
; Operation:         This function divides angle by one-micro-step degrees to 
;                    convert angle into micro step counts, then disable interrupt,
;                    check if stepper_pos_buffer is empty: if empty, update new
;                    step count to this buffer; if not, report overflow error.
;                    Then enable interrupt again. The stepper motor would make
;                    micro steps one step each in 50hz interrupts through 
;                    Timer2B interrupt handler MakeOneStep. 
;
; Arguments:         angle - R0 - by value - relative angle in signed integer 
;                                            to move stepper motor's position by  
;
; Return Value:      None. 
;
; Local Variables:   None. 
; Shared Variables:  spb_empty                - r/w - check and updates 
;                    (addr_spb_empty)                 stepper_pos_buffer status 
;                    stepper_pos_buffer       - w - update to new value 
;                    (addr_stepper_pos_buffer)
;                    spb_overflow             - w - update overflow error flag 
;                    (addr_spb_overflow)
;
; Input:             None. 
; Output:            None.
;
; Error Handling:    angle that is not multiples of 6 degrees is truncated to 
;                    the biggest 6 multiple that is less than angle with SDIV
;                    operation. 
;
; Algorithms:        None.
; Data Structures:   None. 
;
; Registers Changed: R0, R1, R2, R3, LR
; Stack Depth:       1 word 
;
; Author:            Di Hu
; Last Modified:     Jan 19, 2019  
SetRelAngle:
    PUSH {LR} 

    MOV R1, #MICRO_STEP_DEGREE      ;divide angle by MICRO_STEP_DEGREE 
    SDIV R1, R0, R1                 ;R1 = R0 / R1 

    MOV R3, #FALSE

    CPSID i                         ;disable interrupt
    
    RDVAR R2, addr_spb_empty
    CMP R2, R3                      ;check if spb is empty to avoid overwriting 
                                    ;   current value  
    BEQ SetStepperBufferError       ;not empty, report overflow error 
    ;BNE empty, continue to update spb buffer value 
    WRVAR R1, addr_stepper_pos_buffer ;update step buffer write pointer 
    WRVAR R3, addr_spb_empty        ;clear empty flag 
    
    CPSIE i                         ;re-enable interrupt 
    
    WRVAR R3, addr_spb_overflow     ;clear overflow flag 
    B EndSetRelAngle

SetStepperBufferError:
    MOV R1, #TRUE 
    WRVAR R1, addr_spb_overflow 
    CPSIE i                         ;re-enable interrupt 

EndSetRelAngle:
    POP {LR}                        ;done and return 
    BX LR 

; SetAngle(angle)
;
; Description:       The function is passed a single argument (angle) in R0
;                    which is the absolute angle (in degrees) at which the
;                    stepper motor is to be pointed. This angle is unsigned
;                    (i.e. positive values only). An angle of zero (0) indicates
;                    the "home" position for the stepper motor and non-zero angles
;                    are measured clockwise. The angle resolution must be 
;                    multiples of 6 degrees. If current position is 350 absolute
;                    degree and SetAngle(20) is called, the stepper would 
;                    go counter-clock wise to meet 20 absolute degree position,
;                    since when calling SetRelAngle, an negative argument is 
;                    passed in R0. 
;
; Operation:         This function sets the stepper motor to passed in angle 
;                    position by reading its current position(total_angle) and 
;                    subtracting by angle in R0, then calling SetRelAngle to
;                    control the stepper motor. 
;
; Arguments:         angle - R0 - by value - absolute angle in unsigned integer 
;                                            to set stepper motor's position by 
;
; Return Value:      None. 
;
; Local Variables:   None. 
; Shared Variables:  total_angle       - r - read to calculate relative angle 
;                    (addr_total_angle)      by subtracting angle in R0 
;
; Input:             None. 
; Output:            None.
;
; Error Handling:    angle that is not multiples of 6 degrees is rounded to 
;                    the nearest 6 multiple with signed subtraction from
;                    current position(total_angle) and SDIV operation in
;                    SetRelAngle. 
;
; Algorithms:        None.
; Data Structures:   None. 
;
; Registers Changed: R0, R1, LR
; Stack Depth:       2 words
;
; Author:            Di Hu
; Last Modified:     Dec 18, 2019  
SetAngle: 
    PUSH {LR, R0}

    RDVAR R1, addr_total_angle
    POP {LR, R0}
    PUSH {LR}
    SUB R0, R1 
    BL SetRelAngle 

    POP {LR}
    BX LR 

; GetAngle
;
; Description:       The function is called with no arguments and returns the
;                    current absolute angle setting for the turret in degrees
;                    in R0. An angle of zero (0) indicates the stepper motor is
;                    in the "home" position and angles are measured clockwise.
;                    The value returned will always be between 0 and 359
;                    inclusively.
;
; Operation:         The function reads total_angle's value to get stepper's
;                    current absolute angle position which is updated in each
;                    micro step update(updated in MakeOneStep if a micro step
;                    was made).  
;
; Arguments:         None.  
;
; Return Value:      R0 - stepper motor's current absolute angle position in
;                         degrees  
;
; Local Variables:   None. 
; Shared Variables:  total_angle       - r - read to get stepper's current
;                    (addr_total_angle)      absolute angle position
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
; Last Modified:     Dec 18, 2019  
GetAngle: 

    RDVAR R1, addr_total_angle  ;get stepper motor's current position
    MOV R0, R1                  ;return in R0 

    BX LR 


; StepperStepTable
;
; Description:       This table contains value to control the stepper to make 
;                    micro steps. Updating from n row to n+1 row represents
;                    one micro step forward(clockwise) and updating from n+1 row
;                    to n row represents one micro step
;                    backward(counterclockwise). Each micro step is 6 degrees
;                    change in position. This table includes total 12
;                    rows(entries), and each includes values for setting the
;                    stepper's control A(first byte), control B(second byte),
;                    PWM A control(first and second halfwords) and PWM B control
;                    (third and fourth halfwords). The PWM A control values 
;                    are calculated by 980000 * (1 - cos(deg * 5)), and the 
;                    PWM B control values are calculated by 980000 * 
;                    (1 - sin(deg * 5)), where 980000 is 20ms' clock count and 
;                    deg is degree of change relative to stepper's initial
;                    position. CTL A and CTL B represents the direction of 
;                    stepper coil's current direction. 
;
; Author:            Di Hu
; Last Modified:     Jan 15, 2020
    .align 512 
StepperStepTable: 
    ;                 CTL A          CTL B    
    ;              TAMATCHR          TAPMR          TBMATCHR          TBPMR  
    ;index  pos deg  
    ;0      12t + 0  (t: times traversed thru the table) 
StepTabEntryStart:    
    .byte               1,             1
    .half        0 & 0xFFFF,       0 >> 16,  960000 & 0xFFFF,  960000 >> 16     
StepTabEntryEnd: 
    ;1      12t + 6 
    .byte               1,             1
    .half   128616 & 0xFFFF,  128616 >> 16,  480000 & 0xFFFF,  480000 >> 16 
    ;2      12t + 12
    .byte               1,             1
    .half   480000 & 0xFFFF,  480000 >> 16,  128616 & 0xFFFF,  128616 >> 16 
    ;3      12t + 18
    .byte               0,             1
    .half   960000 & 0xFFFF,  960000 >> 16,       0 & 0xFFFF,       0 >> 16     
    ;4      12t + 24
    .byte               0,             1
    .half   480000 & 0xFFFF,  480000 >> 16,  128616 & 0xFFFF,  128616 >> 16  
    ;5      12t + 30
    .byte               0,             1
    .half   128616 & 0xFFFF,  128616 >> 16,  480000 & 0xFFFF,  480000 >> 16  
    ;6      12t + 36
    .byte               0,             0
    .half        0 & 0xFFFF,       0 >> 16,  960000 & 0xFFFF,  960000 >> 16     
    ;7      12t + 42
    .byte               0,             0
    .half   128616 & 0xFFFF,  128616 >> 16,  480000 & 0xFFFF,  480000 >> 16  
    ;8      12t + 48
    .byte               0,             0
    .half   480000 & 0xFFFF,  480000 >> 16,  128616 & 0xFFFF,  128616 >> 16  
    ;9      12t + 54
    .byte               1,             0
    .half   960000 & 0xFFFF,  960000 >> 16,       0 & 0xFFFF,       0 >> 16     
    ;10     12t + 60
    .byte               1,             0
    .half   480000 & 0xFFFF,  480000 >> 16,  128616 & 0xFFFF,  128616 >> 16  
    ;11     12t + 66
    .byte               1,             0
    .half   128616 & 0xFFFF,  128616 >> 16,  480000 & 0xFFFF,  480000 >> 16  

EndStepperStepTable:

;constants
STEP_TAB_ENTRY_SIZE         .equ (StepTabEntryEnd - StepTabEntryStart)
STEP_TAB_SIZE               .equ (EndStepperStepTable - StepperStepTable)

;address of shared variables 
addr_steps_to_make:         .word steps_to_make         ;used to step to current
                                                        ;   set position
addr_stepper_pos_buffer:    .word stepper_pos_buffer    ;used to step to next
                                                        ;   set position
addr_spb_empty:             .word spb_empty             ;indicates if 
                                                        ;   stepper_pos_buffer
                                                        ;   is empty 
addr_spb_overflow:          .word spb_overflow          ;indicates if 
                                                        ;   stepper_pos_buffer
                                                        ;   is full but a new 
                                                        ;   position is requested 
addr_total_angle:           .word total_angle           ;current absolute angle 
addr_curr_table_entry_addr: .word curr_table_entry_addr ;used to traverse 
                                                        ;   StepperStepTable
