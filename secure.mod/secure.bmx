' Copyright (c) 2023 Bruce A Henderson
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
bbdoc: Random Numbers - Secure
End Rem
Module Random.Secure

ModuleInfo "Version: 1.02"
ModuleInfo "License: zlib"
ModuleInfo "Copyright: 2023 Bruce A Henderson"

ModuleInfo "History: 1.02"
ModuleInfo "History: Fixed context type for Win32"
ModuleInfo "History: 1.01"
ModuleInfo "History: Fixed use of bmx_secure_next_double()"
ModuleInfo "History: 1.00"
ModuleInfo "History: Initial Release."

Import Random.Core

?macos
	Import "-framework Security"
	Import "macos_glue.c"
?win32
	Import "-ladvapi32"
	Import "win32_glue.c"
?linux
	Import "linux_glue.c"
?

Type TSecureRandom Extends TRandom

	Private

?win32
	Field context:ULongInt Ptr
?linux
	Field fd:Int
?
	
	Public
	
	Method New()
?win32
		context = bmx_secure_init()
?linux
		fd = bmx_secure_init()
?
	End Method
	
	Method New(seed:Int)
?win32
		context = bmx_secure_init()
?linux
		fd = bmx_secure_init()
?
	End Method
	
	Method RndFloat:Float() Override
		Return Float(RndDouble())
	End Method
	
	Method RndDouble:Double() Override
?win32
		Return bmx_secure_next_double(context)
?macos
		Return bmx_secure_next_double()
?linux
		Return bmx_secure_next_double(fd)
?
	End Method
	
	Method Rnd:Double(minValue:Double = 1, maxValue:Double = 0) Override
?win32
		If maxValue > minValue Return bmx_secure_next_double(context) * (maxValue - minValue) + minValue
		Return bmx_secure_next_double(context) * (minValue - maxValue) + maxValue
?macos
		If maxValue > minValue Return bmx_secure_next_double() * (maxValue - minValue) + minValue
		Return bmx_secure_next_double() * (minValue - maxValue) + maxValue
?linux
		If maxValue > minValue Return bmx_secure_next_double(fd) * (maxValue - minValue) + minValue
		Return bmx_secure_next_double(fd) * (minValue - maxValue) + maxValue
?
	End Method
	
	Method Rand:Int(minValue:Int, maxValue:Int = 1) Override
		Local Range:Double = maxValue - minValue
?win32
		If Range > 0 Return Int( bmx_secure_next_double(context)*(1:Double+Range) )+minValue
		Return Int( bmx_secure_next_double(context)*(1:Double-Range) )+maxValue
?macos
		If Range > 0 Return Int( bmx_secure_next_double()*(1:Double+Range) )+minValue
		Return Int( bmx_secure_next_double()*(1:Double-Range) )+maxValue
?linux
		If Range > 0 Return Int( bmx_secure_next_double(fd)*(1:Double+Range) )+minValue
		Return Int( bmx_secure_next_double(fd)*(1:Double-Range) )+maxValue
?
	End Method
	
	Method SeedRnd(seed:Int) Override
		' no op
	End Method
	
	Method RndSeed:Int() Override
		Return 0
	End Method

	Method GetName:String() Override
		Return "Secure"
	End Method

	Method Delete()
?win32
		bmx_secure_destroy(context)
?linux
		bmx_secure_destroy(fd)
?
	End Method
End Type

Private
Type TSecureRandomFactory Extends TRandomFactory
	
	Method New()
		Super.New()
		Init()
	End Method
	
	Method GetName:String()
		Return "Secure"
	End Method
	
	Method Create:TRandom(seed:Int)
		Return New TSecureRandom()
	End Method

	Method Create:TRandom()
		Return New TSecureRandom()
	End Method
		
End Type

Extern
?macos
	Function bmx_secure_next_double:Double()
?win32
	Function bmx_secure_next_double:Double(context:ULongInt Ptr)
	Function bmx_secure_destroy(context:ULongInt Ptr)
	Function bmx_secure_init:ULongInt Ptr()
?linux
	Function bmx_secure_next_double:Double(fd:Int)
	Function bmx_secure_init:Int()
	Function bmx_secure_destroy(fd:Int)
?
End Extern

New TSecureRandomFactory
