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

void h_ins(char *key, char *val)
{
  Node *p = h_get(key);
  unsigned int hashval;

  if (p == NULL) {
    p = (Node *) malloc(sizeof(*p));
    hashval = hash(key);
    p->key = key;
    p->val = val;
    p->next = h[hashval];
    h[hashval] = p;
  } else
    p->val = val;
}
