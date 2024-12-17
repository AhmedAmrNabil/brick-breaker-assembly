EXTRN drawSeparator:FAR
EXTRN drawTile:FAR
EXTRN drawPaddle:FAR
EXTRN drawBall:FAR
EXTRN clearBall:FAR
EXTRN checkInput:FAR
EXTRN moveBall:FAR
EXTRN checkCollision:FAR
EXTRN movePaddle1:FAR
EXTRN movePaddle2:FAR
EXTRN mainMenu:FAR
EXTRN choice:BYTE


PUBLIC PADDLE_X
PUBLIC PADDLE1_X
PUBLIC PADDLE1_VEL_X
PUBLIC PADDLE2_X
PUBLIC PADDLE2_VEL_X
PUBLIC BALL_X
PUBLIC BALL_Y
PUBLIC BALL1_Y
PUBLIC BALL_VELOCITY_X
PUBLIC BALL_VELOCITY_Y


getSystemTime MACRO
	MOV AH,2CH    ;get the system time
	INT 21H       ; CH = hour, CL = minute, DH = seconds, DL = 1/100s
ENDM

setIntteruptHandle MACRO
;getting int09h interrupt vector handler
	cli                       ;turn off interrupt flag
	pusha
;get the interrupt 09 address
	mov   ax,3509h
	int   21h

;save the original interrupt address
	mov   int9Off, bx
	mov   int9Seg, es
	popa

;setting the new int 09h interrupt vector handler
	push  ds
	mov   ax,cs
	mov   ds,ax               ;load the segment of the new interrupt
	lea   dx,checkInput    ;load the offset of the new interrupt
	mov   ax,2509h            ; int 21/25h at interrupt 09
	int   21h
	pop   ds
	sti
ENDM

resetInterruptHandle MACRO
	cli

	mov  ax,int9Seg
	mov  dx,int9Off
	push ds
	mov  ds,ax
	mov  ax,2509h
	int  21h
	pop  ds

	sti
ENDM

.MODEL small
.386

.STACK 100h
.DATA

	PADDLE_X dw ?
	PADDLE1_X dw 55
	PADDLE2_X dw 215

	PADDLE1_VEL_X dw 0
	PADDLE2_VEL_X dw 0

	BALL_X dw ?
	BALL_Y dw ?
	BALL1_X dw 75
	BALL1_Y dw 150
	BALL2_X dw 240
	BALL2_Y dw 150

	BALL_VELOCITY_X dw ?
	BALL_VELOCITY_Y dw ?
	BALL1_VELOCITY_X dw 5
	BALL1_VELOCITY_Y dw -5
	BALL2_VELOCITY_X dw 5
	BALL2_VELOCITY_Y dw -5

	TIME DB 1

	BRICKS_COLS EQU 8
	BRICKS_COUNT EQU 48
	PADDLE_VEL_MAG EQU 5

	int9Seg DW ?
	int9Off DW ?

.CODE
MAIN PROC FAR
	MOV AX, @DATA
	MOV DS, AX
 menuLoop:
    CALL mainMenu

    CMP choice, '1'          
    JE playGame
    CMP choice, '2'      
    JE chatOption
    CMP choice, '3'          
    JE exitGame

   JMP menuLoop

  playGame:
	setIntteruptHandle

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
	GetSystemTime
	CMP DL, TIME
	JE gameLoop
	MOV TIME, DL

	MOV AX, BALL1_X
	MOV BALL_X, AX
	MOV AX, BALL1_Y
	MOV BALL_Y, AX

	MOV AX, BALL1_VELOCITY_X
	MOV BALL_VELOCITY_X, AX
	MOV AX, BALL1_VELOCITY_Y
	MOV BALL_VELOCITY_Y, AX

	MOV AX, PADDLE1_X
	MOV PADDLE_X, AX

	CALL clearBall
	CALL checkCollision
	CALL moveBall
	CALL drawBall

	MOV AX, BALL_VELOCITY_X
	MOV BALL1_VELOCITY_X, AX
	MOV AX, BALL_VELOCITY_Y
	MOV BALL1_VELOCITY_Y, AX

	MOV AX, BALL_X
	MOV BALL1_X, AX
	MOV AX, BALL_Y
	MOV BALL1_Y, AX

WaitForVSync:
	MOV DX, 03DAh         ; VGA Input Status Register 1
WaitForRetrace:
	IN AL, DX
	TEST AL, 08H          ; Check the Vertical Retrace bit (bit 3)
	JZ WaitForRetrace     ; Loop until retrace starts

	CALL movePaddle1
	CALL movePaddle2
	CALL drawSeparator

	JMP gameLoop

	; exit the program:
	resetInterruptHandle
chatOption:  ;will be added 
exitGame:
	MOV AH, 4CH
	INT 21h
MAIN ENDP
END MAIN