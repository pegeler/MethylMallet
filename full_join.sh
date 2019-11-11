#!/bin/bash

progname=$(basename $0)

set -e

# Usage -----------------------------------------------------------------------
function usage {
  cat << EOF >&2
usage: $progname [-h] [-d DIR] [-S BUFFER_SIZE] [-o OUT_FILE] FILE [FILE ...]

Do a full outer join of tab-separated methylation files.

positional arguments:
  FILE            file(s) to be joined

required arguments:
  -d DIR          working directory (doesn't need to exist but should be empty)
  -o OUT_FILE     file name to be output to

optional arguments:
  -h              show this help message and exit
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

echo "$progname: Sorting files one-by-one" >&2
CHECKPOINT=$SECONDS
i=1
for f in "$@"; do
  echo -n "$progname: $(printf '% 5i' $i)/$#: $(basename $f)" >&2

  # Find out if the first line has headers
  first_line=$(zcat "$f" | head -n 1 | cut -f 1)
  if [[ "$first_line" == "chrom" ]]; then
    start_line=+2
  else
    start_line=+1
  fi

  # Pipe it through the sort
  zcat "$f" | \
    tail -q -n $start_line | \
    sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -S $buffer_size -T $work_dir -o "${work_dir}/sorted_$(basename $f .gz)"

  # Time stats
  echo " ($((SECONDS - CHECKPOINT)) seconds)" >&2
  CHECKPOINT=$SECONDS
  ((i++))
done

# KEY FILE --------------------------------------------------------------------
echo -n "$progname: Making the key file..." >&2

# Put down the header
echo "chrom,pos,strand,mc_class" > ${work_dir}/out.csv

# Find the keys and write to csv
sort -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -u -m -S $buffer_size -T $work_dir ${work_dir}/sorted_* | \
  cut -f 1,2,3,4 | \
  tr '\t' , \
  >> ${work_dir}/out.csv

echo " ($((SECONDS - CHECKPOINT)) seconds)" >&2
CHECKPOINT=$SECONDS

# APPEND ----------------------------------------------------------------------
echo "$progname: Appending columns..." >&2

# Append columns one-by-one using python3 script
i=1
for f in ${work_dir}/sorted_*; do
  echo -n "$progname: $(printf '% 5i' $i)/$#: $(basename $f)" >&2
  test -f "bin/do_join" && bin/do_join "$f" || python3 python/do_join.py "$f"
  rm "$f"
  echo " ($((SECONDS - CHECKPOINT)) seconds)" >&2
  CHECKPOINT=$SECONDS
  ((i++))
done

# DONE ------------------------------------------------------------------------

mv "${work_dir}/out.csv" "$out_file"

echo "$progname: Success! All files joined." >&2
echo "$progname: Combined comma-separated file saved in '$out_file'" >&2
