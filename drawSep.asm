PUBLIC drawSeparator

.MODEL SMALL
.STACK 10h
.386

.CODE
drawSeparator PROC FAR
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
	RET
drawSeparator ENDP
END