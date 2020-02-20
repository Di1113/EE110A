;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW4_IOCONFIG_DEFS.inc                          ;
;                              IO Configuration                              ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the setting values for configuring IO pins for servo 
; control(DAC output) and for reading servo shaft analog data(ADC input).
; 
; CONSTANT INDEX: 
;   Keypad Pins: 
;     Output: 
;       IOCFG11_SETNS - configure DIO11 as output pin for servo motor control
;     Input: 
;       IOCFG24_SETNS - configure DIO23 as input pin for reading servo shaft
;                       position data
;
; REVISION HISTORY:
;     12/10/19  Di Hu      Initial Revision
;     12/11/19  Di Hu      Updated IOCFG11_SETNS' port id to be PWM timer 2A 
;     12/28/19  Di Hu      Edited comments 

    .data


;servo output pin for PWM control (Digital to Analog) 
IOCFG11_SETNS        .EQU    0x0000601B
                                  ;| |
                                  ;0110(PULL_CTL: No pull)
                                  ;  |
                                  ;  011011(PORT_ID: PORT_EVENT4(Timer2A)) 
;servo input pin for reading analog values (Analog to Digital) 
IOCFG24_SETNS        .EQU    0x20006008
                              ;|   | |
                              ;0010(IE:Input enabled)
                              ;    | |
                              ;    0110(PULL_CTL: No pull)
                              ;      |
                              ;      001000(PORT_ID:AUX IO)

;enable output pins in GPIO.DOE31_0 register 
SERVO_OUTPUT_PIN_MASK   .EQU    0x00000800
                                      ;|
                                      ;1000(DIO11 enabled)


