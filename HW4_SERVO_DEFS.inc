;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                              HW4_SERVO_DEFS.inc                            ;
;                                Servo Control                               ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the setting values for configuring ADC module and trigger
; ADC conversion and constants used to convert servo voltage value to position
; degrees.  
; 
; CONSTANT INDEX: 
;     AUX_AIODIO3:
;         AUXIO25_IOMODE_SETNS   -  set IO mode for AUX IO pins 
;         AUXIO25_GPIODIE_SETNS  -  enable input buffer for AUX input pins.
;     AUX_SYSIF_ADCCLKCTL:        
;         ADC_CLOCK_REQ_MASK     -  set request to enable ADC clock 
;         ADC_CLOCK_ACK_MASK     -  acknowledge ADC clock set 
;     AUX_ADI4: 
;         ADC0_EN_CLR_MASK       -  clear ADC0 enable bit for configuration
;         ADC0_RESET_CLR_MASK    -  clear ADC0 reset bit for configuration
;         ADC0_SETNS_MASK        -  configure ADC as asynchronous mode. 
;         ADC0_EN_SET_MASK       -  set ADC0 enable bit 
;         ADC0_RESET_SET_MASK    -  set ADC0 reset bit     
;         AUX_MUX3_SETNS         -  select AUX IO pin for IO 
;         ADCREF0_EN_MASK        -  enable ADC reference module
;     AUX_ANAIF:
;         ADCCTL_CMD_MASK        -  clear CMD bits for configuration 
;         ADCCTL_EN_MASK         -  enable ADC interface 
;         ADCCTL_NOEVENT_MASK    -  set ADC to manual trigger mode 
;         ADCCTL_FLUSH_MASK      -  flush ADC sample in FIFO 
;         ADCTRIG_TRIG_MASK      -  enable ADC single trigger 
;     AUX_EVCTL_EVTOMCUFLAGS & AUX_EVCTL_EVTOMCUFLAGSCLR: 
;         AUX_ADC_DONE_MASK      -  check if ADC-done flag bit is set and 
;                                   clear ADC-done flag bit for next read 
;     Constants for Voltage to Degrees Conversion: 
;         CLK_PER_DEG            -  clocks needed to rotate one degree 
;         SERVO_BASE_POS_VOL     -  voltage value when servo is at 0 degree pos
;         VOL_TO_DEGREE_DIVISOR  -  reciprocal of degree / voltage value ratio 
;         FIXED_POINT_I_LEN      -  for fixed point multiplication reduction 
;         FIXED_POINT_F_LEN      -  for fixed point multiplication trunaction    
;
; REVISION HISTORY:
;     12/11/19  Di Hu      Initial Revision
;     12/29/19  Di Hu      Edited comments 


    .data


;definitions for AUX IO settings 
;configure in AUX_AIODIO3 (control AUX IO 24 to 31)
AUXIO25_IOMODE_SETNS    .EQU    0x00000004
                                 ;|      |
                                 ;(31-16: RESERVED)
                                 ;       |
                                 ;       0100(IO1: set Input Mode for AUXIO25) 
AUXIO25_GPIODIE_SETNS   .EQU    0x00000002
                                 ;|     |
                                 ;(31-8: RESERVED)
                                 ;      |
                                 ;      00000010(enable digital input buffer for AUXIO25)

;configure in AUX_SYSIF_ADCCLKCTL 
ADC_CLOCK_REQ_MASK      .EQU    0x00000001  ;set clock request
                                        ;|
                                        ;0001(REQ: enable ADC clock)
ADC_CLOCK_ACK_MASK      .EQU    0x00000002  ;check clock is enabled
                                        ;|
                                        ;0010(ACK: ADC clock is enabled)
;configure in AUX_ADI4_ADC0
ADC0_EN_CLR_MASK        .EQU    0x000000FE
                                       ;|
                                       ;11111110
                                              ;|
                                              ;clear enable bit for configuration
ADC0_RESET_CLR_MASK     .EQU    0x000000FD
                                       ;|
                                       ;11111101
                                             ;|
                                             ;clear reset bit for configuration
ADC0_SETNS_MASK         .EQU    0x00000080   ;configure ADC settings
                                       ;|
                                       ;10000000
                                       ;||   |||
                                       ;SMPL_MODE: asynchronous(sets ANAIF.ADCTL.START_SRC to NO_EVENT)
                                       ; |   |||
                                       ; SMPL_CYCLE_EXP: has no effect in asynchronous mode
                                       ;     |||
                                       ;     RESERVED
                                       ;      ||
                                       ;      RESET_N
                                       ;       |
                                       ;       EN
ADC0_EN_SET_MASK        .EQU    0x00000001
                                        ;|
                                        ;00000001
                                               ;|
                                               ;set enable bit for configuration
ADC0_RESET_SET_MASK     .EQU    0x00000002
                                       ;|
                                       ;00000010
                                             ;|
                                             ;set reset bit for configuration
;configure in AUX_ADI4_MUX3
AUX_MUX3_SETNS          .EQU    0x00000002
                                       ;|
                                       ;00000010
                                             ;|
                                             ;select AUX IO pin 25
;configure in AUX_ADI4_ADCREF0
ADCREF0_EN_MASK         .EQU    0x00000001
                                        ;|
                                        ;00000001
                                               ;|
                                               ;enable ADC reference module
;configure in AUX_ANAIF 
ADCCTL_CMD_MASK         .EQU    0xFFFFFFFC
                                        ;|
                                        ;1100
                                        ;  |
                                        ;  mask out the CMD bits for configuration 
ADCCTL_EN_MASK          .EQU    0x00000001
                                        ;|
                                        ;0001
                                        ;   |
                                        ;   enable ADC interface 
ADCCTL_NOEVENT_MASK     .EQU    0x00003F00
                                     ;|
                                     ;NO_EVENT, manually trigger ADC
ADCCTL_FLUSH_MASK       .EQU    0x00000003
                                        ;|
                                        ;0011
                                        ;   |
                                        ;   flush ADC interface 
ADCTRIG_TRIG_MASK       .EQU    0x00000001
                                        ;|
                                        ;0001
                                        ;   |
                                        ;   single ADC trigger 
;check ADC conversion status in AUX_EVCTL_EVTOMCUFLAGS
;   and clear ADC-done flag bit in AUX_EVCTL_EVTOMCUFLAGSCLR
AUX_ADC_DONE_MASK       .EQU    0x00000080
                                       ;|
                                       ;1000
                                       ;|
                                       ;AUX_ADC_DONE 

;constants used to convert voltage value to position degrees 
CLK_PER_DEG             .EQU    533     ;90 degree takes 1 ms which 48000 clocks, 
                                        ;  so each degree takes about 533 clocks
SERVO_BASE_POS_VOL      .EQU    0x820   ;digital voltage value when servo is
                                        ;  at 0 degree position 
VOL_TO_DEGREE_DIVISOR   .EQU    0xFFFFFFE2
                                        ;fixed point value, -0.1171875 
                                        ;                   (close to 1/8.67)
                                        ;= 1 / ((voltage at 90 degrees - 
                                        ;        voltage at -90 degrees) 
                                        ;       / 180)
FIXED_POINT_I_LEN       .EQU    7       ;bits before fixed point in Q7.8 
FIXED_POINT_F_LEN       .EQU    8       ;bits after fixed point in Q7.8