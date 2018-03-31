$q = @"
SELECT TOP 25 [ContactID]
      ,[FirstName]
      ,[LastName]
      ,[EmailAddress]
      ,[Phone]
  FROM [AdventureWorks].[Person].[Contact]
"@

$val = invoke-sqlcmd -ServerInstance 'SQLTBWS\INST01' -Database 'AdventureWorks' -Query $q
$val | Select FirstName, EmailAddress
