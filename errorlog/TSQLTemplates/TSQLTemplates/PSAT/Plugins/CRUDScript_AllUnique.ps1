foreach ($table in $smoTables)
{
    $indexes = $table.Indexes | Where-Object {($_.IsUnique -eq $true) -and ($_.IndexKeyType -ne [Microsoft.SqlServer.Management.Smo.IndexKeyType]::DriPrimaryKey)}
    if ($indexes -eq $null)
    {
        Write-Warning "Table '$($table.Name)' does not have any unique indexes and will be skipped."
        continue
    }

    foreach ($index in $indexes)
    {
    
        $params = [String]::Join(",`r`n",(Get-SQLIndexColumns -Index $index | Out-ParameterDef -Prefix "pi_"))
        $docparams = [String]::Join("`t`t`tI`r`n",(Get-SQLIndexColumns -Index $index | Out-ParameterDef -Prefix "pi_"))
        $colList = [String]::Join(",`r`n",(Get-SQLTableColumns -Table $table | Out-ColumnList | Add-PreText -PrependText "    "))
        $colDocList = [String]::Join("`t$($table.Name)`r`n",(Get-SQLTableColumns -Table $table | Out-ColumnDoc))
        $whereClause = [String]::Join(" AND `r`n",(Get-SqlIndexColumns -Index $index | Out-WhereClause -prefix "pi_" | Add-PreText -PrependText "    "))
        $procName = "Get" + (Format-ColumnNameForProcedure -Name $table.Name) + "By" + [String]::Join("_",(Get-SQLIndexColumns -Index $index | Format-ColumnNameForProcedure))

        #region Get
		$procName = "Get" + (Format-ColumnNameForProcedure -Name $table.Name) + "By" + [String]::Join("_",(Get-SQLIndexColumns -Index $index | Format-ColumnNameForProcedure))
		$fileContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($table.Schema).$procname.sp.sql

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     INFORMATION_SCHEMA.ROUTINES
   WHERE    ROUTINE_NAME = '$procname' 
            AND ROUTINE_SCHEMA = '$($table.Schema)')
   DROP PROCEDURE $($table.Schema).$procname;
GO
/********************************************************************************
Name : IEaccounts_SD
Author : Patrick W. O'Brien - Specification as of 10/11/2010 version 1.4
Description : ECR Extract for Accounts

`$Author: `$
`$Date: `$
`$Rev: `$
`$URL: `$
===============================================================================
Parameters :
Name           |I/O|     Description
--------------------------------------------------------------------------------
$docparams

ResultSet:
----------------------------------------------------------------------------
$colDocList

--------------------------------------------------------------------------------

Revisions :
--------------------------------------------------------------------------------
Ini| Date       | Description
--------------------------------------------------------------------------------
CREATE PROCEDURE $($table.Schema).$procname
$params
AS
SELECT
$colList
FROM
    $($table.Schema).$($table.Name)
WHERE
$whereClause
GO

"@
        $outputObj = New-Object PSObject -Property @{
            FileName = "Procedures\$($table.Schema).$procname.sp.sql"
            FileContent = $fileContent
        }

        Write-Output $outputObj
		
		#endregion
		#region Update
		$procName = "Update" + (Format-ColumnNameForProcedure -Name $table.Name) + "By" + [String]::Join("_",(Get-SQLIndexColumns -Index $index | Format-ColumnNameForProcedure))
    $setClause = [String]::Join(",`r`n",(Get-SqlTableColumns -Table $table | Out-WhereClause -prefix "pi_" | Add-PreText -PrependText "    "))
    
		$fileContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($table.Schema).$procname.sp.sql

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     INFORMATION_SCHEMA.ROUTINES
   WHERE    ROUTINE_NAME = '$procname' 
            AND ROUTINE_SCHEMA = '$($table.Schema)')
   DROP PROCEDURE $($table.Schema).$procname;
GO
/********************************************************************************
Name : $procname
Author : Patrick W. O'Brien - Specification as of 10/11/2010 version 1.4
Description : ECR Extract for Accounts

`$Author: `$
`$Date: `$
`$Rev: `$
`$URL: `$
===============================================================================
Parameters :
Name           |I/O|     Description
--------------------------------------------------------------------------------
$docparams

--------------------------------------------------------------------------------

Revisions :
--------------------------------------------------------------------------------
Ini| Date       | Description
--------------------------------------------------------------------------------
CREATE PROCEDURE $($table.Schema).$procname
$params
AS
UPDATE
  $($table.Name)
SET
$setClause
WHERE
$whereClause
GO

"@
        $outputObj = New-Object PSObject -Property @{
            FileName = "Procedures\$($table.Schema).$procname.sp.sql"
            FileContent = $fileContent
        }

        Write-Output $outputObj
		    
        #endregion
        #region Delete
		$procName = "Delete" + (Format-ColumnNameForProcedure -Name $table.Name) + "By" + [String]::Join("_",(Get-SQLIndexColumns -Index $index | Format-ColumnNameForProcedure))
    
		$fileContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($table.Schema).$procname.sp.sql

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     INFORMATION_SCHEMA.ROUTINES
   WHERE    ROUTINE_NAME = '$procname' 
            AND ROUTINE_SCHEMA = '$($table.Schema)')
   DROP PROCEDURE $($table.Schema).$procname;
GO
/********************************************************************************
Name : $procname
Author : Patrick W. O'Brien - Specification as of 10/11/2010 version 1.4
Description : ECR Extract for Accounts

`$Author: `$
`$Date: `$
`$Rev: `$
`$URL: `$
===============================================================================
Parameters :
Name           |I/O|     Description
--------------------------------------------------------------------------------
$docparams

--------------------------------------------------------------------------------

Revisions :
--------------------------------------------------------------------------------
Ini| Date       | Description
--------------------------------------------------------------------------------
CREATE PROCEDURE $($table.Schema).$procname
$params
AS
DELETE
FROM    
  $($table.Name)
WHERE
$whereClause
GO

"@
        $outputObj = New-Object PSObject -Property @{
            FileName = "Procedures\$($table.Schema).$procname.sp.sql"
            FileContent = $fileContent
        }

        Write-Output $outputObj
    }
    
}