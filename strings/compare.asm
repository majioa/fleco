;[]-----------------------------------------------------------------[]
;|   COMPARE.ASM -- string comparing functions			     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1.1.1 $
;
;int __fastcall Compare(const AnsiString& rhs) const;
;int __fastcall Compare(const AnsiString& rhs, const Mode &mode) const;
;bool __fastcall operator !=(const AnsiString& rhs) const;
;bool __fastcall operator ==(const AnsiString& rhs) const;
;bool __fastcall operator <(const AnsiString& rhs) const;
;bool __fastcall operator <=(const AnsiString& rhs) const;
;bool __fastcall operator >(const AnsiString& rhs) const;
;bool __fastcall operator >=(const AnsiString& rhs) const;

	%include 'constant.inc'
	GLOBAL	Compare_table
	GLOBAL	CompareSymbol_table
	GLOBAL	@FastString@Compare$xqqrrx10FastString
	GLOBAL	@FastString@Compare$xqqrrx10FastStringrx4Mode
	GLOBAL	@FastString@$bequ$xqqrrx10FastString
	GLOBAL	@FastString@$bneq$xqqrrx10FastString
	GLOBAL	@FastString@$bblw$xqqrrx10FastString
	GLOBAL	@FastString@$babw$xqqrrx10FastString
	GLOBAL	@FastString@$bble$xqqrrx10FastString
	GLOBAL	@FastString@$babe$xqqrrx10FastString

	EXTERN	IsEmpty
	section _TEXT

@FastString@Compare$xqqrrx10FastString:
	;in
	;eax: this
	;edx: FastString
	;out
	;eax: code -1 0 1
	call	IsEmpty
	jz	@FastString@Compare$xqqrrx10FastString_exit
	call	[CompareSymbol_table+edx*4]
@FastString@Compare$xqqrrx10FastString_exit:
	ret
@FastString@Compare$xqqrrx10FastStringrx4Mode:
	;in
	;eax: this
	;edx: FastString
	;ecx: CompareMode
	;out
	;eax: code -1 0 1
	ret
@FastString@$bequ$xqqrrx10FastString:
	ret
@FastString@$bneq$xqqrrx10FastString:
	ret
@FastString@$bblw$xqqrrx10FastString:
	ret
@FastString@$babw$xqqrrx10FastString:
	ret
@FastString@$bble$xqqrrx10FastString:
	ret
@FastString@$babe$xqqrrx10FastString:
	ret


	section _DATA

CompareSymbol_table: dd 0
Compare_table: dd 0
