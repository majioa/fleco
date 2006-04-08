;[]-----------------------------------------------------------------[]
;|   CONVERT.ASM -- strings conversion functions		     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.2 $
;
;enum TStringFloatFormat {sffGeneral, sffExponent, sffFixed, sffNumber, sffCurrency };
;static AnsiString __fastcall FloatToStrF(long double value, TStringFloatFormat format, int precision, int digits);
;static AnsiString __fastcall FmtLoadStr(int ident, const TVarRec *args, int size);
;static AnsiString __fastcall Format(const AnsiString& format, const TVarRec *args, int size);
;static AnsiString __fastcall FormatFloat(const AnsiString& format,const long double& value);
;static AnsiString __fastcall IntToHex(int value, int digits);
;AnsiString __fastcall SubString(int index, int count) const;

	%include 'constant.inc'


	section _TEXT

	PUBLIC	@FastString@$oo$xqqrv
	PUBLIC	@FastString@$oc$xqqrv
	PUBLIC	@FastString@$ozc$xqqrv
	PUBLIC	@FastString@$ouc$xqqrv
	PUBLIC	@FastString@$os$xqqrv
	PUBLIC	@FastString@$ous$xqqrv
	PUBLIC	@FastString@$oi$xqqrv
	PUBLIC	@FastString@$ol$xqqrv
	PUBLIC	@FastString@$oui$xqqrv
	PUBLIC	@FastString@$oul$xqqrv
	PUBLIC	@FastString@$oj$xqqrv
	PUBLIC	@FastString@$ouj$xqqrv
	PUBLIC	@FastString@$of$xqqrv
	PUBLIC	@FastString@$od$xqqrv
	PUBLIC	@FastString@$og$xqqrv
	PUBLIC	@FastString@$opv$xqqrv
	PUBLIC	@FastString@$opb$qqrv
	PUBLIC	@FastString@$opc$qqrv
	PUBLIC	@FastString@$o17System@AnsiString$qqrv
	PUBLIC	@FastString@$o17System@WideString$qqrv


	PUBLIC	Floating_point_symbol
	PUBLIC	Positive_sign_symbol
	PUBLIC	Negative_sign_symbol

;	 EXTRN	 @Memblock@$bctr$qqrrx8Memblock

	EXTERN	GetSymbol_table

;	 EXTRN	 decimal_constant

;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------------------------------------------
CheckString	proc	near
	;in
	;ebp: codepage caller
	;esi: input string buffer
	;out
;	;c: error
;	;bl: value type
;	;dl: value sign
;	;ecx: length of string buffer
	;ebp: the same
	;dl,dh: count of numbers
	;esi: pointer
	;output record show
	;0: offset to pointer
	;1: length of words
	;2: base of accounting
	;3: flags: 7,6:sign, 0:overflow

	xor	edx, edx
	push	0a0000h
	push	edx
	mov	edi, ebx
;;	  call	  GetOffsetCP
;	 cmp	 cl, 255
;	 ja	 CheckString_error
	mov	dx, ZERO_FLAG | REQ_BASE_FLAG | LEAD_ZERO_FLAG | DIGIT_FLAG | BASE_FLAG | SEPARATOR_FLAG | SIGN_FLAG
.loop:
	xor	eax, eax
	call	[GetSymbol_table+ebp]
	test	dh, ZERO_FLAG / 256	;если сброшен, то проверка режима ведущего нуля
;	cmp	dh, dh
;	test	dh, dh
	jz	.zero
	xor	dh, dh
;	cmp	dl, 0ffh
;	jnz	.zero
	cmp	al, '0'	;если равен "0", то изменение режима, иначе другое изменение режима
	jnz	.clr_zero
	;если символ равен нулю
	mov	dl, REQ_BASE_FLAG | LEAD_ZERO_FLAG | DIGIT_FLAG | BASE_FLAG | SEPARATOR_FLAG | FLOAT_DOT_FLAG
	jmp	.nnum_inc
.clr_zero:
	;если символ не равен нулю
	mov	dl, DIGIT_FLAG | BASE_FLAG | SEPARATOR_FLAG | SIGN_FLAG | FLOAT_DOT_FLAG  | EXP_FLAG
	jmp	.number
.zero
	test	dl, LEAD_ZERO_FLAG
	jz	.number
	cmp	al, '0'
	jz	.nnum_inc
;	jz	.next
;CheckString_zero_flg:
;	test	ah, ZERO_FLAG
;	test	ah, NUMBER_FLAG
;	jz	CheckString_1
;	cmp	al, '0'
;	jnz	CheckString_1
;	jz	CheckString_next
;	|      ebp, ebp
;	jz	CheckString_next
;	jmp	CheckString_inc_next
.number:
	test	dl, DIGIT_FLAG
	jz	.error
	mov	ebx, offset CheckRange
.number_1:
	cmp	byte ptr [ebx], 0
	jz	.syschars
;	cmp	ch, [ebx]
;	jae	
;	ja	.error	;wrong base of system
	cmp	eax, [ebx+ebp+2]
	jb	.number_2
	cmp	eax, [ebx+ebp+18]
	jbe	.digit_inc
.number_2:
;	and	dx, [ebx+CheckSymbol.Allow]
	add	ebx, 2+4*8
	jmp	.number_1
.digit_inc:
	mov	dx, (LEAD_ZERO_FLAG | ZERO_FLAG | REQ_BASE_FLAG) ^ 0ffffh
	cmp	ch, [ebx]
	jae	.digit_inc_1
	mov	ch, [ebx]
.digit_inc_1:
;	test	byte ptr[esp+3],80h
;	js	.digit_inc_2
	or	byte ptr[esp+3],80h
;.digit_inc_2:
	inc	byte ptr[esp+4]
	jmp	.next
;	cmp	al, '1'
;	jb	CheckString_2
;	cmp	al, '9'
;	ja	CheckString_2
;	mov	edi, esi
;	jmp	CheckString_inc_next
;	jbe	CheckString_inc_next
.syschars:
 ;	 test	 dh, 80h
;	test	dl, BASE_FLAG | REG_BASE_FLAG | SIGN_FLAG
;	jz	CheckString_error
	mov	ebx, offset CheckTable - SIZEOF_CHECKSYMBOL
;;	  push	  ebp
.syschars_1:
	add	ebx, SIZEOF_CHECKSYMBOL
	mov	edi, [ebx]
;	cmp	byte ptr [ebx.Symbol], 0
	or	edi, edi
	jz	.separator
	cmp	eax, [edi+ebp]
	jnz	.syschars_1
	test	dl, [ebx+CheckSymbol.SymType]
;	mov	byte ptr[esp+6], al
	jz	.error
;;	movzx	eax, byte ptr[ebx+CheckSymbol.SymType]
;;	mov	dh, [ebx+CheckSymbol.Value]
;;	mov	byte ptr[esp+eax], dh
	jmp	[ebx+CheckSymbol.Handler]
.exp:
	mov	byte ptr[esp+1], 2
	jmp	.syschars_2

.float:
;	mov	al, [ebx+CheckSymbol.Value]
;	mov	byte ptr[esp+6], al
	mov	byte ptr[esp+1], 1
	jmp	.syschars_2
.sign:
	mov	al, [ebx+CheckSymbol.Value]
	mov	byte ptr[esp+7], al
	jmp	.syschars_2
.base:
	mov	al, [ebx+CheckSymbol.Value]
	mov	byte ptr[esp+6], al
	jmp	.syschars_2
.pre_base:
;	mov	ch, [ebx+CheckSymbol.Value]
	mov	al, [ebx+CheckSymbol.Value]
	mov	byte ptr[esp+6], al
.syschars_2:
;;	mov	dx, 01ffh
;	test	dl, EXP_FLAG | FLOAT_DOT_FLAG;
;	jz	.syschars_3
	
;.syschars_3:
	mov	dx, [ebx+CheckSymbol.Allow]
;	cmp	ch, [ebx+CheckSymbol.Degree]
;	ja	.error
;	mov	ch, [ebx+CheckSymbol.Degree]
;	or	dl, dl
;	jz	.mode_val
;	cmp	dl, [ebx+CheckSymbol.Value]
;	jae	.error
;.mode_val:
;	mov	dl, [ebx+CheckSymbol.Value]
;	and	dh, [ebx+CheckSymbol.Mask]
;.mode_inc:
;	test	byte ptr[esp+6],80h
;	jz	,next_1
;;	and	byte ptr[esp+6],7fh
;	mov	[esp+6], ch			;сохранение степени
;	mov	byte ptr[esp+7], dl
;	or	byte ptr[esp+7], dl
;	pop	ebx
;	push	byte 0
;	inc	ebx
;	push	ebx
;p.next_1:
;	inc	dword ptr[esp+4]
	jmp	.nnum_inc
;	;2: 
;;	  or	  bl, bl
;;	  test	  dl,
;;	  jz	  CheckString_2_2
;;	  jns	  CheckString_2_2
;	 shl	 dword ptr[esp+4], 8
;;	  mov	  bl, 0
;CheckString_2_2:
;;	  inc	  dword ptr[esp]
;;	  pop	  ebp
;;	  inc	  dword ptr[esp+4]
;	|      ah, [ebx.Mask]
;	test	dh, byte ptr[ebx.Mask]
;	jnz	CheckString_error
;	test	byte ptr[ebx.Flags], POSTFIX_FLAG
;	jz	CheckString_2_2
;	|      dh, byte ptr[ebx.Value]
;	 jmp	 CheckString_next
;CheckString_2_2:
;	mov	dl, [ebx.Value]
;	and	ah, [ebx.Flags]
;	jmp	CheckString_next
.separator:
;;	  pop	  ebp
	cmp	dx, 1ffh
	jz	.nnum_inc
	test	dl, SEPARATOR_FLAG
	jz	.error
;	dec	esi
	jmp	.exit
;	dec	bl
;	jnz	CheckString_2_1

;	cmp	al, ah
;	jz	CheckString_float_exit
;	|      ebp, ebp
;	jnz	CheckString_2_1
	;2: 
;	cmp	al, bh
;	jz	CheckString_next
;	cmp	al, bl
;	jnz	CheckString_3
;	|      dl, MINUS_SIGN
;	jmp	CheckString_next
;CheckString_2_1:
;CheckString_3:
;	cmp	al, 'e'
;	jz	CheckString_exp_exit
;	cmp	al, 'E'
;	jz	CheckString_exp_exit
;	cmp	al, 'h'
;	jz	CheckString_hex_exit
	;2: 
;	cmp	al, 'H'
;	jz	CheckString_hex_exit
;	cmp	al, 'q'
;	jz	CheckString_octal_exit
;	cmp	al, 'Q'
;	jz	CheckString_octal_exit
;	cmp	al, 'b'
;	jz	CheckString_bin_exit
;	cmp	al, 'B'
;	jz	CheckString_bin_exit
;	cmp	al, 'x'
;	jz	CheckString_set_hex
;	cmp	al, 'X'
;	jnz	CheckString_error
;CheckString_set_hex:
;	|      dl, HEX_SIGN
;	jmp	CheckString_next
;;	  inc	  dword ptr[esp+4]
;;	  or	  bl, bl;
;;	  js	  CheckString_inc_next_1
;;	  shl	  ebp, 8
;;	  not	  bl;
;;CheckString_inc_next_1:
;;	  inc	  dword ptr [esp]
;;;	   mov	   ch, [ebx+2]??


.nnum_inc:
	test	byte ptr[esp+3],80h
	jns	.nnum_inc_1
	and	byte ptr[esp+3],7fh
	cmp	ch, [esp+6]
	jb	.error
	pop	eax
	xor	ch, ch
	inc	eax
	movsx	ebx, byte [esp+3]
	and	ebx, 0c0000000h
	or	ebx, 0a0000h
	push	ebx
	push	eax
.nnum_inc_1:
	inc	byte ptr[esp+5]


;;	mov	[esp], ebx
.next:
;;	  inc	  dword ptr[esp+4]
;	loop	CheckString_loop
	dec	cl
	jnz	.loop
;	 pop	 eax
;	 push	 ecx
;	 inc	 eax
;	 push	 eax
;;	test	dl, HEX_SIGN
;;	jz	CheckString_exit
;;	mov	dh, HEX_VALUE
.exit:
;	mov	ecx, ebp
;;	  pop	  ecx
;;	  pop	  ecx
;;	  push	  ecx
;	 mov	 ecx, [esp]
;;	  xor	  ebx, ebx
	cmp	ch, [esp+6]
	ja	.error
;	shr	ecx, 8
;	or	ecx, ecx
;	jnz	.patch_degree_val
;	mov	ecx, [decimal_constant]
;.patch_degree_val:
;	mov	ebx, ecx
	pop	ecx
;	pop	ebp;??
;	pop	ebp
;;	  mov	  bl, dl
	cmp	byte ptr[esp], 0
	jnz	.storing
;	test	ecx, ecx
;	js	.storing
	pop	edx
	shr	edx, 8
	and	edx, 0ffh
	dec	ch
;	movzx	edx, byte ptr[esp+1]
	sub	esi, edx
.storing:	
	xor	edx, edx
	mov	dl, ch
;	inc	ecx
	and	ecx, 0ffh
	push	dword ptr[esp+ecx*4+4]
;	xor	dh, dh
;	mov	dword ptr[esp+ecx*4+8], edx
;;;	   mov	   ebp, ecx
	mov	ch, cl
	inc	ch
	dec	esi
;	xchg	ebx, ecx
;;	  pop	  edi
;;	  test	  bl, bl;
;;	  js	  CheckString_clear_break_sym
;;	  shrd	  edi, eax, 8
;;	  shr	  eax, 24
;;	  sub	  esi, eax
;;;.clear_break_sym:
;	mov	ecx, ebp
;	lea	esi, [edi - 1]
;	dec	esi1
;	dec	esi
	pushfd
	or	dword ptr [esp], 400h
	popfd
;	 xor	 ebx, ebx
;;	  mov	  bl, dl
;;	  and	  bl, 80h
;;	  mov	  [esp+7], dl
;;	  pop	  ebx
;;	  pop	  ebp

	ret
.error:
	stc
;	 pop	 ebx
;	 pop	 ebp
;	 pop	 ebx
	pop	ecx
;	pop	ebx
	movzx	ecx, cl
	lea	esp, [esp+ecx*4+4]
	ret
;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------------------------------------------
BinString2Qword:
	;in
	;esi: pointer to string (in backward direction)
	;ecx: string size
	;ebp: sign check
	;out
	;edx:eax: number
	;edi, ecx, ebx: destoryed
	push	ebx
	xor	eax, eax
	xor	ecx, ecx
	xor	ebx, ebx
	xor	edx, edx
	cmp	ecx, 64
	ja	HexString2Qword.error
	push	ecx
.next:
	call	[GetSymbol_table]
	shr	eax, 1
	rcr	edx, 1
	rcr	ebx, 1
	loop	BinString2Qword.next
	pop	ecx
	jmp	HexString2Qword.count_cvts


;	xor	cl, 1111111b
;	shrd	edx, ebx, cl
;	test	 cl, 100000b
;	jz	HexString2Qword_32xcgh
;	xchg	ebx, edx
;HexString2Qword_32xcgh:
;	mov	  eax, ebx
;	jmp	String2Int_sign_fix
;-----------------------------------------------------------------
OctalString2Qword:
	push	ebx
	xor	eax, eax
	xor	ecx, ecx
	xor	ebx, ebx
	xor	edx, edx
	cmp	ecx, 22
	ja	HexString2Qword.error
	push	ecx
.next:
	call	[GetSymbol_table]
	sub	al, '0'
	cmp	edi, 22
	jnz	.signed_digit
	pop	ecx
	cmp	al, 1
	ja	HexString2Qword.error
	shr	eax, 1
	rcr	edx, 1
	rcr	ebx, 1
	jmp	HexString2Qword.count_cvts
.signed_digit:
	shrd	edx, ebx, 3
	ror	eax, 3
	or	edx, eax
	loop	.next
	pop	ecx
	ja	HexString2Qword.error
	lea	ecx, [ecx + ecx * 2]
	jmp	HexString2Qword.count_cvts
;-----------------------------------------------------------------
HexString2Qword:
	;in
	;esi: pointer to string (in backward direction)
	;ecx: string size
	;ebp: sign check
	;out
	;edx:eax: number
	;edi, ecx, ebx: destoryed
	push	ebx
	xor	eax, eax
	xor	ebx, ebx
	xor	edx, edx
	cmp	ecx, 16
	ja	.error
	push	ecx
;HexString2Qword_count_cvts:
.next:
	lodsb
	sub	al, 'A'
	jc	.digit
	sub	al, 'a' - 'A' + 10
	jnc	.write
;	jb	IntToInt64

	add	al, 'a' - 'A' + 10
	jmp	.write
.digit:
	add	al, 'A' - '0'
.write:
	shrd	edx, ebx, 4
	ror	eax, 4
	or	edx, eax
	loop	.next
	pop	ecx
	lea	ecx, [ecx * 4 ]
;HexString2Qword_count_cvts:
.count_cvts:
	xor	cl, 1111111b
	inc	cl
	shrd	edx, ebx, cl
	test	cl, 100000b
	jz	.32xcgh
	xchg	ebx, edx
.32xcgh:
	mov	eax, ebx
	jmp	.sign_fix
;HexString2Qword_error:
.error:
	xor	eax, eax
	xor	edx, edx
	pop	ebx
	ret
.sign_fix:
	ret	;??//??
;-----------------------------------------------------------------
DecString2Qword:
	;in
	;esi: pointer to string (in backward direction)
	;ebx: base
	;ebp: codepage jump
	;al: string size
	;in fmt struct
	;+0: count of pre num
	;+1: count of num
	;+2: base of account
	;+3: flags: 7:sign, 6:overflow
;	out:
;	eax: sign of number


	push	ebx
	push	ecx
	push	edx
	push	edi
	movzx	eax, al
	cmp	al, 20
	jb	.loop5
	sub	al, 20
	;fixing stirng
	sub	esi, eax
	cmp	ebp, 2
	jnz	.unicode
	sub	esi, eax
.unicode:
	mov	ah, al
	mov	al, 20
;	call	FixString
;	xor	ebx, ebx
;	xor	ebp, ebp;Codepage
.loop5:
	push	eax
.loop:
	cmp	byte [esp+2bh], 0
	jnz	.loop_exit
	xor	eax, eax
	call	[ebp+GetSymbol_table]
	sub	al, '0'
	mov	ecx, eax
;	mov	[esp], eax???
	mul	dword ptr[esp+20h]
	add	[esp+18h], eax
	adc	[esp+1ch], edx
	jnc	.calc_2part
	inc	byte [esp+2bh]
.calc_2part:
	mov	eax, ecx
	mul	dword ptr[esp+24h]
;	or	edx, edx
;	jnz	.error
	add	[esp+1ch], eax
	adc	edx, 0
	jz	.calc_base
	mov	[esp+2bh], dl
.calc_base:
;	jc	.error
	mov	eax, ebx
	mul	dword ptr [esp+20h]
;	mov	[esp+24h], eax
	mov	edi, edx
;	jc	.check_error
	push	edx
	xchg	edi, eax
	mov	eax, ebx
	mul	dword ptr[esp+28h]
	mov	[esp+2ah], dl
;	or	edx, edx
;	jnz	.check_error1
	add	[esp], eax
	pop	eax
	jnc	.calc_base2
	inc	byte [esp+2ah]
.calc_base2:
	mov	[esp+24h], eax
	mov	[esp+20h], edi

;	xchg	ebx, edx
;	or	edx, edx
;	 jz	 String2Int_loop
;	jz	.loop_check
;	imul	edx, dword ptr [esp]
;	add	ebx, edx
;.loop_check:
	dec	byte ptr[esp]
;	 jz	 String2Int_loop_exit
	jnz	.loop
.loop_exit:
	pop	eax
	movzx	eax, ah
	mov	cl, [esp+27h]
	mov	ebx, [esp+18h]
	rcl	ebx, 1
	rcl	cl, 1
	rcr	ebx, 1
	mov	[esp+18h], ebx
	mov	[esp+24h], cl
	mov	cl, [esp+26h]
	mov	ebx, [esp+20h]
	rcl	ebx, 1
	rcl	cl, 1
	rcr	ebx, 1
	mov	[esp+20h], ebx
	mov	[esp+25h], cl
;	and	eax, 0ffh
;	or	al, al
	jz	.error
	stc
	jmp	.sign_exit
.error:	
;;	setc	cl
;;	ecx??
;	mov	[esp+0ch], edi
;	mov	[esp+10h], ebp
;	mov	ebx, ecx
;	pop	edx
;	pop	eax
;	 pop	 ebx
;	pop	ebp
.sign_fix:
;	test	ecx, [esp+18h]
;	js	.error1;///??? comp to 0????
;	test	ecx, ecx
;	jns	.sign_exit
;	not	dword ptr[esp+18h]
;IntToInt64;	neg	dword ptr[esp+14h]
;	not	eax
;	inc	eax
;	inc	dword ptr[esp+18h]
;	sbb	dword ptr[esp+18h], -1
;	jns	.error1;///??? comp to 0????
	clc
.sign_exit:
	pop	edi
	pop	edx
	pop	ecx
	pop	ebx
;	push	dword ptr[esp+10h]
	ret
;.check_error1:
;	pop	edx
;.check_error:
;	sbb	byte ptr[esp+18h],0
;	dec	byte ptr[esp]
;	sub	byte ptr[esp],0
;	jz	.loop_exit
;.error:
;	pop	eax
;.error1:
;	stc
;	jmp	.sign_exit
;-----------------------------------------------------------------
VarBasedString2Qword:

;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------------------------------------------

@FastString@$oo$xqqrv	proc	near
	call	@FastString@Converting_int
;IntToBool:
	js	.5
;	or	cl, cl
	jnc	.2
;	setnz	al
;	ret
	or	eax, edx
.2:
	setnz	al
	ret
.5:
	xor	al, al
	ret
;-----------------------------------------------------------------
@FastString@$ozc$xqqrv:
@FastString@$oc$xqqrv	proc	near
;	push	offset ToCharTable
	call	@FastString@Converting_int
;	call	FixFloat
;IntToChar:
	js	.3
.6:
;	or	cl, cl
	jnc	.1
	or	edx, edx
	jnz	.1
	cmp	eax, 7fh
	jbe	.2
.1:
	mov	al, 7fh
.2:
	ret	
.3:
;	or	cl, cl
	jnc	.4
	or	edx, edx
	jnz	.4
.7:
	cmp	eax, -80h
	jae	.5
.4:
	mov	al, 80h
.5:
	neg	al
	ret
@FastString@$ouc$xqqrv:
;	push	offset ToByteTable
	call	@FastString@Converting_int
;IntToByte:
	js	.3
	jnc	.1
;	or	cl, cl
	or	edx, edx
	jz	.2
.1:
	mov	al, 0ffh
	ret
.2:
	cmp	eax, 0ffh
	ja	.1
	ret
.3:
	xor	al, al
	ret
;-----------------------------------------------------------------
@FastString@$os$xqqrv	proc	near
;	push	offset ToShortTable
	call	@FastString@Converting_int
;	call	FixFloat
;IntToShort:
	js	.3
	jnc	.1
;	or	cl, cl
	or	edx, edx
	jnz	.1
.6:
	cmp	eax, 7fffh
	jbe	.2
.1:
	mov	ax, 7fffh
.2:
	ret	
.3:
	jnz	.4
;	or	cl, cl
	or	edx, edx
	jnc	.4
.7:
	cmp	eax, 8000h
	jbe	.5
.4:
	mov	ax, 8000h
.5:
	neg	ax
	ret
;-----------------------------------------------------------------
@FastString@$ous$xqqrv:
;	push	offset ToWordTable
	call	@FastString@Converting_int
;	call	FixFloat
;IntToWord:
	js	.3
	jnc	.1
;	or	cl, cl
	or	edx, edx
	jz	.2
.1:
	mov	ax, 0ffffh
	ret
.2:
	cmp	eax, 0ffffh
	ja	.1
	ret
.3:
	xor	ax, ax
	ret
;-----------------------------------------------------------------
@FastString@$oi$xqqrv:
@FastString@$ol$xqqrv:
	;in
	;eax: this
	;edx: ptr to int64val
	;out
	;eax: integer value
;	push	offset ToIntTable
	call	@FastString@Converting_int
;	jc
	js	.3
	jnc	.1
;	or	cl, cl
	or	edx, edx
	jnz	.1
	test	eax, eax
	jns	.2
.1:
	mov	eax, 7fffffffh
.2:
	ret	
.3:
	jnc	.4
;	or	cl, cl
	or	edx, edx
	jnz	.4
	test	eax, eax
	jns	.5
.4:
	mov	eax, 80000000h
.5:	
	neg	eax
	ret

	
;-----------------------------------------------------------------
;-----------------------------------------------------------------
@FastString@$oui$xqqrv:
@FastString@$oul$xqqrv:
;	push	offset ToDwordTable
	call	@FastString@Converting_int
;	call	FixFloat
;IntToDword:
	js	.1
	jnc	.3
;	or	cl, cl
	or	edx, edx
	jz	.2
.3:
	mov	eax, -1
	ret
.1:
	xor	eax, eax
.2:
	ret
;-----------------------------------------------------------------
@FastString@$oj$xqqrv:
;	push	offset ToInt64Table
	call	@FastString@Converting_int
;	call	FixFloat
;IntToInt64:
;IntegerToInt64:
	js	.2
	jnc	.4
;	or	ch, ch
	test	edx, edx
	jns	.1
.4
	mov	eax, -1
	mov	edx, 7fffffffh
.1:
	ret
.2:
;	or	ch, ch
	jnc	.5
	test	edx, edx
;	jnz	.5
	jns	.3
.5
	xor	eax, eax
	mov	edx, 80000000h
	ret
.3:
	not	edx
	neg	eax
	sbb	edx, -1
	ret
;-----------------------------------------------------------------
@FastString@$ouj$xqqrv:
;	push	offset ToQwordTable
	call	@FastString@Converting_int
;	call	FixFloat

;	call	FixFloat
;IntToQword:
	jns	.1
;	or	ch, ch

	xor	eax, eax
	xor	edx, edx
	ret
.1:
	jc	.2
	mov	eax, -1
	mov	edx, eax
.2:
	ret

;-----------------------------------------------------------------
@FastString@$of$xqqrv:
@FastString@$od$xqqrv:
@FastString@$og$xqqrv:
;	push	offset ToFloatTable
	call	@FastString@Converting_float
FloatToFloat:
IntToFloat:
	;in
	;cl: power
	;ebx: eax: mainnumber
	;ebp: divparting and extnumber
	pushfd

;	shr	ebp, 24
;	push	cl
;	clc
;	jnc	.4
;	stc
;.4:
;	mov	edx, ebx
;	rcl	edx, 1
;	rcl	cl, 1
;	and	edx, 6
;	shr	ebp,8
;	and	ebx, 7fffffffh
;	sub	ebp, 1
;	pushfd
;	jc	.2
;	fld	tword [dwordnum+edx*5]
;	ror	ecx, 8
;	pushfd
	push	edx
	push	eax
	push	edi
	lea	edi, [esp+4]
	call	LoadFloat

;	fild	qword [esp]
;	popfd
	pop	edi
	pop	eax
	pop	edx
;	xor	eax, eax
;	test	cl, cl
	popfd
	jno	.apply_sign
;	fldcw	[fs_def]
;	push	ecx
;	fild	dword [esp]
;	pop	ecx
;	fldl2t
;	fmulp	st1
;	fld	st0
;	frndint
;	fsubr	st1
;	f2xm1
;	fld1
;	faddp	st1
;	fscale
;	fxch	st1
;	ffree	st0
;	fincstp
	faddp	st1
.apply_sign:
;	or	ch, ch
	jc	.apply_power
;	jns	.load_ext_num
;	lea	edi, [esp+8]
;	movzx	ebp, byte [esp+1bh]
;	call	LoadFloat
;	add	edi, 8
;	movzx	ebp, byte [esp+1ah]
;	call	LoadFloat
;	fdivr	st1
	fmulp	st1
;.load_ext_num:
;	jz	.apply_power
;	push	ebp
;	fld	tword [dwordnum]
;	fild	dword [esp]
;	fmulp	st1
;	faddp	st1
;	pop	ebp
.apply_power:
;	or	ecx, ecx
;	jc	.5
;	and	ecx, 0ff000000h
;	popfd
	jns	.3
	fchs
.3:
	ret

;-----------------------------------------------------------------
@FastString@$opv$xqqrv:
	mov	eax, [eax]
	ret
;-----------------------------------------------------------------
@FastString@$opb$qqrv:
	mov	eax, [eax]
	or	eax, eax
	jz	.nullval
	mov	ecx, [eax - SIZEOF_FASTSTRING + FastString.Length]
	or	ecx, ecx
	jz	.nulllen
	
.nulllen:
	mov	eax, ecx
.nullval:
	ret
;-----------------------------------------------------------------
@FastString@$opc$qqrv:
	mov	eax, [eax]
	or	eax, eax
	jz	.nullval
	mov	ecx, [eax - SIZEOF_FASTSTRING + FastString.Length]
	or	ecx, ecx
	jz	.nulllen
.nulllen:
	mov	eax, ecx
.nullval:
	ret
;-----------------------------------------------------------------
@FastString@$o17System@AnsiString$qqrv:
;-----------------------------------------------------------------
@FastString@$o17System@WideString$qqrv:
	nop






@FastString@Converting_float:
	push	byte 1
	jmp	@FastString@Converting
@FastString@Converting_int:
	push	byte 0
@FastString@Converting:
	mov	eax, [eax]
	or	eax, eax
	jz	@FastString@$oi$xqqrv_nullval
	mov	ecx, [eax - SIZEOF_FASTSTRING + FastString.Length]
	or	ecx, ecx
	jz	@FastString@$oi$xqqrv_nulllen
;	push	edx
	push	ebx
	push	esi
	push	edi
	push	ebp
	pushfd
	call	GetSimpleCPCaller
	mov	esi, eax
	call	CheckString
	jc	@FastString@$oi$xqqrv_CheckString_error
	mov	edi, 14h
@FastString@$oi$xqqrv_loop:
	push	0
	push	0
	push	1
	push	0
	push	0
	mov	eax, [esp+edi]
	movzx	ebx, byte ptr[esp+edi+2]
;;	movsx	ebp, byte ptr[esp+edi+3]
;;	and	ebp, 80000000h
	call	[ebx * 4 + String2Qword_table - 8]
;;	jc	@FastString@$oi$xqqrv_cvt_error
;;	or	byte ptr[esp+edi+3], 80h
;;	adc	byte [esp+edi+3], 00h
;	mov	byte [esp+edi], al
	xchg	al, byte ptr[esp+edi+1]
;;@FastString@$oi$xqqrv_cvt_error:
	dec	ch
	jz	@FastString@$oi$xqqrv_loop_exit
;	movzx	eax, byte ptr[esp+edi+1]
	sub	esi, eax
	add	edi, 6*4
	jmp	@FastString@$oi$xqqrv_loop
@FastString@$oi$xqqrv_loop_exit:
;	mov	ebx, [esp + edi + 8]
;	shr	ecx, 8
;	inc	ecx
	mov	ebp, edx
	pop	eax
	pop	edx
	pop	ebx
	pop	ebx
	pop	ebx
;	rol	ebx, 8
;	ror	ebx, 23
;	stc
;	rcr	ebx, 1
;	movzx	edi, cl
;	not	edi
;	shl	edi, 2
;	dec	ecx
	shl	ecx, 3
;	lea	ecx, [ecx*8+12]
	lea	esi, [ecx*3+8]
;	lea	edi, [edi+esi]
;	add	edi, esi
;	movzx	ecx, byte [esp+edi]
	mov	ecx, [esp+esi-8]
;	xor	edi, edi
	or	ebp, ebp
;	jz	PopupInteger
	jz	Conversion
	dec	ebp
	jnz	PopupExponent
;	cmp	dh, 2
;	jb	PopupFloating
	inc	ebp
	jmp	Conversion

;PopupInteger:
;;	lea	esp, [ebp + 8]
;	pop	eax
;	pop	ebx
;	pop	ecx
;	pop	ecx
;	pop	ebp
;	ror	ebp, 23
;	stc
;	rcr	ebp, 1
;;	mov	ebp, ecx
;	test	ecx, ecx
;	pop	ecx
;	xor	esi, esi
;	shr	ecx, 1
;	mov	esi, 4
;	pop	esi
;	pop	esi
;	lea	esp, [esp+16]
;	jmp	Conversion

;PopupIntegerPlus:
;	movzx	esi, dl
;	mov	eax, [esp]
;	mov	edx, [esp+4]
;	mov	ebx, [esp+8]
;	mov	ecx, [esp+0ch]
;	div	ecx
	
;	lea	esp, [esp+8]
;	jmp	Conversion
	
PopupExponent:
;	fild	qword ptr[esp+10h]
;	fild	qword ptr[esp+8]
;	mov	esi, ecx
;	mov	esi, ecx
;	cmp	ecx, 2
;	jz	.divpr_absent
;	inc	edi
;.divpr_absent:
	cmp	esi, 38h
;	adc	ebp, 0
;	cmovnc	ebp, 5*4


	jnc	.5
	xor	ebp, ebp
;	xor	edi, edi
	jmp	.15
.5:
	mov	ebp, 5*4
.15:
;	mov	edi, [esp+esi-16]
	cmp	dword [esp+ebp], 255
	ja	.6	
	cmp	dword [esp+ebp+4], 0
	jnz	.6	
	cmp	byte [esp+ebp+21], 0
	jnz	.6	
;	add	cl, [esp+edi]
	add	ch, [esp+ebp]
	jc	.6
	jmp	Conversion
.6:
	mov	ch, 255
;	mov	ch, 255

;	movzx	esi, byte [esp+17h]
;	movzx	ecx, byte [esp+17h]
		
;	dec	ebx
;	fild	qword ptr[esp+20h]
;	fldl2t
;	fmulp	st1, st0
;	fstsw	ax
;	test	ah, 1000b
;	jz	.1
;	fchs
;.1:
;	fld	st0
;	frndint
;	fsub	st1, st0
;	fxch
;	f2xm1
;	fld1
;	faddp	st1, st0
;	fscale
;	jz	.2
;	fld1
;	fdivrp	st1
;.2:
;;	movzx	eax, dh
;;	sub	esi, eax
;	stc
;	jmp	[edx * 4 + ConvertFromTable]

;PopupFloating:
;	 pushfd
;	 push	 edi@FastString@$oi$xqqrv_storing
;	 mov	 edi, ebp
;	 xor	 ebp, ebp
;	 mov	 eax, [decimal_constant]
;	 call	 IntString2Qword
;	 push	 ebp
;	 push	 edi
;	 fild	 qword ptr[esp]
;	 push	 edx
;	 push	 eax
;	 fild	 qword ptr[esp]

;;;	 and	 edi, 0ffh
;;;	 sub	 esi, edi
;;	 sub	 esi, [esp+16]
;;	 mov	 eax, [decimal_constant]

;;	lea	edi, [esp+20]
;;	shl	ecx, 19
;;	lea	ecx, [ecx*2+ecx+12*65536]
;	mov	esi, 20h
;	inc	ebp
;	movzx	ecx, byte [esp+17h]
;	test	ecx, ecx
;	pop	eax
;	pop	ebx
;	pop	ebp
;	pop	ebp
;	pop	ebp
;;	mov	eax, [esp]
;;	mov	ebx, [esp+4]
;;	mov	ecx, [esp+24h]
;;	lea	eax, [ecx*8]
;;	fild	qword ptr[esp+eax*2+12]
;;	fild	qword ptr[esp+eax*2+4]
;;	fdivrp	st1, st0
;;	or	cl, cl
;;	jnz	.not_zero
;;	fldz
;	jmp	.check
;.not_zero:
;	fild	qword ptr[esp]
;.check
;	shl	ecx, 1	
;	lea	ecx, [ecx*2+ecx+5]
;	lea	esp, [esp+ecx*4]
;	pop	ecx
;	test	ecx, ecx
;	pop	ecx
;;	lea	esp, [esp+ecx]
	
;;;	 dec	 esi
;;;	 movzx	 eax, bl
;;	 sub	 esi, eax
;;	 mov	 ebp, ebx
;;;	 mov	 ebp, [esp+16]
;;	 shr	 ecx, 8
;;	 call	 IntString2Qword
;;	 push	 edx
;;	 push	 eax
;;	 fild	 qword ptr[esp]
;	faddp	st1, st0
;	jns	.6
;	fchs
;.6:
;	fnclex
;	fldcw	[rnddefsets]
;	 add	 esp, 24
;	 pop	 edi
;	 popfd
;	 jnc	 @FastString@$oi$xqqrv_exit
;	 fmulp	 st1, st0
;	 jmp	 @FastString@$oi$xqqrv_exit
Conversion:
;	lea	edx, [edx*4]
	;cl: full power
	;ch: remain power
	;bl: extnum
	xchg	ch, cl
	rol	ecx, 8
	or	cl, bl
	;ecx: sign, full power, rempower, extnum
;	pop	ebx
	mov	ebx, [esp+esi+20]
;	mov	cl, ch
	or	ch, ch
	jz	.nofixpower
	call	[ebx*4+NumberPower]
.nofixpower:
	or	ebp, ebp
	jz	.nofixdiv
	call	[ebx*4+NumberDivision]
;	or	ebx, ebx
;	jnz	.nointegerdiv
;	call	FixDiv
;	jmp	.nofixdiv
;.nointegerdiv:
;	call	LoadDiv
.nofixdiv:
;	or	ebx, ebx
;	jnz	.nointegerpower
;	call	FixPower
;	jmp	.nofixpower
;.nointegerpower:
;	call	LoadPower
;	mov	ebx, ebp
;	mov	cl, bl
;	shl	ecx, 1
;	shr	ebp, 1
	add	esp, esi
;	shl	cl, 1
;	rcr	ecx, 1
;	test	cl, 80h
	
	test	cl, 7fh
	setz	byte [esp]
	mov	bl, cl
	and	bl, 80h
	or	[esp], bl
	or	ebp, ebp
	jz	.20
	or	byte[esp+1], 1000b
.20:
;	setnz	ebp
;	shl	ebp, 11
;	or	[esp], ebp
	
;	shrd	ebp, ecx, 1
;	shrd	ecx, ebp, 2
	popfd
;	test	ecx, ecx
	pop	ebp
	pop	edi
	pop	esi
	pop	ebx
;	pop	edx
;	pop	ecx
	lea	esp, [esp+4]
;	add	esp, 4
	ret



newvers:
	mov	ebx, ecx
	xor	ecx, ecx
	cmp	bl, 2	;check number format with exp
	jnz	.flin
	pop	eax
;	movzx	ebx, byte ptr[2]
	movzx	ecx, al
	shr	eax, 8
	movzx	ebp, ah
	;ebx: control word
	call	[ebp * 8 + String2Qword_table - 8]
	jc	.greater_number
	;out: ecx: power
	movzx	eax, al
	sub	esi, eax
	dec	bh
	mov	bl, bh
	dec	bl
	
.flin:
	cmp	byte ptr [esp+10h], 0	;check number with cvt to float formating
	ja	.float_num
	cmp	ecx, 20
	ja	.greater_number
	or	ecx, ecx
	js	.smaller_number
	cmp	bh, 2
	jnz	.intnum
	pop	ebx
	jmp	.calculing
;	mov	ah, [esp+4]
;	pop	eax
;	pop	eax
.intnum:
	xor	ebx, ebx
.calculing:
	pop	eax
	mov	dl, al
	mov	dl, bl
	add	dl, cl
	call	chk
	sub	dl, cl
	call	chk

;jnc	.div_pos	;cmp division
;	xor	dh, dh
;	jmp	.div_cmp
;.div_pos:
;	cmp	dh, 20
;	jbe	.div_cmp
;	mov	dh, 20
;.div_cmp:

;	add	ecx, []
;	jmp	.cnt_num
;.float_num:
;	cmp	ecx, 4090
;	ja	.greater_number
;.flin5:
;	cmp	ecx, -4090
;	jb	.smaller_number
;.cnt_num:
	;in ecx:power the pos is divpos -= power
	;edx: power base and length of natural and div numbers
	;esi: pointer to number string
	;ebx, eax: natural and div numbers chars
;	call	[ebp * 8 + String2Qword_table - 4]
;	call	conversion



.greater_number:
.smaller_number:
.float_num:
	ret

chk:
	jnc	.check_pos	;cmp natural
	mov	dh, dl
	neg	dh
	xor	dl, dl
	jmp	.check_cmp
.check_pos:
	xor	dh, dh
	cmp	dl, 20
	jbe	.check_cmp
	mov	dl, 20
.check_cmp:
	rol	edx, 16
	ret



	push	0
	push	0
	push	1
	push	0
	push	0
	mov	eax, [esp+edi]
	movzx	ebx, byte ptr[esp+edi+2]
;;	movsx	ebp, byte ptr[esp+edi+3]
;;	and	ebp, 80000000h
	call	[ebx * 4 + String2Qword_table - 8]
;;	jc	@FastString@$oi$xqqrv_cvt_error
;;	or	byte ptr[esp+edi+3], 80h
;;	adc	byte [esp+edi+3], 00h
;	mov	byte [esp+edi], al
	xchg	al, byte ptr[esp+edi+1]
;;@FastString@$oi$xqqrv_cvt_error:
	dec	ch
	jz	@FastString@$oi$xqqrv_loop_exit
;	movzx	eax, byte ptr[esp+edi+1]
	sub	esi, eax
	add	edi, 6*4


	mov	ebp, edx
	cmp	ebp, 2
	jnz	.flin
	
.flin:



;	mov	edx, ebx

;	shl	edx, 2
;	add	edx, [esp+4*5+esi]
;	call	[edx]
;@FastString@$oi$xqqrv_FromHex:
;	 call	 HexString2Qword
;	 jmp	 @FastString@$oi$xqqrv_exit
;@FastString@$oi$xqqrv_FromOctal:
;	 call	 OctalString2Qword
;	 jmp	 @FastString@$oi$xqqrv_exit
;@FastString@$oi$xqqrv_FromBinary:
;	 call	 BinString2Qword
@FastString@$oi$xqqrv_FromInt:
@FastString@$oi$xqqrv_exit:
;	pop	ebp
;	pop	edi
;	popfd
;	pop	ebp
;	pop	edi
;	pop	esi
;	pop	ebx
;;	pop	edx
;	pop	ecx
;	ret
@FastString@$oi$xqqrv_CheckString_error:
	xor	eax, eax
	jmp	@FastString@$oi$xqqrv_exit
@FastString@$oi$xqqrv_nulllen:
	xor	eax, eax
@FastString@$oi$xqqrv_nullval:
;ConvertRetFunc:
	ret
LoadPower:
	fldcw	[fs_def]
	push	0
	mov	[esp], ch
;	and	dword [esp], 0ffh
	fild	dword [esp]
	add	esp, 4
	fldl2t
	fmulp	st1
	fld	st0
	frndint
	fsubr	st1
	f2xm1
	fld1
	faddp	st1
	fscale
	fxch	st1
	ffree	st0
	fincstp
;	fmulp	st1
	ret
LoadDiv:
	push	ecx
	lea	edi, [esp+8]
	mov	cl, [esp+1bh]
	call	LoadFloat
	add	edi, 8
;	movzx	ebp, byte [esp+1ah]
	mov	cl, [esp+1ah]
	call	LoadFloat
	fdivp	st1
;	faddp	st1
	pop	ecx
	ret
FixPower:
;	call	LoadPower
;	push	edx
;	push	eax
;	lea	edi, [esp]
;	call	LoadFloat
;	fmulp	st0
;	fistp	qword ptr[esp]
;	push	eax
;	push	edx
;	push	ecx
;	add	byte [esp+2], ch
;	cmp	byte [esp+2], 20
;	ja	.error
;	cmp	byte [esp+2], 20
;	ja	.error
;	shr	ecx, 8
;	movzx	ecx, byte [esp+2]
;	mov	cl, byte [esp+2]
;	shr	ecx, 8
;	mov	ch, cl
	or	ebp, ebp
	jz	.nosub
	cmp	ch, [esp+30h]
	jbe	.nosub
	mov	ch, [esp+30h]
.nosub:
	
;	mov	cl, ch
;	mov	ch, byte [esp+2]
;	and	ecx, 0ffh
;	push	ebx
;	push	edx
;	push	eax
	
;.loop:
;	mov	eax, 10
;	xor	ebx, ebx
;	mov	ebx, 10
;	mul	dword [esp]
;	add	[esp], eax
;	adc	ebx, edx
;	mov	eax, 10
;	mul	dword [esp+4]
;	add	edx, ebx
;	jc	.errorp
;	add	[esp+4], edx
;	jc	.errorp
;	loop	.loop
;	dec	byte [esp+2]
;	jnz	.loop
;	pop	eax
;	pop	edx
;	pop	ebx
	
;	push	ecx
;	push	eax
;	push	edx
	call	num_power
	jc	.error
	or	ebp, ebp
	jz	.nosub5
	add	eax, [esp+4h]
	adc	edx, [esp+8h]
	adc	cl, [esp+14h]
	js	.errorp
	jc	.errorm
.nosub5:
	
;	pop	edx
;	pop	eax
;	pop	ecx
;	or	[esp], cl
;	jmp	.5
;	pop	ecx
	ret
.errorm:
	or	cl, 0ffh
.errorp:
;	add	esp, 8
;	pop	ebx
	
	mov	eax, -1
	mov	edx, eax
	or	cl, 7fh
;.5
;	pop	ecx
.error:
	ret
FixDiv:
	pushfd
;	and	cl, 7fh
;	lea	edi, [esp+8]
	or	ch, ch
	jz	.std_zero_pwr
;	sub	ch, [esp+1bh]
;	sub	ch, [esp+30h]
;	or	ch, [esp+30h]
	jnz	.power_unequal
	adc	eax, [esp+4]
	adc	edx, [esp+8]
	adc	cl, [esp+14h]
	jmp	.exit
.power_unequal:
;	push	eax
;	push	edx
;	push	ecx
	pushfd
;	sub	ch, [esp+1bh]
	mov	bl, [esp+46h]
	jnc	.power_pos
	neg	ch
.power_pos:
;	mov	ch, [esp+1bh]
	;power calculation
	;10^(n0-n)
;	call	power
	;edx, eax: result of power

	;number / 10^(n0-n)
;	push	eax
;	mov	ecx, edx
;;	mov	eax, [esp+12]
;;	xor	edx, edx
;	movzx	edx, byte [esp+36]
;	mov	eax, [esp+32]
;	div	ecx
;	pop	ecx
;	mov	[esp+16], eax
;	mov	eax, [esp+28]
;;	xchg	ecx, eax
;	div	ecx
;	mov	ecx, eax
	;[esp+16]: big num
	;ecx: little num
	;edx: remainder
	popfd
;	ja	.power_greater
	jb	.power_smaller
	;edx, eax: result of power
	;number * 10^(n0-n)
;	or	cl, cl
;	jz	.power_greater_calc
;	cmp	cl, 20
;	or	edx, edx
;	jnz	.power_greater_error
;	cmp	eax, 10
;	ja	.power_greater_error
;	jnz	.power_greater_error
;.power_greater_calc:
;	push	byte 0
;	push	byte 0
;	push	byte 0

	call	num_power
	jc	.error
;	or	[esp], cl
;	pop	ecx
;	add	esp, 8
	popfd
	ret
;	;edx, eax: result of power
;	push	edx
;;	xor	eax, eax
;;	mov	[esp+28], al
;;	mov	[], eax
;;	mov	[], eax
;	mov	ecx, eax
;;	movzx	edx, byte [esp+36]
;;	mov	eax, [esp+32]
;	mov	eax, [esp+24]
;	mul	ecx
;	mov	[esp+32], eax
;	mov	[esp+36], edx
;	mov	eax, [esp+28]
;	mul	ecx
;	add	[esp+36], eax
;	adc	dl, 0
;	mov	[esp+41], dl
;	cmp	byte [esp+41], 7fh
;	ja	.power_greater_error
;	mov	eax, [esp+24]
;;	mul	[esp+16]
;	mul	dword[esp]
;	cmp	edx, 7fh
;	ja	.power_greater_error
;	add	[esp+36], eax
;	adc	[esp+41], dl
;	cmp	byte [esp+41], 7fh
;	ja	.power_greater_error
;	movzx	eax, byte[esp+40]
;;	mul	[esp+16]
;	mul	dword[esp]
;	or	edx, edx
;	jnz	.power_greater_error
;	cmp	eax, 7fh
;	ja	.power_greater_error
;	add	[esp+41], al
;	js	.power_greater_error
;;	cmp	byte [esp+41], 7fh
;;	ja	.power_greater_error
;;	cmp	byte [esp+28], 7fh
;	pop	eax
;	pop	ecx
;	pop	edx
;	pop	eax
;	add	eax, [esp+16]
;	adc	edx, [esp+20]
;	adc	cl, [esp+25]
;	popfd
;	ret
;;	movzx	eax, byte [esp+40]
;;	mul	ecx
;;	or	edx, edx
;;	jnz	.power_greater_error
;;	cmp	eax, 7fh
;;	ja	.power_greater_error

;;	add	[esp+24], eax
;;	adc	[esp+28], dl

;.power_greater_error:
;	pop	eax
;	pop	ecx
;	pop	edx
;	pop	eax
;	popfd
;	mov	eax, -1	
;	mov	edx, eax
;	mov	cl, al
;	ret
.power_greater:
;	cmp	ch, [esp+1bh]
;	mov	ebx, edx
			
.power_smaller:
;	or	ch, ch
;	jz	.std_zero_pwr
	movzx	ecx, ch
	mov	eax, edx
.power_chk_loop:
	xor	edx, edx
	div	ecx; base
	or	eax, eax
	jnz	.power_chk_loop
	cmp	edx, 5
;	jb	.5
;		
;.5:
	cmc
	mov	edx, [esp+16]
	adc	[esp+8], ecx
	adc	[esp+4], edx
	adc	byte [esp], 0
	jmp	.exit
.std_zero_pwr:
	push	eax
	push	edx
	push	ecx
	
	and	cl, 7fh
	mov	eax, [esp+28]
	sub	eax, [esp+20]
	mov	edx, [esp+32]
	sbb	edx, [esp+24]
;	mov	ch, [esp+36]
	sbb	cl, [esp+36]
	sub	eax, [esp+20]
	sbb	edx, [esp+24]
	sbb	cl, [esp+36]
	adc	dword[esp+8], 0
	adc	dword[esp+4], 0
	adc	byte [esp], 0
;	jnc	.notfix
;	add	eax, 1
;	adc	edx, 0
;	adc	cl, 0
;.notfix:
.exit:
.error:
	pop	ecx
	pop	edx
	pop	eax
	popfd
	ret

power:
	;in
	;ch: power
	;ecx24: base
	;out
	;edx,eax: number 10^cl

;	push	ebx
;	shr	ecx, 24
	mov	cl, ch
	rol	ecx, 8
	cmp	cl, 10
	jnz	.nondec
	cmp	ch, 20
	ja	.error
	movzx	ebx, ch
	mov	eax, [dectbl+ebx*4-4]
	cmp	cl, 10
	cmova	edx, [dectbl+ebx*4]
	cmp	cl, 19
	cmova	ecx, [dectbl+ebx*4+4]
	clc
	ret
.nondec:
	push	ecx
	push	0
	push	1
	shr	ecx, 24
	mov	bl, ch
;	mov	cl, bl
;	mov	cl, bl
.loop:
	movzx	eax, cl
	mul	dword[esp]
	mov	[esp], eax
	mov	ebp, edx
;	mov	[esp+4], edx
;	or	ebx, ebx
	cmp	dword[esp+4], 0 
	jz	.next
	movzx	eax, cl
	mul	dword[esp+4]
	add	ebp, eax
.next:
	mov	[esp+4], ebp
	dec	bl
	jnz	.loop
	pop	eax
	pop	edx
	pop	ecx
;	pop	ecx
	ret	
.error:
	stc
	ret
num_power:
	;in
	;cl, edx, eax: number
	;ch - power
	;ecx/16: base
	;out calc num * base ^ power
;	push	ebx
;	push	eax
;	push	edx
;	push	ecx
	pushad
;	shr	ecx, 8
	call	power
	;edx, eax: result of power
;	xor	eax, eax
;	mov	[esp+28], al
;	mov	[], eax
;	mov	[], eax
	
	mov	ebp, edx
	mov	ecx, eax
;	movzx	edx, byte [esp+36]
;	mov	eax, [esp+32]
	mov	eax, [esp+1ch]	;load lesser
	mul	ecx
	mov	edi, eax	;save lesser
	mov	esi, edx	;save middle
	mov	eax, [esp+14h]	;load middle
	mul	ecx
	add	esi, eax	;add to middle
	adc	dl, 0
	mov	bl, dl	;save larger
;	cmp	byte [esp+41], 7fh
	js	.error
	mov	eax, [esp+1ch]	;load lesser
;	mul	[esp+16]
	mul	ebp
	cmp	edx, 7fh
	ja	.error
	add	esi, eax	;add to middle
	adc	bl, dl	;add to larger
	js	.error
;	cmp	byte [esp+41], 7fh
;	ja	.power_greater_error
	movzx	eax, byte[esp+18h]	;load larger
;	mul	[esp+16]
	mul	ebp
	or	edx, edx
	jnz	.error
	cmp	eax, 7fh
	ja	.error
	add	bl, al
	js	.error
;	cmp	byte [esp+41], 7fh
;	ja	.power_greater_error
;	cmp	byte [esp+28], 7fh
;	pop	eax
;	pop	ecx
;	pop	edx
;	pop	eax
	mov	[esp+1ch], edi
	mov	[esp+14h], esi
	or	[esp+18h], bl
	popad
	ret
.error:
	popad
	mov	edx, -1
	mov	eax, edx
	mov	cl, al
	ret
;FloatToBool:
;;	push	1
;	fxam
;	fnstsw	ax
;	ffree	st0
;	fincstp
;	test	ah,2
;	jnz	.1
;	sahf
;	setnz	al
;	ret
;.1:
;	xor	al, al
;	ret
;	call	FixFloat


;FloatToByte:
;	push	0ffh
;	fistp	dword ptr[esp]
;	fnstsw	ax
;	sahf
;;	jns	.stored
;	js	FloatToChar.error
;;	fnclex
;;	ffree	st0
;;	fincstp
;.stored:
;	pop	eax
;	test	eax, eax
;	jns	IntToByte.2
;	xor	eax, eax
;	ret
;

FloatToChar:
;	push	7fh
;	fistp	dword ptr[esp]
;	fnstsw	ax
;	sahf
;	jns	.stored
;.error:
;	fnclex
;;	fcomp	dword ptr[zero_cnts]
;	fxam
;	fnstsw	ax
;	test	ah, 2
;;	sahf
;	pop	eax
;	ffree	st0
;	fincstp
;	jz	.1
;	inc	al
;.1
;	ret
;.stored:
;	pop	eax
;	test	eax, eax
;	js	IntToChar.7
;	jmp	IntToChar.6

;IntToByte:
;	test	ebx, ebx
;	js	.3
;	or	ebx, ebx
;	jz	.2
;.1:
;	mov	al, 07fh
;	ret
;.2:
;	cmp	eax, 07fh
;	ja	.1
;	ret
;	mov	al, 7fh
;	ret
;.3:
;	or	ebx, ebx
;	jz	.2
;	mov	al, 80h
;	ret

FloatToWord:
;	push	0ffffh
;	fistp	dword ptr[esp]
;	fnstsw	ax
;	sahf
;	js	FloatToShort.error
;	pop	eax
;	test	eax, eax
;	jns	IntToWord.2
;	xor	eax, eax
;	ret


FloatToShort:
;	push	7fffh
;	fistp	word ptr[esp]
;	fnstsw	ax
;	sahf
;	jns	.stored
;.error:
;	fnclex	
;	fxam
;	fnstsw	ax
;	test	ah, 2
;;	sahf
;	pop	eax
;	ffree	st0
;	fincstp
;	jz	.1
;	inc	ax
;.1
;	ret
;.stored:
;	pop	eax
;;	test	eax, eax
;;	jns	IntToShort.6
;;	jmp	IntToShort.7
;	ret


FloatToDword:
;	push	0
;	push	7fffffffh
;	fistp	qword ptr[esp]
;	fnstsw	ax
;	sahf
;	js	FloatToInt.error
;	pop	eax
;	pop	ebx
;	test	ebx, ebx
;	jns	IntToDword
;	xor	eax, eax
;	ret


FloatToInt:
;	push	eax
;	push	7fffffffh
;	fistp	dword ptr[esp]
;	fnstsw	ax
;	sahf
;	jns	.stored
;.error:
;	fnclex	
;	fxam
;	fnstsw	ax
;	test	ah, 2
;;	sahf
;	pop	eax
;	pop	ebx
;	ffree	st0
;	fincstp
;	jz	.1
;	inc	eax
;.1
;	ret
;.stored:
;	pop	eax
;	pop	ebx
;	pop	eax
;	pop	ebx
;	ret



FloatToQword:
;	push	-1
;	push	-1
;	fistp	qword ptr[esp]
;	fnstsw	ax
;	sahf
;	jns	.stored
;	fnclex
;	fld	tword ptr[c2_64]
;	fsubp	st1, st0
;	fistp	qword ptr[esp]
;	fstsw	ax
;	sahf
;	jns	.stored
;	pop	eax
;	pop	ebx
;	ret
;.stored:
;	pop	eax
;	pop	ebx
;	test	ebx, ebx
;	jns	IntToQword
;	xor	ebx, ebx
;	mov	eax, ebx



LoadFloat:
	;in
	;cl: extnum
;	shl	dword [edi+4], 1
;	rcl	cl, 1 
;	shr	dword [edi+4], 1
	fild	qword [edi]
;	or	cl, cl
	push	ecx
	and	cl, 7fh
	jz	.sn_overnum_app
	push	0
	mov	[esp], cl
	fld	tword [dwordnum]
	fild	dword [esp]
	fmulp	st1
	faddp	st1
	add	esp, 4
.sn_overnum_app:
	pop	ecx
	ret


FloatToInt64:
;	push	7fffffffh
;	push	-1
;	fistp	qword ptr[esp]
;	fstsw	ax
;	sahf
;	jns	.stored
;	fnclex	
;	fxam
;	fnstsw	ax
;	sahf
;	pop	eax
;	pop	ebx
;	ffree	st0
;	fincstp
;	jb	IntToInt64
;	inc	eax
;	inc	ebx
;	jmp	IntToInt64
;.stored:
;	pop	eax
;	pop	ebx
;	ret
;

GetSimpleCPCaller:
	xor	ebp, ebp
	ret



;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------------------------------------------


	section _DATA


CheckTable:
;	istruc CheckSymbol db  FUNCTION_Symbol,GetPlusSign,0,0 iend
;	istruc CheckSymbol db  FUNCTION_Symbol,GetMinusSign,0,MINUS_SIGN iend
;	istruc CheckSymbol db  FUNCTION_Symbol,GetFloationPointSign,FLOAT_VALUE,0 iend
	istruc CheckSymbol
	dd Symbol_e, CheckString.exp
	db EXP_VALUE, EXP_FLAG, SIGN_FLAG | DIGIT_FLAG
	iend
	istruc CheckSymbol
	dd Symbol_ec, CheckString.exp
	db EXP_VALUE, EXP_FLAG
	dw SIGN_FLAG | DIGIT_FLAG
	iend
	istruc CheckSymbol
	dd Symbol_h, CheckString.base
	db 16, BASE_FLAG, SEPARATOR_FLAG
	iend
	istruc CheckSymbol
	dd Symbol_hc, CheckString.base
	db 16, BASE_FLAG, SEPARATOR_FLAG
	iend
	istruc CheckSymbol
	dd Symbol_x, CheckString.pre_base
	db 16, REQ_BASE_FLAG, DIGIT_FLAG | LEAD_ZERO_FLAG
	iend
	istruc CheckSymbol
	dd Symbol_xc, CheckString.pre_base
	db 16, REQ_BASE_FLAG, DIGIT_FLAG | LEAD_ZERO_FLAG
	iend
	istruc CheckSymbol
	dd Symbol_q, CheckString.base
	db 8, BASE_FLAG, SEPARATOR_FLAG
	iend
	istruc CheckSymbol
	dd Symbol_qc, CheckString.base
	db 8, BASE_FLAG, SEPARATOR_FLAG
	iend
	istruc CheckSymbol
	dd Symbol_b, CheckString.base
	db 2, BASE_FLAG, SEPARATOR_FLAG
	iend
	istruc CheckSymbol
	dd Symbol_bc, CheckString.base
	db 2, BASE_FLAG, SEPARATOR_FLAG
	iend
Floating_point_symbol:
	istruc CheckSymbol
;	dd Symbol_e, CheckString.float
	dd Symbol_es, CheckString.float
	db FLOAT_VALUE, FLOAT_DOT_FLAG, 
	dw DIGIT_FLAG | SEPARATOR_FLAG | EXP_FLAG
	iend
Positive_sign_symbol:
	istruc CheckSymbol
	dd Symbol_ps, CheckString.sign
	db POS_VALUE, SIGN_FLAG
	dw DIGIT_FLAG | BASE_FLAG | FLOAT_DOT_FLAG | ZERO_FLAG | LEAD_ZERO_FLAG
	iend
Negative_sign_symbol:
	istruc CheckSymbol
	dd Symbol_ms, CheckString.sign
	db NEG_VALUE, SIGN_FLAG
	dw DIGIT_FLAG | BASE_FLAG | FLOAT_DOT_FLAG | ZERO_FLAG | LEAD_ZERO_FLAG
	iend
	dd	0

;	 istruc CheckSymbol db		    PARAMETER_Symbol,'E',FLOAT_VALUE,0 iend
;	 istruc CheckSymbol db	PARAMETER_Symbol,'E',FLOAT_VALUE,0 iend
;	istruc CheckSymbol db  PARAMETER_Symbol,'e',FLOAT_VALUE,0 iend
;	istruc CheckSymbol db  PARAMETER_Symbol,'H',HEX_VALUE,0 iend
;	istruc CheckSymbol db  PARAMETER_Symbol,'h',HEX_VALUE,0 iend
;	istruc CheckSymbol db  PARAMETER_Symbol,'X',HEX_VALUE,HEX_SIGN iend
;	istruc CheckSymbol db  PARAMETER_Symbol,'x',HEX_VALUE,HEX_SIGN iend
;	istruc CheckSymbol db  PARAMETER_Symbol,'Q',OCTAL_VALUE,0 iend
;	istruc CheckSymbol db  PARAMETER_Symbol,'q',OCTAL_VALUE,0 iend
;	CheckSymbol	  istruc PARAMETER_Symbol,'B',BIN_VALUE,0 iend
;	CheckSymbol istruc PARAMETER_Symbol,'b',BIN_VALUE,0 iend
;	 db	 0

;Range_0_9_8	  label   byte
;	db	'0', '9'
;Range_0_9_8r	label	byte
;	db	26h, 2fh
;Range_0_9_16	label	word
;	dw	'0', '9'
;Range_0_9_rutf label	dword
;	dd	26h, 2fh
;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------------------------------------------
CheckRange:
	db 10, 0
Range_0_9:	 istruc Symbol
	dd '0',20h,'0',20h
iend
istruc Symbol
	dd '9',29h,'9',29h
iend

	db 16, 10
Range_a_f:	 istruc Symbol
	dd 'a',80h,'a',80h
iend
istruc Symbol
	dd 'f',85h,'f',85h
iend

	db 16, 10
Range_ac_fc:	 istruc Symbol
	dd 'A',0a0h,'A',0a0h
iend
istruc Symbol
	dd 'F',0a5h,'F',0a5h
iend
	db	0

;Range_a_f_8	label	byte
;	db	'a', 'f'
;Range_a_f_8r	label	byte
;	db	80h, 85h
;Range_a_f_16	label	word
;	dw	'a', 'f'
;Range_a_f_rutf label	dword
;	dd	80h, 85h

;Range_ac_fc_8	label	byte
;	db	'A', 'F'
;Range_ac_fc_8r label	byte
;	db	0a0h, 0a5h
;Range_ac_fc_16 label	word
;	dw	'A', 'F'
;Range_ac_fc_rutf	label	dword
;	dd	0a0h, 0a5h

Symbol_e	istruc Symbol
;dd 'e', 084h, 'e', 084h
dd 'p', 084h, 'p', 084h
iend

Symbol_ec	istruc Symbol
dd 'P', 0a4h, 'P', 0a4h
iend

Symbol_h	istruc Symbol
dd 'h', 84h, 'h', 84h
iend

Symbol_hc	istruc Symbol
dd 'H',0a4h,'H',0a4h
iend

Symbol_x	istruc Symbol
dd 'x',84h,'x',84h
iend

Symbol_xc  istruc Symbol
dd 'X',0a4h,'X',0a4h
iend

Symbol_q	istruc Symbol
dd 'q',84h,'q',84h
iend

Symbol_qc	istruc Symbol
dd 'Q',0a4h,'Q',0a4h
iend

Symbol_b	istruc Symbol
dd 'b',81h,'b',81h
iend

Symbol_bc	istruc Symbol
dd 'B',0a1h,'B',0a1h
iend

Symbol_ms	istruc Symbol
dd '-',0a1h,'-',0a1h
iend

Symbol_ps	istruc Symbol
dd '+',0a1h,'+',0a1h
iend

Symbol_es	istruc Symbol
dd ',',0a1h,',',0a1h
iend

;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------------------------------------------
rnddefsets:
	dw	0

;ConvertFromTable:
;	dd	@FastString@$oi$xqqrv_FromInt
;	dd	@FastString@$oi$xqqrv_FromFloat
;	dd	@FastString@$oi$xqqrv_FromExp

;	dd	@FastString@$oi$xqqrv_FromHexПоэтому истина есть процесс, но не предмет или трактовка чего-либо, истина это индивидуальный процесс чистого восприятия без искажений того что есть, непередающийся другому.
;	dd	@FastString@$oi$xqqrv_FromOctal
;	dd	@FastString@$oi$xqqrv_FromBinary


NumberPower:
	dd	FixPower
	dd	LoadPower
NumberDivision:
	dd	FixDiv
	dd	LoadDiv


;ToBoolTable:
;	dd	IntToBool
;	dd	FloatToBool
;ToByteTable:
;	dd	IntToByte
;	dd	FloatToByte
;ToCharTable:
;	dd	IntToChar
;	dd	FloatToChar
;ToWordTable:
;	dd	IntToWord
;	dd	FloatToWord
;ToShortTable:
;	dd	IntToShort
;	dd	FloatToShort
;ToDwordTable:
;	dd	IntToDword
;	dd	FloatToDword
;ToIntTable:
;	dd	IntegerToInt64
;	dd	FloatToInt
;ToQwordTable:
;	dd	IntToQword
;	dd	FloatToQword
;ToInt64Table:
;	dd	IntToInt64
;	dd	FloatToInt64
;ToFloatTable:
;	dd	IntToFloat
;	dd	FloatToFloat


String2Qword_table:
	dd	BinString2Qword
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	OctalString2Qword
	dd	0
	dd	DecString2Qword
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	HexString2Qword
;	 dd	 VarBasedString2Qword
decimal_constant:
dectbl:
	dd	10
	dd	100
	dd	1000
	dd	10000
	dd	100000
	dd	1000000
	dd	10000000
	dd	100000000
	dd	1000000000
	dq	10000000000.
	dq	100000000000.
	dq	1000000000000.
	dq	10000000000000.
	dq	100000000000000.
	dq	1000000000000000.
	dq	10000000000000000.
	dq	100000000000000000.
	dq	1000000000000000000.
	dq	10000000000000000000.
	dq	100000000000000000000.
c2_64	dt	18446744073709551600.
dwordnum:	dt	9223372036854775808.
;dt	18446744073709551600.
;	dt	27670116110564327400.
fs_def	dw	73fh
fs_def2	dw	33fh
