/**
 * prvhash16.h version 4.3.1
 *
 * The inclusion file for the "prvhash16" hash function. For demonstration
 * purposes, not practically useful.
 *
 * Description is available at https://github.com/avaneev/prvhash
 *
 * License
 *
 * Copyright (c) 2020-2023 Aleksey Vaneev
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#ifndef PRVHASH16_INCLUDED
#define PRVHASH16_INCLUDED

#include "prvhash_core.h"

/**
 * PRVHASH hash function (16-bit variables). Produces a hash of the specified
 * message, string, or binary data block. This function does not apply
 * endianness correction to the resulting hash.
 *
 * @param Msg0 The message to produce a hash from. The alignment of this
 * pointer is unimportant.
 * @param MsgLen Message's length, in bytes.
 * @param[out] Hash0 The resulting hash. The length of this buffer should be
 * equal to HashLen. On systems where this is relevant, this address should be
 * aligned to 32 bits.
 * @param HashLen The required hash length, in bytes; should be >= 4, in
 * increments of 2; no higher-value limits.
 * @param UseSeed Optional value, to use instead of the default seed. To use
 * the default seed, set to 0. The UseSeed value can have any bit length and
 * any statistical quality, and is used only as an additional entropy source.
 */

static inline void prvhash16( const void* const Msg0, const size_t MsgLen,
	void* const Hash0, const size_t HashLen, uint32_t UseSeed )
{
	const uint8_t* Msg = (const uint8_t*) Msg0;
	uint8_t* const Hash = (uint8_t*) Hash0;

	memset( Hash, 0, HashLen );

	typedef uint16_t state_t;

	state_t Seed = 0x128D; // The state after 5 PRVHASH rounds from the
	state_t lcg = 0x8D5B; // "zero-state".
	*(state_t*) Hash = 0x0932;

	const state_t* const HashEnd = (state_t*) ( Hash + HashLen );
	state_t* hc = (state_t*) Hash;
	state_t fbm = 0x0101;

	if( MsgLen > 0 )
	{
		fbm <<= ( Msg[ MsgLen - 1 ] >> 7 );
	}

	size_t k;

	if( UseSeed != 0 )
	{
		for( k = 0; k < 2; k++ )
		{
			Seed ^= (state_t) UseSeed;
			lcg ^= (state_t) UseSeed;

			prvhash_core16( &Seed, &lcg, hc );

			if( ++hc == HashEnd )
			{
				hc = (state_t*) Hash;
			}

			UseSeed >>= 16;
		}
	}

	const uint8_t* const MsgEnd = Msg + MsgLen;

	while( Msg <= MsgEnd )
	{
		state_t msgw;

		if( Msg < MsgEnd )
		{
			msgw = *Msg;
		}
		else
		{
			msgw = (state_t) ( fbm & 0xFF );
			fbm = 0;
		}

		if( Msg < MsgEnd - 1 )
		{
			msgw |= (state_t) ( (state_t) Msg[ 1 ] << 8 );
		}
		else
		{
			msgw |= (state_t) ( fbm & 0xFF00 );
			fbm = 0;
		}

		Seed ^= msgw;
		lcg ^= msgw;

		prvhash_core16( &Seed, &lcg, hc );

		if( ++hc == HashEnd )
		{
			hc = (state_t*) Hash;
		}

		Msg += sizeof( state_t );
	}

	const size_t fc = HashLen + ( MsgLen < HashLen - sizeof( state_t ) ?
		(uint8_t*) HashEnd - (uint8_t*) hc : 0 );

	for( k = 0; k <= fc; k += sizeof( state_t ))
	{
		prvhash_core16( &Seed, &lcg, hc );

		if( ++hc == HashEnd )
		{
			hc = (state_t*) Hash;
		}
	}

	for( k = 0; k < HashLen; k += sizeof( state_t ))
	{
		*hc = prvhash_core16( &Seed, &lcg, hc );

		if( ++hc == HashEnd )
		{
			hc = (state_t*) Hash;
		}
	}
}

#endif // PRVHASH16_INCLUDED
