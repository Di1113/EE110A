;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW3_IOCONFIG.s                                 ;
;                           DIO CONFIGURATION                                ;
;                                 EE110A                                     ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains function for initializing LCD control pins as outputs and
; functions for configuring LCD data pins as outputs or inputs.
; 
; FUNCTION INDEX: 
;   InitLCDIO       - configure DIO8..10 as outputs for LCD controls 
;   InitOutputLCDDB - configure DIO16..23 as outputs for LCD data bus 
;   InitInputLCDDB  - configure DIO16..23 as inputs for LCD data bus 
;
; REVISION HISTORY:
;     11/28/19  Di Hu      Initial Revision
;     12/27/19  Di Hu      Added comments 

;   include files 
    .include "HW3_IOCONFIG_DEFS.inc"
    .include "HW3_CC26x2_DEFS.inc"
    .include "HW3_MACROS.inc"

;   public function
    .global InitLCDIO
    .global InitOutputLCDDB
    .global InitInputLCDDB


	.text
;code starts 

; InitLCDIO
;
; Description:       This function configures DIO8..10 pins as outputs
;                    for LCD's control pins: RS, R/~W, and Enable selects. 
;
; Operation:         This function configures DIO8..10 as output pins in IOC 
;                    registers and enable them as outputs in GPIO.DOE31_0 
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
; Last Modified:     Nov 28, 2019
InitLCDIO:                       ;config LCD's r/~w, rs and e pins as output
    MV32 R1, #IOC_BASE_ADDR
    MOV R0, #IOCFG10_SETNS              
    STR R0, [R1, #IOCFG10_ADDR_OFFSET] ;config DIO10 as no-pull output pins 
    MOV R0, #IOCFG9_SETNS              
    STR R0, [R1, #IOCFG9_ADDR_OFFSET]  ;config DIO9 as no-pull output pins 
    MOV R0, #IOCFG8_SETNS             
    STR R0, [R1, #IOCFG8_ADDR_OFFSET]  ;config DIO8 as no-pull output pins
    
    MV32 R1, #GPIO_BASE_ADDR
    LDR R0, [R1, #DOE31_0_ADDR_OFFSET]
    ORR R0, R0, #LCD_CTL_OUTPUT_MASK 
    STR R0, [R1, #DOE31_0_ADDR_OFFSET] ;enable them as outputs GPIO.DOE31_0

    BX LR 


; InitOutputLCDDB
;
; Description:       This function configures DIO16..23 pins as outputs
;                    for LCD's 2-byte data bus. 
;
; Operation:         This function configures DIO16..23 as output pins in IOC 
;                    registers and enable them as outputs in GPIO.DOE31_0 
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
; Registers Changed: R0, R1, R2 
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Nov 28, 2019
InitOutputLCDDB:
    MV32 R1, #IOC_BASE_ADDR
    MOV R0, #IOCFG23_OUT_SETNS              
    STR R0, [R1, #IOCFG23_ADDR_OFFSET]  ;config DIO23 as no-pull output pins 
    MOV R0, #IOCFG22_OUT_SETNS              
    STR R0, [R1, #IOCFG22_ADDR_OFFSET]  ;config DIO22 as no-pull output pins 
    MOV R0, #IOCFG21_OUT_SETNS              
    STR R0, [R1, #IOCFG21_ADDR_OFFSET]  ;config DIO21 as no-pull output pins
    MOV R0, #IOCFG20_OUT_SETNS              
    STR R0, [R1, #IOCFG20_ADDR_OFFSET]  ;config DIO20 as no-pull output pins 
    MOV R0, #IOCFG19_OUT_SETNS              
    STR R0, [R1, #IOCFG19_ADDR_OFFSET]  ;config DIO19 as no-pull output pins 
    MOV R0, #IOCFG18_OUT_SETNS              
    STR R0, [R1, #IOCFG18_ADDR_OFFSET]  ;config DIO18 as no-pull output pins
    MOV R0, #IOCFG17_OUT_SETNS              
    STR R0, [R1, #IOCFG17_ADDR_OFFSET]  ;config DIO17 as no-pull output pins 
    MOV R0, #IOCFG16_OUT_SETNS              
    STR R0, [R1, #IOCFG16_ADDR_OFFSET]  ;config DIO16 as no-pull output pins

    MV32 R1, #GPIO_BASE_ADDR
    LDR R0, [R1, #DOE31_0_ADDR_OFFSET]
    MV32 R2, #LCD_OUTPUT_DB_MASK
    ORR R0, R0, R2
    STR R0, [R1, #DOE31_0_ADDR_OFFSET] ;enable output pins in GPIO.DOE31_0

    BX LR 


; InitOutputLCDDB
;
; Description:       This function configures DIO16..23 pins as inputs 
;                    for LCD's 2-byte data bus. 
;
; Operation:         This function configures DIO16..23 as input pins in IOC 
;                    registers and disable them in GPIO.DOE31_0. 
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
; Registers Changed: R0, R1, R2 
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Nov 28, 2019
InitInputLCDDB:  
    MV32 R1, #IOC_BASE_ADDR
    MV32 R0, #IOCFG23_IN_SETNS              
    STR R0, [R1, #IOCFG23_ADDR_OFFSET]  ;config DIO23 as pull-up input pins 
    MV32 R0, #IOCFG22_IN_SETNS              
    STR R0, [R1, #IOCFG22_ADDR_OFFSET]  ;config DIO22 as pull-up input pins  
    MV32 R0, #IOCFG21_IN_SETNS              
    STR R0, [R1, #IOCFG21_ADDR_OFFSET]  ;config DIO21 as pull-up input pins 
    MV32 R0, #IOCFG20_IN_SETNS              
    STR R0, [R1, #IOCFG20_ADDR_OFFSET]  ;config DIO20 as pull-up input pins 
    MV32 R0, #IOCFG19_IN_SETNS              
    STR R0, [R1, #IOCFG19_ADDR_OFFSET]  ;config DIO19 as pull-up input pins 
    MV32 R0, #IOCFG18_IN_SETNS              
    STR R0, [R1, #IOCFG18_ADDR_OFFSET]  ;config DIO18 as pull-up input pins 
    MV32 R0, #IOCFG17_IN_SETNS              
    STR R0, [R1, #IOCFG17_ADDR_OFFSET]  ;config DIO17 as pull-up input pins 
    MV32 R0, #IOCFG16_IN_SETNS              
    STR R0, [R1, #IOCFG16_ADDR_OFFSET]  ;config DIO16 as pull-up input pins 

    MV32 R1, #GPIO_BASE_ADDR
    LDR R0, [R1, #DOE31_0_ADDR_OFFSET]
    MV32 R2, #LCD_INPUT_DB_MASK
    AND R0, R0, R2
    STR R0, [R1, #DOE31_0_ADDR_OFFSET] ;disable data input pins in GPIO.DOE31_0

    BX LR 

