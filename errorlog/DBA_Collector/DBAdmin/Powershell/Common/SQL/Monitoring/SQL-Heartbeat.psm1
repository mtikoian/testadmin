function Get-sqlHeartBeat
{
	<#
	.SYNOPSIS
	Script takes a list of inputted server names and attempts to connect to them
	.DESCRIPTION
	This function is used as a heartbeat check for SQL Server instances. It accepts either
	a piped input of server names or a single server name.
	.PARAMETER ServerName
	The server name to perform the heartbeat check against.
	.PARAMETER AlertEMail
	The e-mail address to send the notification to in case of failure.
	.PARAMETER SMTPServer
	The SMTP server to use for sending alert e-mails
	.NOTES
	Author: Josh Feierman
	#>

	param 
	(
		$ServerName = "",
		$AlertEMail = $(throw "You must specify an e-mail address for alerting."),
		$SMTPServer = $(throw "You must specify a SMTP server to use for alert e-mails.")
	)

	#Check if there was piped input provided.
	if ($input -ne $null)
	{
		foreach ($Server in $input)
		{
			$Server;
		}
	}
}	