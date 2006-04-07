;[]-----------------------------------------------------------------[]
;|   CURRENCY.ASM -- string to currency converting functions	     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1.1.1 $
;
;AnsiString __fastcall AnsiString(const Currency &value)
;AnsiString __fastcall AnsiString(const Currency &value, TStringFloatFormat format, int digits)
;AnsiString &__fastcall =(const Currency &value)

	%include 'constant.inc'
	GLOBAL	@FastString@$bctr$qqrrx8Currency
	GLOBAL	@FastString@$basg$qqrrx8Currency
	GLOBAL	@FastString@o8Currency$xqqrv

	section _TEXT

@FastString@$bctr$qqrrx8Currency:
	ret
@FastString@$basg$qqrrx8Currency:
	ret
@FastString@o8Currency$xqqrv:
	ret
