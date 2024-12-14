EXTRN BALL_X:WORD
EXTRN BALL_Y:WORD
EXTRN BALL_VELOCITY_X:WORD
EXTRN BALL_VELOCITY_Y:WORD
EXTRN clearTile:FAR

PUBLIC checkCollision

getColor MACRO x, y
    MOV AH, 0Dh       ; Function: Read Pixel
    MOV BH, 0         ; Video page (usually 0)
    MOV CX, x         ; X-coordinate (column)
    MOV DX, y         ; Y-coordinate (row)
    INT 10h           ; BIOS video interrupt
    ; The color is now in AL
ENDM

.MODEL SMALL
.386

.DATA
BALL_PIXELS EQU 0Ah        ; Diameter of the ball
WINDOW_WIDTH EQU 158       ; Play area width
WINDOW_HEIGHT EQU 0c8h     ; Play area height (200 in hex)

.CODE
checkCollision PROC FAR
    pusha                ; Save all registers

    ; ==== Handle Border Collisions ====
    ; Left Border Collision
    CMP BALL_X, 0        
    JGE checkRightBorder 
    NEG BALL_VELOCITY_X  
    ;MOV BALL_X, 0        

checkRightBorder:
    MOV AX, WINDOW_WIDTH
    SUB AX, BALL_PIXELS
    CMP BALL_X, AX       
    JLE checkTopBorder   
    NEG BALL_VELOCITY_X  
    ;MOV BALL_X, AX       

checkTopBorder:
    CMP BALL_Y, 0        
    JGE checkBottomBorder
    NEG BALL_VELOCITY_Y  
    ;MOV BALL_Y, 0        ; Keep ball inside the top border

checkBottomBorder:
    MOV AX, WINDOW_HEIGHT
    SUB AX, BALL_PIXELS
    CMP BALL_Y, AX       
    JLE checkBrickCollision 
    NEG BALL_VELOCITY_Y  
   ; MOV BALL_Y, AX       ; Keep ball inside the bottom border

    ; ==== Brick Collision Check ====
checkBrickCollision:
    ; Top of the ball
    MOV AX, BALL_X
    ADD AX, 5            ; Center of the ball (X)
    MOV BX, BALL_Y
    getColor AX, BX
    CMP AL, 0            ; Check if the pixel is not empty
    JNZ handleTopCollision

    ; Left of the ball
    MOV AX, BALL_X
    MOV BX, BALL_Y
    ADD BX, 5            ; Center of the ball (Y)
    getColor AX, BX
    CMP AL, 0
    JNZ handleLeftCollision

    ; Bottom of the ball
    MOV AX, BALL_X
    ADD AX, 5
    MOV BX, BALL_Y
    ADD BX, 0Ah          ; Bottom edge of the ball
    getColor AX, BX
    CMP AL, 0
    JNZ handleBottomCollision

    ; Right of the ball
    MOV AX, BALL_X
    ADD AX, 0Ah          ; Right edge of the ball
    MOV BX, BALL_Y
    ADD BX, 5
    getColor AX, BX 
    CMP AL, 0
    JNZ handleRightCollision

    JMP skipCollisionCheck ; If no collision, skip

; ==== Collision Handlers ====
handleTopCollision:
    NEG BALL_VELOCITY_Y  ; Reverse vertical velocity for top collision
    JMP clearBrick

handleBottomCollision:
    NEG BALL_VELOCITY_Y  ; Reverse vertical velocity for bottom collision
    JMP clearBrick

handleLeftCollision:
    NEG BALL_VELOCITY_X  ; Reverse horizontal velocity for left collision
    JMP clearBrick

handleRightCollision:
    NEG BALL_VELOCITY_X  ; Reverse horizontal velocity for right collision

clearBrick:
    ; Convert ball position to brick grid coordinates
    MOV AX, BALL_X
    MOV BL, 20           ; Grid width factor
    DIV BL
    MOV CL, AL           ; Grid X coordinate in CL

    MOV AX, BALL_Y
    MOV BL, 10           ; Grid height factor
    DIV BL
    MOV CH, AL           ; Grid Y coordinate in CH

    ; Call clearTile with grid coordinates (CL = X, CH = Y)
    MOV AL, CL
    MOV AH, CH
    CALL clearTile

skipCollisionCheck:
    popa                 ; Restore all registers
    RET

checkCollision ENDP
END
