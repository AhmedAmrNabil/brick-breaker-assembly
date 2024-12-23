EXTRN PADDLE1_VEL_X:WORD
EXTRN GAME_EXIT_FLAG:BYTE

PUBLIC checkInput

.MODEL small
.386
.DATA
	PADDLE_VEL_MAG EQU 5
	MOVE_LEFT DW 0
	MOVE_RIGHT DW 0

.CODE
checkInput PROC FAR
	PUSHA                                                       ;push all regs to the stack
	PUSHF                                                       ;push flag register to the stack
	IN AL,60h 

	; check for a or A to move left
	CMP AL,1EH			
	JE moveLeft

	; check for d or D to move right
	CMP AL,20H
	JE moveRight

	CMP AL, 1EH + 80H
	JE stopMoveLeft
	
	CMP AL, 20H + 80H
	JE stopMoveRight

	CMP AL, 01h
	JE exitGame
	JMP exit
	
moveLeft:
	MOV MOVE_LEFT, -1*PADDLE_VEL_MAG
	JMP exit

stopMoveLeft:
	MOV MOVE_LEFT, 0
	JMP exit

moveRight:
	MOV MOVE_RIGHT, PADDLE_VEL_MAG
	JMP exit

stopMoveRight:
	MOV MOVE_RIGHT, 0
	JMP exit

exitGame:
	MOV GAME_EXIT_FLAG, 1
	JMP exit

exit:
	MOV AX, MOVE_LEFT
	ADD AX, MOVE_RIGHT
	MOV PADDLE1_VEL_X, AX
	MOV AL, 20h			;The non specific EOI (End Of Interrupt)
	OUT 20h, AL
	POPF
	POPA
	IRET
checkInput ENDP
END