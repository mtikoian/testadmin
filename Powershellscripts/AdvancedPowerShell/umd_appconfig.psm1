$configfile = Join-Path -Path $PSScriptRoot -ChildPath "psappconfig.txt" 

# Note: ConvertFrom-StringData converts the strings into a hash table. 
$configdata = Get-Content -Path $configfile | ConvertFrom-StringData 

function Get-UdfConfiguation ([string] $configkey)
{
   Return $configdata.$configkey
}

# Import-Module umd_appconfig
# Get-UdfConfiguation "EDWServer"

