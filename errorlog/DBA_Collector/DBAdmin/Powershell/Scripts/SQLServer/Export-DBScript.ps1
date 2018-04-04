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

[Cmdletbinding()]
param
(
	[parameter(mandatory=$true)]
	[string]$Server,
	[parameter(mandatory=$true)]
	[string]$Database,
	[parameter(mandatory=$true)]
	[string]$Path,
	[parameter(mandatory=$false)]
	[switch]$ScriptTables = $true,
	[parameter(mandatory=$false)]
	[switch]$ScriptForeignKeys = $true,
	[parameter(mandatory=$false)]
	[switch]$ScriptTriggers = $true,
	[parameter(mandatory=$false)]
	[switch]$ScriptProcedures = $true,
	[parameter(mandatory=$false)]
	[switch]$ScriptViews = $true,
	[parameter(mandatory=$false)]
	[switch]$ScriptFunctions = $true,
	[parameter(mandatory=$false)]
	[switch]$ScriptSymmetricKeys = $true, 
	[parameter(mandatory=$false)]
	[string[]]$IncludeSchemas = $null,
	[parameter(mandatory=$false)]
	[switch]$AddSVNTag
)
begin
{
	Set-StrictMode -Version 2

	Write-Verbose "Loading SMO assembly"
	try
	{
		[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SQLServer.Management.SMO") | Out-Null
	}
	catch
	{
		Write-Warning "Could not load SMO assembly, please make sure it is installed."
		Write-Warning "Error: $($_.Exception.Message)"
		break
	}

	if ($AddSVNTag)
	{
		$script:AddSVNTag = $true
	}

	function Script-Object
 {
		[Cmdletbinding()]
		param
		(
			[parameter(mandatory=$true)]
			[Object]$ScriptObject,
			[parameter(mandatory=$false)]
			[Microsoft.SqlServer.Management.Smo.ScriptingOptions]$ScriptOptions
		)

		$tempFile = "$env:temp\temp.sql"

		if ($script:AddSVNTag)
		{
			$headerText = @'
/*********************************************************
 $Author: $
 $Date: $
 $Rev:  $
 $URL: $
 *********************************************************/

'@
		}
		else
		{
			$headerText = ""
		}

		if ($ScriptOptions -eq $null)
		{
      $scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
		}

  	$scriptOptions.FileName = $tempFile
    $scriptOptions.ToFileOnly = $true
    $ScriptObject.Script($scriptOptions)
    $scriptText = [String]::Join([Environment]::NewLine,(Get-Content $tempFile))

		$dropText = switch ($ScriptObject.GetType().Name)
		{
			"View" { "IF EXISTS (SELECT 1 `n" +
				"           FROM INFORMATION_SCHEMA.VIEWS `n" +
				"           WHERE TABLE_SCHEMA = '$($ScriptObject.Schema)' `n" +
				"                 AND TABLE_NAME = '$($ScriptObject.Name)')`n" +
				"   DROP VIEW $($ScriptObject.Schema).$($ScriptObject.Name);`n"}
			"Table" {"IF EXISTS (SELECT 1 `n" +
				"           FROM INFORMATION_SCHEMA.TABLES `n" +
				"           WHERE TABLE_SCHEMA = '$($ScriptObject.Schema)' `n" +
				"                 AND TABLE_NAME = '$($ScriptObject.Name)')`n" +
				"   DROP TABLE $($ScriptObject.Schema).$($ScriptObject.Name);`n"}
			"StoredProcedure" {"IF EXISTS (SELECT 1 `n" +
				"           FROM INFORMATION_SCHEMA.ROUTINES `n" +
				"           WHERE ROUTINE_TYPE = 'PROCEDURE' `n" +
				"                 AND ROUTINE_SCHEMA = '$($ScriptObject.Schema)' `n" +
				"                 AND ROUTINE_NAME = '$($ScriptObject.Name)')`n" +
				"   DROP PROCEDURE $($ScriptObject.Schema).$($ScriptObject.Name);`n"}
			"UserDefinedFunction" {"IF EXISTS (SELECT 1 `n" +
				"           FROM INFORMATION_SCHEMA.ROUTINES `n" +
				"           WHERE ROUTINE_TYPE = 'FUNCTION' `n" +
				"                 AND ROUTINE_SCHEMA = '$($ScriptObject.Schema)' `n" +
				"                 AND ROUTINE_NAME = '$($ScriptObject.Name)')`n" +
				"   DROP FUNCTION $($ScriptObject.Schema).$($ScriptObject.Name);`n"}
			default {""}
		}
		if ($dropText -ne "")
		{
			$scriptText = $headerText + $dropText + "GO`n" + $scriptText
		}

		Write-Output $scriptText
	}


}
process
{
	try
	{
		Write-Verbose "Retrieving database $database from server $server"
		$serverObj = New-Object Microsoft.SqlServer.Management.Smo.Server "$Server"
		$databaseObj = $serverObj.Databases["$database"]

		#Tables
		if ($ScriptTables)
		{
			Write-Verbose "Scripting tables"

			if (-not (Test-Path "$Path\Tables"))
			{
				New-Item -ItemType "Directory" -Path "$Path\Tables"
			}

			$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
			$scriptOptions.DriChecks = $true
			$scriptOptions.DriClustered = $true
			$scriptOptions.DriDefaults = $true
			$scriptOptions.DriForeignKeys = $false
			$scriptOptions.DriIndexes = $true
			$scriptOptions.ExtendedProperties = $true 
			$scriptOptions.Permissions = $true
			$scriptOptions.ScriptBatchTerminator = $true

			foreach ($table in $databaseObj.Tables)
			{
				if ($IncludeSchemas -contains $table.Schema -or $IncludeSchemas -eq $null)
				{
					Write-Verbose "Scripting table $($table.Name)"
					Script-Object $table $scriptOptions | Set-Content -Path "$Path\Tables\$($table.Schema).$($table.Name).table.sql"
				}
			}

		}

		#Foreign Keys
		if ($ScriptForeignKeys)
		{
			Write-Verbose "Scripting foreign keys"

			if (-not (Test-Path "$Path\ForeignKeys"))
			{
				New-Item -ItemType "Directory" -Path "$Path\ForeignKeys"
			}

			foreach ($table in $databaseObj.Tables)
			{
				if ($IncludeSchemas -contains $table.Schema -or $IncludeSchemas -eq $null)
				{
					foreach ($foreignKey in $table.ForeignKeys)
					{
						Write-Verbose "Scripting foreign key $($foreignKey.Name)"
						Script-Object $foreignKey | Set-Content -Path "$Path\ForeignKeys\$($foreignKey.Name).fk.sql"
					}
				}
			}
		}

		#Triggers
		if ($ScriptTriggers)
		{
			Write-Verbose "Scripting Triggers"

			if (-not (Test-Path "$Path\Triggers"))
			{
				New-Item -ItemType "Directory" -Path "$Path\Triggers"
			}

			foreach ($table in $databaseObj.Tables)
			{
				if ($IncludeSchemas -contains $table.Schema -or $IncludeSchemas -eq $null)
				{
					foreach ($trigger in $table.Triggers)
					{
						Write-Verbose "Scripting trigger $($trigger.Name)"
						Script-object $trigger | Set-Content -Path "$Path\Triggers\$($trigger.Name).trg.sql"
					}
				}
			}
		}

		#Procedures
		if ($ScriptProcedures)
		{
			Write-Verbose "Scripting Procedures"

			if (-not (Test-Path "$Path\Procedures"))
			{
				New-Item -ItemType "Directory" -Path "$Path\Procedures"
			}

			$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions

			$scriptOptions.ExtendedProperties = $true
			$scriptOptions.Permissions = $true
			#$scriptOptions.IncludeHeaders = $true

			foreach ($procedure in $databaseObj.StoredProcedures)
			{
				if ($IncludeSchemas -contains $procedure.Schema -or $IncludeSchemas -eq $null)
				{
					Write-Verbose "Scripting Procedure $($Procedure.Name)"
					$scriptText = Script-object $procedure $scriptOptions

					Set-Content -Path "$Path\Procedures\$($Procedure.Schema).$($Procedure.Name).sp.sql" -Value $scriptText
				}
			}
		}

		#Views
		if ($ScriptViews)
		{
			Write-Verbose "Scripting Views"

			if (-not (Test-Path "$Path\Views"))
			{
				New-Item -ItemType "Directory" -Path "$Path\Views"
			}

			$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
			$scriptOptions.DriChecks = $true
			$scriptOptions.DriClustered = $true
			$scriptOptions.DriDefaults = $true
			$scriptOptions.DriForeignKeys = $false
			$scriptOptions.DriIndexes = $true
			$scriptOptions.ExtendedProperties = $true 
			$scriptOptions.Permissions = $true
			$scriptOptions.ScriptBatchTerminator = $true

			foreach ($view in $databaseObj.Views)
			{
				if ($IncludeSchemas -contains $view.Schema -or $IncludeSchemas -eq $null)
				{
					Write-Verbose "Scripting View $($View.Name)"
					$scriptText = Script-Object $view $scriptOptions

					Set-Content -Path "$Path\Views\$($view.Schema).$($view.Name).view.sql" -Value $scriptText
				}
			}
		}

		#Views
		if ($ScriptFunctions)
		{
			Write-Verbose "Scripting Functions"

			if (-not (Test-Path "$Path\Functions"))
			{
				New-Item -ItemType "Directory" -Path "$Path\Functions"
			}

			$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
			$scriptOptions.ExtendedProperties = $true 
			$scriptOptions.Permissions = $true
			$scriptOptions.ScriptBatchTerminator = $true

			foreach ($function in $databaseObj.UserDefinedFunctions)
			{
				if ($IncludeSchemas -contains $Function.Schema -or $IncludeSchemas -eq $null)
				{
					Write-Verbose "Scripting Function $($function.Name)"
					$scriptText = Script-Object $function $scriptOptions

					Set-Content -Path "$Path\Functions\$($function.Schema).$($function.Name).function.sql" -Value $scriptText
				}
			}
		}


		#Symmetric Keys
		if ($ScriptSymmetricKeys)
		{
			if (-not (Test-Path "$Path\SymmetricKeys"))
			{
				New-Item -ItemType "Directory" -Path "$Path\SymmetricKeys"
			}
			foreach ($symKey in $databaseObj.SymmetricKeys)
			{
				Write-Verbose "Scripting symmetric key $($symKey.Name)"
				Script-Object $symKey | Set-Content -Path "$Path\SymmetricKeys\$($symKey.Name).sk.sql"
			}
		}
	}
	catch
	{
		Write-Warning $_.Exception.Message
	}


}