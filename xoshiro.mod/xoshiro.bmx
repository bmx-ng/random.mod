' Copyright (c) 2022 Bruce A Henderson
'
' This software is provided 'as-is', without any express or implied
' warranty. In no event will the authors be held liable for any damages
' arising from the use of this software.
'
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
'
'    1. The origin of this software must not be misrepresented; you must not
'    claim that you wrote the original software. If you use this software
'    in a product, an acknowledgment in the product documentation would be
'    appreciated but is not required.
'
'    2. Altered source versions must be plainly marked as such, and must not be
'    misrepresented as being the original software.
'
'    3. This notice may not be removed or altered from any source
'    distribution.
'
SuperStrict

Rem
bbdoc: Random Numbers - Xoshiro
End Rem
Module Random.Xoshiro

ModuleInfo "Version: 1.01"
ModuleInfo "License: zlib"
ModuleInfo "Copyright: Wrapper - 2022 Bruce A Henderson"
ModuleInfo "Copyright: xoshiro256++ - 2019 David Blackman and Sebastiano Vigna"

ModuleInfo "History: 1.01"
ModuleInfo "History: Added GetName()."
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import Random.Core
Import "src/xoshiro256plusplus.c"

Type TXoshiroRandom Extends TRandom
	
	Private
	
	Field rnd_state:SState
	Field rnd_seed:Int
	Const SIGNBIT_64:ULong = $8000000000000000:ULong
	
	Public
	
	Method New()
		SeedRnd(GenerateSeed())
	End Method
	
	Method New(seed:Int)
		SeedRnd seed
	End Method
	
	Method RndFloat:Float()
		Return Float(RndDouble())
	End Method
	
	Method RndDouble:Double()
		Return bmx_xoshiro_next_double(rnd_state)
	End Method
	
	Method Rnd:Double(minValue:Double = 1, maxValue:Double = 0)
		If maxValue > minValue Return RndDouble() * (maxValue - minValue) + minValue
		Return RndDouble() * (minValue - maxValue) + maxValue
	End Method
	
	Method Rand:Int(minValue:Int, maxValue:Int = 1)
		Local Range:Double = maxValue - minValue
		If Range > 0 Return Int( bmx_xoshiro_next_double(rnd_state)*(1:Double+Range) )+minValue
		Return Int( bmx_xoshiro_next_double(rnd_state)*(1:Double-Range) )+maxValue
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
			Return bmx_xoshiro_next(rnd_state)
		End If

		Local max:ULong = $FFFFFFFFFFFFFFFF:ULong
		Local limit:ULong = (max / span) * span - 1:ULong

		Local r:ULong
		Repeat
			r = bmx_xoshiro_next(rnd_state)
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

	Method SeedRnd(seed:Int)
		rnd_seed = seed
		If seed = 0 Then
			seed = $1234
		End If
		bmx_xoshiro_seed(ULong(seed), rnd_state)
	End Method
	
	Method RndSeed:Int()
		Return rnd_seed
	End Method

	Method GetName:String()
		Return "Xoshiro"
	End Method

End Type

Private
Type TXoshiroRandomFactory Extends TRandomFactory
	
	Method New()
		Super.New()
		Init()
	End Method
	
	Method GetName:String()
		Return "Xoshiro"
	End Method
	
	Method Create:TRandom(seed:Int)
		Return New TXoshiroRandom(seed)
	End Method

	Method Create:TRandom()
		Return New TXoshiroRandom()
	End Method
		
End Type

Struct SState
	Field StaticArray rnd_state:ULong[4]
End Struct

Extern
	Function bmx_xoshiro_seed(seed:ULong, state:SState Var)
	Function bmx_xoshiro_next:ULong(state:SState Var)
	Function bmx_xoshiro_next_double:Double(state:SState Var)
End Extern

New TXoshiroRandomFactory
