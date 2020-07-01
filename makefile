CXX = gcc
CXXFLAGS = -O2

.PHONY: all

all: ./bin/append_tag ./bin/spread

./bin/append_tag: ./src/append_tag.c
	$(CXX) $(CXXFLAGS) $< -o $@

./bin/spread: ./src/spread.c ./src/hashmap.c ./src/primes.c
	$(CXX) $(CXXFLAGS) $^ -o $@
