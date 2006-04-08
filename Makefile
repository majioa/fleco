#[]-----------------------------------------------------------------[]
#|   Makefile -- makefile					     |
#[]-----------------------------------------------------------------[]
#
# $Copyright: 2005$
# $Revision: 1.0 $
#

ifneq ($(shell uname),Linux)
    export TOPDIR=$(subst \,/,$(shell pwd))
    export OS=WIN32
else
    export TOPDIR=$(shell pwd)
    export OS=LINUX
endif

.PHONY : all	 # .PHONY ignores files named all
all: $(BIN)	 # all is dependent on $(BIN) to be complete
	make -C src/locale
	make -C src/strings

.PHONY : clean	 # .PHONY ignores files named clean
clean:
	-$(RM) -f $(OBJ) *.lst *.err   # '-' causes errors not to exit the process

