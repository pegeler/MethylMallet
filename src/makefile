CXX = gcc

.PHONY: all

all: append_tag spread

append_tag: append_tag.c
	$(CXX) $@.c -o ../bin/$@

spread: spread.c hashmap.c hashmap.h
	$(CXX) $@.c hashmap.c -o ../bin/$@
