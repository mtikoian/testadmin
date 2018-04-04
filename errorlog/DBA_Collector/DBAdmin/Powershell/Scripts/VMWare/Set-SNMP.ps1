<#
.SYNOPSIS
   Sets the SNMP configuration of an ESX server.
.PARAMETER Server
   The name of the ESX server to connect to.
#>
[Cmdletbinding()]
param
(
	[parameter(mandatory=$true,ValueFromPipeline=$true)]
	[string]$Server
)

begin 
{
	if (-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue))
	{
		Add-PSSnapin VMware.vimautmation.core
	}
	
	$cred = $Host.UI.PromptForCredential("ESX Credential","Please enter a user name to connect to the specified ESX hosts.",$null,$null)
}
process 
{
	Connect-VIServer $Server -Credential $cred
	
	Get-VMHostSnmp | 
		Set-VMHostSnmp -AddTarget -TargetCommunity "public" -TargetHost "snmp1.corp.seic.com" -TargetPort 162 |
		Set-VMHostSnmp -AddTarget -TargetCommunity "public" -TargetHost "snmp2.corp.seic.com" -TargetPort 162 |
		Set-VMHostSnmp -AddTarget -TargetCommunity "public" -TargetHost "snmp3.corp.seic.com" -TargetPort 162 |
		Set-VMHostSnmp -Enabled $true |
		Test-VMHostSnmp
		
	Disconnect-VIServer -Confirm:$false
}