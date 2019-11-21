#!/bin/bash

progname="$( basename "$0" )"
progpath="$( dirname "$( readlink -f "$0" )" )"

set -e

# Standardize sort order
export LC_ALL="en_US.UTF-8"

# Speed over compression ratio
export GZIP_OPT=-1

# Usage -----------------------------------------------------------------------
function usage {
  cat << EOF >&2
usage:
$progname [-h] [-k] -n NMERGE -S BUFFER_SIZE -d DIR -o OUT_FILE FILE [FILE ...]

Do a full outer join of tab-separated methylation files.

positional arguments:
  FILE            files to be joined

required arguments:
  -d DIR          working directory (doesn't need to exist but should be empty)
  -o OUT_FILE     file name to be output to

optional arguments:
  -h              show this help message and exit
  -k              keep intermediary files
  -n NMERGE       number of files to merge simultaneously
  -S BUFFER_SIZE  buffer size allocated to sorting operation
EOF
  exit 1
}

# Options ---------------------------------------------------------------------
while getopts ":d:S:o:n:kh" opt; do
  case $opt in
    d)
      work_dir=$OPTARG
      ;;
    S)
      buffer_size="--buffer-size=$OPTARG"
      ;;
    o)
      out_file=$OPTARG
      ;;
    h)
      usage
      ;;
    k)
      keep_files=true
      ;;
    n)
      batch_size="--batch-size=$OPTARG"
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
  file_name=$(basename "$f")
  file_stem=$(basename "$f" .gz)
  echo -n "$progname: $(printf '% 5i' $i)/$#: $file_name" >&2

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
    awk -v FILE_STEM="$file_stem" -f "$progpath/awk/append_tag.awk" | \
    sort -t, \
      -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -k 5,5 \
      $buffer_size \
      -T "$work_dir" \
      -o "${work_dir}/sorted_${file_stem}"

  # Time stats
  echo " ($((SECONDS - CHECKPOINT)) seconds)" >&2
  CHECKPOINT=$SECONDS
  ((i++))
done

# LONG FILE -------------------------------------------------------------------
echo -n "$progname: Spreading the data..." >&2

sort  -t, \
      -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 -k 5,5 -m \
      $buffer_size \
      -T "$work_dir" \
      $batch_size \
      --compress-program=gzip \
      "${work_dir}/sorted_"* | \
  "$progpath/python/spread.py" "$@" | \
  gzip > "$out_file"

test -z "$keep_files" && rm "${work_dir}/sorted_"*

echo " ($((SECONDS - CHECKPOINT)) seconds)" >&2
CHECKPOINT=$SECONDS

# DONE ------------------------------------------------------------------------

echo "$progname: Success! All files joined. ($SECONDS seconds total)" >&2
