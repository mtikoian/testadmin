################
## VARIABLES  ##
################

$projects = @("Project1", "Project2", "Project3")
$dbs = @("Staging", "Warehouse")
$dir = $PSScriptRoot

################
##   LOGIC    ##
################

Function BuildObjectCombined($objectDir) {
    Write-Host ("    - Building sub-objects...")
    $dirs = Get-ChildItem -Path $objectDir –Directory 
    Foreach ($dir in $dirs) {
        $combinedFile = $null
        Write-Host ("         - Building " + $dir.FullName + '.sql')
        $files = Get-ChildItem $dir.FullName -Filter *.sql
        Foreach ($file in $files) {
            $combinedFile = $combinedFile + (Get-Content $file.FullName)
        }
        $combinedFile | Set-Content ($dir.FullName + '.sql')
    }
}

Function BuildProjectCombined($ProjectDir) {
    Write-Host ("Writing " + $ProjectDir + '_Combined.sql')
    $files = Get-ChildItem $ProjectDir -Filter *.sql
    Foreach ($file in $files) {
        $combinedFile = $combinedFile + (Get-Content $file.FullName)
    }
    $combinedFile | Set-Content ($dir + '\' + $db + '_' + $project + '_Combined.sql')
}

Function BuildDB($db) {
    Foreach ($project in $projects) {
        $ProjectDir = ($dir + '\' + $project + '\SQL\' + $db)
        if ( Test-Path $ProjectDir -PathType Container ) {
            Write-Host ("Building " + $project)
            BuildObjectCombined($ProjectDir)
            BuildProjectCombined($ProjectDir)
        }
    }
}

Foreach ($db in $dbs) {
    Write-Host ("DB: " + $db)
    BuildDB($db) | out-null
}
