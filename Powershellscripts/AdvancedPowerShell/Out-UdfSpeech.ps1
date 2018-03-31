
function Out-UdfSpeech  
{ 
 <#
     .SYNOPSIS 
     Speaks the string passed to it.

     .DESCRIPTION
     This function uses the SAPI interface to speak.

     .PARAMETER $speakit
     The string to be spoken.

     .INPUTS
     This function does not support piping.

     .OUTPUTS
     Describe what this function returns.

     .EXAMPLE
     Out-UdfSpeach 'Something to be said.'

     .LINK
     www.SAPIHelp.com.

#>
[CmdletBinding()]
        param (
              [ValidateLength(1,50)]
              [string]$speakit = 'What do you want me to say?'
          )
  #  Fun using SAPI - the text to speech thing....    

  Write-Verbose 'SAPI is about to speak!'

  $speaker = new-object -com SAPI.SpVoice

  $speaker.Speak($speakit, 1) | out-null

  Write-Debug 'SAPI has spken.' 

}

<# 

Out-UdfSpeech 'Good evening everyone!' -Verbose -Debug
 
#>

Out-UdfSpeech