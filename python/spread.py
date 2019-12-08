#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from sys import argv, stdout, stdin
from os.path import basename
import re

def write_line(tags, key, values):
    data_line = ','.join(key) + ','
    data_line += ','.join([values.get(t, '') for t in tags]) + '\n'
    values.clear()
    stdout.write(data_line)

# Get tags
r = re.compile(r'^(GSM[0-9]+)')
tags = [r.match(basename(f)).group(1) for f in argv[1:]]

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
        write_line(tags, key, values)
        key = line[:4]
    values.update({line[-2]: line[-1]})
else:
    # Write last line
    write_line(tags, key, values)
