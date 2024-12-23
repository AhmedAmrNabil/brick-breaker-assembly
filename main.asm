EXTRN drawSeparator:FAR
EXTRN drawTile:FAR
EXTRN drawPaddle:FAR
EXTRN drawBall:FAR
EXTRN clearBall:FAR
EXTRN clearPaddle:FAR
EXTRN checkInput:FAR
EXTRN moveBall:FAR
EXTRN checkCollision:FAR
EXTRN movePaddle1:FAR
EXTRN mainMenu:FAR
EXTRN choice:BYTE


PUBLIC PADDLE_X
PUBLIC PADDLE1_X
PUBLIC PADDLE1_VEL_X
PUBLIC PADDLE2_X
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
	PADDLE1_X dw 50
	PADDLE2_X dw 210
	PADDLE2_X2 dw 210

	PADDLE1_VEL_X dw 0

	BALL_X dw ?
	BALL_Y dw ?
	BALL1_X dw 75
	BALL1_Y dw 150
	BALL2_X dw 240
	BALL2_Y dw 150
	BaLL2_Xrec dw 240
	BaLL2_Yrec dw 150
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

	COM EQU 03F8h
.CODE

SendPaddle PROC FAR
    ; Check if the Transmitter Holding Register is Empty
	
	mov               dx,COM+5        ; Line Status Register
	in                al,dx           ;Read Line Status
	test              al,00100000b
	jz                exitSendPaddle       ;Recieve if not empty

	mov               dx,COM          ; Transmit data register
	mov               al, byte ptr PADDLE1_X       ; put the data into al
	mov 			  ah,1
	out               dx,ax           ; sending the data

exitSendPaddle:
    RET
SendPaddle ENDP


ReceivePaddle PROC FAR
    mov dx,COM+5        ;check if data is ready
	in al,dx
	test al,1
	jz exitRecievePaddle        ;if not check for sending


	mov dx,COM
	in ax,dx           ;read data from reg
	cmp ah,1
	jnz exitRecievePaddle
	MOV AH, 0
    ADD AX, 160 
	MOV PADDLE2_X2, AX
exitRecievePaddle:
    RET
ReceivePaddle ENDP


SendBall_X PROC FAR
  ;check_X:
	mov               dx,COM+5        ; Line Status Register
	in                al,dx           ;Read Line Status
	test              al,00100000b
	jz                exit_x       ;Recieve if not empty

	mov               dx,COM         ; Transmit data register
    mov               al, byte ptr BALL1_X       ; put the data into al
	mov				  ah,2
	out               dx,axl          ; sending the data
exit_x:
RET
SendBall_X ENDP




;Rec Ball_x

RecieveBall_X PROC FAR

	mov dx,COM+5        ;check if data is ready
	in al,dx
	test al,1
	jz exitRecieveBall_X        ;if not check for sending
	mov dx,COM
	in al,dx           ;read data from reg
	cmp ah,2
	jne exitRecieveBall_X
	MOV AH, 0
    ADD AX, 160          
	MOV BaLL2_Xrec, AX

exitRecieveBall_X:
RET
RecieveBall_X ENDP


SendBall_Y PROC FAR
;check_Y:
	mov               dx,COM+5        ; Line Status Register
	in                al,dx           ;Read Line Status
	test              al,00100000b
	jz                exitSendBall_Y       ;Recieve if not empty

	mov               dx,COM          ; Transmit data register
    mov               al, byte ptr BALL1_Y       ; put the data into al
	mov				  ah,3
	out               dx,al           ; sending the data
exitSendBall_Y:
RET
SendBall_Y ENDP



;Rec Ball_y

RecieveBall_Y PROC FAR
	 mov dx,COM+5        ;check if data is ready
	in al,dx
	test al,1
	jz exitRecieveBall_Y        ;if not check for sending
	
	mov dx,COM
	in al,dx           ;read data from reg
	cmp ah,3
	jne exitRecieveBall_Y
	MOV AH, 0
	MOV BaLL2_Yrec, AX

exitRecieveBall_Y:
RET
RecieveBall_Y ENDP


MAIN PROC FAR
	MOV AX, @DATA
	MOV DS, AX

	; Set divisor Latch Acess bit
	mov dx,COM+3
	mov ax,10000000b
	out dx,al

;Set LSB of the Baud Rate Divisor Latch register
	mov dx,COM
	mov al,0ch          ;9600 baud rate
	out dx,al

;Set MSB of the Baud Rate Divisor Latch register
	mov dx,COM+1
	mov al,00h
	out dx,al

;Set Port config
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
	; CALL SendPaddle
	; CALL ReceivePaddle
	mov cx,1000000000000
	check_z:
	dec cx
	jnz check_z
	CALL SendBall_X
	CALL RecieveBall_X
	mov cx,1000000000000
	check_zz:
	dec cx
	jnz check_zz
	CALL SendBall_Y
	CALL RecieveBall_Y


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
	; MOV AX, PADDLE1_X
	; MOV PADDLE_X, AX
	; MOV AX, PADDLE2_X
	; MOV PADDLE_X, AX
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

	MOV AX,BALL2_X
	MOV BALL_X,AX
	MOV AX,BALL2_Y
	MOV BALL_Y,AX
	CALL clearBall


    MOV AX,BaLL2_Xrec
	MOV BALL2_X, AX
	MOV BALL_X, AX
	MOV AX,BaLL2_Yrec
	MOV BALL2_Y, AX
	MOV BALL_Y, AX
	MOV AX, BALL2_VELOCITY_X
	MOV BALL_VELOCITY_X, AX
	MOV AX, BALL2_VELOCITY_Y
	MOV BALL_VELOCITY_Y, AX
	CALL checkCollision
	CALL drawBall
	MOV AX, BALL_VELOCITY_X
	MOV BALL2_VELOCITY_X, AX
	MOV AX, BALL_VELOCITY_Y
	MOV BALL2_VELOCITY_Y, AX
	; MOV AX, BALL_X
	; MOV BALL2_X, AX
	; MOV AX, BALL_Y
	; MOV BALL2_Y, AX
	
	
WaitForVSync:
	MOV DX, 03DAh         ; VGA Input Status Register 1
WaitForRetrace:
	IN AL, DX
	TEST AL, 08H          ; Check the Vertical Retrace bit (bit 3)
	JZ WaitForRetrace     ; Loop until retrace starts

	CALL movePaddle1

	MOV AX, PADDLE2_X
	CMP AX, PADDLE2_X2
	JE gameLoop

	MOV AX, PADDLE2_X
	MOV PADDLE_X, AX
	CALL clearPaddle

    
	
	CALL drawBall


	MOV AX,PADDLE2_X2
	MOV PADDLE2_X, AX
	MOV PADDLE_X, AX
	CALL drawPaddle

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




