$createSolution = 
{
    param($vsIde)

    $slnName = "All"
    $targetDirectory = Read-Host "Enter target directory (will create solution here and include all projects)"
    $projects = Get-ChildItem $targetDirectory -Recurse *.csproj | Sort-Object -Property Name

    $solution = $vsIde.Solution
    $solution.Create($targetDirectory, $slnName)
    #$vsIde.MainWindow.GetType().InvokeMember("Visible","SetProperty",$null,$vsIde.MainWindow,$true)

    foreach($proj in $projects)
    { 
        Write-Host "Adding $($proj.Name) to $($solution.Properties.Item("Name").Value)"
        $solution.AddFromFile($proj.FullName, $false) | Out-Null
        Write-Host "Added $($proj.Name) to $($solution.Properties.Item("Name").Value)"
        Write-Host ""
    }

    $solution.SaveAs( (Join-Path $targetDirectory 'All.sln') ) 
}

..\Shared\Ref\VisualStudio_PerformTask.ps1 -taskScriptBlockAsString $createSolution.ToString()