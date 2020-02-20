;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 HW3_LCD.s                                  ;
;                               LCD Functions                                ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains functions for LCD initialization, character and string
; display, and utility functions used in these three main functions. 
; 
; FUNCTION INDEX: 
;   Utility Functions:
;       WriteLCD:         output 2-byte command or character value to LCD data
;                         pins; used in OutputCmdForInit, OutputCmd, OutputChar
;       WaitTillNotBusy:  read busy flag bit and loop till busy flag is clear;
;                         used in OutputCmd, OutputChar 
;       OutputCmdForInit: output 2-byte command without reading busy flag first;
;                         used in LCD_Eight_Bit_Init 
;       OutputCmd:        output 2-byte command after busy flag is clear; used
;                         in LCD_Eight_Bit_Init, SetPrintPosition, Display 
;       OutputChar:       output 2-byte character after busy flag is clear; 
;                         used in DisplayChar, Display 
;       SetPrintPosition: set cursor position on LCD display; used in
;                         DisplayChar and Display 
;   Main Functions: 
;       LCD_Eight_Bit_Init: initialize LCD's display mode and prepare it for 
;                           displaying characters and strings 
;       DisplayChar:        display a character on LCD  
;       Display:            display a string on LCD 
;
; REVISION HISTORY:
;     11/27/19  Di Hu      Initial Revision
;     11/29/19  Di Hu      Debugged busy flag always set issue by connecting 
;                          LCD to external 5V power supply 
;     12/20/19  Di Hu      Added error message display in SetPrintPosition
;     12/26/19  Di Hu      Finished editing comments 


;   include files 
    .include "HW3_CC26x2_DEFS.inc"
    .include "HW3_LCD_DEFS.inc"
    .include "HW3_MACROS.inc"

;   public functions 
    .global LCD_Eight_Bit_Init
    .global DisplayChar
    .global Display
    .ref StartTimer0BCounter
    .ref StartTimer1ACounter
    .ref StartTimer1BCounter
    .ref WaitTillCountingDoneT0B
    .ref WaitTillCountingDoneT1A
    .ref WaitTillCountingDoneT1B
    .ref InitOutputLCDDB
    .ref InitInputLCDDB

;   shared variables 
    .data
    .align 4   ;aligned by word
curr_ddram_addr:        .SPACE 4
word_byte_counter:      .SPACE 4
word_counter:           .SPACE 4
string_tbp:             .SPACE 4
char_tbp:               .SPACE 4


;code starts 
    .text

; WriteLCD (R0: cmd/char)
;
; Description:       This function is passed a 2-byte command(cmd) or
;                    character(char) to output to the LCD through LCD 2-byte  
;                    data pins. The command/character is passed in R0 by value.
;
; Operation:         This function output the passed-in command/character by:
;                       1.  [timer1B] wait for last E cycle to finish 
;                       2.  set R/~W low for data output 
;                       3.  [timer1A] count down R/~W and RS setup delay
;                       4.  clear LCD data pins 
;                       5.  set LCD data pins as outputs 
;                       6.  [timer1A] wait for R/~W, RS setup delay to finish 
;                       7.  [timer1B] count down E cycle 
;                       8.  set E high for data output 
;                       9.  [timer1A] count down E high pulse width  
;                       10. [timer0B] count down data setup delay  
;                       11. [timer0B] wait for data setup delay to finish 
;                       12. output passed-in cmd/char to data pins 
;                       13. [timer1A] wait for E high pulse width to finish 
;                       14. set E low and return 
;
; Arguments:         cmd/char - R0 - by value - command or character to be 
;                                               output to LCD data pins 
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
; Registers Changed: R0, R1, R2, R3, R12, LR 
; Stack Depth:       2 words 
;
; Author:            Di Hu
; Last Modified:     Dec 25, 2019
WriteLCD:
    PUSH {R0, LR}                   ;save R0(cmd/char) to output to LCD later 
                                    ;save LR for branching to other functions 

    ;Timer1B is used for timing Enable control cycle 
    BL WaitTillCountingDoneT1B          ;wait for last E cycle to finish 

    MV32 R2, #GPIO_BASE_ADDR 
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET]
    MV32 R12, #WRITE_ON_MASK            
    AND R3, R3, R12
    STR R3, [R2, #DOUT31_0_ADDR_OFFSET] ;set R/~W control low for data output
    
    MOV R0, #RR_SETUP_DELAY
    MOV R1, #0 
    BL StartTimer1ACounter              ;count down delay for RS, R/~W setup

    MV32 R2, #GPIO_BASE_ADDR
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET] 
    MV32 R12, #LCD_DB_CLR_MASK
    AND R3, R3, R12                    
    STR R3, [R2, #DOUT31_0_ADDR_OFFSET] ;clear LCD's data pins 

    BL InitOutputLCDDB                  ;set LCD IO pins as output pins 

    BL WaitTillCountingDoneT1A          ;wait for RS, R/~W setup delay to finish

    MOV R0, #EN_CYCLE_TIME
    MOV R1, #0
    BL StartTimer1BCounter              ;count down Enable control cycle 

    MV32 R2, #GPIO_BASE_ADDR
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET]
    ORR R3, R3, #E_ON_MASK
    STR R3, [R2, #DOUT31_0_ADDR_OFFSET] ;set E control high to output data 

    MOV R0, #EN_PULSE_WIDTH
    MOV R1, #0
    BL StartTimer1ACounter              ;count down E high pulse width time 

    MOV R0, #DATA_SETUP_DELAY 
    MOV R1, #0
    BL StartTimer0BCounter              ;count down data setup delay  
    BL WaitTillCountingDoneT0B          ;wait for data setup delay to finish

    POP {R0, LR}
    PUSH {LR}                           ;retrieve data byte into R0 from stack 

    MV32 R2, #GPIO_BASE_ADDR
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET] 
    ORR R0, R0, R3  
    STR R0, [R2, #DOUT31_0_ADDR_OFFSET] ;output data byte 

    BL WaitTillCountingDoneT1A          ;wait for E high pulse to finish 

    MV32 R2, #GPIO_BASE_ADDR
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET]
    MV32 R12, #E_OFF_MASK               
    AND R3, R3, R12
    STR R3, [R2, #DOUT31_0_ADDR_OFFSET] ;set E low 
     
    POP {LR}                            ;done and return 
    BX LR 
    

; WaitTillNotBusy
;
; Description:       This function reads LCD busy flag through LCD data pins. 
;
; Operation:         This function reads LCD busy flag by:
;                       1.  [timer1B] wait for last E cycle to finish 
;                       2.  set RS low for outputting command 
;                       3.  set R/~W high for reading LCD data pins
;                       4.  [timer1A] count down R/~W and RS setup delay
;                       5.  clear LCD data pins 
;                       6.  set LCD data pins as inputs 
;                       7.  [timer1A] wait for R/~W, RS setup delay to finish 
;                       8.  [timer1B] count down E cycle 
;                       9.  set E high to read data input 
;                       10. [timer1A] count down E high pulse width  
;                       11. [timer1A] wait for E high pulse width to finish 
;                       12. read buys flag bit(7th bit) in 2-bytes data input 
;                       13. loop reading busy flag till busy flag is clear 
;                       14. set E low and return 
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
; Registers Changed: R0, R1, R2, R3, R12, LR 
; Stack Depth:       1 word
;
; Author:            Di Hu
; Last Modified:     Dec 25, 2019
WaitTillNotBusy: 
    PUSH {LR}                        ;save LR for branching to other functions 

ReadBFStart: 
    BL WaitTillCountingDoneT1B          ;wait for last E cycle to finish 

    MV32 R2, #GPIO_BASE_ADDR
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET]
    MV32 R12, #RS_OFF_MASK
    AND R3, R3, R12                     ;set RS low for outputting command 

    MOV R12, #READ_ON_MASK           
    ORR R3, R3, R12             
    STR R3, [R2, #DOUT31_0_ADDR_OFFSET] ;set R/~W high for reading LCD data pins 

    MOV R0, #RR_SETUP_DELAY
    MOV R1, #0
    BL StartTimer1ACounter              ;count down delay for RS, R/~W setup

    MV32 R2, #GPIO_BASE_ADDR
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET]
    MV32 R12, #LCD_DB_CLR_MASK    
    AND R3, R3, R12 
    STR R3, [R2, #DOUT31_0_ADDR_OFFSET] ;clear LCD's data pins 

    BL InitInputLCDDB                   ;set LCD IO pins as input pins 
    
    BL WaitTillCountingDoneT1A          ;wait for RS, R/~W setup delay to finish

    MOV R0, #EN_CYCLE_TIME
    MOV R1, #0
    BL StartTimer1BCounter              ;count down Enable control cycle 

    MV32 R2, #GPIO_BASE_ADDR
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET]
    ORR R3, R3, #E_ON_MASK
    STR R3, [R2, #DOUT31_0_ADDR_OFFSET] ;set E control high to read in data 

    MOV R0, #EN_PULSE_WIDTH
    MOV R1, #0
    BL StartTimer1ACounter              ;count down E high pulse width time 
    BL WaitTillCountingDoneT1A          ;wait for E high pulse to finish
                                        ;   (data is ready for reading) 

    MV32 R2, #GPIO_BASE_ADDR
    LDR R3, [R2, #DIN31_0_ADDR_OFFSET]
    MOV R12, #BUSY_FLAG_MASK
    ANDS R3, R3, R12                    ;read busy flag bit 
    BNE ReadBFStart                     ;loop till busy flag is clear
    ;BEQ busy flag clear, continue 
    
    MV32 R2, #GPIO_BASE_ADDR
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET]
    MV32 R12, #E_OFF_MASK
    AND R3, R3, R12
    STR R3, [R2, #DOUT31_0_ADDR_OFFSET] ;set E low 
     
    POP {LR}                            ;done and return 
    BX LR 


; OutputCmdForInit(cmd)
;
; Description:       This function is passed a 2-byte command (cmd) to send to 
;                    LCD. The command (cmd) is passed in R0 by value. This
;                    function sends command without waiting for busy flag to 
;                    clear first. 
;
; Operation:         This function sends command to LCD for LCD initialization
;                    by setting RS low and outputting command in R0 by calling
;                    WriteLCD. 
;
; Arguments:         cmd - R0 - by value - command to be output to LCD data pins 
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
; Registers Changed: R0, R1, R2, R3, R12, LR 
; Stack Depth:       3 words 
;
; Author:            Di Hu
; Last Modified:     Dec 25, 2019
OutputCmdForInit:
    PUSH {LR}                       ;save LR for branching to other functions 

    MV32 R2, #GPIO_BASE_ADDR 
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET]
    MV32 R12, #RS_OFF_MASK
    AND R3, R3, R12
    STR R3, [R2, #DOUT31_0_ADDR_OFFSET] ;set RS low for outputting command 

    BL WriteLCD                     ;branch to WriteLCD to output command in R0 
    
    POP {LR}                        ;done and return 
    BX LR 


; OutputCmd(cmd)
;
; Description:       This function is passed a 2-byte command (cmd) to send to 
;                    LCD. The command (cmd) is passed in R0 by value. This
;                    function sends command by waiting for busy flag to 
;                    clear first. 
;
; Operation:         This function waits for busy flag to clear, then sends
;                    passed-in command to LCD by setting RS low for command 
;                    output and outputting command in R0 by calling WriteLCD.
;
; Arguments:         cmd - R0 - by value - command to be output to LCD data pins 
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
; Registers Changed: R0, R1, R2, R3, R12, LR 
; Stack Depth:       4 words 
;
; Author:            Di Hu
; Last Modified:     Dec 25, 2019
OutputCmd: 
    PUSH {LR, R0}           ;save LR for branching to other functions 
                            ;save R0(cmd) for passing to WriteLCD 
    
    BL WaitTillNotBusy      ;wait for busy flag to clear 
                            ;        (last operation to finish)

    MV32 R2, #GPIO_BASE_ADDR 
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET]     
    MV32 R12, #RS_OFF_MASK
    AND R3, R3, R12
    STR R3, [R2, #DOUT31_0_ADDR_OFFSET] ;set RS low for outputting command 
    
    POP {LR, R0}
    PUSH {LR}
    BL WriteLCD             ;branch to WriteLCD to output command in R0 
    
    POP {LR}                ;done and return 
    BX LR 


; OutputChar(ch)
;
; Description:       This function is passed a 2-byte character (ch) to send 
;                    to LCD. The character (ch) is passed in R0 by value. This
;                    function sends command by waiting for busy flag to 
;                    clear first. 
;
; Operation:         This function waits for busy flag to clear, then sends
;                    passed-in character to LCD by setting RS high for data 
;                    output and outputting character in R0 by calling WriteLCD.
;
; Arguments:         ch - R0 - by value - char to be output to LCD data pins 
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
; Registers Changed: R0, R1, R2, R3, R12, LR 
; Stack Depth:       4 words 
;
; Author:            Di Hu
; Last Modified:     Dec 25, 2019
OutputChar: 
    PUSH {R0, LR}           ;save LR for branching to other functions 
                            ;save R0(ch) for passing to WriteLCD 
    
    BL WaitTillNotBusy      ;wait for busy flag to clear 
                            ;        (last operation to finish)

    MV32 R2, #GPIO_BASE_ADDR     
    LDR R3, [R2, #DOUT31_0_ADDR_OFFSET]
    MV32 R12, #RS_ON_MASK
    ORR R3, R3, R12
    STR R3, [R2, #DOUT31_0_ADDR_OFFSET] ;set RS high for outputting data  
    
    POP {R0, LR}
    PUSH {LR}
    BL WriteLCD             ;branch to WriteLCD to output character in R0 
    
    POP {LR}                ;done and return 
    BX LR 


; LCD_Eight_Bit_Init 
;
; Description:       This function initializes LCD display for displaying
;                    characters and strings.  
;
; Operation:         This function initializes LCD by:
;                       1. wait for some time after power on 
;                       2. send 8-bit bus mode Function Set command three times
;                          with time delay in between 
;                       3. send Function Set command to set LCD as 8-bit bus,
;                          2-line display and 5x11 dots format mode. 
;                       4. send Display ON/OFF Control command to turn off 
;                          display 
;                       5. send Clear Display command to clear display 
;                       6. send Entry Mode Set command to set cursor to move
;                          right and increment in DDRAM address 
;                       7. send Clear Display command to turn on display with
;                          cursor and cursor blink on 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None. 
; Shared Variables:  None. 
;
; Input:             None. 
; Output:            Cursor blinks on LCD display at the start of the first line. 
;
; Error Handling:    None. 
;
; Algorithms:        None. 
; Data Structures:   None.
;
; Registers Changed: R0, R1, R2, R3, R12, LR 
; Stack Depth:       5 words 
;
; Author:            Di Hu
; Last Modified:     Dec 25, 2019
LCD_Eight_Bit_Init:
    
    PUSH {LR}
    
    MV32 R0, #LONG_DELAY
    MOV R1, #LONG_DELAY_PS           
    BL StartTimer1ACounter
    BL WaitTillCountingDoneT1A  ;wait for some delay after IO power is on 
    
    MV32 R0, #FUNC_SET_CMD_EIGHTBIT_MASK
    BL OutputCmdForInit         ;output function set cmd(fsc) for initialization

    MV32 R0, #MED_DELAY
    MOV R1, #MED_DELAY_PS
    BL StartTimer1ACounter
    BL WaitTillCountingDoneT1A  ;wait for some delay after sending first fsc 

    MV32 R0, #FUNC_SET_CMD_EIGHTBIT_MASK
    BL OutputCmdForInit         ;output function set cmd(fsc) for initialization

    MOV R0, #SHORT_DELAY
    MOV R1, #SHORT_DELAY_PS
    BL StartTimer1ACounter
    BL WaitTillCountingDoneT1A  ;wait for some delay after sending second fsc 

    MV32 R0, #FUNC_SET_CMD_EIGHTBIT_MASK
    BL OutputCmdForInit         ;output function set cmd(fsc) for initialization

    MV32 R0, #FUNC_SET_TWOLINE_EIGHTDOT
    BL OutputCmd                ;configure LCD display mode 

    MV32 R0, #DISPLAY_OFF_INS
    BL OutputCmd                ;turn off LCD display 

    MV32 R0, #CLR_DISPLAY_INS
    BL OutputCmd                ;clear LCD display 

    MV32 R0, #ENTRY_MODE_LS_LSD
    BL OutputCmd                ;configure cursor moving direction 

    MV32 R0, #DISPLAY_ON_INS    
    BL OutputCmd            ;turn on display with cursor and cursor blink config

    POP {LR}
    BX LR                       ;finished and return


; SetPrintPosition(r, c) 
;
; Description:       This function is passed a row (r) position and a 
;                    column (c) position to set cursor on LCD. Row (r) position
;                    is passed in R0 by value, and column (c) position is 
;                    passed in R2 by value. This function validate row and 
;                    column positions by comparing them to valid values, and 
;                    prints error message if positions are invalid, or set 
;                    set cursor positions on LCD if positions are valid. 
;                    Valid row and column positions are (for this 2x24 LCD): 
;                       1. r and c are both 0xFF (cursor stays at current pos)
;                       2. r is either 0x00 or 0x40
;                       3. c is an unsigned value less than 24, since 0 indexed 
;
; Operation:         This function sets cursor to passed-in valid position on 
;                    LCD by: 
;                       1. check if passed-in arguments are both 0xFF, 
;                          if yes, set cursor to current position,
;                          if not, check if row & column positions are valid;
;                       2. check if row & column positions are in range,
;                          if yes, set cursor to passed-in position,
;                          if not, print error message to LCD to warn user;
;                       3. call OutputCmd to update cursor position on LCD.
;
; Arguments:         r  - R0 - by value - row position to set cursor at;
;                    c  - R1 - by value - column position to set cursor at;
;
; Return Value:      None. 
;
; Local Variables:   None. 
; Shared Variables:  curr_ddram_addr - r/w - to read current cursor position or
;                    (addr_curr_ddram_addr)  to update to new cursor position 
;
; Input:             None.
; Output:            An invalid position error message to LCD display if 
;                    passed-in arguments are invalid. 
;
; Error Handling:    If only one of row or column value is 0xFF, or if row or 
;                    column value is out of range, an error message is printed 
;                    to LCD screen by calling Display to warn users about 
;                    invalid position arguments. 
;
; Algorithms:        None. 
; Data Structures:   None.
;
; Registers Changed: R0, R1, R2, R3, R12, LR 
; Stack Depth:       5 words 
;
; Author:            Di Hu
; Last Modified:     Dec 25, 2019
SetPrintPosition: 
    PUSH {LR}                   ;save LR for branching to other functions 

CheckRowPosIsFF:                ;check if row argument is 0xFF 
    AND R0, R0, #0xFF
    CMP R0, #0xFF
    BNE CheckValidDDRAMAddr     ;if not, check if arguments are valid 
    ;BEQ CheckColPos            ;if yes, check if column argument is 0xFF 

CheckColPosIsFF:                ;check if column argument is 0xFF 
    AND R1, R1, #0xFF           
    CMP R1, #0xFF 
    BNE CursorPosInvalidWarning ;if not, send invalid position warning since 
                                ;   row argument is 0xFF and column is not 
    ; BEQ SetCurrPos             ;if yes, continue 

SetCurrPos:                     ;set cursor to current position
    RDVAR R1, addr_curr_ddram_addr ;get current cursor position 
    B SetPos                    ;branch to set to current cursor position
    
CheckValidDDRAMAddr:            ;check if passed-in position is valid 
CheckIsFirRow:                  ;check if row argument is first row 
    CMP R0, #LCD_FIRST_ROW      
    BEQ CheckColInRange         ;if yes, check column argument 
    ;BNE CheckIsSecRow          ;if not, check for second row value 
CheckIsSecRow:                  ;check if row argument is second row 
    CMP R0, #LCD_SECOND_ROW
    BEQ CheckColInRange         ;if yes, check column argument 
    BNE CursorPosInvalidWarning ;if not, send invalid position warning since 
                                ;   this LCD only has two rows 

CheckColInRange:                ;check if column argument is valid 
    CMP R1, #LCD_COL_SIZE 
    BHS CursorPosInvalidWarning ;if higher than or equal to column size, send 
                                ;   invalid position warning since column is 
                                ;   0-indexed 
    ; BLO UpdateNewPos          ;if less than col size, position is valid, ctn

UpdateNewPos:                   ;update cursor position to passed-in position 
    ADD R1, R1, R0              ;get new position by combining row and col value
    WRVAR R1, addr_curr_ddram_addr  ;update cursor position in buffer 
    ; B SetPos                    

SetPos:                         ;update cursor position on LCD 
    LSL R1, R1, #LCD_DIO_SHIFT  ;R1 contains DD RAM Addr that sets cursor pos 
    MOV R0, #DDRAM_SELECT_MASK 
    ORR R0, R0, R1              ;turn on data bit to set DDRAM select 
    BL OutputCmd                ;output Set DD RAM Address command 

    B SetPrintPositionDone      ;finished setting cursor 

CursorPosInvalidWarning:        ;output position invalid warning message on LCD 
    PRINT_STR LCD_FIRST_ROW, 0, warning_cur_pos ;call Display to print message
    DELAY_ONE_SEC
    DELAY_ONE_SEC
    DELAY_ONE_SEC               ;wait for 3 seconds after printing message 
    POP {LR}                    ;skip the rest of the parent function that 
                                ;   called SetPrintPosition 
    ;B SetPrintPositionDone

SetPrintPositionDone:           ;done setting cursor position for printing 
    POP {LR}
    BX LR                       ;return 


; DisplayChar(r, c, ch)
;
; Description:       The function is passed a character (ch) to output to the
;                    LCD at the passed position (row r and column c). The
;                    character (ch) is passed in R2 by value. The row (r) is
;                    passed in R0 by value and the column (c) is passed in R1
;                    by value. If the row and column are both -1 the character
;                    is output at the current cursor position. The cursor
;                    position is always updated to the position after the
;                    character.
;
; Operation:         This function prints the passed-in character at required
;                    position by: 
;                       1. call SetPrintPosition to set cursor position, 
;                       2. call OutputChar to print the character,
;                       3. update cursor to next position in curr_ddram_addr,
;                       4. return 
;
; Arguments:         r  - R0 - by value - row position to be printed at;
;                    c  - R1 - by value - column position to be printed at;
;                    ch - R2 - by value - character to be printed to the LCD
;                                         display;
;
; Return Value:      None. 
;
; Local Variables:   char_tbp             - r/w - stores character value in R2
;                    (addr_char_tbp)              before calling SetPrintPosition 
; Shared Variables:  curr_ddram_addr      - r/w - increment cursor position for
;                    (addr_curr_ddram_addr)       printing next character 
;
; Input:             None. 
; Output:            Display shows the passed-in character. 
;
; Error Handling:    Invalid printing position is handled by SetPrintPosition
;                    by printing an error message. 
;
; Algorithms:        None. 
; Data Structures:   None. 
;
; Registers Changed: R0, R1, R2, R3, R12, LR 
; Stack Depth:       7 words 
;
; Author:            Di Hu
; Last Modified:     Dec 24, 2019
DisplayChar: 
    PUSH {LR}                   ;save LR for branching to other functions 

    PUSH {R0}                   ;WRVAR uses R0, save passed-in value in R0
    WRVAR R2, addr_char_tbp     ;save passed-in value in R2 before branching
                                ;   to SetPrintPosition
    POP {R0}                    ;restore passed-in value in R0
    
    BL SetPrintPosition         ;branch to validate and set cursor position 

    ;if cursor position is invalid, 
    ;   program would skip the rest
    ;   and return to the parent function of DisplayChar 
    ;if cursor position is valid, 
    ;   program would return to next line and continue

    RDVAR R2, addr_char_tbp     ;restore passed-in value in R2 
    AND R0, R2, #0xFF           ;get char value by masking over the lowest
                                ;   byte mask, since little endian
    LSL R0, R0, #LCD_DIO_SHIFT  ;shift character value bits to LCD DIO output 
                                ;   pin bit positions 
    BL OutputChar               ;branch to output character data value 

    RDVAR R1, addr_curr_ddram_addr  ;get current cursor position 
    ADD R1, #1                      ;increment cursor position
    WRVAR R1, addr_curr_ddram_addr  ;update cursor position 

DisplayCharDone:                ;done and return 
    POP {LR}                    
    BX LR 


; Display(r, c, str) 
;
; Description:       The function is passed a <null> terminated string (str)
;                    to output to the LCD at the passed row (r) and column (c).
;                    The string is passed by reference in R2 (i.e. the address
;                    of the string is R2). The row (r) is passed in R0 by value
;                    and the column (c) is passed in R1 by value. If the row
;                    and column are both -1 the string is output starting at
;                    the current cursor position. The cursor position is always
;                    updated to the position after the last character in the
;                    string.
;
; Operation:         This function prints the passed-in string at required
;                    position by: 
;                       1. call SetPrintPosition to check and set cursor position, 
;                       2. retrieve characters in the string word by word since 
;                          string's (characters') value is aligned by word in 
;                          little endian 
;                       3. track cursor position to print next character to a new 
;                          line when current line is full 
;                       4. wait for 2 seconds then clear the screen if need to 
;                          update cursor to the start of first line from the end 
;                          of the second line 
;                       5. print retrieved character by calling OutputChar when
;                          the character is not <null> 
;                       6. return when retrieved character is <null> 
;
; Arguments:         r  - R0 - by value     - row position to be printed at;
;                    c  - R1 - by value     - column position to be printed at;
;                    ch - R2 - by reference - address of the string to be
;                                             printed to the LCD display;
;
; Return Value:      None.
;
; Local Variables:   string_tbp             - r/w - stores the address of 
;                    (addr_string_tbp)              passed-in string's first 
;                                                   word of chars  
;                    word_counter           - r/w - up-count string's chars in
;                    (addr_word_counter)            words for retrieve character
;                                                   values since little endian 
;                    word_byte_counter      - r/w - down-count 4 bytes of chars
;                    (addr_word_byte_counter)       in a word 
; Shared Variables:  curr_ddram_addr        - r/w - increment cursor position for
;                    (addr_curr_ddram_addr)         printing next character and
;                                                   check if at the last column 
;
; Input:             None. 
; Output:            Display shows the passed-in string. 
;
; Error Handling:    Invalid printing position is handled by SetPrintPosition
;                    by printing an error message.     
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0, R1, R2, R3, R12, LR 
; Stack Depth:       7 words 
;
; Author:            Di Hu
; Last Modified:     Dec 24, 2019
Display: 
    PUSH {LR}                   ;save LR for branching to other functions 

    PUSH {R0}                   ;WRVAR uses R0, save passed-in value in R0
    WRVAR R2, addr_string_tbp   ;save passed-in value in R2 before branching
                                ;   to SetPrintPosition
    POP {R0}                    ;restore passed-in value in R0

    BL SetPrintPosition         ;branch to validate and set cursor position 

    ;if cursor position is invalid, 
    ;   program would skip the rest
    ;   and return to the parent function of Display
    ;if cursor position is valid, 
    ;   program would return to next line and continue

    RESETVAR addr_word_counter, 0 ;initialize word counter to retrieve next 
                                ;  word of characters by address offset

    RDVAR R12, addr_string_tbp  ;get the first word of character values
    LDR R12, [R12]              ;   of the string by address
    
    PUSH {R12}                  ;push the word on stack for printing chars 

DisplayNextWordofChar:          ;track char bytes in a word to move to next 
                                ;   word when done with the current one 
    RESETVAR addr_word_byte_counter, 4 ;count down, since 1 word = 4 bytes
    ;B CheckEndofLine

CheckEndofLine:                 ;check if current cursor position is at last
                                ;   column 
    RDVAR R3, addr_curr_ddram_addr ;get current cursor position 
    AND R2, R3, #CURSOR_POS_COL_BITS_MASK
    CMP R2, #LCD_COL_SIZE       ;check if cursor column position is at column
                                ;   size index, which is out of screen since 
                                ;   column is 0 indexed 
    BNE GetNextChar             ;if not out of screen, print next character
    ;BEQ ChangeLine             ;else, change cursor position to a new line 

ChangeLine:                     ;check current cursor position and 
                                ;   update it to the start of a new line
    AND R2, R3, #CURSOR_POS_ROW_BIT_MASK   ;mask out row bit for this 2x24 LCD 
    TST R2, R2                  ;check if is at first line (row bit is 0)
    BNE ClearScrAndWriteToFirstLine ;if is at second line,
                                    ;    clear screen and return line 0
    ;BEQ WriteToSecondLine      ;if is at first line, move on to second line

WriteToSecondLine:              ;update cursor position to second line start 
    MOV R2, #DDRAM_ADR_SECOND_LINE_START ;set cursor position
    WRVAR R2, addr_curr_ddram_addr ;update cursor position in the buffer  
    MOV R0, R2                  ;pass arguments for SetPrintPosition
                                ;   R0 - r - DDRAM_ADR_SECOND_LINE_START
                                ;            (second row) 
    MOV R1, #0                  ;pass arguments for SetPrintPosition
                                ;   R1 - c - 0 th column
    BL SetPrintPosition         ;update cursor on LCD screen 
    B GetNextChar               ;done updating cursor position, print char  

ClearScrAndWriteToFirstLine:    ;update cursor position to first line start 
    DELAY_ONE_SEC
    DELAY_ONE_SEC               ;display the old content for twos seconds

    MV32 R0, #CLR_DISPLAY_INS
    MOV R1, #0
    BL OutputCmd                ;clear screen for new characters and 
                                ;   reset cursor position on LCD 

    MOV R2, #DDRAM_ADR_FIRST_LINE_START ;set cursor position
    WRVAR R2, addr_curr_ddram_addr      ;update cursor position in the buffer  

GetNextChar:                    ;get next character's value 
    POP {R12}                   ;get the saved word of characters from stack
    AND R0, R12, #0xFF          ;get the character from the lowest byte

CheckCharNull: 
    TST R0, R0                  ;check if current char is <null>, 
                                ;   since <null>'s value is 0
    BEQ DisplayStrDone          ;if is, finished printing the string 
    ;BNE PrintChar              ;if not, print current character

PrintChar:                      ;print current character to LCD 
    LSR R12, R12, #8            ;shift saved word of characters for next print
    PUSH {R12}                  ;save shifted word on stack 

    LSL R0, R0, #LCD_DIO_SHIFT  ;shift character value to LCD data output pins 
    BL OutputChar               ;print character in R0 to LCD and 
                                ;   update cursor to next position on LCD  

    RDVAR R3, addr_curr_ddram_addr
    ADD R3, #1 
    WRVAR R3, addr_curr_ddram_addr ;increment cursor position in buffer 

    RDVAR R3, addr_word_byte_counter 
    SUB R3, #1
    WRVAR R3, addr_word_byte_counter ;decrement word byte counter in buffer 
    ;B CheckWordPrinted

CheckWordPrinted:               ;check if done with current word of characters
    TST R3, R3                  ;(which is to check if word byte counter is 0)
    BNE CheckEndofLine          ;if not, print next byte of character
    ;BEQ UpdateStringWordAddr   ;if yes, get next word of characters 

UpdateStringWordAddr:           ;get next word of characters of the string 
    POP {R12}                   ;get the saved word of characters from stack
    RDVAR R3, addr_word_counter
    ADD R3, #1 
    WRVAR R3, addr_word_counter ;update word counter
    LSL R3, R3, #2              ;get address offset to the start of the string 
                                ;   in bytes by timing word counter by 4,
                                ;   since 1 word = 4 bytes 
    RDVAR R12, addr_string_tbp
    LDR R12, [R12, R3]          ;get a word of characters to be printed next 
    PUSH {R12}                  ;save the word on stack 
    B DisplayNextWordofChar     ;print the saved word 

DisplayStrDone:                 ;done printing the string and return 
    POP {LR}
    BX LR                       

;local and shared variable buffers 
addr_curr_ddram_addr:   .word curr_ddram_addr
addr_word_byte_counter: .word word_byte_counter
addr_word_counter:      .word word_counter
addr_string_tbp:        .word string_tbp 
addr_char_tbp:          .word char_tbp 

;error message for invalid cursor position 
    .align 4
warning_cur_pos: .cstring "[Error]: Given cursor position is out of screen. String/Char is not printed."
