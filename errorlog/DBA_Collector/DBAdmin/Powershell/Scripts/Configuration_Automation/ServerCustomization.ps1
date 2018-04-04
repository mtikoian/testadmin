<#

SEI eDev Customizations
Author: Josh Feierman 11/18/2011

#>

Set-StrictMode -Version "Latest";

#Get Windows version
$windowsVersion = (Get-WmiObject win32_operatingsystem | select Version).Version;

#Create shortcuts on all desktop
$shell = New-Object -ComObject WScript.Shell;
$desktopPath = $shell.SpecialFolders.Item("AllUsersDesktop");

#Command prompt
if (-not (Test-Path "$desktopPath\CMD.lnk"))
{
    $cmdPath = "$($env:windir)\system32\cmd.exe";
    $shortcut = $shell.CreateShortcut("$desktopPath\CMD.lnk");
    $shortcut.TargetPath = $cmdPath;
    $shortcut.Save();
}

#Computer Management
$cmdPath = "$($env:SystemRoot)\system32\compmgmt.msc";
$shortcut = $shell.CreateShortcut("$desktopPath\Computer Management.lnk");
$shortcut.TargetPath = $cmdPath;
$shortcut.Save();

#Windows Explorer
$cmdPath = "$($env:SystemRoot)\explorer.exe";
$shortcut = $shell.CreateShortcut("$desktopPath\Windows Explorer.lnk");
$shortcut.TargetPath = $cmdPath;
$shortcut.Save();

#Network Connections
#Haven't figured this one out yet

#Delete local ZAQ user if it exists
$objComputer = [ADSI]("WinNT://$($env:computername),computer");
$colUsers = ($objComputer.psbase.children | Where-Object {$_.psBase.schemaClassName -eq "User"} | Select-Object -expand Name);
$blnExists = $colUsers -contains "ZAQ12WSX";
if ($blnExists)
{
    $objComputer.Delete("user","ZAQ12WSX");
}

#Services
function SEISet-Service
{

    param
    (
        [string]$ServiceName,
        [switch]$Enable,
        [switch]$Disable
    )
    
    #Validate parameters
    if (($Enable -and $Disable) -or (-not $Enable -and -not $Disable))
    {
        Write-Error "You must either specify '-Enable' or '-Disable' and you cannot specify both.";
        Return;
    }
    #Check if the service exists
    if (Get-Service $ServiceName)
    {
        if ($Enable)
        {
            Set-Service -Name $ServiceName -StartupType Automatic;
            Start-Service $ServiceName;
        }
        else
        {
            Set-Service -Name $ServiceName -StartupType Disabled
            Stop-Service $ServiceName;
        }
    }
}

SEISet-Service -ServiceName BITS -Enable;
SEISet-Service -ServiceName MSDTC -Enable;
SEISet-Service -ServiceName Dnscache -Enable;
SEISet-Service -ServiceName Dhcp -Enable;
SEISet-Service -ServiceName RemoteRegistry -Enable;
SEISet-Service -ServiceName TermService -Enable;
SEISet-Service -ServiceName lmhosts -Enable;
SEISet-Service -ServiceName W32Time -Disable;
SEISet-Service -ServiceName WUAUSERV -Disable;
#Begin WIndows 2008+ specific services
if ($windowsVersion -like "6*")
{
    SEISet-Service -ServiceName NlaSvc -Enable;
    SEISet-Service -ServiceName netprofm -Enable;
    SEISet-Service -ServiceName MpsSvc -Enable;
    SEISet-Service -ServiceName WerSvc -Disable;
}
else
#We only need to turn off Error Reporting
{
    SEISet-Service -ServiceName ERSvc -Disable;
}

#Terminal Services

#Function courtesy of http://blogs.technet.com/b/jamesone/archive/2009/01/31/checking-and-enabling-remote-desktop-with-powershell.aspx
Function Set-RemoteDesktopConfig
{Param ([switch]$LowSecurity, [switch]$disable) 
 if ($Disable) {
       set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'`
                        -name "fDenyTSConnections" -Value 1 -erroraction silentlycontinue 
       if (-not $?) {new-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
                                      -name "fDenyTSConnections"  -Value 1 -PropertyType dword }
       set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'`
                        -name "UserAuthentication" -Value 1 -erroraction silentlycontinue
      if (-not $?) {new-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
                        -name "UserAuthentication" -Value 1 -PropertyType dword} 
     } 
else {
       set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
                        -name "fDenyTSConnections" -Value 0 -erroraction silentlycontinue
        if (-not $?) {new-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
                                      -name "fDenyTSConnections" -Value 0 -PropertyType dword } 
       if ($LowSecurity) {
           set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'`
                                               -name "UserAuthentication" -Value 0 -erroraction silentlycontinue 
        if (-not $?) {new-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'`
                                          -name "UserAuthentication" -Value 0 -PropertyType dword}
          }
     } 

}

Set-RemoteDesktopConfig -LowSecurity;

#Setup Windows Firewall
if ($windowsVersion -like "6*")
{
    $fwObj = New-Object -ComObject HNetCfg.FwPolicy2;

    #Set default incoming policy to allow
    $fwObj.DefaultInboundAction(1) = 1;
}

#Joining to domain
function Join-Domain
{

    param
    (
        [string]$DomainName
    )
    
    #Get the computer system object
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem;
    
    #Get the credentials to join the domain
    $credential = ($host.UI.PromptForCredential("Domain Admin Credential","Please enter a credential with rights to join to the domain.",$null,$null)).GetNetworkCredential();
    $domainUser = $credential.get_Domain() + "\" + $credential.get_UserName();
    $domainPassword = $credential.get_Password();
    
    #Join to the domain
    $computerSystem.JoinDomainOrWorkgroup($DomainName,$domainPassword,$domainUser,$null,3) | Out-Null;
    
    Write-Host "Joined computer to domain successfully.";

}

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Join the computer to a specified domain."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Leave the machine as it is.."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice("Join Domain", "Would you like to join the computer to a domain?", $options, 0);

if ($result -eq 0)
{
    #Get the name of the domain to join.
    $DomainName = Read-Host -Prompt "Please enter the full DNS name of the domain to join.";
    
    #Let the user know they'll be prompted for credentials and continue
    Write-Host -ForegroundColor Yellow "You will now be prompted for credentials to join the computer to the domain.";
    Read-Host -Prompt "Please press Enter to continue.";
    Join-Domain -DomainName $DomainName;
}

#Add users to local administrators group

function Add-LocalAdministrator
{

    param
    (
        [string]$UserName,
        [string]$DomainName
    )
    
    $adminGroup = [ADSI]("WinNT://$env:computername/administrators,group");
    
    if ($DomainName -eq $null)
    {
        $DomainName = $env:COMPUTERNAME;
    }
    
    $adminGroup.Add("WinNT://$DomainName/$UserName");
    
    $adminGroup = $null;

}

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Yes, add a user to the administrators group."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "No, do not add a user to the administrators group."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice("Local Administrators", "Would you like to add a user to the local administrators group?", $options, 0);

while ($result -eq 0)
{
    $UserName = Read-Host -Prompt "Please enter the user name (not including the domain name) to add to the administrators group.";
    $DomainName = Read-Host -Prompt "Please enter the domain name of the user to be added. If it is a local user, enter the local machine name.";
    
    Add-LocalAdministrator -UserName $UserName -DomainName $DomainName;
    
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Yes, add another user to the administrators group."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "No, do not add another user to the administrators group."
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice("Local Administrators", "Would you like to add another user to the local administrators group?", $options, 0);
}

# Windows activation
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Yes, activate the OS."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "No, do not activate the OS."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice("OS Activation", "Would you like to activate the OS?", $options, 0);

if ($result -eq 0)
{

    $cmd = "$env:windir\system32\cscript.exe `"$env:windir\system32\SLMGR.vbs`" /SKMS 10.40.40.141"
    Invoke-Expression $cmd;
    if ($LASTEXITCODE -ne 0) {throw "Error setting KMS server."}
    
    $cmd = "$env:windir\system32\cscript.exe `"$env:windir\system32\SLMGR.vbs`" /ATO"
    Invoke-Expression $cmd;
    if ($LASTEXITCODE -ne 0) {throw "Error activating OS."}

}

#Delete complete setup VBS file
Get-ChildItem -Path $env:USERPROFILE\..\ -Include "Complete Setup.vbs" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Verbose


