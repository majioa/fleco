#[]-----------------------------------------------------------------[]
#|   Makefile -- makefile					     |
#[]-----------------------------------------------------------------[]
#
# $Copyright: 2005$
# $Revision: 1.0 $
#

OS=WIN32
BIN=strings.dll
SRC=common.asm construc.asm convert.asm codepage.asm check.asm compare.asm currency.asm date.asm format.asm modify.asm regex.asm search.asm symbol.asm
OBJ=$(SRC:.asm=.o) # replaces the .asm from SRC with .o
DEF=strings.def
SRCDIR=src
OBJDIR=obj
BINDIR=bin
LIB=
VPATH=src;obj;bin

AS=fasm
LD=ilink32
#AFLAGS=-f coff -O4
AFLAGS=-f obj -O4 -I$(SRCDIR)/
#LFLAGS=-mi386pe -call_shared --disable-stdcall-fixup	--export-all-symbols	#Link flags with gcc
#LFLAGS=-mi386pe -call_shared --disable-stdcall-fixup  -E   #Link flags with gcc
#LFLAGS = -c -Tpd -aa -x -Gn -Gi -v -b:0x340000 #Link flags with ilink32
LLFLAGS=-m -M -s    #Link loggings flags with ilink32
LFLAGS = -Tpd -aa -x -Gn -Gi -v -b:0x340000  #Link flags with ilink32

%.o: %.asm
	$(AS) $(AFLAGS) -l $(<:.asm=.lst) -o $(OBJDIR)/$@ $< -E $(OBJDIR)/$(@:.o=.err)	-d$(OS)

.PHONY : all	 # .PHONY ignores files named all
all: $(BIN)	 # all is dependent on $(EXE) to be complete

$(BIN): $(OBJ) $(DEF) $(RES) # $(EXE) is dependent on all of the files in $(OBJ) to exist
	$(LD)  $(LFLAGS) $(LLFLAGS) -j$(OBJDIR) $(OBJ) , $(BINDIR)\\$@,, $(LIB), $(SRCDIR)\\$(DEF), $(RES)

.PHONY : clean	 # .PHONY ignores files named clean
clean:
	-$(RM) -f $(OBJ) *.lst *.err   # '-' causes errors not to exit the process
