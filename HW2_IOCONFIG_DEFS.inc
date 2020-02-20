;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW2_IOCONFIG_DEFS.inc                          ;
;                              IO Configuration                              ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the setting values for configuring IO pins. 
; 
; CONSTANT INDEX: 
;   Keypad Pins: 
;     Output: 
;       IOCFG4_SETNS - output value to decoder to select row to scan 
;       IOCFG4_SETNS - output value to decoder to select row to scan
;     Input: 
;       IOCFG12_SETNS - detect key press on the most right column on keypad 
;       IOCFG13_SETNS - detect key press on the second right column on keypad 
;       IOCFG14_SETNS - detect key press on the third right column on keypad 
;       IOCFG15_SETNS - detect key press on the most left column on keypad 
;   General IO Registers: 
;       
;
; REVISION HISTORY:
;     11/10/19  Di Hu      Initial Revision
;     11/20/19  Di Hu      - Added comments. 
;                          - Separate out address constants to CC26x2_DEFS.inc.

    .data

;KEYPAD 
;output pins for row selection  
IOCFG5_SETNS        .EQU    0x00006000
                                 ;|
                                 ;0110(PULL_CTL: No pull)
IOCFG4_SETNS        .EQU    0x00006000
                                 ;|
                                 ;0110(PULL_CTL: No pull)
;input pins for column detection 
IOCFG15_SETNS        .EQU    0x20004000
                              ;|   |
                              ;0010(IE:Input enabled)
                              ;    |
                              ;    0100(PULL_CTL: Pull up)
IOCFG14_SETNS        .EQU    0x20004000
                              ;|   |
                              ;0010(IE:Input enabled)
                              ;    |
                              ;    0100(PULL_CTL: Pull up)
IOCFG13_SETNS        .EQU    0x20004000
                              ;|   |
                              ;0010(IE:Input enabled)
                              ;    |
                              ;    0100(PULL_CTL: Pull up)
IOCFG12_SETNS        .EQU    0x20004000
                              ;|   |
                              ;0010(IE:Input enabled)
                              ;    |
                              ;    0100(PULL_CTL: Pull up)
;enable output pins in GPIO.DOE31_0 register 
KEYPAD_DOE31_0_SETNS        .EQU    0x000000030
                                            ;|
                                            ;0011(DIO5, DIO4 enabled)
                                            ;Other DIOs are either inputs or not initialized
