/*
Copyright (c) 2023 Bruce A Henderson

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
*/
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>

static inline double uint64_to_double(uint64_t v) {
    return (v >> 11) * (1.0/9007199254740992.0);
}

int bmx_secure_init() {
    return open("/dev/urandom", O_RDONLY);
}

void bmx_secure_destroy(int fd) {
    close(fd);
}

uint64_t bmx_secure_random(int fd) {
    uint64_t result;
    read(fd, &result, sizeof(result));
    return result;
}

double bmx_secure_next_double(int fd) {
	return uint64_to_double(bmx_secure_random(fd));
}
