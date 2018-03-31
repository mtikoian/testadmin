$filter = "bi_*"
$groups = Get-ADGroup -Filter {name -like $filter}

foreach ($group in $groups)
{
    $groupName = $group.Name
    $members = Get-ADGroupMember $groupName
    foreach ($member in $members)
    {
        $output = $groupName + "," + $member.name
        Write-Host $output
    }
}