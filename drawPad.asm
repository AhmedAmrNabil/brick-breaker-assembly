EXTRN PADDLE_X:WORD
EXTRN PADDLE_WIDTH:WORD
EXTRN PADDLE2_WIDTH:WORD

PUBLIC drawPaddle
PUBLIC drawPaddle2
PUBLIC clearPaddle
PUBLIC clearPaddle2

.MODEL SMALL
.STACK 100h

.DATA
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

drawPaddle2 PROC FAR
    MOV DX, PADDLE_Y             
    drawRow2:
        PUSH DX                       
        MOV CX, PADDLE_X             

    drawPixel2:
        MOV AX, CX
        SUB AX, PADDLE_X
        CMP AX, EDGE_WIDTH
        JL drawRed2                   

        MOV AX, CX
        SUB AX, PADDLE_X
        MOV BX,PADDLE2_WIDTH
        SUB BX,AX
        CMP BX,EDGE_WIDTH
        JLE drawRed2                 

    drawGrey2:
        MOV AH, 0Ch
        MOV AL, 08h                   
        MOV BH, 00h
        INT 10h
        JMP nextPixel2

    drawRed2:
        MOV AH, 0Ch
        MOV AL, 04h                   
        MOV BH, 00h
        INT 10h

    nextPixel2:
        INC CX                     
        MOV AX, CX
        SUB AX, PADDLE_X
        CMP AX, PADDLE2_WIDTH
        JL drawPixel2                
        POP DX                        
        INC DX                         
        MOV AX, DX
        SUB AX, PADDLE_Y
        CMP AX, PADDLE_HEIGHT
        JL drawRow2

        RET
drawPaddle2 ENDP

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

clearPaddle2 PROC FAR
    MOV DX, PADDLE_Y             
    clearRow2:
        PUSH DX                       
        MOV CX, PADDLE_X             

    drawBlack2:
        MOV AH, 0Ch
        MOV AL, 00h                   
        MOV BH, 00h
        INT 10h

    clearNextPixel2:
        INC CX                     
        MOV AX, CX
        SUB AX, PADDLE_X
        CMP AX, PADDLE2_WIDTH
        JL drawBlack2
        POP DX                        
        INC DX                         
        MOV AX, DX
        SUB AX, PADDLE_Y
        CMP AX, PADDLE_HEIGHT
        JL clearRow2
        RET
clearPaddle2 ENDP

END


