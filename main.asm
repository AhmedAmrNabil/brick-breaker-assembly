EXTRN drawTile:FAR
EXTRN drawPaddle:FAR
EXTRN drawBall:FAR
EXTRN drawColoredTile:FAR
EXTRN clearBall:FAR
EXTRN clearPaddle:FAR
EXTRN checkInput:FAR
EXTRN moveBall:FAR
EXTRN checkCollision:FAR
EXTRN movePaddle1:FAR
EXTRN mainMenu:FAR
EXTRN choice:BYTE
EXTRN checkCollision2:FAR
EXTRN Chat:FAR

PUBLIC PADDLE_X
PUBLIC PADDLE1_X
PUBLIC PADDLE1_VEL_X
PUBLIC PADDLE2_X
PUBLIC BALL_X
PUBLIC BALL_Y
PUBLIC BALL1_Y
PUBLIC BALL1_X
PUBLIC BALL2_X
PUBLIC BALL2_Y
PUBLIC BALL_VELOCITY_X
PUBLIC BALL_VELOCITY_Y
PUBLIC CLEAR_TILE_OFFSET
PUBLIC GAME_EXIT_FLAG

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


initGame MACRO
	; set video mode to 320x200 256-color mode

	MOV AH, 00h
	INT 1Ah
	MOV AX,CX
	SHL EAX, 16
	MOV AX,DX
	MOV SEED, EAX
	MUL EAX

	SHR EAX, 15
	AND EAX,00000003h
	ADD EAX,2
	MOV POWERUP_COUNT,AL


	MOV AH, 0
	MOV AL, 13h
	INT 10h
	MOV GAME_EXIT_FLAG,0
	MOV PADDLE1_X , 50
	MOV PADDLE2_X , 210
	MOV PADDLE2_X2 , 210
	MOV BALL1_X , 80
	MOV BALL1_Y , 150
	MOV BALL2_X , 240
	MOV BALL2_Y , 150
	MOV BaLL2_Xrec , 240
	MOV BaLL2_Yrec , 150
	MOV BALL1_VELOCITY_X , 1
	MOV BALL1_VELOCITY_Y , -2

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
	

	MOV CL, POWERUP_COUNT
powerupLoop1:
	PUSH CX
	CALL LCG
	MOV EAX,SEED
	MOV ECX,48
	XOR EDX,EDX
	DIV ECX
	MOV AX,DX
	MOV CL,8
	DIV CL
	XCHG AL, AH
	CALL drawColoredTile
	POP CX
	LOOP powerupLoop1	

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

	; draw the separator
	drawSeparator
ENDM


.MODEL small
.386

.STACK 100h
.DATA

	PADDLE1_VEL_X dw 0
	
	PADDLE_X dw ?
	PADDLE1_X dw 50
	PADDLE2_X dw 210
	PADDLE2_X2 dw 210

	BALL_X dw ?
	BALL_Y dw ?
	BALL1_X dw 80
	BALL1_Y dw 150
	BALL2_X dw 240
	BALL2_Y dw 150
	BaLL2_Xrec dw 240
	BaLL2_Yrec dw 150
	BALL_VELOCITY_X dw ?
	BALL_VELOCITY_Y dw ?
	BALL1_VELOCITY_X dw 2
	BALL1_VELOCITY_Y dw -1
	GAME_EXIT_FLAG db 0
	POWERUP_COUNT db 0

	CLEAR_TILE_OFFSET db 8

	TIME DB 1

	BRICKS_COLS EQU 8
	BRICKS_COUNT EQU 48
	PADDLE_VEL_MAG EQU 5

	int9Seg DW ?
	int9Off DW ?
	SEED DD 5970917
	MULTIPLIER EQU 22695477	
	INCREMENT EQU 1
	MODULUS EQU 2147483647

	COM EQU 03F8h
.CODE

LCG PROC FAR
	PUSHA
	MOV EAX, SEED
	MOV EBX, MULTIPLIER
	MUL EBX
	ADD EAX, INCREMENT
	MOV SEED, EAX
	MOV EDX, 0
	MOV EBX,MODULUS
	DIV EBX
	MOV SEED, EDX
	MOV EAX, EDX
	POPA
	RET
LCG ENDP

SendAll PROC FAR

SendBall_X:
	mov               dx,COM+5        ; Line Status Register
	in                al,dx           ;Read Line Status
	test              al,00100000b
	jz                exitSendAll       

	mov               dx, COM         ; Transmit data register
	mov               al, byte ptr BALL1_X       ; put the data into al
	out               dx, al          ; sending the data

SendBall_Y:
	mov               dx,COM+5        ; Line Status Register
	in                al,dx           ;Read Line Status
	test              al,00100000b
	jz                SendBall_Y       ;Recieve if not empty

	mov               dx,COM          ; Transmit data register
	mov               al, byte ptr BALL1_Y       ; put the data into al
	CMP GAME_EXIT_FLAG,1
	JNE continueSendBallY
	mov al, 0FFh
continueSendBallY:
	out               dx,al           ; sending the data

SendPaddle:
	mov               dx,COM+5        ; Line Status Register
	in                al,dx           ;Read Line Status
	test              al,00100000b
	jz                SendPaddle       ;Recieve if not empty

	mov               dx,COM          ; Transmit data register
	mov               al, byte ptr PADDLE1_X       ; put the data into al
	out               dx,al           ; sending the data

exitSendAll:
    RET
SendAll ENDP

ReceiveAll PROC FAR

WaitPaddleX:
	mov dx,COM+5        ;check if data is ready
	in al,dx
	test al,1
	jz exitReceiveAll        ;if not check for sending

	mov dx, COM
	in al, dx           ;read data from reg
	MOV AH, 0
	ADD AX, 160 
	MOV PADDLE2_X2, AX

WaitBallX:
	mov dx, COM+5        ;check if data is ready
	in al, dx
	test al, 1
	jz  WaitBallX       ;if not check for sending

	mov dx, COM
	in al, dx           ;read data from reg
	
	MOV AH, 0
	ADD AX, 160          
	MOV BaLL2_Xrec, AX

WaitBallY:
	mov dx, COM+5        ;check if data is ready
	in al, dx
	test al, 1
	jz WaitBallY        ;if not check for sending
	
	mov dx, COM
	in al, dx           ;read data from reg
	CMP al,0FFh
	JNE continueBallY
	MOV GAME_EXIT_FLAG, 1

continueBallY:	
	MOV AH, 0
	MOV BaLL2_Yrec, AX

exitReceiveAll:
	RET
ReceiveAll ENDP

drawSeparator MACRO
	LOCAL print
	PUSHA
	PUSHF

	MOV   CX, 160
	MOV   DX,0

	MOV   AH,0ch
	MOV   AL,0fh
print:
	INT   10h
	DEC   CX
	INT   10h
	INC   CX
	INC   DX
	CMP   DX,200
	JL    print

	POPF
	POPA
ENDM


MAIN PROC FAR
	MOV AX, @DATA
	MOV DS, AX

	; Set divisor Latch Acess bit
	mov dx,COM+3
	mov ax,10000000b
	out dx,al

;Set LSB of the Baud Rate Divisor Latch register
	mov dx,COM
	mov al,1
	out dx,al

;Set MSB of the Baud Rate Divisor Latch register
	mov dx,COM+1
	mov al,00h
	out dx,al

; Set Port config
; transrecieve buffer,set break disabled, even parity, one stop bit, 8 bit word
	mov dx,COM+3
	mov ax,00011011b
	out dx,al

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
	initGame
	setIntteruptHandle

gameLoop:
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

	mov cx,3
collisionLoop:
	push cx
	cmp GAME_EXIT_FLAG, 1
	JE gotoMainMenu
	CALL SendAll
	CALL ReceiveAll

	MOV AX, BALL1_X
	MOV BALL_X, AX

	MOV AX, BALL1_Y
	MOV BALL_Y, AX

	MOV AX, BALL1_VELOCITY_X
	MOV BALL_VELOCITY_X, AX

	MOV AX, BALL1_VELOCITY_Y
	MOV BALL_VELOCITY_Y, AX

	CALL clearBall


	MOV AL, 0
	MOV CLEAR_TILE_OFFSET, AL
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


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	MOV AX, BALL2_X
	MOV BALL_X, AX

	MOV AX, BALL2_Y
	MOV BALL_Y, AX
	CALL clearBall
	CALL checkCollision2

	MOV AX, BaLL2_Xrec
	MOV BALL2_X, AX
	MOV BALL_X, AX

	MOV AX, BaLL2_Yrec
	MOV BALL2_Y, AX
	MOV BALL_Y, AX

	CALL drawBall
		pop cx
	dec cx
	cmp cx,0
	je skipLoop
	jmp collisionLoop
	skipLoop:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



	CALL movePaddle1

	MOV AX, PADDLE2_X
	CMP AX, PADDLE2_X2
	drawSeparator
	JE gameLoop

	

	MOV PADDLE_X, AX
	CALL clearPaddle
	
	MOV AX, PADDLE2_X2
	MOV PADDLE2_X, AX
	MOV PADDLE_X, AX
	CALL drawPaddle

	drawSeparator
	
	JMP gameLoop
gotoMainMenu:
	resetInterruptHandle
	call SendAll
	jmp menuLoop

chatOption:  
	CALL Chat
	JMP menuLoop 

exitGame:
	MOV AH, 4CH
	INT 21h
MAIN ENDP
END MAIN




