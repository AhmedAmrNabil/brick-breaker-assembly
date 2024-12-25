EXTRN drawTile:FAR
EXTRN drawPaddle:FAR
EXTRN drawPaddle2:FAR
EXTRN drawBall:FAR
EXTRN drawColoredTile:FAR
EXTRN clearBall:FAR
EXTRN clearPaddle:FAR
EXTRN clearPaddle2:FAR
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
PUBLIC BALL1_VELOCITY_X
PUBLIC BALL1_VELOCITY_Y
PUBLIC CLEAR_TILE_OFFSET
PUBLIC GAME_EXIT_FLAG
PUBLIC TIME
PUBLIC LCG
PUBLIC SEED
PUBLIC POWERUPSARR
PUBLIC PADDLE_VEL_MAG
PUBLIC PADDLE_WIDTH
PUBLIC PADDLE2_WIDTH
PUBLIC SKIP_PADDLE_CHECK
PUBLIC GAME_OVER_FLAG
PUBLIC GAME_OVER_FLAG2
PUBLIC COUNT_TILES
PUBLIC CI_MOVE_LEFT
PUBLIC CI_MOVE_RIGHT

getSystemTime MACRO
	MOV AH, 2CH    ;get the system time
	INT 21H       ; CH = hour, CL = minute, DH = seconds, DL = 1/100s
ENDM

setIntteruptHandle MACRO
;getting int09h interrupt vector handler
	CLI                       ;turn off interrupt flag
	PUSHA
;get the interrupt 09 address
	MOV   AX,3509h
	INT   21h

;save the original interrupt address
	MOV   int9Off, BX
	MOV   int9Seg, es
	POPA

;setting the new INT 09h interrupt vector handler
	PUSH  DS
	MOV   AX,cs
	MOV   DS,AX               ;load the segment of the new interrupt
	LEA   DX,checkInput    ;load the offset of the new interrupt
	MOV   AX,2509h            ; INT 21/25h at interrupt 09
	INT   21h
	POP   DS
	STI
ENDM

resetInterruptHandle MACRO
	CLI

	MOV  AX,int9Seg
	MOV  DX,int9Off
	PUSH DS
	MOV  DS,AX
	MOV  AX,2509h
	INT  21h
	POP  DS

	STI
ENDM

initSerialPort MACRO
	; Set divisor Latch Acess bit
	MOV DX, COM + 3
	MOV AX, 10000000b
	OUT DX, AL

	;Set LSB of the Baud Rate Divisor Latch register
	MOV DX, COM
	MOV AL, 01h
	OUT DX, AL

	;Set MSB of the Baud Rate Divisor Latch register
	MOV DX, COM + 1
	MOV AL, 00h
	OUT DX, AL

	; Set Port config
	; transrecieve buffer,set break disabled, even parity, one stop bit, 8 bit word
	MOV DX, COM + 3
	MOV AX, 00011011b
	OUT DX, AL
ENDM

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

.MODEL small
.386

.STACK 100h
.DATA
	CI_MOVE_LEFT dw 0
	CI_MOVE_RIGHT dw 0

	PADDLE1_VEL_X dw 0

	PADDLE_X dw ?
	PADDLE1_X dw 50
	PADDLE2_X dw 210
	PADDLE2_X2 dw 210
	PADDLE_WIDTH dw 40
	PADDLE2_WIDTH dw 40

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
	
	POWERUP_COUNT_1 db 0
	POWERUP_COUNT_2 db 0

	GAME_EXIT_FLAG db 0
	GAME_OVER_FLAG dw 16
	GAME_OVER_FLAG2 dw 178

	GAMELOOP_SPEED dw 2

	CLEAR_TILE_OFFSET db 8
	COUNT_TILES db 0

	TEXT_GAME_OVER db 'Game Over','$'
	TEXT_PLAYERL db 'YOU LOST$'
	TEXT_PLAYERW db 'YOU WON$'

	TEXT_REST_MENU db 'Press Y to go back to the main menu','$'
	yes_or_no db ?

	TIME DB 0

	BRICKS_COLS EQU 8
	BRICKS_COUNT EQU 48
	BALL_SIZE EQU 5
	PADDLE_VEL_MAG dw 4

	int9Seg DW ?
	int9Off DW ?
	SEED DD 5970917
	MULTIPLIER EQU 22695477	
	INCREMENT EQU 1
	MODULUS EQU 2147483647

	myRandomTiles DB 5 dup(0)
	enemyRandomTiles DB 5 dup(0)

	waitingMessage db 'Waiting for another player$'

	POWERUPSARR db 5 dup(0)

	SKIP_PADDLE_CHECK db 0

	COM EQU 03F8h
.CODE

Game_over_Screen PROC FAR
	MOV AH, 0
	MOV AL, 13h
	INT 10h

	MOV ah,02H
	MOV bh,00H
	MOV dh,04h
	MOV dl,04h
	int 10h

	MOV ah,09H
	lea dx,TEXT_GAME_OVER
	int 21h

	CMP GAME_OVER_FLAG, 1
	jg WINNING

	MOV ah,02H
	MOV bh,00H
	MOV dh,06h
	MOV dl,04h
	int 10h
	MOV ah,09H
	lea dx,TEXT_PLAYERL
	int 21h
	JMP EXIT_SC

WINNING:
	MOV ah,02H
	MOV bh,00H
	MOV dh,06h
	MOV dl,04h
	int 10h
	MOV ah,09H
	lea dx,TEXT_PLAYERW
	int 21h

EXIT_SC:
	MOV ah,02H
	MOV bh,00H
	MOV dh,08h
	MOV dl,04h
	int 10h

	MOV ah, 09h
	lea dx,TEXT_REST_MENU
	int 21h

RET
Game_over_Screen ENDP

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

initGame PROC FAR
	; set video mode to 320x200 256-color mode
	MOV AH, 0
	MOV AL, 13h
	INT 10h

	; set initial values
	MOV GAMELOOP_SPEED, 2
	MOV GAME_EXIT_FLAG,0
	MOV PADDLE1_X , 50
	MOV PADDLE2_X , 210
	MOV PADDLE2_X2 , 210
	MOV PADDLE1_VEL_X , 0
	MOV BALL1_X , 80
	MOV BALL1_Y , 150
	MOV BALL2_X , 240
	MOV BALL2_Y , 150
	MOV BaLL2_Xrec , 240
	MOV BaLL2_Yrec , 150
	MOV BALL1_VELOCITY_X , 1
	MOV BALL1_VELOCITY_Y , -2
	MOV PADDLE_WIDTH,40
	MOV PADDLE2_WIDTH,40
	MOV GAME_OVER_FLAG, 16
	MOV GAME_OVER_FLAG2, 178
	MOV COUNT_TILES, 0
	MOV CI_MOVE_LEFT, 0
	MOV CI_MOVE_RIGHT, 0

	MOV CX,5
	MOV SI,0
resetPowerups:
	MOV POWERUPSARR[SI],0
	INC SI
	LOOP resetPowerups

	MOV SKIP_PADDLE_CHECK, 0

	; draw the bricks (player 1)
	MOV CL, BRICKS_COLS
	MOV DX, 8
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
	MOV DX, 8
printLoop2:
	MOV AX, DX
	DIV CL
	XCHG AL, AH
	ADD AL, 8
	CALL drawTile
	INC DX
	CMP DX, BRICKS_COUNT
	JL printLoop2

	MOV CH, 0
	MOV CL, POWERUP_COUNT_1
	MOV SI,0
powerupLoop1:
	PUSH CX
	MOV DL, myRandomTiles[SI]
	INC SI
	MOV DH,0
	MOV AX,DX
	MOV CL,8
	DIV CL
	XCHG AL, AH
	INC AH
	CALL drawColoredTile
	POP CX
	LOOP powerupLoop1	

	MOV CH, 0
	MOV CL, POWERUP_COUNT_2
	MOV SI, 0
powerupLoop2:
	PUSH CX
	MOV DH, 0
	MOV DL, enemyRandomTiles[SI]
	INC SI
	MOV AX, DX
	MOV CL, BRICKS_COLS
	DIV CL
	XCHG AL, AH
	ADD AL, 8
	INC AH
	CALL drawColoredTile
	POP CX
	LOOP powerupLoop2	

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

	MOV Ball_X,2
	MOV BALL_Y,2
	CALL drawBall
	MOV Ball_X,9
	MOV BALL_Y,2
	CALL drawBall
	MOV Ball_X,16
	MOV BALL_Y,2
	CALL drawBall

	MOV Ball_X,164
	MOV BALL_Y,2
	CALL drawBall
	MOV Ball_X,171
	MOV BALL_Y,2
	CALL drawBall
	MOV Ball_X,178
	MOV BALL_Y,2
	CALL drawBall

	; draw the separator
	drawSeparator
initGame ENDP

generateRandomBricks PROC FAR
	PUSHA
	PUSHF

	; generate seed with system time
	MOV AH, 00h
	INT 1Ah
	MOV AX,CX
	SHL EAX, 16
	MOV AX,DX
	MOV SEED, EAX

	; generate random powerup count
	MUL EAX
	SHR EAX, 15
	AND EAX,00000003h
	ADD EAX,2
	MOV POWERUP_COUNT_1,AL

	; generate random bricks
	MOV CH, 0
	MOV CL, POWERUP_COUNT_1
	MOV SI, 0
randomBricksLoop:
	PUSH CX
	CALL LCG
	MOV EAX,SEED
	MOV ECX,40
	XOR EDX,EDX
	DIV ECX
	MOV myRandomTiles[SI], DL
	INC SI
	POP CX
	LOOP randomBricksLoop

	POPF
	POPA
	RET
generateRandomBricks ENDP

loadingScreen PROC FAR
	PUSHA
	PUSHF

	; Show loading screen
	MOV AH, 0
	MOV AL, 03h
	INT 10h
	
	MOV AH, 09h
	LEA DX, waitingMessage
	INT 21h

StartSendRandomByte:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 00100000b
	JZ StartSendRandomByte

	MOV DX, COM
	MOV AL, 0FEh
	OUT DX, AL

sendPowerupCount:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 00100000b
	JZ sendPowerupCount

	MOV DX, COM
	MOV AL, POWERUP_COUNT_1
	OUT DX, AL

	MOV CX, 0
	MOV CL, POWERUP_COUNT_1
	MOV SI, 0
sendRandomLoop:
	PUSH CX
sendRandomLoop2:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 00100000b
	JZ sendRandomLoop2

	MOV AL, myRandomTiles[SI]
	INC SI
	MOV DX, COM
	OUT DX, AL

	POP CX
	LOOP sendRandomLoop

receiveStartRandomByte:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 1
	JZ receiveStartRandomByte

	MOV DX, COM
	IN AL, DX
	CMP AL, 0FEh
	JNE receiveStartRandomByte

receivePowerupCount:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 1
	JZ receivePowerupCount

	MOV DX, COM
	IN AL, DX
	MOV POWERUP_COUNT_2, AL

	MOV CX, 0
	MOV CL, POWERUP_COUNT_2
	MOV SI, 0
receiveRandomLoop:
	PUSH CX
receiveRandomLoop2:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 00000001b
	JZ receiveRandomLoop2

	MOV DX, COM
	IN AL, DX

	CMP AL, 0FFh
	JE receiveRandomLoop2
	CMP AL, 0FEh
	JE receiveRandomLoop2
	
	MOV enemyRandomTiles[SI],AL
	INC SI
	
	POP CX
	LOOP receiveRandomLoop

FinalStartSendRandomByte:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 00100000b
	JZ FinalStartSendRandomByte

	MOV DX, COM
	MOV AL, 0FEh
	OUT DX, AL 

finalSendPowerupCount:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 00100000b
	JZ finalSendPowerupCount

	MOV DX, COM
	MOV AL, POWERUP_COUNT_1
	OUT DX, AL

	MOV CX, 0
	MOV CL, POWERUP_COUNT_1
	MOV SI, 0
finalSendRandomLoop:
	PUSH CX
finalSendRandomLoop2:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 00100000b
	JZ finalSendRandomLoop2

	MOV AL, myRandomTiles[SI]
	INC SI
	MOV DX, COM
	OUT DX, AL

	POP CX
	LOOP finalSendRandomLoop

	POPF
	POPA

	RET
loadingScreen ENDP

SendAll PROC FAR
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 00100000b
	JZ exitSendAll

	MOV DX, COM
	MOV AL, 0FDh
	CMP GAME_EXIT_FLAG, 1
	JNE continueStartSendByte
	MOV AL, 0FFh
	OUT DX, AL
	JMP exitSendAll
continueStartSendByte:
	OUT DX, AL   

SendBall_X:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 00100000b
	JZ SendBall_X       

	MOV DX, COM
	MOV AL, BYTE PTR BALL1_X
	OUT DX, AL

SendBall_Y:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 00100000b
	JZ SendBall_Y

	MOV DX, COM
	MOV AL, BYTE PTR BALL1_Y
	OUT DX, AL

SendPaddle:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 00100000b
	JZ SendPaddle

	MOV DX, COM
	MOV AL, BYTE PTR PADDLE1_X
	CMP PADDLE_WIDTH, 60
	JNE continueSendPaddle
	OR AL, 10000000b
continueSendPaddle:
	OUT DX, AL

exitSendAll:
	RET
SendAll ENDP

ReceiveAll PROC FAR

WaitForReceiveByte:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 1
	JZ WaitForReceiveByte

	MOV DX, COM
	IN AL, DX
	CMP AL, 0FFh
	JNE continueWaitForReceiveByte
	MOV GAME_EXIT_FLAG, 1
	JMP exitReceiveAll

continueWaitForReceiveByte:
	CMP AL, 0FDh
	JNE WaitForReceiveByte

WaitBallX:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 1
	JZ  WaitBallX

	MOV DX, COM
	IN AL, DX
	
	MOV AH, 0
	ADD AX, 160          
	MOV BaLL2_Xrec, AX

WaitBallY:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 1
	JZ WaitBallY
	
	MOV DX, COM
	IN AL, DX
	MOV AH, 0
	MOV BaLL2_Yrec, AX

WaitPaddleX:
	MOV DX, COM + 5
	IN AL, DX
	TEST AL, 1
	JZ WaitPaddleX

	MOV DX, COM
	IN AL, DX
	MOV AH, 0

	TEST AL, 10000000b
	JZ resetSkipPaddleFlag
	MOV PADDLE2_WIDTH, 60
	MOV SKIP_PADDLE_CHECK, 1
	AND AL, 01111111b
	JMP continueWaitPaddleX

resetSkipPaddleFlag:
	CMP PADDLE2_WIDTH,60
	JNE continuepaddlewidthx
	call clearPaddle2

continuepaddlewidthx:	
	MOV PADDLE2_WIDTH, 40
	MOV SKIP_PADDLE_CHECK, 0

continueWaitPaddleX:
	ADD AX, 160 
	MOV PADDLE2_X2, AX

exitReceiveAll:
	RET
ReceiveAll ENDP

powerups PROC FAR
	PUSHA

	MOV DX,PADDLE_WIDTH

	MOV PADDLE_VEL_MAG, 4
	MOV PADDLE_WIDTH,40

checkSpeedUpPaddle:
	MOV AL, POWERUPSARR[0]
	CMP AL, 0
	JE checkSlowDownPaddle

	DEC POWERUPSARR[0]
	MOV PADDLE_VEL_MAG, 8
	JMP checkPaddleSize

checkSlowDownPaddle:
	MOV AL, POWERUPSARR[1]
	CMP AL, 0
	JE checkPaddleSize

	DEC POWERUPSARR[1]
	MOV PADDLE_VEL_MAG, 2
	JMP checkPaddleSize

checkPaddleSize:
	MOV AL, POWERUPSARR[2]
	CMP AL, 0
	JE EndPowerups

	DEC POWERUPSARR[2]
	MOV PADDLE_WIDTH, 60
	JMP EndPowerups

EndPowerups:
	CMP DX,PADDLE_WIDTH
	JE actuallyExitPowerups
	MOV CX,PADDLE_WIDTH
	PUSH CX
	MOV PADDLE_WIDTH,DX
	CALL clearPaddle
	POP CX
	MOV PADDLE_WIDTH,CX
	MOV SKIP_PADDLE_CHECK,1
	CALL movePaddle1
	call drawPaddle

actuallyExitPowerups:
	POPA
	RET
powerups ENDP

MAIN PROC FAR
	MOV AX, @DATA
	MOV DS, AX

	initSerialPort

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
	CALL generateRandomBricks

	CALL loadingScreen

	CALL initGame
	CALL SendAll
	setIntteruptHandle

gameLoop:
	GetSystemTime
	CMP DL, TIME
	JE gameLoop
	MOV TIME, DL

	CALL powerups

WaitForVSync:
	MOV DX, 03DAh         ; VGA Input Status Register 1
WaitForRetrace:
	IN AL, DX
	TEST AL, 08H          ; Check the Vertical Retrace bit (bit 3)
	JZ WaitForRetrace     ; Loop until retrace starts

	MOV CX, GAMELOOP_SPEED
collisionLoop:
	PUSH CX
	CMP GAME_EXIT_FLAG, 1
	JE gotoMainMenu

	CALL SendAll
	CALL ReceiveAll

	CMP GAME_OVER_FLAG, 1
	JL Game_Over_Loop
	CMP GAME_OVER_FLAG, 15
	JL clearchance 
	CMP COUNT_TILES, 5d
	JE Game_Over_Loop
	JMP coun
clearchance:
	MOV ax, GAME_OVER_FLAG
	ADD ax, 7
	MOV BALL_X, ax
	MOV BALL_Y, 2
	CALL clearBall
coun:
	CMP GAME_OVER_FLAG2, 160
	JL Game_Over_Loop
	CMP GAME_OVER_FLAG2, 177
	JL clearchance2
	JMP coun2 
clearchance2:
	MOV AX, GAME_OVER_FLAG2
	ADD AX,7
	MOV BALL_X,AX
	MOV BALL_Y,2
	CALL clearBall
coun2:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Player 1 ball                       ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; End Player 1 ball                   ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Player 2 ball                       ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
	POP CX
	DEC CX
	CMP CX,0
	JE skipLoop
	JMP collisionLoop

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; End Player 2 ball                   ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Player 2 paddle                     ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

skipLoop:
	; MOV AX, PADDLE2_X
	; CMP AX, PADDLE2_X2
	; JE skipDrawPaddle2

	MOV PADDLE_X, AX
	CALL clearPaddle2
	
	MOV AX, PADDLE2_X2
	MOV PADDLE2_X, AX
	MOV PADDLE_X, AX
	CALL drawPaddle2

skipDrawPaddle2:

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; End Player 2 paddle                 ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Player 1 paddle                     ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CALL movePaddle1

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; End Player 1 paddle                 ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	drawSeparator

	JMP gameLoop

Game_Over_Loop:
	CALL SendAll
	resetInterruptHandle
	CALL Game_over_Screen
	MOV AH, 00H         
	INT 16H
	MOV yes_or_no,AL
	CMP yes_or_no,'Y'
	JE gotoMainMenu
	CMP yes_or_no,'y'
	JE gotoMainMenu
	JMP Game_Over_Loop

gotoMainMenu:
	resetInterruptHandle
	call SendAll
	JMP menuLoop

chatOption:  
	CALL Chat
	JMP menuLoop 

exitGame:
	MOV AH, 4CH
	INT 21h
MAIN ENDP
END MAIN