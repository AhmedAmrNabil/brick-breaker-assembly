EXTRN drawSeparator:FAR
EXTRN drawTile:FAR
EXTRN drawPaddle:FAR
EXTRN clearPaddle:FAR
EXTRN drawBall:FAR
EXTRN checkInput:FAR
EXTRN movePaddle:FAR

PUBLIC PADDLE_X
PUBLIC PADDLE1_X
PUBLIC BALL_X
PUBLIC BALL_Y
PUBLIC PADDLE1_VEL_X


getSystemTime MACRO
                  MOV AH,2CH    ;get the system time
                  INT 21H       ; CH = hour, CL = minute, DH = seconds, DL = 1/100s

ENDM


.MODEL small
.386

.STACK 100h
.DATA
	PADDLE_X dw ?
	PADDLE_Y dw ?
	PADDLE1_X dw 0
	PADDLE2_X dw 160

	BALL_X dw ?
	BALL_Y dw ?
	BALL1_X dw 74
	BALL1_Y dw 150
	BALL2_X dw 238
	BALL2_Y dw 150

	PADDLE1_VEL_X dw 0

	TIME DB 0

	BRICKS_COLS EQU 8
	BRICKS_COUNT EQU 48
	PADDLE_VEL_MAG EQU 5

.CODE
MAIN PROC FAR
	MOV AX, @DATA
	MOV DS, AX

	; set video mode to 320x200 256-color mode
	MOV AH, 0
	MOV AL, 13h
	INT 10h

	; draw the bricks (player 1)
	MOV CL, BRICKS_COLS
	MOV DX, 0
printLoop1:
	MOV AX, DX
	DIV CL
	XCHG AL, AH
	CALL drawTile
	INC DX
	CMP DX, BRICKS_COUNT
	JL printLoop1

	; draw the bricks (player 2)
	MOV CL, BRICKS_COLS
	MOV DX, 0
printLoop2:
	MOV AX, DX
	DIV CL
	XCHG AL, AH
	ADD AL, 8
	CALL drawTile
	INC DX
	CMP DX, BRICKS_COUNT
	JL printLoop2

	; draw the separator
	CALL drawSeparator

	; draw the paddle (player 1)
	MOV AX, PADDLE1_X
	MOV PADDLE_X, AX
	CALL drawPaddle

	; draw the paddle (player 2)
	MOV AX, PADDLE2_X
	MOV PADDLE_X, AX
	CALL drawPaddle

	; draw the ball (player 1)
	MOV AX, BALL1_X
	MOV BALL_X, AX
	MOV AX, BALL1_Y
	MOV BALL_Y, AX
	CALL drawBall

	; draw the ball (player 2)
	MOV AX, BALL2_X
	MOV BALL_X, AX
	MOV AX, BALL2_Y
	MOV BALL_Y, AX
	CALL drawBall


gameLoop:
	call checkInput
	GetSystemTime
	CMP DL, TIME
	JE gameLoop
	MOV TIME, DL


WaitForVSync:
    MOV DX, 03DAh         ; VGA Input Status Register 1
WaitForRetrace:
    IN AL, DX
    TEST AL, 08H          ; Check the Vertical Retrace bit (bit 3)
    JZ WaitForRetrace     ; Loop until retrace starts

	CALL movePaddle



	CALL drawSeparator
	jmp gameLoop

	; exit the program:
	MOV AH, 4CH
	INT 21h
MAIN ENDP
END MAIN