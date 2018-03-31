--Implemented on \DEV4

--Create in master first so user dbs can share the same cert
USE master;
GO

--We're assigning server-level permissions which require a certificate in master
CREATE CERTIFICATE cert_WindowsGroupLookup ENCRYPTION BY PASSWORD = '!38bjiIm6S847fNzAEHIvWN@9' WITH SUBJECT = 'Windows Group Lookup Access Certirficate', EXPIRY_DATE = '99991231'
GO
--SELECT * FROM sys.certificates


--BOL:  Logins created from certificates or asymmetric keys are used only for code signing.
--They cannot be used to connect to SQL Server. You can create a login from a certificate or asymmetric key only when the certificate or asymmetric key already exists in master. 
CREATE LOGIN WindowsGroupLookup FROM CERTIFICATE cert_WindowsGroupLookup;
GO
ALTER SERVER ROLE sysadmin ADD MEMBER WindowsGroupLookup
GO


--For use with each user db that needs this
BACKUP CERTIFICATE cert_WindowsGroupLookup
TO FILE = 'C:\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\Backup\certs\cert_WindowsGroupLookup.cer' WITH PRIVATE KEY (
FILE = 'C:\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\Backup\certs\pkey_WindowsGroupLookup.pvk',
ENCRYPTION BY PASSWORD = '!38bjiIm6S847fNzAEHIvWN@9',
DECRYPTION BY PASSWORD = '!38bjiIm6S847fNzAEHIvWN@9');
GO





USE SS654;
GO


--BOL:  You can create a certificate in the master database to grant server-level permissions.
CREATE CERTIFICATE cert_WindowsGroupLookup
FROM FILE = 'C:\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\Backup\certs\cert_WindowsGroupLookup.cer'
WITH PRIVATE KEY (
	FILE = 'C:\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\Backup\certs\pkey_WindowsGroupLookup.pvk',
	ENCRYPTION BY PASSWORD = '!38bjiIm6S847fNzAEHIvWN@9',
	DECRYPTION BY PASSWORD = '!38bjiIm6S847fNzAEHIvWN@9');
GO


IF EXISTS(SELECT * FROM sys.objects AS so WHERE so.[name] = 'procGetADGroups' AND so.[type] = 'P' AND SCHEMA_NAME(so.[schema_id]) = 'dbo')
	DROP PROCEDURE dbo.procGetADGroups
GO
CREATE PROCEDURE dbo.procGetADGroups
	(
		@LoginName nvarchar(128)
	)
AS

SET NOCOUNT ON;

BEGIN TRY
	--EXECUTE AS used to change login search context
	DECLARE @strSQL nvarchar(MAX) = N'USE [master]; EXECUTE AS LOGIN = ' + QUOTENAME(@LoginName, '''') + ';';
	EXEC sp_executesql @strSQL;

	SELECT
		tkn.name AS GroupMemberOf
	FROM sys.login_token AS tkn
	WHERE
	  tkn.[type] = 'WINDOWS GROUP';

END TRY
BEGIN CATCH

	THROW;

END CATCH;
GO

--Digitally sign the procedure using the certificate.
--This will give anyone that runs the stored procedure permission only while they are running the procedure,
--AND only if the procedure has not been modified in any way. Any change to the procedure will cause the digital signature to be dropped.
ADD SIGNATURE TO dbo.procGetADGroups BY CERTIFICATE cert_WindowsGroupLookup WITH PASSWORD = '!38bjiIm6S847fNzAEHIvWN@9';
GO