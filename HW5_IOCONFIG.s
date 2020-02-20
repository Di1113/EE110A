;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW5_IOCONFIG.s                                 ;
;                           DIO CONFIGURATION                                ;
;                                 EE110A                                     ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains function for configuring IO pins and enabling output pins
; for controlling step motor. 
;
; FUNCTION INDEX: 
;     InitStepperIO - Configure IO pins for step motor's control routines. 
;
; REVISION HISTORY:
;     12/17/19  Di Hu      Initial Revision
;     12/31/19  Di Hu      Edited comments 

;   include files 
    .include "HW5_IOCONFIG_DEFS.inc"
    .include "HW5_CC26x2_DEFS.inc"
    .include "HW5_MACROS.inc"

;   public function
    .global InitStepperIO


    .text
;code starts 


; InitStepperIO
;
; Description:       This function configures DIO0, DIO1 as no-pull output pins
;                    enabling control A and control for stepper control, and 
;                    configures DIO2 and DIO3 as no-pull output pins that each
;                    listens to PWM timer 3A and 3B.  
;
; Operation:         This function configures DIO0..3 in IOC registers and 
;                    enable them as output pins in DOE31_0 register. 
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
; Registers Changed: R0, R1
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Dec 17, 2019

InitStepperIO:                       
    MV32 R1, #IOC_BASE_ADDR

    MOV R0, #IOCFG0_SETNS              
    STR R0, [R1, #IOCFG0_ADDR_OFFSET]  ;config DIO0 as a no-pull output pin 
    
    MOV R0, #IOCFG1_SETNS              
    STR R0, [R1, #IOCFG1_ADDR_OFFSET]  ;config DIO1 as a no-pull output pin

    MOV R0, #IOCFG2_SETNS              
    STR R0, [R1, #IOCFG2_ADDR_OFFSET]  ;config DIO2 as a no-pull pwm timer
                                       ;    output pin 
    
    MOV R0, #IOCFG3_SETNS              
    STR R0, [R1, #IOCFG3_ADDR_OFFSET]  ;config DIO3 as a no-pull pwm timer
                                       ;    output pins

    MV32 R1, #GPIO_BASE_ADDR
    LDR R0, [R1, #DOE31_0_ADDR_OFFSET]
    ORR R0, R0, #STEPPER_OUTPUT_PIN_MASK 
    STR R0, [R1, #DOE31_0_ADDR_OFFSET] ;enable output pins in GPIO.DOE31_0

    BX LR 
