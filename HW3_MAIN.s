;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 HW3_MAIN                                   ;
;                               LCD ROUTINES                                 ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program runs a subroutine that initializes the 
;                   launchpad and LCD, and tests LCD subroutines by printing
;                   characters and strings to the LCD with time delays. 
;
; Operation:        This program initializes the launchpad: enables the 
;                   power and clock for GPIO, Timer 0 and Timer 1, and 
;                   initializes Timer0B, Timer1A, Timer1B for timing delays 
;                   for LCD subroutines; and tests LCD routines by calling 
;                   DisplayChar and Display with time delays in between. 
;
; Local Variables:  None. 
; Shared Variables: None.
; Global Variables: None.
;
; Input:            None.
; Output:           A 2x24 LCD display that outputs given strings and chars.  
; User Interface:   A 2x24 LCD display that shows strings and characters.  
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Known Bugs:       None.
; Limitations:      None.
;
; Revision History:
;    11/23/19  Di Hu      Initial Revision
;    11/24/19  Di Hu      Added more test cases. 
;    12/24/19  Di Hu      Added macros PRINT_CHAR and PRINT_STR in test cases. 
;    01/10/20  Di Hu      Separated out InitSystemPower and InitSystemClock
;                         functions from main and put into HW3_SYS_INIT.s  


    ;include files 
    .include "HW3_CC26x2_DEFS.inc"
    .include "HW3_MACROS.inc"
    .include "HW3_LCD_TEST_VALUES.s"
    ;public functions 
    .ref InitSystemPower
    .ref InitSystemClock
    .ref InitOneShotTimer0B
    .ref InitOneShotTimer1A
    .ref InitOneShotTimer1B
    .ref InitLCDIO
    .ref LCD_Eight_Bit_Init
    .ref DisplayChar
    .ref Display
    .ref StartTimer1ACounter
    .ref WaitTillCountingDoneT1A


    .data                              ;allocate space for stack 
    .align 8
    .SPACE TOTAL_STACK_SIZE
TopOfStack:                            ;point to the bottom of the stack 

    .text
    .global ResetISR                   ;resets program when necessary 
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
    BL InitSystemPower
    BL InitSystemClock
    BL InitOneShotTimer0B              ;configure Timer0B for timing delays
    BL InitOneShotTimer1A              ;configure Timer1A for timing delays
    BL InitOneShotTimer1B              ;configure Timer1B for timing delays
    BL InitLCDIO 

; LCD test cases 
Test:
    BL LCD_Eight_Bit_Init 

;print single chars at different cursor positions 
    PRINT_CHAR LCD_FIRST_ROW, 0, char_t
    DELAY_ONE_SEC

    PRINT_CHAR LCD_SECOND_ROW, 2, char_e
    DELAY_ONE_SEC
    
    PRINT_CHAR LCD_FIRST_ROW, 4, char_s
    DELAY_ONE_SEC

    PRINT_CHAR LCD_SECOND_ROW, 6, char_t
    DELAY_ONE_SEC

    PRINT_CHAR LCD_FIRST_ROW, 8, char_i
    DELAY_ONE_SEC

    PRINT_CHAR LCD_SECOND_ROW, 10, char_n
    DELAY_ONE_SEC
    
    PRINT_CHAR LCD_FIRST_ROW, 12, char_g
    DELAY_ONE_SEC
    
    PRINT_CHAR LCD_SECOND_ROW, 14, char_c
    DELAY_ONE_SEC

    PRINT_CHAR LCD_FIRST_ROW, 16, char_h
    DELAY_ONE_SEC
    
    PRINT_CHAR LCD_SECOND_ROW, 18, char_a
    DELAY_ONE_SEC
    
    PRINT_CHAR LCD_FIRST_ROW, 20, char_r
    DELAY_ONE_SEC

;print a string that wraps to the second row 
    PRINT_STR LCD_SECOND_ROW, 0, str_completestr
    DELAY_ONE_SEC
    DELAY_ONE_SEC
    DELAY_ONE_SEC

;print a string that wraps to the first row 
    PRINT_STR LCD_CURR_ROW, LCD_CURR_COL, str_longstr
    DELAY_ONE_SEC
    DELAY_ONE_SEC
    DELAY_ONE_SEC

;print a string that wraps to the second row then to the first row 
    PRINT_STR LCD_FIRST_ROW, 0, str_wrap_instr
    DELAY_ONE_SEC
    DELAY_ONE_SEC
    DELAY_ONE_SEC

;print another string that wraps to the second row then to the first row 
    PRINT_STR LCD_FIRST_ROW, 0, str_clr_instr
    DELAY_ONE_SEC
    DELAY_ONE_SEC
    DELAY_ONE_SEC

;print a char at an invalid column position
;an error message would be printed instead of the character
    PRINT_CHAR LCD_FIRST_ROW, 24, char_r
    DELAY_ONE_SEC

;print a string at an invalid row position 
;an error message would be printed instead of the string
    PRINT_STR 3, 0, str_clr_instr
    DELAY_ONE_SEC
    DELAY_ONE_SEC
    DELAY_ONE_SEC

;string printed after erroneous strings/characters should be printed normally
    PRINT_STR LCD_FIRST_ROW, 0, str_err_instr
    DELAY_ONE_SEC
    DELAY_ONE_SEC
    DELAY_ONE_SEC

Loop:
    B Loop

    .align 4
addr_TopOfStack: .word TopOfStack
