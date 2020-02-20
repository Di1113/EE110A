;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                             HW5_STEPPER_DEFS.inc                           ;
;                                Servo Control                               ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains constants used in stepper control routines. 
; 
; CONSTANT INDEX: 
;     MICRO_STEP_DEGREE - every micro step's size in position degrees 
;     SERVO_EN_CTL_MASK - AND mask to clear stepper's control pins  
;
; REVISION HISTORY:
;     12/18/19  Di Hu      Initial Revision
;     12/31/19  Di Hu      Edited comments 


    .data


MICRO_STEP_DEGREE   .EQU    6               ;one micro step changes 6 degrees
                                            ;   in position 
SERVO_EN_CTL_MASK   .EQU    0xFFFFFFFC      ;AND mask to clear stepper's  
                                    ;|          control A and control B IO pins 
                                    ;1100
