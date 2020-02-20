;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                HW4_SERVO.s                                 ;
;                            Servo Control Routines                          ;
;                                  EE110A                                    ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains functions for controlling servo to specified positions 
; and for reading servo's current position in degrees. 
;
; FUNCTION INDEX: 
;     SetPulseValue(lp) - set PWM timer's TAMATCHR and TAPMR with lp 
;     SetServo(pos)     - convert pos to clocks and pass as lp to SetPulseValue
;                         to control servo motor 
;     InitADC           - initialize ADC module for reading converted analog data 
;     GetServoPosDegree - translate converted analog data(voltage value) to 
;                         position degrees with fixed-point multiplication 
;     GetServo          - return translated position degrees by GetServoPosDegree
;                         in R0 to report servo shaft's current position 
;
; REVISION HISTORY:
;     12/11/19  Di Hu      Initial Revision
;     12/14/19  Di Hu      Debugged SetServo function to accept negative values
;     12/16/19  Di Hu      Changed to fixed-point calculation in GetServoPosDegree
;     12/29/19  Di Hu      Moved manual trigger configuration in ANAIF from 
;                          GetServo to InitADC;
;                          Edited comments
;     01/10/20  Di Hu      Added error handling for SetServo 

;   .include files 
    .include "HW4_CC26x2_DEFS.inc"
    .include "HW4_SERVO_DEFS.inc"
    .include "HW4_MACROS.inc"
    .include "HW4_TIMER_DEFS.inc"
;   public functions 
    .global SetServo
    .global InitADC
    .global GetServo

    .text

; SetPulseValue (lp)
;
; Description:       This function is passed a low pulse(lp) value to set to 
;                    PWM timer's TAMATCHR and TAPMR. 
;
; Operation:         This function configures TAMATCHR and TAPMR to set low 
;                    pulse width for PWM cycle to control servo motor. 
;
; Arguments:         lp - R0 - by value - low pulse width for pwm cycle, value 
;                                         to be set to TAMATCH(low 16 bits) 
;                                         and TAPMR (high 16 bits)
;
; Return Value:      None.
;
; Local Variables:   R1 - used as base address of GPT2 
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
; Registers Changed: R0, R1, R2, R3
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Dec 09, 2019
SetPulseValue:

    MV32 R1, #GPT2_BASE_ADDR

    MOV R3, #LOWER_HALFWORD_MASK
    AND R2, R0, R3                      ;pulse match width is passed in R0
    STR R2, [R1, #TAMATCHR_ADDR_OFFSET] ;set Timer2A low pulse width' low 16 bits 

    LSR R0, R0, #LSR_SIXTEEN
    STR R0, [R1, #TAPMR_ADDR_OFFSET]    ;set Timer2A low pulse width' high 8 bits 

    BX LR


; SetServo(pos)
;
; Description:       This function is passed the position in degrees (pos) to
;                    which to set the servo. The position (pos) is passed in
;                    R0 by value. It is a signed integer between -90 and +90.  
;
; Operation:         This function sets servo shaft to passed-in position degree
;                    by calculating the low pulse width for PWM timer and
;                    calling SetPulseValue to set PWM timer. Low pulse width for
;                    PWM timer is the match value which is calculated by: 
;                    pwm match value = total pulse width - high pulse width
;                                    = total pulse clock - pos * CLK_PER_DEG 
;
; Arguments:         pos - R0 - by value - position degree to set servo shaft
;                                          at, range between -90 and +90. 
;
; Return Value:      None. 
;
; Local Variables:   None. 
; Shared Variables:  None.
;
; Input:             None. 
; Output:            Set servo shaft to the passed-in position. 
;
; Error Handling:    If argument pos is less than -90 or larger than 90,
;					 function exits without setting servo to a new position.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0, R1, R2, LR 
; Stack Depth:       1 word 
;
; Author:            Di Hu
; Last Modified:     Jan 10, 2019
SetServo: 
    PUSH {LR}

	MV32 R1, #NEG_NINETY
	CMP R0, R1							;check if R0 < -90
	BLT SetServoDone 					;if yes, exits function
	;BGE continue 						;if not, continue
	CMP R0, #90 						;check if R0 > 90
	BGT SetServoDone 					;if yes, exits function
	;BLE continue  						;if not, continue
    MV32 R1, #PWM2A_MATCHR_BASE_VALUE
    MOV R2, #CLK_PER_DEG                ;533 clocks; clocks to rotate one degree
    MLS R0, R0, R2, R1                  ;R0 = R1 - R0 * R2

    BL SetPulseValue                    ;set servo position by setting PWM timer 

SetServoDone:
    POP {LR}
    BX LR 


; InitADC
;
; Description:       This function initializes ADC module for reading servo 
;                    shaft position in degrees which is converted to digital 
;                    value from analog value. 
;
; Operation:         This function initializes ADC module by:
;                       1. Set AUX pin as input in AUXIODIO3_IOMODE
;                       2. Enable AUX input's input buffer in AUXIODIO3_GPIODIE
;                       3. Set AUX_SYSIF:ADCCLKCTL.REQ clock request to enable
;                          ADC clock 
;                       4. Wait for Clock is enabled -> wait till
;                          AUX_SYSIF:ADCCLKCTL.ACK bit is on 
;                       5. Clear ADI_4_AUX.ADC0.EN, ADI_4_AUX.ADC0.RESET_N
;                          for configuring asynchronous manual trigger 
;                       6. Config ADI_4_AUX_MUX3 to select AUXIO25: 0x2 
;                       7. Set ADI_4_AUX.ADCREF0.EN to enable ADC reference module 
;                       8. Set ADI_4_AUX.ADC0.EN, ADI_4_AUX.ADC0.RESET_N to 
;                          enable ADC
;                       9. Set manual trigger in AUX_ANAIF
;                       10.ADC initialization done, return 
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
; Registers Changed: R0, R1
; Stack Depth:       0
;
; Author:            Di Hu
; Last Modified:     Dec 28, 2019
InitADC:
    MV32 R1, #AUX_AIODIO3_BASE_ADDR

    MOV R0, #AUXIO25_IOMODE_SETNS 
    STR R0, [R1, #IOMODE_ADDR_OFFSET]   ;set selected AUX pin as input
    MOV R0, #AUXIO25_GPIODIE_SETNS      ;enable input buffer for selected AUX 
    STR R0, [R1, #GPIODIE_ADDR_OFFSET]  ;   input pin

EnableADCClk: 
    MV32 R1, #AUX_SYSIF_BASE_ADDR

    MOV R0, #ADC_CLOCK_REQ_MASK         
    STR R0, [R1, #ADCCLKCTL_ADDR_OFFSET];set clock enable request 

CheckADCClk:
    LDR R0, [R1, #ADCCLKCTL_ADDR_OFFSET]
    AND R0, R0, #ADC_CLOCK_ACK_MASK
    TST R0, R0                          ;check if clock is on
    BEQ CheckADCClk                     ;if not keep waiting
    ;BNE ConfigADC0                     ;if clock is set, keep configuring ADC 

ConfigADC0: 
    MV32 R1, #AUX_ADI4_BASE_ADDR

    LDRB R0, [R1, #ADC0_ADDR_OFFSET]    ;load AUX control byte register 
    AND R0, R0, #ADC0_EN_CLR_MASK 
    AND R0, R0, #ADC0_RESET_CLR_MASK    ;clear enable and reset bit 
    STRB R0, [R1, #ADC0_ADDR_OFFSET]    ;   and store back 
    ORR R0, R0, #ADC0_SETNS_MASK        
    STRB R0, [R1, #ADC0_ADDR_OFFSET]    ;set asynchronous bit for manual trigger 

ConfigMux3:
    LDRB R0, [R1, #MUX3_ADDR_OFFSET]    ;load AUX pin select byte register
    ORR R0, R0, #AUX_MUX3_SETNS         ;turn on selected pin
    STRB R0, [R1, #MUX3_ADDR_OFFSET]    ;store configuration 

ConfigADCREF0: 
    LDRB R0, [R1, #ADCREF0_ADDR_OFFSET] ;load AUX control reference byte register
    ORR R0, R0, #ADCREF0_EN_MASK        
    STRB R0, [R1, #ADCREF0_ADDR_OFFSET] ;enable ADC reference module  

ConfigADC0Done: 
    LDRB R0, [R1, #ADC0_ADDR_OFFSET]    ;load AUX control byte register again 
    ORR R0, R0, #ADC0_EN_SET_MASK       ;turn on enable 
    ORR R0, R0, #ADC0_RESET_SET_MASK    ;set normal operation 
    STRB R0, [R1, #ADC0_ADDR_OFFSET]

ConfigANAIF: 
    MV32 R1, #AUX_ANAIF_BASE_ADDR

    LDR R0, [R1, #ADCCTL_ADDR_OFFSET]
    ORR R0, R0, #ADCCTL_NOEVENT_MASK
    STR R0, [R1, #ADCCTL_ADDR_OFFSET]   ;set manual trigger 

    BX LR                               ;finished and return 


; GetServoPosDegree(sample)
;
; Description:       This function is passed in an ADC sample and converts 
;                    this sample (digital voltage value) to position degrees
;                    and return the result in R0. 
;
; Operation:         This function converts voltage value passed in R0 to 
;                    position degrees by multiplying the voltage value the
;                    reciprocal of divisor to divide voltage value into
;                    position degrees. The divisor is calculated by reading 
;                    voltage value when servo is at -90 and 90 degree positions,
;                    and dividing by 180. Multiplication result is a 32 bit
;                    value with redundent signed bits and decimal bits; thus,
;                    trunacation is performed to get fixed-point multiplication
;                    result. Lastly, the result is trunacated to integer value
;                    and returned in R0. 
;
; Arguments:         sample - R0 - by value - discrete voltage value converted
;                                             from analog value 
;
; Return Value:      R0 - servo shaft's current position in degrees 
;
; Local Variables:   None. 
; Shared Variables:  None.
;
; Input:             Servo motor. 
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        Q7.8 fixed point multiplication. 
; Data Structures:   None.
;
; Registers Changed: R0, R1
; Stack Depth:       0 
;
; Author:            Di Hu
; Last Modified:     Dec 16, 2019
GetServoPosDegree: 
    MOV R1, #SERVO_BASE_POS_VOL
    SUB R0, R1                      ;R0 = R0 - digital voltage value when  
                                    ;     servo is at 0 degree position 

    LSL R0, R0, #FIXED_POINT_F_LEN  ;convert value in R0 to a Q7.8 fp value 

    MV32 R1, #VOL_TO_DEGREE_DIVISOR
    MUL R0, R1                      ;divide signed divisor by multiplying with
                                    ;   the reciprocal value(also a Q7.8 fp)
    MOV R1, #FIXED_POINT_I_LEN      
    ADD R1, #1                      
    LSL R0, R0, R1                  ;left shift by i+1 bits to remove the
                                    ;   redundent parts before sign bit 
    LSR R0, R0, R1                  ;remove the zero bits shifted in by LSL      
    LSR R0, R0, #FIXED_POINT_F_LEN  ;right shift by f bits length to trunacate 
                                    ;   redundent parts by multiplication 
    LSR R0, R0, #FIXED_POINT_F_LEN  ;round the fixed-point values to integer
                                    ;   by trunacating decimal digits 

    SXTB R0, R0                     ;extends sign bit to make a 32-bit integer  

    ADD R0, #1                      ;to make up for the trunacated decimals 

    BX LR 


; GetServo
;
; Description:       This function triggers analog-to-digital conversion (ADC) 
;                    and reads ADC sample from ANAIF_FIFO register
;                    after ADC is done. 
;
; Operation:         This function reads ADC sample by:
;                    1. Flush FIFO in AUX_ANAIF.ADCCTL: Set CMD = 0x3 to flush 
;                    2. Wait for 2 NOPs and set CMD = 0x1 to enable ADC interface
;                    3. Trigger conversion in ADCTRIG 
;                    4. Wait for AUX_EVCTL_EVTOMCUFLAGS to be set (ADC is done)
;                    5. Clear AUX_EVCTL_EVTOMCUFLAGSCLR for next reading 
;                    6. Read latest sample from ADCFIFO into R0
;                    7. Convert digital value to position degrees by calling
;                       GetServoPosDegree 
;                    8. Done and return
;
; Arguments:         None. 
;
; Return Value:      R0 - servo shaft's current position in degrees 
;
; Local Variables:   None. 
; Shared Variables:  None.
;
; Input:             Servo motor. 
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0, R1, R2, LR 
; Stack Depth:       1 word 
;
; Author:            Di Hu
; Last Modified:     Dec 28, 2019
GetServo: 
    PUSH {LR}

    MV32 R1, #AUX_ANAIF_BASE_ADDR

    LDR R0, [R1, #ADCCTL_ADDR_OFFSET]
    MV32 R2, #ADCCTL_CMD_MASK
    AND R0, R0, R2                      ;prepare for flushing 
    ORR R0, R0, #ADCCTL_FLUSH_MASK 
    STR R0, [R1, #ADCCTL_ADDR_OFFSET]   ;flush FIFO register 

    NOP
    NOP          ;wait for two clocks before enable ADC interface 
    AND R0, R0, R2 
    ORR R0, R0, #ADCCTL_EN_MASK
    STR R0, [R1, #ADCCTL_ADDR_OFFSET]   ;enable ADC interface 

    MOV R0, #ADCTRIG_TRIG_MASK
    STR R0, [R1, #ADCTRIG_ADDR_OFFSET]  ;trigger single ADC conversion  

    ;loop till AUX_EVCTL_EVTOMCUFLAGS is set 
CheckADCDone:
    MV32 R1, #AUX_EVCTL_BASE_ADDR

    LDR R0, [R1, #EVTOMCUFLAGS_ADDR_OFFSET]
    MOV R2, #AUX_ADC_DONE_MASK
    ANDS R0, R0, R2                     ;mask out ADC_DONE flag bit 
    BEQ CheckADCDone                    ;check if ADC is done, 
                                        ;   if not, keep waiting 
    ;BNE ReadFIFO                       ;   if yes, read ADC sample 

ReadFIFO: 
    ; R1 contains #AUX_EVCTL_BASE_ADDR
    ; R2 contains #AUX_ADC_DONE_MASK
    STR R2, [R1, #EVTOMCUFLAGSCLR_ADDR_OFFSET] ;clear ADC_DONE flag bit
                                               ;    for next read 

    MV32 R1, #AUX_ANAIF_BASE_ADDR
    LDR R0, [R1, #ADCFIFO_ADDR_OFFSET]  ;read latest converted digital
                                        ;   value into R0

    ;call GetServoPosDegree to convert voltage value to degrees in R0 
    BL GetServoPosDegree

    POP {LR}
    BX LR 


