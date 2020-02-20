;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW4_CC26x2_DEFS.inc                            ;
;                   General Definitions for CC2652 Specifics                 ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains used modules' bases addresses, their registers' address 
; offset values, stack constants, PRCM constants for CC2652 launchpad and
; constants for servo motor routines and tests. 
; 
; CONSTANT INDEX: 
;   Module Base Address: 
;       GPT2_BASE_ADDR          - used for controlling servo through PWM timer  
;       GPIO_BASE_ADDR          - used for configuring and accessing servo IOs  
;       IOC_BASE_ADDR           - used for IO pin configuration 
;       PRCM_BASE_ADDR          - used for enabling GPIO power and clock 
;       AUX_ADI4_BASE_ADDR      - used for initializing ADC module
;       AUX_ANAIF_BASE_ADDR     - used for configure ADC mode and read ADC sample
;       AUX_EVCTL_BASE_ADDR     - used for check and acknowledge ADC FIFO
;                                 sample ready 
;       AUX_SYSIF_BASE_ADDR     - used for enable ADC module clock 
;       AUX_AIODIO3_BASE_ADDR   - used for configure AUX IO pin mode 
;   Register Offset Address:  
;       PRCM: 
;           PDCTL0_ADDR_OFFSET  - used for enabling GPIO power in main function
;           PDSTAT0_ADDR_OFFSET - used for checking GPIO power on in main 
;           GPIOCLKGR_ADDR_OFFSET   
;                               - used for enabling GPIO clock in main 
;           CLKLOADCTL_ADDR_OFFSET  
;                               - used for loading PRCM settings to CLKCTRL 
;                                 in main 
;           GPTCLKGR_ADDR_OFFSET    
;                               - used for selecting timer type 
;       IOC:
;           IOCFG11_ADDR_OFFSET - highest bit of LCD's 2-byte data bus
;           IOCFG24_ADDR_OFFSET - used for LCD's 2-byte data bus
;       GPIO:  
;           DIN31_0_ADDR_OFFSET - used for reading inputs from keypad 
;           DOE31_0_ADDR_OFFSET - used for enabling output pins for keypad
;       GPTn:
;           CFG_ADDR_OFFSET     - used for configuring timer load register size 
;           CTL_ADDR_OFFSET     - used for enabling and starting Timer
;           TAMR_ADDR_OFFSET    - used for configuring Timer A mode 
;           TAILR_ADDR_OFFSET   - used for setting Timer A PWM full cycle width
;           TAPR_ADDR_OFFSET    - prescaler for TAILR 
;           TAMATCHR_ADDR_OFFSET 
;                               - used for setting PWM A low pulse width 
;           TAPMR_ADDR_OFFSET   - prescaler for TAMATCHR 
;       AUX: 
;           ADCCLKCTL_ADDR_OFFSET
;                               - in SYSIF; for enabling AUX clock 
;           MUX3_ADDR_OFFSET    - in ADI4; for enabling selected AUXIO pin 
;           ADC0_ADDR_OFFSET    - in ADI4; for configuring and enabling 
;                                 ADC module 
;           ADCREF0_ADDR_OFFSET - in ADI4; for enabling ADCREF0
;           IOMODE_ADDR_OFFSET  - in AIODIO; for configuring AUX IO
;                                 pin mode 
;           GPIODIE_ADDR_OFFSET - in AIODIO; for enabling input buffers
;           ADCCTL_ADDR_OFFSET  - in ANAIF; for configuring ADC trigger
;           ADCFIFO_ADDR_OFFSET - in ANAIF; for reading ADC samples
;           ADCTRIG_ADDR_OFFSET - in ANAIF; for configuring ADC trigger 
;           EVTOMCUFLAGS_ADDR_OFFSET    
;                               - in EVCTL; for checking ADC sample ready 
;           EVTOMCUFLAGSCLR_ADDR_OFFSET 
;                               - in EVCTL; for clearing ADC sample's
;                                 ready flag 
;   SERVO Constants: 
;       NEG_NINETY              - signed integer -90 
;       LSR_SIXTEEN             - for right shifting by 16 bits 
;       PRESCALE_SIXTEEN        - for prescaling 16 bits 
;       LOWER_HALFWORD_MASK     - AND mask to get low half word 
;   PRCM Constants: 
;       PRCM_STN_LOAD_MASK      - used for checking LOAD_DONE bit 
;       PERIPH_POWER_ON_MASK    - used for checking PERIPH_ON bit 
;       PERIPH_CLOCK_ON         - used for enabling CLK_EN bit for peripherals 
;       LOAD_PERIPH_SETNS       - used for enabling LOAD bit for peripherals 
;       GPTCLKGR_SETNS_GPTO     - used for enabling CLK_EN bit for GP Timer 0 
;       GPTCLKGR_SETNS_GPT1     - used for enabling CLK_EN bit for GP Timer 1 
;       GPTCLKGR_SETNS_GPT2     - used for enabling CLK_EN bit for GP Timer 2
;   STACK Constants:
;       HANDLER_STACK_SIZE
;       PROCESS_STACK_SIZE
;       TOTAL_STACK_SIZE
;
; REVISION HISTORY:
;     12/17/19  Di Hu      Initial Revision
;     12/28/19  Di Hu      Edited comments 
;     01/10/20  Di Hu      Deleted STACK_ADDR



     .data


;MISCELLANEOUS CONSTANTS USED IN SERVO
NEG_NINETY                  .EQU    0xFFFFFFA6  ;signed integer -90
LSR_SIXTEEN                 .EQU    16          ;for right shifting by 16 bits 
PRESCALE_SIXTEEN            .EQU    15          ;for prescaling 16 bits 
LOWER_HALFWORD_MASK         .EQU    0x0000FFFF  ;AND mask to get low half word 


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
GPTCLKGR_SETNS_GPT2         .EQU    0x00000004
                                            ;|
                                            ;0100(CLK_EN: Enable clock for GPT2)


;REGISTER OFFSET ADDRESS  

;PRCM Registers
PDCTL0_ADDR_OFFSET          .EQU    0x12C   ;used for enabling GPIO power 
PDSTAT0_ADDR_OFFSET         .EQU    0x140   ;used for checking GPIO power on  
GPIOCLKGR_ADDR_OFFSET       .EQU    0x48    ;used for enabling GPIO clock  
CLKLOADCTL_ADDR_OFFSET      .EQU    0x28    ;used for loading PRCM settings
                                            ;    to CLKCTRL
GPTCLKGR_ADDR_OFFSET        .EQU    0x54    ;used for enabling GPT0's clock 

;IOC Registers
IOCFG24_ADDR_OFFSET         .EQU    0x60    ;for configuring servo ADC input
IOCFG11_ADDR_OFFSET         .EQU    0x2C    ;for configuring servo DAC output 

;GPIO Registers 
DIN31_0_ADDR_OFFSET         .EQU    0xC0    ;used for reading in servo's 
                                            ;   analog input  
DOE31_0_ADDR_OFFSET         .EQU    0xD0    ;used for enabling output pins 

;GPTn Registers 
CFG_ADDR_OFFSET             .EQU    0x0     ;used for selecting timer type
CTL_ADDR_OFFSET             .EQU    0xC     ;used for enabling and clearing timer
TAMR_ADDR_OFFSET            .EQU    0x4     ;used for configuring timer A's mode
TAILR_ADDR_OFFSET           .EQU    0x28    ;used for setting counting time
                                            ;   for timer A
TAPR_ADDR_OFFSET            .EQU    0x38    ;used for prescaling TAILR
TAMATCHR_ADDR_OFFSET        .EQU    0x30    ;used for setting pulse width for
                                            ;   PWM timer A 
TAPMR_ADDR_OFFSET           .EQU    0x40    ;used for prescaling TAMATCHR 

;AUX Registers
;SYSIF Registers 
ADCCLKCTL_ADDR_OFFSET       .EQU    0x50    ;used for enabling AUX clock 

;ADI4 Registers
MUX3_ADDR_OFFSET            .EQU    0x3     ;BYTE register, used for enable 
                                            ;   selected AUX IO pin
ADC0_ADDR_OFFSET            .EQU    0x8     ;BYTE register, used for configuring 
                                            ;   ADC settings and enabling ADC 
ADCREF0_ADDR_OFFSET         .EQU    0xA     ;BYTE register, used for configuring
                                            ;   and enabling ADC reference module 

;AIODIOn Registers
IOMODE_ADDR_OFFSET          .EQU    0x0     ;used for configuring AUX IO mode 
GPIODIE_ADDR_OFFSET         .EQU    0x4     ;used for enable input buffer for
                                            ;   AUX input pins

;ANAIF Registers 
ADCCTL_ADDR_OFFSET          .EQU    0x10    ;used for configuring ADC trigger 
ADCFIFO_ADDR_OFFSET         .EQU    0x18    ;used for reading ADC sample 
ADCTRIG_ADDR_OFFSET         .EQU    0x1C    ;used for configuring ADC trigger 

;EVCTL Registers
EVTOMCUFLAGS_ADDR_OFFSET    .EQU    0x30    ;used for checking if ADC FIFO sample
                                            ;   is ready 
EVTOMCUFLAGSCLR_ADDR_OFFSET .EQU    0x38    ;used for clearing ADC FIFO sample-
                                            ;   ready flag for next reading 


;MODULE BASE ADDRESS

GPT2_BASE_ADDR              .EQU    0x40012000  ;used for: 
                                                ;   - control servo motor 
GPIO_BASE_ADDR              .EQU    0x40022000  ;used for:
                                                ;   - enable output pins 
                                                ;   - read in inputs 
                                                ;   - write to outputs 
IOC_BASE_ADDR               .EQU    0x40081000  ;used for:
                                                ;   - configure IO pins 
PRCM_BASE_ADDR              .EQU    0x40082000  ;used for:
                                                ;   - enable GPIO power and clock
AUX_SYSIF_BASE_ADDR         .EQU    0x400C6000  ;System Interface, used for:
                                                ;   - enable ADC clock 
AUX_ADI4_BASE_ADDR          .EQU    0x400CB000  ;ADI Master, used for:
                                                ;   - initialize ADC module 
AUX_AIODIO3_BASE_ADDR       .EQU    0x400CF000  ;Analog Digital IOs, used for:
                                                ;   - configure AUX IOs 
AUX_ANAIF_BASE_ADDR         .EQU    0x400C9000  ;Analog Interface, used for:
                                                ;   - configure ADC mode and 
                                                ;   - read ADC sample 
AUX_EVCTL_BASE_ADDR         .EQU    0x400C5000  ;Event Controller, used for:
                                                ;   - check and acknowledge 
                                                ;     ADC FIFO sample ready 
