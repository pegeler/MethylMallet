#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import os
import re

files = [os.path.split(i) for i in sys.argv[1:]]
work_dir = files[0][0]

regex = re.compile(r'^sorted_(.*?)_')
tags = []
for _, file_name in files:
    tags.append(regex.match(file_name).group(1))

fout = open(os.path.join(work_dir, 'out.csv'), 'w')
fin = open(os.path.join(work_dir, 'long.csv'), 'r')

header = 'chrom,pos,strand,mc_class,'
header + ','.join(tags) + '\n'
fout.write(header)

key = []
data_line = ''
for line in fin:
    line = line.strip().split(',')
    if line[:4] == key:
        pass
    else:
        # Write out data line
        data_line += ',' + ','.join(map(str, sorted(values))) + '\n'
        fout.write(data_line)

        # Make new key and start new data line
        key = line[:4]
        data_line = ','.join(key)

        # Reset values
        values = {t: '' for t in tags}

        # Add current line
        values.update({line[-1]: line[-2]})


fout.close()
fin.close()
