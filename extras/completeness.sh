#!/bin/bash

echo 'N_1,N_0,N_MISS'

tail -q -n +2 $1 | \
  cut -d, -f 1,2,3,4 --complement | \
  awk 'BEGIN{ FS=","; OFS="," }
    { 
      nmiss = 0
      n_0 = 0
      n_1 = 0
      for ( i=1; i <= NF; i++ ) { 
        if ( $i == 1 ) {
          n_1++
        } else if ( $i == 0 ) {
          n_0++
        } else {
          nmiss++
        }
      }
      print NR, n_1, n_0, nmiss
    }'

exit 0
