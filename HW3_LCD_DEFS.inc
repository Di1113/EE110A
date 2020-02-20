;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                              HW3_LCD_DEFS.inc                              ;
;                           LCD Routine Constants                            ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains constant values for LCD initialization and display routines.
; 
; CONSTANT INDEX: 
;   Timer Constants: 
;       LONG_DELAY          - clock counter size for timing delays 
;       LONG_DELAY_PS       - prescaler for LONG_DELAY 
;       MED_DELAY           - clock counter size for timing delays 
;       MED_DELAY_PS        - prescaler for MED_DELAY
;       SHORT_DELAY         - clock counter size for timing delays 
;       SHORT_DELAY_PS      - prescaler for SHORT_DELAY 
;       RR_SETUP_DELAY      - clock counter size for timing RR setup delay
;       EN_PULSE_WIDTH      - clock counter size for timing E high pulse 
;       EN_CYCLE_TIME       - clock counter size for timing E full cycle 
;       DATA_SETUP_DELAY    - clock counter size for timing data setup delay
;   LCD Control Constants: 
;       RS_ON_MASK          - turn on RS select 
;       RS_OFF_MASK         - turn off RS select 
;       READ_ON_MASK        - turn on R/~W select
;       WRITE_ON_MASK       - turn off R/~W select 
;       E_ON_MASK           - turn on E select 
;       E_OFF_MASK          - turn off E select 
;   LCD Commands:           
;       FUNC_SET_CMD_EIGHTBIT_MASK  - for LCD initialization
;       BUSY_FLAG_MASK              - for reading busy flag 
;       FUNC_SET_TWOLINE_EIGHTDOT   - for LCD initialization 
;       DISPLAY_OFF_INS             - turn off LCD display 
;       CLR_DISPLAY_INS             - clear LCD display 
;       ENTRY_MODE_LS_LSD           - set LCD entry mode 
;       DISPLAY_ON_INS              - turn on LCD display 
;   Miscellaneous:
;       LCD_DB_CLR_MASK             - clear LCD data bus 
;       DDRAM_ADR_FIRST_LINE_START  - set cursor to first line start 
;       DDRAM_ADR_SECOND_LINE_START - set cursor to second line start 
;       LCD_DIO_SHIFT               - shift data bits to LCD IO pins 
;       DDRAM_SELECT_MASK           - select DDRAM address 
;       CURSOR_POS_COL_BITS_MASK    - row bits of 2x24 LCD's DDRAM address 
;       CURSOR_POS_ROW_BIT_MASK     - column bits of 2x24 LCD's DDRAM address 
;       LCD_COL_SIZE                - 2x24 LCD's column size 
;
; REVISION HISTORY:
;     11/28/19  Di Hu      Initial Revision
;     11/29/19  Di Hu      Changed LONG_DELAY, MED_DELAY and SHORT_DELAY values
;     12/04/19  Di Hu      Added comments
;     12/26/19  Di Hu      Edited comments, removed redundant constants  

    .data

LONG_DELAY                  .EQU    0x0000BB80
LONG_DELAY_PS               .EQU    15          ;21 ms

MED_DELAY                   .EQU    0x0000BB80 
MED_DELAY_PS                .EQU    7           ;10 ms

SHORT_DELAY                 .EQU    0x0000BB80
SHORT_DELAY_PS              .EQU    0           ;1 ms 

RR_SETUP_DELAY              .EQU    7           ;146 ns
EN_PULSE_WIDTH              .EQU    24          ;500 ns 
EN_CYCLE_TIME               .EQU    48          ;1000 ns

DATA_SETUP_DELAY            .EQU    12          ;250 ns

RS_ON_MASK                  .EQU    0x00000100
                                          ;|
                                          ;0001 (DIO8 on) 
RS_OFF_MASK                 .EQU    0xFFFFFEFF
                                          ;|
                                          ;1110 (DIO8 off)   
READ_ON_MASK                .EQU    0x00000200
                                          ;|
                                          ;0010 (DIO9 on)   
WRITE_ON_MASK               .EQU    0xFFFFFDFF
                                          ;|
                                          ;1101 (DIO9 off) 
E_ON_MASK                   .EQU    0x00000400
                                          ;|
                                          ;0100 (DIO10 on) 
E_OFF_MASK                  .EQU    0xFFFFFBFF
                                          ;|
                                          ;1011 (DIO10 off)  

FUNC_SET_CMD_EIGHTBIT_MASK  .EQU    0x00300000
                                       ;|
                                       ;00110000
                                       ;   |
                                       ;   8-bit bus mode with MPU 

BUSY_FLAG_MASK              .EQU    0x00800000

FUNC_SET_TWOLINE_EIGHTDOT   .EQU    0x00380000
                                       ;||
                                       ;00111000
                                       ;   |||
                                       ;   8-bit bus mode with MPU 
                                       ;    ||
                                       ;    2-line display
                                       ;     |
                                       ;     5x8 dots format display mode 

DISPLAY_OFF_INS             .EQU    0x00080000
                                       ;||
                                       ;00001000
                                       ;     |||
                                       ;     display off 
                                       ;      ||
                                       ;      cursor off 
                                       ;       |
                                       ;       cursor blink off 

CLR_DISPLAY_INS             .EQU    0x00010000
                                       ;||
                                       ;00000001
                                       ; clear display 

ENTRY_MODE_LS_LSD           .EQU    0x00060000
                                       ;||
                                       ;00000110
                                       ;      ||
                                       ;      increment of DDRAM address 
                                       ;       |
                                       ;       shift of entire display off 

DISPLAY_ON_INS              .EQU    0x000F0000
                                       ;||
                                       ;00001111
                                       ;     |||
                                       ;     display on 
                                       ;      ||
                                       ;      cursor on 
                                       ;       |
                                       ;       cursor blink on 

LCD_DB_CLR_MASK             .EQU    0xFF00FFFF
                                       ;||
                                       ;00000000
                                       ; AND mask to clear data bus 

DDRAM_ADR_FIRST_LINE_START  .EQU    0x00 ;set cursor to first row on 2x24 LCD
DDRAM_ADR_SECOND_LINE_START .EQU    0x40 ;set cursor to second row on 2x24 LCD

LCD_DIO_SHIFT               .EQU    16 ;since data bus is DIO16..23 

DDRAM_SELECT_MASK           .EQU    0x00800000 
                                       ;||
                                       ;10000000
                                       ;||||||||
                                       ;set DDRAM address to AC 
                                       ; |||||||
                                       ; AC6..0 

CURSOR_POS_COL_BITS_MASK    .EQU    0x1F
                                     ;||
                                     ;00011111
                                     ;   |||||
                                     ;   AND mask to get column index
CURSOR_POS_ROW_BIT_MASK     .EQU    0x40 
                                     ;||
                                     ;01000000
                                     ; |
                                     ; AND mask to get row index
LCD_COL_SIZE                .EQU    24 ;2x24 LCD has 24 columns
