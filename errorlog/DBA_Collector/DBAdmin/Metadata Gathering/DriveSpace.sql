DECLARE @CmdResult TABLE (Result VARCHAR(250));
DECLARE @RC INT;

IF OBJECT_ID('tempdb..#DriveSpace') IS NOT NULL
	DROP TABLE #DriveSpace;
	
CREATE TABLE #DriveSpace (Drive VARCHAR(520), CapacityMB DECIMAL(14,2), SpaceFreeMB DECIMAL(14,2), PercentFree DECIMAL(5,2));

insert @CmdResult
exec @RC = xp_cmdshell 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "if (test-path \"C:\\Windows\\Temp\\Drives.txt\") {remove-item \"C:\\Windows\\Temp\\Drives.txt\";}'
IF @RC <> 0
BEGIN
	SELECT * FROM @CmdResult;
	RETURN
END

insert @CmdResult
exec @RC = xp_cmdshell 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command "Get-WmiObject -Class Win32_Volume | where {$_.DriveType -eq 3 } | select @{label=\"Drive\";expression={$_.Label}},@{label=\"CapacityMB\";expression={$_.Capacity/1MB}},@{label=\"SpaceFreeMB\";expression={$_.FreeSpace/1MB}},@{label=\"PercentFree\";expression={($_.FreeSpace/$_.Capacity)*100}} | ForEach-Object { $line = $_.Drive + \"`t\" + $_.CapacityMB + \"`t\" + $_.SpaceFreeMB + \"`t\" + $_.PercentFree + \"`n\"; Add-Content -Path \"C:\\Windows\\Temp\\Drives.txt\" $line;}'
IF @RC <> 0
BEGIN
	SELECT * FROM @CmdResult;
	RETURN
END

--SELECT * FROM @CmdResult;

BULK INSERT [TEMPDB].[dbo].[#DriveSpace] FROM 'C:\Windows\Temp\drives.txt'

SELECT * FROM #DriveSpace