EXTRN Ball_X:WORD
EXTRN Ball_Y:WORD
EXTRN Ball_Pixels:WORD


PUBLIC Draw_Ball
.MODEL SMALL
.STACK 100h

.CODE
Draw_Ball PROC FAR

    ;   MOV AX, @DATA
    ; MOV DS, AX
    MOV AX,00h

    MOV AH,00h  ;Move to graphic mode
    MOV AL,13h
    INT 10h



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
    CMP AX,Ball_Pixels
    JNG DRAW_HORIZONTAL_VERTICAL   ;Loop for X-axis



    MOV CX,Ball_X
    INC DX
    MOV AX,DX
    SUB AX,Ball_Y
    CMP AX,Ball_Pixels
    JNG DRAW_HORIZONTAL_VERTICAL   ;Loop for Y-axis


 Draw_Ball ENDP
 END
