#!/bin/bash

if [ ! -f TAIR10_GFF3_genes.gff ]; then
  wget https://www.arabidopsis.org/download_files/Genes/TAIR10_genome_release/TAIR10_gff3/TAIR10_GFF3_genes.gff
fi

./process_gff.py TAIR10_GFF3_genes.gff > genes.tsv
