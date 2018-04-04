function sqlHeartBeat
{
	<#
	.SYNOPSIS
	Script takes a list of inputted server names and attempts to connect to them
	.DESCRIPTION
	This script is used as a heartbeat check for SQL Server
	.NOTES
	Author: Josh Feierman
	#>

	param 
	(
		$ServerName = "",
		$AlertEMail = $(throw "You must specify an e-mail address for alerting.")
	)
}