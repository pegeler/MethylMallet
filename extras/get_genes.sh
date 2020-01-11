#!/bin/bash

export LC_ALL=C

if [ ! -f TAIR10_GFF3_genes.gff ]; then
  echo "Downloading data from arabidopsis.org" >&2
  wget https://www.arabidopsis.org/download_files/Genes/TAIR10_genome_release/TAIR10_gff3/TAIR10_GFF3_genes.gff
fi

# awk '$3 == "gene"' TAIR10_GFF3_genes.gff > genes

# echo "chrom,start,end,strand,ID"
awk \
  '$3 == "gene" && /^Chr[[:digit:]]/ { print substr($1, 4, 1), $4, $5, $7, $9 }' \
  TAIR10_GFF3_genes.gff | \
  sort -k 1n,1 -k 2n,2 -k 3n,3 -k 4,4
