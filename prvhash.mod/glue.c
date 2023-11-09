 /*
  Copyright (c) 2023 Bruce A Henderson
 
  Permission is hereby granted, free of charge, to any person obtaining a
  copy of this software and associated documentation files (the "Software"),
  to deal in the Software without restriction, including without limitation
  the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the
  Software is furnished to do so, subject to the following conditions:
 
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.
 */

#include "prvhash_core.h"

struct SState {
    uint64_t seed;
    uint64_t lcg;
    uint64_t hash;
};

void bmx_prvhash_seed(uint64_t seed, struct SState * state) {
    state->seed = seed;
    state->lcg = 0;
    state->hash = 0;

    for (int i = 0; i < 5; i++)
    {
        prvhash_core64(&state->seed, &state->lcg, &state->hash);
    }
}

uint64_t bmx_prvhash_next(struct SState * state) {
    return prvhash_core64(&state->seed, &state->lcg, &state->hash);
}

double bmx_prvhash_next_double(struct SState * state) {
    uint64_t rv = bmx_prvhash_next(state);
    return ( rv >> ( 64 - 53 )) * 0x1p-53;
}
