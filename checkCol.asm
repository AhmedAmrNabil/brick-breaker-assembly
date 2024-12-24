EXTRN BALL_X:WORD
EXTRN BALL_Y:WORD
EXTRN BALL2_X:WORD
EXTRN BALL2_Y:WORD
EXTRN BALL_VELOCITY_X:WORD
EXTRN BALL_VELOCITY_Y:WORD
EXTRN PADDLE_X:WORD
EXTRN GAME_OVER_FLAG:BYTE
EXTRN clearTile:FAR

PUBLIC checkCollision
PUBLIC checkCollision2

.MODEL SMALL
.STACK 100h

.386

.DATA
SCREEN_WIDTH  EQU 160
SCREEN_HEIGHT EQU 200
BALL_SIZE     EQU 5
PADDLE_Y      EQU 180
PADDLE_WIDTH EQU 50
PADDLE_HEIGHT EQU 10
TILE_WIDTH  equ 20
TILE_HEIGHT equ 10
rest_position_X equ 80
rest_position_Y equ 150
BALL_VELOCITY_MAG EQU 1
COLLISION_X dw ?
COLLISION_Y dw ?
COLLISION_X_FLAG db ?
COLLISION_Y_FLAG db ?


.CODE
getPixelColor PROC FAR
    MOV AX, 0

    MOV AH, 0Dh
    INT 10h

    MOV AH, 0

    RET
getPixelColor ENDP

checkPaddleCollision PROC FAR
    MOV AX, BALL_Y
    ADD AX, BALL_SIZE
    CMP AX, PADDLE_Y
    JL  endCheckPaddle
    MOV AX, PADDLE_Y
    ADD AX, PADDLE_HEIGHT
    CMP AX, BALL_Y
    JL  endCheckPaddle
checkPaddleX:
    MOV AX, BALL_X
    ADD AX,BALL_SIZE
    CMP AX, PADDLE_X
    JL  endCheckPaddle
    MOV AX, PADDLE_X
    ADD AX, PADDLE_WIDTH
    CMP AX, BALL_X
    JL  endCheckPaddle
    
    MOV AX, BALL_X
    ADD AX, BALL_SIZE/2
    MOV BX, PADDLE_X
    ADD BX,5
    CMP AX,BX
    JL farLeft
    ADD BX,15
    CMP AX,BX
    JL nearLeft
    ADD BX,15
    CMP AX,BX
    JL nearRight
    JMP farRight
    RET

nearLeft:
    MOV BALL_VELOCITY_X, -BALL_VELOCITY_MAG
    MOV BALL_VELOCITY_Y, -BALL_VELOCITY_MAG*2
    RET
farLeft:
    MOV BALL_VELOCITY_X, -BALL_VELOCITY_MAG*2
    MOV BALL_VELOCITY_Y, -BALL_VELOCITY_MAG
    RET

nearRight:
    MOV BALL_VELOCITY_X, BALL_VELOCITY_MAG
    MOV BALL_VELOCITY_Y, -BALL_VELOCITY_MAG*2
    RET

farRight:
    MOV BALL_VELOCITY_X, BALL_VELOCITY_MAG*2
    MOV BALL_VELOCITY_Y, -BALL_VELOCITY_MAG

    RET
endCheckPaddle:
    RET
checkPaddleCollision ENDP

checkCollision PROC FAR
    MOV AX, BALL_X
    MOV BX, BALL_Y
    MOV COLLISION_X_FLAG, 0
    MOV COLLISION_Y_FLAG, 0

; Check left boundary
LeftBoundary:
    CMP AX, 1
    JG  RightBoundary
    NEG BALL_VELOCITY_X
    JMP EndCheck

; Check right boundary
RightBoundary:
    CMP AX, SCREEN_WIDTH - BALL_SIZE -1
    JL  TopBoundary
    NEG BALL_VELOCITY_X
    JMP EndCheck

; Check top boundary
TopBoundary:
    MOV BX, BALL_Y
    CMP BX, 1
    JG  BottomBoundary
    NEG BALL_VELOCITY_Y
    JMP EndCheck

; Will be removed later for game over
; Check bottom boundary
BottomBoundary:
    cmp BX, SCREEN_HEIGHT - 15
    JL  skipBottomBoundary
    mov ax,rest_position_X
    mov BALL_X,ax
    mov ax,rest_position_Y
    mov BALL_Y,ax
    mov BALL_VELOCITY_X,  2
	mov BALL_VELOCITY_Y,  -1
    mov GAME_OVER_FLAG,0
    JMP EndCheck

skipBottomBoundary:
  
    CMP BX, 100
    JL skipPaddle
    call checkPaddleCollision
    JMP EndCheck
    
skipPaddle:

; Check the color of the pixel at the top and bottom edges of the ball
TopEdgeColor:
    MOV CX, BALL_X
    MOV DX, BALL_Y
    DEC DX
    DEC DX
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromTop

    MOV CX, BALL_X
    MOV DX, BALL_Y
    DEC DX
    DEC DX
    ADD CX, BALL_SIZE - 1
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromTop 

BottomEdgeColor:
    MOV CX, BALL_X
    MOV DX, BALL_Y
    ADD DX, BALL_SIZE
    INC DX
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromBottom

    MOV CX, BALL_X
    MOV DX, BALL_Y
    ADD DX, BALL_SIZE
    INC DX
    ADD CX, BALL_SIZE - 1
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromBottom

; Check the color of the pixel at the left and right edges of the ball
LeftEdgeColor:
    MOV CX, BALL_X
    DEC CX
    DEC CX
    MOV DX, BALL_Y
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromLeft

    MOV CX, BALL_X
    DEC CX
    DEC CX
    MOV DX, BALL_Y
    ADD DX, BALL_SIZE - 1
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromLeft

RightEdgeColor:
    MOV CX, BALL_X
    ADD CX, BALL_SIZE
    INC CX
    MOV DX, BALL_Y
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromRight

    MOV CX, BALL_X
    ADD CX, BALL_SIZE
    INC CX
    MOV DX, BALL_Y
    ADD DX, BALL_SIZE - 1
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromRight

    JMP EndCheck

; Clear the tile above the ball
BallCollidedFromTop:
    CMP COLLISION_Y_FLAG, 1
    JE skipNegYTop
    NEG BALL_VELOCITY_Y
    MOV COLLISION_Y_FLAG,1
    skipNegYTop:
    MOV COLLISION_X,CX
    MOV COLLISION_Y,DX

    MOV AX, COLLISION_X
    MOV CX, TILE_WIDTH
    DIV CL
    MOV AH, 0
    MOV DX, AX

    MOV AX, COLLISION_Y
    MOV CX, TILE_HEIGHT
    DIV CL
    MOV AH, 0
    MOV AH, AL
    MOV AL, DL

    CALL clearTile

    JMP TopEdgeColor

; Clear the tile below the ball
BallCollidedFromBottom:
    CMP COLLISION_Y_FLAG, 1
    JE skipNegYBottom
    NEG BALL_VELOCITY_Y
    MOV COLLISION_Y_FLAG,1
    
    skipNegYBottom:
    MOV COLLISION_X,CX
    MOV COLLISION_Y,DX

    MOV AX, COLLISION_X
    MOV CX, TILE_WIDTH
    DIV CL
    MOV AH, 0
    MOV DX, AX

    MOV AX, COLLISION_Y
    MOV CX, TILE_HEIGHT
    DIV CL
    MOV AH, 0
    MOV AH, AL
    MOV AL, DL

    CALL clearTile

    JMP BottomEdgeColor

; Clear the tile to the left of the ball
BallCollidedFromLeft:
    
    CMP COLLISION_X_FLAG, 1
    JE skipNegXLeft
    NEG BALL_VELOCITY_X
    MOV COLLISION_X_FLAG,1
    
    skipNegXLeft:
    MOV COLLISION_X,CX
    MOV COLLISION_Y,DX

    MOV AX, COLLISION_X
    MOV CX, TILE_WIDTH
    DIV CL
    MOV AH, 0
    MOV DX, AX

    MOV AX, COLLISION_Y
    MOV CX, TILE_HEIGHT
    DIV CL
    MOV AH, 0
    MOV AH, AL
    MOV AL, DL

    CALL clearTile

    JMP LeftEdgeColor

; Clear the tile to the right of the ball
BallCollidedFromRight:
        
    CMP COLLISION_X_FLAG, 1
    JE skipNegXRight
    NEG BALL_VELOCITY_X
    MOV COLLISION_X_FLAG,1
    
    skipNegXRight:

    MOV COLLISION_X,CX
    MOV COLLISION_Y,DX

    MOV AX, COLLISION_X
    MOV CX, TILE_WIDTH
    DIV CL
    MOV AH, 0
    MOV DX, AX

    MOV AX, COLLISION_Y
    MOV CX, TILE_HEIGHT
    DIV CL
    MOV AH, 0
    MOV AH, AL
    MOV AL, DL

    CALL clearTile

    JMP BottomEdgeColor

EndCheck:
    RET
checkCollision ENDP


checkCollision2 PROC FAR
    MOV AX, BALL2_X
    MOV BX, BALL2_Y

    CMP BX,100
    JG EndCheck2

; Check the color of the pixel at the top and bottom edges of the ball
TopEdgeColor2:
    MOV CX, BALL2_X
    MOV DX, BALL2_Y
    DEC DX
    DEC DX
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollided

    MOV CX, BALL2_X
    MOV DX, BALL2_Y
    DEC DX
    DEC DX
    ADD CX, BALL_SIZE - 1
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollided

BottomEdgeColor2:
    MOV CX, BALL2_X
    MOV DX, BALL2_Y
    ADD DX, BALL_SIZE
    INC DX
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollided

    MOV CX, BALL2_X
    MOV DX, BALL2_Y
    ADD DX, BALL_SIZE
    INC DX
    ADD CX, BALL_SIZE - 1
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollided

; Check the color of the pixel at the left and right edges of the ball
LeftEdgeColor2:
    MOV CX, BALL2_X
    DEC CX
    DEC CX
    MOV DX, BALL2_Y
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollided

    MOV CX, BALL2_X
    DEC CX
    DEC CX
    MOV DX, BALL2_Y
    ADD DX, BALL_SIZE - 1
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollided

RightEdgeColor2:
    MOV CX, BALL2_X
    ADD CX, BALL_SIZE
    INC CX
    MOV DX, BALL2_Y
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollided

    MOV CX, BALL2_X
    ADD CX, BALL_SIZE
    INC CX
    MOV DX, BALL2_Y
    ADD DX, BALL_SIZE - 1
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollided

    JMP EndCheck2

; Clear the tile above the ball
BallCollided:
    MOV COLLISION_X,CX
    MOV COLLISION_Y,DX

    MOV AX, COLLISION_X
    MOV CX, TILE_WIDTH
    DIV CL
    MOV AH, 0
    MOV DX, AX

    MOV AX, COLLISION_Y
    MOV CX, TILE_HEIGHT
    DIV CL
    MOV AH, 0
    MOV AH, AL
    MOV AL, DL

    CALL clearTile

    JMP TopEdgeColor2

; Clear the tile below the ball


EndCheck2:
    RET
checkCollision2 ENDP

END