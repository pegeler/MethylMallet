#include <stdio.h>
#include <string.h>
#include "config.h"

#define FIELD_SEP '\t'

void process_line(char *l, char *t)
{
  for (int field=0; field < KEY_FIELDS; l++) {
    if (*l == FIELD_SEP)
      field++;
    putchar(*l);
  }

  fputs(t, stdout);

  for (l = strrchr(l, FIELD_SEP); *l != '\0'; l++)
    putchar(*l);
}

int main(int argc, char *argv[])
{
  char line[MAX_LINE], tag[MAX_FIELD];
  int i;

  // Get the tag
  for (i=0; (tag[i] = argv[1][i]) != '_'; i++)
    ;
  tag[i] = '\0';

  // Check for file header
  if (fgets(line, MAX_LINE, stdin) == NULL) {
    fprintf(stderr, "No lines in %s\n", argv[1]);
    return 1;
  }

  if (strncmp(line, "chrom", 5) != 0)
    process_line(line, tag);

  // Run through the rest of the file
  while (fgets(line, MAX_LINE, stdin) != NULL)
    process_line(line, tag);

  return 0;
}
