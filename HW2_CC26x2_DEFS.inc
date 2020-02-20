;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW2_CC26x2_DEFS.inc                            ;
;                   General Definitions for CC2652 Specifics                 ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains used modules' bases addresses, their registers' address 
; offset values, and interrupt table, register constants for CC2652 launchpad. 
; 
; CONSTANT INDEX: 
;   Module Base Address: 
;       GPT0_BASE_ADDR - used for clear Timer 0 interrupt 
;       GPIO_BASE_ADDR - used for writing and reading IO
;       IOC_BASE_ADDR - used for IO configuration
;       CPU_SCS_BASE_ADDR - used for interrupt initialization       
;   Register Offset Address:  
;       PRCM: 
;           PDCTL0_ADDR_OFFSET - used for enabling GPIO power in main function
;           PDSTAT0_ADDR_OFFSET - used for checking GPIO power on in main 
;           GPIOCLKGR_ADDR_OFFSET - used for enabling GPIO clock in main 
;           CLKLOADCTL_ADDR_OFFSET - used for loading PRCM stns to CLKCTRL 
;                                     in main 
;           GPTCLKGR_ADDR_OFFSET - used for enabling GPT0's clock in main 
;       IOC:
;           IOCFG15_ADDR_OFFSET - used for column selection on keypad   
;           IOCFG14_ADDR_OFFSET - used for column selection on keypad   
;           IOCFG13_ADDR_OFFSET - used for column selection on keypad  
;           IOCFG12_ADDR_OFFSET - used for column selection on keypad   
;           IOCFG5_ADDR_OFFSET - used for row selection on keypad   
;           IOCFG4_ADDR_OFFSET - used for row selection on keypad  
;       GPIO:  
;           DIN31_0_ADDR_OFFSET - used for reading inputs from keypad 
;           DOUT31_0_ADDR_OFFSET - used for sending outputs to keypad 
;           DOE31_0_ADDR_OFFSET - used for enabling output pins for keypad
;       GPT0:
;           ICLR_ADDR_OFFSET - used for clearing Timer0A's interrupt
;           CFG_ADDR_OFFSET - used for selecting timer type for Timer0A
;           CTL_ADDR_OFFSET - used for enabling and starting Timer0A
;           IMR_ADDR_OFFSET - used for enabling Timer0A interrupt 
;           TAMR_ADDR_OFFSET - used for configuring Timer0A's mode 
;           TAILR_ADDR_OFFSET - used for controlling Timer0A's interrupt rate
;   Interrupt Constants:
;       IR_VTABLE_SIZE - interrupt vector table size 
;       Timer0A_ADDR_OFFSET - address offset for Timer0A handler in IR table
;   PRCM Constants: 
;       PRCM_STN_LOAD_MASK - to check LOAD_DONE bit 
;       PERIPH_POWER_ON_MASK - to check PERIPH_ON bit 
;       PERIPH_CLOCK_ON - to enable CLK_EN bit  
;       LOAD_PERIPH_SETNS - to enable LOAD bit 
;       GPTCLKGR_SETNS - to enable CLK_EN bit 
;
; REVISION HISTORY:
;     11/20/19  Di Hu      Initial Revision


    .data

;debug usage 
CSC_BA .EQU 0xE000E000
CFSR_ADDR .EQU 0xD28
CFSR_CHF .EQU 0x00008200


;STACK CONSTANTS 
HANDLER_STACK_SIZE      .EQU    128
PROCESS_STACK_SIZE      .EQU    256
TOTAL_STACK_SIZE        .EQU    PROCESS_STACK_SIZE + HANDLER_STACK_SIZE
STACK_ADDR              .EQU    0x20013F00


;PRCM CONSTANTS 
PERIPH_POWER_ON_MASK    .EQU    0x00000004
                                        ;|
                                        ;0100(PERIPH_ON: PERIPH powered up)
PERIPH_CLOCK_ON         .EQU    0x00000001
                                        ;|
                                        ;0001(CLK_EN: enable clock)
LOAD_PERIPH_SETNS       .EQU    0x00000001
                                        ;|
                                        ;0001(LOAD: load settings to CLKCTRL)
PRCM_STN_LOAD_MASK      .EQU    0x00000002
                                        ;|
                                        ;0010(LOAD_DONE: status of LOAD)
GPTCLKGR_SETNS          .EQU    0x00000001
                                        ;|
                                        ;0001(CLK_EN: Enable clock for GPT0)


;INTERRUPT CONSTANTS 
;
IR_VTABLE_SIZE          .EQU    0xC8    ;IR vector table's total byte size
Timer0A_ADDR_OFFSET     .EQU    0x07C   ;Timer0A handler's offset addr in 
                                        ; the IR vector table 
NVIC_ISER0_SETNS        .EQU    0x00008000  ;interrupt enable register  
                                     ;|
                                     ;1000(SETENA15: enable GP Timer 0A
                                     ; Interrupt, which is No.15 interrupt)


;REGISTER OFFSET ADDRESS  
;
;PRCM Registers 
;
PDCTL0_ADDR_OFFSET      .EQU    0x12C   ;used for enabling GPIO power 
PDSTAT0_ADDR_OFFSET     .EQU    0x140   ;used for checking GPIO power on  
GPIOCLKGR_ADDR_OFFSET   .EQU    0x48    ;used for enabling GPIO clock  
CLKLOADCTL_ADDR_OFFSET  .EQU    0x28    ;used for loading PRCM stns to CLKCTRL
GPTCLKGR_ADDR_OFFSET    .EQU    0x54    ;used for enabling GPT0's clock 
;IOC Registers
IOCFG5_ADDR_OFFSET      .EQU    0x14    ;used for config keypad output pin  
IOCFG4_ADDR_OFFSET      .EQU    0x10    ;used for config keypad output pin 
IOCFG15_ADDR_OFFSET     .EQU    0x3C    ;used for config keypad input pin 
IOCFG14_ADDR_OFFSET     .EQU    0x38    ;used for config keypad input pin
IOCFG13_ADDR_OFFSET     .EQU    0x34    ;used for config keypad input pin
IOCFG12_ADDR_OFFSET     .EQU    0x30    ;used for config keypad input pin
;
;GPIO Registers 
DIN31_0_ADDR_OFFSET     .EQU    0xC0    ;used for reading in input value 
DOUT31_0_ADDR_OFFSET    .EQU    0x80    ;used for writing out output value
DOE31_0_ADDR_OFFSET     .EQU    0xD0    ;used for enabling output pins 
;
;CPU_SCS Registers 
VTOR_ADDR_OFFSET        .EQU    0xD08   ;used for updating vector table location
NVIC_ISER0_ADDR_OFFSET  .EQU    0x100   ;used for enabling interrupts 
;
;GPT0 Registers 
ICLR_ADDR_OFFSET        .EQU    0x24    ;used for clearing timer interrupt
CFG_ADDR_OFFSET         .EQU    0x0     ;used for selecting timer type 
CTL_ADDR_OFFSET         .EQU    0xC     ;used for enabling and starting timer
IMR_ADDR_OFFSET         .EQU    0x18    ;used for enabling timer interrupt 
TAMR_ADDR_OFFSET        .EQU    0x4     ;used for configuring timer mode 
TAILR_ADDR_OFFSET       .EQU    0x28    ;used for controlling counting time
                                        ;                    (interrupt rate)
TAPR_ADDR_OFFSET        .EQU    0x38    ;used for controlling counting time 

;MODULE BASE ADDRESS
;
GPT0_BASE_ADDR          .EQU    0x40010000  ;used to: 
                                            ;   - clear Timer0A interrupt 
                                            ;   - update vtor
GPIO_BASE_ADDR          .EQU    0x40022000  ;used to:
                                            ;   - enable output pins 
IOC_BASE_ADDR           .EQU    0x40081000  ;used to:
                                            ;   - configure IO pins 
PRCM_BASE_ADDR          .EQU    0x40082000  ;used to:
                                            ;   - enable GPIO power and clock
CPU_SCS_BASE_ADDR       .EQU    0xE000E000  ;used to: 
                                            ;   - enable interrupts 
                                            ;   - update vtor


