<#
.SYNOPSIS
Creates the standard shares for the eDev Standard SQL Server Build
.NOTES
Author: Josh Feierman
#>

Function Select-Item 
{    
<# 
     .Synopsis
        Allows the user to select simple items, returns a number to indicate the selected item. 

    .Description 

        Produces a list on the screen with a caption followed by a message, the options are then
        displayed one after the other, and the user can one. 
  
        Note that help text is not supported in this version. 

    .Example 

        PS> select-item -Caption "Configuring RemoteDesktop" -Message "Do you want to: " -choice "&Disable Remote Desktop",
           "&Enable Remote Desktop","&Cancel"  -default 1
       Will display the following 
  
        Configuring RemoteDesktop   
        Do you want to:   
        [D] Disable Remote Desktop  [E] Enable Remote Desktop  [C] Cancel  [?] Help (default is "E"): 

    .Parameter Choicelist 

        An array of strings, each one is possible choice. The hot key in each choice must be prefixed with an & sign 

    .Parameter Default 

        The zero based item in the array which will be the default choice if the user hits enter. 

    .Parameter Caption 

        The First line of text displayed 

     .Parameter Message 

        The Second line of text displayed     
#> 

Param(   [String[]]$choiceList, 
         [String]$Caption="Please make a selection", 
         [String]$Message="Choices are presented below", 
         [int]$default=0 
      ) 
   $choicedesc = New-Object System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription] 
   $choiceList | foreach  { $choicedesc.Add((New-Object "System.Management.Automation.Host.ChoiceDescription" -ArgumentList $_))} 
   $Host.ui.PromptForChoice($caption, $message, $choicedesc, $default) 
}  

$baseDirectory = "";
$instanceName = "";
$sharePath = "";

Write-Host "Below is a list of available drives and their labels. Use this information to decide the location of the standard shares. In general choose the largest drive available.";
#Show the user all the drives available
Get-WmiObject -Query "SELECT DriveLetter, Label, Capacity, FreeSpace FROM Win32_Volume WHERE drivetype = 3" | Format-Table DriveLetter,Label,@{Label="Capacity";Expression={"{0:N2}" -f ($_.Capacity/1GB)}},@{Label="FreeSpace";Expression={"{0:N2}" -f ($_.Freespace/1GB)}},@{Label="PercentFree";Expression={"{0:P2}" -f ($_.Freespace/$_.Capacity)}}
#Get the base directory for the shares
$baseDirectory = Read-Host -Prompt "Please enter the root path at which shares will be created.";
if ($baseDirectory -eq "") {exit 1;}
#Get the instance name
$instanceName = Read-Host -Prompt "Please enter the instance name (i.e. STDDEV, ENTQA, etc) for the share being created. If the default instance, enter MSSQLServer.";
if ($instanceName -eq "") { Write-Error "You must provide an instance name for the share."; exit 1;}
#Construct the share name
$sharePath = "$baseDirectory\ProdBackup$instanceName";
#Test to see if the path exists
if ((Test-Path -Path $baseDirectory) -eq $false)
{
	Write-Warning "The specified path does not appear to exist, would you like to attempt to create it?";
	$response = select-item -ChoiceList "Yes","No" -Caption "Please make a selection" -Message "Choices are below.";
	if ($response -eq 0)
	{
		New-Item -ItemType "Directory" -Path $baseDirectory;
	}
	else
	{
		Write-Warning "The specified path could not be found. Exiting.";
		exit 1;
	}
}
#Create the ProdBackups share
if ((Test-Path -Path $sharePath) -eq $false)
{
	New-Item -ItemType "Directory" -Path $sharePath;
}
$netCmd = "net share ProdBackup$instanceName=`"$sharePath`" `"/grant:sei-domain-1\edelivery_dba_team,change`" `"/grant:Administrators,full`"";
Invoke-Expression $netCmd;
if ($LASTEXITCODE -ne 0)
{
	Write-Error "Share creation for ProdBackups share failed.";
	exit 1;
}
$currentACL = Get-Acl -Path $sharePath;
$permission = "SEI-DOMAIN-1\EDELIVERY_DBA_TEAM","FullControl","Allow";
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission;
$currentACL.SetAccessRule($accessRule);
$permission = "Administrators","FullControl","Allow";
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission;
$currentACL.SetAccessRule($accessRule);
$currentACL | Set-Acl -Path $sharePath;

$currentACL = $null;
$accessRule = $null;
