assume cs:code
code segment
start:
	mov ax,1000h
	mov dh,1
	div dh
	
	mov ax,4c00h
	int 21h
	
code ends
end start