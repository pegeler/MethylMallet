#!/bin/bash

set -e

REFERENCE=2de1b2050d4223ff99eb39d23d4b7944

mkdir -p out

echo "Testing parallel..." >&2

../methyl_mallet -d work -j 2 -n 5 -S10M -o out/test.csv.gz data/GSM*

CHECKSUM=$(zcat out/test.csv.gz | md5sum | cut -d" " -f1)

if [[  "$REFERENCE" == "$CHECKSUM" ]]; then
  echo Parallel OK >&2
else
  echo Parallel NOT OK >&2
fi

echo "Testing single..." >&2

../methyl_mallet -d work -n 5 -S10M -o out/test.csv.gz data/GSM*

CHECKSUM=$(zcat out/test.csv.gz | md5sum | cut -d" " -f1)

if [[  "$REFERENCE" == "$CHECKSUM" ]]; then
  echo Single OK >&2
else
  echo Single NOT OK >&2
fi

rm out/test.csv.gz
