param(
    [string[]]$emailToAddrs,

    [string[]]$emailToAdGroupNames,

    [string[]]$emailCcs,

    [Parameter(Mandatory=$true)]
    [string]$emailSubject,

    [bool]$isBodyHtml = $false,

    [Parameter(Mandatory=$true)]
    [string]$emailBody,

    [string[]]$attachmentFilePaths,
    
    [PSCredential]$myCreds
)

. ..\Shared\Ref\Function_Misc.ps1

[Nullable[bool]]$hasAuthenticationError = $null

while($hasAuthenticationError -eq $null -or $hasAuthenticationError)
{

    if($emailToAddrs -eq $null)
    {
        $emailToAddrs = @()
    }

    if($emailToAdGroupNames -ne $null -and $emailToAdGroupNames.Count -gt 0)
    {
        foreach($adGroupName in $emailToAdGroupNames)
        {
            $groupObject = (New-Object DirectoryServices.DirectorySearcher "ObjectClass=group")
            $groupObject.Filter = "(name=$adGroupName)"
            $adGroupObject = $groupObject.FindOne()

            if($adGroupObject -ne $null)
            {
                $adGroupPath = $adGroupObject.Path -Replace 'LDAP://', ''
                $allMembers = (New-Object DirectoryServices.DirectorySearcher "ObjectClass=user")
                $allMembers.Filter = "(memberof=$adGroupPath)"
            
                try 
                {
                    $recipients = $allMembers.FindAll()
                
                    foreach($recipient in $recipients)
                    {
                        $recipentEmails = $recipient.Properties.mail
                    
                        if($recipentEmails -ne $null)
                        {
                            foreach($recipentEmail in $recipentEmails)
                            {
                                $emailToAddrs += $recipentEmail
                            }
                        }
                    }
                }
                catch
                {
                    Write-Warning "$adGroupName is not a valid Active Directory Group.  There must be one or more of: a valid distribution list, valid security group and/or vaild email address(es)."
                } 
            }
            else
            {
                Write-Warning "$adGroupName is not a valid Active Directory Group.  There must be one or more of: a valid distribution list, valid security group and/or vaild email address(es)."
            }
        }
    }

    if($emailToAddrs.Count -eq 0)
    {
        throw "No recipient email addresses were included.  There must be one or more of: a valid distribution list, valid security group and/or vaild email address(es)."
    }

    if([string]::IsNullOrWhiteSpace($myCreds.UserName))
    {
        [string]$emailSenderAddress = $null

        try
        {
            $emailSenderObject = GetUserDetails -userName $env:USERNAME -promptMessage "Enter user name"

            if($emailSenderObject -ne $null)
            {
                $emailSenderAddress = $emailSenderObject.Email
            }
        }
        catch
        {
            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
            [System.Windows.Forms.MessageBox]::Show("There was no response from Active Directory to pass current user email address." , "Active Directory unresponsive") 
            continue
        }

        $mycreds = $host.ui.PromptForCredential("Invalid Credentials", "Please enter email address and password.", $emailSenderAddress, "")
    }

    if($mycreds.UserName -inotmatch "([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})")
    {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        [System.Windows.Forms.MessageBox]::Show("The UserName should be the entire email address." , "Invalid UserName Credential") 
        $mycreds = Get-Credential -Message "Please enter email address and password."
    }

    [string]$smtpServer = "smtp.office365.com"
    [string]$port = "587"
    [string]$emailFrom = $mycreds.UserName

    [string]$sendmailCommand = "Send-MailMessage -To `$emailToAddrs -SmtpServer `$smtpServer -Credential `$mycreds -UseSsl `$emailSubject -Port `$port -Body `$emailBody -From `$emailFrom"
    if($emailCcs -ne $null)
        {
            $sendmailCommand += " -CC `$emailCcs"
        }

    if($isBodyHtml)
    {
        $sendmailCommand += " -BodyAsHtml"
    }

    if($attachmentFilePaths -ne $null)
    {
        $sendmailCommand += " -Attachments `$attachmentFilePaths"
    }

    try
    {
        $hasAuthenticationError = $false
        iex $sendmailCommand
    }
    catch
    {
        $hasAuthenticationError = $Error[0].Exception -imatch "\w*A?a?uthenticat\w*"

        if(!$hasAuthenticationError)
        {
            throw
        }

        Write-Warning "Email address or password is invalid.  Please re-enter your credentials."
        Write-Host
        Pause
        $myCreds = $null
    }
}