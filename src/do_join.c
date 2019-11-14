#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libgen.h>

#pragma GCC diagnostic ignored "-Wunused-result"

#define LINE_LEN 5000
#define CANDIDATE_LEN 100

int compare_keys(char* s1, char* s2)
{
  int f=0, c=0;
  while ( f < 4 && s1[c] > '\0')
  {
    // Comma: skip char and increment field
    if ( s1[c] == ',' ) {
      f++, c++;
      continue;
    }

    // No match
    if ( s1[c] != s2[c] ) {
      return 0;
    }

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

  // File line buffers
  char line[LINE_LEN], candidate[CANDIDATE_LEN];

  // Read in header line
  int c;
  while ( (c = fgetc(fout)) != '\n' ) putc(c, ftmp);
  putc(',', ftmp);

  // Add Accession Tag
  int in_tag=0;
  for (int i=0; i < strlen(argv[1]); i++)
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

  // Preload the candidate
  fgets(candidate, CANDIDATE_LEN, fin);

  // Iterate over lines
  while ( fgets(line, LINE_LEN, fout) != NULL )
  {
    // Strip newline
    line[strlen(line) - 1] = '\0';
    fputs(line, ftmp);
    putc(',', ftmp);

    if ( compare_keys(line, candidate) )
    {
      putc(candidate[strlen(candidate) - 2], ftmp);
      fgets(candidate, CANDIDATE_LEN, fin);
    }

    putc('\n', ftmp);
  }

  fclose(ftmp);

  rename(tmp_path, out_path);

  return 0;

}
