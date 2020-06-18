CXX = gcc
CXXFLAGS = -O2

.PHONY: all

all: ./bin/append_tag ./bin/spread

./bin/append_tag: ./src/append_tag.c
	$(CXX) $(CXXFLAGS) $< -o $@

./bin/hashmap.o: ./src/hashmap.c
	$(CXX) $(CXXFLAGS) $^ -o $@ -c

./bin/primes.o: ./src/primes.c
	$(CXX) $(CXXFLAGS) $^ -o $@ -c

./bin/spread.o: ./src/spread.c
	$(CXX) $(CXXFLAGS) $^ -o $@ -c

./bin/spread: ./bin/spread.o ./bin/hashmap.o ./bin/primes.o
	$(CXX) $(CXXFLAGS) $^ -o $@
