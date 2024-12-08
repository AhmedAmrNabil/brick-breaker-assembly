EXTRN BALL_X:WORD
EXTRN BALL_Y:WORD
PUBLIC drawBall

.MODEL SMALL
.STACK 100h

.DATA
BALL_PIXELS equ 06h

.CODE
drawBall PROC FAR
    MOV AX,00h

    MOV CX,Ball_X   ;Mov the x,y for ball
    MOV DX,Ball_Y
    MOV AX,00h

    DRAW_HORIZONTAL_VERTICAL:
    MOV AH,0ch
    MOV AL,0Ah
    MOV BH,00h
    INT 10h    ; Draw the pixel
    INC CX
    MOV AX,CX
    SUB AX,Ball_X
    CMP AX,BALL_PIXELS
    JNG DRAW_HORIZONTAL_VERTICAL   ;Loop for X-axis

    MOV CX,Ball_X
    INC DX
    MOV AX,DX
    SUB AX,Ball_Y
    CMP AX,BALL_PIXELS
    JNG DRAW_HORIZONTAL_VERTICAL   ;Loop for Y-axis
drawBall ENDP

clearBall PROC FAR
    MOV AX,00h

    MOV CX,Ball_X   ;Mov the x,y for ball
    MOV DX,Ball_Y
    MOV AX,00h

    CLEAR_BALL_HORIZONTAL_VERTICAL:
    MOV AH,0ch
    MOV AL,00h
    MOV BH,00h
    INT 10h    ; Clear the pixel
    INC CX
    MOV AX,CX
    SUB AX,Ball_X
    CMP AX,BALL_PIXELS
    JNG CLEAR_BALL_HORIZONTAL_VERTICAL   ;Loop for X-axis

    MOV CX,Ball_X
    INC DX
    MOV AX,DX
    SUB AX,Ball_Y
    CMP AX,BALL_PIXELS
    JNG CLEAR_BALL_HORIZONTAL_VERTICAL   ;Loop for Y-axis
clearBall ENDP
END
