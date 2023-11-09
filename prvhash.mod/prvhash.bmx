' Copyright (c) 2023 Bruce A Henderson
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

ModuleInfo "Version: 1.00"
ModuleInfo "License: MIT"
ModuleInfo "Copyright: Wrapper - 2023 Bruce A Henderson"
ModuleInfo "Copyright: PRVHASH - 2020-2023 Aleksey Vaneev"

ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import Random.Core
Import "prvhash/*.h"
Import "glue.c"

Type TPrvHashRandom Extends TRandom
	
	Private
	
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
