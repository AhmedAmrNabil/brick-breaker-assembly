PUBLIC drawTile

.model small
.386
.data
	tileStartX   dw  0
	tileEndX     dw  0
	tileStartY   dw  0
	tileEndY     dw  0

	windowWidth  equ 160
	tileWidth    equ 20
	tileHeight   equ 10
	brickColor   equ 20d
	borderColor1 equ 18d
	borderColor2 equ 22d

.code
drawTile proc far
	                pusha
	                pushf

	                mov   bx,ax          	; bh = y, bl = x
	                mov   ax,0
	;get the x pixel coordinate
	                mov   al,bl
	                mov   dl,tileWidth
	                mul   dl
	                mov   tileStartX,ax
	                add   ax,tileWidth
	                mov   tileEndX ,ax

	                mov   ax,0
	;get the y pixel coordinate
	                mov   al,bh
	                mov   dl,tileHeight
	                mul   dl
	                mov   tileStartY,ax
	                add   ax,tileHeight
	                mov   tileEndY ,ax

	; draw the tile
	                mov   al,brickColor
	                mov   ah,0ch
	                mov   cx,tileStartX
	                mov   dx,tileStartY
	drawX:          int   10h
	                inc   dx
	                cmp   dx,tileEndY
	                jl    drawX
	                mov   dx,tileStartY
	                inc   cx
	                cmp   cx,tileEndX
	                jl    drawX

	;draw borders

	                mov   al,borderColor2
	                mov   ah,0ch
	                mov   cx,tileStartX
	                mov   dx,tileStartY
	drawLeftBorder: int   10h
	                inc   dx
	                cmp   dx,tileEndY
	                jl    drawLeftBorder


	                mov   al,borderColor1
	                mov   ah,0ch
	                mov   cx,tileEndX
	                dec   cx
	                mov   dx,tileStartY
	drawRightBorder:int   10h
	                inc   dx
	                cmp   dx,tileEndY
	                jl    drawRightBorder

	                mov   al,borderColor2
	                mov   ah,0ch
	                mov   cx,tileStartX
	                mov   dx,tileStartY
	drawTopBorder:  int   10h
	                inc   cx
	                cmp   cx,tileEndX
	                jl    drawTopBorder

	                mov   al,borderColor1
	                mov   ah,0ch
	                mov   cx,tileStartX
	                mov   dx,tileEndY
	                dec   dx
	drawBotBorder:  int   10h
	                inc   cx
	                cmp   cx,tileEndX
	                jl    drawBotBorder

	                

	                popf
	                popa
	                ret
drawTile endp
end