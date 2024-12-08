EXTRN PADDLE1_VEL_X:WORD

PUBLIC checkInput

.MODEL small
.386
.DATA
	PADDLE_VEL_MAG EQU 5

.CODE
checkInput PROC FAR
	MOV AH, 01H			; check for charater in keyboard buffer
	INT 16H
	JNZ stopMoving				
	MOV AH, 00h			; remove the charater from buffer
	INT 16H

	; check for a or A to move left
	CMP AL,'A'			
	JE moveLeft
	CMP AL,'a'
	JE moveLeft

	; check for d or D to move right
	CMP AL,'D'
	JE moveRight
	CMP AL,'d'
	JE moveRight
	
	; else stop moving
stopMoving:
	MOV PADDLE1_VEL_X, 0
	JMP exit

moveLeft:
	MOV AX, PADDLE_VEL_MAG
	NEG AX
	MOV PADDLE1_VEL_X, AX
	JMP exit

moveRight:
	MOV AX, PADDLE_VEL_MAG
	MOV PADDLE1_VEL_X, AX
	JMP exit

exit:
	RET
checkInput ENDP
END