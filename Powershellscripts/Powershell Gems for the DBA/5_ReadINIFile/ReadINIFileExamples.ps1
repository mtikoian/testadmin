#####################################################################################
## This function reads ini file and creates hash table key=value pairs

# Get-Settings Reads an ini file into a hash table
# Each line of the .ini File will be processed through the pipe.
# The splitted lines fill a hastable. Empty lines and lines beginning with
# '[' or ';' are ignored. $ht returns the results as a hashtable.
function ReadIniFile()
{
	BEGIN
	{
		$ht = @{}
	}
	PROCESS
	{
		[string[]] $key = [regex]::split($_,'=')      # Split line by "=" char
		
		#ignore non blank and comment lines
		if(($key[0].CompareTo("") -ne 0) -and ($key[0].StartsWith("[") -ne $True) -and ($key[0].StartsWith(";") -ne $True))
		{
            $IniName = $key[0].trim()                 # set key name
            if ($key[1]) {$IniValue = $key[1].trim()} else {$IniValue = $key[1]}   # set Key value
			$ht.Add($IniName, $IniValue)             #add key value pair to has table.
		}
	}
	END
	{
		return $ht
	}
}

## Maint #############

$ConfigFile = "C:\APresentation\SQLSat382PowershellGems\5_ReadINIFile\RestoreDBBackup.INI"

#### Read  INI file into hash table
$IniHashtable = ( Get-Content $ConfigFile | ReadIniFile)   # each line of file processed by ReadIniFile function.

### Reference INI field
$BDBackupDir = $IniHashtable.item("BDBackupDir")

Write-Host "Backup Dir -> $BDBackupDir"

#Write-Host "Backup Dir inline -> $IniHashtable.item("BDBackupDir")"  # this errors, can't substitute
#Write-Host "Backup Dir inline -> $($IniHashtable.item("BDBackupDir"))"

#### Reference string of databases and split
#[string] $RDRestoreDBList = $($IniHashtable.item("RDRestoreDBs")).trim()
####
#### add brackets [] to the db name and lower case the name and then store in string array.
#[String[]] $IncludeExcludeDbsArray = $RDRestoreDBList.split(",") | ForEach-Object {if ($_.substring(0,1) -ne "[") {"[" + $_.trim().tolower() + "]"}}

#foreach ($db in $IncludeExcludeDbsArray)
#{
#  Write-Host "Processing DB -> $db"
#}

#### Get all the Keys in the Ini File - Usefull for validate key names passed
#foreach ($I in $IniHashtable.keys)
#{
#  Write-Host "INI Key -> $I"
#}

