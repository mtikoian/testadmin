try {
$d = '1/1/2011'

$SnapshotDate = [datetime]::ParseExact($Snapshotdate, "dd/MM/yyyy h:mm:ss tt", $null)

}
catch 
{
    if($host.name -eq "ConsoleHost")
	  {
       write-host "Caught an exception:"  -ForegroundColor yellow
       write-host  "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor yellow
       write-host  "Exception Message: $($_.Exception.Message)" -ForegroundColor yellow
	  }
	else
	  {
	    write-error "Caught an exception:" 
        write-error "Exception Type: $($_.Exception.GetType().FullName)" 
        write-error "Exception Message: $($_.Exception.Message)" 
	  }  
    exit 1    ## does NOT affect on completion status of a job
   
   # [System.Environment]::Exit(1)    ## does not show write-output or write-error but does affect the completion status of a job
   
   # Throw "Failure"  ## does show write-error and does affect the completion status of a job
}

