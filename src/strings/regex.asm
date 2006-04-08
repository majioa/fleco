;[]-----------------------------------------------------------------[]
;|   REGEX.ASM -- string regex functions			     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1.1.1 $
;
;bool __fastcall Match(const AnsiString& str) const;
;int __fastcall Match(const Strings& list) const;

	%include 'constant.inc'

	GLOBAL	@FastString@Match$xqqrrx10FastString
	GLOBAL	@FastString@Match$xqqrrx8FastText

	section _TEXT

@FastString@Match$xqqrrx10FastString:
	ret
@FastString@Match$xqqrrx8FastText:
	ret
