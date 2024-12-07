PUBLIC drawTile

.MODEL small
.386
.DATA
	TILE_START_X dw  0
	TILE_END_X   dw  0
	TILE_START_Y dw  0
	TITLE_END_Y   dw  0

	TILE_WIDTH  equ 20
	TILE_HEIGHT equ 10
	BRICK_COLOR equ 20d
	BORDER_COLOR_1 equ 18d
	BORDER_COLOR_2 equ 22d

.CODE
drawTile PROC FAR
	PUSHA
	PUSHF

	MOV BX, AX    	; BH = y, BL = x
	MOV AX, 0

	; get the x pixel coordinate
	MOV AL, BL
	MOV DL, tileWidth
	MUL DL
	MOV TILE_START_X, AX
	ADD AX, tileWidth
	MOV TILE_END_X, AX

	MOV AX, 0

	; get the y pixel coordinate
	MOV AL, BH
	MOV DL, tileHeight
	MUL DL
	MOV TILE_START_Y, AX
	ADD AX, tileHeight
	MOV TITLE_END_Y, AX

	; draw the tile
	MOV AL, BRICK_COLOR
	MOV AH, 0ch
	MOV CX, TILE_START_X
	MOV DX, TILE_START_Y
drawX:
	INT 10h
	INC DX
	CMP DX, TITLE_END_Y
	JL drawX
	MOV DX, TILE_START_Y
	INC CX
	CMP CX, TILE_END_X
	JL drawX

	; draw borders
	MOV AL, BORDER_COLOR_2
	MOV AH, 0ch
	MOV CX, TILE_START_X
	MOV DX, TILE_START_Y
drawLeftBorder:
	INT 10h
	INC DX
	CMP DX, TITLE_END_Y
	JL drawLeftBorder

	MOV AL, BORDER_COLOR_1
	MOV AH, 0ch
	MOV CX, TILE_END_X
	DEC CX
	MOV DX, TILE_START_Y
drawRightBorder:
	INT 10h
	INC DX
	CMP DX, TITLE_END_Y
	JL drawRightBorder

	MOV AL, BORDER_COLOR_2
	MOV AH, 0ch
	MOV CX, TILE_START_X
	MOV DX, TILE_START_Y
drawTopBorder:
	INT 10h
	INC CX
	CMP CX, TILE_END_X
	JL drawTopBorder

	MOV AL, BORDER_COLOR_1
	MOV AH, 0ch
	MOV CX, TILE_START_X
	MOV DX, TITLE_END_Y
	DEC DX
drawBotBorder:
	INT 10h
	INC CX
	CMP CX, TILE_END_X
	JL drawBotBorder

	POPF
	POPA
	RET
drawTile ENDP
END