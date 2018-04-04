﻿<#
  .SYNOPSIS
  This function is used for finding all AD objects with a given SPN.
  
  .DESCRIPTION
  Finds all AD objects that have a given SPN. Wildcard search patterns are
  acceptable.
  
  .PARAMETER SearchRoot
  The root path at which to search. Should be in the form of "LDAP://xyz".
  
  .PARAMETER SPNName
  The name of the SPN to search for. Can include the "*" wildcard character.
  
  .PARAMETER Credential
  The alternate credentials to use when searching the domain. Can be either a string
  (user name) or a PSCredential object.

  .EXAMPLE
  Search-SPN -SearchRoot "LDAP://mydomain.com" -SPNName "MSSQLSvc*" -Credential josh@mydomain.com
  
  Will find all objects with a SPN starting with "MSSQLSvc" (used for 
  SQL Server services) within the "mydomain.com" AD domain. Will prompt the user
  for the password of the "josh@mydomain.com" account and use that to authenticate
  against the domain.
  
  .NOTES
  Author - Josh Feierman
  Date - 5/22/2012
  
#>
function Search-SPN
{
  [Cmdletbinding()]
  param
  (
    [parameter(mandatory=$true)]
    [string]$SearchRoot,
    [parameter(mandatory=$true)]
    [string]$SPNName,
    [parameter(mandatory=$false)]
    $Credential
  )
  
  try
  {
    if ($Credential)
    {
    
      switch ($Credential.GetType().FullName)
      {
        "System.Management.Automation.Credential" {}
        "System.String" { $Credential = Get-Credential -Credential $Credential }
        default { throw "Invalid type given for parameter Credential." }
      }
      $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($Credential.Password)
      $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
      [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
      
      $de = New-Object system.DirectoryServices.DirectoryEntry $SearchRoot,$Credential.UserName,$Password
    }
    else
    {
      $de = New-Object system.DirectoryServices.DirectoryEntry $SearchRoot
    }
    
    $ds = New-Object System.DirectoryServices.DirectorySearcher $de
    
    $ds.Filter = "(servicePrincipalName=$SPNName)"
    $ds.FindAll()
  }
  catch
  {
    if ($_.Exception.Message -like "*The server is not operational*")
    {
      Write-Warning "Server for search root '$SearchRoot' could not be contacted. Exiting."
    }
    else
    {
      Write-Warning "Error occurred while executing."
      Write-Warning $_.Exception.Message
    }
    Write-Verbose $_.Exception
  }
  
}