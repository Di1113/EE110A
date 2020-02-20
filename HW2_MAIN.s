;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 HW2_MAIN                                   ;
;                    INTERRUPT-CONTROLED KEYPAD ROUTINES                     ;
;                                 EE 110 A                                   ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program runs a subroutine that detects key presses on
;                   the keypad every one millisecond, debounces pressed keys 
;                   for 10 millisecond and enqueues the debounced key to an 
;                   event queue. 
; Operation:        This program initializes the launchpad by enabling the 
;                   power and clock for GPIO and calls Timer0A's interrupt 
;                   handler every millisecond to scan key presses on the keypad.
;
; Local Variables:  R1 is used as base address register for PRCM first and then
;                   for GPIO module.
; Shared Variables: None.
; Global Variables: None.
;
; Input:            Keypad Status. Pressed keys after debouncing are enqueued 
;                   as key events. 
;
; Output:           None. 
; User Interface:   Click-able keys on keypad. 
;
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Known Bugs:       None.
; Limitations:      None.
;
; Revision History:
;    11/10/19  Di Hu      Initial Revision
;       ...               Hardware debugging: Mux, Decoder, Diodes... 
;    11/21/19  Di Hu      - Added comments;
;                         - Replaced link to "HW2_MAIN.inc" with link to 
;                           "HW2_CC26x2_DEFS.inc"
;                         - Added CheckLoadPRCMStnDone
;    11/22/19  Di Hu      Bus Fault occurred after adding comments
;    11/23/19  Di Hu      Bus Fault disappeared for one running.
;	 11/25/19  Di Hu	  Debugged bus fault by add ".text" to timer and io files.

    ;include files 
    .include "HW2_CC26x2_DEFS.inc"
    .include "HW2_MACROS.inc"
    ;public functions 
    .ref ConfigKeypadIOs
    .ref KeypadInit   
    .ref ConfigTimer0A
    .ref InterruptInit
    .global temp

    .data                               ;allocate space for stack 
    .align 8
    .SPACE TOTAL_STACK_SIZE
TopOfStack:                             ;point to the bottom of the stack 


    .text
    .global ResetISR
	.align 4
ResetISR:

main:
;start of the actual program

SetUpStack:                            ;set up stack pointers
    LDR R0, addr_TopOfStack            ;initialize the stack pointers MSP, PSP
    MSR MSP, R0
    SUB R0, R0, #HANDLER_STACK_SIZE
    MSR PSP, R0

SetupGPIOPower:                        ;turn on power for GPIO
    MOV R0, #PERIPH_POWER_ON_MASK      ;turn on enable power bit in PRCM.PDCTL0
    MV32 R1, #PRCM_BASE_ADDR
    STR R0, [R1, #PDCTL0_ADDR_OFFSET]

CheckPeriphPower:                      ;wait for GPIO power to turn on
    LDR R2, [R1, #PDSTAT0_ADDR_OFFSET] ;read value in PRCM.PDSTAT0 into R2
    AND R2, R2, #PERIPH_POWER_ON_MASK  ;mask to read periph power bit  
    CMP R2, #PERIPH_POWER_ON_MASK      ;check if periph power bit is on
    BNE CheckPeriphPower               ;if not, keep waiting and checking
    ;BEQ  EnablePeriphClock            ;else, enable peripheral clock

EnablePeriphClock:                     ;enable clock for GPIO
    MOV R0, #PERIPH_CLOCK_ON           ;turn on enable clock bit in
                                       ; PRCM.GPIOCLKGR
    STR R0, [R1, #GPIOCLKGR_ADDR_OFFSET]

EnableGPT0Clock:                       ;enable clock for GPT0 for run and all modes
    MOV R0, #GPTCLKGR_SETNS            ;turn on enable clock bit for GPT0 in
                                       ; PRCM.GPTCLKGR
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
    ;BEQ Initializations               ;else, continue to function inits 

Initializations:
    BL ConfigKeypadIOs                 ;initialize keypad IO pins 
    BL KeypadInit                      ;initialize keypad buffers
    BL ConfigTimer0A                   ;configure Timer0A for keypad interrupt
    BL InterruptInit                   ;initialize interrupt vector table 

temp:                                  ;infinite loop to detect key presses 
                                       ;   by calling interrupt handler 
    B temp


addr_TopOfStack: .word TopOfStack


