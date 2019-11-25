#!/bin/bash

progname="$( basename "$0" )"
progpath="$( dirname "$( readlink -f "$0" )" )"

set -e

# Standardize sort order
export LC_ALL=C

# Speed over compression ratio
export GZIP_OPT=-1

# Usage -----------------------------------------------------------------------
function usage {
  cat << EOF >&2
usage:
$progname [-h] [-j JOBS] [-k] [-n NMERGE] [-S BUFFER_SIZE]
          -d DIR -o OUT_FILE FILE [FILE ...]

Do a full outer join of tab-separated methylation files.

positional arguments:
  FILE            files to be joined

required arguments:
  -d DIR          working directory to store intermediary files
  -o OUT_FILE     file name to be output to

optional arguments:
  -h              show this help message and exit
  -j JOBS         number of parallel jobs using GNU parallel
  -k              keep intermediary files
  -n NMERGE       number of files to merge simultaneously
  -S BUFFER_SIZE  buffer size allocated to sorting operation
EOF
  exit 1
}

# Options ---------------------------------------------------------------------
while getopts ":d:S:o:n:j:kh" opt; do
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
    j)
      n_jobs=$OPTARG
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
CHECKPOINT=$SECONDS
if [[ -n "$n_jobs" && -x "$(command -v parallel)" ]]; then
  echo "$progname: Sorting files in parallel" >&2

  i=0
  for f in "$@"; do
    sorted_files[$i]="$work_dir/sorted_$( basename "$f" .gz )"
    ((++i))
  done

  parallel -j $n_jobs \
    'zcat "{1}" | awk -v FILE_STEM="{1/.}" -f "{2}/awk/append_tag.awk" | \
     sort -t, -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 {3} -T "{4}" -o "{4}/sorted_{1/.}"' \
    ::: "$@" ::: "$progpath" ::: $buffer_size ::: "$work_dir"

    echo "$progname: Intial sorting done in $((SECONDS - CHECKPOINT)) seconds." >&2
    CHECKPOINT=$SECONDS
else
  echo "$progname: Sorting files one-by-one" >&2
  i=0
  for f in "$@"; do
    file_name="$( basename "$f" )"
    file_stem="$( basename "$f" .gz )"
    sorted_files[$i]="$work_dir/sorted_$file_stem"
    echo -n "$progname: $(printf '% 5i' $(expr $i + 1))/$#: $file_name" >&2
    zcat "$f" | \
      awk -v FILE_STEM="$file_stem" -f "$progpath/awk/append_tag.awk" | \
      sort -t, \
        -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 \
        $buffer_size \
        -T "$work_dir" \
        -o "${sorted_files[$i]}"

    echo " ($((SECONDS - CHECKPOINT)) seconds)" >&2
    CHECKPOINT=$SECONDS
    ((++i))
  done
fi

# LONG FILE -------------------------------------------------------------------
echo -n "$progname: Spreading the data..." >&2

sort  -t, \
      -k 1n,1 -k 2n,2 -k 3,3 -k 4,4 \
      -m \
      $buffer_size \
      -T "$work_dir" \
      $batch_size \
      --compress-program=gzip \
      "${sorted_files[@]}" | \
  "$progpath/python/spread.py" "$@" | \
  gzip > "$out_file"

test -z "$keep_files" && rm "${sorted_files[@]}"

echo " ($((SECONDS - CHECKPOINT)) seconds)" >&2
CHECKPOINT=$SECONDS

# DONE ------------------------------------------------------------------------

echo "$progname: Success! All files joined. ($SECONDS seconds total)" >&2
