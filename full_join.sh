#!/bin/bash

progname=$(basename $0)

set -e

# Usage -----------------------------------------------------------------------
function usage {
  echo "Usage: $progname [-d dir] [-S buffer_size] [-o out_file] [-p] FILE [FILE ...]" >&2
  exit 1
}

# Options ---------------------------------------------------------------------
while getopts ":d:S:o:p" opt; do
  case $opt in
    d)
      work_dir=$OPTARG
      ;;
    S)
      buffer_size=$OPTARG
      ;;
    o)
      out_file=$OPTARG
      ;;
    p)
      do_par=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

shift $((OPTIND-1))

if [[ -z "$buffer_size" ]]; then
  buffer_size=1024b
fi

mkdir -p "$work_dir"

# SORT ------------------------------------------------------------------------
echo "$progname: Sorting the inputs..." >&2

# Sort all of our input data files
if [[ -n "$do_par" && -x "$(command -v parallel)" ]]; then
  echo "$progname: Sorting files in parallel" >&2
  parallel --eta --noswap --load 80% \
    $(printf 'tail -q -n +2 {} | sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -S %s -o "%s/sorted_{/}"' $buffer_size $work_dir) \
    ::: "$@"
else
  echo "$progname: Sorting files one-by-one" >&2
  for f in "$@"; do
    echo "$progname:   Working on $(basename $f .tsv)" >&2
    tail -q -n +2 "$f" | \
      sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -S $buffer_size -o "${work_dir}/sorted_$(basename $f)"
  done
fi

# KEY FILE --------------------------------------------------------------------
echo "$progname: Making the key file..." >&2

# Put down the header
echo "chrom,pos,strand,mc_class" > ${work_dir}/out.csv

# Find the keys and write to csv
sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -u -m -S $buffer_size ${work_dir}/sorted_*.tsv | \
  cut -f 1,2,3,4 | \
  tr '\t' , \
  >> ${work_dir}/out.csv

# APPEND ----------------------------------------------------------------------
echo "$progname: Appending columns..." >&2

# Append columns one-by-one using python3 script
for f in ${work_dir}/sorted_*.tsv; do
  echo "$progname:   Working on $(basename $f .tsv)" >&2
  python3 src/do_join.py "$f"
done

# DONE ------------------------------------------------------------------------
rm ${work_dir}/sorted_*.tsv

mv "${work_dir}/out.csv" "$out_file"

echo "$progname: Success! All files joined." >&2
echo "$progname: Combined comma-separated file saved in '$out_file'" >&2
