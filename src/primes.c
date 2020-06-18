#include "primes.h"

int is_prime(uint32 n) {
  if (n <= 3)
    return n > 1;

  /* Bitwise & should be faster than modulo arithmetic */
  if ((n & 1) == 0 || n % 3 == 0)
    return 0;

  /* Exploit the 6k +/- 1 rule (3x faster than testing all m per Wikipedia)  */
  for (uint32 i = 5; i*i <= n; i += 6)
    if (n % i == 0 || n % (i + 2) == 0)
      return 0;

  return 1;
}

uint32 next_prime(uint32 n) {
  while (!is_prime(++n))
    ;
  return n;
}
