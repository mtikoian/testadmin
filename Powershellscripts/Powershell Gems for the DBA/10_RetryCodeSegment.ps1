####################################################################################
## This function checks a SMO error, if found, it displays the error and sets the 

function ShowError ($DbMaintErrObj)
{
        $ex = $DbMaintErrObj.Exception
        Dispmessage $ex.message $true
        $ex = $ex.InnerException		
        while ($ex.InnerException)
        {  
            Dispmessage $ex.InnerException.message $true
            $ex = $ex.InnerException
        }
		
}

Function RestoreDatabase ([string] $DbName, [object] $RDSQLConn, [string] $BackupFile, [boolean] $ExtraRestoresExist, [string] $RestoreDBState,
                          [string] $DataBackupPath, [string] $TLBackupPath, [int] $RetryCount, [int] $RetryDelaySec, [Ref] $DBMaint2ErrorFlag)

{
 [int] $retries = 1  ## seed retry start value
 [string] $RestoreDBErrorFlag = ""
 
 ## if Restore Db is not processed then retry until Retry count is exceeded
 While ($retries -le $RetryCount -and $RestoreDBErrorFlag -ne "RestoreDBProcessed" )
   {
	 try
	  { 
	    $RestoreDBErrorFlag = "RestoreDBProcessed"
		<# 
		
		Process restore database code
		
		#>
		
	  }  
     catch ## if error then show it, set error flag and continue for retry
	  {
	    ShowError $_  continue
	    if ($_.exception.message.length -gt 0) {$RestoreDBErrorFlag = "RestoreDBProcFlagError"} ## Restore error found
		
		Dispmessage "-----> Retrying Failed Process - Retry No -> $retries"
		Dispmessage "-----> Sleeping for $RetryDelaySec seconds"
		Start-Sleep -s $RetryDelaySec  ## Delay between rety
		$Restore = $null 
	  }		
	$retries++  ## increment retry count
  }	## end Retry Loop
  
  ## Pass back to calling function the update ErrorFlag (by reference)
  if ($RestoreDBErrorFlag -eq "RestoreDBProcFlagError") { $DBMaint2ErrorFlag.value = "ProcFlagError"}
     
}  ## end RestoreDB function