function PromptForYesNoValue([Parameter(Mandatory = $true)][string]$displayMessage, [bool] $isYesDefaultValue=$true)
{         
	[hashtable] $yesNoValues = @{"&Yes"="Y"; "&No"="N"}
    [string] $defaultValue = $null
    
    if($isYesDefaultValue)
    {
        $defaultValue = "Y"
    }

    return ..\Shared\Ref\ReadHostWithAllowedValues.ps1 -allowedValues $yesNoValues -defaultValue $defaultValue -message $displayMessage
}

function GetUserDetails([string]$userName=$null, [string]$promptMessage, [bool]$allowCurrentUser = $true )
{
    [PsCustomObject]$userDetails = $null             

    while($userDetails -eq $null)
    {
        if([string]::IsNullOrWhiteSpace($userName) -and ![string]::IsNullOrWhiteSpace($promptMessage))
        {
            $userName = Read-Host $promptMessage
        }
    
        if(!$allowCurrentUser -and $userName -ieq $env:USERNAME)
        {
            Write-Warning "User name should not be current user: $userName"
            $userName = $null
            continue
        }

        if(![string]::IsNullOrWhiteSpace($userName))
        {
            $searcher = [ADSISearcher]"(samaccountname=$userName)" 
            $results = $searcher.FindOne() 

            if ($results -eq $null) 
            {
                Write-Warning "User name not found in active directory: $userName"   
                $userName = $null

                if([string]::IsNullOrWhiteSpace($promptMessage)){ 
                    return $null
                }
            }        
            else
            {
                $userName = $results.Properties["samaccountname"].Item(0)
                $fullName = $results.Properties["givenname"].Item(0) + " " + $results.Properties["sn"].Item(0)
      
                $userDetails = [PsCustomObject] @{
                    FullName = $fullName
                    UserName =  $userName
	                FormattedName = $fullName + " ($($userName))"
                    Email = $results.Properties["mail"].Item(0)
                    DisplayName = $results.Properties["displayname"]
                }
            } 
        }
    }

    return $userDetails
}

function GetSqlException([System.Exception]$exception) 
{ 
    [string]$sqlException = $exception.Message
    if($exception.InnerException -ne $null)
    {
        if($exception.InnerException.GetType() -eq [System.Data.SqlClient.SqlException]) 
        { 
            $sqlException = $exception.InnerException.Message
            return $sqlException
        } 
        else 
        {            
            return GetSqlException -exception $exception.InnerException
        } 
    }
    else
    {
        return $sqlException
    }
} 

function DisplayWaitTimeProgressBar(
        
        [Parameter(Mandatory=$true)]
        [int]$secondsToPause, 
        
        [Parameter(Mandatory=$true)]
        [string]$activityMessage)
{
    [int]$originalSecondsToWait = $secondsToPause;

    while($secondsToPause -ge 0)
    {                    
        [string]$timeRemainingText = $([string]::Format("Seconds Remaining: {0:d2}", $secondsToPause))

        [int]$percentageComplete = ($secondsToPause/$originalSecondsToWait) * 100

        if($secondsToPause -eq 0)
        {
            Write-Progress -Activity $activityMessage -Status $timeRemainingText -PercentComplete $percentageComplete -Completed
        }
        else
        {
            Write-Progress -Activity $activityMessage -Status $timeRemainingText -PercentComplete $percentageComplete
            Start-Sleep -Seconds 1
        }

        $secondsToPause--        
    }
}