EXTRN PADDLE_X:WORD
PUBLIC drawPaddle
PUBLIC clearPaddle

.MODEL SMALL
.STACK 100h

.DATA
PADDLE_WIDTH equ 50
PADDLE_HEIGHT equ 10
EDGE_WIDTH equ 2
PADDLE_Y equ 180

.CODE
drawPaddle PROC FAR
    MOV DX, PADDLE_Y             
    drawRow:
        PUSH DX                       
        MOV CX, PADDLE_X             

    drawPixel:
        MOV AX, CX
        SUB AX, PADDLE_X
        CMP AX, EDGE_WIDTH
        JL drawRed                   

        MOV AX, CX
        SUB AX, PADDLE_X
        MOV BX,PADDLE_WIDTH
        SUB BX,AX
        CMP BX,EDGE_WIDTH
        JLE drawRed                 

    drawGrey:
        MOV AH, 0Ch
        MOV AL, 08h                   
        MOV BH, 00h
        INT 10h
        JMP nextPixel

    drawRed:
        MOV AH, 0Ch
        MOV AL, 04h                   
        MOV BH, 00h
        INT 10h

    nextPixel:
        INC CX                     
        MOV AX, CX
        SUB AX, PADDLE_X
        CMP AX, PADDLE_WIDTH
        JL drawPixel                
        POP DX                        
        INC DX                         
        MOV AX, DX
        SUB AX, PADDLE_Y
        CMP AX, PADDLE_HEIGHT
        JL drawRow                    

        RET
drawPaddle ENDP

clearPaddle PROC FAR
    MOV DX, PADDLE_Y             
    clearRow:
        PUSH DX                       
        MOV CX, PADDLE_X             

    drawBlack:
        MOV AH, 0Ch
        MOV AL, 00h                   
        MOV BH, 00h
        INT 10h

    clearNextPixel:
        INC CX                     
        MOV AX, CX
        SUB AX, PADDLE_X
        CMP AX, PADDLE_WIDTH
        JL drawBlack              
        POP DX                        
        INC DX                         
        MOV AX, DX
        SUB AX, PADDLE_Y
        CMP AX, PADDLE_HEIGHT
        JL clearRow                    
        RET
clearPaddle ENDP
END


