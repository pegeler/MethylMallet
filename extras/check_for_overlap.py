#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Checking for overlap in gene annotation file

Created on Sat Jan 11 02:01:58 2020

@author: pablo
"""
genes_file = open('dat/genes', 'rt')

for line in genes_file:
    gene = line.split()
    gene[:3] = [int(x) for x in gene[:3]]
    gene[-1] = pattern.match(gene[-1]).groups()[0]
    genes.append(Gene(*gene))

iter_genes = iter(genes)

next_gene = next(iter_genes, None)

while next_gene:
    current_gene, next_gene = next_gene, next(iter_genes, None)
    
    try:
        if current_gene.chrom != next_gene.chrom: 
            continue
    except AttributeError:
        continue

    if current_gene.stop > next_gene.start:
        print(current_gene)
        print(next_gene)
        print('-' * 78)
