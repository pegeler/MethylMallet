#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import os
import re
import gzip

# Process file names
work_dir = sys.argv[1]
files = [os.path.basename(i) for i in sys.argv[2:]]

# Get tags
regex = re.compile(r'^(GSM[0-9]+)')
tags = [regex.match(f).group(1) for f in files]

# Open file handles
fout = open(os.path.join(work_dir, 'out.csv'), 'wt')
fin = gzip.open(os.path.join(work_dir, 'long.csv.gz'), 'rt')

# Header
fout.write('chrom,pos,strand,mc_class,' + ','.join(tags) + '\n')

# Initialize values for loop
line = fin.readline().strip().split(',')
key = line[:4]
values = {line[-2]: line[-1]}

# Loop over the infile
for line in fin:
    line = line.strip().split(',')

    if line[:4] != key:
        # Write out data line for previous key
        data_line = ','.join(key) + ','
        data_line += ','.join([values.get(v, '') for v in tags]) + '\n'
        values.clear()
        fout.write(data_line)
        key = line[:4]

    # Add current line
    values.update({line[-2]: line[-1]})

# Write last line
data_line = ','.join(key) + ','
data_line += ','.join([values.get(v, '') for v in tags]) + '\n'
fout.write(data_line)

# Bye!
fout.close()
fin.close()
