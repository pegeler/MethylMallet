#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from sys import argv, stdout, stdin
import os
import re

# Process file names
files = [os.path.basename(i) for i in argv[1:]]

# Get tags
regex = re.compile(r'^(GSM[0-9]+)')
tags = [regex.match(f).group(1) for f in files]

# Header
stdout.write('chrom,pos,strand,mc_class,' + ','.join(tags) + '\n')

# Initialize values for loop
line = stdin.readline().strip().split(',')
key = line[:4]
values = {line[-2]: line[-1]}

# Loop over the infile
for line in stdin:
    line = line.strip().split(',')

    if line[:4] != key:
        # Write out data line for previous key
        data_line = ','.join(key) + ','
        data_line += ','.join([values.get(v, '') for v in tags]) + '\n'
        values.clear()
        stdout.write(data_line)
        key = line[:4]

    # Add current line
    values.update({line[-2]: line[-1]})

# Write last line
data_line = ','.join(key) + ','
data_line += ','.join([values.get(v, '') for v in tags]) + '\n'
stdout.write(data_line)
