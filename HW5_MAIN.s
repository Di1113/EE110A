;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 HW5_MAIN                                   ;
;                              STEPPER ROUTINES                              ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program runs a subroutine that initializes TI CC26x2
;                   launchpad and its interrupt vector table, initializes 
;                   Timer2B as a periodic timer to generate interrupts, Timer3A
;                   and Timer3B as PWM timers to control the connected
;                   step motor, and initializes step motor and test its control 
;                   routines.
;
; Operation:        This program initializes the launchpad by enabling the 
;                   power and clock for GPIO and initializes Timer2B, Timer3A,
;                   Timer3A, step motor's IO, interrupt vector table and servo
;                   functions's shared variables by branching to their 
;                   initialization functions. 
;
; Local Variables:  None.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None. 
;
; Output:           Step motor's shaft rotating to different positions.  
; User Interface:   A step motor with 6 degrees resolution. 
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Known Bugs:       None.
; Limitations:      This program only supports step motor to step in degrees 
;                   of 6 multiples and round angles that are not 6 multiples to
;                   the biggest 6 multiple that is less than that angle. 
;
; Revision History:
;    12/10/19  Di Hu      Initial Revision
;    12/30/19  Di Hu      Edited comments
;    01/10/20  Di Hu      Separated out InitSystemPower and InitSystemClock
;                         functions from main and put into HW5_SYS_INIT.s  
;    01/13/20  Di Hu      Swapped DIO0 and DIO2's, and DIO1 and DIO3's connection
;                         on the board; made DIO0 and DIO1 to control stepper
;                         driver's current direction control pins, DIO2 and DIO3
;                         to control PWM controls. 
;    01/15/20  Di Hu      Added Timer1A functions for macro DELAY_ONE_SEC for
;                         testing
;    01/20/20  Di Hu      Added more test cases.


    ;include files 
    .include "HW5_CC26x2_DEFS.inc"
    .include "HW5_MACROS.inc"

    ;public functions 
    .ref InitSystemPower
    .ref InitSystemClock
    .ref InitOneShotTimer1A
    .ref StartTimer1ACounter
    .ref WaitTillCountingDoneT1A
    .ref InitPeriodicTimer2B 
    .ref InitPWMTimer3A
    .ref InitPWMTimer3B
    .ref InitStepperIO
    .ref InterruptInit 

    ;for testing
    .ref StepperInit
    .ref SetRelAngle
    .ref SetAngle
    .ref GetAngle


    .data                              ;allocate space for stack 
    .align 8
    .space TOTAL_STACK_SIZE
TopOfStack:                            ;point to the bottom of the stack 

    .text
    .global ResetISR
    .align 4
ResetISR:

main:
;start of the actual program

SetUpStack:                            ;set up stack pointers
    LDR R0, addr_TopOfStack            ;initialize the stack pointers MSP, PSP
    MSR MSP, R0
    SUB R0, R0, #HANDLER_STACK_SIZE
    MSR PSP, R0

Initializations:
    BL InitSystemPower
    BL InitSystemClock
    BL InitOneShotTimer1A              ;configure Timer1A for timing delays
    BL InitPeriodicTimer2B             ;initialize Timer2B to generate interrupts 
    BL InitPWMTimer3A                  ;initialize Timer3A to control step motor
    BL InitPWMTimer3B                  ;initialize Timer3A to control step motor
    BL InitStepperIO                   ;initialize IO pins on stepper motor 
    BL InterruptInit                   ;initialize interrupt vector table 
    BL StepperInit                     ;init shared variables for stepper functions

; Stepper test cases 
StartStepperTest:
    MOV R0, #36 ;TOTAL TEST TABLE ENTRIES
    ADR R12, StepperTestTable
LoopTestTable:
    PUSH {R0}
    LDR R0, [R12]
    LDR R1, [R12, #4]
    PUSH {R12}
    BLX R1
    DELAY_ONE_SEC
    BL GetAngle
    POP {R12}
    POP {R0}
    SUB R0, #1
    CMP R0, #0
    BEQ Loop
    ;BNE CONITNUE
    ADD R12, #8
    B LoopTestTable

Loop:
    B Loop
    

StepperTestTable: 
    .word   720,        SetAngle
    .word   0xFFFFFD30, SetRelAngle ;-720
    .word   0,          SetRelAngle
    .word   350,        SetRelAngle
    .word   20,         SetAngle
    .word   0xFFFFFE98, SetRelAngle ;-360
    .word   0xFFFFFFFA, SetRelAngle ;-6
    .word   0xFFFFFFFA, SetRelAngle ;-6
    .word   0xFFFFFFFA, SetRelAngle ;-6
    .word   0,          SetAngle
    .word   12,         SetAngle
    .word   15,         SetAngle
    .word   10,         SetAngle
    .word   90,         SetAngle
    .word   180,        SetAngle
    .word   360,        SetAngle
    .word   720,        SetRelAngle
    .word   6,          SetRelAngle
    .word   0xFFFFFFFA, SetRelAngle ;-6
    .word   0xFFFFFF88, SetRelAngle ;-120
    .word   0xFFFFFF88, SetRelAngle ;-120
    .word   0xFFFFFE20, SetRelAngle ;-480
    .word   12,         SetRelAngle
    .word   0xFFFFFFF4, SetRelAngle ;-12
EndStepperTestTable:

    .align 4
addr_TopOfStack: .word TopOfStack
