$createSolution = #function createSolution
{
    param($vsIde)

    $targetDirectory = Read-Host "Enter target directory (will create solution here and include all projects)"
    Write-Host

    $projects = Get-ChildItem $targetDirectory -Recurse *.csproj | 
        Where-Object { (-not $_.FullName.Contains("C:\Workspace\CSES\Release\Dev\Core\Interfaces")) } | 
        Sort-Object -Property Name #| Select-Object -First 2

    $skippedProjects = @()

    $solutionName = "AnalyzeReferences"
    $solutionFullName = Join-Path $targetDirectory "$($solutionName).sln"

    $solution = $vsIde.Solution

    $currentTask = 0
    $totalTasks = 0
    
    function updateProgress() {
        Write-Progress -activity "Progress" -status "$currentTask/$totalTasks Completed" -PercentComplete ($currentTask/$totalTasks * 100)
    }

    if(Test-Path $solutionFullName){
        Write-Host "Using existing $solutionName solution file" 
        $solution.Open($solutionFullName)
    }
    else
    {
        Write-Host "Creating $solutionName solution for analysis"

        $solution.Create($targetDirectory, "AnalyzeReferences")
        #$vsIde.MainWindow.GetType().InvokeMember("Visible","SetProperty",$null,$vsIde.MainWindow,$true)

        $currentTask = 0
        $totalTasks = $($projects.Length)

        updateProgress

        foreach($proj in $projects)
        {
            try
            {
                $solution.AddFromFile($proj.FullName, $false) | Out-Null
            }
            catch
            {
                if($Error[0].Exception.Message.Contains("is from a previous version of this application")){
                    $skippedProjects += $proj
                    Write-Host "Skipping $($proj.Name) due to version compatibility."
                }
                else{
                    throw $Error[0].Exception.Message
                }
            }

            $currentTask++
            updateProgress
        }

        Write-Host "$solutionName solution created" 
        Write-Host

        $solution.SaveAs($solutionFullName) 
    }

    Write-Host "Analyzing projects"

    [hashtable]$dllInfo = @{}
    [hashtable]$projectInfo = @{}

    [hashtable]$projectAndReferencedDlls = @{}
    [hashtable]$projectsAndReferencedProjects = @{}

    $currentTask = 0
    $totalTasks = $solution.Projects.Count

    updateProgress

    foreach($vsProj in $solution.Projects)
    {
        $projectName = $vsProj.Name

        if($vsProj.Kind -eq "{66A2671D-8FB5-11D2-AA7E-00C04F688DDE}")
        {
            Write-Host "$projectName is being skipped because it appears to be miscellaneous solution files"
            continue
        }                   
        
        [string]$targetFramework = $vsProj.Properties.Item("TargetFrameworkMoniker").Value;
        $targetFramework -imatch "\.NETFramework\,Version\=v(?<Version>\d+\.\d+)" | Out-Null

        $projectInfo[$projectName] = $Matches["Version"]

        $projectAndReferencedDlls[$projectName] = @()  
        $projectsAndReferencedProjects[$projectName] = @()  

        foreach($reference in $vsProj.Object.References)
        {
            [string]$referencePath = $reference.Path

            if($referencePath.StartsWith($targetDirectory)){
                $referencePath = $referencePath.Remove(0, $targetDirectory.Length + 1)
            }

            if(($referencePath -eq $null) -or ($referencePath.Length -eq 0)){
                Write-Host "$projectName contains an invalid reference to: $($reference.Name)"
            }
            elseif($reference.SourceProject -eq $null){
                $projectAndReferencedDlls[$projectName] += $referencePath

                if(-not $dllInfo.ContainsKey($referencePath)){
                    $dllInfo[$referencePath] = $reference.Version
                }
            }
            else{
                $projectsAndReferencedProjects[$projectName] += $reference.SourceProject.Name
            }
        }

        $currentTask++
        updateProgress
    }

    Write-Host "Projects Analyzed"
    Write-Host

    $dllSummaries = $dllInfo.Keys | 
        ForEach-Object { New-Object psobject -Property @{Name=(Split-Path $_ -Leaf); Version=$dllInfo["$_"]; Path=$_; } } | 
        Sort-Object @{Expression="Name";Descending=$false},@{Expression="Version";Descending=$false}

    $availableDllId = 0
    $dllSummaries | ForEach-Object { $availableDllId++; $_ | Add-Member -MemberType NoteProperty -Name Id -Value $availableDllId; }

    function GenerateProjectDllReferenceOutput()
    {    
        $projectAndReferencedDllsFilePath = Join-Path $targetDirectory "Projects and Referenced DLL's.csv"
        $projectAndDllSummaries = @()

        foreach($projectName in $projectAndReferencedDlls.Keys)
        {
            $projectDllSummary = New-Object psobject -Property @{Project=($projectName + " - .NET " + $projectInfo[$projectName]);}
            $referencedDlls = $projectAndReferencedDlls[$projectName]

            foreach($dllSummary in $dllSummaries)
            {
                [string]$isReferenced =  if($referencedDlls -contains $dllSummary.Path){"X"}Else{""}

                $projectDllSummary | Add-Member -MemberType NoteProperty -Name ($dllSummary.Name + " - " + $dllSummary.Version + " (ID: " + $dllSummary.Id + ")") -Value $isReferenced           
            }      
        
            $projectAndDllSummaries += $projectDllSummary  
        }        

        $projectAndDllSummaries | Sort-Object @{Expression="Project";Descending=$false} | Export-Csv -Path $projectAndReferencedDllsFilePath -NoTypeInformation
        
        Write-Host "Project DLL reference info written to: $projectAndReferencedDllsFilePath"
        Invoke-Item $projectAndReferencedDllsFilePath 
    }
    GenerateProjectDllReferenceOutput

    function GenerateDllOutput()
    {
        $dllOutputFilePath = Join-Path $targetDirectory "DLL Master List.csv"

        $dllSummaries | 
            Select-Object -Property Id,Name,Version,Path |
            Export-Csv -Path $dllOutputFilePath -NoTypeInformation

        Write-Host "DLL info written to: $dllOutputFilePath"
        Invoke-Item $dllOutputFilePath 
    }
    GenerateDllOutput

    function GenerateProjectToProjectReferenceOutput()
    {
        $projectsAndReferencedProjectsFilePath = Join-Path $targetDirectory "Projects and Referenced Projects.csv"
        $projectRefProjectSummaries = @()
        
        foreach($projectName in $projectsAndReferencedProjects.Keys)
        {
            $projectRefProjectSummary = New-Object psobject -Property @{Project=($projectName + " - .NET " + $projectInfo[$projectName]);}
            $referencedProjects = $projectsAndReferencedProjects[$projectName]

            foreach($otherProjectName in ($projectsAndReferencedProjects.Keys | Sort-Object))
            {
                [string]$isReferenced =  if($referencedProjects -contains $otherProjectName){"X"}Else{""}

                $projectRefProjectSummary | Add-Member -MemberType NoteProperty -Name ($otherProjectName + " - .NET " + $projectInfo[$otherProjectName]) -Value $isReferenced   
            }

            $projectRefProjectSummaries += $projectRefProjectSummary
        }

        $projectRefProjectSummaries | Sort-Object @{Expression="Project";Descending=$false} | Export-Csv -Path $projectsAndReferencedProjectsFilePath -NoTypeInformation
        
        Write-Host "Project to project reference info written to: $projectsAndReferencedProjectsFilePath"
        Invoke-Item $projectsAndReferencedProjectsFilePath 
    }
    GenerateProjectToProjectReferenceOutput
}

..\Shared\Ref\VisualStudio_PerformTask.ps1 -taskScriptBlockAsString $createSolution.ToString()