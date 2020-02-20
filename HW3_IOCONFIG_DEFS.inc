;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW3_IOCONFIG_DEFS.inc                          ;
;                              IO Configuration                              ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the setting values for configuring IO pins. 
; 
; CONSTANT INDEX: 
;   LCD Pins: 
;     Control Output: 
;       IOCFG10_SETNS       - configure DIO10 as output pin for E select 
;       IOCFG9_SETNS        - configure DIO9 as output pin for R/~W select 
;       IOCFG8_SETNS        - configure DIO8 as output pin for RS select 
;     Output:
;       IOCFG23_OUT_SETNS   - configure DIO23 as output pin for 2-byte data bus
;       IOCFG22_OUT_SETNS   - configure DIO22 as output pin for 2-byte data bus
;       IOCFG21_OUT_SETNS   - configure DIO21 as output pin for 2-byte data bus
;       IOCFG20_OUT_SETNS   - configure DIO20 as output pin for 2-byte data bus
;       IOCFG19_OUT_SETNS   - configure DIO19 as output pin for 2-byte data bus
;       IOCFG18_OUT_SETNS   - configure DIO18 as output pin for 2-byte data bus
;       IOCFG17_OUT_SETNS   - configure DIO17 as output pin for 2-byte data bus
;       IOCFG16_OUT_SETNS   - configure DIO16 as output pin for 2-byte data bus
;       LCD_CTL_OUTPUT_MASK - enable DIO8..10 as output pins in GPIO.DOE31_0
;       LCD_OUTPUT_DB_MASK  - enable DIO16..23 as output pins in GPIO.DOE31_0
;     Input: 
;       IOCFG23_IN_SETNS    - configure DIO23 as input pin for 2-byte data bus
;       IOCFG22_IN_SETNS    - configure DIO22 as input pin for 2-byte data bus
;       IOCFG21_IN_SETNS    - configure DIO21 as input pin for 2-byte data bus
;       IOCFG20_IN_SETNS    - configure DIO20 as input pin for 2-byte data bus
;       IOCFG19_IN_SETNS    - configure DIO19 as input pin for 2-byte data bus
;       IOCFG18_IN_SETNS    - configure DIO18 as input pin for 2-byte data bus
;       IOCFG17_IN_SETNS    - configure DIO17 as input pin for 2-byte data bus
;       IOCFG16_IN_SETNS    - configure DIO16 as input pin for 2-byte data bus
;       LCD_INPUT_DB_MASK   - disable DIO16..23 input pins in GPIO.DOE31_0
;
; REVISION HISTORY:
;     11/28/19  Di Hu      Initial Revision
;     12/25/19  Di Hu      Added comments 

    .data

;LCD  
;control output pins 
IOCFG10_SETNS           .EQU    0x00006000
                                     ;|
                                     ;0110(PULL_CTL: No pull)
                                     ; enable(E) select  
IOCFG9_SETNS            .EQU    0x00006000
                                     ;|
                                     ;0110(PULL_CTL: No pull)
                                     ; R/~W select 
IOCFG8_SETNS            .EQU    0x00006000
                                     ;|
                                     ;0110(PULL_CTL: No pull)
                                     ; RS select 
;data output pin configuration
IOCFG23_OUT_SETNS       .EQU    0x00006000
                                     ;|
                                     ;0110(PULL_CTL: No pull)
IOCFG22_OUT_SETNS       .EQU    0x00006000
                                     ;|
                                     ;0110(PULL_CTL: No pull)
IOCFG21_OUT_SETNS       .EQU    0x00006000
                                     ;|
                                     ;0110(PULL_CTL: No pull)
IOCFG20_OUT_SETNS       .EQU    0x00006000
                                     ;|
                                     ;0110(PULL_CTL: No pull)
IOCFG19_OUT_SETNS       .EQU    0x00006000
                                     ;|
                                     ;0110(PULL_CTL: No pull)
IOCFG18_OUT_SETNS       .EQU    0x00006000
                                     ;|
                                     ;0110(PULL_CTL: No pull)
IOCFG17_OUT_SETNS       .EQU    0x00006000
                                     ;|
                                     ;0110(PULL_CTL: No pull)
IOCFG16_OUT_SETNS       .EQU    0x00006000
                                     ;|
                                     ;0110(PULL_CTL: No pull)
;data input pin configuration
IOCFG23_IN_SETNS        .EQU    0x20004000
                                 ;|   |
                                 ;0010(IE:Input enabled)
                                 ;    |
                                 ;    0100(PULL_CTL: Pull up)
IOCFG22_IN_SETNS        .EQU    0x20004000
                                 ;|   |
                                 ;0010(IE:Input enabled)
                                 ;    |
                                 ;    0100(PULL_CTL: Pull up)
IOCFG21_IN_SETNS        .EQU    0x20004000
                                 ;|   |
                                 ;0010(IE:Input enabled)
                                 ;    |
                                 ;    0100(PULL_CTL: Pull up)
IOCFG20_IN_SETNS        .EQU    0x20004000    
                                 ;|   |
                                 ;0010(IE:Input enabled)
                                 ;    |
                                 ;    0100(PULL_CTL: Pull up)
IOCFG19_IN_SETNS        .EQU    0x20004000
                                 ;|   |
                                 ;0010(IE:Input enabled)
                                 ;    |
                                 ;    0100(PULL_CTL: Pull up)
IOCFG18_IN_SETNS        .EQU    0x20004000
                                 ;|   |
                                 ;0010(IE:Input enabled)
                                 ;    |
                                 ;    0100(PULL_CTL: Pull up)
IOCFG17_IN_SETNS        .EQU    0x20004000
                                 ;|   |
                                 ;0010(IE:Input enabled)
                                 ;    |
                                 ;    0100(PULL_CTL: Pull up)
IOCFG16_IN_SETNS        .EQU    0x20004000
                                 ;|   |
                                 ;0010(IE:Input enabled)
                                 ;    |
                                 ;    0100(PULL_CTL: Pull up)

;config output pins in GPIO.DOE31_0 register 
LCD_CTL_OUTPUT_MASK     .EQU    0x00000700
                                      ;|
                                      ;0111(DIO10, DIO9, DIO8 enabled)
                                      ; for enabling control pins as outputs 
LCD_OUTPUT_DB_MASK      .EQU    0x00FF0000
                                   ;|
                                   ;11111111(DIO23..16 enabled)
                                   ; for enabling data pins as outputs 
LCD_INPUT_DB_MASK       .EQU    0xFF00FFFF
                                   ;|
                                   ;00000000(DIO23..16 disabled)
                                   ; for disabling data pins as outputs 