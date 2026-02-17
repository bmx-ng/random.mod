' Copyright (c) 2025-2026 Bruce A Henderson
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
bbdoc: Random Numbers - Squares
End Rem
Module Random.Squares

ModuleInfo "Version: 1.01"
ModuleInfo "License: zlib"
ModuleInfo "Copyright: Wrapper - 2025-2026 Bruce A Henderson"
ModuleInfo "Copyright: Based on a paper (Squares: A Fast Counter-Based RNG) by Bernard Widynski"

ModuleInfo "History: 1.01"
ModuleInfo "History: Added new Random methods."
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import Random.Core

Type TSquaresRandom Extends TRandom

	' use SetKey() to override the default key
	Const key:ULong = $06c9c021156eaa:ULong

	Private
	Const SIGNBIT_64:ULong = $8000000000000000:ULong
	Field state:SState
	
	Public
	
	Method New()
		SeedRnd(GenerateSeed())
		state.key = key
	End Method
	
	Method New(seed:Int)
		SeedRnd seed
		state.key = key
	End Method
	
	Method RndFloat:Float()
		Return Float(SquaresToDouble(state))
	End Method
	
	Method RndDouble:Double()
		Return SquaresToDouble(state)
	End Method
	
	Method Rnd:Double(minValue:Double = 1, maxValue:Double = 0)
		If maxValue > minValue Return RndDouble() * (maxValue - minValue) + minValue
		Return RndDouble() * (minValue - maxValue) + maxValue
	End Method
	
	Method Rand:Int(minValue:Int, maxValue:Int = 1)
		Local Range:Double = maxValue - minValue
		If Range > 0 Return Int( SquaresToDouble(state)*(1:Double+Range) )+minValue
		Return Int( SquaresToDouble(state)*(1:Double-Range) )+maxValue
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
			Return Squares64(state)
		End If

		Local max:ULong = $FFFFFFFFFFFFFFFF:ULong
		Local limit:ULong = (max / span) * span - 1:ULong

		Local r:ULong
		Repeat
			r = Squares64(state)
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
		If seed = 0 Then
			seed = $1234
		End If
		state.seed = seed
		state.count = 0
	End Method
	
	Method RndSeed:Int()
		Return state.seed
	End Method

	Method SetKey(key:ULong)
		state.key = key
	End Method

	Method GetName:String()
		Return "Squares"
	End Method

End Type

Private
Type TSquaresRandomFactory Extends TRandomFactory
	
	Method New()
		Super.New()
		Init()
	End Method
	
	Method GetName:String()
		Return "Squares"
	End Method
	
	Method Create:TRandom(seed:Int)
		Return New TSquaresRandom(seed)
	End Method

	Method Create:TRandom()
		Return New TSquaresRandom()
	End Method
		
End Type


New TSquaresRandomFactory

Private

Struct SState
	Field key:ULong
	Field count:ULong
	Field seed:Int
End Struct

Function Squares64:ULong(state:SState Var) Inline
	state.count :+ 1
	Local x:ULong = (state.count + ULong(state.seed)) * state.key
	Local y:ULong = x
	Local z:ULong = y + state.key

	x = x * x + y
	x = (x Shr 32) | (x Shl 32)

	x = x * x + z
	x = (x Shr 32) | (x Shl 32)

	x = x * x + y
	x = (x Shr 32) | (x Shl 32)

	x = x * x + z
	Local t:ULong = x
	x = (x Shr 32) | (x Shl 32)

	Return t ~ ((x * x + y) Shr 32)
End Function

Function SquaresToDouble:Double(state:SState Var) Inline
	Local x:ULong = Squares64(state)
	Return (x Shr 11) * (1.0:Double/9007199254740992.0:Double)
End Function
