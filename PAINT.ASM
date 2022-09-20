; DPP (Desperate Painting Program) Version 0.2
; Made by Chillingen
; Date: 2019-12-26

[BITS 16]
[ORG 0x0100]

section .data
	; screen_const: equ (80*25)*2
	welcome:        db "~DPP~ @ Welcome! Made by Chillingen",0
	magic0:         db "///David is gay\\\",0
	magic1:         db "///Maciek is a bitch\\\",0
	svd_screen:             times (80*25)*2 db 0    ; allocate space for previous screen state              
section .text
	global _start
_start:
	cli
	cld

	mov dl, 0x41    ; default character
	mov bx, 0xb800  
	mov es, bx      ; segment for text dump
	mov di, 0x0000  ; offset for cursor position
	
	; subroutine to display welcome message on the screen
	; takes no arguments and returns nothing
	call welcome_msg

mainloop:

	; subroutine to get key press and set offset coordinates
	; returns special flag in ax if v is pressed
	call get_key_set_pos
	; paints a character onto the screen after key read
	; takes one argument in ax: special flag
	call paint
	jmp mainloop

; ~~~ Start of subroutine ~~~   
get_key_set_pos:
	; prolouge
	push bp
	mov bp, sp

	; TODO: when adding new feature, ADD KEY BINDING!!
	loc_sub_loop:
		xor ah, ah
		int 0x16
		cmp al, 'x'
		je eof

		cmp al, 'w'
		je loc_case_w
		cmp al, 'a'
		je loc_case_a
		cmp al, 's'
		je loc_case_s
		cmp al, 'd'
		je loc_case_d
		cmp al, 'v'
		je loc_case_v
		cmp al, 'n'
		je loc_case_n
		cmp al, 'm'
		je loc_case_m
		cmp al, 'k'
		je loc_case_k
		cmp al, 'l'
		je loc_case_l
		cmp al, 'q'
		je loc_case_q
		jmp loc_sub_loop

	loc_case_w:
		sub di, 0xa0
		xor ax, ax
		jmp loc_end
	loc_case_a:
		sub di, 0x02
		xor ax, ax
		jmp loc_end
	loc_case_s:
		add di, 0xa0
		xor ax, ax
		jmp loc_end
	loc_case_d:
		add di, 0x02
		xor ax, ax
		jmp loc_end 
	loc_case_v:
		mov ax, 0x0001
		jmp loc_end
	loc_case_n:
		dec dh
		jmp loc_end
	loc_case_m:
		inc dh
		jmp loc_end
	loc_case_k:
		inc dl
		jmp loc_end
	loc_case_l:
		dec dl
		jmp loc_end
	loc_case_q:
		call save_screen
		call select_char
		call load_screen
	loc_end:
		; epilogue
		pop bp
		ret
; ~~~ End of subroutine ~~~

; ~~~ Start of subroutine ~~~
paint:
	push bp
	mov bp, sp

	cmp ax, 0x0001
	je loc_stampmsg

	mov [es:di], dx
	
	pop bp
	ret

	loc_stampmsg:
		xor cx, cx
		xor ax, ax
		int 0x16
		cmp al, '0'
		je loc_case_0
		cmp al, '1'
		je loc_case_1
		jmp loc_stampmsg

	loc_case_0:
		lea bx, [magic0]
		mov si, bx
		jmp loc_stampmsg_loop
	loc_case_1:
		lea bx, [magic1]
		mov si, bx
		jmp loc_stampmsg_loop

	loc_stampmsg_loop:
		lodsb
		cmp al, 0x00
		je loc_stampmsg_end
		mov ah, 0x0d
		; call switchax
		mov [es:di], ax
		add di, 0x02
		add cx, 0x02
		jmp loc_stampmsg_loop
	loc_stampmsg_end:
		sub di, cx
		xor cx, cx

		pop bp
		ret
; ~~~ End of subroutine ~~~

; ~~~ Start of subroutine ~~~
switchax:
	push bp
	mov bp, sp
	
	push dx
	mov dx, ax
	mov al, dh
	mov ah, dl
	pop dx
	
	pop bp
	ret
; ~~~ End of subroutine ~~~

; ~~~ Start of subroutine ~~~
welcome_msg:
	push bp
	mov bp, sp
	
	push dx
	push di
	
	xor di, di
	
	lea bx, [welcome]
	mov si, bx
	
	mov ah, 0x34
	loc_welcome_msg_loop:
		lodsb
		cmp al, 0x00
		je loc_welcome_msg_end
		mov [es:di], ax
		add di, 0x02
		jmp loc_welcome_msg_loop
	
	loc_welcome_msg_end:
		pop di
		pop dx
		
		pop bp
		ret 
; ~~~ End of subroutine ~~~     

; ~~~ Start of subroutine ~~~
save_screen:
	push bp
	mov bp, sp
	
	push dx
	push bx
	push si
	push di
	
	; es:si is x:0 y:0 of screen
	mov bx, 0x0000
	mov si, bx
	lea bx, [svd_screen]
	mov di, bx
	
	loc_save_screen_loop:
		mov dx, [es:si]         ; move from b800:0000 into dx
		add si, 0x02            ; si += 2
		mov [ds:di], dx         ; move into ds:svd_screen dx
		add di, 0x02
		cmp si, 0xfa0
		je loc_save_screen_end
		jmp loc_save_screen_loop
	
	loc_save_screen_end:
		pop di
		pop si
		pop bx
		pop dx
		
		pop bp
		ret

; ~~~ End of subroutine ~~~

; ~~~ Start of subroutine ~~~
select_char:
	push bp
	mov bp, sp
	
	push ax
	push bx
	push si
	push di
	
	mov di, 0x0000
	xor al, al              ; al = 0
	mov ah, 0x0a    ; ax = 0x0a00
	
	loc_show_chars_loop:
		mov [es:di], ax         ; first cell = 00, 2nd = 0a
		add di, 0x02            ; di += 2
		inc al                          ; al++
		cmp al, 0xff            
		jne loc_show_chars_loop
		
	xor di, di
	inc di          ; offset di by 1
	xor cl, cl
	
	loc_select_chars_loop:
		
		xor ax, ax
		int 0x16
		
		mov ah, 0x0a
		
		cmp al, 'a'
		je .case_a
		cmp al, 'd'
		je .case_d
		cmp al, 's'
		je .case_s
		cmp al, 'w'
		je .case_w
		cmp al, 'q'
		je loc_select_char_end
		jmp loc_select_chars_loop
		
		.case_a:
			mov [es:di], ah
			sub di, 0x02
			or ah, 0xd0
			mov [es:di], ah
			dec cl
			jmp loc_select_chars_loop
		.case_d:
			mov [es:di], ah
			add di, 0x02
			or ah, 0xd0
			mov [es:di], ah
			inc cl
			jmp loc_select_chars_loop
		.case_w:
			mov [es:di], ah
			sub di, 0xa0
			or ah, 0xd0
			mov [es:di], ah
			sub cl, 0x50
			jmp loc_select_chars_loop
		.case_s:
			mov [es:di], ah
			add di, 0xa0
			or ah, 0xd0
			mov [es:di], ah
			add cl, 0x50
			jmp loc_select_chars_loop
		
	loc_select_char_end:
		pop di
		pop si
		pop bx
		pop ax
		
		mov dl, cl
		
		pop bp
		ret
		
; ~~~ End of subroutine ~~~

; ~~~ Start of subroutine ~~~
load_screen:
	push bp
	mov bp, sp
	
	push bx
	push dx
	push di
	push si
	
	lea bx, [svd_screen]
	mov si, bx
	mov bx, 0x0000
	mov di, bx
	
	loc_load_screen_loop:
		mov dx, [ds:si]
		add si, 0x02
		mov [es:di], dx
		add di, 0x02
		cmp di, 0xfa0
		je loc_load_screen_end
		jmp loc_load_screen_loop
		
	loc_load_screen_end:
		pop si
		pop di
		pop dx
		pop bx
		
		pop bp
		ret
; ~~~ End of subroutine ~~~
eof:
	mov ax, 0x4c00
	int 0x21
