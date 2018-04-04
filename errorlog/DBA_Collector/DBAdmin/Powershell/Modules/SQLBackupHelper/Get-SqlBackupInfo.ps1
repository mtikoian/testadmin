	<#

	.SYNOPSIS 
	 Gets the information from a SQL backup file using either xp_restore_headeronly (Litespeed) or RESTORE HEADERONLY
	.PARAMETER FullName
	 The name of the backup file(s) to process.
	.PARAMETER Litepseed
	 Indicates if the Litespeed extended procedure should be used.
	.PARAMETER ServerName
	 The name of the SQL Server on which to try and read the backup set.
	.NOTES
	 Author: Josh Feierman
	 Date: 3/24/2011


	#>
	function Get-SqlBackupInfo
	{

		param
		(
			[parameter(mandatory=$true,ValueFromPipeline=$true)][object[]]$FullName,
			[parameter(mandatory=$true)][string]$ServerName,
			[switch]$Litespeed
		)
		
    BEGIN {
  		[string]$sqlStatement = '';
  		[Object[]]$backupFileInfo = @();
		}
		
    PROCESS {
  		foreach ($file in $FullName)
  		{
  			#If the obejct is a string, we need to create a file info object from it
        if ($file.GetType().Name -eq "String")
        {
          $file = Get-Item $file;
        }
        
        if ($Litespeed)
  			{
  				$sqlStatement = "exec xp_restore_headeronly @filename = '" + $file.FullName.Replace("$","`$") + "';";
  			}
  			else
  			{
  				$sqlStatement = "RESTORE HEADERONLY FROM DISK = '"+$file.FullName.Replace("$","`$")+"';";
  			}
  			
  			$backupFileHeader = Invoke-Query -database master -server $ServerName -sql $sqlStatement | 
                            Add-Member -MemberType NoteProperty -Value $file.FullName -Name "BackupFile" -PassThru | 
                            Add-Member -MemberType NoteProperty -Value $ServerName -Name ServerName -Force -PassThru | 
                            Add-Member -MemberType NoteProperty -Value $Litespeed -Name Litespeed -PassThru;
  			if ($backupFileHeader -eq $null)
  			{
  				Write-Error "Could not retrieve backup file info for $backupFileName.";
  			}
  			$backupFileInfo += $backupFileHeader;
  		}
    }
		
    END {
		  return $backupFileInfo;
    }
		
	}