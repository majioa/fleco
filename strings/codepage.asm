;[]-----------------------------------------------------------------[]
;|   CODEPAGE.ASM -- strings conversion functions		     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.2 $
;

	%include 'constant.inc'

	PUBLIC	@FastString@ConvertTo$qqrul
	PUBLIC	@FastString@SetCodePage$qqrul
;	 GLOBAL  GetSymbol
;	 GLOBAL  GetRutfSymbol
;	 GLOBAL  CompareSymbol
;	 GLOBAL  ConvertSymbol

	PUBLIC	GetSymbol_table
	PUBLIC	ConvertSymbol_table


	EXTRN	@Memblock@$bctr$qqrrx8Memblock

	EXTRN	decimal_constant


	section _TEXT


;GetSymbol:
;GetRutfSymbol:
;CompareSymbol:
;ConvertSymbol:

;CheckSymbol	proc	near
;	ret
;CheckSymbol	endp
GetSymbol8	proc	near
	;out
	;eax:	symbol
	lodsb
;	test	al, al
;	js
;	sub	al, '0'
	ret
GetSymbol8_8P:
	lodsb
	ret
GetSymbol8_16:
	lodsb
	ret
GetSymbol8_Rutf:
	lodsb
	ret

GetSymbol8P_8:
GetSymbol8P:
GetSymbol8P_16:
GetSymbol8P_Rutf:
	lodsb
	ret



GetSymbol16	proc	near
	;out
	;eax:	symbol
	lodsw
;	test	ax, ax
;	js
;	sub	al, '0'
	ret
GetSymbol16_8:
	lodsw
	ret
GetSymbol16_8P:
	lodsw
	ret
GetSymbol16_Rutf:
	lodsw
	ret

GetSymbolRutf	proc	near
	;out
	;eax:	symbol
	lodsb
	test	al, al
	jns	GetSymbolRutf_exit
;	  shl	  eax, 8
	ror	eax, 7
	lodsb
	test	al, al
	jns	GetSymbolRutf_exit1
;	shr		  eax, 16
	ror	eax, 7
	lodsw
	ror	  eax, 18
	jmp	GetSymbolRutf_exit
GetSymbolRutf_exit1:
	rol												     eax, 7
GetSymbolRutf_exit:
	ret
GetSymbolRutf_8:
	call	GetSymbolRutf
	ret
GetSymbolRutf_8P:
	call	GetSymbolRutf
	ret
GetSymbolRutf_16:
	call	GetSymbolRutf
	ret



GetCPOffset	proc	near
	;in
	;eax: cp
	;in
	;ebx: cp offset
	test	eax, eax
	js	GetCPOffset_ext
;	 lea	 ebx, RussainCodePages
	mov	ebx, RussainCodePages
	jmp	GetCPOffset_exit
GetCPOffset_ext:

;	 lea	 ebx, ASCIICP
	mov	ebx, ASCIICP
;	 lea	 ebx, RusCP
	mov	ebx, RusCP
GetCPOffset_exit:
	ret


;@FastString@ConvertTo$qqrul:
@FastString@ConvertTo$qqrul	proc	near
@FastString@ChangeCodePage$qqrul:
	;in
	;eax: this
	;edx: codepage
	mov	eax, [eax]
	or	eax, eax
	jz	@FastString@ConvertTo$qqrui_empty
	;simple convert
	push	esi
	push	edi
	mov	esi, eax
	mov	ecx, [eax - SIZEOF_FASTSTRING + FastString.Length]
	lea	edi, [eax - SIZEOF_FASTSTRING]
	xchg	dx, [edi - Locale.CP]
	movzx	eax, word ptr[edi - Locale.CP]
;	movzx	eax, word ptr[eax - SIZEOF_FASTSTRING + FastString.CodePage.Page]
;	mov	word ptr[eax - SIZEOF_FASTSTRING + FastString.CodePage.Page], dx
	xchg	eax, edx
	cmp	eax, edx
	mov	edi, eax
	jz	@FastString@ConvertTo$qqrui_dontcvt
	test	ah, dh
	js	@FastString@ConvertTo$qqrui_utf
	call	Convert8_8
@FastString@ConvertTo$qqrui_dontcvt:
	pop	edi
	pop	esi
@FastString@ConvertTo$qqrui_empty:
	ret
@FastString@ConvertTo$qqrui_utf:
	test	ah, ah
	js	@FastString@ConvertTo$qqrui_ruft
	test	ah, 40h
	jnz	@FastString@ConvertTo$qqrui_uft16
	test	dh, dh
	js	@FastString@ConvertTo$qqrui_to_ruft
	call	Convert8_16
	jmp	@FastString@ConvertTo$qqrui_dontcvt
@FastString@ConvertTo$qqrui_to_ruft:
	call	Convert8_8P
	jmp	@FastString@ConvertTo$qqrui_dontcvt

@FastString@ConvertTo$qqrui_uft16:
	test	dh, dh
	jnz	@FastString@ConvertTo$qqrui_utf16_to_ruft
	call	Convert16_8
	jmp	@FastString@ConvertTo$qqrui_dontcvt
@FastString@ConvertTo$qqrui_utf16_to_ruft:
	call	Convert16_8P
	jmp	@FastString@ConvertTo$qqrui_dontcvt

@FastString@ConvertTo$qqrui_ruft:
	test	dh, 40h
	jnz	@FastString@ConvertTo$qqrui_rutf_to_uft16
	call	Convert8P_8
	jmp	@FastString@ConvertTo$qqrui_dontcvt
@FastString@ConvertTo$qqrui_rutf_to_uft16:
	call					    Convert8P_16
	jmp	@FastString@ConvertTo$qqrui_dontcvt




;@FastString@SetCodePage$qqrul:
@FastString@SetCodePage$qqrul	proc	near
	;in
	;eax: this
	;edx: codepage
	mov	eax, [eax]
	or	eax, eax
	jz	@FastString@SetCodePage$qqrui_empty
	mov	eax, [eax - SIZEOF_FASTSTRING + FastString.Locale]
	mov	word ptr[eax + Locale.CP], dx
@FastString@SetCodePage$qqrui_empty:
	ret


Convert8_8:
	;in
	;eax: input codepage
	;edx: output codepage
	;esi: input string
	;edi: output string
	;ecx: input count
	;out
	;esi: new input string
	;esi: new output string
	;ecx, eax, edx: destroyed
	push	ebx
	push	ebp
	imul	eax, RUSSIAN_CP_COUNT * 4
;	shl	edx, 2
;	lea	esi, [RussianConvertTable8_8 + eax*4 + edx*4]
	mov	ebx, [RussianConvertTable8_8 + edx*4 + eax]
	push	ebx
	xor	eax, eax
	mov	ebp, ecx
Convert8_8_enter:
	lodsb
	mov	ebx, [esp]
	movzx	ecx, byte ptr[ebx]
Convert8_8_a:
;	lodsw
	mov	dx, [ebx+1]
	cmp	al, dl
	jb	Convert8_8_b
	cmp	al, dh
	ja	Convert8_8_b
	sub	al, dl
	mov	al, [ebx+eax+3]
	jmp	Convert8_8_next
Convert8_8_b:
	sub	dh, dl
	shr	edx, 8
	lea	ebx, [ebx+edx+3]
	loop	Convert8_8_a
Convert8_8_next:
	stosb
	dec	ebp
	jnz	Convert8_8_enter
	pop	ebx
	pop	ebp
	pop	ebx
	ret
Convert8_16:
	;eax: input codepage
	lea	esi, [RussianConvertTable8_16 + eax*4]
	ret
Convert8_8P:
Convert16_8:
	;edx: output codepage
	lea	esi, [RussianConvertTable16_8 + edx*4]
	ret
Convert16_8P:
Convert8P_8:
Convert8P_16:



	section _DATA

CpInfo:
CP8	dd	RussainCodePages
CPRUFT	dd	WcharCP
CP16	dd	RutfCP


;ASCIICP CPData  istruc 0 iend
ASCIICP istruc CPData dd 0 iend

;RusCP	 CPData  istruc 4 iend
RusCP	istruc	CPData	4 iend

RussainCodePages:
Cp866	istruc	CPData	dd 0 iend
Cp1251	istruc	CPData	dd 0 iend
Mac	istruc	CPData	dd 0 iend
Koi8r	istruc	CPData	dd 0 iend
Cp8859_5	istruc	CPData	dd 0 iend
Cp10007 istruc	CPData	dd 0 iend
WcharCP istruc	CPData	dd 8 iend
RutfCP	istruc	CPData	dd 0ch iend

RussianConvertTable8_8:
	dd	0, Cp866_Cp1251_tbl, Cp866_Mac_tbl, Cp866_Koi8r_tbl, Cp866_Mac_tbl, Cp866_Cp8859_5_tbl
	dd	Cp1251_Cp866_tbl, 0, Cp1251_Cp10007_tbl, Cp1251_Koi8r_tbl, Cp1251_Mac_tbl, Cp1251_Cp8859_5_tbl
	dd	Cp10007_Cp866_tbl, Cp10007_Cp1251_tbl, 0, Cp10007_Koi8r_tbl, 0, Cp10007_Cp8859_5_tbl
	dd	Koi8r_Cp866_tbl, Koi8r_Cp1251_tbl, Koi8r_Cp10007_tbl, 0, Koi8r_Mac_tbl, Koi8r_Cp8859_5_tbl
	dd	Mac_Cp866_tbl, Mac_Cp1251_tbl, 0, Cp10007_Koi8r_tbl, 0, Cp10007_Cp8859_5_tbl
	dd	Cp8859_5_Cp866_tbl, Cp8859_5_Cp1251_tbl, Cp8859_5_Mac_tbl, Cp8859_5_Koi8r_tbl, Cp8859_5_Mac_tbl, 0
RussianConvertTable8_16:
	dd	Cp866_Utf16_tbl, Cp1251_Utf16_tbl, Cp10007_Utf16_tbl, Koi8r_Utf16_tbl, Mac_Utf16_tbl, Cp8859_5_Utf16_tbl
RussianConvertTable8_8P:
;	dd	Cp866_Cutf_tbl, Cp1251_Cutf_tbl, Cp10007_Cutf_tbl, Koi8r_Cutf_tbl, Mac_Cutf_tbl, Cp8859_5_Cutf_tbl
RussianConvertTable16_8:
	dd	Utf16_Cp866_tbl, Utf16_Cp1251_tbl, Utf16_Cp10007_tbl, Utf16_Koi8r_tbl, Utf16_Mac_tbl, Utf16_Cp8859_5_tbl
RussianConvertTable16_8P:
;	dd	Utf16_Cutf_tbl
RussianConvertTable8P_8:
;	dd	Cutf_Cp866_tbl, Cutf_Cp1251_tbl, Cutf_Cp10007_tbl, Cutf_Koi8r_tbl, Cutf_Mac_tbl, Cutf_Cp8859_5_tbl
RussianConvertTable8P_16:
;	dd	Cutf_Utf16_tbl

;0- iend 1
Cp866_Cp1251_tbl:
	db	5h
	db	80h, 0afh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh
	db	0e0h, 0f8h, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0ffh, 0a8h, 0b8h, 0aah, 0bah, 0afh, 0bfh, 0a1h, 0a2h, 0b0h
	db	0fah, 0fah, 0b7h
	db	0fch, 0fdh, 0b9h, 0a4h
	db	0ffh, 0ffh, 0a0h

;0- iend 2+4
Cp866_Mac_tbl:
	db	4h
	db	0a0h, 0afh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh
	db	0e0h, 0f8h, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0dfh, 0ddh, 0deh, 0b8h, 0b9h, 0bah, 0bbh, 0d8h, 0d9h, 0a1h
	db	0fbh, 0fdh, 0c3h, 0dch, 0ffh
	db	0ffh, 0ffh, 0cah

;0- iend 3
Cp866_Koi8r_tbl:
	db	3h
	db	80h, 0f1h, 0e1h, 0e2h, 0f7h, 0e7h, 0e4h, 0e5h, 0f6h, 0fah, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f2h, 0f3h, 0f4h, 0f5h, 0e6h, 0e8h, 0e3h, 0feh, 0fbh, 0fdh, 0ffh, 0f9h, 0f8h, 0fch, 0e0h, 0f1h, 0c1h, 0c2h, 0d7h, 0c7h, 0c4h, 0c5h, 0d6h, 0dah, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 090h, 091h, 092h, 081h, 087h, 0b2h, 0b4h, 0a7h, 0a6h, 0b5h, 0a1h, 0a8h, 0aeh, 0adh, 0ach, 083h, 084h, 089h, 088h, 086h, 080h, 08ah, 0afh, 0b0h, 0abh, 0a5h, 0bbh, 0b8h, 0b1h, 0a0h, 0beh, 0b9h, 0bah, 0b6h, 0b7h, 0aah, 0a9h, 0a2h, 0a4h, 0bdh, 0bch, 085h, 082h, 08dh, 08ch, 08eh, 08fh, 08bh, 0d2h, 0d3h, 0d4h, 0d5h, 0c6h, 0c8h, 0c3h, 0deh, 0dbh, 0ddh, 0dfh, 0d9h, 0d8h, 0dch, 0c0h, 0d1h, 0b3h, 0a3h
	db	0f8h, 0fbh, 09ch, 095h, 09eh, 096h
	db	0feh, 0ffh, 094h, 09ah

;0- iend 5
Cp866_Cp8859_5_tbl:
	db	5h
	db	080h, 0afh, 0b0h, 0b1h, 0b2h, 0b3h, 0b4h, 0b5h, 0b6h, 0b7h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh, 0bfh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh
	db	0f0h, 0f0h, 0a1h
	db	0f2h, 0f7h, 0a4h, 0f4h, 0a7h, 0f7h, 0aeh, 0feh
	db	0fch, 0fch, 0f0h
	db	0ffh, 0ffh, 0a0h

;1- iend 0
Cp1251_Cp866_tbl:
	db	7h
	db	0a0h, 0a2h, 0ffh, 0f6h, 0f7h
	db	0a4h, 0a4h, 0fdh
	db	0a8h, 0a8h, 0f0h
	db	0aah, 0aah, 0f2h
	db	0afh, 0b0h, 0f4h, 0f8h
	db	0b7h, 0bah, 0fah, 0f1h, 0fch, 0f3h
	db	0bfh, 0ffh, 0f5h, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0a0h, 0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh

;1- iend 2
Cp1251_Cp10007_tbl:
	db	0ch
	db	080h, 081h, 0abh, 0aeh
	db	083h, 086h, 0afh, 0d7h, 0c9h, 0a0h
	db	08ah, 08ah, 0bch
	db	08ch, 09ah, 0beh, 0cdh, 0cbh, 0dah, 0ach, 0d4h, 0d5h, 0d2h, 0d3h, 0a5h, 0d0h, 0d1h, 0aah, 0bdh, 0h
	db	09ch, 0a4h, 0bfh, 0ceh, 0cch, 0dbh, 0cah, 0d8h, 0d9h, 0b7h, 0ffh
	db	0a7h, 0a8h, 0a4h, 0ddh
	db	0aah, 0ach, 0b8h, 0c7h, 0c2h
	db	0aeh, 0b0h, 0a8h, 0bah, 0a1h
	db	0b2h, 0b3h, 0a7h, 0b4h
	db	0b6h, 0b6h, 0a6h
	db	0b8h, 0dfh, 0deh, 0dch, 0b9h, 0c8h, 0c0h, 0c1h, 0cfh, 0bbh, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh
	db	0ffh, 0ffh, 0dfh

;1- iend 3
Cp1251_Koi8r_tbl:
	db	5h
	db	0a0h, 0a0h, 09ah
	db	0a8h, 0a9h, 0b3h, 0bfh
	db	0b0h, 0b0h, 09ch
	db	0b7h, 0b8h, 09eh, 0a3h
	db	0c0h, 0ffh, 0e1h, 0e2h, 0f7h, 0e7h, 0e4h, 0e5h, 0f6h, 0fah, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f2h, 0f3h, 0f4h, 0f5h, 0e6h, 0e8h, 0e3h, 0feh, 0fbh, 0fdh, 0ffh, 0f9h, 0f8h, 0fch, 0e0h, 0f1h, 0c1h, 0c2h, 0d7h, 0c7h, 0c4h, 0c5h, 0d6h, 0dah, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d2h, 0d3h, 0d4h, 0d5h, 0c6h, 0c8h, 0c3h, 0deh, 0dbh, 0ddh, 0dfh, 0d9h, 0d8h, 0dch, 0c0h, 0d1h

;1- iend 4
Cp1251_Mac_tbl:
	db	0eh
	db	080h, 081h, 0abh, 0aeh
	db	083h, 086h, 0afh, 0d7h, 0c9h, 0a0h
	db	088h, 088h, 0ffh
	db	08ah, 08ah, 0bch
	db	08ch, 09ah, 0beh, 0cdh, 0cbh, 0dah, 0ach, 0d4h, 0d5h, 0d2h, 0d3h, 0a5h, 0d0h, 0d1h, 0aah, 0bdh, 0efh
	db	09ch, 0a3h, 0bfh, 0ceh, 0cch, 0dbh, 0cah, 0d8h, 0d9h, 0b7h
	db	0a5h, 0a5h, 0a2h
	db	0a7h, 0a8h, 0a4h, 0ddh
	db	0aah, 0ach, 0b8h, 0c7h, 0c2h
	db	0aeh, 0b0h, 0a8h, 0bah, 0a1h
	db	0b2h, 0b4h, 0a7h, 0b4h, 0b6h
	db	0b6h, 0b6h, 0a6h
	db	0b8h, 0dfh, 0deh, 0dch, 0b9h, 0c8h, 0c0h, 0c1h, 0cfh, 0bbh, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh
	db	0ffh, 0ffh, 0dfh

;1- iend 5
Cp1251_Cp8859_5_tbl:
	db	0dh
	db	080h, 081h, 0a2h, 0a3h
	db	083h, 083h, 0f3h
	db	08ah, 08ah, 0a9h
	db	08ch, 090h, 0aah, 0ach, 0abh, 0afh, 0f2h
	db	09ah, 09ah, 0f9h
	db	09ch, 09fh, 0fah, 0fch, 0fbh, 0ffh
	db	0a1h, 0a3h, 0aeh, 0feh, 0a8h
	db	0a7h, 0a8h, 0fdh, 0a1h
	db	0aah, 0aah, 0a4h
	db	0afh, 0afh, 0a7h
	db	0b2h, 0b3h, 0a6h, 0f6h
	db	0b8h, 0bah, 0f1h, 0f0h, 0f4h
	db	0bch, 0ffh, 0f8h, 0a5h, 0f5h, 0f7h, 0b0h, 0b1h, 0b2h, 0b3h, 0b4h, 0b5h, 0b6h, 0b7h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh, 0bfh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh

;2- iend 0
Cp10007_Cp866_tbl:
	db	6h
	db	0a1h, 0a1h, 0f8h
	db	0b8h, 0bbh, 0f2h, 0f3h, 0f4h, 0f5h
	db	0c3h, 0c3h, 0fbh
	db	0cah, 0cah, 0ffh
	db	0d8h, 0d9h, 0f6h, 0f7h
	db	0dch, 0ffh, 0fch, 0f0h, 0f1h, 0efh, 0a0h, 0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0fdh


;2- iend 1
Cp10007_Cp1251_tbl:
	db	9h
	db	080h, 0a1h, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 086h, 0b0h
	db	0a4h, 0a8h, 0a7h, 095h, 0b6h, 0b2h, 0aeh
	db	0aah, 0ach, 099h, 080h, 090h
	db	0aeh, 0afh, 081h, 083h
	db	0b4h, 0b4h, 0b3h
	db	0b7h, 0c2h, 0a3h, 0aah, 0bah, 0afh, 0bfh, 08ah, 09ah, 08ch, 09ch, 0bch, 0bdh, 0ach
	db	0c7h, 0d5h, 0abh, 0bbh, 085h, 0a0h, 08eh, 09eh, 08dh, 09dh, 0beh, 096h, 098h, 093h, 094h, 091h, 092h
	db	0d7h, 0dfh, 084h, 0a1h, 0a2h, 08fh, 09fh, 0b9h, 0a8h, 0b8h, 0ffh
	db	0ffh, 0ffh, 0a4h

;2+4- iend 3
Cp10007_Koi8r_tbl:
	db	9h
	db	080h, 09fh, 0e1h, 0e2h, 0f7h, 0e7h, 0e4h, 0e5h, 0f6h, 0fah, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f2h, 0f3h, 0f4h, 0f5h, 0e6h, 0e8h, 0e3h, 0feh, 0fbh, 0fdh, 0ffh, 0f9h, 0f8h, 0fch, 0e0h, 0f1h
	db	0a1h, 0a1h, 09ch
	db	0a9h, 0a9h, 0bfh
	db	0b2h, 0b3h, 098h, 099h
	db	0c3h, 0c3h, 096h
	db	0c5h, 0c5h, 097h
	db	0cah, 0cah, 09ah
	db	0d6h, 0d6h, 09fh
	db	0ddh, 0feh, 0b3h, 0a3h, 0d1h, 0c1h, 0c2h, 0d7h, 0c7h, 0c4h, 0c5h, 0d6h, 0dah, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d2h, 0d3h, 0d4h, 0d5h, 0c6h, 0c8h, 0c3h, 0deh, 0dbh, 0ddh, 0dfh, 0d9h, 0d8h, 0dch, 0c0h

;2+4- iend 5
Cp10007_Cp8859_5_tbl:
	db	    9h
	db	080h, 09fh, 0b0h, 0b1h, 0b2h, 0b3h, 0b4h, 0b5h, 0b6h, 0b7h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh, 0bfh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh
	db	0a4h, 0a4h, 0fdh
	db	0a7h, 0a7h, 0a6h
	db	0abh, 0ach, 0a2h, 0f2h
	db	0aeh, 0afh, 0a3h, 0f3h
	db	0b4h, 0b4h, 0f6h
	db	0b7h, 0c1h, 0a8h, 0a4h, 0f4h, 0a7h, 0f7h, 0a9h, 0f9h, 0aah, 0fah, 0f8h, 0a5h
	db	0cah, 0cfh, 0a0h, 0abh, 0fbh, 0ach, 0fch, 0f5h
	db	0d8h, 0feh, 0aeh, 0feh, 0afh, 0ffh, 0f0h, 0a1h, 0f1h, 0efh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh

;3- iend 0
Koi8r_Cp866_tbl:
	db	7h
	db	080h, 092h, 0c4h, 0b3h, 0dah, 0bfh, 0c0h, 0d9h, 0c3h, 0b4h, 0c2h, 0c1h, 0c5h, 0dfh, 0dch, 0dbh, 0ddh, 0deh, 0b0h, 0b1h, 0b2h
	db	094h, 096h, 0feh, 0f9h, 0fbh
	db	09ah, 09ah, 0ffh
	db	09ch, 09ch, 0f8h
	db	09eh, 09eh, 0fah
	db	0a0h, 0beh, 0cdh, 0bah, 0d5h, 0f1h, 0d6h, 0c9h, 0b8h, 0b7h, 0bbh, 0d4h, 0d3h, 0c8h, 0beh, 0bdh, 0bch, 0c6h, 0c7h, 0cch, 0b5h, 0f0h, 0b6h, 0b9h, 0d1h, 0d2h, 0cbh, 0cfh, 0d0h, 0cah, 0d8h, 0d7h, 0ceh
	db	0c0h, 0ffh, 0eeh, 0a0h, 0a1h, 0e6h, 0a4h, 0a5h, 0e4h, 0a3h, 0e5h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0efh, 0e0h, 0e1h, 0e2h, 0e3h, 0a6h, 0a2h, 0ech, 0ebh, 0a7h, 0e8h, 0edh, 0e9h, 0e7h, 0eah, 09eh, 080h, 081h, 096h, 084h, 085h, 094h, 083h, 095h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 09fh, 090h, 091h, 092h, 093h, 086h, 082h, 09ch, 09bh, 087h, 098h, 09dh, 099h, 097h, 09ah

;3- iend 1
Koi8r_Cp1251_tbl:
	db	6h
	db	09ah, 09ah, 0a0h
	db	09ch, 09ch, 0b0h
	db	09eh, 09eh, 0b7h
	db	0a3h, 0a3h, 0b8h
	db	0b3h, 0b3h, 0a8h
	db	0bfh, 0ffh, 0a9h, 0feh, 0e0h, 0e1h, 0f6h, 0e4h, 0e5h, 0f4h, 0e3h, 0f5h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0ffh, 0f0h, 0f1h, 0f2h, 0f3h, 0e6h, 0e2h, 0fch, 0fbh, 0e7h, 0f8h, 0fdh, 0f9h, 0f7h, 0fah, 0deh, 0c0h, 0c1h, 0d6h, 0c4h, 0c5h, 0d4h, 0c3h, 0d5h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0dfh, 0d0h, 0d1h, 0d2h, 0d3h, 0c6h, 0c2h, 0dch, 0dbh, 0c7h, 0d8h, 0ddh, 0d9h, 0d7h, 0dah

;3- iend 2
Koi8r_Cp10007_tbl:
	db	6h
	db	096h, 09ah, 0c3h, 0c5h, 0b2h, 0b3h, 0cah
	db	09ch, 09ch, 0a1h
	db	09fh, 09fh, 0d6h
	db	0a3h, 0a3h, 0deh
	db	0b3h, 0b3h, 0ddh
	db	0bfh, 0ffh, 0a9h, 0feh, 0e0h, 0e1h, 0f6h, 0e4h, 0e5h, 0f4h, 0e3h, 0f5h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0dfh, 0f0h, 0f1h, 0f2h, 0f3h, 0e6h, 0e2h, 0fch, 0fbh, 0e7h, 0f8h, 0fdh, 0f9h, 0f7h, 0fah, 09eh, 080h, 081h, 096h, 084h, 085h, 094h, 083h, 095h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 09fh, 090h, 091h, 092h, 093h, 086h, 082h, 09ch, 09bh, 087h, 098h, 09dh, 099h, 097h, 09ah

;3- iend 4
Koi8r_Mac_tbl:
	db	6h
	db	096h, 09ah, 0c3h, 0c5h, 0b2h, 0b3h, 0cah
	db	09ch, 09ch, 0a1h
	db	09fh, 09fh, 0d6h
	db	0a3h, 0a3h, 0deh
	db	0b3h, 0b3h, 0ddh
	db	0bfh, 0ffh, 0a9h, 0feh, 0e0h, 0e1h, 0f6h, 0e4h, 0e5h, 0f4h, 0e3h, 0f5h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0dfh, 0f0h, 0f1h, 0f2h, 0f3h, 0e6h, 0e2h, 0fch, 0fbh, 0e7h, 0f8h, 0fdh, 0f9h, 0f7h, 0fah, 09eh, 080h, 081h, 096h, 084h, 085h, 094h, 083h, 095h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 09fh, 090h, 091h, 092h, 093h, 086h, 082h, 09ch, 09bh, 087h, 098h, 09dh, 099h, 097h, 09ah

;3- iend 5
Koi8r_Cp8859_5_tbl:
	db	5h
	db	09ah, 09ah, 0a0h
	db	0a3h, 0a3h, 0f1h
	db	0b3h, 0b3h, 0a1h
	db	0c0h, 0d5h, 0eeh, 0d0h, 0d1h, 0e6h, 0d4h, 0d5h, 0e4h, 0d3h, 0e5h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0efh, 0e0h, 0e1h, 0e2h, 0e3h
	db	0d7h, 0ffh, 0d2h, 0ech, 0ebh, 0d7h, 0e8h, 0edh, 0e9h, 0e7h, 0eah, 0ceh, 0b0h, 0b1h, 0c6h, 0b4h, 0b5h, 0c4h, 0b3h, 0c5h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh, 0bfh, 0cfh, 0c0h, 0c1h, 0c2h, 0c3h, 0b6h, 0b2h, 0cch, 0cbh, 0b7h, 0c8h, 0cdh, 0c9h, 0c7h, 0cah

;4- iend 0
Mac_Cp866_tbl:
	db	6h
	db	0a1h, 0a1h, 0f8h
	db	0b8h, 0bbh, 0f2h, 0f3h, 0f4h, 0f5h
	db	0c3h, 0c3h, 0fbh
	db	0cah, 0cah, 0ffh
	db	0d8h, 0d9h, 0f6h, 0f7h
	db	0dch, 0feh, 0fch, 0f0h, 0f1h, 0efh, 0a0h, 0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh

;4- iend 1
Mac_Cp1251_tbl:
	db	9h
	db	080h, 0a2h, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 086h, 0b0h, 0a5h
	db	0a4h, 0a8h, 0a7h, 095h, 0b6h, 0b2h, 0aeh
	db	0aah, 0ach, 099h, 080h, 090h
	db	0aeh, 0afh, 081h, 083h
	db	0b4h, 0b4h, 0b3h
	db	0b6h, 0c2h, 0b4h, 0a3h, 0aah, 0bah, 0afh, 0bfh, 08ah, 09ah, 08ch, 09ch, 0bch, 0bdh, 0ach
	db	0c7h, 0d5h, 0abh, 0bbh, 085h, 0a0h, 08eh, 09eh, 08dh, 09dh, 0beh, 096h, 098h, 093h, 094h, 091h, 092h
	db	0d7h, 0dfh, 084h, 0a1h, 0a2h, 08fh, 09fh, 0b9h, 0a8h, 0b8h, 0ffh
	db	0ffh, 0ffh, 088h


;5- iend 0
Cp8859_5_Cp866_tbl:
	db	9h
	db	0a0h, 0a1h, 0ffh, 0f0h
	db	0a4h, 0a4h, 0f2h
	db	0a7h, 0a7h, 0f4h
	db	0aeh, 0aeh, 0f6h
	db	0b0h, 0dfh, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0a0h, 0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh
	db	0f0h, 0f0h, 0fch
	db	0f4h, 0f4h, 0f3h
	db	0f7h, 0f7h, 0f5h
	db	0feh, 0feh, 0f7h

;5- iend 1
Cp8859_5_Cp1251_tbl:
	db	2h
	db	0a1h, 0ach, 0a8h, 080h, 081h, 0aah, 0bdh, 0b2h, 0afh, 0a3h, 08ah, 08ch, 08eh, 08dh
	db	0aeh, 0ffh, 0a1h, 08fh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0ffh, 0b9h, 0b8h, 090h, 083h, 0bah, 0beh, 0b3h, 0bfh, 0bch, 09ah, 09ch, 09eh, 09dh, 0a7h, 0a2h, 09fh

;5- iend 2+4
Cp8859_5_Mac_tbl:
	db	2h
	db	0a0h, 0ach, 0cah, 0ddh, 0abh, 0aeh, 0b8h, 0c1h, 0a7h, 0bah, 0b7h, 0bch, 0beh, 0cbh, 0cdh
	db	0aeh, 0ffh, 0d8h, 0dah, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0dfh, 0dch, 0deh, 0ach, 0afh, 0b9h, 0cfh, 0b4h, 0bbh, 0c0h, 0bdh, 0bfh, 0cch, 0ceh, 0a4h, 0d9h, 0dbh

;5- iend 3
Cp8859_5_Koi8r_tbl:
	db	4h
	db	0a0h, 0a1h, 09ah, 0b3h
	db	0b0h, 0d5h, 0e1h, 0e2h, 0f7h, 0e7h, 0e4h, 0e5h, 0f6h, 0fah, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f2h, 0f3h, 0f4h, 0f5h, 0e6h, 0e8h, 0e3h, 0feh, 0fbh, 0fdh, 0ffh, 0f9h, 0f8h, 0fch, 0e0h, 0f1h, 0c1h, 0c2h, 0d7h, 0c7h, 0c4h, 0c5h
	db	0d7h, 0efh, 0dah, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d2h, 0d3h, 0d4h, 0d5h, 0c6h, 0c8h, 0c3h, 0deh, 0dbh, 0ddh, 0dfh, 0d9h, 0d8h, 0dch, 0c0h, 0d1h
	db	0f1h, 0f1h, 0a3h





;wchar- iend 0
Utf16_Cp866_tbl:
	db	01eh
	dw	0a0h, 0a0h
	db	0ffh
	dw	  0a4h, 0a4h
	db	0fdh
	dw	0b0h, 0b0h
	db	0f8h
	dw	0b7h, 0b7h
	db	0fah
	dw	0401h, 0401h
	db	0f0h
	dw	0404h, 0404h
	db	0f2h
	dw	0407h, 0407h
	db	0f4h
	dw	040eh, 0451h
	db	0f6h, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0a0h, 0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f1h, 0h, 0h
	dw	0454h, 0454h
	db	0f3h
	dw	0457h, 0457h
	db	0f5h
	dw	045eh, 045eh
	db	0f7h
	dw	02116h, 02116h
	db	0fch
	dw	02219h, 0221ah
	db	0f9h, 0fbh
	dw	02500h, 02501h
	db	0c4h, 0b3h
	dw	0250ch, 0250ch
	db	0dah
	dw	02510h, 02510h
	db	0bfh
	dw	02514h, 02514h
	db	0c0h
	dw	02518h, 02518h
	db	0d9h
	dw	0251ch, 0251ch
	db	0c3h
	dw	02524h, 02524h
	db	0b4h
	dw	0252ch, 0252ch
	db	0c2h
	dw	02534h, 02534h
	db	0c1h
	dw	0253ch, 0253ch
	db	0c5h
	dw	02550h, 0256ch
	db	0cdh, 0bah, 0d5h, 0d6h, 0c9h, 0b8h, 0b7h, 0bbh, 0d4h, 0d3h, 0c8h, 0beh, 0bdh, 0bch, 0c6h, 0c7h, 0cch, 0b5h, 0b6h, 0b9h, 0d1h, 0d2h, 0cbh, 0cfh, 0d0h, 0cah, 0d8h, 0d7h, 0ceh
	dw	02580h, 02580h
	db	0dfh
	dw	02584h, 02584h
	db	0dch
	dw	02588h, 02588h
	db	0dbh
	dw	0258ch, 0258ch
	db	0ddh
	dw	02590h, 02593h
	db	0deh, 0b0h, 0b1h, 0b2h
	dw	025a0h, 025a0h
	db	0feh

Utf16_Cp1251_tbl:
;wchar- iend 1
	db	0ch
	dw	00401h, 045fh
	db	0a8h, 080h, 081h, 0aah, 0bdh, 0b2h, 0afh, 0a3h, 08ah, 08ch, 08eh, 08dh, 0a1h, 08fh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0ffh, 0b8h, 090h, 083h, 0bah, 0beh, 0b3h, 0bfh, 0bch, 09ah, 09ch, 09eh, 09dh, 0a2h, 09fh, 0h, 0h, 0h
	dw	0490h, 0491h
	db	0a5h, 0b4h
	dw	02013h, 02014h
	db	096h, 098h
	dw	02018h, 0201ah
	db	091h, 092h, 082h
	dw	0201ch, 0201eh
	db	093h, 094h, 084h
	dw	02020h, 02022h
	db	086h, 087h, 095h
	dw	02026h, 02026h
	db	085h
	dw	02030h, 02030h
	db	089h
	dw	02039h, 0203ah
	db	08bh, 09bh
	dw	020ach, 020ach
	db	088h
	dw	02116h, 02116h
	db	0b9h
	dw	02122h, 02122h
	db	099h

;wchar- iend 2
Utf16_Cp10007_tbl:
	db	019h
	dw	0a0h, 0a0h
	db	0cah
	dw	0a4h, 0a4h
	db	0ffh
	dw	0a7h, 0a7h
	db	0a4h
	dw	0abh, 0ach
	db	0c7h, 0c2h
	dw	0aeh, 0b0h
	db	0a8h, 0a1h, 084h
	dw	0b6h, 0b6h
	db	0a6h
	dw	0bbh, 0bbh
	db	0c8h
	dw	0f7h, 0f7h
	db	0d6h
	dw	0192h, 0192h
	db	0c4h
	dw	0401h, 045fh
	db	0ddh, 0abh, 0aeh, 0b8h, 0c1h, 0a7h, 0bah, 0b7h, 0bch, 0beh, 0cbh, 0cdh, 0d8h, 0dah, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0dfh, 0deh, 0ach, 0afh, 0b9h, 0cfh, 0b4h, 0bbh, 0c0h, 0bdh, 0bfh, 0cch, 0ceh, 0d9h, 0dbh, 0h, 0h, 0h
	dw	02013h, 02014h
	db	0d0h, 0d1h
	dw	02018h, 02019h
	db	0d4h, 0d5h
	dw	0201ch, 0201eh
	db	0d2h, 0d3h, 0d7h
	dw	02020h, 02020h
	db	0a0h
	dw	02022h, 02022h
	db	0a5h
	dw	02026h, 02026h
	db	0c9h
	dw	02116h, 02116h
	db	  0dch
	dw	02122h, 02122h
	db	0aah
	dw	02202h, 02202h
	db	0b6h
	dw	02206h, 02206h
	db	0c6h
	dw	0221ah, 0221ah
	db	0c3h
	dw	0221eh, 0221eh
	db	0b0h
	dw	02248h, 02248h
	db	0c5h
	dw	02260h, 02260h
	db	0adh
	dw	02264h, 02265h
	db	0b2h, 0b3h

;wchar- iend 3
Utf16_Koi8r_tbl:
	db	01dh
	dw	0a0h, 0a0h
	db	09ah
	dw	0a9h, 0a9h
	db	0bfh
	dw	0b0h, 0b0h
	db	09ch
	dw	0b2h, 0b2h
	db	09dh
	dw	0b7h, 0b7h
	db	09eh
	dw	0f7h, 0f7h
	db	09fh
	dw	0401h, 0401h
	db	0b3h
	dw	0410h, 0451h
	db	0e1h, 0e2h, 0f7h, 0e7h, 0e4h, 0e5h, 0f6h, 0fah, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f2h, 0f3h, 0f4h, 0f5h, 0e6h, 0e8h, 0e3h, 0feh, 0fbh, 0fdh, 0ffh, 0f9h, 0f8h, 0fch, 0e0h, 0f1h, 0c1h, 0c2h, 0d7h, 0c7h, 0c4h, 0c5h, 0d6h, 0dah, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d2h, 0d3h, 0d4h, 0d5h, 0c6h, 0c8h, 0c3h, 0deh, 0dbh, 0ddh, 0dfh, 0d9h, 0d8h, 0dch, 0c0h, 0d1h, 0a3h, 0f1h
	dw	02219h, 0221ah
	db	095h, 096h
	dw	02248h, 02248h
	db	097h
	dw	02264h, 02265h
	db	098h, 099h
	dw	02320h, 02321h
	db	093h, 09bh
	dw	02500h, 02502h
	db	080h, 081h, 0d7h
	dw	0250ch, 0250ch
	db	082h
	dw	02510h, 02510h
	db	083h
	dw	02514h, 02514h
	db	084h
	dw	02518h, 02518h
	db	085h
	dw	0251ch, 0251ch
	db	086h
	dw	02524h, 02524h
	db	087h
	dw	0252ch, 0252ch
	db	088h
	dw	02534h, 02534h
	db	089h
	dw	0253ch, 0253ch
	db	08ah
	dw	02550h, 0256ch
	db	0a0h, 0a1h, 0a2h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0b0h, 0b1h, 0b2h, 0b4h, 0b5h, 0b6h, 0b7h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh
	dw	02580h, 02580h
	db	08bh
	dw	02584h, 02584h
	db	08ch
	dw	02588h, 02588h
	db	08dh
	dw	0258ch, 0258ch
	db	08eh
	dw	02590h, 02593h
	db	08fh, 090h, 091h, 092h
	dw	025a0h, 025a0h
	db	094h

;wchar- iend 4
Utf16_Mac_tbl:
	db	019h
	dw	0a0h, 0a0h
	db	0cah
	db	0a7h, 0a7h
	dw	0a4h
	dw	0abh, 0ach
	db	0c7h, 0c2h
	dw	0aeh, 0b0h
	db	0a8h, 0a1h, 082h
	dw	0b6h, 0b6h
	db	0a6h
	dw	0bbh, 0bbh
	db	0c8h
	dw	0f7h, 0f7h
	db	0d6h
	dw	0192h, 0192h
	db	0c4h
	dw	0401h, 045fh
	db	0ddh, 0abh, 0aeh, 0b8h, 0c1h, 0a7h, 0bah, 0b7h, 0bch, 0beh, 0cbh, 0cdh, 0d8h, 0dah, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0dfh, 0deh, 0ach, 0afh, 0b9h, 0cfh, 0b4h, 0bbh, 0c0h, 0bdh, 0bfh, 0cch, 0ceh, 0d9h, 0dbh, 0h, 0h, 0h
	dw	0490h, 0491h
	db	0a2h, 0b6h
	dw	02013h, 02014h
	db	0d0h, 0d1h
	dw	02018h, 02019h
	db	0d4h, 0d5h
	dw	0201ch, 0201eh
	db	0d2h, 0d3h, 0d7h
	dw	02020h, 02020h
	db	0a0h
	dw	02022h, 02022h
	db	0a5h
	dw	02026h, 02026h
	db	0c9h
	dw	020ach, 020ach
	db	0ffh
	dw	02116h, 02116h
	db	   0dch
	dw	02122h, 02122h
	db	0aah
	dw	02206h, 02206h
	db	0c6h
	dw	0221ah, 0221ah
	db	0c3h
	dw	0221eh, 0221eh
	db	0b0h
	dw	02248h, 02248h
	db	0c5h
	dw	     02260h, 02260h
	db	0adh
	dw	02264h, 02265h
	db	0b2h, 0b3h

;wchar- iend 5
Utf16_Cp8859_5_tbl:
	db	3h
	dw	0a7h, 0a7h
	db	0fdh
	dw	0401h, 045fh
	db	0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0aeh, 0afh, 0b0h, 0b1h, 0b2h, 0b3h, 0b4h, 0b5h, 0b6h, 0b7h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh, 0bfh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0feh, 0ffh, 0h, 0h, 0h
	dw	02116h, 02116h
	db	0f0h


;0- iend wchar
Cp866_Utf16_tbl:
	db	1h
	db	080h, 0ffh
	dw	0410h, 0411h, 0412h, 0413h, 0414h, 0415h, 0416h, 0417h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 0420h, 0421h, 0422h, 0423h, 0424h, 0425h, 0426h, 0427h, 0428h, 0429h, 042ah, 042bh, 042ch, 042dh, 042eh, 042fh, 0430h, 0431h, 0432h, 0433h, 0434h, 0435h, 0436h, 0437h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 02591h, 02592h, 02593h, 02502h, 02524h, 02561h, 02562h, 02556h, 02555h, 02563h, 02551h, 02557h, 0255dh, 0255ch, 0255bh, 02510h, 02514h, 02534h, 0252ch, 0251ch, 02500h, 0253ch, 0255eh, 0255fh, 0255ah, 02554h, 02569h, 02566h, 02560h, 02550h, 0256ch, 02567h, 02568h, 02564h, 02565h, 02559h, 02558h, 02552h, 02553h, 0256bh, 0256ah, 02518h, 0250ch, 02588h, 02584h, 0258ch, 02590h, 02580h, 0440h, 0441h, 0442h, 0443h, 0444h, 0445h, 0446h, 0447h, 0448h, 0449h, 044ah, 044bh, 044ch, 044dh, 044eh, 044fh, 0401h, 0451h, 0404h, 0454h, 0407h, 0457h, 040eh, 045eh, 0b0h, 02219h, 0b7h, 0221ah, 02116h, 0a4h, 025a0h, 0a0h

;1- iend wchar
Cp1251_Utf16_tbl:
	db	0ah
	db	080h, 096h
	dw	0402h, 0403h, 0201ah, 0453h, 0201eh, 02026h, 02020h, 02021h, 020ach, 02030h, 0409h, 02039h, 040ah, 040ch, 040bh, 040fh, 0452h, 02018h, 02019h, 0201ch, 0201dh, 02022h, 02013h
	db	098h, 09fh
	dw	02014h, 02122h, 0459h, 0203ah, 045ah, 045ch, 045bh, 045fh
	db	0a1h, 0a3h
	dw	040eh, 045eh, 0408h
	db	0a5h, 0a5h
	dw	0490h
	db	0a8h, 0a8h
	dw	0401h
	db	0aah, 0aah
	dw	0404h
	db	0afh, 0afh
	dw	0407h
	db	0b2h, 0b4h
	dw	0406h, 0456h, 0491h
	db	0b8h, 0bah
	dw	0451h, 02116h, 0454h
	dw	0bch, 0ffh, 0458h, 0405h, 0455h, 0457h, 0410h, 0411h, 0412h, 0413h, 0414h, 0415h, 0416h, 0417h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 0420h, 0421h, 0422h, 0423h, 0424h, 0425h, 0426h, 0427h, 0428h, 0429h, 042ah, 042bh, 042ch, 042dh, 042eh, 042fh, 0430h, 0431h, 0432h, 0433h, 0434h, 0435h, 0436h, 0437h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 0440h, 0441h, 0442h, 0443h, 0444h, 0445h, 0446h, 0447h, 0448h, 0449h, 044ah, 044bh, 044ch, 044dh, 044eh, 044fh

;2- iend wchar
Cp10007_Utf16_tbl:
	db	5h
	db	080h, 0a1h
	dw	0410h, 0411h, 0412h, 0413h, 0414h, 0415h, 0416h, 0417h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 0420h, 0421h, 0422h, 0423h, 0424h, 0425h, 0426h, 0427h, 0428h, 0429h, 042ah, 042bh, 042ch, 042dh, 042eh, 042fh, 02020h, 0b0h
	db	0a4h, 0a8h
	dw	0a7h, 02022h, 0b6h, 0406h, 0aeh
	db	0aah, 0b0h
	dw	02122h, 0402h, 0452h, 02260h, 0403h, 0453h, 0221eh
	db	0b2h, 0b4h
	dw	02264h, 02265h, 0456h
	db	0b6h, 0ffh
	dw	02202h, 0408h, 0404h, 0454h, 0407h, 0457h, 0409h, 0459h, 040ah, 045ah, 0458h, 0405h, 0ach, 0221ah, 0192h, 02248h, 02206h, 0abh, 0bbh, 02026h, 0a0h, 040bh, 045bh, 040ch, 045ch, 0455h, 02013h, 02014h, 0201ch, 0201dh, 02018h, 02019h, 0f7h, 0201eh, 040eh, 045eh, 040fh, 045fh, 02116h, 0401h, 0451h, 044fh, 0430h, 0431h, 0432h, 0433h, 0434h, 0435h, 0436h, 0437h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 0440h, 0441h, 0442h, 0443h, 0444h, 0445h, 0446h, 0447h, 0448h, 0449h, 044ah, 044bh, 044ch, 044dh, 044eh, 0a4h

;3- iend wchar
Koi8r_Utf16_tbl:
	db	1h
	db	080h, 0ffh
	dw	02500h, 02502h, 0250ch, 02510h, 02514h, 02518h, 0251ch, 02524h, 0252ch, 02534h, 0253ch, 02580h, 02584h, 02588h, 0258ch, 02590h, 02591h, 02592h, 02593h, 02320h, 025a0h, 02219h, 0221ah, 02248h, 02264h, 02265h, 0a0h, 02321h, 0b0h, 0b2h, 0b7h, 0f7h, 02550h, 02551h, 02552h, 0451h, 02553h, 02554h, 02555h, 02556h, 02557h, 02558h, 02559h, 0255ah, 0255bh, 0255ch, 0255dh, 0255eh, 0255fh, 02560h, 02561h, 0401h, 02562h, 02563h, 02564h, 02565h, 02566h, 02567h, 02568h, 02569h, 0256ah, 0256bh, 0256ch, 0a9h, 044eh, 0430h, 0431h, 0446h, 0434h, 0435h, 0444h, 0433h, 0445h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 044fh, 0440h, 0441h, 0442h, 0443h, 0436h, 0432h, 044ch, 044bh, 0437h, 0448h, 044dh, 0449h, 0447h, 044ah, 042eh, 0410h, 0411h, 0426h, 0414h, 0415h, 0424h, 0413h, 0425h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 042fh, 0420h, 0421h, 0422h, 0423h, 0416h, 0412h, 042ch, 042bh, 0417h, 0428h, 042dh, 0429h, 0427h, 042ah

;4- iend wchar
Mac_Utf16_tbl:
	db	5h
	db	080h, 0a2h
	dw	0410h, 0411h, 0412h, 0413h, 0414h, 0415h, 0416h, 0417h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 0420h, 0421h, 0422h, 0423h, 0424h, 0425h, 0426h, 0427h, 0428h, 0429h, 042ah, 042bh, 042ch, 042dh, 042eh, 042fh, 02020h, 0b0h, 0490h
	db	0a4h, 0a8h
	dw	0a7h, 02022h, 0b6h, 0406h, 0aeh
	db	0aah, 0b0h
	dw	02122h, 0402h, 0452h, 02260h, 0403h, 0453h, 0221eh
	db	0b2h, 0b4h
	dw	02264h, 02265h, 0456h
	db	0b6h, 0ffh
	dw	0491h, 0408h, 0404h, 0454h, 0407h, 0457h, 0409h, 0459h, 040ah, 045ah, 0458h, 0405h, 0ach, 0221ah, 0192h, 02248h, 02206h, 0abh, 0bbh, 02026h, 0a0h, 040bh, 045bh, 040ch, 045ch, 0455h, 02013h, 02014h, 0201ch, 0201dh, 02018h, 02019h, 0f7h, 0201eh, 040eh, 045eh, 040fh, 045fh, 02116h, 0401h, 0451h, 044fh, 0430h, 0431h, 0432h, 0433h, 0434h, 0435h, 0436h, 0437h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 0440h, 0441h, 0442h, 0443h, 0444h, 0445h, 0446h, 0447h, 0448h, 0449h, 044ah, 044bh, 044ch, 044dh, 044eh, 020ach

;5- iend wchar
Cp8859_5_Utf16_tbl:
	db	2h
	db	0a1h, 0ach
	dw	0401h, 0402h, 0403h, 0404h, 0405h, 0406h, 0407h, 0408h, 0409h, 040ah, 040bh, 040ch
	db	0aeh, 0ffh
	dw	040eh, 040fh, 0410h, 0411h, 0412h, 0413h, 0414h, 0415h, 0416h, 0417h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 0420h, 0421h, 0422h, 0423h, 0424h, 0425h, 0426h, 0427h, 0428h, 0429h, 042ah, 042bh, 042ch, 042dh, 042eh, 042fh, 0430h, 0431h, 0432h, 0433h, 0434h, 0435h, 0436h, 0437h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 0440h, 0441h, 0442h, 0443h, 0444h, 0445h, 0446h, 0447h, 0448h, 0449h, 044ah, 044bh, 044ch, 044dh, 044eh, 044fh, 02116h, 0451h, 0452h, 0453h, 0454h, 0455h, 0456h, 0457h, 0458h, 0459h, 045ah, 045bh, 045ch, 0a7h, 045eh, 045fh


CheckRange:
	dd	Range_0_9
	db	10, 0
	dd	Range_a_f
	db	16, 10
	dd	Range_ac_fc
	db	16, 10
	db	0

;CheckTable:
;	istruc CheckSymbol db  FUNCTION_Symbol,GetPlusSign,0,0 iend
;	istruc CheckSymbol db  FUNCTION_Symbol,GetMinusSign,0,MINUS_SIGN iend
;	istruc CheckSymbol db  FUNCTION_Symbol,GetFloationPointSign,FLOAT_VALUE,0 iend
;	 istruc CheckSymbol
;	 dd Symbol_ec
;	 db EXP_VALUE, EXP_FLAG, SIGN_FLAG | NUMBER_FLAG, 10
;	 iend
;	 istruc CheckSymbol
;	 dd Symbol_ec
;	 db EXP_VALUE, EXP_FLAG, SIGN_FLAG | NUMBER_FLAG, 10
;	 iend
 ;	 istruc CheckSymbol
 ;	 dd Symbol_h
 ;	 db HEX_VALUE, MODE_FLAG, SEPARATOR_FLAG, 16
;	 iend
;	 istruc CheckSymbol
;	 dd Symbol_hc
;	 db HEX_VALUE, MODE_FLAG, SEPARATOR_FLAG, 16
;	 iend
;	 istruc CheckSymbol
;	 dd Symbol_x
;	 db HEX_VALUE, MODE_FLAG, NUMBER_FLAG | ZERO_FLAG, 16
;	 iend
;	 istruc CheckSymbol
;	 dd Symbol_xc
;	 db HEX_VALUE, MODE_FLAG, NUMBER_FLAG | ZERO_FLAG, 16
;	 iend
;	 istruc CheckSymbol
;	 dd Symbol_q
;	 db OCTAL_VALUE, MODE_FLAG, SEPARATOR_FLAG, 8
;	 iend
;	 istruc CheckSymbol
;	 dd Symbol_qc
;	 db OCTAL_VALUE, MODE_FLAG, SEPARATOR_FLAG, 8
;	 iend
;	 istruc CheckSymbol
;	 dd Symbol_b
;	 db BIN_VALUE, MODE_FLAG, SEPARATOR_FLAG, 2
;	 iend
 ;	 istruc CheckSymbol
;	 dd Symbol_bc
;	 db BIN_VALUE, MODE_FLAG, SEPARATOR_FLAG, 2
;	 iend
;Floating_point_symbol:
 ;	 istruc CheckSymbol
;	 dd Symbol_es
;	 db FLOAT_VALUE, FLOAT_DOT_FLAG, NUMBER_FLAG | SEPARATOR_FLAG | EXP_FLAG, 10
 ;	 iend
;Positive_sign_symbol:
;	 istruc CheckSymbol
;	 dd Symbol_ps
;	 db POS_VALUE, SIGN_FLAG, NUMBER_FLAG | MODE_FLAG | FLOAT_DOT_FLAG | ZERO_FLAG | MODE_ZERO_FLAG, 0
;	 iend
;Negative_sign_symbol:
;	 istruc CheckSymbol
;	 dd Symbol_ms
 ;	 db NEG_VALUE, SIGN_FLAG, NUMBER_FLAG | MODE_FLAG | FLOAT_DOT_FLAG | ZERO_FLAG | MODE_ZERO_FLAG, 0
;	 iend
;	 dd	 0
;
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
	db	0

;Range_0_9_8	  label   byte
;	db	'0', '9'
;Range_0_9_8r	label	byte
;	db	26h, 2fh
;Range_0_9_16	label	word
;	dw	'0', '9'
;Range_0_9_rutf label	dword
;	dd	26h, 2fh
Range_0_9:	 istruc Symbol
	db '0',20h,'0',20h
iend
istruc Symbol
	db '9',29h,'9',29h
iend

Range_a_f:	 istruc Symbol
	db 'a',80h,'a',80h
iend
istruc Symbol
	db 'z',85h,'a',85h
iend

Range_ac_fc:	 istruc Symbol
	db 'A',0a0h,'A',0a0h
iend
istruc Symbol
	db 'Z',0a5h,'Z',0a5h
iend

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
db 'e', 084h, 'e', 084h
iend

Symbol_ec	istruc Symbol
db 'E', 0a4h, 'E', 0a4h
iend

Symbol_h	istruc Symbol
db 'h', 84h, 'h', 84h
iend

Symbol_hc	istruc Symbol
db 'H',0a4h,'H',0a4h
iend

Symbol_x	istruc Symbol
db 'x',84h,'x',84h
iend

Symbol_xc	istruc Symbol
db 'X',0a4h,'X',0a4h
iend

Symbol_q	istruc Symbol
db 'q',84h,'q',84h
iend

Symbol_qc	istruc Symbol
db 'Q',0a4h,'Q',0a4h
iend

Symbol_b	istruc Symbol
db 'b',81h,'b',81h
iend

Symbol_bc	istruc Symbol
db 'B',0a1h,'B',0a1h
iend

Symbol_ms	istruc Symbol
db '-',0a1h,'-',0a1h
iend

Symbol_ps	istruc Symbol
db '+',0a1h,'+',0a1h
iend

Symbol_es	istruc Symbol
db ',',0a1h,',',0a1h
iend


GetSymbol_table:
	dd	GetSymbol8, GetSymbol8, GetSymbol16, GetSymbolRutf

ConvertSymbol_table:
	dd	GetSymbol8, GetSymbol8_8P, GetSymbol8_16, GetSymbol8_Rutf
	dd	GetSymbol8P_8, GetSymbol8P, GetSymbol8P_16, GetSymbol8P_Rutf
	dd	GetSymbol16_8, GetSymbol16_8P, GetSymbol16, GetSymbol16_Rutf
	dd	GetSymbolRutf_8, GetSymbolRutf_8P, GetSymbolRutf_16, GetSymbolRutf
