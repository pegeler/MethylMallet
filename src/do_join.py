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
import os.path

# Get inputs
input_file = sys.argv[1]
work_dir, file_name = os.path.split(input_file)

# Open files
temp = open(os.path.join(work_dir, 'tmp.csv'), 'w+')
work = open(os.path.join(work_dir, 'out.csv'), 'r')
infile = open(input_file, 'r')

# Header
header = work.readline().strip() + ','
header += re.search(r'^sorted_(.*?)_', file_name)[1] + '\n'
temp.write(header)

# Preload first line from stdin
candidate = infile.readline().strip().split()

# Loop over working file
for line in work:
    temp.write(line.strip() + ',')
    if line.split(',', 4)[:4] == candidate[:4]:
        temp.write(candidate[-1])
        candidate = infile.readline().strip().split()
    temp.write('\n')

# Close file connections
temp.close()
work.close()
infile.close()

# At last, copy tmp into out
shutil.move(os.path.join(work_dir, 'tmp.csv'),
            os.path.join(work_dir, 'out.csv'))
