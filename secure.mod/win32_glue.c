/*
Copyright (c) 2023-2026 Bruce A Henderson

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
#include <Windows.h>
#include <Wincrypt.h>
#include <stdint.h>

static inline double uint64_to_double(uint64_t v) {
    return (v >> 11) * (1.0/9007199254740992.0);
}

HCRYPTPROV bmx_secure_init() {
    HCRYPTPROV prov;
    CryptAcquireContext(&prov, NULL, NULL, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
    return prov;
}

void bmx_secure_destroy(HCRYPTPROV prov) {
    CryptReleaseContext(prov, 0);
}

uint64_t bmx_secure_random(HCRYPTPROV prov) {
    uint64_t result;
    CryptGenRandom(prov, sizeof(result), (BYTE *)&result);
    return result;
}

double bmx_secure_next_double(HCRYPTPROV prov) {
	return uint64_to_double(bmx_secure_random(prov));
}
