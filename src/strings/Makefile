#[]-----------------------------------------------------------------[]
#|   Makefile -- makefile					     |
#[]-----------------------------------------------------------------[]
#
# $Copyright: 2005$
# $Revision: 1.0 $
#

ifeq ($(OS),WIN32)
    BIN=strings.dll
else
    BIN=libstrings.so
endif

SRC=common.asm
OBJ=$(SRC:.asm=.o) # replaces the .asm from SRC with .o
DEF=strings.def
SRCDIR=src/locale

include $(TOPDIR)/src/RULES