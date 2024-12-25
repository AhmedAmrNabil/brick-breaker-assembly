PUBLIC choice
PUBLIC mainMenu
.MODEL medium
.386

.DATA

    filename db 'menu.bin', 0
    buffer_size equ 64001d
    buffer db buffer_size dup(?)

    IMAGE_HEIGHT equ 200
    IMAGE_WIDTH equ 320
    SCREEN_WIDTH equ 320
    SCREEN_HEIGHT equ 200       

    choice dw 0
    startArrow dw 55
    endArrow dw 55+15

    startPositions dw 55,153,251
    arrowHeight equ 140

.CODE


drawArrow PROC FAR

    MOV AX,choice
    MOV SI,AX
    SHL SI,1
    MOV BX,startPositions[SI]
    MOV startArrow,BX
    ADD BX,15
    MOV endArrow,BX

    MOV CX, startArrow
    MOV DX, arrowHeight
    MOV AH, 0CH
    MOV AL, 15d

drawArrowRowLoop:
    INT 10h
    INC CX
    CMP CX,endArrow
    JL drawArrowRowLoop
    INC DX
    INC startArrow
    DEC endArrow
    MOV CX,startArrow
    MOV BX,endArrow
    CMP BX,startArrow
    JGE drawArrowRowLoop

    RET
drawArrow ENDP

clearArrow PROC FAR

    MOV AX,choice
    MOV SI,AX
    SHL SI,1
    MOV BX,startPositions[SI]
    MOV startArrow,BX
    ADD BX,15
    MOV endArrow,BX

    MOV CX, startArrow
    MOV DX, arrowHeight
    MOV AH, 0CH
    MOV AL, 00d

clearArrowRowLoop:
    INT 10h
    INC CX
    CMP CX,endArrow
    JL clearArrowRowLoop
    INC DX
    INC startArrow
    DEC endArrow
    MOV CX,startArrow
    MOV BX,endArrow
    CMP BX,startArrow
    JGE clearArrowRowLoop

    RET
clearArrow ENDP

drawImage PROC

    MOV AX, 0A000h
    MOV ES, AX

    MOV DI, 0
    MOV SI, offset buffer
    MOV CX, 320 * 200 ; Total pixels in the screen (320x200)

    REP MOVSB

    RET
drawImage ENDP

displayMenu PROC


    mov ah, 03Dh
    mov al, 0 ; open attribute: 0 - read-only, 1 - write-only, 2 -read&write
    mov dx, offset filename ; ASCIIZ filename to open
    int 21h

    mov bx, AX
    mov ah, 03Fh
    mov cx, buffer_size ; number of bytes to read
    mov dx, offset buffer ; were to put read data
    int 21h

    mov ah, 3Eh         ; DOS function: close file
    INT 21H

    call drawImage
    RET

displayMenu ENDP


mainMenu PROC FAR

    mov ah,0
    mov al,13h
    int 10h

    CALL displayMenu

    MOV choice, 0
    
choiceLoop:
    call drawArrow
    MOV AH, 00H         
    INT 16H
    PUSHA
    call clearArrow
    POPA
    CMP AH,4BH
    JNE skipDecrement
    CMP choice,0
    JE skipDecrement
    DEC choice
skipDecrement:
    CMP AH,4DH
    JNE skipIncrement
    CMP choice,2
    JE skipIncrement
    INC choice
skipIncrement:
    CMP AH,1CH
    JE exitMainMenu
    jmp choiceLoop


exitMainMenu:

    RET

mainMenu ENDP

END
