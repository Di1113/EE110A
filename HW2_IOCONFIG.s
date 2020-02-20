;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW2_IOCONFIG.s                                 ;
;                           DIO CONFIGURATION                                ;
;                                 EE110A                                     ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains function for configuring IO pins and enabling output pins
; for keypad pins. 
; 
; FUNCTION INDEX: 
;   ConfigKeypadIOs - Configure IO pins for keypad scan functions. 
;
; REVISION HISTORY:
;     11/10/19  Di Hu      Initial Revision
;     11/21/19  Di Hu      Added comments
;	  11/25/19  Di Hu 	   Added ".text" and debugged hard fault

;   include files 
    .include "HW2_IOCONFIG_DEFS.inc"
    .include "HW2_CC26x2_DEFS.inc"
    .include "HW2_MACROS.inc"
;   public function
    .global ConfigKeypadIOs

	.text
; ConfigKeypadIOs
;
; Description:       This function configures IO pins for keypad scan functions 
;                    to detect key presses. 
;
; Operation:         This function enables DIO12..15 as output pins to select 
;                    columns for key press detection, and configure DIO4..5 as
;                    as input pins to select row for key press detection.
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
; Last Modified:     Nov 21, 2019

ConfigKeypadIOs:                       ;config IO pins for keypad 
    MV32 R1, #IOC_BASE_ADDR
    ;config output pins for keypad row selection 
    MOV R0, #IOCFG5_SETNS              
    STR R0, [R1, #IOCFG5_ADDR_OFFSET]  ;config DIO5 as no-pull output pins 
    MOV R0, #IOCFG4_SETNS              ;
    STR R0, [R1, #IOCFG4_ADDR_OFFSET]  ;config DIO4 as no-pull output pins 
    ;config input pins for keypad column selection 
    MV32 R0, #IOCFG15_SETNS            ;
    STR R0, [R1, #IOCFG15_ADDR_OFFSET] ;config DIO15 as pull-up input pins 
    MV32 R0, #IOCFG14_SETNS            
    STR R0, [R1, #IOCFG14_ADDR_OFFSET] ;config DIO14 as pull-up input pins 
    MV32 R0, #IOCFG13_SETNS            
    STR R0, [R1, #IOCFG13_ADDR_OFFSET] ;config DIO13 as pull-up input pins 
    MV32 R0, #IOCFG12_SETNS            
    STR R0, [R1, #IOCFG12_ADDR_OFFSET] ;config DIO12 as pull-up input pins 
    ; enable output pins for keypad
    MV32 R1, #GPIO_BASE_ADDR
    MOV R0, #KEYPAD_DOE31_0_SETNS
    STR R0, [R1, #DOE31_0_ADDR_OFFSET] ;enable output pins in GPIO.DOE31_0

    BX LR                              ;finished, return 


