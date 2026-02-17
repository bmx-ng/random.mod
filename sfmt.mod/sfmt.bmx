' Copyright (c) 2007-2026, Bruce A Henderson
' All rights reserved.
'
' Redistribution and use in source and binary forms, with or without
' modification, are permitted provided that the following conditions are met:
'     * Redistributions of source code must retain the above copyright
'       notice, this list of conditions and the following disclaimer.
'     * Redistributions in binary form must reproduce the above copyright
'       notice, this list of conditions and the following disclaimer in the
'       documentation and/or other materials provided with the distribution.
'     * Neither the name of Bruce A Henderson nor the
'       names of its contributors may be used to endorse or promote products
'       derived from this software without specific prior written permission.
'
' THIS SOFTWARE IS PROVIDED BY Bruce A Henderson ``AS IS'' AND ANY
' EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
' WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
' DISCLAIMED. IN NO EVENT SHALL Bruce A Henderson BE LIABLE FOR ANY
' DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
' (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
' LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
' ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
' (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
' SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'
SuperStrict

Rem
bbdoc: Random Numbers - SFMT
End Rem
Module Random.SFMT

ModuleInfo "Version: 1.08"
ModuleInfo "License: BSD"
ModuleInfo "Copyright: SFMT - 2006-2017 Mutsuo Saito, Makoto Matsumoto and Hiroshima"
ModuleInfo "Copyright: Wrapper - 2007-2026 Bruce A Henderson"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.08"
ModuleInfo "History: Added new Random methods."
ModuleInfo "History: 1.07"
ModuleInfo "History: Added GetName()."
ModuleInfo "History: 1.06"
ModuleInfo "History: Integrated into new BRL.Random API."
ModuleInfo "History: 1.05"
ModuleInfo "History: Created TRandom to support multiple generators."
ModuleInfo "History: Aligned pointer creation."
ModuleInfo "History: 1.04"
ModuleInfo "History: Update to SFMT 1.5.1"
ModuleInfo "History: Refactored."
ModuleInfo "History: 1.03"
ModuleInfo "History: Update to SFMT 1.4.1"
ModuleInfo "History: Updated for NG."
ModuleInfo "History: 1.02"
ModuleInfo "History: Fix for PPC Mac compile."
ModuleInfo "History: 1.01"
ModuleInfo "History: Automatically initializes via SeedRnd() if required."
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Version (SFMT 1.2)"

ModuleInfo "CC_OPTS: -DMEXP=19937"
ModuleInfo "CC_OPTS: -fno-strict-aliasing"
ModuleInfo "CC_OPTS: -std=c11"

Import Random.Core

?x86
ModuleInfo "CC_OPTS: -msse2 -DHAVE_SSE2"
?x64
ModuleInfo "CC_OPTS: -msse2 -DHAVE_SSE2"
?arm
ModuleInfo "CC_OPTS: -DHAVE_NEON"
?arm64
ModuleInfo "CC_OPTS: -DHAVE_NEON"
?

Import "common.bmx"

Rem
bbdoc: An instance of a random number generator.
End Rem
Type TSFMTRandom Extends TRandom

	Const SIGNBIT_64:ULong = $8000000000000000:ULong
	Field sfmtPtr:Byte Ptr
	Field rnd_seed:Int
	
	Method New()
		sfmtPtr = bmx_sfmt_init_gen_rand(Null, GenerateSeed())
	End Method

	Method New(seed:Int)
		rnd_seed = seed
		sfmtPtr = bmx_sfmt_init_gen_rand(Null, seed)
	End Method
	
	Method SeedRnd(seed:Int)
		rnd_seed = seed
		bmx_sfmt_init_gen_rand(sfmtPtr, seed)
	End Method

	Method RndSeed:Int()
		Return rnd_seed
	End Method

	Method Rand:Int( min_value:Int, max_value:Int = 1 )
		Local Range:Double = max_value - min_value
		If Range > 0 Return Int( bmx_genrand_res53(sfmtPtr)*(1:Double+Range) )+min_value
		Return Int( bmx_genrand_res53(sfmtPtr)*(1:Double-Range) )+max_value
	End Method

	Method Rnd:Double( min_value!=1,max_value!=0 )
		If max_value > min_value Return RndDouble() * (max_value - min_value) + min_value
		Return RndDouble() * (min_value - max_value) + max_value
	End Method

	Method Rand64:Long( min_value:Long, max_value:Long = 1 )
		Local Range:Long = max_value - min_value
		If Range > 0 Return Long( bmx_genrand_res53(sfmtPtr) * (1:Long + Range) ) + min_value
		Return Long( bmx_genrand_res53(sfmtPtr) * (1:Long - Range) ) + max_value
	End Method
	
	Method RndFloat:Float()
		Return Float(bmx_genrand_real3(sfmtPtr))
	End Method
	
	Method RndDouble:Double()
		Return bmx_genrand_res53(sfmtPtr)
	End Method

	Method RangeULong:ULong(lo:ULong, hi:ULong)
		If lo > hi Then
			Local t:ULong = lo
			lo = hi
			hi = t
		End If

		Local span:ULong = hi - lo + 1:ULong

		' span==0 means full 0..2^64-1
		If span = 0:ULong Then
			Local v:ULong
			bmx_gen_rand64(sfmtPtr, v)
			Return v
		End If

		Local max:ULong = $FFFFFFFFFFFFFFFF:ULong
		Local limit:ULong = (max / span) * span - 1:ULong

		Local r:ULong
		Repeat
			bmx_gen_rand64(sfmtPtr, r)
		Until r <= limit

		Return lo + (r Mod span)
	End Method

	Method RandomByte:Byte(minValue:Byte, maxValue:Byte = 1)
		Return Byte( RangeULong(ULong(minValue), ULong(maxValue)) )
	End Method

	Method RandomShort:Short(minValue:Short, maxValue:Short = 1)
		Return Short( RangeULong(ULong(minValue), ULong(maxValue)) )
	End Method

	Method RandomUInt:UInt(minValue:UInt, maxValue:UInt = 1)
		Return UInt( RangeULong(ULong(minValue), ULong(maxValue)) )
	End Method

	Method RandomULong:ULong(minValue:ULong, maxValue:ULong = 1)
		Return RangeULong(minValue, maxValue)
	End Method

	Method RandomULongInt:ULongInt(minValue:ULongInt, maxValue:ULongInt = 1)
		Return ULongInt( RangeULong(ULong(minValue), ULong(maxValue)) )
	End Method

	Method RandomSizeT:Size_T(minValue:Size_T, maxValue:Size_T = 1)
		Return Size_T( RangeULong(ULong(minValue), ULong(maxValue)) )
	End Method

	Method RandomLong:Long(minValue:Long, maxValue:Long = 1)
		Local lo:ULong = ULong(minValue) ~ SIGNBIT_64
		Local hi:ULong = ULong(maxValue) ~ SIGNBIT_64

		Local u:ULong = RangeULong(lo, hi)

		Return Long(u ~ SIGNBIT_64)
	End Method

	Method RandomInt:Int(minValue:Int, maxValue:Int = 1)
		Return Int(RandomLong(minValue, maxValue))
	End Method

	Method RandomLongInt:LongInt(minValue:LongInt, maxValue:LongInt = 1)
		Return LongInt(RandomLong(minValue, maxValue))
	End Method

	Method Delete()
		If sfmtPtr Then
			bmx_sfmt_free(sfmtPtr)
			sfmtPtr = Null
		End If
	End Method

	Method GetName:String()
		Return "SFMT"
	End Method

End Type


Private
Type TSFMTRandomFactory Extends TRandomFactory
	
	Method New()
		Super.New()
		Init()
	End Method
	
	Method GetName:String()
		Return "SFMT"
	End Method
	
	Method Create:TRandom(seed:Int)
		Return New TSFMTRandom(seed)
	End Method

	Method Create:TRandom()
		Return New TSFMTRandom()
	End Method
		
End Type

New TSFMTRandomFactory
