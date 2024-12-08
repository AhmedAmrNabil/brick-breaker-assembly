EXTRN PADDLE_X:WORD
EXTRN PADDLE_Y:WORD
PUBLIC drawPaddle

.MODEL SMALL
.STACK 100h

.DATA
PADDLE_WIDTH equ 60
PADDLE_HEIGHT equ 10
EDGE_WIDTH equ 2

.CODE
drawPaddle PROC FAR
    MOV DX, PADDLE_Y             
    DRAW_ROW:
        PUSH DX                       
        MOV CX, PADDLE_X             

    DRAW_PIXEL:
        MOV AX, CX
        SUB AX, PADDLE_X
        CMP AX, EDGE_WIDTH
        JL DRAW_RED                   

        MOV AX, CX
        SUB AX, PADDLE_X
        MOV BX,PADDLE_WIDTH
        SUB BX,AX
        CMP BX,EDGE_WIDTH
        JLE DRAW_RED                 

    DRAW_GRAY:
        MOV AH, 0Ch
        MOV AL, 08h                   
        MOV BH, 00h
        INT 10h
        JMP NEXT_PIXEL

    DRAW_RED:
        MOV AH, 0Ch
        MOV AL, 04h                   
        MOV BH, 00h
        INT 10h

    NEXT_PIXEL:
        INC CX                     
        MOV AX, CX
        SUB AX, PADDLE_X
        CMP AX, PADDLE_WIDTH
        JL DRAW_PIXEL                
        POP DX                        
        INC DX                         
        MOV AX, DX
        SUB AX, PADDLE_Y
        CMP AX, PADDLE_HEIGHT
        JL DRAW_ROW                    

        RET
drawPaddle ENDP
END


