;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW2_KEYPAD_DEFS.inc                            ;
;                              Keypad Constants                              ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for keypad initialization, scan functions and 
; key event enqueue function. 
; 
; CONSTANT INDEX: 
;   DEBOUNCE_COUNTER - debouncing time for a pressed key in ms 
;   AUTO_REPEAT_COUNTER - autorepeat debouncing time for a long-hold key in ms
;   KEY_INPUT_MASK - for reading the keypad column input pins 
;   ROW_SCAN_MASK - for reading the keypad row output pins 
;   LAST_ROW_OFFSET - select last row with keypad row output pins 
;   R_SUB - offset to move to next row 
;   BUFFER_SIZE - event queue buffer table size in words  
;
; REVISION HISTORY:
;   11/10/19  Di Hu      Initial Revision
;   11/21/19  Di Hu      - Added comments. 
;                        - Separate out address constants to CC26x2_DEFS.inc.

    .data
;for ScanPressedKey function 
DEBOUNCE_COUNTER    .EQU 10         ;debounce pressed key for 10 ms 
AUTO_REPEAT_COUNTER .EQU 500        ;repeat the key event after key is pressed
                                    ;   another 500 ms 
KEY_INPUT_MASK 	    .EQU 0xF000     ;select DIO15..12 to read col input values
ROW_SCAN_MASK       .EQU 0x30       ;select DIO5..4 to read row output values
LAST_ROW_OFFSET	    .EQU 0x30       ;last row is selected when DIO5,
                                    ;    DIO4 are both high
R_SUB               .EQU 0x10       ;row selection for row3, row2, row1, row0 
                                    ;   are 0x30, 0x20, 0x10, 0x00; thus, 
                                    ;   the offset is 0x10 
;for DummyEnqueue function 
BUFFER_SIZE         .EQU 20         ;allocate 20 words of space for event buffer

