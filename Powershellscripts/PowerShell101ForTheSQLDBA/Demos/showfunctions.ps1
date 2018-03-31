#showfunctions.ps1
#Demonstrates different ways to execute functions

Function Do-Something {
	  write-host "I'm Doing it!"
	  }
Do-Something

Function Do-Something ($instance) {
	  write-host "Parameter passed in is $instance"
	  }
Do-Something ('SQLTBWS\INST02')

Function Do-Something {
	  param (
	     [int]$m = 2,
	     [int]$n = 8
	     )
	  write-host "m contains $m and n contains $n"
	  }
Do-Something (1)
