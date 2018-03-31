Function Get-UdfFileName
{  
[CmdletBinding()]
        param (
              [string]$InitialDirectory = (Join-Path -Path $env:HOMEDRIVE -ChildPath $env:HOMEPATH) 
          )

 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename

 Write-Verbose "You selected $OpenFileDialog ."
}

<# Example Call...
  Get-UdfFileName -Verbose
#>