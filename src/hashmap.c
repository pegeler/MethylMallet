#include "hashmap.h"

#define BUCKETS 1999

static Node *h[BUCKETS];

static unsigned int hash(char *key)
{
  unsigned int hashval=0L;
  while (*key != '\0')
    hashval = hashval * 31 + *key++;
  return (unsigned int) hashval % BUCKETS;
}

Node *h_get(char *key)
{
  for (Node *p = h[hash(key)]; p != NULL; p = p->next)
    if (strcmp(p->key, key) == 0)
      return p;
  return NULL;
}

int h_pop(char *key, char *dest)
{
  unsigned int hashval = hash(key);
  Node *prev = NULL;

  for (Node *curr = h[hashval]; curr != NULL; curr = curr->next) {
    if (strcmp(curr->key, key) == 0) {
      // Resetting linked list
      if (prev == NULL)
        h[hashval] = curr->next;
      else
        prev->next = curr->next;

      // Copying data, free memory, and return
      strcpy(dest, curr->val);
      free(curr->key);
      free(curr->val);
      free(curr);
      return 1;
    }
    prev = curr;
  }

  // Key not found. Copying null string.
  dest[0] = '\0';
  return 0;
}

void h_ins(char *key, char *val)
{
  Node *p = h_get(key);
  unsigned int hashval;

  if (p == NULL) {
    p = (Node *) malloc(sizeof(*p));
    hashval = hash(key);
    p->key = strdup(key);
    p->val = strdup(val);
    p->next = h[hashval];
    h[hashval] = p;
  } else {
    free(p->val);
    p->val = strdup(val);
  }
}
