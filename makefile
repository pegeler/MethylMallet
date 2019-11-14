CXX = gcc
CXXFLAGS=-O3 -std=gnu11
LIBS=
DEPS=

BIN=./bin/
SRC=./src/

all: $(BIN)do_join

$(BIN)%: $(SRC)%.c
	$(CXX) $(CXXFLAGS) $< -o $@ $(LIBS)
