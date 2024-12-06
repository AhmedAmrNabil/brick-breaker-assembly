EXTERN drawTile:FAR

.model small
.386

.stack 100h
.data

.code

drawSeparator proc far
	              pusha
	              pushf

	               
	              mov   cx, 160
	              mov   dx,0

	              mov   ah,0ch
	              mov   al,0fh
	print:        int   10h
	              dec   cx
	              int   10h
	              inc   cx
	              inc   dx
	              cmp   dx,200
	              jl    print
					

	              popf
	              popa
	              ret
drawSeparator endp

main proc far
	              mov   ax,@data
	              mov   ds,ax

	; set video mode
	              mov   ah, 0
	              mov   al, 13h
	              int   10h

	              mov   dx,0
	              mov   cl,8
					
	printLoop:    mov   ax,dx
	              div   cl
	              xchg  al,ah
	              call  drawTile
	              inc   dx
	              cmp   dx,48
	              jl    printLoop

	                 
	              mov   dx,0
	printLoop1:   mov   ax,dx
	              div   cl
	              xchg  al,ah
	              add   al,8
	              call  drawTile
	              inc   dx
	              cmp   dx,48
	              jl    printLoop1

	              call  drawSeparator



	l:            jmp   l

main endp

end main