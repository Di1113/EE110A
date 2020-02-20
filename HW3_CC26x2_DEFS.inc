;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW3_CC26x2_DEFS.inc                            ;
;                   General Definitions for CC2652 Specifics                 ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains used modules' bases addresses, their registers' address 
; offset values, stack constants, PRCM constants for CC2652 launchpad and
; constants for the 2x24 LCD display. 
; 
; CONSTANT INDEX: 
;   Module Base Address: 
;       GPT0_BASE_ADDR    - used for counting time delays for LCD routines 
;       GPT1_BASE_ADDR    - used for counting time delays for LCD routines 
;       GPIO_BASE_ADDR    - used for configure and access IO pins for LCD 
;       IOC_BASE_ADDR     - used for IO configuration 
;       PRCM_BASE_ADDR    - used for enabling GPIO power and clock 
;   Register Offset Address:  
;       PRCM: 
;           PDCTL0_ADDR_OFFSET  - used for enabling GPIO power in main function
;           PDSTAT0_ADDR_OFFSET - used for checking GPIO power on in main 
;           GPIOCLKGR_ADDR_OFFSET   - used for enabling GPIO clock in main 
;           CLKLOADCTL_ADDR_OFFSET  - used for loading PRCM stns to CLKCTRL 
;                                     in main 
;           GPTCLKGR_ADDR_OFFSET    - used for selecting timer type 
;       IOC:
;           IOCFG23_ADDR_OFFSET - highest bit of LCD's 2-byte data bus
;           IOCFG22_ADDR_OFFSET - used for LCD's 2-byte data bus
;           IOCFG21_ADDR_OFFSET - used for LCD's 2-byte data bus
;           IOCFG20_ADDR_OFFSET - used for LCD's 2-byte data bus
;           IOCFG19_ADDR_OFFSET - used for LCD's 2-byte data bus
;           IOCFG18_ADDR_OFFSET - used for LCD's 2-byte data bus
;           IOCFG17_ADDR_OFFSET - used for LCD's 2-byte data bus
;           IOCFG16_ADDR_OFFSET - lowest bit of LCD's 2-byte data bus
;           IOCFG10_ADDR_OFFSET - used for LCD's enable select control
;           IOCFG9_ADDR_OFFSET  - used for LCD's R/~W select control 
;           IOCFG8_ADDR_OFFSET  - used for LCD's RS select control 
;       GPIO:  
;           DIN31_0_ADDR_OFFSET  - used for reading inputs from keypad 
;           DOUT31_0_ADDR_OFFSET - used for sending outputs to keypad 
;           DOE31_0_ADDR_OFFSET  - used for enabling output pins for keypad
;       GPTn:
;           ICLR_ADDR_OFFSET  - used for clearing timer interrupt
;           CFG_ADDR_OFFSET   - used for configuring timer load register size 
;           CTL_ADDR_OFFSET   - used for enabling and starting Timer
;           IMR_ADDR_OFFSET   - used for enabling Timer interrupt 
;           TAMR_ADDR_OFFSET  - used for configuring Timer A mode 
;           TBMR_ADDR_OFFSET  - used for configuring Timer B mode 
;           TAILR_ADDR_OFFSET - used for controlling Timer A interrupt rate
;           TBILR_ADDR_OFFSET - used for controlling Timer B interrupt rate
;           TAPR_ADDR_OFFSET  - prescaler for TAILR 
;           TBPR_ADDR_OFFSET  - prescaler for TBILR 
;   LCD Constants:
;           LCD_FIRST_ROW     - first row's DDRAM address value 
;           LCD_SECOND_ROW    - second row's DDRAM address value
;           LCD_CURR_ROW      - to set current row position  
;           LCD_CURR_COL      - to set current col position 
;   PRCM Constants: 
;       PRCM_STN_LOAD_MASK   - to check LOAD_DONE bit 
;       PERIPH_POWER_ON_MASK - to check PERIPH_ON bit 
;       PERIPH_CLOCK_ON      - to enable CLK_EN bit for peripherals 
;       LOAD_PERIPH_SETNS    - to enable LOAD bit for peripherals 
;       GPTCLKGR_SETNS_GPTO  - to enable CLK_EN bit for GP Timer 0 
;       GPTCLKGR_SETNS_GPT1  - to enable CLK_EN bit for GP Timer 1 
;   STACK Constants:
;       HANDLER_STACK_SIZE
;       PROCESS_STACK_SIZE
;       TOTAL_STACK_SIZE
;
; REVISION HISTORY:
;     11/20/19  Di Hu      Initial Revision
;     12/26/19  Di Hu      Edited commenting 
;     01/10/20  Di Hu      Deleted STACK_ADDR


    .data


;LCD CONSTANTS 
LCD_FIRST_ROW               .EQU    0x00    ;first row's DDRAM address value 
LCD_SECOND_ROW              .EQU    0x40    ;second row's DDRAM address value
LCD_CURR_ROW                .EQU    0xFF    ;set to current row position, only  
                                            ;   valid when used with LCD_CURR_COL 
LCD_CURR_COL                .EQU    0xFF    ;set to current col position, only  
                                            ;   valid when used with LCD_CURR_COL 


;STACK CONSTANTS 
HANDLER_STACK_SIZE          .EQU    128
PROCESS_STACK_SIZE          .EQU    256
TOTAL_STACK_SIZE            .EQU    PROCESS_STACK_SIZE + HANDLER_STACK_SIZE


;PRCM CONSTANTS 
PERIPH_POWER_ON_MASK        .EQU    0x00000004
                                            ;|
                                            ;0100(PERIPH_ON: PERIPH powered up)
PERIPH_CLOCK_ON             .EQU    0x00000001
                                            ;|
                                            ;0001(CLK_EN: enable clock)
LOAD_PERIPH_SETNS           .EQU    0x00000001
                                            ;|
                                            ;0001(LOAD: load settings to CLKCTRL)
PRCM_STN_LOAD_MASK          .EQU    0x00000002
                                            ;|
                                            ;0010(LOAD_DONE: status of LOAD)
GPTCLKGR_SETNS_GPTO         .EQU    0x00000001
                                            ;|
                                            ;0001(CLK_EN: Enable clock for GPT0)
GPTCLKGR_SETNS_GPT1         .EQU    0x00000002
                                            ;|
                                            ;0010(CLK_EN: Enable clock for GPT1)


;REGISTER OFFSET ADDRESS  
;
;PRCM Registers
PDCTL0_ADDR_OFFSET          .EQU    0x12C   ;used for enabling GPIO power 
PDSTAT0_ADDR_OFFSET         .EQU    0x140   ;used for checking GPIO power on  
GPIOCLKGR_ADDR_OFFSET       .EQU    0x48    ;used for enabling GPIO clock  
CLKLOADCTL_ADDR_OFFSET      .EQU    0x28    ;used for loading PRCM stns to CLKCTRL
GPTCLKGR_ADDR_OFFSET        .EQU    0x54    ;used for enabling GPT0's clock 
;
;IOC Registers
IOCFG23_ADDR_OFFSET         .EQU    0x5C    ;highest bit of LCD's 2-byte data bus
IOCFG22_ADDR_OFFSET         .EQU    0x58    ;used for LCD's 2-byte data bus
IOCFG21_ADDR_OFFSET         .EQU    0x54    ;used for LCD's 2-byte data bus
IOCFG20_ADDR_OFFSET         .EQU    0x50    ;used for LCD's 2-byte data bus
IOCFG19_ADDR_OFFSET         .EQU    0x4C    ;used for LCD's 2-byte data bus
IOCFG18_ADDR_OFFSET         .EQU    0x48    ;used for LCD's 2-byte data bus
IOCFG17_ADDR_OFFSET         .EQU    0x44    ;used for LCD's 2-byte data bus
IOCFG16_ADDR_OFFSET         .EQU    0x40    ;lowest bit of LCD's 2-byte data bus
IOCFG10_ADDR_OFFSET         .EQU    0x28    ;used for LCD's enable select control
IOCFG9_ADDR_OFFSET          .EQU    0x24    ;used for LCD's R/~W select control 
IOCFG8_ADDR_OFFSET          .EQU    0x20    ;used for LCD's RS select control 
;
;GPIO Registers 
DIN31_0_ADDR_OFFSET         .EQU    0xC0    ;used for reading in input value 
DOUT31_0_ADDR_OFFSET        .EQU    0x80    ;used for writing out output value
DOE31_0_ADDR_OFFSET         .EQU    0xD0    ;used for enabling output pins 
;
;GPTn Registers 
ICLR_ADDR_OFFSET            .EQU    0x24    ;used for clearing timer interrupt
CFG_ADDR_OFFSET             .EQU    0x0     ;used for selecting timer type
CTL_ADDR_OFFSET             .EQU    0xC     ;used for enabling and clearing timer
IMR_ADDR_OFFSET             .EQU    0x18    ;used for configuring timer interrupt
TAMR_ADDR_OFFSET            .EQU    0x4     ;used for configuring timer A's mode
TBMR_ADDR_OFFSET            .EQU    0x8     ;used for configuring timer B's mode
TAILR_ADDR_OFFSET           .EQU    0x28    ;used for setting counting time
                                            ;   for timer A
TBILR_ADDR_OFFSET           .EQU    0x2C    ;used for setting counting time
                                            ;   for timer B
                                            ;  (interrupt rate)
TAPR_ADDR_OFFSET            .EQU    0x38    ;used for prescaling TAILR
TBPR_ADDR_OFFSET            .EQU    0x3C    ;used for prescaling TBILR


;MODULE BASE ADDRESS
GPT0_BASE_ADDR          .EQU    0x40010000  ;used for: 
                                            ;   - counting time delays  
GPT1_BASE_ADDR          .EQU    0x40011000  ;used for:
                                            ;   - counting time delays  
GPIO_BASE_ADDR          .EQU    0x40022000  ;used for:
                                            ;   - enable output pins 
IOC_BASE_ADDR           .EQU    0x40081000  ;used for:
                                            ;   - configure IO pins 
PRCM_BASE_ADDR          .EQU    0x40082000  ;used for:
                                            ;   - enable GPIO power and clock
