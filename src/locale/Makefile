#[]-----------------------------------------------------------------[]
#|   Makefile -- makefile					     |
#[]-----------------------------------------------------------------[]
#
# $Copyright: 2005$
# $Revision: 1.0 $
#

ifeq ($(OS),WIN32)
    BIN=locale.dll
else
    BIN=liblocale.so
endif

SRC=locale.asm
OBJ=$(SRC:.asm=.o) # replaces the .asm from SRC with .o
DEF=locale.def
SRCDIR=src/locale

include $(TOPDIR)/src/RULES