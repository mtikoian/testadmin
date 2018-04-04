<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>

function New-VMHostStoragePathMask
{
	[Cmdletbinding()]
	param
	(
		[parameter(mandatory=$true,position=0)]
		[VMWare.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]$VMHost,
		[parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
		[string]$Adapter,
		[parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
		[int]$Channel,
		[parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
		[int]$Target,
		[parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
		[int]$LUN
	)
	begin
	{
		try
		{
			$cli = get-esxcli -VMHost $VMHost
		}
		catch
		{
			Write-Warning $_.Exception.Message
			return
		}
	}
	process
	{
		try
    {
      # Get the next rule number
      $ruleNum = ($cli.corestorage.claimrule.list() | 
            Select-Object @{n="Rule";e={[int]$_.Rule}} |
            Sort-Object -Property Rule -Descending |
            Where-Object {$_.Rule -lt 65535} |
            Select-Object -First 1).Rule + 1
      
      # Add the rule
      $cli.corestorage.claimrule.add($Adapter,$Channel,$null,$null,$LUN,$null,"MASK_PATH",$ruleNum,$Target,$null,'location',$null)
      $cli.corestorage.claimrule.load()
      
      # Un-claim the device
      $cli.corestorage.claiming.unclaim($Adapter,$Channel,$null,$null,$LUN,$null,$null,$Target,'location')
      $cli.corestorage.claimrule.run()
    }
    catch
    {
      Write-Warning $_.Exception.Message
      return
    }
	}
}