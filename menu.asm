PUBLIC choice
PUBLIC mainMenu
.MODEL small
.386

.DATA
    menuMsg DB 10, 13, '=== MAIN MENU ===', 10, 13, '$'
    playMsg DB '1. Play Game', 10, 13, '$'
    chatMsg DB '2. Chat', 10, 13, '$'
    exitMsg DB '3. Exit', 10, 13, '$'
    selectMsg DB 'Select an option (1-3): $'

    choice DB ?           

.CODE


mainMenu PROC FAR

    CALL clearScreen 
    ;CALL setCursorMiddle       
    CALL displayMenu   

 
    MOV AH, 01H         
    INT 21H
    MOV choice, AL      
    RET

mainMenu ENDP


displayMenu PROC

    mov ah,02h
    mov dh,0
    mov dl,0
    mov bh,0
    int 10h

    LEA DX, menuMsg
    MOV AH, 09H
    INT 21H

    LEA DX, playMsg
    MOV AH, 09H
    INT 21H

    LEA DX, chatMsg
    MOV AH, 09H
    INT 21H

    LEA DX, exitMsg
    MOV AH, 09H
    INT 21H

    LEA DX, selectMsg
    MOV AH, 09H
    INT 21H
    RET
displayMenu ENDP

clearScreen PROC
    MOV AH, 06H            
    MOV AL, 0       
    MOV BH, 07H    
    MOV CX, 0         
    MOV DX, 184FH  
    INT 10H

     

    RET
clearScreen ENDP




END
