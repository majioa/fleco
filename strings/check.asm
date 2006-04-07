;[]-----------------------------------------------------------------[]
;|   CHECK.ASM -- string checking functions			     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1.1.1 $
;
;bool __fastcall IsDelimiter(const AnsiString& delimiters, int index) const;
;bool __fastcall IsEmpty() const;
;bool __fastcall IsPathDelimiter(int index) const;

	%include 'constant.inc'

;	 EXTERN  GetSymbol
;	 EXTERN  GetRutfSymbol
;	 EXTERN  CompareSymbol
;	 EXTERN  ConvertSymbol
	EXTERN	ConvertSymbol_table
	EXTERN	CompareSymbol_table
	GLOBAL	@FastString@IsDelimiter$xqqrrx10FastStringui
	GLOBAL	@FastString@IsEmpty$xqqrv
	GLOBAL	@FastString@IsPathDelimiter$xqqrui
	GLOBAL	IsEmpty


	section _TEXT
IsEmpty:
	mov	eax, [eax]
	or	eax, eax
	jz	IsEmpty_exit
	cmp	dword [eax-SIZEOF_FASTSTRING+FastString.Length],0
IsEmpty_exit:
	ret

@FastString@IsDelimiter$xqqrrx10FastStringui:
	;in
	;eax: this
	;edx: delimiters fast string
	;ecx: index
	call	IsEmpty
	jz	@FastString@IsDelimiter$xqqrrx10FastStringui_exit
	push	ebx
	push	esi
	push	edi
	mov	esi, [eax]
	mov	edi, edx
	;
;	 mov	 eax, [esi-SIZEOF_FASTSTRING+FastString.Locale]
;	 movzx	 eax, byte [eax-SIZEOF_LOCALE+Locale.Type]
	movzx	eax, word [esi-SIZEOF_FASTSTRING+FastString.CP]
	shr	eax, 12
	and	eax, 1100b
	movzx	edx, word [edi-SIZEOF_FASTSTRING+FastString.CP]
	shr	edx, 14
	call	[ConvertSymbol_table+edx*4+eax]
;	 call	 GetCPS
	call	[CompareSymbol_table+edx*4]

	pop	edi
	pop	esi
	pop	ebx
@FastString@IsDelimiter$xqqrrx10FastStringui_exit:
	ret

@FastString@IsEmpty$xqqrv:
	call	IsEmpty
	setz	al
	ret

@FastString@IsPathDelimiter$xqqrui:
	;in
	;eax: this
	;edx: index
	call	IsEmpty
	jz	@FastString@IsPathDelimiter$xqqrui_exit
	push	ebx
	mov	ebx, [eax]
	movzx	eax, word [ebx-SIZEOF_FASTSTRING+FastString.CP]
	shr	eax, 14
	or	eax, 1100b
	call	[ConvertSymbol_table+eax]
;	 call	 GetRutfSymbol
	cmp	eax, [PathDelimiter]
	setz	al
	pop	ebx
@FastString@IsPathDelimiter$xqqrui_exit:
	ret


	section _DATA


PathDelimiter: dd '/'
