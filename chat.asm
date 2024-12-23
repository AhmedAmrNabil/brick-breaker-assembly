PUBLIC Chat

.MODEL SMALL
.386
.STACK 100h
.DATA
    closeProgram DB 0
    myCursorX DB 0
    myCursorY DB 0
    otherCursorX DB 0
    otherCursorY DB 13

.CODE
CLEAR_SCREEN PROC
    MOV AH, 00H
    MOV AL, 03H
    INT 10H

    RET
CLEAR_SCREEN ENDP

DRAW_SEPARATOR PROC
    ; Set the cursor position to row 12
    MOV AH, 02H
    MOV BH, 0
    MOV DH, 12
    MOV DL, 0
    INT 10H
    
    ; Draw the horizontal line using the character '-'
    MOV AH, 09H
    MOV AL, '-'
    MOV BL, 7
    MOV CX, 80
    INT 10H

    RET
DRAW_SEPARATOR ENDP

MOVE_MY_CURSOR PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AH, 02H
    MOV BH, 0
    MOV DH, myCursorY
    MOV DL, myCursorX
    INT 10H

    POP DX
    POP BX
    POP AX
    RET
MOVE_MY_CURSOR ENDP

MOVE_OTHER_CURSOR PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AH, 02H
    MOV BH, 0
    MOV DH, otherCursorY
    MOV DL, otherCursorX
    INT 10H

    POP DX
    POP BX
    POP AX
    RET
MOVE_OTHER_CURSOR ENDP

SCROLL_WINDOW PROC
    PUSH AX
    PUSH BX

    MOV AH, 06H
    MOV AL, 01H
    MOV BH, 07H
    INT 10H

    POP BX
    POP AX
    RET
SCROLL_WINDOW ENDP

RECEIVE_KEY PROC
    ; Check if data Ready from UART
    MOV DX, 03FDH
    IN AL, DX
    AND AL, 1
    JZ END_RECEIVE_KEY

    ; Read the value
    MOV DX, 03F8H
    IN AL, DX

    ; Check if esc is pressed
    CMP AL, 27
    JZ R_CLOSE_PROGRAM

    ; Set if we need to scroll the window after displaying the value
    MOV BL, 0

    ; Move the cursor to the other side
    CALL MOVE_OTHER_CURSOR

    ; Check if char is a new line
    CMP AL, 0Dh
    JNZ R_DISPLAY_VALUE
    MOV otherCursorX, 0
    INC otherCursorY
    JMP R_CHECK_CURSOR_POS

R_DISPLAY_VALUE:
    ; Display the value
    MOV DL, AL
    MOV BH, 0
    MOV CX, 1
    MOV AH, 0Ah
    INT 10h

R_INCREMENT_CURSOR:
    ; Increment the cursor position and check if it is the end of row
    INC otherCursorX
    CMP otherCursorX, 80
    JNE R_CHECK_CURSOR_POS
    MOV otherCursorX, 0
    INC otherCursorY

R_CHECK_CURSOR_POS:
    ; Check if the cursor is at the end of the screen and set a flag
    CMP otherCursorX, 0
    JNE END_RECEIVE_KEY
    CMP otherCursorY, 25
    JNE END_RECEIVE_KEY

    ; Scroll the window
R_SCROLL_WINDOW:
    MOV CH, 13
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    CALL SCROLL_WINDOW
    MOV otherCursorX, 0
    MOV otherCursorY, 24

    JMP END_RECEIVE_KEY

R_CLOSE_PROGRAM:
    MOV closeProgram, 1

END_RECEIVE_KEY:
    RET
RECEIVE_KEY ENDP

TRANS_KEY PROC
    ; Check if key is pressed
    MOV AH, 0Bh
    INT 21h
    CMP AL, 0h
    JZ EXIT_TRANS_KEY

    ; Check that Transmitter Holding Register is Empty
WAIT_FOR_EMPTY:
    MOV DX, 3FDH
    IN AL, DX
    AND AL, 00100000b
    JZ WAIT_FOR_EMPTY

    ; Read the value
    MOV AH, 00H
    INT 16h

    ; Transmit the value
    MOV DX, 3F8H
    OUT DX , AL

    ; Check if esc is pressed
    CMP AL, 27
    JZ T_CLOSE_PROGRAM

T_DISPLAY_VALUE:
    ; Move the cursor to the other side
    CALL MOVE_MY_CURSOR

    ; Display the value
    MOV DL, AL
    MOV AH, 02h
    INT 21h

    ; Check if char is a new line
    CMP AL, 0Dh
    JNZ T_GET_CURSOR_POS

    ; Print the new line
    MOV DL, 0Ah
    MOV AH, 02
    INT 21h

T_GET_CURSOR_POS:
    ; Get new cursor position
    MOV AH, 03h
    INT 10h
    MOV myCursorX, DL
    MOV myCursorY, DH

T_CHECK_CURSOR_POS:
    ; Check if the cursor is at the end of the screen
    CMP myCursorX, 0
    JNE EXIT_TRANS_KEY
    CMP myCursorY, 12
    JNE EXIT_TRANS_KEY

    ; Scroll the window
T_SCROLL_WINDOW:
    MOV CH, 0
    MOV CL, 0
    MOV DH, 11
    MOV DL, 79
    CALL SCROLL_WINDOW
    MOV myCursorX, 0
    DEC myCursorY

    ; Set the cursor position
    CALL MOVE_MY_CURSOR

    JMP EXIT_TRANS_KEY

T_CLOSE_PROGRAM:
    MOV closeProgram, 1

EXIT_TRANS_KEY:
    RET
TRANS_KEY ENDP

Chat PROC FAR
	MOV closeProgram, 0
	MOV myCursorX, 0
    MOV myCursorY, 0
    MOV otherCursorX, 0
    MOV otherCursorY, 13

    ; Clear the screen
    CALL CLEAR_SCREEN

    ; Divide the screen into two parts
    CALL DRAW_SEPARATOR

MAIN_LOOP:
    CALL MOVE_MY_CURSOR

    ; Check if there is a character in the UART
    CALL RECEIVE_KEY

    ; Check if esc is pressed
    CMP closeProgram, 1
    JZ EXIT_PROGRAM

    ; Check if key is pressed and send it to the UART
    CALL TRANS_KEY

    ; Check if esc is pressed
    CMP closeProgram, 1
    JZ EXIT_PROGRAM

    JMP MAIN_LOOP

EXIT_PROGRAM:
    ret

Chat ENDP
END
