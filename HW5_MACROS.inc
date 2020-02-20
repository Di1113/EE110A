;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                               HW5_MACROS.inc                               ;
;                              Macro Definitions                             ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains macro definitions used in all assembly files for HW1, 
; HW2, HW3, HW4 and HW5.
;
; MACRO INDEX:
;   MV32           - copy a 32-bit immediate value to a register
;   RDVAR          - read a variable's value from its pointer to a register
;   WRVAR          - write a register's value to a variable through its pointer
;   RESETVAR       - reset a variable's value with a 16-bit immediate value
;   DELAY_ONE_SEC  - call StartTimer1ACounter and WaitTillCountingDoneT1A
;                    three times to time an 1 second delay 
;   PRINT_CHAR     - call DisplayChar to print a character on LCD Display
;   PRINT_STR      - call Display to print a string on LCD Display
;
; REVISION HISTORY:
;   11/10/19  Di Hu      Initial Revision
;   11/22/19  Di Hu      Added comments.
;   12/22/19  Di Hu      Added DELAY_ONE_SEC, PRINT_CHAR, PRINT_STR.
;   01/11/20  Di Hu      Added Register changed description for all macros. 


    .data 
; Name:         MV32
; Description:  Copy a 32-bit immediate value immed into a register.
; Parameters:   register: 32-bit register;
;               immed: 32-bit immediate value.
; Register changed:
;               None. 
MV32    .macro register, immed
    MOV     register, immed & 0xFFFF   ;copy the lower 2-byte value first
    MOVT    register, immed >> 16      ;copy the higher 2-byte value without
                                       ;   changing the lower 2 bytes.
        .endm


; Name:         RDVAR
; Description:  Read variable pointer(addr_var)'s value into a register
; Parameters:   register: destination register to be loaded with value
;               addr_var: variable pointer
; Register changed:
;               R0 
RDVAR   .macro register, addr_var
    LDR R0, addr_var  ;load variable's address into R0
    LDR register, [R0];load variable's value into register
        .endm


; Name:         WRVAR
; Description:  Write a register's value into variable pointer(addr_var)
; Parameters:   register: register with value to be written into addr_var
;               addr_var: variable pointer
; Register changed:
;               R0 
WRVAR   .macro register, addr_var
    LDR R0, addr_var    ;load variable's address into R0
    STR register, [R0]  ;store register's value into that address
        .endm


; Name:         RESETVAR
; Description:  Reset a variable's value with a 16-bit immediate value.
; Parameters:   addr_var: variable pointer
;               immed: default value to write into the variable
; Register changed:
;               R0, R1 
RESETVAR    .macro addr_var, immed
    MOV R0, #immed    ;copy immed value to R0
    LDR R1, addr_var  ;load variable's address into R1
    STR R0, [R1]      ;store immed value to variable
            .endm


; Name:         DELAY_ONE_SEC
; Description:  Set Timer1A to delay for about 1 second(1.047s).
; Parameters:   None. 
; Register changed:
;               R0, R1 
DELAY_ONE_SEC   .macro 
    MV32 R0, #0xFFFF
    MOV R1, #0xFF
    BL StartTimer1ACounter          ;start couting down  
    BL WaitTillCountingDoneT1A      ;wait till delay time finishes 

    MV32 R0, #0xFFFF
    MOV R1, #0xFF
    BL StartTimer1ACounter
    BL WaitTillCountingDoneT1A
    
    MV32 R0, #0xFFFF
    MOV R1, #0xFF
    BL StartTimer1ACounter
    BL WaitTillCountingDoneT1A
                .endm 


; Name:         PRINT_CHAR
; Description:  Print a character to the 2x24 LCD screen. 
; Parameters:   row_immed: an immediate value that represents the row position,
;                          0x00 for the first row and 0x40 for the second row.
;               col_immed: an immediate value that represents the column
;                          position; range from 0 to 23. 
;               character: an pointer(address value) that points to the 
;                          character to be printed; the character needs to be 
;                          stored in SRAM (.text). 
; Register changed:
;               R0, R1, R2
PRINT_CHAR  .macro row_immed, col_immed, character 
    MOV R0, #row_immed
    MOV R1, #col_immed
    LDR R2, character   ;pass the charater by value 
    BL DisplayChar
            .endm


; Name:         PRINT_STR
; Description:  Print a string to the 2x24 LCD screen. 
; Parameters:   row_immed: an immediate value that represents the row position,
;                          0x00 for the first row and 0x40 for the second row.
;               col_immed: an immediate value that represents the column
;                          position; range from 0 to 23. 
;               string:    an pointer(address value) that points to the string
;                          to be printed; the string needs to be stored in SRAM 
;                          (.text). 
; Register changed:
;               R0, R1, R2
PRINT_STR   .macro row_immed, col_immed, string  
    MOV R0, #row_immed
    MOV R1, #col_immed
    ADR R2, string      ;pass the string by address 
    BL Display
            .endm            
