#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Low resource full outer join

Hacky approach, but necessary because of file sizes
Please don't judge :)

Plan of attack
===========================
- Get new data from stdin
- Read existing table as working/out.csv
- Write concatenated lines to working/tmp.csv
- Copy tmp.csv to out.csv

Created on Mon Oct 28 19:08:07 2019
@author: Paul W. Egeler, M.S.
"""
import sys
import re
import shutil

temp = open('working/tmp.csv', 'w+')
work = open('working/out.csv', 'r')

# Header ---
header = work.readline().strip()
header += ',' + re.search(r'^sorted_(.*?)_', sys.argv[1])[1] + '\n'
temp.write(header)

del header

# Preload first line from stdin
candidate = sys.stdin.readline().strip().split()

# Loop over working file
for line in work:
    line = line.strip()
    if line.split(',', 4)[:4] == candidate[:4]:
        # Write line!
        temp.write(line + ',' + candidate[-1] + '\n')
        # Load in next line
        candidate = sys.stdin.readline().strip().split()
    else:
        temp.write(line + ',\n')

# Close file connections
temp.close()
work.close()

# At last, copy tmp into out
shutil.move('working/tmp.csv', 'working/out.csv')
