function New-Login
{
	<#

	.SYNOPSIS
	 Used to create a new login on a SQL Server instance.
	 
	.NOTES
	 Author - Josh Feierman

	#>

	param
	(

		[parameter()][string]$LoginName = "",
		[parameter()][string]$ServerName = "",
		[parameter()][string]$Password = "",
		[parameter()][switch]$IsSQLAccount = $false,
		[parameter()][string]$DefaultDatabase = "",
		[parameter()][switch]$Interactive = $false

	)

	function Collect-Input
	{
		
		#Create the form and gather input
		$inputs = New-Window -Title "New Login" -Width 200  -Height 200 -WindowStartupLocation CenterScreen -HorizontalAlignment Stretch -Content {
			New-UniformGrid -Columns 2 -Children {
				"Login Name";
				New-TextBox -Name txtLoginName -Text $LoginName;
				"Is this a SQL Login?";
				New-CheckBox -Name chkIsSQLLogin -IsChecked $IsSQLAccount -On_Checked {$txtPassword.IsEnabled = $true} -On_unchecked {$txtPassword.IsEnabled = $false};
				"Password";
				New-TextBox -Name txtPassword -Text $Password -IsEnabled:$false;
				New-Button -Content "OK" -On_Click {
					Get-ParentControl | Set-UIValue -passThru | Close-Control;
				};
				New-Button -Content "Cancel" -On_Click {
					Get-ParentControl | Close-Control;
					return $null;
				};
			}
		} -Show;
		
		if ($inputs -eq $null) {return $null;}
		
		$LoginName = $inputs["txtLoginName"];
		$Password = $inputs["txtPassword"];
		$IsSQLAccount = $inputs["chkIsSQLAccount"];
		$DefaultDatabase = $inputs["txtDefaultDatabase"];
		
		return $true;

	}

	function Validate-Input
	{
		
		$Valid = $true;
		
		#Rule: If -IsSQLLogin = true password must be set
		if ($IsSQLAccount -and (($Password -eq $null) -or ($Password -eq "")))
		{
			Write-Error "If the account is a SQL Account, a password must be specified.";
			$Valid = $false;
		}
		#Rule: Default database must be specified
		if (($DefaultDatabase -eq $null) -or ($DefaultDatabase -eq ""))
		{
			Write-Error "A default database must be specified.";
			$Valid = $false;
		}
		
		return $Valid;

	}

	#If -Interactive is specified, present a dialog for input
	if ($Interactive)
	{
		
		$result = Collect-Input;
		
		if ($result -eq $null) {return;}
		
		$ArgsIsValid = $false; 	#Indicates if arguments were valid for interactive process
		
		#Enter loop to validate input then allow for re-entry if necessary
		While ($ArgsIsValid -eq $false)
		{
			$ArgsIsValid = Validate-Input;
			if ($ArgsIsValid -eq $false) {Collect-Input;}
		}
	}
}