#showstrings.ps1
#Demonstrates different ways to construct query strings

# Construct the string one line at a time
$q = "SELECT TOP 25 [ContactID]"
$q = $q + "      ,[FirstName]"
$q = $q + "      ,[LastName]"
$q = $q + "      ,[EmailAddress]"
$q = $q + "      ,[Phone]"
$q = $q + "  FROM [AdventureWorks].[Person].[Contact]"
$q

# Now use a 'here' string
$q = @"
SELECT TOP 25 [ContactID]
      ,[FirstName]
      ,[LastName]
      ,[EmailAddress]
      ,[Phone]
  FROM [AdventureWorks].[Person].[Contact]
"@
$q
