;[]-----------------------------------------------------------------[]
;|   FORMAT.ASM -- string formatting functions			     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1.1.1 $
;
;AnsiString& __cdecl cat_sprintf(const char* format, ...);
;int __cdecl cat_printf(const char* format, ...);
;AnsiString& __cdecl cat_vprintf(const char* format, ...);
;int __cdecl printf(const char* format, ...);
;AnsiString& __cdecl sprintf(const char* format, ...);
;int __cdecl vprintf(const char* format, va_list);

	%include 'constant.inc'
	GLOBAL	@FastString@printf$qqrrx10FastString7Variant
	GLOBAL	@FastString@sprintf$qqrrx10FastString7Variant
	GLOBAL	@FastString@printf$rrx10FastString
	GLOBAL	@FastString@sprintf$rrx10FastString

	section _TEXT

@FastString@printf$qqrrx10FastString7Variant:
	ret
@FastString@sprintf$qqrrx10FastString7Variant:
	ret
@FastString@printf$rrx10FastString:
	ret
@FastString@sprintf$rrx10FastString:
	ret
