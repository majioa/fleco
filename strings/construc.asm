;[]-----------------------------------------------------------------[]
;|   CONSTRUC.ASM -- string constructors			     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1.1.1 $
;
;
;AnsiString& __fastcall operator =(const AnsiString& rhs);
;static AnsiString __fastcall StringOfChar(char ch, int count);

	%include 'constant.inc'


	EXTERN	@FastString@Unique$qqrv

	PUBLIC	@FastString@$bctr$qqrv
	PUBLIC	@FastString@$bctr$qqrxo
	PUBLIC	@FastString@$bctr$qqrxc
	PUBLIC	@FastString@$bctr$qqrxuc
	PUBLIC	@FastString@$bctr$qqrxs
	PUBLIC	@FastString@$bctr$qqrxus
	PUBLIC	@FastString@$bctr$qqrxi
	PUBLIC	@FastString@$bctr$qqrxl
	PUBLIC	@FastString@$bctr$qqrxui
	PUBLIC	@FastString@$bctr$qqrxul
	PUBLIC	@FastString@$bctr$qqrxj
	PUBLIC	@FastString@$bctr$qqrxuj
	PUBLIC	@FastString@$bctr$qqrxf
	PUBLIC	@FastString@$bctr$qqrxd
	PUBLIC	@FastString@$bctr$qqrxg
	PUBLIC	@FastString@$bctr$qqrpxc
	PUBLIC	@FastString@$bctr$qqrpxb
	PUBLIC	@FastString@$bctr$qqrrx17System@AnsiString
	PUBLIC	@FastString@$bctr$qqrrx17System@WideString
	PUBLIC	@FastString@$bctr$qqrrx11MathVariant
	PUBLIC	@FastString@$bctr$qqrrx10FastString
	PUBLIC	@FastString@$bdtr$qqrv

	PUBLIC	@FastString@$basg$qqrxo
	PUBLIC	@FastString@$basg$qqrxc
	PUBLIC	@FastString@$basg$qqrxuc
	PUBLIC	@FastString@$basg$qqrxs
	PUBLIC	@FastString@$basg$qqrxus
	PUBLIC	@FastString@$basg$qqrxi
	PUBLIC	@FastString@$basg$qqrxl
	PUBLIC	@FastString@$basg$qqrxui
	PUBLIC	@FastString@$basg$qqrxul
	PUBLIC	@FastString@$basg$qqrxj
	PUBLIC	@FastString@$basg$qqrxuj
	PUBLIC	@FastString@$basg$qqrxf
	PUBLIC	@FastString@$basg$qqrxd
	PUBLIC	@FastString@$basg$qqrxg
	PUBLIC	@FastString@$basg$qqrrx17System@AnsiString
	PUBLIC	@FastString@$basg$qqrrx17System@WideString
	PUBLIC	@FastString@$basg$qqrpxc
	PUBLIC	@FastString@$basg$qqrpxb
	PUBLIC	@FastString@$basg$qqrrx11MathVariant
	PUBLIC	@FastString@$basg$qqrrx10FastString

	GLOBAL	CopyString
	GLOBAL	StringRedim

;	 EXTRN	 @Memblock@$bctr$qqrrx8Memblock
;	 EXTRN	 @Memblock@$bctr$qqri
	EXTRN	@Memblock@$bdtr$qqrv
;	 EXTRN	 @Locale@GetSystemCodepage$qqrv
	EXTRN	@Locale@$bctr$qqrv
	EXTRN	@Memblock@Resize$qqrul
	EXTRN	@Memblock@$bctr$qqrul

	section _TEXT


StringRedim	proc	near
	;in
	;ecx: size of buffer
	;eax: this
	;carry flag: force new buffer
	;out
	;eax: new pointer of string buffer
	;ebx: new pointer to begin of system area of string
	;ecx: size of buffer
	;edx: this
	;edi: new pointer of string buffer
	;carry flag: error
	push	eax
	push	ecx
	mov	eax, [eax]
	mov	edx, ecx
	jc	StringDim_new
	or	eax, eax
	jz	StringDim_new
	sub	eax, SIZEOF_FASTSTRING
;	 call	 @Memblock@$bctr$qqrrx8Memblock
;	 lea	 edx, [ebx+FastString.MemBlock - SIZEOF_FASTSTRING]
	call	@Memblock@Resize$qqrul
	jmp	StringRedim_exit
StringDim_new:
	push	eax
	push	eax
	mov	eax, esp
	call	@Memblock@$bctr$qqrul
	pop	ebx
	pop	eax
;	 pop	 dword [ebx+FistString.MemBlock]
;	 mov	 ebx, [eax+MemBlock.Ptr]
	mov	[ebx+FastString.MemBlock], eax
StringRedim_exit:
	pop	ecx
	pop	edx
	jc	StringRedim_error
	mov	eax, ebx
;	 mov	 [eax+FastString.BufferSize], ecx
	lock	inc	dword ptr[ebx+FastString.RefCount]
	add	eax, SIZEOF_FASTSTRING
	mov	[edx], eax
	mov	edi, eax
StringRedim_error:
	ret


;StringDim	proc	near
	;in
	;ecx: size of buffer
	;ebx: this
	;out
	;eax: new pointer of buffer
	;carry flag: error
;	push	edx
;	push	eax
;	push	ecx
;StringDim	endp


@FastString@$bctr$qqrv	proc	near
	mov	dword ptr [eax], 0
	ret


@FastString@$bdtr$qqrv	proc	near
StringFree:
	;in
	;eax: this
	mov	eax, [eax]
	or	eax, eax
	jz	StringFree_exit
	lock	dec	dword ptr[eax-SIZEOF_FASTSTRING+FastString.RefCount]
	jnz	StringFree_exit
	sub	eax, SIZEOF_FASTSTRING
	push	dword ptr[eax+FastString.MemBlock]
	push	eax
	mov	eax, esp
	call	@Memblock@$bdtr$qqrv
	pop	eax
	pop	eax
StringFree_exit:
	ret


Clear	proc	near
	push	eax
	call	StringFree
	pop	eax
	mov	dword ptr[eax], 0
	ret


@FastString@$basg$qqrxo proc	near
	call	Clear
@FastString@$bctr$qqrxo:
	ret


@FastString@$basg$qqrxc proc	near
	;eax: this
	;dl: char
	call	Clear
@FastString@$bctr$qqrxc:
	push	edx
	movsx	edx, byte ptr[esp]
	pop	ecx
	jmp	CreateIntegerNumber


@FastString@$basg$qqrxuc	proc	near
	;eax: this
	;dl: unsigned char
	call	Clear
@FastString@$bctr$qqrxuc:
	and	edx,0ffh
	xor	ecx, ecx
	jmp	Construct_string_from_number


@FastString@$basg$qqrxs proc	near
	;eax: this
	;edx: char
	call	Clear
@FastString@$bctr$qqrxs:
	push	edx
	movsx	edx, word ptr[esp]
	pop	ecx
	jmp	CreateIntegerNumber


@FastString@$basg$qqrxus	proc	near
	;eax: this
	;edx: unsigned char
	call	Clear
@FastString@$bctr$qqrxus:
	and	edx,0ffffh
	xor	ecx, ecx
	jmp	Construct_string_from_number


@FastString@$basg$qqrxi proc	near
@FastString@$basg$qqrxl:
	call	Clear
@FastString@$bctr$qqrxi:
@FastString@$bctr$qqrxl:
	;eax: this
	;edx: char
	mov	ecx, edx
CreateIntegerNumber:
	sar	ecx, 31
	stc
	jmp	Construct_string_from_number
;Ctr_convert:
;	mov	ecx, INT_STRING_LENGTH * SIZEOF_CHAR + SIZEOF_FASTSTRING
;	call	StringDim
;	xchg	edi, [esp]
;	xchg	eax, edi
;	push	edi
;	push	ebx
;	test	dl, SIGN_INT
;	jnz	short	Ctr_convert_plus
;	test	eax, eax
;	jns	short	Ctr_convert_plus
;	neg	eax
;	mov	byte ptr[edi], '-'
;	jmp	short	Ctr_convert_add1
;Ctr_convert_plus:
;	test	dl, FORCE_SIGN
;	jz	Ctr_convert_tostring
;	mov	byte ptr[edi], '+'
;Ctr_convert_add1:
;	inc	edi
;Ctr_convert_tostring:
;	mov	ecx, 10
;	mov	ebx, 1
;Ctr_convert_loop:
;	cmp	eax, ecx
;	jbe	short	Ctr_convert_loop_exit
;	xor	edx, edx
;	div	ecx
;	push	edx
;	inc	ebx
;	jmp	short	Ctr_convert_loop
;Ctr_convert_loop_exit:
;	add	al, '0'
;	stosb
;	dec	ebx
;	jz	Ctr_convert_loop1_exit
;	pop	eax
;	jmp	Ctr_convert_loop_exit
;Ctr_convert_loop1_exit:
;	pop	ebx
;	sub	edi, [esp]
;	pop	eax
;	mov	[eax-SIZEOF_FASTSTRING+FastString.Length], edi
;	pop	edi
;	pop	eax
;	ret

;@FastString@$basg$qqrxl:
	;eax: this
	;edx: char
;	push	eax
;	push	edx
;Asg_int_convert:
;	xor	dl, dl
;Asg_convert1:
;	call	@FastString@Unique$qqrv
;Asg_convert:
;	mov	ecx, INT_STRING_LENGTH * SIZEOF_CHAR + SIZEOF_FASTSTRING
;	call	StringRedim
;	xchg	edi, [esp]
;	xchg	eax, edi
;	push	edi
;	push	ebx
;	test	dl, SIGN_INT
;	jnz	Asg_convert_plus
;	test	eax, eax
;	jns	Asg_convert_plus
;	neg	eax
;	mov	byte ptr[edi], '-'
;	jmp	Asg_convert_add1
;Asg_convert_plus:
;	test	dl, FORCE_SIGN
;	jz	Asg_convert_tostring
;	mov	byte ptr[edi], '+'
;Asg_convert_add1:
;	inc	edi
;Asg_convert_tostring:
;	mov	ecx, 10
;	mov	ebx, 1
;Asg_convert_loop:
;	cmp	eax, ecx
;	jbe	Asg_convert_loop_exit
;	xor	edx, edx
;	div	ecx
;	push	edx
;	inc	ebx
;	jmp	Asg_convert_loop
;Asg_convert_loop_exit:
;	add	al, '0'
;	stosb
;	dec	ebx
;	jz	Asg_convert_loop1_exit
;	pop	eax
;	jmp	Asg_convert_loop_exit
;Asg_convert_loop1_exit:
;	pop	ebx
;	sub	edi, [esp]
;	pop	eax
;	mov	[eax-SIZEOF_FASTSTRING+FastString.Length], edi
;	pop	edi
;	pop	eax
;	ret


@FastString@$basg$qqrxui	proc	near
@FastString@$basg$qqrxul:
;Asg_dword_convert:
	;eax: this
	;edx: unsigned char
	call	Clear
@FastString@$bctr$qqrxui:
@FastString@$bctr$qqrxul:
;Ctr_convert:
	xor	ecx, ecx
	jmp	Construct_string_from_number


@FastString@$basg$qqrxj proc	near
	;eax: this
	;esp[4,8]: qword
	call	Clear
@FastString@$bctr$qqrxj:
	stc
Construct_string_from_qword:
	pop	edx
	pop	ecx
	xchg	[esp], edx
	mov	dword ptr [eax], 0
;	jmp	Construct_string_from_number
;
;	clc
;Assign_qword_to_string:
;	pop	edx
;	pop	ecx
;	xchg	[esp], edx
;Assign_number_to_string:
;	call	@FastString@Unique$qqrv
Construct_string_from_number:
	;in ecx:edx - number
	;c = 0 - signed integer number
	push	ebx
	push	esi
	push	edi
	push	eax
	push	ecx
;	mov	ebx, ecx
	mov	ecx, QWORD_STRING_LENGTH * SIZEOF_CHAR + SIZEOF_FASTSTRING
	pushfd
;	call	StringRedim ;out - eax: pointer
	; StringRedim ;out - eax: pointer
	mov	esi, edx
	call	StringRedim ;out - eax: pointer
	jc	 Assign_StringRedim_error

;	push	eax
;	 push	 ecx
;	mov	eax, [eax]
;	or	eax, eax
;	jz	Assign_StringDim_new
;	sub		eax, SIZEOF_FASTSTRING
;	call	MemoryReAlloc
;	jmp	Assign_StringRedim_exit
;Assign_StringDim_new:
;	call	MemoryAlloc
;Assign_StringRedim_exit:
;	pop		      ecx
;	jc	  Assign_StringRedim_error
;	mov	esi, eax
;	mov	[eax+FastString.BufferSize], ecx
;	add	eax, SIZEOF_FASTSTRING
;	pop	edx
;	mov	[edx], eax
;	mov	edi, eax

	popfd
	pop	 eax
;	xchg	edi, [esp]
;	xchg	eax, edi
	; SignCheck
;	test	ch, SIGN_INT
;	     jnz     SignCheck_plus
	push	edi
	jnc	Assign_SignCheck_plus
	test	eax, eax
	jns	Assign_SignCheck_plus
	not	eax
	not	esi
	add	esi, 1
	adc	eax, 0
	mov	byte ptr[edi], '-'
	jmp	Assign_SignCheck_add1
Assign_SignCheck_plus:
	test	byte ptr[ebx+FastString.Mode], FORCE_SIGN
	jz	Assign_SignCheck_exit
	mov	byte ptr[edi], '+'
Assign_SignCheck_add1:
	inc	edi
Assign_SignCheck_exit:
;	mov	eax, ebx
;	mov	ebx, edx
	xor	ecx, ecx
	call	Asg_convert_loop
	pop	eax
	sub	edi, eax
	mov	[eax-SIZEOF_FASTSTRING+FastString.Length], edi
Assign_exit:
	pop	eax
	pop	edi
	pop	esi
	pop	ebx
	ret
Assign_StringRedim_error:
;	pop	eax
;	pop	edx
	popfd
	pop	ecx
	jmp	Assign_exit


@FastString@$basg$qqrxuj	proc	near
	call	Clear
@FastString@$bctr$qqrxuj:
	clc
	jmp	Construct_string_from_qword


@FastString@$basg$qqrxf proc	near
	call	Clear
@FastString@$bctr$qqrxf:
	mov	ecx, 7
AssignFloat:
	pop	edx
	fld	dword ptr[esp]
	mov	[esp], edx
	mov	dword ptr[eax], 0
	push	eax
	push	ebx
	push	edi
	push	ecx
	mov	ecx, FLOAT_STRING_LENGTH * SIZEOF_CHAR + SIZEOF_FASTSTRING
	call	StringRedim ;out - eax: pointer
	pop	ecx
	jc	AssignFloat_StringRedim_error
;	mov	edi, eax
	push	edi
	call	FloatSignCheck
	call	StdFloatConvert
	pop	eax
	sub	edi, eax
	mov	[eax-SIZEOF_FASTSTRING+FastString.Length], edi
	pop	edi
	pop	ebx
	pop	eax
	ret
AssignFloat_StringRedim_error:
	pop	edi
	pop	ebx
	pop	eax
	ret


@FastString@$basg$qqrxd proc	near
	call	Clear
@FastString@$bctr$qqrxd:
	mov	ecx, 12
	jmp	AssignFloat


@FastString@$basg$qqrxg proc	near
	call	Clear
@FastString@$bctr$qqrxg:
	mov	ecx, 20
	jmp	AssignFloat



GetBufferSizeFromStringLength	proc	near
	cmp	ecx, 20
	ja	Size_greater_20W
	mov	ecx, 20
	ret
Size_greater_20W:
	cmp	ecx, 0ffffh
	ja	Size_greater_64KW
	shr	ecx, 1
	lea	ecx, [ecx+ecx*2]
	ret
Size_greater_64KW:
	cmp	ecx, 7ffffh
	ja	Size_greater_512KW
	sub	ecx, 10000h
	shr	ecx, 4
	neg	ecx
	add	ecx, 8000h
	ret
Size_greater_512KW:
	add	ecx, 400h
	ret


@FastString@$basg$qqrrx17System@AnsiString	proc	near
	call	Clear
@FastString@$bctr$qqrrx17System@AnsiString:
	mov	edx, [edx]
	or	edx, edx
	jnz	@FastString@$bctr$qqrpxc
Create_from_ansistring_empty:
	mov	[eax], ecx
	ret
@FastString@$basg$qqrpxc:
	call	Clear
@FastString@$bctr$qqrpxc:
	push	ebx
	push	esi
	push	edi
	mov	esi, edx
;	mov	ecx, [edx-SIZEOF_INT]
	mov	ecx, -1
	mov	edi, edx
	push	eax
	xor	eax, eax
	repnz	scasb
	pop	eax
	not	ecx
	dec	ecx
	push	ecx
	call	GetBufferSizeFromStringLength
	add	ecx, SIZEOF_FASTSTRING
	stc
	call	StringRedim
	pop	ecx
	mov	[ebx+FastString.Length], ecx
	mov	byte ptr[ebx+FastString.Mode], 0
	call	SetupDefaultCodepage
	jmp	CopyString


@FastString@$basg$qqrrx17System@WideString	proc	near
	call	Clear
@FastString@$bctr$qqrrx17System@WideString:
	mov	edx, [edx]
	or	edx, edx
	jz	Create_from_ansistring_empty
	jmp	@FastString@$bctr$qqrpxb
@FastString@$basg$qqrpxb:
	call	Clear
@FastString@$bctr$qqrpxb:
	push	ebx
	push	esi
	push	edi
	mov	esi, edx
	mov	ecx, -1
;	mov	ecx, [edx - SIZEOF_INT]
	mov	edi, edx
	push	eax
	xor	eax, eax
	repnz	scasw
	pop	eax
	not	ecx
;	shr	ecx, 1
	dec	ecx
	push	ecx
	call	GetBufferSizeFromStringLength
	shl	ecx, 1
	add	ecx, SIZEOF_FASTSTRING
	stc
	call	StringRedim
	pop	ecx
	mov	[ebx + FastString.Length], ecx
	shl	ecx, 1
	mov	byte ptr[ebx + FastString.Mode], 0
;	 mov	 [ebx + FastString.CodePage.Type], WCHARCP
	mov	eax, [ebx + FastString.Locale],
	mov	byte ptr[eax + Locale.CPType], WCHARCP
	jmp	CopyString
	ret


@FastString@$basg$qqrrx11MathVariant	proc	near
	call	Clear
@FastString@$bctr$qqrrx11MathVariant:
	ret


@FastString@$basg$qqrrx10FastString	proc	near
	call	Clear
@FastString@$bctr$qqrrx10FastString:
	mov	ecx, [edx]
	lock	inc	dword ptr[ecx-SIZEOF_FASTSTRING+FastString.RefCount]
	mov	[eax], ecx
	ret


SetupDefaultCodepage	proc	near
	;in
	;ebx: pointer to FastString data
;	;ecx: destructed
	push	ecx
	push	edx
;	 call	 @Locale@GetSystemCodepage$qqrv
	lea	eax, [ebx+FastString.Locale]
	call	@Locale@$bctr$qqrv
;	 mov	 ecx, [ebx+FastString.Locale]
;	 mov	 [eax+Locale.CP], ax
;	 mov	 byte ptr[eax+Locale.CPType], 0
	pop	edx
	pop	ecx
;	mov	[ebx+FastString.CodePage.Page], 1251
;	mov	[ebx+FastString.CodePage.Type], WINANSICP
	ret


Asg_convert_loop	proc	near
	;in
	;eax:esi: number
	;ecx = 0ffh if zero is need to be counted
	;eax, ebx, ecx, edx: destroyed
;Asg_convert_loop_init:
	mov	ebx, 10
Asg_convert_loop1:
	xor	edx, edx
Asg_convert_loop2:
	inc	ch
	cmp	eax, ebx
	jb	Asg_convert_loop_check
	div	ebx
	push	edx
	or	cl, cl
	jz	Asg_convert_loop1
	or	edx, edx
	jnz	Asg_convert_loop_clear_zero
	mov	cl, ch
	jmp	Asg_convert_loop1
Asg_convert_loop_clear_zero:
	mov	cl, 0ffh
	jmp	Asg_convert_loop1
Asg_convert_loop_check:
	test	ecx, ecx
	js	Asg_convert_loop_back
	or	ecx, 80000000h
	mov	edx, eax
	mov	eax, esi
	dec	ch
	jmp	Asg_convert_loop2
Asg_convert_loop_back1:
	mov	al, dl
Asg_convert_loop_back:
	add	al, '0'
	stosb
	dec	ch
	jz	Asg_convert_loop_exit
	pop	eax
	jmp	Asg_convert_loop_back
Asg_convert_loop_exit:
	ret


FloatSignCheck	proc	near
	;in
	;edi: pointer to string buffer
	;ebx: pointer to begin of faststring buffer
	;st0: floating point value
	;out
	;st0: floating point absolute value
	ftst
;	fstsw	ax
	jfge	FloatSignCheck_plus
	fabs
	mov	byte ptr[edi], '-'
	inc	edi
	ret
;	jmp	FloatSignCheck_add1
FloatSignCheck_plus:
	test	byte ptr[ebx+FastString.Mode], FORCE_SIGN
	jz	FloatSignCheck_exit
	mov	byte ptr[edi], '+'
FloatSignCheck_add1:
	inc	edi
FloatSignCheck_exit:
	ret


StdFloatConvert proc	near
	;in
	;edi: pointer to string buffer
	;ecx: number of symbols after floating point
	;st0: floating point absolute value

	fld	st0
	fld	tbyte ptr[float_1e10]
	fcomp	st1
	jfl	ExpFloatConvert
	frndint
	fsub	st1, st0
	sub	esp, 10h
	fistp	qword ptr[esp]
	push	ecx
	fild	dword ptr[esp]
	pop	eax
	xor	ecx, ecx
	fld	tbyte ptr[float_10]
	fyl2x
	fld	st0
	frndint
	fsub	st1,st0
	fxch	st1
	f2xm1
	fld1
	faddp	st1, st0
	fscale
	fxch	st1
	ffree	st0
	fincstp
	fmulp	st1, st0
	fistp	qword ptr[esp+8]
	pop	esi
	pop	eax
	call	Asg_convert_loop
	pop	esi
	pop	ebx
	mov	eax, ebx
	or	eax, esi
	jz	StdFloatConvert_int_value
	call	GetFloatingPointSymbol
	stosb
	mov	eax, ebx
	mov	ecx, 0ffh
	call	Asg_convert_loop
StdFloatConvert_int_value:
	ret


;	fld	tbyte ptr[float_10]
;	fxch	st1
;	fld	st0
;	fincstp
;StdFloatConvert_loop1:
;	fcom	st1
;	jfl	StdFloatConvert_check_zero
;	fprem
;	push	eax
;	inc	dl
;	fistp	dword ptr[esp]
;	fdiv	st6, st0
;	fld	 st6
;	cmp	byte ptr[esp], 0ah
;	jnz	StdFloatConvert_loop1
;	mov	byte ptr[esp], 0
;	 jmp	    StdFloatConvert_loop1
;StdFloatConvert_check_zero:
;	push	eax
;	fistp	dword ptr[esp]
;	inc	dl
;StdFloatConvert_loop1_back:
;	pop	eax
;	add	al, '0'
;	stosb
;	dec	dl
;	jnz	StdFloatConvert_loop1_back
;StdFloatConvert_loop1_back_exit:
;	ffree	st6
;	fxch	st1
;	push	ecx
;	fild	dword ptr[esp]
;	pop	ecx
;	fld	st2
;	fyl2x
;	fld	st0
;	frndint
;	fsub	st1,st0
;	fxch	st1
;	f2xm1
;	fld1
;	faddp	st1, st0
;	fscale
;	fxch	st1
;	ffree	st0
;	fincstp
;	fmulp	st1, st0
;	fld	st0
;	fincstp
;	mov	dh, cl
;StdFloatConvert_loop:
;	fprem
;	push	      eax
;	fistp	dword ptr[esp]
;	fdiv	st6, st0
;	fld	st6
;	cmp	byte ptr[esp], 0ah
;	jnz	StdFloatConvert_loop_next
;	mov	[esp], ch
;StdFloatConvert_loop_next:
;	cmp	dh, cl
;	jnz	StdFloatConvert_loop_check
;	cmp	ch, [esp]
;	jz	StdFloatConvert_loop_check
;	mov	dh, dl
;StdFloatConvert_loop_check:
;	inc	dl
;	cmp	dl, cl
;	jb	StdFloatConvert_loop
;	call	GetFloatingPointSymbol
;	stosb
;StdFloatConvert_loop_back:
;	pop	eax
;	cmp	dh, dl
;	jae	StdFloatConvert_loop_back_next
;	add	al, '0'
;	stosb
;StdFloatConvert_loop_back_next:
;	dec	dl
;	jnz	StdFloatConvert_loop_back
;StdFloatConvert_loop_back_exit:
;	ret


;	fld	tbyte ptr[float_1_5]
;	fld1
;	fscale
;	sub	 esp, 12
;	fst	tbyte ptr[esp]
	fld	st0
	fld	tbyte ptr[float_1e10]
	fcomp	st1
;	fstsw	ax
;	test	ah,20;>=
;	jz	ExpFloatConvert
	jfl	ExpFloatConvert
	xor	edx, edx
	frndint
	fsub	st1, st0
	fld	tbyte ptr[float_10]
	fxch	st1
	fld	st0
	fincstp
StdFloatConvert_loop1:
	fcom	st1
	jfl	StdFloatConvert_check_zero
	fprem
;	fld	tbyte ptr[float_0_1]
;	fmulp		    st1, st0
;	fld	st0
;	frndint
;	fxch	st1
;	fsub	st0, st1
;	fld	tbyte ptr[float_10]
;	fmulp	st1, st0
	push	eax
	inc	dl
	fistp	dword ptr[esp]
	fdiv	st6, st0
	fld	st6
	cmp	byte ptr[esp], 0ah
	jnz	StdFloatConvert_loop1
	mov	byte ptr[esp], 0
	jmp	StdFloatConvert_loop1
StdFloatConvert_check_zero:
;	or	dh, dh
;	jnz	StdFloatConvert_loop1_back
	push	eax
	fistp	dword ptr[esp]
	inc	dl
StdFloatConvert_loop1_back:
	pop	eax
	add	al, '0'
	stosb
	dec	dl
	jnz	StdFloatConvert_loop1_back
StdFloatConvert_loop1_back_exit:
	ffree	st6
	fxch	st1


;	push	ecx
;	fild	dword ptr[esp]
;	pop	ecx
;	fldl2t
;	fmulp	st1
;	fld	st0
;	frndint
;	fsub	st1, st0
;	fxch	st1
;	fld1
;	fscale
;	fscale

	push	ecx
	fild	dword ptr[esp]
	pop	ecx
	fld	st2
	fyl2x
	fld	st0
	frndint
	fsub	st1,st0
	fxch	st1
	f2xm1
	fld1
	faddp	st1, st0
	fscale
	fxch	st1
	ffree	st0
	fincstp
	fmulp	st1, st0
;	fld	tbyte ptr[float_10]
;	fxch	st1
	fld	st0
	fincstp
	mov	dh, cl
StdFloatConvert_loop:
	fprem

;	fld	tbyte ptr[float_0_1]
;	fmulp	st1, st0
;	fld	st0
;	frndint
;	fxch	st1
;	fsub	st0, st1
;	fld	tbyte ptr[float_10]
;	fmulp	st1, st0

	push	eax
	fistp	dword ptr[esp]
	fdiv	st6, st0
	fld	st6
	cmp	byte ptr[esp], 0ah
	jnz	StdFloatConvert_loop_next
	mov	[esp], ch
;StdFloatConvert_loop_not_10:
;	cmp	ch, [esp]
;	jnz	StdFloatConvert_loop_not_zero
;StdFloatConvert_loop_increment_zero_counter:
;	inc	dh
;	jmp	StdFloatConvert_loop_next
;StdFloatConvert_loop_not_zero:
;	xor	dh, dh
StdFloatConvert_loop_next:
	cmp	dh, cl
	jnz	StdFloatConvert_loop_check
	cmp	ch, [esp]
	jz	StdFloatConvert_loop_check
	mov	dh, dl
StdFloatConvert_loop_check:
	inc	dl
	cmp	dl, cl
	jb	StdFloatConvert_loop


;	fld	tbyte ptr[float_0_1]
;	fmulp	st1, st0
;	fdecstp
;	ffree	st0
;	fdecstp
;	ffree	st0
;	fdecstp

	call	GetFloatingPointSymbol
	stosb

StdFloatConvert_loop_back:
	pop	eax
	cmp	dh, dl
	jae	StdFloatConvert_loop_back_next
	add	al, '0'
	stosb
StdFloatConvert_loop_back_next:
	dec	dl
	jnz	StdFloatConvert_loop_back
StdFloatConvert_loop_back_exit:

	ret
;;	sub	esp, 12
;;	fst	tbyte ptr[esp]
;	fld	st0
;	fld	tbyte ptr[float_1e10]
;	fcomp	st1
;;	fstsw	ax
;;	test	ah,20;>=
;;	jz	ExpFloatConvert
;	jfl	ExpFloatConvert
;	xor	edx, edx
;	frndint
;	fsub	st1, st0
;	fxch	st1
;	lea	eax, [edx+ecx*4]
;	sub	esp, eax
;StdFloatConvert_loop:
;	fld	tbyte ptr[float_10]
;	fmulp	st1, st0
;	fld	st0
;	frndint
;	fsub	st1, st0
;	push	eax
;;	fistp	dword ptr[esp]
;	fistp	dword ptr[esp+edx*4]
;	inc	dl
;	cmp	ch, [esp]
;	jz	StdFloatConvert_loop_zero_value
;	xor	dh, dh
;	jmp	StdFloatConvert_loop_check_cond
;StdFloatConvert_loop_zero_value:
;	inc	dh
;StdFloatConvert_loop_check_cond:
;	cmp	dl, cl
;	jb	StdFloatConvert_loop
;	sub	dl, dh
;	xor	dh, dh
;;	fld	tbyte ptr[esp]
;	ffree	st0
;	fincstp
;StdFloatConvert_loop1:
;	ftst
;;	fstsw	ax
;;	test	ah, 10
;;	jnz	StdFloatConvert_check_zero
;	jfe	StdFloatConvert_check_zero
;	fld	tbyte ptr[float_0_1]
;	fmulp	st1, st0
;	fld	st0
;	frndint
;	fxch	st1
;	fsub	st0, st1
;	fld	tbyte ptr[float_10]
;	fmulp	st1, st0
;	push	eax
;	inc	dh
;	fistp	dword ptr[esp]
;	jmp	StdFloatConvert_loop1
;StdFloatConvert_check_zero:
;	or	dh, dh
;	jnz	StdFloatConvert_loop_back
;	push	0
;	inc	dh
;StdFloatConvert_loop_back:
;	pop	eax
;	add	al, '0'
;	stosb
;	dec	dh
;	jnz	StdFloatConvert_loop_back
;	or	dl, dl
;	jz	StdFloatConvert_exit
;	call	GetFloatingPointSymbol
;	stosb
;;	xor	eax, eax
;;	sub	cl, dl
;;	mov	al, cl
;;	lea	esp, [esp+eax*4]
;StdFloatConvert_loop_back1:
;	pop	eax
;	add	al, '0'
;	stosb
;	dec	cl
;	dec	dl
;	jnz	StdFloatConvert_loop_back1
;;	add	esp, 12
;StdFloatConvert_exit:
;	lea	esp, [esp+ecx*4]
;	ret


ExpFloatConvert proc	near
	ret


GetFloatingPointSymbol	proc	near
	mov	eax, ','
	ret

CopyString:
	mov	edx, ecx
	shr	ecx, 2
	repz	movsd
	and	edx, 3
	jz	CopyString_exit
	mov	ecx, edx
	repz	movsb
CopyString_exit:
	pop	edi
	pop	esi
	pop	ebx
	ret


	section _DATA

float_1e10:
	db	0,0,0,0,0,0f9h,2,95h,20h,40h
;float_0_1	label	tbyte
;	db	0,0d0h,0cch,0cch,0cch,0cch,0cch,0cch,0fbh,3fh
float_10:
	db	0,0,0,0,0,0,0,0a0h,2,40h
;float_1_5	label	tbyte
;	db	0,0,0,0,0,0,0,0c0h,0ffh,3fh


;end
