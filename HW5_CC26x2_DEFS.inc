;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW5_CC26x2_DEFS.inc                            ;
;                   General Definitions for CC2652 Specifics                 ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains used modules' bases addresses, their registers' address 
; offset values, and interrupt table, register constants for CC2652 launchpad. 
; 
; CONSTANT INDEX: 
;   Module Base Address: 
;       GPT3_BASE_ADDR          - used for controlling stepper through PWM timer  
;       GPT2_BASE_ADDR          - used for generate interrupts for stepper   
;       GPIO_BASE_ADDR          - used for configuring and accessing servo IOs  
;       IOC_BASE_ADDR           - used for IO pin configuration 
;       PRCM_BASE_ADDR          - used for enabling GPIO power and clock 
;       CPU_SCS_BASE_ADDR       - used for interrupt table initialization       
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
;       CPU_SCS: 
;           VTOR_ADDR_OFFSET    - used for updating vector table address 
;           NVIC_ISER0_ADDR_OFFSET  
;                               - used for enabling interrupts  
;       IOC:
;           IOCFG0_ADDR_OFFSET  - used for enabling stepper control A
;           IOCFG1_ADDR_OFFSET  - used for enabling stepper control B
;           IOCFG2_ADDR_OFFSET  - used to set stepper control A's DAC output
;           IOCFG3_ADDR_OFFSET  - used to set stepper control B's DAC output
;       GPIO:  
;           DOUT31_0_ADDR_OFFSET- used for controlling stepper 
;           DOE31_0_ADDR_OFFSET - used for enabling output pins for stepper 
;       GPTn:
;           ICLR_ADDR_OFFSET    - used clearing Timer2B's interrupt
;           CFG_ADDR_OFFSET     - used for configuring timer load register size 
;           CTL_ADDR_OFFSET     - used for enabling and starting Timer
;           IMR_ADDR_OFFSET     - used for enabling interrupt in Timer2B  
;           TAMR_ADDR_OFFSET    - used for configuring Timer A mode 
;           TBMR_ADDR_OFFSET    - used for configuring Timer B mode 
;           TAILR_ADDR_OFFSET   - used for setting PWM Timer3A's full cycle width  
;           TBILR_ADDR_OFFSET   - used for controlling Timer2B's interrupt rate 
;                                 and setting PWM Timer3B's full cycle width  
;           TAPR_ADDR_OFFSET    - prescaler for TAILR 
;           TBPR_ADDR_OFFSET    - prescaler for TBILR 
;           TAMATCHR_ADDR_OFFSET- used for setting PWM Timer A low pulse width 
;           TAPMR_ADDR_OFFSET   - prescaler for TAMATCHR 
;           TBMATCHR_ADDR_OFFSET- used for setting PWM Timer B low pulse width 
;           TBPMR_ADDR_OFFSET   - prescaler for TBMATCHR 
;   INTERRUPT Constants:
;       IR_VTABLE_SIZE          - interrupt vector table size 
;       Timer2B_ADDR_OFFSET     - Timer2B handler's offset address in IR table
;       ENABLE_TIMER2B_IRQ      - enable Timer2B's interrupt 
;   STEPPER Constants: 
;       HALF_WORD_SIZE_IN_BYTE  - for reading values from stepper table 
;       PRESCALE_SIXTEEN        - for prescaling 16 bits 
;       BOTTOM_HALFWORD_MASK    - AND mask to get low half word 
;   PRCM Constants: 
;       PRCM_STN_LOAD_MASK      - used for checking LOAD_DONE bit 
;       PERIPH_POWER_ON_MASK    - used for checking PERIPH_ON bit 
;       PERIPH_CLOCK_ON         - used for enabling CLK_EN bit for peripherals 
;       LOAD_PERIPH_SETNS       - used for enabling LOAD bit for peripherals 
;       GPTCLKGR_SETNS_GPTO     - used for enabling CLK_EN bit for GP Timer 0 
;       GPTCLKGR_SETNS_GPT1     - used for enabling CLK_EN bit for GP Timer 1 
;       GPTCLKGR_SETNS_GPT2     - used for enabling CLK_EN bit for GP Timer 2
;       GPTCLKGR_SETNS_GPT3     - used for enabling CLK_EN bit for GP Timer 3
;   STACK Constants:
;       HANDLER_STACK_SIZE
;       PROCESS_STACK_SIZE
;       TOTAL_STACK_SIZE
;   miscellaneous: 
;       TRUE                    - truth value 1 
;       FALSE                   - truth value 0
;
; REVISION HISTORY:
;     12/10/19  Di Hu      Initial Revision
;     12/30/19  Di Hu      Edited comments 
;     01/11/20  Di Hu      Deleted STACK_ADDR
;     01/18/20  Di Hu      Added TRUE and FALSE


     .data

TRUE                        .EQU    1
FALSE                       .EQU    0

;MISCELLANEOUS CONSTANTS USED IN STEPPER's TIMER ROUTINES 
LSR_SIXTEEN                 .EQU    16          ;for right shifting by 16 bits 
BOTTOM_HALFWORD_MASK        .EQU    0x0000FFFF  ;AND mask to get low half word 
HALF_WORD_SIZE_IN_BYTE      .EQU    2           ;one half word is 2 bytes 


;INTERRUPT CONSTANTS 
;
IR_VTABLE_SIZE              .EQU    0xC8    ;IR vector table's total byte size
Timer2B_ADDR_OFFSET         .EQU    0x90    ;Timer2B handler's offset address 
                                            ;    in the IR vector table 
ENABLE_TIMER2B_IRQ          .EQU    0x00100000  ;interrupt enable register  
                                       ;|
                                       ;0001(SETENA20: enable GP Timer2B
                                       ; Interrupt, which is No.20 interrupt)


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
GPTCLKGR_SETNS_GPT3         .EQU    0x00000008
                                            ;|
                                            ;1000(CLK_EN: Enable clock for GPT3)


;REGISTER OFFSET ADDRESS  
;
;PRCM Registers 
PDCTL0_ADDR_OFFSET          .EQU    0x12C   ;used for enabling GPIO power 
PDSTAT0_ADDR_OFFSET         .EQU    0x140   ;used for checking GPIO power on  
GPIOCLKGR_ADDR_OFFSET       .EQU    0x48    ;used for enabling GPIO clock  
CLKLOADCTL_ADDR_OFFSET      .EQU    0x28    ;used for loading PRCM settings
                                            ;    to CLKCTRL
GPTCLKGR_ADDR_OFFSET        .EQU    0x54    ;used for enabling GPT0's clock 

;CPU_SCS Registers 
VTOR_ADDR_OFFSET            .EQU    0xD08   ;used for updating vector table 
NVIC_ISER0_ADDR_OFFSET      .EQU    0x100   ;used for enabling interrupts 

;IOC Registers
IOCFG0_ADDR_OFFSET          .EQU    0x0     ;used for setting stepper control A 
IOCFG1_ADDR_OFFSET          .EQU    0x4     ;used for setting stepper control B
IOCFG2_ADDR_OFFSET          .EQU    0x8     ;used for setting stepper
                                            ;    control A's DAC output
IOCFG3_ADDR_OFFSET          .EQU    0xC     ;used for setting stepper
                                            ;    control B's DAC output

;GPIO Registers 
DOUT31_0_ADDR_OFFSET        .EQU    0x80    ;used for writing out output value 
                                            ;   for controlling stepper 
DOE31_0_ADDR_OFFSET         .EQU    0xD0    ;used for enabling output pins 

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
TAMATCHR_ADDR_OFFSET        .EQU    0x30    ;used for setting pulse width for
                                            ;   PWM timer A
TAPMR_ADDR_OFFSET           .EQU    0x40    ;used for prescaling TAMATCHR 
TBMATCHR_ADDR_OFFSET        .EQU    0x34    ;used for setting pulse width for
                                            ;   PWM timer B
TBPMR_ADDR_OFFSET           .EQU    0x44    ;used for prescaling TBMATCHR 


;MODULE BASE ADDRESS
;
GPT3_BASE_ADDR              .EQU    0x40013000  ;used to: 
                                                ;   - control step motor
GPT2_BASE_ADDR              .EQU    0x40012000  ;used to: 
                                                ;   - control servo motor 
                                                ;   - generate interrupt for
                                                ;     step motor
GPT1_BASE_ADDR              .EQU    0x40011000  ;used for:
                                                ;   - counting time delays  
GPIO_BASE_ADDR              .EQU    0x40022000  ;used to:
                                                ;   - enable output pins 
                                                ;   - read in inputs 
                                                ;   - write to outputs 
IOC_BASE_ADDR               .EQU    0x40081000  ;used to:
                                                ;   - configure IO pins 
PRCM_BASE_ADDR              .EQU    0x40082000  ;used to:
                                                ;   - enable GPIO power and clock
CPU_SCS_BASE_ADDR           .EQU    0xE000E000  ;used to: 
                                                ;   - enable interrupts 
                                                ;   - update vector table 
