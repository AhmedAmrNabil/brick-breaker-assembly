EXTRN BALL_X:WORD
EXTRN BALL_Y:WORD

PUBLIC drawBall
PUBLIC clearBall

.MODEL SMALL
.STACK 100h

.DATA
BALL_SIZE EQU 5

.CODE
drawBall PROC FAR
    MOV AX,00h

    MOV CX,BALL_X   ;Mov the x,y for ball
    MOV DX,BALL_Y
    MOV AX,00h

    DRAW_HORIZONTAL_VERTICAL:
    MOV AH,0ch
    MOV AL,0Ah
    MOV BH,00h
    INT 10h    ; Draw the pixel
    INC CX
    MOV AX,CX
    SUB AX,BALL_X
    CMP AX,BALL_SIZE
    JL DRAW_HORIZONTAL_VERTICAL   ;Loop for X-axis

    MOV CX,BALL_X
    INC DX
    MOV AX,DX
    SUB AX,BALL_Y
    CMP AX,BALL_SIZE
    JL DRAW_HORIZONTAL_VERTICAL   ;Loop for Y-axis
    RET
drawBall ENDP


clearBall PROC FAR
    MOV AX,00h

    MOV CX,BALL_X   ;Mov the x,y for ball
    MOV DX,BALL_Y
    MOV AX,00h

    clearHorizontalVertical:
    MOV AH,0ch
    MOV AL,00h
    MOV BH,00h
    INT 10h    ; Draw the pixel
    INC CX
    MOV AX,CX
    SUB AX,BALL_X
    CMP AX,BALL_SIZE
    JL clearHorizontalVertical  ;Loop for X-axis

    MOV CX,BALL_X
    INC DX
    MOV AX,DX
    SUB AX,BALL_Y
    CMP AX,BALL_SIZE
    JL clearHorizontalVertical  ;Loop for Y-axis
    RET
clearBall ENDP
END
