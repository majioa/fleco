//[]-----------------------------------------------------------------[]
//|   LOCALE.H -- locale header file				      |
//[]-----------------------------------------------------------------[]
#if !defined(LOCALE_H)
#define LOCALE_H


#define cp866	    0
#define cp1251	    1
#define cp10007     2
#define cpkoi8r     3
#define cpmac	    4
#define cp8859_5    5
#define utf15	    0x8000
#define ruft	    0xc000


class Locale
{
public:
  __fastcall Locale();
  __fastcall ~Locale();

  __fastcall int GetCodePage();
};

#endif

