#include <stdio.h>
#include <libgen.h>
#include <string.h>
#include "hashmap.h"

#define TRUE         1
#define FALSE        0
#define MAX_LINE  1000
#define MAX_FIELD  100
#define KEY_FIELDS   4
#define N_FIELDS     6
#define FIELD_SEP  ','
#define trace(s) puts((s))

/* // Using a 2d char array instead
typedef struct {
  char chrom[MAX_FIELD];
  char pos[MAX_FIELD];
  char strand[MAX_FIELD];
  char mc_class[MAX_FIELD];
  char tag[MAX_FIELD];
  char state[MAX_FIELD];
} Record;
*/

char *get_tag(char *path)
{
  char *t, *u;
  t = basename(path);
  if ((u = strchr(t, '_')) != NULL)
    *u = '\0';
  char *out = (char *) malloc(strlen(t) * sizeof(*t) + 1);
  for (int i=0; (out[i] = t[i]) != '\0'; i++)
    ;
  return out;
}

void write_header(char **tags, int n)
{
  printf("chrom,pos,strand,mc_class");
  for (int i=0; i < n; i++)
    printf("%c%s", FIELD_SEP, tags[i]);
  putchar('\n');
}

void get_fs_loc(char *line, int *loc, int len)
{

  *loc++ = -1;
  for (int i=1; line[i] != '\0'; i++)
    if (line[i] == FIELD_SEP)
      *loc++ = i;
  *loc = len;
}

void process_record(char *line, char r[][MAX_FIELD])
{
  int fs[N_FIELDS + 1];
  int line_len = strlen(line);
  line[--line_len] = '\0';

  get_fs_loc(line, fs, line_len);

  for (int i=0; i < N_FIELDS; i++) {
    int j, start, len;
    start = fs[i] + 1;
    len = fs[i + 1] - start;
    for (j=0; j < len; j++)
      r[i][j] = *(line + start + j);
    r[i][j] = '\0';
  }

}

void assign_keys(char record[][MAX_FIELD], char keys[][MAX_FIELD])
{
  for (int i=0; i < KEY_FIELDS; i++)
    strcpy(keys[i], record[i]);
}

int compare_keys(char record[][MAX_FIELD], char keys[][MAX_FIELD])
{
  for (int i=0; i < KEY_FIELDS; i++)
    if (strcmp(record[i], keys[i]) != 0)
      return FALSE;
  return TRUE;
}

void write_line(char **tags, char keys[][MAX_FIELD], int len)
{
  char val[MAX_LINE];

  for (int i=0; i < KEY_FIELDS; i++) {
    if (i > 0)
      putchar(FIELD_SEP);
    fputs(keys[i], stdout);
  }

  for (int i=0; i < len; i++) {
    putchar(FIELD_SEP);
    h_pop(tags[i], val);
    if (val[0] > '\0')
      fputs(val, stdout);
  }
  putchar('\n');
}

int main(int argc, char *argv[])
{
  char line[MAX_LINE];
  char **tags = (char **) malloc(--argc * sizeof(char *));
  char record[N_FIELDS][MAX_FIELD], keys[KEY_FIELDS][MAX_FIELD];

  for (int i=0; i < argc; i++) {
    tags[i] = get_tag(argv[i+1]);
    h_ins(tags[i], "");
  }

  write_header(tags, argc);

  if (fgets(line, MAX_LINE, stdin) == NULL) {
    fprintf(stderr, "No lines\n");
    return 1;
  }

  process_record(line, record);
  assign_keys(record, keys);
  h_ins(record[4], record[5]);

  while (fgets(line, MAX_LINE, stdin) != NULL) {
    process_record(line, record);
    if (!compare_keys(record, keys)) {
      write_line(tags, keys, argc);
      assign_keys(record, keys);
    }
    h_ins(record[4], record[5]);
  }

  write_line(tags, keys, argc);

  return 0;
}
