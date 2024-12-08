EXTRN drawSeparator:FAR
EXTRN drawTile:FAR
EXTRN drawPaddle:FAR
EXTRN drawBall:FAR

PUBLIC PADDLE_X
PUBLIC PADDLE_Y
PUBLIC BALL_X
PUBLIC BALL_Y

.MODEL small
.386

.STACK 100h
.DATA
	PADDLE_X dw ?
	PADDLE_Y dw ?
	PADDLE1_X dw 49
	PADDLE1_Y dw 180
	PADDLE2_X dw 213
	PADDLE2_Y dw 180

	BALL_X dw ?
	BALL_Y dw ?
	BALL1_X dw 74
	BALL1_Y dw 150
	BALL2_X dw 238
	BALL2_Y dw 150

	BRICKS_COLS EQU 8
	BRICKS_COUNT EQU 48

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
	MOV AX, PADDLE1_Y
	MOV PADDLE_Y, AX
	CALL drawPaddle

	; draw the paddle (player 2)
	MOV AX, PADDLE2_X
	MOV PADDLE_X, AX
	MOV AX, PADDLE2_Y
	MOV PADDLE_Y, AX
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

	HLT
MAIN ENDP
END MAIN