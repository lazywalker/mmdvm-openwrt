#
# Copyright 2019 BD7MQB <bd7mqb@qq.com>
# This is free software, licensed under the GNU GENERAL PUBLIC LICENSE, Version 2.0
#

# for lua 5.3
# CXXFLAGS = -g -O3 -Wall -std=c++0x -I/usr/local/Cellar/lua/5.3.5_1/include/lua
# LDFLAGS = -lm -L/usr/local/Cellar/lua/5.3.5_1/lib

# for lua 5.1
CXXFLAGS = -g -O3 -Wall -std=c++0x -I/usr/local/Cellar/lua\@5.1/5.1.5_8/include/lua5.1
LDFLAGS = -lm -L/usr/local/Cellar/lua\@5.1/5.1.5_8/lib -bundle -undefined dynamic_lookup

# CXXFLAGS = -g -O3 -Wall -std=c++0x
# LDFLAGS = -llua -lm -shared

FPIC = -fPIC
OBJ = DMRLookup.o DMRId.o
LIB = mmdvm.so

%.o: %.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(FPIC) -c -o $@ $<

compile: $(OBJ)
	$(CXX) $(LDFLAGS) -o $(LIB) $(OBJ) 

install: compile
	mkdir -p $(DESTDIR)/usr/lib/lua
	cp $(LIB) $(DESTDIR)/usr/lib/lua/$(LIB)

clean:
	rm -f *.o *.so
