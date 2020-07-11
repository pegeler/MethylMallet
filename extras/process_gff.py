#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Prepare gff file for further processing
"""
import re
import sys

pattern = re.compile(r'ID=(.+?);')
genes_file = open(sys.argv[1], 'rt')

# Header
sys.stdout.write('ID\tchrom\tstart\tend\tstrand\n')

column_order = [8, 0, 3, 4, 6]

for line in genes_file:
    gene = line.split('\t')
    if gene[2] != 'gene':
        continue
    gene[0] = gene[0][3:]
    gene[8] = pattern.match(gene[8]).groups()[0]
    sys.stdout.write('\t'.join(gene[i] for i in column_order) + '\n')
