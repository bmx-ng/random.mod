' Copyright (c) 2023-2026 Bruce A Henderson
'
' Permission is hereby granted, free of charge, to any person obtaining a
' copy of this software and associated documentation files (the "Software"),
' to deal in the Software without restriction, including without limitation
' the rights to use, copy, modify, merge, publish, distribute, sublicense,
' and/or sell copies of the Software, and to permit persons to whom the
' Software is furnished to do so, subject to the following conditions:
'
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
'
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
' FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
' DEALINGS IN THE SOFTWARE.
'
SuperStrict

Rem
bbdoc: Random Numbers - PRVHASH
End Rem
Module Random.PRVHASH

ModuleInfo "Version: 1.01"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: Wrapper - 2023-2026 Bruce A Henderson"
ModuleInfo "Copyright: PRVHASH - 2020-2023 Aleksey Vaneev"

ModuleInfo "History: 1.01"
ModuleInfo "History: Added new Random methods."
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import Random.Core
Import "prvhash/*.h"
Import "glue.c"

Type TPrvHashRandom Extends TRandom
	
	Private
	Const SIGNBIT_64:ULong = $8000000000000000:ULong
	Field rnd_state:SHashState
	Field rnd_seed:Int
	
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
		Return bmx_prvhash_next_double(rnd_state)
	End Method
	
	Method Rnd:Double(minValue:Double = 1, maxValue:Double = 0)
		If maxValue > minValue Return RndDouble() * (maxValue - minValue) + minValue
		Return RndDouble() * (minValue - maxValue) + maxValue
	End Method
	
	Method Rand:Int(minValue:Int, maxValue:Int = 1)
		Local Range:Double = maxValue - minValue
		If Range > 0 Return Int( bmx_prvhash_next_double(rnd_state)*(1:Double+Range) )+minValue
		Return Int( bmx_prvhash_next_double(rnd_state)*(1:Double-Range) )+maxValue
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
			Return bmx_prvhash_next(rnd_state)
		End If

		Local max:ULong = $FFFFFFFFFFFFFFFF:ULong
		Local limit:ULong = (max / span) * span - 1:ULong

		Local r:ULong
		Repeat
			r = bmx_prvhash_next(rnd_state)
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
		bmx_prvhash_seed(ULong(seed), rnd_state)
	End Method
	
	Method RndSeed:Int()
		Return rnd_seed
	End Method

	Method GetName:String()
		Return "PRVHASH"
	End Method

End Type

Private
Type TPrvHashRandomFactory Extends TRandomFactory
	
	Method New()
		Super.New()
		Init()
	End Method
	
	Method GetName:String()
		Return "PRVHASH"
	End Method
	
	Method Create:TRandom(seed:Int)
		Return New TPrvHashRandom(seed)
	End Method

	Method Create:TRandom()
		Return New TPrvHashRandom()
	End Method
		
End Type

Struct SHashState
	Field seed:ULong
	Field lcg:ULong
	Field hash:ULong
End Struct

Extern
	Function bmx_prvhash_seed(seed:ULong, state:SHashState Var)
	Function bmx_prvhash_next:ULong(state:SHashState Var)
	Function bmx_prvhash_next_double:Double(state:SHashState Var)
End Extern

New TPrvHashRandomFactory
