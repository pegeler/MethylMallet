#!/usr/bin/env python3
from sys import argv
import gzip

f1 = gzip.open(argv[1], 'rt')
f2 = gzip.open(argv[2], 'rt')

l1 = f1.readline().strip()
l2 = f2.readline().strip()

line = 1

while l1 and l2:
    if l1 != l2:
        print(str(line) + ": " + l1 + " -- " + l2)
    l1 = f1.readline().strip()
    l2 = f2.readline().strip()
    line += 1

print("Done!")
