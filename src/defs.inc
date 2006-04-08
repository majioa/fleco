;[]-----------------------------------------------------------------[]
;|   DEFS.INC -- locale definitions file			     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1 $
;
	bits 32


%define PUBLIC GLOBAL
%define EXTRN EXTERN
%define endm endmacro
%define proc :
%define near
%define ptr
%define endp
%define tbyte tword
%define offset

RUSSIAN_CP_COUNT	equ	  6


PARAMETER_Symbol	equ	  1
FUNCTION_Symbol 	equ	  2
NEG_VALUE	equ	  80h
POS_VALUE	equ	  0
;BREAK_VALUE	equ	  80h
FLOAT_VALUE	equ	  1
EXP_VALUE	equ	  2

SIGN_FLAG	equ	  1
FLOAT_DOT_FLAG	equ	  2
EXP_FLAG	equ	  4
SEPARATOR_FLAG	equ	  8
BASE_FLAG	equ	  16
REQ_BASE_FLAG	equ	  32
DIGIT_FLAG	equ	  64
LEAD_ZERO_FLAG	equ	  128
ZERO_FLAG	equ	  256

;SIGN_FLAG	equ	  1
;FLOAT_DOT_FLAG equ	  2
;SEPARATOR_FLAG equ	  4
;MODE_FLAG	equ	  8
;EXP_FLAG	equ	  16
;NUMBER_FLAG	equ	  32
;MODE_ZERO_FLAG equ	  64
;ZERO_FLAG	equ	  128



FORCE_SIGN	equ	  1h
;SIGN_INT	equ	  2h

BOOL_STRING_LENGTH	equ	  11
INT_STRING_LENGTH	equ	  21
QWORD_STRING_LENGTH	equ	  41
FLOAT_STRING_LENGTH	equ	  161


SIZEOF_CHAR		equ	  1
SIZEOF_WCHAR_T		equ	  2
SIZEOF_INT		equ	  4
SIZEOF_FASTSTRING	equ	  24
SIZEOF_CHECKSYMBOL	equ	  12
SIZEOF_LOCALE		equ	4

;Code page Flags
;0 - 16 bit
;1 - Win32 supports this function

;Type of a codepage
;WINANSICP	 equ	   000b
;WIDECHARCP	 equ	   001b
;UNIXCP 	 equ	   010b
;MACCP		 equ	   011b
;ISOCP		 equ	   100b
BITS8CP      equ       00b
WCHARCP      equ       01b
UTFCP	     equ       10b
RUTFCP	     equ       11b

;Ansi codepages
;CP874	Thai
;CP932	Japan
;CP936	Chinese (PRC, Singapore)
;CP949	Korean
;CP950	Chinese (Taiwan, Hong Kong)
;CP1200 Unicode (BMP of ISO 10646)
;CP1250 Windows 3.1 Eastern European
;CP1251 Windows 3.1 Cyrillic
;CP1252 Windows 3.1 Latin 1 (US, Western Europe)
;CP1253 Windows 3.1 Greek
;CP1254 Windows 3.1 Turkish
;CP1255 Hebrew
;CP1256 Arabic
;CP1257 Baltic

;OEM codepages
;CP437	MS-DOS United States
;CP708	Arabic (ASMO 708)
;CP709	Arabic (ASMO 449+, BCON V4)
;CP710	Arabic (Transparent Arabic)
;CP720	Arabic (Transparent ASMO)
;CP737	Greek (formerly 437G)
;CP775	Baltic
;CP850	MS-DOS Multilingual (Latin I)
;CP852	MS-DOS Slavic (Latin II)
;CP855	IBM Cyrillic (primarily Russian)
;CP857	IBM Turkish
;CP860	MS-DOS Portuguese
;CP861	MS-DOS Icelandic
;CP862	Hebrew
;CP863	MS-DOS Canadian-French
;CP864	Arabic
;CP865	MS-DOS Nordic
;CP866	MS-DOS Russian (former USSR)
;CP869	IBM Modern Greek
;CP874	Thai
;CP932	Japan
;CP936	Chinese (PRC, Singapore)
;CP949	Korean
;CP950	Chinese (Taiwan, Hong Kong)
;CP1361 Korean (Johab)




%macro	jfe	1
	fstsw	ax
	test	ah, 1000000b
	jnz	%1
%endm


%macro	jfne	1
	fstsw	ax
	test	ah, 1000000b
	jz	%1
%endm


%macro	jfge	1
	fstsw	ax
	test	ah, 1
	jz	%1
%endm


%macro	jfl	1
	fstsw	ax
	test	ah, 1
	jnz	%1
%endm


	section _TEXT use32 public class=code align=16
	section _DATA use32 public class=data align=16
	__SECT__

;strings structure constants


struc CPData
.Offset:  resd	    1	    ;offset for symbol getting
endstruc


struc Symbol
.Bits8:   resd	    1	    ;Symbol 8 bit
.Bits8ru: resd	    1	    ;Symbol 8 bit russian
.Bits16:  resd	    1	    ;Symbol 16 bit
.Rutf:	  resd	    1	    ;Symbol Rutf
endstruc


struc CheckSymbol
.Ptr:		resd	1	;ptr to symbol for check
.Handler	resd	1
.Value: 	resb	1	;value of symbol
.SymType:	resb	1	;type of symbol
.Allow: 	resw	1	;mask allowing following symbols
endstruc
;.Degree:  resb     1	    ;degree of divider


struc CodePage
.CP:	  resw	    1
.CPType:  resb	    1
endstruc

struc Locale
.CP:	  resw	    1
.CPType:  resb	    1
.CPType1: resb      1
endstruc

struc MemBlock
.Ptr:	       resd  1
.Size	       resd  1
endstruc

struc FastString
.RefCount:	  resd	    1
.CP:		  resw	    1
.Type:		  resb	    1
.Mode:		  resb	    1
.Length:	  resd	    1
;.BufferSize:	   resd      1
.Locale:	  resd	    1
.MemBlock:	    resd      1
endstruc

CP866	equ	0
CP1251	equ	0
MAC	equ	0
KOI8R	equ	0
CP10007 equ	0
CP8859_5 equ	0
