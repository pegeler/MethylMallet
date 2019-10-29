#!/bin/bash

mkdir -p working

# Put down the header
echo "chrom,pos,strand,mc_class" > working/out.csv

# Start by finding the keys and writing to csv
tail -q -n +2 "$@" | \
  cut -f 1,2,3,4 | \
  sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -u -S 2G | \
  tr '\t' , \
  >> working/out.csv

# Append columns one-by-one using python3 script
for f in "$@"; do
  echo "Working on $(basename $f .tsv)" >&2
  tail -q -n +2 "$f" | \
    cut -f 1,2,3,4,7 | \
    sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -u -S 2G | \
    python3 do_join.py "$(basename $f .tsv)"
done

# Inform user of success
echo "${0}: Success! All files transposed." >&2
echo "${0}: Combined comma-separated file saved in 'working/out.csv'" >&2
