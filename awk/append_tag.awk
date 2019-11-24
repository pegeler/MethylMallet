BEGIN {
  OFS=","

  # Get tag
  match(FILE_STEM, /^GSM[0-9]+/)
  FILE_TAG = substr(FILE_STEM, RSTART, RLENGTH)

  # Find out if the first line has headers
  getline;
  if ($1 != "chrom") {
    print $1, $2, $3, $4, FILE_TAG, $7
  }

}
{

  print $1, $2, $3, $4, FILE_TAG, $7

}
