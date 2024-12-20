EXTRN BALL_X:WORD
EXTRN BALL_Y:WORD
EXTRN BALL_VELOCITY_X:WORD
EXTRN BALL_VELOCITY_Y:WORD
EXTRN PADDLE_X:WORD
EXTRN clearTile:FAR

PUBLIC checkCollision

.MODEL SMALL
.STACK 100h

.386

.DATA
SCREEN_WIDTH  EQU 160
SCREEN_HEIGHT EQU 200
BALL_SIZE     EQU 10
PADDLE_Y      EQU 180
PADDLE_WIDTH EQU 40
PADDLE_HEIGHT EQU 10
TILE_WIDTH  equ 20
TILE_HEIGHT equ 10
BALL_VELOCITY_MAG equ 5

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
    JE checkPaddleX
    RET
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
    ADD BX,10
    CMP AX,BX
    JL farLeft
    ADD BX,10
    CMP AX,BX
    JL nearLeft
    ADD BX,10
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

; Check left boundary
LeftBoundary:
    CMP AX, 0
    JG  RightBoundary
    NEG BALL_VELOCITY_X
    JMP EndCheck

; Check right boundary
RightBoundary:
    CMP AX, SCREEN_WIDTH - BALL_SIZE
    JL  TopBoundary
    NEG BALL_VELOCITY_X
    JMP EndCheck

; Check top boundary
TopBoundary:
    MOV BX, BALL_Y
    CMP BX, 0 
    JG  BottomBoundary
    NEG BALL_VELOCITY_Y
    JMP EndCheck

; Will be removed later for game over
; Check bottom boundary
BottomBoundary:
    CMP BX, SCREEN_HEIGHT - BALL_SIZE
    JL  paddleCollision
    NEG BALL_VELOCITY_Y
    JMP EndCheck

; Check if ball collided with paddle from the top of the paddle

paddleCollision:
    MOV AX, BALL_Y
    CMP AX, 70
    JL TopAndBottomEdgeColor
    CALL checkPaddleCollision
    RET

; Check the color of the pixel at the top and bottom edges of the ball
TopAndBottomEdgeColor:
    MOV CX, BALL_X
    MOV DX, BALL_Y
    DEC DX
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromTop

    MOV CX, BALL_X
    MOV DX, BALL_Y
    ADD DX, BALL_SIZE
    ADD DX, 1
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromBottom

; Check the color of the pixel at the left and right edges of the ball
LeftAndRightEdgeColor:
    MOV CX, BALL_X
    DEC CX
    MOV DX, BALL_Y
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromLeft

    MOV CX, BALL_X
    ADD CX, BALL_SIZE
    INC CX
    MOV DX, BALL_Y
    CALL getPixelColor
    CMP AX, 0
    JNE BallCollidedFromRight

    JMP EndCheck

; Clear the tile above the ball
BallCollidedFromTop:
    NEG BALL_VELOCITY_Y

    MOV AX, BALL_X
    MOV CX, TILE_WIDTH
    DIV CL
    MOV AH, 0
    MOV DX, AX

    MOV AX, BALL_Y
    SUB AX, TILE_HEIGHT
    INC AX
    MOV CX, TILE_HEIGHT
    DIV CL
    MOV AH, 0
    MOV AH, AL
    MOV AL, DL

    CALL clearTile

    JMP LeftAndRightEdgeColor

; Clear the tile below the ball
BallCollidedFromBottom:
    NEG BALL_VELOCITY_Y

    MOV AX, BALL_X
    MOV CX, TILE_WIDTH
    DIV CL
    MOV AH, 0
    MOV DX, AX

    MOV AX, BALL_Y
    ADD AX, TILE_HEIGHT
    DEC AX
    MOV CX, TILE_HEIGHT
    DIV CL
    MOV AH, 0
    MOV AH, AL
    MOV AL, DL

    CALL clearTile

    JMP LeftAndRightEdgeColor

; Clear the tile to the left of the ball
BallCollidedFromLeft:
    NEG BALL_VELOCITY_X

    MOV AX, BALL_X
    SUB AX, TILE_WIDTH
    INC AX
    MOV CX, TILE_WIDTH
    DIV CL
    MOV AH, 0
    MOV DX, AX

    MOV AX, BALL_Y
    MOV CX, TILE_HEIGHT
    DIV CL
    MOV AH, 0
    MOV AH, AL
    MOV AL, DL

    CALL clearTile

    JMP EndCheck

; Clear the tile to the right of the ball
BallCollidedFromRight:
    NEG BALL_VELOCITY_X

    MOV AX, BALL_X
    ADD AX, TILE_WIDTH
    DEC AX
    MOV CX, TILE_WIDTH
    DIV CL
    MOV AH, 0
    MOV DX, AX

    MOV AX, BALL_Y
    MOV CX, TILE_HEIGHT
    DIV CL
    MOV AH, 0
    MOV AH, AL
    MOV AL, DL

    CALL clearTile

    JMP EndCheck

EndCheck:
    RET
checkCollision ENDP

END
