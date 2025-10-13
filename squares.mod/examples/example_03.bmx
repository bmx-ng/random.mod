SuperStrict

Framework BRL.Standardio
Import Random.Squares

Local counts:Int[6]

For Local i:Int = 0 until 1000000
	counts[ Rand(0, 5) ] :+ 1
Next

For Local i:Int = 0 until 6
	Print i + " : " + counts[i]
Next
