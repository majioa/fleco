#include "../src/strings.h"

#include <windows.h>
#ifdef __BORLANDC__
  #pragma argsused
#endif
int APIENTRY WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow )
{
//   MessageBox(NULL,"","",MB_OK);
//  FastString a("-0x31");
//  FastString a("-0x31");
//  FastString a("-0x31");
  long double fl = 18446744073709551599;
  long double fl1 = -4500000000000000000.6;
//  FastString a("450000000000000000000");
//  FastString a("450000000000000000000,2");
//  FastString a("450000000000000000,6");
//  FastString a("450000000000000000");
  FastString a("45,222p2");
//  FastString a("45,2o2");
//  FastString a("18446744073709551599");
//  FastString a("18446744073709551616");
//  FastString a("999999999999999999999,9");
//  FastString a("9223372036854775807");
  __int64 i = 1, j = 2, k = i / j;
  float f1 = 1e21, f2 = 0;
  bool b1 = a;
  char c1 = a;
  byte b2 = a;
  short s1 = a;
  word w1 = a;
  int i1 = a;
  dword dw1 = a;
  __int64 in1 = a;
  qword qw1 = a;
  float f = a;

  if(f1 < f2)
    j = 1;
  if(f1 == 0)
    j = 1;

//  long (*x)[1000];
//  x =  malloc(1000*1000*sizeof(long));
//  x[i][j] = 0;

  void *hin = 0;
 // for(;;)
//    hin = LoadLibrary("strings.dll");
//  int  i =0;
/*  i = GetLastError();
  LPVOID lpMsgBuf;

FormatMessage(
    FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
    NULL,
    i,
    MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
    (LPTSTR) &lpMsgBuf,
    0,
    NULL
);
// Display the string.
//MessageBox( NULL, (const char *)lpMsgBuf, "GetLastError", MB_OK|MB_ICONINFORMATION );

// Free the buffer.
LocalFree( lpMsgBuf );


//  int i = a;
/*  char c = a;
  short s = a;
  float f = a;
  double d = a;
  long double extendedf = a;
  void *p = a;
  char *s1 = (char *)p;*/
//  return !hin;
}
