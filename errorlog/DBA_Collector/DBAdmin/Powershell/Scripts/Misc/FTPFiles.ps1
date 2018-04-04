<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>

[Cmdletbinding()]
param
(
  <#
  [parameter(mandatory=$true)]
  [String]$DestinationServer,
  [parameter(mandatory=$true)]
  [string]$SourcePath,
  [parameter(mandatory=$true)]
  [string]$PWFile,
  [parameter(mandatory=$true)]
  [string]$LogFilePath,
  [parameter(mandatory=$true)]
  [string]$AlertEMail,
  [parameter(mandatory=$true)]
  [string]$
  #>
  [parameter(mandatory=$false)]
  [switch]$Configure
)

Set-StrictMode -version 2

##Begin Settings##

#Enter the source directory for files to transfer
$SourcePath="\\seiinvtuatdb03\e$\backup\SEIINVTUATDB03\IT_GSHFS\FULL"

#Enter the mask to use to select files for transfer. Use "*" to match everything.
$SourceMask="*.bak"

#Enter the name of the destination FTP server and path (should not include "ftp://").
$DestinationPath="abernas03.ctc.seic.com"

#Enter the user name for the FTP site (never edit this manually, only set via the config routine)
$FTPUser="01000000d08c9ddf0115d1118c7a00c04fc297eb010000004c263abacebc404bae47d7c6d1a840ba0000000002000000000003660000c00000001000000002b9253303d3aea8ae4feb12736823e00000000004800000a000000010000000ff2d8a56765c84e903bb3ae4deb681bc18000000e3504debb4a5b26653024e798b001e6355e63512aaf5d9e814000000a753716ee6137e51fdad05505d2ce06c64c18184"

#Enter the password for the FTP site (never edit this manually, only set via the config routine)
$FTPPassword="01000000d08c9ddf0115d1118c7a00c04fc297eb010000004c263abacebc404bae47d7c6d1a840ba0000000002000000000003660000c0000000100000006539a60f0db8b920f4db4363459840e50000000004800000a0000000100000003a90159e5e03fb10fcf7953870aeb79718000000e4cc8895572cec453b15f583ebbbdca5c6321a40e93f5dae14000000ef9e3a91599663c92ed3babd763edf3fb36108c9"

#Enter the path for the log files
$LogFilePath="C:\Users\jfeierman\Desktop\Crap"

#Enter the retention time (in days) of log files
$LogFileRetention="30"

#Enter the SMTP server to use for sending alert / summary e-mails
$SMTPServer="smtp.corp.seic.com"

#Enter the e-mail address for the "FROM" field for alert / summary e-mails
$FromAddress="jfeierman@seic.com"

#Enter the e-mail address that all alert / summary e-mails will be sent to
$ToAddress="jfeierman@seic.com"

#Enter the subject of all e-mail messages (make this something you will recognize and clue you in to the process)
$Subject="FTP"

#Enter the size (in bytes or Powershell notation - i.e. '1MB') of the FTP buffer. If in doubt leave as the default.
$BufferSize = 10485760

##End Settings##

#region Common functions

<#
  Partial attribution of function and idea to Alan Renouf (http://virtu-al.net) and vCheck.
#>
function script:Invoke-Setting
{
  param
  (
    $Path
  )
  $scriptContent = Get-Content $Path
  
  $StartLine = ($scriptContent | Select-String "^##Begin Settings##").LineNumber
  $EndLine = ($scriptContent | Select-String "^##End Settings##").LineNumber
  
  $out = @()
  
  $out = $scriptContent[0..$StartLine]
  
  # Iterate and set the settings
  for ($lineCounter = $StartLine + 1;$lineCounter -lt $EndLine; $lineCounter ++)
  {
    $currentLine = $scriptContent[$lineCounter]
    if ($currentLine -match "^#")
    {
      $Question = $currentLine.Replace("#","")
      $out += $currentLine
      $Ask = 0
    }
    elseif ($currentLine -match "^\$.+=.+")
    {
      $lineSplit = $currentLine.Split("=")
      $variable = $lineSplit[0].Replace("`$","")
      $oldVal = $lineSplit[1].Replace("`"","")
      $Ask = 1
    }
    else
    {
      $out += ""
    }
    
    if ($Ask -eq 1)
    {
      $newVal = Read-Host -Prompt "$Question [$oldVal]"
      if ($newVal -eq "")
      {
        $newVal = $oldVal
      }
      elseif ("FTPUser","FTPPassword" -contains $variable)
      {
        $newVal = ConvertTo-SecureString -AsPlainText -Force -String $newVal | ConvertFrom-SecureString
      }
      
      $out += "`$$variable=`"$newVal`""
      
      $Ask = 0
    }
  }
  
  # Get the rest of the content
  $out += $scriptContent[$EndLine..($scriptContent.Length - 1)]
  
  $content = [String]::Join("`n",$out)
  
  Set-Content $Path $content
  break
}

function script:Write-Log
{
  [Cmdletbinding()]
  param
  (
    [parameter(mandatory=$true)]
    [String]$LogFileName,
    [parameter(mandatory=$true)]
    [ValidateSet("Info","Debug","Warning","Error")]
    [String]$LogLevel,
    [parameter(mandatory=$true)]
    [String]$LogMessage
  )
  
  $msgText = "$(Get-Date -Format `"yyyyMMdd hh:mm:ss`") :: $LogLevel :: $LogMessage"
  Add-Content -Path $LogFileName -Value $msgText
  
  if ($LogLevel -eq "Error")
  {
    $alertMsgText = @"
The automated FTP process on server $env:computername ended in error.

Please review the logs at '$LogFileName' for more details.
"@
    Send-MailMessage -Body $alertMsgText -From $FromAddress -To $ToAddress -Subject $Subject -SmtpServer $SMTPServer
    break
  }
}

#endregion

try
{
  if ($Configure)
  {
    Invoke-Setting $MyInvocation.MyCommand.Path
  }
  
  $LogFileName = "$LogFilePath\$(Get-Date -Format `"yyyyMMddhhmm`").ftplog.txt"
  
  # Validate source path
  if (-not (Test-Path $SourcePath))
  {
    Write-Log $LogFileName "Error" "Source path '$SourcePath' was not found."
  }
  
  # Setup the FTP connection
  if (-not ($DestinationPath -match "^ftp://.*"))
  {
    $DestinationPath = "ftp://$DestinationPath"
  }
  Write-Log $LogFileName "Info" "Destination path is '$DestinationPath'."
  
  [System.Net.FtpWebRequest]$Request = [System.Net.WebRequest]::Create($DestinationPath)
  
  $UserName = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((ConvertTo-SecureString $FTPUser)))
  Write-Log $LogFileName "Info" "Destination user name is '$($Credentials.UserName)'."
  $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((ConvertTo-SecureString $FTPPassword)))
  
  $Credentials = New-Object System.Net.NetworkCredential -ArgumentList $UserName,$Password
  

  
  # Get the list of files to process
  $filesToProcess = Get-ChildItem -Path $SourcePath -Filter $SourceMask
  
  # Process the files
  Write-Log $LogFileName "Info" "Source path is $SourcePath."
  Write-Log $LogFileName "Info" "There are $($filesToProcess.Count) files to process."
  
  $HadWarnings = $false
  
  Foreach ($fileToProcess in $filesToProcess)
  {
    Write-log $LogFileName "Info" "Processing file $($fileToProcess.FullName)."
    
    try
    {
      [System.Net.FtpWebRequest]$Request = [System.Net.WebRequest]::Create("$DestinationPath/$fileToProcess.Name")
      $Request.Credentials = $Credentials
      $Request.Method = "STOR"
        
      $UploadStream = $Request.GetRequestStream()
      
      $Buffer = New-Object byte[] $BufferSize
      
      $AllReadData = 0
      $ReadData = 0
      $TotalData = $fileToProcess.Length
      
      if ($TotalData -gt 0)
      {
        Write-Log $LogFileName "Info" "Uploading file $($fileToProcess.FullName)"
        $FileBuffer = [System.IO.File]::OpenRead($fileToProcess.FullName)
        
        Do
        {
          $ReadData = $FileBuffer.Read($Buffer, 0, $Buffer.Length)
          $AllReadData += $ReadData
          $UploadStream.Write($Buffer,0,$ReadData)
          if ($AllReadData % (10 * $BufferSize) -eq 0)
          {
            Write-Log $LogFileName "Info" "Uploaded $($AllReadData/1MB)MB of $($TotalData/1MB)MB - $([Math]::Round(($AllReadData/$TotalData)*100,2))%"
          }
        } Until ($ReadData -eq 0)
        
        Write-Log $LogFileName "Info" "File $($fileToProcess.FullName) uploaded successfully."
      }
      else
      {
        Write-Log $LogFileName "Warning" "File $($fileToProcess.FullName) is empty. Skipping."
      }
      Write-Log $LogFileName "Info" "FTP Process completed."
    }
    catch
    {
      Write-Log $LogFileName "Warning" "Processing of file $($fileToProcess.FullName) failed."
      Write-Log $LogFileName "Warning" "$($_.Exception.Message)"
      
      $HadWarnings = $true
    }
    finally
    {
      $FileBuffer.Close()
      $FileBuffer.Dispose()
      $UploadStream.Close()
      $UploadStream.Dispose()
    }

  }
  
  if ($HadWarnings)
  {
    Write-Log $LogFileName "Error" "Not all files processed successfully."
  }
}
catch 
{
  Write-Warning $_.Exception.Message
  Write-Log $LogFileName "Error" $_.Exception.Message
}

