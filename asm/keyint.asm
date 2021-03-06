assume cs:code
data segment
	db 20 dup (0)
data ends
code segment
start:
	;== 安装新的键盘中断==
	mov ax,cs
	mov ds,ax
	mov si,offset int9
	
	mov ax,0
	mov es,ax
	mov di,200h
	
	mov cx,offset int9End - offset int9
	cld
	rep movsb
	
	mov ax,data
	mov ds,ax
	mov ax,0
	mov es,ax
	;保存原键盘中断入口
	mov ax,word ptr es:[9*4]
	mov ds:[0],ax
	mov ax,word ptr es:[9*4+2]
	mov ds:[2],ax
	;设置新中断向量表
	cli
	mov word ptr es:[9*4],200h
	mov word ptr es:[9*4+2],0
	sti
	;=====================

	mov ax,0b800h
	mov es,ax
	mov di,160*12+2*40
	mov ah,'a'
	
show:
	mov es:[di],ah
	inc ah
	cmp ah,'z'
	ja showEnd
	call delay
	jmp show
	
showEnd:
	cli
	;==== 恢复旧的键盘中断====
	mov ax,data
	mov ds,ax
	mov ax,0
	mov es,ax
	mov ax,ds:[0]
	mov word ptr es:[9*4],ax
	mov ax,ds:[2]
	mov word ptr es:[9*4+2],ax
	;=========================
	sti
	
	mov ax,4c00h
	int 21h
	
;===============delay================
delay:
	push ax
	push dx
	
	mov ax,0
	mov dx,1000h
loopSub:
	sub ax,1
	sbb dx,0
	cmp ax,0
	jne loopSub
	cmp dx,0
	jne loopSub
	
	pop dx
	pop ax
ret
;==============delay end=============
;==============int9==================
int9:
	push ax
	in al,60h
	
	;模拟外中断，调用原本中断9的内容
	pushf
	call dword ptr ds:[0]
	
	cmp al,1
	jne ignoreIn
	inc byte ptr es:[di+1]
ignoreIn:
	pop ax
iret
int9End:nop
;==============int9 end==============
code ends
end start