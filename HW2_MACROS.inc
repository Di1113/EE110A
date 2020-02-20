;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                               HW2_MACROS.inc                               ;
;                              Macro Definitions                             ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains macro definitions used in all assembly files for HW2.
;
; MACRO INDEX:
;   MV32 - copy a 32-bit immediate value to a register
;   RDVAR - read a variable's value from its pointer to a register
;   WRVAR - write a register's value to a variable through its pointer
;   RESETVAR - reset a variable's value with a 16-bit immediate value
;
; REVISION HISTORY:
;   11/10/19  Di Hu      Initial Revision
;   11/22/19  Di Hu      Added comments.

; Name:         MV32
; Description:  Copy a 32-bit immediate value immed into a register.
; Parameters:   register: 32-bit register;
;               immed: 32-bit immediate value.

MV32    .macro register, immed
    MOV     register, immed & 0xFFFF   ;copy the lower 2-byte value first
    MOVT    register, immed >> 16      ;copy the higher 2-byte value without
                                       ;   changing the lower 2 bytes.
        .endm

; Name:         RDVAR
; Description:  Read variable pointer(addr_var)'s value into a register
; Parameters:   register: destination register to be loaded with value
;               addr_var: variable pointer
RDVAR   .macro register, addr_var
    LDR R0, addr_var  ;load variable's address into R0
    LDR register, [R0];load variable's value into register
        .endm

; Name:         WRVAR
; Description:  Write a register's value into variable pointer(addr_var)
; Parameters:   register: register with value to be written into addr_var
;               addr_var: variable pointer
WRVAR   .macro register, addr_var
    LDR R0, addr_var    ;load variable's address into R0
    STR register, [R0]  ;store register's value into that address
        .endm

; Name:         RESETVAR
; Description:  Reset a variable's value with a 16-bit immediate value.
; Parameters:   addr_var: variable pointer
;               immed: default value to write into the variable
RESETVAR    .macro addr_var, immed
    MOV R0, #immed    ;copy immed value to R0
    LDR R1, addr_var  ;load variable's address into R1
    STR R0, [R1]      ;store immed value to variable
            .endm
