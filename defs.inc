;[]-----------------------------------------------------------------[]
;|   DEFS.INC -- locale definitions file			     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1.1.1 $
;
;if defined WIN32
;	format COFF
;else if defined LINUX
;	format ELF
;end if

match	=WIN32, OS { format COFF }
match	=LINUX, OS { format ELF }
format ELF


macro	fje	op
{
	fstsw	ax
	test	ah, 1000000b
	jnz	op
}


macro	fjne	op
{
	fstsw	ax
	test	ah, 1000000b
	jz	op
}


macro	fjge	op
{
	fstsw	ax
	test	ah, 1
	jz	op
}


macro	fjl	op
{
	fstsw	ax
	test	ah, 1
	jnz	op
}


	section '.text' executable
	section '.data' writeable 
;	section '.text' code readable executable
;	section '.data' data readable writeable 
;	section '.reloc' data discardable fixups
;	section '.rsrc' data readable resource from 'res'


;	__SECT__

;strings structure constants

SIZEOF_LOCALE	equ	4

BITS8CP      equ       00b
WCHARCP      equ       01b
UTFCP	     equ       10b
RUTFCP	     equ       11b


struc Locale
{
.CP	  dw	    1
.CPType   db	    1
.CPType1  db	    1
}

CP866	equ	0
CP1251	equ	0
MAC	equ	0
KOI8R	equ	0
CP10007 equ	0
CP8859_5 equ	0
