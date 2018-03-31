Clear-Host

[string]$configFileName = $MyInvocation.MyCommand.Name -ireplace "\..+$",".config"
$path = Read-Host "Enter resume folder path"

[string]$skillCountPropertyName = $null

$exclusionDirectoryPaths = @(
    
)

$fileExtensions = @(
    "*.doc","*.docx","*.pdf","*.rtf","*.txt"
)

$searchTopics = @()

function ThrowUnexpectedNode($node)
{
    throw "Unexpected xml node: $(GetNodePath $node)"
}

function ReadTopics($topicsNode)
{  
    foreach($topicNode in $topicsNode.ChildNodes)
    {
        $name = $topicNode.text
        [string[]]$searchTerms = @($topicNode.SelectNodes('synonyms/add') | Select -ExpandProperty Text)
        $searchTerms += $name

        $searchTopic = New-Object psobject -Property @{Name=$name; SearchTerms=$searchTerms}
        $global:searchTopics += $searchTopic
    }    
}

function ReadConfigFile()
{
    [xml]$xml = Get-Content $configFileName
    
    foreach($rootNode in $xml.ChildNodes)
    {
        if($rootNode.Name -eq "configuration")
        {
            foreach($rootChildNode in $rootNode.ChildNodes)
            {
                if($rootChildNode.Name -eq "topics"){
                    ReadTopics $rootChildNode
                }
                else{
                    ThrowUnexpectedNode $rootChildNode
                }
            }
        }
        else {
            ThrowUnexpectedNode $rootNode
        }
    }
}

function AnalyzeResume {
    param([string]$fileName)

    $result = $null

    try
    {        
        $docText = "" 
        
        if(-not $fileName.EndsWith(".pdf"))
        {
            $word = New-Object -ComObject Word.Application

            try
            {                   
                $word.Visible = $false
                $wordDoc = $null

                try
                {
                    $wordDoc = $word.Documents.Open($fileName, $false, $true)
                    $docText = $wordDoc.Content.Text
                }
                finally
                {
                    if($wordDoc -ne $null){
                        $wordDoc.Close()
                    }
                }
            }
            finally
            {
                if($word -ne $null){
                    $word.Quit($false)
                    $word = $null
                }
            }
        }  
        else
        {
            Add-Type -Path .\itextsharp.dll
            $pdfReader = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList $fileName

            try
            {
                for($page = 1; $page -le $pdfReader.NumberOfPages; $page++)
                {
                    $strategy = new-object  'iTextSharp.text.pdf.parser.SimpleTextExtractionStrategy'            
                    $currentText = [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($pdfReader, $page, $strategy);
                    [string[]]$textArray += [system.text.Encoding]::UTF8.GetString([System.Text.ASCIIEncoding]::Convert( [system.text.encoding]::default, [system.text.encoding]::UTF8, [system.text.Encoding]::Default.GetBytes($currentText)));

                    $docText += $textArray -join ""
                }
            }
            finally
            {
                if($pdfReader -ne $null){
                    $pdfReader.Dispose()
                    $pdfReader = $null
                }
            }
        }     
        
        $global:skillCountPropertyName = "Skill Count (Max $($searchTopics.Count))" 

        $result = New-Object psobject -Property @{Candidate=[io.path]::GetFileNameWithoutExtension($fileName); }
        $result | Add-Member -MemberType NoteProperty -Name "Rank" -Value ""
        $result | Add-Member -MemberType NoteProperty -Name "Comments" -Value ""
        $result | Add-Member -MemberType NoteProperty -Name "Experience (Years)" -Value ""
        $result | Add-Member -MemberType NoteProperty -Name "Architect" -Value ""
        $result | Add-Member -MemberType NoteProperty -Name "Team Lead" -Value ""
        $result | Add-Member -MemberType NoteProperty -Name "$skillCountPropertyName" -Value 0        

        [int]$skillScore = 0

        foreach($topic in $searchTopics)
        {
            $present = "";

            foreach($term in $topic.SearchTerms)
            {
                if($docText -imatch ("[\b,\s]+" + [Regex]::Escape($term) + "[\b,\s]+"))
                {
                    $present = "X";
                    $skillScore++;
                    break;
                }
            }

            $result | Add-Member -MemberType NoteProperty -Name $topic.Name -Value $present
        }

        $result."$skillCountPropertyName" = $skillScore
    }
    catch
    {
        Write-Host "Error on $fileName : $($_.Exception.Message)"
        throw
    }

    return $result
}

ReadConfigFile

$startTime = Get-Date
[int]$numCompleted = 0
$results = @()

Write-Host "Building file list..."
$fileNames = Get-ChildItem -Path $global:path -Recurse -Include $fileExtensions | Sort-Object FullName | Select -ExpandProperty FullName
Write-Host "File list built."
Write-Host ""

Write-Host "Getting Exclusions..."
$exclusionNames = Get-ChildItem $global:exclusionDirectoryPaths -Recurse -Include $fileExtensions | Sort-Object FullName | Select -ExpandProperty BaseName

$originalFileNames = @($fileNames)
$fileNames = @()

foreach($fileName in @($originalFileNames))
{
    $candidateName = [io.path]::GetFileNameWithoutExtension($fileName)
    $include = $true

    foreach($exclusion in $exclusionNames)
    {
        if($exclusion -imatch [Regex]::Escape($candidateName))
        {
            Write-Host "Excluded: $fileName"
            $include = $false
            break
        }
    }

    if($include){
        $fileNames += $fileName
    }
}
Write-Host "Files excluded"
Write-Host ""

function updateProgress() {
    Write-Progress -activity "Analyzing Files" -status "$global:numCompleted/$($fileNames.Length) Completed" -PercentComplete (($global:numCompleted / $fileNames.length)  * 100)
}

updateProgress

foreach($fileName in $fileNames)
{
    $results += AnalyzeResume $fileName
    $global:numCompleted++;

    updateProgress
}

$scriptDirectory = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
$resultFilePath = $scriptDirectory + "\Resume Analysis " + (Get-Date -Format "yyyy_MM_dd_HHmmss") + ".csv"

$results | Sort-Object @{Expression="Child Support";Descending=$true}, @{Expression="$skillCountPropertyName";Descending=$true}, @{Expression="Candidate";Descending=$false} | Export-Csv -Path $resultFilePath -NoTypeInformation -NoClobber
Write-Host "Results written to: $resultFilePath"

$timeElapsed = New-TimeSpan $startTime $(Get-Date)
Write-Host ""
Write-Host "Minutes elapsed: $($timeElapsed.TotalMinutes)"
Write-Host "Files analyzed: $($results.Count)"
Write-Host "Seconds per file: $($timeElapsed.TotalSeconds / $results.Count)"

    
Invoke-Item $resultFilePath 