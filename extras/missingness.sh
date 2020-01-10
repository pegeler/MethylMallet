#!/bin/bash

echo 'ROW_NUMBER N_NONMISSING PROP_NONMISSING'

tail -q -n +2 $1 | \
  cut -d, -f 1,2,3,4 --complement | \
  awk -F, \
    '{ n = 0; for ( i=1; i <= NF; i++ ) { if ($i > "") n++ }; print NR, n, n / NF }'
