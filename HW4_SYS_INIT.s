;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                               HW4_SYS_INIT.s                               ;
;                         System Initialization Routines                     ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains functions for enabling power and clock for launchpad CC2652's   
; GPIO, GPT1 and GPT2 modules. 
;
; FUNCTION INDEX: 
;     InitSystemPower   -  turn on power for GPIO in PRCM 
;     InitSystemClock   -  turn on clock for GPIO, GPT1 and GPT2 in PRCM
;
; REVISION HISTORY:
;     01/10/20  Di Hu      Initial Revision, separated out from main. 
;     01/11/20  Di Hu      Edited comments. 

;   .include files 
    .include "HW4_CC26x2_DEFS.inc"
    .include "HW4_MACROS.inc"

;   public functions 
    .global InitSystemPower
    .global InitSystemClock


    .text
;code starts 

; InitSystemPower
;
; Description:       This function turns on GPIO module's power in PRCM. 
;
; Operation:         This function sets the power bit on in PRCM.PDCTL0 and
;                    loop till power bit in PRCM.PDSTAT0 is on. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   R1 is used as base address for PRCM to access its registers. 
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
; Registers Changed: R0, R1, R2
; Stack Depth:       0 
;
; Author:            Di Hu
; Last Modified:     Jan 10, 2019
InitSystemPower: 
    MV32 R1, #PRCM_BASE_ADDR

SetupGPIOPower:                        ;turn on power for GPIO
    MOV R0, #PERIPH_POWER_ON_MASK      ;turn on enable power bit in PRCM.PDCTL0
    STR R0, [R1, #PDCTL0_ADDR_OFFSET]

CheckPeriphPower:                      ;wait for GPIO power to turn on
    LDR R2, [R1, #PDSTAT0_ADDR_OFFSET] ;read value in PRCM.PDSTAT0 into R2
    AND R2, R2, #PERIPH_POWER_ON_MASK  ;mask to read periph power bit  
    CMP R2, #PERIPH_POWER_ON_MASK      ;check if periph power bit is on
    BNE CheckPeriphPower               ;if not, keep waiting and checking
    ;BEQ  done                         ;else, finished and return 
    BX LR 


; InitSystemClock
;
; Description:       This function turns on GPIO, GPT1 and GPT2's clock in PRCM.  
;
; Operation:         This function sets the clock bits in PRCM.GPIOCLKGR and 
;                    PRCM.GPTCLKGR, set LOAD bit in PRCM.CLKLOADCTL to load
;                    PRCM clock settings and loop till LOAD_DONE bit is set in 
;                    PRCM.CLKLOADCTL. 
;
; Arguments:         None. 
;
; Return Value:      None. 
;
; Local Variables:   R1 is used as base address for PRCM to access its registers. 
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
; Registers Changed: R0, R1, R2
; Stack Depth:       0 
;
; Author:            Di Hu
; Last Modified:     Jan 11, 2019
InitSystemClock:
    MV32 R1, #PRCM_BASE_ADDR

EnablePeriphClock:                     ;enable clock for GPIO
    MOV R0, #PERIPH_CLOCK_ON           ;turn on enable clock bit in
                                       ; PRCM.GPIOCLKGR
    STR R0, [R1, #GPIOCLKGR_ADDR_OFFSET]

EnableGPTnClock:                  ;enable clock for GPT0 for run and all modes
    MOV R0, #GPTCLKGR_SETNS_GPTO       ;turn on enable clock bit for GPT0 and
    ORR R0, R0, #GPTCLKGR_SETNS_GPT1   ; GPT1 in PRCM.GPTCLKGR
    ORR R0, R0, #GPTCLKGR_SETNS_GPT2   ; GPT2 in PRCM.GPTCLKGR
    STR R0, [R1, #GPTCLKGR_ADDR_OFFSET]

LoadPRCMSettings:                      ;Load PRCM Settings to CLKCTRL Power
                                       ; Domain
    MOV R0, #LOAD_PERIPH_SETNS         ;turn on load bit in PRCM.CLKLOADCTL
    STR R0, [R1, #CLKLOADCTL_ADDR_OFFSET]

CheckLoadPRCMStnDone:                  ;check PRCM Settings is loaded 
    LDR R2, [R1, #CLKLOADCTL_ADDR_OFFSET]
                                       ;read value in PRCM.CLKLOADCTL into R2
    AND R2, R2, #PRCM_STN_LOAD_MASK        
    CMP R2, #PRCM_STN_LOAD_MASK        ;check if LOAD_DONE bit is on
    BNE CheckLoadPRCMStnDone           ;if not, keep waiting and checking
    ;BEQ  done                         ;else, finished and return 
    BX LR 