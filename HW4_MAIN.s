;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 HW4_MAIN                                   ;
;                              SERVO ROUTINES                                ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program runs a subroutine that initializes Timer2A as
;                   a PWM timer, initializes TI CC26x2 launchpad and the 
;                   connected 4-pin servo motor, and tests servo motor routines
;                   by setting servo shaft to different positions and reading
;                   its current position, which is return in R0 in degrees.
;
; Operation:        This program initializes the launchpad by enabling the 
;                   power and clock for GPIO and Timer 2, initializes AUX's 
;                   ADC module for reading servo positions and initializes 
;                   Timer2A as a PWM timer to control servo. This program tests
;                   servo routines by calling SetServo to set servo shaft to 
;                   different positions and calling GetServo to get servo's 
;                   current position in R0.
;
; Local Variables:  R0 is used as return register for GetServo function to read
;					servo shaft's current position in degrees.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            Servo motor's ADC pin; for reading servo shaft position. 
; Output:           Servo motor's DAC pin; for setting servo shaft position. 
; User Interface:   A servo motor.
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Known Bugs:       None.
; Limitations:      - SetServo only takes arguments of degrees range from -90 to
;					  90, argument that exceeds this range would cause SetServo
;					  function to exit;
;					- noise exists in ADC;
;					- servo position read by GetServo has error range of -1 to 1
;				      degree.
;
; Revision History:
;    12/09/19  Di Hu      Initial Revision
;    12/29/19  Di Hu      Edited comments
;    01/10/20  Di Hu      - Added more test cases, 
;                         - Separated out InitSystemPower and InitSystemClock
;                           functions from main and put into HW4_SYS_INIT.s  

    ;include files 
    .include "HW4_CC26x2_DEFS.inc"
    .include "HW4_MACROS.inc"

    ;public functions 
    .ref InitSystemPower
    .ref InitSystemClock
    .ref InitServoIO
    .ref InitADC
    .ref InitPWMTimer2A
    .ref SetServo
    .ref GetServo

    ;for testing


    .data                              ;allocate space for stack 
    .align 8
    .SPACE TOTAL_STACK_SIZE
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
    BL InitSystemPower                 ;enable power for GPIO 
    BL InitSystemClock                 ;enable clock for GPIO and GPTn 
    BL InitServoIO                     ;init IO for controlling and reading servo 
    BL InitADC                         ;configure ADC settings  
    BL InitPWMTimer2A                  ;initialize Timer2A as a PWM timer to 
                                       ;    control servo 

;GetZeroPos:
    MV32 R0, #0						;set to 0 degree
    BL SetServo

    BL GetServo

    MOV R0, #90 					;counter-clockwise half circle
    BL SetServo

    BL GetServo

    MV32 R0, #0xFFFFFFD3 			;clockwise quater circle(-45)
    BL SetServo

    BL GetServo

    MV32 R0, #NEG_NINETY 			;clockwise half circle
    BL SetServo

    BL GetServo

    MV32 R0, #0xFFFFFFF6 			;clockwise 10 degrees
    BL SetServo

    BL GetServo

    MV32 R0, #10 					;counter-clockwise 10 degrees
    BL SetServo

    BL GetServo

    MV32 R0, #30 					;counter-clockwise 30 degrees
    BL SetServo

    BL GetServo

    MV32 R0, #0xFFFFFFC9 			;clockwise 55 degrees
    BL SetServo

    BL GetServo

    MV32 R0, #98 					;invalid position arguments, servo would
    BL SetServo						;	not response

    BL GetServo

	MV32 R0, #0xFFFFFF9C     		;invalid position arguments, servo would
    BL SetServo						;	not response

    BL GetServo

Loop:
    B Loop
    
    .align 4
addr_TopOfStack: .word TopOfStack
