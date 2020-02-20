;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                          HW3_LCD_TEST_VALUES.inc                           ;
;                          LCD Routine Test Values                           ;
;                                   EE110A                                   ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains test values to LCD and DisplayChar and Display routines
; in the main. 
; 
; VALUE INDEX: 
;       char_a: character 'a'
;       char_c: character 'c'
;       char_e: character 'e'
;       char_g: character 'g'
;       char_h: character 'h'
;       char_i: character 'i'
;       char_n: character 'n'
;       char_r: character 'r'
;       char_s: character 's'
;       char_t: character 't'
;       str_completestr: string for testing  
;       str_longstr:     string for testing  
;       str_wrap_ins:    string for testing 
;       str_clr_inst:    string for testing 
;       str_err_instr:   string for testing 
;
; REVISION HISTORY:
;     12/21/19  Di Hu      Initial Revision, moved out from LCD.s
;     12/27/19  Di Hu      Added comments  

    .text 

    .align 4
char_a: .string "a"
    .align 4
char_c: .string "c"
    .align 4
char_e: .string "e"
    .align 4
char_g: .string "g"
    .align 4
char_h: .string "h"
    .align 4
char_i: .string "i"
    .align 4
char_n: .string "n"
    .align 4
char_r: .string "r"
    .align 4
char_s: .string "s"
    .align 4
char_t: .string "t"

    .align 4
str_completestr: .cstring "This is a complete string."
    .align 4
str_longstr: .cstring "Though there is no way to tell a string and an array of characters by eyes."
    .align 4
str_wrap_instr: .cstring "This program wraps the string to a new line when its length exceeds current LCD row length."
    .align 4
str_clr_instr: .cstring "This program clears screen when screen is full and waits for two seconds before clearing."
    .align 4
str_err_instr: .cstring "This program prints error message when cursor position is out of range."
