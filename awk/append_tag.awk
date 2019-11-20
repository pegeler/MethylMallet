BEGIN {
  OFS=","
  match(FILE_STEM, /^GSM[0-9]+/)
  FILE_TAG = substr(FILE_STEM, RSTART, RLENGTH)
}
{

  print $1, $2, $3, $4, FILE_TAG, $7

}
