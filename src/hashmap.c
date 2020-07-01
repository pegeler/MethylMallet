#include "hashmap.h"

static Node **h;
static unsigned int buckets;

static unsigned int hash(char *key)
{
  unsigned int hashval=0L;
  while (*key != '\0')
    hashval = hashval * 31 + *key++;
  return (unsigned int) hashval % buckets;
}

int h_init(unsigned int size)
{
  size = size * 1.33f;
  if (size < 17)
    buckets = 17;
  else
    buckets = is_prime(size) ? size : next_prime(size);

  h = malloc(buckets * sizeof(Node *));

  return h == NULL ? 0 : 1;
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
  Node *p = h_get(key);

  if (p != NULL) {
    strcpy(dest, p->val);
    p->val[0] = '\0';
    return 1;
  } else {
    dest[0] = '\0';
    return 0;
  }
}

void h_ins(char *key, char *val)
{
  Node *p = h_get(key);
  unsigned int hashval;

  if (p == NULL) {
    p = (Node *) malloc(sizeof(*p));
    p->key = (char *) malloc(sizeof(char) * MAX_FIELD);
    p->val = (char *) malloc(sizeof(char) * MAX_FIELD);
    strcpy(p->key, key);
    strcpy(p->val, val);
    hashval = hash(key);
    p->next = h[hashval];
    h[hashval] = p;
  } else {
    strcpy(p->val, val);
  }
}
