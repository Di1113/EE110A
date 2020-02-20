;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                            HW5_IOCONFIG_DEFS.inc                           ;
;                              IO Configuration                              ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the setting values for configuring IO pins for stepper 
; control. 
; 
; CONSTANT INDEX: 
;     Output: 
;       IOCFG0_SETNS - configure DIO0 as a no-pull output pin 
;       IOCFG1_SETNS - configure DIO1 as a no-pull output pin 
;       IOCFG2_SETNS - configure DIO2 as a no-pull output pin that listens to
;                      PWM Timer3A 
;       IOCFG3_SETNS - configure DIO3 as a no-pull output pin that listens to
;                      PWM Timer3B
;       STEPPER_OUTPUT_PIN_MASK - enable stepper output pins in DOE31_0 
;       
;
; REVISION HISTORY:
;     12/17/19  Di Hu      Initial Revision
;     12/31/19  Di Hu      Edited comments 
    
    .data


;stepper output pin for enable control
IOCFG0_SETNS            .EQU    0x00006000 ;no pull, output 
                                     ;| 
                                     ;0110(PULL_CTL: No pull)
IOCFG1_SETNS            .EQU    0x00006000 ;no pull, output 
                                     ;| 
                                     ;0110(PULL_CTL: No pull)

;stepper output pin for PWM control (Digital to Analog) 
IOCFG2_SETNS            .EQU    0x0000601D
                                     ;| |
                                     ;0110(PULL_CTL: No pull)
                                     ;  |
                                     ;  011101(PORT_ID: PORT_EVENT6(Timer3A)) 
IOCFG3_SETNS            .EQU    0x0000601E
                                     ;| |
                                     ;0110(PULL_CTL: No pull)
                                     ;  |
                                     ;  011110(PORT_ID: PORT_EVENT7(Timer3B)) 

;enable output pins in GPIO.DOE31_0 register 
STEPPER_OUTPUT_PIN_MASK   .EQU  0x0000000F
                                        ;|
                                        ;1111(DIO0..3 enabled)


