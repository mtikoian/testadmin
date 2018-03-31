#Create a new Excel object using COM 
$Excel = New-Object -ComObject Excel.Application
$Excel.visible = $True

$Excel = $Excel.Workbooks.Add()
$Sheet = $Excel.Worksheets.Item(1)

#Counter variable for rows
$intRow = 1

#Read thru the contents of the SQL_Servers.txt file
foreach ($instance in get-content "C:\APresentation\SQLSat382PowershellGems\AllServers.txt")
{

     #Create column headers
     $Sheet.Cells.Item($intRow,1) = "INSTANCE NAME:"
     $Sheet.Cells.Item($intRow,2) = $instance
     $Sheet.Cells.Item($intRow,1).Font.Bold = $True
     $Sheet.Cells.Item($intRow,2).Font.Bold = $True

     $intRow++

      $Sheet.Cells.Item($intRow,1) = "JOB NAME"
      $Sheet.Cells.Item($intRow,2) = "LAST RUN OUTCOME"
      $Sheet.Cells.Item($intRow,3) = "LAST RUN DATE"


     #Format the column headers
     for ($col = 1; $col –le 3; $col++)
     {
          $Sheet.Cells.Item($intRow,$col).Font.Bold = $True
          $Sheet.Cells.Item($intRow,$col).Interior.ColorIndex = 48
          $Sheet.Cells.Item($intRow,$col).Font.ColorIndex = 34
     }


     $intRow++
      #######################################################
     #This script gets SQL Server Agent job status information using PowerShell


     [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null

     # Create an SMO connection to the instance
     $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $instance

     $jobs=$srv.JobServer.Jobs

     #Formatting using Excel 


ForEach ($job in $jobs)  
{ 

       # Formatting for the failed jobs 
       if ($job.LastRunOutcome -eq 0) 
       { 
           $fgColor = 3 
       } 
       else 
       { 
           $fgColor = 0 
       } 
    

       $Sheet.Cells.Item($intRow, 1) =  $job.Name 
       $Sheet.Cells.Item($intRow, 2) = $job.LastRunOutcome.ToString() 
       $Sheet.Cells.item($intRow, 2).Interior.ColorIndex = $fgColor 
       $Sheet.Cells.Item($intRow, 3) =  $job.LastRunDate

    
            
       $intRow ++ 
   
} 
   $intRow ++ 


}

$Sheet.UsedRange.EntireColumn.AutoFit()
cls

