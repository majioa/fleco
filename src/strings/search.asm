;[]-----------------------------------------------------------------[]
;|   SEARCH.ASM -- string search functions			     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1.1.1 $
;
;int __fastcall Pos(const AnsiString& subStr) const;
;int __fastcall LastDelimiter(const AnsiString& delimiters) const;

	%include 'constant.inc'
	GLOBAL	@FastString@Pos$xqqri
	GLOBAL	@FastString@Seek$xqqrrx10FastString
	GLOBAL	@FastString@LastDelimiter$xqqrrx10FastString

	section _TEXT

@FastString@Pos$xqqri:
	ret
@FastString@Seek$xqqrrx10FastString:
	ret
@FastString@LastDelimiter$xqqrrx10FastString:
	ret
