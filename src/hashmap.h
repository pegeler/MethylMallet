#ifndef HASHMAP_H
#define HASHMAP_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "primes.h"
#include "config.h"

typedef struct node {
  char *key;
  char *val;
  struct node *next;
} Node;

int h_init(unsigned int size);
Node *h_get(char *key);
void h_ins(char *key, char *val);
int h_pop(char *key, char *dest);

#endif
