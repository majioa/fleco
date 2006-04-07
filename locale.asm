;[]-----------------------------------------------------------------[]
;|   LOCALE.ASM -- locale class functions			     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1.1.1 $
;

       include 'defs.inc'

;section '.text' code readable executable
section '.text' executable


	PUBLIC  _mainCRTStartup
	PUBLIC  _start
	PUBLIC	@Locale@$bctr$qqrv
	PUBLIC  @Locale@$bdtr$qqrv
	PUBLIC  @Locale@GetSystemCodepage$qqrv
	PUBLIC  @Locale@GetDecimalConstant$qqrv
	EXTRN	GetACP

	CP_COUNT  equ	  15


_mainCRTStartup:
_start:
;virtual
;       align 16
;f OS=WIN32
	mov	eax, [decimal_constant]
	mov	eax, 1
DllEntryPoint_exit1:
	ret	0ch
;else if OS=LINUX
	mov	eax, 1
	ret
;end if
;end virtual

@Locale@$bctr$qqrv:
;%ifdef WIN32
	push	ebx
	mov	ebx, eax
;	call	GetACP
;	 movzx	 ecx, byte [CPCount]
	mov	dword [ebx], 0
	mov	edx, CP_COUNT*8
	mov	ecx, CPs
@Locale@GetSystemCodepage$qqrv_loop:
	sub	edx, 8
	jz	@Locale@GetSystemCodepage$qqrv_not_found
	cmp	eax, [edx+ecx]
	jnz	@Locale@GetSystemCodepage$qqrv_loop
@Locale@GetSystemCodepage$qqrv_not_found:
	mov	eax, [edx+ecx+4]
	mov	[ebx], eax
	mov	eax, ebx
	pop	ebx
;%endif
	ret
;end virtual


;virtual
@Locale@$bdtr$qqrv:
	test	dl, 2
	jz	@Locale@$bdtr$qqrv_exit
;	freer
@Locale@$bdtr$qqrv_exit:
	ret
;end virtual


;virtual
@Locale@GetSystemCodepage$qqrv:
	mov    eax, [eax]
	ret
;end virtual


;virtual
@Locale@GetDecimalConstant$qqrv:
	mov    eax, [decimal_constant]
	ret
;end virtual


	section '.data'

decimal_constant     dd 10
CPs:
;Thai
	dd	874, 0
;Japan
	dd	932, 0
;Chinese (PRC, Singapore)
	dd	936, 0
;Korean
	dd	949, 0
;Chinese (Taiwan, Hong Kong)
	dd	950, 0
;Unicode (BMP of ISO 10646)
	dd	1200, 0
;Windows 3.1 Eastern European
	dd	1250, 0
;Windows 3.1 Cyrillic
;       dd	1251, (BITS8CP << 24) + CP1251
       dd	1251, CP1251
;Windows 3.1 Latin 1 (US, Western Europe)
	dd	1252, 0
;Windows 3.1 Greek
	dd	1253, 0
;Windows 3.1 Turkish
	dd	1254, 0
;Hebrew
	dd	1255, 0
;Arabic
	dd	1256, 0
;Baltic
	dd	1257, 0



