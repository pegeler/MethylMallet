#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Assign Gene ID to each Methylation State
Created on Fri Jan 10 18:21:49 2020
"""

import re
import sys
import collections

sys.stderr.write("Work in progress\n")
sys.exit(1)

# Load up genes file
pattern = re.compile(r'ID=(.+?);')
Gene = collections.namedtuple('Gene', ['chrom', 'start', 'stop', 'strand', 'ID'])
genes_file = open(sys.argv[2], 'rt')
genes = []
for line in genes_file:
    gene = line.split()
    gene[:3] = [int(x) for x in gene[:3]]
    gene[-1] = pattern.match(gene[-1]).groups()[0]
    genes.append(Gene(*gene))

iter_genes = iter(genes)
candidate_gene = next(iter_genes, None)

# Assign gene name to each row of methylation dataset
methylation_file = open(sys.argv[1], 'rt')

# Write header
header = methylation_file.readline().split(',')
header = header[:4] + ['gene_id'] + header[4:]
sys.stdout.write(','.join(header))

for line in methylation_file:
    line = line.split(',')

    # Exhausted the gene list
    if not candidate_gene:
        sys.stdout.write(','.join(line[:4] + [''] + line[4:]))
        continue

    chrom, pos, strand = int(line[0]), int(line[1]), line[2]
    
    # If match, write ID, otherwise null string
    if (chrom == candidate_gene.chrom and 
            candidate_gene.start <= pos <= candidate_gene.end and
            strand == candidate_gene.strand):
        sys.stdout.write(','.join(line[:4] + [candidate_gene.ID] + line[4:]))
        continue
    else:
        sys.stdout.write(','.join(line[:4] + [''] + line[4:]))
        
    # Decide if we need a new candidate
    while (candidate_gene and 
               candidate_gene.chrom < chrom or
               candidate_gene.start < pos):
        candidate_gene = next(iter_genes, None)
