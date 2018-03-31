$replaceFrameworkDllReferences = {
    param($vsIde)

    $targetSolution = "C:\Workspace\CSES\Dev\CSES.sln" #Read-Host "Enter solution path"
    Write-Host

    Write-Host "$targetSolution opening..."
    $vsIde.Solution.Open($targetSolution)
    $solution = $vsIde.Solution
    Write-Host "$targetSolution opened"
    Write-Host

    #add-type -assemblyName "VSLangProj"
    $solutionFolderKind = "{66A26720-8FB5-11D2-AA7E-00C04F688DDE}"
    $allProjects = @{}

    Write-Host "Gathering Projects..."

    function GatherProjects([int]$level, $projects){
        $padding = " " * 5 * $level

        foreach($project in $projects)
        {
            if($project.SubProject -ne $null){
                $project = $project.SubProject
            }

            if($project.Kind -eq $solutionFolderKind){
                GatherProjects $($level + 1) $project.ProjectItems
            }
            elseif($project.ConfigurationManager -ne $null){
                $allProjects.Add($project.Name, $project)
            }
        }
    }
    GatherProjects $level $solution.Projects  
    
    Write-Host "Projects Gathered"
    Write-Host

    $padding = " " * 5

    foreach($project in ($allProjects.Values | Sort-Object -Property Name))
    {
        Write-Host "$($project.Name) - starting dll replacement"

        $projectObject = $project.Object
        $references = @($projectObject.References)

        foreach($reference in ($references | Sort-Object -Property Name)){
            $referenceName = $reference.Name

            if($reference.SourceProject -eq $null -and $referenceName.StartsWith("Saber.Framework")){
                if(($project.Name -eq 'Saber.Framework.Exception.Logger' -and $referenceName -eq 'Saber.Framework.BusinessDate') -or
                    ($project.Name -eq 'Saber.Framework.BusinessDate' -and $referenceName -eq 'Saber.Framework.Domain.Base')){
                    Write-Host "$padding $referenceName - skipping circular reference"
                    continue
                }

                Write-Host "$padding $referenceName - replacing"                

                $reference.Remove()
                $projectToRef = $allProjects[$referenceName]

                if($projectToRef -eq $null){
                    throw "Could not find $referenceName project"
                }

                $projectObject.References.AddProject($projectToRef) | Out-Null

                Write-Host "$padding $referenceName - replaced"
                Write-Host
            }
        }

        Write-Host "$($project.Name) - finished dll replacement"
        Write-Host
    }       
     
    $vsIde.ExecuteCommand("File.SaveAll")
}

.\Common\VisualStudio_PerformTask.ps1 -taskScriptBlockAsString $replaceFrameworkDllReferences.ToString()