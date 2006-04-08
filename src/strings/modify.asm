;[]-----------------------------------------------------------------[]
;|   MODIFY.ASM -- string modification functions		     |
;[]-----------------------------------------------------------------[]
;
; $Copyright: 2005$
; $Revision: 1.1.1.1 $
;
;AnsiString& __fastcall Delete(int index, int count);
;AnsiString& __fastcall Insert(const AnsiString& str, int index);
;AnsiString __fastcall LowerCase() const;
;friend AnsiString __fastcall operator +(const char* lhs, const AnsiString& rhs);
;AnsiString __fastcall operator +(const AnsiString& rhs) const;
;AnsiString& __fastcall operator +=(const AnsiString& rhs);
;AnsiString __fastcall Trim() const;
;AnsiString __fastcall TrimLeft() const;
;AnsiString __fastcall TrimRight() const;
;void __fastcall Unique();
;AnsiString __fastcall UpperCase() const;

	%include 'constant.inc'
	GLOBAL	@FastString@$badd$qqrrx10FastString7Variant
	GLOBAL	@FastString@Add$qqrrx10FastString
	GLOBAL	@FastString@$bpls$xqqrrx10FastString7Variant
	GLOBAL	@FastString@$bpls$xqqrrx10FastString
	GLOBAL	@FastString@Insert$qqrrx10FastStringui
	GLOBAL	@FastString@Delete$qqrrx10FastString
	GLOBAL	@FastString@Delete$qqrruiui
	GLOBAL	@FastString@Trim$xqqrv
	GLOBAL	@FastString@TrimRight$xqqrv
	GLOBAL	@FastString@TrimLeft$xqqrv
	GLOBAL	@FastString@Unique$qqrv
	GLOBAL	@FastString@LowerCase$qqrrv
	GLOBAL	@FastString@UpperCase$qqrrv
;	 EXTERN  CopyString
;	 EXTERN  StringRedim

	section _TEXT

@FastString@$badd$qqrrx10FastString7Variant:
@FastString@Add$qqrrx10FastString:
	ret
@FastString@$bpls$xqqrrx10FastString7Variant:
	ret
@FastString@$bpls$xqqrrx10FastString:
	ret
@FastString@Insert$qqrrx10FastStringui:
	ret
@FastString@Delete$qqrrx10FastString:
	ret
@FastString@Delete$qqrruiui:
	ret
@FastString@Trim$xqqrv:
	ret
@FastString@TrimRight$xqqrv:
	ret
@FastString@TrimLeft$xqqrv:
	ret
@FastString@Unique$qqrv:
	mov	edx, [eax]
	or	edx, edx
	jz	Unique_exit
	lock	dec	dword ptr[edx-SIZEOF_FASTSTRING+FastString.RefCount]
	jnz	Unique_make_new_string
	lock	inc	dword ptr[edx-SIZEOF_FASTSTRING+FastString.RefCount]
Unique_exit:
	ret
Unique_make_new_string:
	push	ebx
	push	esi
	push	edi
	lea	esi, [edx-SIZEOF_FASTSTRING+FastString.Length]
	mov	ecx, [edx-SIZEOF_FASTSTRING+FastString.MemBlock]
	mov	ecx, [ecx+MemBlock.Size]
	stc
;;`	   call    StringRedim
	lodsd
	stosd
	lea	ecx, [eax + SIZEOF_FASTSTRING - 2 * SIZEOF_INT]
;	call	SetupDefaultCodepage
;;	  jmp	  CopyString

@FastString@LowerCase$qqrrv:
	ret
@FastString@UpperCase$qqrrv:
	ret
