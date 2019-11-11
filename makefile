CXX = g++-8
CXXFLAGS=-std=c++17 -O3
LIBS=-lstdc++fs
DEPS=

BIN=./bin/
SRC=./src/

all: $(BIN)do_join

$(BIN)%: $(SRC)%.cpp
	$(CXX) $(CXXFLAGS) $< -o $@ $(LIBS)
