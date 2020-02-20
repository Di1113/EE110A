;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                               HW2_KEYPAD.s                                 ;
;                             Keypad Functions                               ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains functions for keypad initialization, key-press scan and 
; a dummy enqueue function that enqueues pressed key event. 
; 
; FUNCTION INDEX: 
;   KeypadInit     - initialize buffers used for detecting key presses
;   ScanPressedKey - scan to check if any key is pressed, called by Timer0A
;                    interrupt every 1 ms 
;   DummyEnqueue.  - enqueue pressed key's key code to eventBuffer 
;
; REVISION HISTORY:
;     11/10/19  Di Hu      Initial Revision
;     11/15/19  Di Hu      Added enqueue event routine 
;     11/21/19  Di Hu      - Added comments;
;                          - Deleted unnecessary NOPs 
;                          - Separated DummyEnqueue to be another function
;                          - Added clear eventBuffer routine 
; 	  11/25/19  Di Hu 	   Changed ".word 1" to ".SPACE 4"

;   include files 
    .include "HW2_CC26x2_DEFS.inc"
    .include "HW2_KEYPAD_DEFS.inc"
    .include "HW2_MACROS.inc"
;   public functions 
    .global ScanPressedKey
    .global KeypadInit


    .data
             .align 4   ;aligned by word
eventBuffer:            ;event queue for en-queuing key presses
             .SPACE BUFFER_SIZE << 2    ;allocate space for event buffer
bufferOffset:   .SPACE 4 ;counter for tracking eventBuffer's available space
enqueuedFlag:   .SPACE 4 ;for storing enqueued key press
pressedKey:     .SPACE 4 ;for storing last detected key press
debounceCounter:.SPACE 4 ;counter for tracking debouncing time
currRowOffset:  .SPACE 4 ;for iterating through each row for key press scan


    .text
;code starts 

; KeypadInit
;
; Description:       This function initializes buffers used for scanning key 
;                    presses to default values. 
;
; Operation:         This function initializes debounceCounter, currRowOffset,
;                    enqueuedFlag, pressedKey, bufferOffset and eventBuffer to 
;                    their default values. 
;
; Arguments:         None. 
;
; Return Value:      None.
;
; Local Variables:   R1 - used to store default values for initializing buffers 
; Shared Variables:  addr_debounceCounter - written
;                                         - initialize debounceCounter to 
;                                           default value 
;                    addr_currRowOffset - written
;                                       - initialize currRowOffset to default
;                                         value 
;                    addr_enqueuedFlag - written
;                                      - initialize enqueuedFlag to default
;                                        value
;                    addr_pressedKey - written
;                                    - initialize pressedKey to default value
;                    addr_eventBuffer - written
;                                     - initialize eventBuffer to default value
;
; Input:             None. 
; Output:            None. 
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   eventBuffer table, one word each entry. 
;
; Registers Changed: R0(used in WRVAR too), R1, R2
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Nov 21, 2019
KeypadInit:
    
    MOV R1, #DEBOUNCE_COUNTER
    WRVAR R1, addr_debounceCounter  ;init debounceCounter with countdown value
    MOV R1, #LAST_ROW_OFFSET
    WRVAR R1, addr_currRowOffset    ;init row counter with last row's offset
    MOV R1, #0                      ;clear the rest buffers for initialization
    WRVAR R1, addr_enqueuedFlag     ;clear enqueuedFlag
    WRVAR R1, addr_pressedKey       ;clear pressedKey
    WRVAR R1, addr_bufferOffset     ;clear bufferOffset
ClearEventBuffer:
    MOV R0, #BUFFER_SIZE            ;start a down-counting counter in R0
    LDR R2, addr_eventBuffer        ;clear entire eventBuffer table
CtnClearEventBuffer:
    STR R1, [R2], #4                ;clear current word and move to next word
    SUB R0, #1                      ;decrement counter
    TST R0, R0                      ;check if cleared all words in the table
    BNE CtnClearEventBuffer         ;if not, continue clearing
    ;BEQ -> BX LR                   ;else, finished

    BX LR                           ;finished and return



; ScanPressedKey
;
; Description:       This function scans for key presses on the keypad by every
;                    millisecond. If key press is detected, the key will be 
;                    debounced before it is enqueued in event queue. If no key
;                    press is scanned in current row, the function continues to
;                    scan the next row.
;
; Operation:         This function is called by the Timer0A interrupt handler.
;                    It scans the 4x4 keypad row by row by selecting row to pull
;                    low with DIO4 and DIO5, and checks if any column connected 
;                    to DIO12..15 is low, which means a key press. When a key 
;                    press is detected, its key code is stored into pressedKey;
;                    if no key press is detected, pressedKey is cleared. The 
;                    debounceCounter is reset if no key is pressed, or if a
;                    second switch is pressed before the first one is released;
;                    and the debouceCounter is decremented if any new key is
;                    pressed or the same key press is detected consecutively. 
;                    When the counter reaches zero, DummyEnqueue is called to
;                    enqueue the pressed key as a key event. 
;                       keycode: 
;                           row: (DIO5|DIO4)
;                           col: (DIO15|DIO14|DIO13|DIO12)
;                                  ----------------------------------- 
;                                 |Bit| 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
;                                  ----------------------------------- 
;                                 |r/c|  col  |  row  |  col  |  row  |
;                                  ----------------------------------- 
;
; Arguments:         None. 
;
; Return Value:      None.   
;
; Local Variables:   R2 - contains base address for GPIO module 
; Shared Variables:  addr_pressedKey - read and written
;                                    - read to check if a key is pressed in 
;                                      last interrupt; written when a key press
;                                      is detected, and its key code is written
;                                      into this variable, or when no key is 
;                                      pressed, this variable is cleared.  
;                    addr_currRowOffset - read and written
;                                       - read to select row to scan, written 
;                                         when update to next row for next scan
;                    addr_debounceCounter - read and written 
;                                         - read to check if debouncing is done,
;                                           written when a key press is detected
;                                           and decremented counter value is 
;                                           updated to this variable 
;                    addr_enqueuedFlag - read and written 
;                                      - read to check if detected key press is
;                                        already enqueued, written(cleared) when
;                                        no key is pressed or debouncing clear 
;
; Input:             The state of the keypad(if any key is pressed or not). 
; Output:            eventBuffer - debounced keys are enqueued into eventBuffer
;
; Error Handling:    eventBuffer overflow: 
;                       If key event entries exceed the size of the eventBuffer, 
;                       the previous events are overwritten by the new events, 
;                       overwriting starts at the beginning of the event table. 
;                    multiple key presses: 
;                       Multiple key presses on the same row will not be detected.
;                       Multiple key presses on the same column column would 
;                       generate a different key event value from the value in
;                       the table above; the key event value would have multiple 
;                       column pins set low. 
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0(used in RDVAR, WRVAR), R1, R2, R3, R12, LR 
; Stack Depth:       2 bytes. 
;
; Author:            Di Hu
; Last Modified:     Nov 21, 2019
ScanPressedKey:
    MV32 R2, #GPIO_BASE_ADDR    ;for accessing GPIO registers to read/write
                                ; from/to IO pins 

CheckPressedKeyFlag:
    RDVAR R1, addr_pressedKey   ;read last pressed key
    TST R1, R1                  ;if there is pressed key,
    BEQ ScanNewKey              ;   scan for new pressed key
    ;BNE CtnScanPreKey          ;else, ctn scan the same key 

CtnScanPreKey:                  ;continue scan the last pressed key
    AND R1, R1, #ROW_SCAN_MASK      ;get row to scan
    STR R1, [R2, #DOUT31_0_ADDR_OFFSET] ;scan the old row
    B WaitToRead                ;read the columns to check key press 

ScanNewKey:                     ;start to scan new key presses 

ContinueScan:
    RDVAR R1, addr_currRowOffset;get next row to be scanned
    STR R1, [R2, #DOUT31_0_ADDR_OFFSET];write to output pins to scan row
    ;B WaitToRead

WaitToRead:                     ;wait for output to finish 
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    ;B StartReading

StartReading:
    LDR R12, [R2, #DIN31_0_ADDR_OFFSET] ;read value from input register 
    MOV R3, #KEY_INPUT_MASK             ;get the column pin mask
    AND R12, R3                         ;mask over the input value 
    CMP R12, R3                         ;check if any cols is low
    BEQ NoKeyPressed                    ;if all cols are high, no key is pressed
    ;BNE FoundPressedKey                ; else, some key is pressed

FoundPressedKey:                        ;if found pressed key
    RDVAR R3, addr_pressedKey           ;save old pressed key in R3
    RDVAR R1, addr_currRowOffset        ;get row offset of the pressed key 
    ORR R1, R12                         ;generate key code with col and row
    WRVAR R1, addr_pressedKey           ;write key code to the pressedKey buffer
    ;B CheckSamePressedKey

CheckSamePressedKey:                    ;check if the key pressed is the same as
    TEQ R1, R3                          ;    the last key press 
    BNE StartDebouncing                 ;if not same, start new debouncing cycle
    ;BEQ CheckEnqueuedFlag              ;else, check if has enqueued to buffer

CheckEnqueuedFlag:
    RDVAR R1, addr_enqueuedFlag         ;read last enqueued key's key code 
    TEQ R1, R3                          ;compare with current pressed key code 
    BNE CheckDebounceDone               ;if diff, check if debouncing is done
    ;BEQ StartAutoRepeat                ;if same, already enqueued, start auto-
                                        ;    repeat 

StartAutoRepeat:
    RESETVAR addr_debounceCounter, AUTO_REPEAT_COUNTER
                                        ;set debouceCounter with auto-repeat  
                                        ;    down-counting value 
    B DecDebounceCounter                ;start debouncing 

CheckDebounceDone: 
    RDVAR R12, addr_debounceCounter     ;read current debouceCounter value 
    TST R12, R12                        ;check if counter = 0 
    BEQ EnqueueDebouncedKey             ;if =, debouncing finished, enqueue key 
    BNE DecDebounceCounter              ;else, continue debouncing 

StartDebouncing:
    RESETVAR addr_debounceCounter, DEBOUNCE_COUNTER
                                        ;set debouceCounter with default 
                                        ;    down-counting value 
    ;B DecDebounceCounter

DecDebounceCounter:
    RDVAR R3, addr_debounceCounter      
    SUB R3, #1 
    WRVAR R3, addr_debounceCounter      ;decrement debouceCounter
    RESETVAR addr_enqueuedFlag, 0       ;clear enqueuedFlag 
    B KeypadFinished                    ;debounced once, return 

EnqueueDebouncedKey: 
    PUSH {LR}                   ;push LR onto stack before overwritten by BL
    BL DummyEnqueue             ;enqueue debounced key press as a key event
    POP {LR}                    ;pop LR back from stack
    B KeypadFinished            ;enqueued debounced key press, return 

NoKeyPressed:              
    RESETVAR addr_pressedKey, 0         ;clear pressedKey buffer
    RESETVAR addr_enqueuedFlag, 0       ;clear enqueuedFlag buffer
    RESETVAR addr_debounceCounter, DEBOUNCE_COUNTER ;reset debouceCounter
    ;B ScanNextRow

ScanNextRow:
    RDVAR R1, addr_currRowOffset        ;read current row's offset 
    ;B CheckCurrRow

CheckCurrRow:                           ;check if scanned each row once
    TST R1, R1                          ;if row offset = 0, scanned all once
    BNE DecRowOffset                    ;if !=0, continue scan next row
    ;BEQ ResetRowOffset                 ;if =, start another scan cycle

ResetRowOffset:
    MOV R1, #LAST_ROW_OFFSET            ;reset row counter to start read from
                                        ;   the last row 
    B UpdateRowOffset

DecRowOffset:
    MOV R3, #R_SUB                      ;update row offset to next row(the row
                                        ;    above the current row)
    SUB R1, R3
    ;B UpdateRowOffset

UpdateRowOffset:
    WRVAR R1, addr_currRowOffset        ;store updated row offset for next scan
    ;B KeypadFinished

KeypadFinished:
    BX LR



; DummyEnqueue
;
; Description:       This function enqueues the pressed key to eventBuffer table.
;
; Operation:         This function takes the pressed key's 2-byte key code and 
;                    generates a 4-byte(one word) event value to enqueue the 
;                    pressed key as a key event. Key code is a combination of 
;                    row(DIO4..5) and column(DIO12..15) of the pressed key, 
;                    and this 2-byte code is repeated twice to generate a  
;                    one-word key event code:
;                       keypad-keyEvent map: 
;                       col:  3(0111)    2(1011)    1(1101)    0(1110)
;                             ------------------------------------------
;                row:  0(00) |70007000 | B000B000 | D000D000 | E000E000|
;                            |------------------------------------------
;                      1(01) |70107010 | B010B010 | D010D010 | E010E010|
;                            |------------------------------------------
;                      2(10) |70207020 | B020B020 | D020D020 | E020E020|
;                            |------------------------------------------
;                      3(11) |70307030 | B030B030 | D030D030 | E030E030|
;                             ------------------------------------------
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   None. 
; Shared Variables:  addr_pressedKey - read 
;                                    - read debounced key's key code value
;                    addr_enqueuedFlag - written 
;                                      - update the enqueuedFlag to be the 
;                                        enqueued key press 
;
; Input:             None. 
; Output:            None. 
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   eventBuffer table, one word each entry. 
;
; Registers Changed: R0(used in RDVAR, WRVAR too), R1, R2, R3 
; Stack Depth:       0 
;
; Author:            Di Hu
; Last Modified:     Nov 21, 2019
DummyEnqueue: 

    RDVAR R1, addr_pressedKey   ;read the debounced key's key code
    WRVAR R1, addr_enqueuedFlag ;update the enqueuedFlag with this key code
    MOV R3, #0      ;clear R3
    ORR R3, R1      ;copy key code's value to R3
    LSL R1, R1, #16 ;shift key code in R1 to the third and fourth highest bytes
    ORR R3, R1      ;make an event code with repeated key code value
    LDR R1, addr_eventBuffer    ;get eventBuffer address
    RDVAR R2, addr_bufferOffset ;get bufferOffset for next available word to
                                ;    write in the eventBuffer table 
    LSL R0, R2, #2  ;get the address offset in bytes by multiplying bufferOffset
                    ;   by 4
    STR R3, [R1, R0];store event code into eventBuffer after last event
    ADD R2, #1      ;increment bufferOffset
    TEQ R2, #BUFFER_SIZE   ;check if buffer offset is in the last word in table
    BNE UpdateBufferOffset ;if not, update bufferOffset with the incremented
                           ;    value   
    ;BEQ ResetBufferOffset ;else, clear to reset bufferOffset

ResetBufferOffset:
    MOV R2, #0      ;clear R2 to clear bufferOffset
    ;B UpdateBufferOffset

UpdateBufferOffset:
    WRVAR R2, addr_bufferOffset  ;update bufferOffset
    RESETVAR addr_debounceCounter, DEBOUNCE_COUNTER  ;reset debounceCounter
    BX LR 

;code ends

;Variables 
addr_bufferOffset:      .word bufferOffset
addr_eventBuffer:       .word eventBuffer
addr_enqueuedFlag:      .word enqueuedFlag
addr_pressedKey:        .word pressedKey
addr_debounceCounter:   .word debounceCounter
addr_currRowOffset:     .word currRowOffset
