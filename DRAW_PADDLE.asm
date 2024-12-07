.MODEL SMALL
.STACK 100h
.DATA
   PADDLE_X DW 0A0h                
   PADDLE_Y DW 0BEh               
   PADDLE_WIDTH DW 40h            
   PADDLE_HEIGHT DW 8h            
   EDGE_WIDTH DW 05h               

.CODE

DRAW_PADDLE PROC FAR
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
DRAW_PADDLE ENDP

MAIN PROC FAR
    MOV AX, @DATA
    MOV DS, AX 

  
    MOV AH, 00h
    MOV AL, 13h
    INT 10h

  
    CALL DRAW_PADDLE 


    MOV AH, 4Ch
    INT 21h
ENDP
END MAIN
