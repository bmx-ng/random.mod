' Copyright (c) 2025 Bruce A Henderson
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

ModuleInfo "Version: 1.00"
ModuleInfo "License: zlib"
ModuleInfo "Copyright: Wrapper - 2025 Bruce A Henderson"
ModuleInfo "Copyright: Based on a paper (Squares: A Fast Counter-Based RNG) by Bernard Widynski"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import Random.Core

Type TSquaresRandom Extends TRandom

	' use SetKey() to override the default key
	Const key:ULong = $06c9c021156eaa:ULong

	Private
	
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
