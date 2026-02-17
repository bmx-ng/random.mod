
SuperStrict

Rem
bbdoc: Math/Random numbers
End Rem
Module Random.Core

ModuleInfo "Version: 1.11"
ModuleInfo "Author: Mark Sibly, Floyd"
ModuleInfo "License: zlib/libpng"
ModuleInfo "Copyright: Blitz Research Ltd"
ModuleInfo "Modserver: BRL"

ModuleInfo "History: 1.11"
ModuleInfo "History: Added new Random methods to TRandom."
ModuleInfo "History: 1.10"
ModuleInfo "History: Refactored to allow multiple generators."
ModuleInfo "History: Added SetRandom(), GetRandomName() and GetRandomNames()."
ModuleInfo "History: 1.09"
ModuleInfo "History: Moved to Random.Core."
ModuleInfo "History: 1.08"
ModuleInfo "History: New API to enable custom random number generators."
ModuleInfo "History: 1.07"
ModuleInfo "History: Added support for multiple generators"
ModuleInfo "History: 1.06"
ModuleInfo "History: Module is now SuperStrict"
ModuleInfo "History: 1.05 Release"
ModuleInfo "History: Fixed Rand() with negative min value bug"

? Threaded
Import BRL.Threads
?

Private

Global GlobalRandom:TRandom

Global random_factories:TRandomFactory

Global random_names:String[]
Public

Type TRandomFactory
	Field _succ:TRandomFactory

	Field _instance:TRandom
	
	Method New()
		_succ=random_factories
		random_factories=Self
	End Method
	
	Method Init()
		_instance = Create()
		GlobalRandom = _instance
	End Method
	
	Method GetName:String() Abstract
	
	Method Create:TRandom(seed:Int) Abstract

	Method Create:TRandom() Abstract

	Function Find:TRandomFactory(name:String)
		Local factory:TRandomFactory = random_factories
		While factory
			If factory.GetName() = name Then
				Return factory
			End If

			factory = factory._succ
		Wend

		Return Null
	End Function

	Function Create:TRandom(name:String)
		Local factory:TRandomFactory = Find(name)

		If factory Then
			Return factory.Create()
		End If

		Return Null
	End Function

	Function Create:TRandom(seed:Int, name:String)
		Local factory:TRandomFactory = Find(name)

		If factory Then
			Return factory.Create(seed)
		End If

		Return Null
	End Function
End Type

Private
Global LastNewMs:Int = MilliSecs()
Global SimultaneousNewCount:Int = 0
? Threaded
Global NewRandomMutex:TMutex = TMutex.Create()
?
Public

Function GenerateSeed:Int()
	? Threaded
	NewRandomMutex.Lock
	?
	Local currentMs:Int = MilliSecs()
	Local auxSeed:Int
	If currentMs = LastNewMs Then
		SimultaneousNewCount :+ 1
		auxSeed = SimultaneousNewCount
	Else
		LastNewMs = currentMs
		SimultaneousNewCount = 0
		auxSeed = 0
	End If
	? Threaded
	NewRandomMutex.Unlock
	?
	
	Function ReverseBits:Int(i:Int)
		If i = 0 Then Return 0
		Local r:Int
		For Local b:Int = 0 Until 8 * SizeOf i
			r :Shl 1
			r :| i & 1
			i :Shr 1
		Next
		Return r
	End Function
	' left-shift before reversing because SeedRnd ignores the most significant bit
	Return currentMs ~ ReverseBits(auxSeed Shl 1)
End Function

Rem
bbdoc: Random number generator
about:
By creating multiple TRandom objects, multiple independent
random number generators can be used in parallel.
End Rem
Type TRandom
	
	Rem
	bbdoc: Generates a random float
	returns: A random float in the range 0 (inclusive) to 1 (exclusive)
	End Rem
	Method RndFloat:Float() Abstract
	
	Rem
	bbdoc: Generates a random double
	returns: A random double in the range 0 (inclusive) to 1 (exclusive)
	End Rem
	Method RndDouble:Double() Abstract

	Rem
	bbdoc: Generates a random integer
	returns: A random integer in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #RandomInt in 2 ways:
	
	[ @Format | @Result
	* `RandomInt(x)` | Random integer in the range 1 to x (inclusive)
	* `RandomInt(x,y)` | Random integer in the range x to y (inclusive)
	]
	End Rem
	Method RandomInt:Int(minValue:Int, maxValue:Int = 1) Abstract

	Rem
	bbdoc: Generates a random long
	returns: A random long in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #RandomLong in 2 ways:
	
	[ @Format | @Result
	* `RandomLong(x)` | Random long in the range 1 to x (inclusive)
	* `RandomLong(x,y)` | Random long in the range x to y (inclusive)
	]
	End Rem
	Method RandomLong:Long(minValue:Long, maxValue:Long = 1) Abstract

	Rem
	bbdoc: Generates a random short
	returns: A random short in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #RandomShort in 2 ways:
	
	[ @Format | @Result
	* `RandomShort(x)` | Random short in the range 1 to x (inclusive)
	* `RandomShort(x,y)` | Random short in the range x to y (inclusive)
	]
	End Rem
	Method RandomShort:Short(minValue:Short, maxValue:Short = 1) Abstract

	Rem
	bbdoc: Generates a random byte
	returns: A random byte in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #RandomByte in 2 ways:
	
	[ @Format | @Result
	* `RandomByte(x)` | Random byte in the range 1 to x (inclusive)
	* `RandomByte(x,y)` | Random byte in the range x to y (inclusive)
	]
	End Rem
	Method RandomByte:Byte(minValue:Byte, maxValue:Byte = 1) Abstract

	Rem
	bbdoc: Generates a random unsigned long
	returns: A random unsigned long in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #RandomULong in 2 ways:
	
	[ @Format | @Result
	* `RandomULong(x)` | Random unsigned long in the range 1 to x (inclusive)
	* `RandomULong(x,y)` | Random unsigned long in the range x to y (inclusive)
	]
	End Rem
	Method RandomULong:ULong(minValue:ULong, maxValue:ULong = 1) Abstract

	Rem
	bbdoc: Generates a random unsigned integer
	returns: A random unsigned integer in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #RandomUInt in 2 ways:
	
	[ @Format | @Result
	* `RandomUInt(x)` | Random unsigned integer in the range 1 to x (inclusive)
	* `RandomUInt(x,y)` | Random unsigned integer in the range x to y (inclusive)
	]
	End Rem
	Method RandomUInt:UInt(minValue:UInt, maxValue:UInt = 1) Abstract

	Rem
	bbdoc: Generates a random unsigned long integer
	returns: A random unsigned long integer in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #RandomULongInt in 2 ways:
	
	[ @Format | @Result
	* `RandomULongInt(x)` | Random unsigned long integer in the range 1 to x (inclusive)
	* `RandomULongInt(x,y)` | Random unsigned long integer in the range x to y (inclusive)
	]
	End Rem
	Method RandomLongInt:LongInt(minValue:LongInt, maxValue:LongInt = 1) Abstract

	Rem
	bbdoc: Generates a random unsigned long integer
	returns: A random unsigned long integer in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #RandomULongInt in 2 ways:
	
	[ @Format | @Result
	* `RandomULongInt(x)` | Random unsigned long integer in the range 1 to x (inclusive)
	* `RandomULongInt(x,y)` | Random unsigned long integer in the range x to y (inclusive)
	]
	End Rem
	Method RandomULongInt:ULongInt(minValue:ULongInt, maxValue:ULongInt = 1) Abstract

	Rem
	bbdoc: Generates a random size_t
	returns: A random size_t in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #RandomSizeT in 2 ways:
	
	[ @Format | @Result
	* `RandomSizeT(x)` | Random size_t in the range 1 to x (inclusive)
	* `RandomSizeT(x,y)` | Random size_t in the range x to y (inclusive)
	]
	End Rem
	Method RandomSizeT:Size_T(minValue:Size_T, maxValue:Size_T = 1) Abstract
	
	Rem
	bbdoc: Generate random double
	returns: A random double in the range min (inclusive) to max (exclusive)
	about: 
	The optional parameters allow you to use Rnd in 3 ways:
	
	[ @Format | @Result
	* `Rnd()` | Random double in the range 0 (inclusive) to 1 (exclusive)
	* `Rnd(x)` | Random double in the range 0 (inclusive) to n (exclusive)
	* `Rnd(x,y)` | Random double in the range x (inclusive) to y (exclusive)
	]
	End Rem
	Method Rnd:Double(minValue:Double = 1, maxValue:Double = 0) Abstract
	
	Rem
	bbdoc: Generate random integer
	returns: A random integer in the range min (inclusive) to max (inclusive)
	about:
	The optional parameter allows you to use #Rand in 2 ways:
	
	[ @Format | @Result
	* `Rand(x)` | Random integer in the range 1 to x (inclusive)
	* `Rand(x,y)` | Random integer in the range x to y (inclusive)
	]
	End Rem
	Method Rand:Int(minValue:Int, maxValue:Int = 1) Abstract
	
	Rem
	bbdoc: Set random number generator seed
	End Rem
	Method SeedRnd(seed:Int) Abstract
	
	Rem
	bbdoc: Get random number generator seed
	returns: The current random number generator seed
	about: Used in conjunction with SeedRnd, RndSeed allows you to reproduce sequences of random
	numbers.
	End Rem
	Method RndSeed:Int() Abstract

	Rem
	bbdoc: Gets the name of this random number generator
	End Rem
	Method GetName:String() Abstract
End Type

Rem
bbdoc: Sets the current random number generator to @name.
about: If no generator called @name is found, the current random number generator remains active.
End Rem
Function SetRandom(name:String)
	Local factory:TRandomFactory = TRandomFactory.Find(name)
	If factory Then
		GlobalRandom = factory._instance
	End If
End Function

Rem
bbdoc: Gets the name of the current random number generator.
returns: The name of the current random number generator, or #Null if none is set.
End Rem
Function GetRandomName:String()
	If GlobalRandom Then
		Return GlobalRandom.GetName()
	End If 
End Function

Rem
bbdoc: Gets the names of available random number generators.
End Rem
Function GetRandomNames:String[]()
	If random_names Then
		Return random_names
	End If

	Local names:String[] = New String[0]
	
	Local factory:TRandomFactory = random_factories
	While factory
		names :+ [ factory.GetName() ]
		factory = factory._succ
	Wend

	random_names = names
	Return random_names
End Function

Rem
bbdoc: Creates a new TRandom instance.
End Rem
Function CreateRandom:TRandom(name:String = Null)
	If name Then
		Return TRandomFactory.Create(name)
	End If
	If GlobalRandom Then
		Return random_factories.Create()
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Creates a new TRandom instance with the given @seed.
End Rem
Function CreateRandom:TRandom(seed:Int, name:String = Null)
	If name Then
		Return TRandomFactory.Create(seed, name)
	End If
	If GlobalRandom Then
		Return random_factories.Create(seed)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random float
returns: A random float in the range 0 (inclusive) to 1 (exclusive)
End Rem
Function RndFloat:Float()
	If GlobalRandom Then
		Return GlobalRandom.RndFloat()
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random double
returns: A random double in the range 0 (inclusive) to 1 (exclusive)
End Rem
Function RndDouble:Double()
	If GlobalRandom Then
		Return GlobalRandom.RndDouble()
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random double
returns: A random double in the range min (inclusive) to max (exclusive)
about: 
The optional parameters allow you to use Rnd in 3 ways:

[ @Format | @Result
* `Rnd()` | Random double in the range 0 (inclusive) to 1 (exclusive)
* `Rnd(x)` | Random double in the range 0 (inclusive) to n (exclusive)
* `Rnd(x,y)` | Random double in the range x (inclusive) to y (exclusive)
]
End Rem
Function Rnd:Double(minValue:Double = 1, maxValue:Double = 0)
	If GlobalRandom Then
		Return GlobalRandom.Rnd(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random integer
returns: A random integer in the range min (inclusive) to max (inclusive)
about:
The optional parameter allows you to use #RandomInt in 2 ways:

[ @Format | @Result
* `RandomInt(x)` | Random integer in the range 1 to x (inclusive)
* `RandomInt(x,y)` | Random integer in the range x to y (inclusive)
]
End Rem
Function RandomInt:Int(minValue:Int, maxValue:Int = 1)
	If GlobalRandom Then
		Return GlobalRandom.RandomInt(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random long
returns: A random long in the range min (inclusive) to max (inclusive)
about:
The optional parameter allows you to use #RandomLong in 2 ways:

[ @Format | @Result
* `RandomLong(x)` | Random long in the range 1 to x (inclusive)
* `RandomLong(x,y)` | Random long in the range x to y (inclusive)
]
End Rem
Function RandomLong:Long(minValue:Long, maxValue:Long = 1)
	If GlobalRandom Then
		Return GlobalRandom.RandomLong(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random short
returns: A random short in the range min (inclusive) to max (inclusive)
about:
The optional parameter allows you to use #RandomShort in 2 ways:

[ @Format | @Result
* `RandomShort(x)` | Random short in the range 1 to x (inclusive)
* `RandomShort(x,y)` | Random short in the range x to y (inclusive)
]
End Rem
Function RandomShort:Short(minValue:Short, maxValue:Short = 1)
	If GlobalRandom Then
		Return GlobalRandom.RandomShort(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random byte
returns: A random byte in the range min (inclusive) to max (inclusive)
about:
The optional parameter allows you to use #RandomByte in 2 ways:

[ @Format | @Result
* `RandomByte(x)` | Random byte in the range 1 to x (inclusive)
* `RandomByte(x,y)` | Random byte in the range x to y (inclusive)
]
End Rem
Function RandomByte:Byte(minValue:Byte, maxValue:Byte = 1)
	If GlobalRandom Then
		Return GlobalRandom.RandomByte(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random unsigned long
returns: A random unsigned long in the range min (inclusive) to max (inclusive)
about:
The optional parameter allows you to use #RandomULong in 2 ways:

[ @Format | @Result
* `RandomULong(x)` | Random unsigned long in the range 1 to x (inclusive)
* `RandomULong(x,y)` | Random unsigned long in the range x to y (inclusive)
]
End Rem
Function RandomULong:ULong(minValue:ULong, maxValue:ULong = 1)
	If GlobalRandom Then
		Return GlobalRandom.RandomULong(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random unsigned integer
returns: A random unsigned integer in the range min (inclusive) to max (inclusive)
about:
The optional parameter allows you to use #RandomUInt in 2 ways:

[ @Format | @Result
* `RandomUInt(x)` | Random unsigned integer in the range 1 to x (inclusive)
* `RandomUInt(x,y)` | Random unsigned integer in the range x to y (inclusive)
]
End Rem
Function RandomUInt:UInt(minValue:UInt, maxValue:UInt = 1)
	If GlobalRandom Then
		Return GlobalRandom.RandomUInt(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random unsigned long integer
returns: A random unsigned long integer in the range min (inclusive) to max (inclusive)
about:
The optional parameter allows you to use #RandomULongInt in 2 ways:

[ @Format | @Result
* `RandomULongInt(x)` | Random unsigned long integer in the range 1 to x (inclusive)
* `RandomULongInt(x,y)` | Random unsigned long integer in the range x to y (inclusive)
]
End Rem
Function RandomLongInt:LongInt(minValue:LongInt, maxValue:LongInt = 1)
	If GlobalRandom Then
		Return GlobalRandom.RandomLongInt(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random unsigned long integer
returns: A random unsigned long integer in the range min (inclusive) to max (inclusive)
about:
The optional parameter allows you to use #RandomULongInt in 2 ways:

[ @Format | @Result
* `RandomULongInt(x)` | Random unsigned long integer in the range 1 to x (inclusive)
* `RandomULongInt(x,y)` | Random unsigned long integer in the range x to y (inclusive)
]
End Rem
Function RandomULongInt:ULongInt(minValue:ULongInt, maxValue:ULongInt = 1)
	If GlobalRandom Then
		Return GlobalRandom.RandomULongInt(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random size_t
returns: A random size_t in the range min (inclusive) to max (inclusive)
about:
The optional parameter allows you to use #RandomSizeT in 2 ways:

[ @Format | @Result
* `RandomSizeT(x)` | Random size_t in the range 1 to x (inclusive)
* `RandomSizeT(x,y)` | Random size_t in the range x to y (inclusive)
]
End Rem
Function RandomSizeT:Size_T(minValue:Size_T, maxValue:Size_T = 1)
	If GlobalRandom Then
		Return GlobalRandom.RandomSizeT(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Generates a random integer
returns: A random integer in the range min (inclusive) to max (inclusive)
about:
The optional parameter allows you to use #Rand in 2 ways:

[ @Format | @Result
* `Rand(x)` | Random integer in the range 1 to x (inclusive)
* `Rand(x,y)` | Random integer in the range x to y (inclusive)
]
End Rem
Function Rand:Int(minValue:Int, maxValue:Int = 1)
	If GlobalRandom Then
		Return GlobalRandom.Rand(minValue, maxValue)
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Sets the random number generator seed
End Rem
Function SeedRnd(seed:Int)
	If GlobalRandom Then
		GlobalRandom.SeedRnd seed
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function

Rem
bbdoc: Gets the random number generator seed
returns: The current random number generator seed
about: Used in conjunction with SeedRnd, RndSeed allows you to reproduce sequences of random
numbers.
End Rem
Function RndSeed:Int()
	If GlobalRandom Then
		Return GlobalRandom.RndSeed()
	Else
		Throw "No Random installed. Maybe Import BRL.Random ?"
	End If
End Function
