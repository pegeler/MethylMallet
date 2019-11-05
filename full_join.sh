#!/bin/bash

progname=$(basename $0)

set -e

# Usage -----------------------------------------------------------------------
function usage {
  cat << EOF >&2
usage: $progname [-h] [-p] [-d DIR] [-S BUFFER_SIZE] [-o OUT_FILE]
                    FILE [FILE ...]

Do a full outer join of tab-separated methylation files.

positional arguments:
  FILE            file(s) to be joined

required arguments:
  -d DIR          working directory
  -o OUT_FILE     file name to be output to

optional arguments:
  -h,             show this help message and exit
  -p              do sorting operations using GNU parallel
  -S BUFFER_SIZE  buffer size allocated to sorting operation
EOF
  exit 1
}

# Options ---------------------------------------------------------------------
while getopts ":d:S:o:ph" opt; do
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
    h)
      usage
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

if [[ -z "$work_dir" || -z "$out_file" ]]; then
  echo "ERROR: Missing option(s)"
  usage
fi

mkdir -p "$work_dir"

# SORT ------------------------------------------------------------------------
echo "$progname: Sorting the inputs..." >&2

# Sort all of our input data files
if [[ -n "$do_par" && -x "$(command -v parallel)" ]]; then
  echo "$progname: Sorting files in parallel" >&2
  parallel --eta --noswap --load 80% \
    $(printf 'tail -q -n +2 {} | sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -S %s -T %s -o "%s/sorted_{/}"' $buffer_size $work_dir $work_dir) \
    ::: "$@"
else
  echo "$progname: Sorting files one-by-one" >&2
  for f in "$@"; do
    echo "$progname:   Working on $(basename $f)" >&2
    tail -q -n +2 "$f" | \
      sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -S $buffer_size -T $work_dir -o "${work_dir}/sorted_$(basename $f)"
  done
fi

# KEY FILE --------------------------------------------------------------------
echo "$progname: Making the key file..." >&2

# Put down the header
echo "chrom,pos,strand,mc_class" > ${work_dir}/out.csv

# Find the keys and write to csv
sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -u -m -S $buffer_size -T $work_dir ${work_dir}/sorted_* | \
  cut -f 1,2,3,4 | \
  tr '\t' , \
  >> ${work_dir}/out.csv

# APPEND ----------------------------------------------------------------------
echo "$progname: Appending columns..." >&2

# Append columns one-by-one using python3 script
for f in ${work_dir}/sorted_*; do
  echo "$progname:   Working on $(basename $f)" >&2
  python3 src/do_join.py "$f"
done

# DONE ------------------------------------------------------------------------
rm ${work_dir}/sorted_*

mv "${work_dir}/out.csv" "$out_file"

echo "$progname: Success! All files joined." >&2
echo "$progname: Combined comma-separated file saved in '$out_file'" >&2
