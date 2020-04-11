' Copyright (c) 2020 Bruce A Henderson
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

ModuleInfo "Version: 1.00"
ModuleInfo "License: zlib"
ModuleInfo "Copyright: Wrapper - 2020 Bruce A Henderson"
ModuleInfo "Copyright: xoshiro256++ - 2019 David Blackman and Sebastiano Vigna"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import BRL.Random
Import "src/xoshiro256plusplus.c"

Type TXoshiroRandom Extends TRandom
	
	Private
	
	Field rnd_state:SState
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
