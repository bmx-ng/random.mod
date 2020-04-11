
/*  Written in 2019 by David Blackman and Sebastiano Vigna (vigna@acm.org)

To the extent possible under law, the author has dedicated all copyright
and related and neighboring rights to this software to the public domain
worldwide. This software is distributed without any warranty.

See <http://creativecommons.org/publicdomain/zero/1.0/>. */

#include <stdint.h>
#include <stdio.h>

/* This is xoshiro256++ 1.0, one of our all-purpose, rock-solid generators.
   It has excellent (sub-ns) speed, a state (256 bits) that is large
   enough for any parallel application, and it passes all tests we are
   aware of.

   For generating just floating-point numbers, xoshiro256+ is even faster.

   The state must be seeded so that it is not everywhere zero. If you have
   a 64-bit seed, we suggest to seed a splitmix64 generator and use its
   output to fill s. */

typedef struct rng_state {
	uint64_t s[4];
} rng_state;
   
static inline uint64_t rotl(const uint64_t x, int k) {
	return (x << k) | (x >> (64 - k));
}

static inline uint64_t splitmix(uint64_t * x) {
	uint64_t z = (*x += 0x9e3779b97f4a7c15);
	z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
	z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
	return z ^ (z >> 31);
}

static inline double uint64_to_double(uint64_t v) {
	return (v >> 11) * (1.0/9007199254740992.0);
}

void bmx_xoshiro_seed(uint64_t seed, rng_state * state) {
	uint64_t x = seed;
	state->s[0] = splitmix(&x);
	state->s[1] = splitmix(&x);
	state->s[2] = splitmix(&x);
	state->s[3] = splitmix(&x);
}

uint64_t bmx_xoshiro_next(rng_state * state) {
	const uint64_t result = rotl(state->s[0] + state->s[3], 23) + state->s[0];

	const uint64_t t = state->s[1] << 17;

	state->s[2] ^= state->s[0];
	state->s[3] ^= state->s[1];
	state->s[1] ^= state->s[2];
	state->s[0] ^= state->s[3];

	state->s[2] ^= t;

	state->s[3] = rotl(state->s[3], 45);

	return result;
}

double bmx_xoshiro_next_double(rng_state * state) {
	return uint64_to_double(bmx_xoshiro_next(state));
}
