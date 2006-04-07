;[]-----------------------------------------------------------------[]
;|   COMMON.ASM -- string functions				     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1.1.1 $
;
;Fast String standalone methods
;int __fastcall Length() const;
;AnsiString& __fastcall SetLength(int newLength);

	%include 'constant.inc'
	GLOBAL	_mainCRTStartup
	GLOBAL	@FastString@GetLength$xqqrv
	GLOBAL	@FastString@SetLegnth$qqrui

	section _TEXT
;	 section _TEXT use32 public class=code

%ifdef WIN32
..start:
_mainCRTStartup:
	mov	eax, [words]
	mov	eax, 1
	ret	0ch
%endif

@FastString@GetLength$xqqrv:
@FastString@SetLegnth$qqrui:
	ret

	section _DATA

words	dw	0
