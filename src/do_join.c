#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libgen.h>

// Assume keys and first three fields are
// under 99 characters long (incl. \n)
#define BASE_LEN 100

int compare_keys(char* s1, char* s2)
{
  int f=0, c=0;
  while ( f < 4 && s1[c] )
  {
    // Comma: skip char and increment field
    if ( s1[c] == ',' ) {
      f++, c++;
      continue;
    }
    // No match
    if ( s1[c] != s2[c] ) return 0;
    c++;
  }
  return 1;
}

int main(int argc, char* argv[])
{
  // Get directory name
  char *dirc, *dname;
  dirc  = strdup(argv[1]);
  dname = dirname(dirc);

  // Construct working file paths
  char out_path[strlen(dname) + 9],
       tmp_path[strlen(dname) + 9];
  strcpy(out_path, dname);
  strcat(out_path, "/out.csv");
  strcpy(tmp_path, dname);
  strcat(tmp_path, "/tmp.csv");

  // Open files
  FILE *fin, *fout, *ftmp;
  fin  = fopen(argv[1],  "r");
  fout = fopen(out_path, "r");
  ftmp = fopen(tmp_path, "w");

  if ( fin == NULL  || fout == NULL || ftmp == NULL )
    return 1;

  // Read in header line
  int c, nf=0;
  while ( (c = fgetc(fout)) != '\n' )
  {
    putc(c, ftmp);
    // Track number of fields to dynamically allocate buffer
    if ( c == ',' ) nf++;
  }
  putc(',', ftmp);

  // Add Accession Tag
  for ( int i=0, in_tag=0; i < strlen(argv[1]); i++ )
  {
    if ( argv[1][i] == '_' ) {
      if ( in_tag++ ) {
        putc('\n', ftmp);
        break;
      } else {
        continue;
      }
    }
    if ( in_tag ) putc(argv[1][i], ftmp);
  }

  // File line buffers
  char line[BASE_LEN + 2 * nf], candidate[BASE_LEN];

  // Preload the candidate
  int rc;
  rc = fgets(candidate, BASE_LEN, fin) != NULL;

  // Iterate over lines
  while ( fgets(line, BASE_LEN + 2 * nf, fout) != NULL )
  {
    // Strip newline
    line[strlen(line) - 1] = '\0';
    fputs(line, ftmp);
    putc(',', ftmp);

    if ( rc && compare_keys(line, candidate) )
    {
      putc(candidate[strlen(candidate) - 2], ftmp);
      rc = fgets(candidate, BASE_LEN, fin) != NULL;
    }

    putc('\n', ftmp);
  }

  fclose(ftmp);

  rename(tmp_path, out_path);

  return 0;

}
