;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW4_IOCONFIG.s                                 ;
;                           DIO CONFIGURATION                                ;
;                                 EE110A                                     ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains function for initializing servo output and input pins for
; controlling servo shaft and for reading shaft position.
;
; FUNCTION INDEX: 
;   InitServoIO - configure DIO11 as DAC output pin for servo control, and 
;                 configure DIO24 as ADC input pin for reading servo position
;
; REVISION HISTORY:
;     12/06/19  Di Hu      Initial Revision
;     12/28/19  Di Hu      Edited comments 

;   include files 
    .include "HW4_IOCONFIG_DEFS.inc"
    .include "HW4_CC26x2_DEFS.inc"
    .include "HW4_MACROS.inc"

;   public function
    .global InitServoIO


	.text
;code starts 

; InitServoIO
;
; Description:       This function configures DIO11 as DAC output for servo
;                    control and configures DIO24 as ADC input for reading 
;                    servo position.
;
; Operation:         This function sets DIO11 to listen to PWM timer Timer2A
;                    and sets DIO24 as AUX IO 25. 
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
; Registers Changed: R0, R1, LR 
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Nov 27, 2019
InitServoIO:                     
    MV32 R1, #IOC_BASE_ADDR
    MOV R0, #IOCFG11_SETNS              
    STR R0, [R1, #IOCFG11_ADDR_OFFSET]  ;config DIO11 as a no-pull output pin 
    MV32 R0, #IOCFG24_SETNS            
    STR R0, [R1, #IOCFG24_ADDR_OFFSET]  ;config DIO24 as a no-pull input pin 
    
    MV32 R1, #GPIO_BASE_ADDR
    LDR R0, [R1, #DOE31_0_ADDR_OFFSET]
    ORR R0, R0, #SERVO_OUTPUT_PIN_MASK 
    STR R0, [R1, #DOE31_0_ADDR_OFFSET] ;enable DIO11 in GPIO.DOE31_0

    BX LR 
