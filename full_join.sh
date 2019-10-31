#!/bin/bash

set -e

mkdir -p working

# SORT ------------------------------------------------------------------------
echo "$(basename $0): Sorting the inputs..." >&2

# Sort all of our input data files
if [ -x "$(command -v parallel)" ]; then
  echo "$(basename $0): Sorting files in parallel" >&2
  parallel --eta --noswap --load 80% \
    'tail -q -n +2 {} | sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -S 1G -o "working/sorted_{/}"' \
    ::: "$@"
else
  echo "$(basename $0): Sorting files one-by-one" >&2
  for f in "$@"; do
    echo "$(basename $0):   Working on $(basename $f .tsv)" >&2
    tail -q -n +2 "$f" | \
      sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -S 2G -o "working/sorted_$(basename $f)"
  done
fi

# KEY FILE --------------------------------------------------------------------
echo "$(basename $0): Making the key file..." >&2

# Put down the header
echo "chrom,pos,strand,mc_class" > working/out.csv

# Find the keys and write to csv
sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -u -m -S 2G working/sorted_*.tsv | \
  cut -f 1,2,3,4 | \
  tr '\t' , \
  >> working/out.csv

# APPEND ----------------------------------------------------------------------
echo "$(basename $0): Appending columns..." >&2

# Append columns one-by-one using python3 script
for f in working/sorted_*.tsv; do
  echo "$(basename $0):   Working on $(basename $f .tsv)" >&2
  cut -f 1,2,3,4,7 $f | python3 src/do_join.py "$(basename $f .tsv)"
done

# DONE ------------------------------------------------------------------------
rm working/sorted_*.tsv
echo "$(basename $0): Success! All files joined." >&2
echo "$(basename $0): Combined comma-separated file saved in 'working/out.csv'" >&2
