#!/bin/bash

echo "resume..."
progname=$(basename $0)
CHECKPOINT=$SECONDS

set -e

# Usage -----------------------------------------------------------------------
function usage {
  cat << EOF >&2
usage: $progname [-h] [-d DIR] [-o OUT_FILE]

Do a full outer join of tab-separated methylation files.

required arguments:
  -d DIR          working directory (doesn't need to exist but should be empty)
  -o OUT_FILE     file name to be output to

optional arguments:
  -h              show this help message and exit
EOF
  exit 1
}

# Options ---------------------------------------------------------------------
while getopts ":d:S:o:ph" opt; do
  case $opt in
    d)
      work_dir=$OPTARG
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

if [[ -z "$work_dir" || -z "$out_file" ]]; then
  echo "ERROR: Missing option(s)"
  usage
fi

mkdir -p "$work_dir"

# APPEND ----------------------------------------------------------------------
echo "$progname: Resuming appending columns..." >&2

i=1
for f in ${work_dir}/sorted_*; do
  echo -n "$progname: $(printf '% 5i' $i)/unknown: $(basename $f)" >&2
  test -f "bin/do_join" && bin/do_join "$f" || python3 python/do_join.py "$f"
  rm "$f"
  echo " ($((SECONDS - CHECKPOINT)) seconds)" >&2
  CHECKPOINT=$SECONDS
  ((i++))
done

# DONE ------------------------------------------------------------------------

mv "${work_dir}/out.csv" "$out_file"

echo "$progname: Success! All files joined. ($SECONDS seconds since resume)" >&2
echo "$progname: Combined comma-separated file saved in '$out_file'" >&2
