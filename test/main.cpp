#include <include/strings.h>

#ifdef __BORLANDC__
  #pragma argsused
#endif
int main()
{
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

}
