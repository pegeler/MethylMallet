#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Assign Gene ID to each Methylation State
Created on Fri Jan 10 18:21:49 2020
"""

import re
import sys

sys.stderr.write("Work in progress\n")
sys.exit(1)

# Load up genes file
pattern = re.compile(r'ID=(.+?);')
genes_file = open(sys.argv[2], 'rt')
genes = []
for line in genes_file:
    gene = line.split()
    gene[-1] = pattern.match(gene[-1]).groups()[0]
    genes.append(gene)

# Assign gene name to each row of methylation dataset
methylation_file = open(sys.argv[1], 'rt')

# Write header
header = methylation_file.readline()
# split and insert 'name' column name here
sys.stdout.write(','.join(header))

for line in methylation_file:
    pass