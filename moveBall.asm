EXTRN BALL_X:WORD
EXTRN BALL_Y:WORD
EXTRN BALL_VELOCITY_X:WORD
EXTRN BALL_VELOCITY_Y:WORD
PUBLIC moveBall

.MODEL SMALL
.STACK 100h

.DATA
BALL_PIXELS equ 06h
WINDOW_WIDTH       equ 140h
WINDOW_HEIGHT      equ 0c8h

.CODE
moveBall PROC FAR
MOV AX,BALL_VELOCITY_X
ADD BALL_X,AX           ;move x-axis


    CMP BALL_X,00h
    JL NEG_VELOCITY_X
    MOV AX,WINDOW_WIDTH
    SUB AX,BALL_PIXELS
    SUB AX,01H
    CMP BALL_X,AX
    JG NEG_VELOCITY_X         ;check left right borders


   MOV AX,BALL_VELOCITY_Y
    ADD BALL_Y,AX             ;move y-axis


    CMP BALL_Y,00h
    JL NEG_VELOCITY_Y
    MOV AX,WINDOW_HEIGHT
    SUB AX,BALL_PIXELS
    CMP BALL_Y,AX
    JG NEG_VELOCITY_Y         ;check top bottom borders

    RET
    NEG_VELOCITY_X:
    NEG BALL_VELOCITY_X       ;handle left right borders
    RET
    NEG_VELOCITY_Y:
    NEG BALL_VELOCITY_Y       ;handle top bottom borders
    RET
moveBall ENDP
END