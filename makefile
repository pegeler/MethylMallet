CXX = gcc

.PHONY: all

all: ./bin/append_tag ./bin/spread

./bin/append_tag: ./src/append_tag.c
	$(CXX) ./src/append_tag.c -o $@

./bin/spread: ./src/spread.c ./src/hashmap.c ./src/hashmap.h ./src/primes.c ./src/primes.h
	$(CXX) ./src/spread.c ./src/hashmap.c ./src/primes.c -o $@
