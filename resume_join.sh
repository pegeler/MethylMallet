#!/bin/bash

echo "resuming..." >&2

progname="$( basename "$0" )"
progpath="$( dirname "$( readlink -f "$0" )" )"

CHECKPOINT=$SECONDS

set -e

# Usage -----------------------------------------------------------------------
function usage {
  cat << EOF >&2
usage: $progname [-h] [-k] -d DIR -o OUT_FILE

Do a full outer join of tab-separated methylation files.
This resumes the file append process if for some reason
the script was prematurely terminated.

required arguments:
  -d DIR          working directory from previous call
  -o OUT_FILE     file name to be output to

optional arguments:
  -h              show this help message and exit
  -k              keep intermediary files
EOF
  exit 1
}

# Options ---------------------------------------------------------------------
while getopts ":d:o:kh" opt; do
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
    k)
      keep_files=true
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
echo -n "$progname: Resuming appending columns..." >&2
pushd "$progpath" > /dev/null
python3 -m src "${work_dir}/sorted_"*
popd > /dev/null
echo " ($((SECONDS - CHECKPOINT)) seconds)" >&2

# DONE ------------------------------------------------------------------------

mv "${work_dir}/out.csv" "$out_file"

test -z "$keep_files" && rm "${work_dir}/keys.csv" "${work_dir}/sorted_"*

echo "$progname: Success! All files joined. ($SECONDS seconds since resume)" >&2
