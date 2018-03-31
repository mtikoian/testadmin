/* 
	Create database for use in the Demo.
*/
use master
GO

CREATE DATABASE [TESTTDE] ON  PRIMARY 
( 
	NAME = N'TESTTDE', 
	FILENAME = N'C:\sqldata\S1\TESTTDE.mdf' , 
	SIZE = 10240KB , 
	FILEGROWTH = 10240KB 
)
 LOG ON 
( 
	NAME = N'TESTTDE_log', 
	FILENAME = N'C:\sqldata\S1\TESTTDE_log.ldf' , 
	SIZE = 10240KB , 
	FILEGROWTH = 10240KB 
)
GO

USE TESTTDE
GO

CREATE TABLE dbo.TestTable (
	Field1 int,
	Field2 varchar(25),
	Field3 decimal(18,2)
)
GO
INSERT INTO dbo.TestTable 
VALUES (1, '1 Value', 18.2),
(2, '2 Value', 19.2),
(3, '3 Value', 20.2),
(4, '4 Value', 21.2)
GO

SELECT *
FROM dbo.TestTable
GO

/*
	Let's backup the database and view it in an editor
*/
BACKUP DATABASE TESTTDE TO DISK='C:\SQLBACKUP\TESTTDE_unenc.bak' WITH INIT

/*
	Let's create the DB MASTER key for use in TDE
*/

USE master;
GO
CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'INSTANCE1_Use1Strong2Password3Here!';
go

/* 
	Now see if it is there...
	Look for ##MS_DatabaseMasterKey##
*/
SELECT	
	name,
	key_length,
	algorithm_desc,
	create_date,
	modify_date
FROM sys.symmetric_keys

/*
	Now let's create a Certificate that will be used
	in the Encryption hierarchy.
*/

CREATE CERTIFICATE MyServerCert 
WITH SUBJECT = 'My DEK Certificate'
go

/*
	You get warned if you do not backup the Certificate

BACKUP CERTIFICATE MyServerCert
TO FILE='C:\SQLBACKUP\MyserverCert.cer'
WITH PRIVATE KEY (FILE='C:\SQLBACKUP\MyServerCert.pvk',
	ENCRYPTION BY PASSWORD='My1Secure2Password!')	

*/

/*
	Check to see that it exists.
	Also remember that the expiry_date is NOT checked for expiration of the cert.
	If you don't specify EXPIRY_DATE then it will
	expire 1 year from the date you created it.
*/
select 
	name,
	pvt_key_encryption_type_desc,
	[subject],
	[start_date],
	[expiry_date],
	pvt_key_last_backup_date
from sys.certificates
where name not like '##%'

/*
	You must be in the database that you are creating
	the Key for.  Then Create the Key for Encryption
	You can choose the following Encryption algorithms.
		AES_128, AES_192, AES_256, TRIPLE_DES_3KEY
*/
USE TESTTDE
GO

CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE MyServerCert
GO

/*
	You get warned if you do not backup the Certificate
*/
USE master
GO

BACKUP CERTIFICATE MyServerCert
TO FILE='C:\SQLBACKUP\MyserverCert.cer'
WITH PRIVATE KEY (FILE='C:\SQLBACKUP\MyServerCert.pvk',
	ENCRYPTION BY PASSWORD='My1Secure2Password!')	
GO

/* Check the certificate Private Key Backup */
select 
	name,
	pvt_key_encryption_type_desc,
	[subject],
	[start_date],
	[expiry_date],
	pvt_key_last_backup_date
from sys.certificates
where name not like '##%'

/*
	Now Set the Encryption Mode on
*/
ALTER DATABASE TESTTDE
SET ENCRYPTION ON
GO

USE master; 

GO
/* 
	Checking the status of all databases
	Notice that there are 2 databases that are encrypted
	after setting encryption on.  TempDB and the database
	itself.
	0 = No database encryption key present, no encryption
	1 = Unencrypted
	2 = Encryption in progress
	3 = Encrypted
	4 = Key change in progress
	5 = Decryption in progress
	6 = Protection change in progress 
		(The certificate or asymmetric key that is encrypting 
		the database encryption key is being changed.)

*/
SELECT 
    db.name,
    db.is_encrypted,
    dm.encryption_state,
    dm.percent_complete,
    dm.key_algorithm,
    dm.key_length
FROM 
    sys.databases db
    LEFT OUTER JOIN sys.dm_database_encryption_keys dm
        ON db.database_id = dm.database_id;

/*
	Interesting to note:
	sys.database has a CREATE_DATE column that is according
	to your local time zone (of the server).
	sys.dm_database_encryption_keys has a column CREATE_DATE
	that is GMT instead of Local.
*/
SELECT 
	db.name, 
	db.create_date
FROM sys.databases db
WHERE name = 'TESTTDE'
GO

SELECT 
	db.name,
	db.create_date as db_created,
	dm.create_date as enc_created
FROM
	sys.databases db
	LEFT OUTER JOIN sys.dm_database_encryption_keys dm
		ON db.database_id = dm.database_id
WHERE db.name = 'TESTTDE'
GO


USE master; 
GO

BACKUP DATABASE TESTTDE 
TO DISK='C:\SQLBACKUP\TESTTDE_enc.bak' WITH INIT
GO

/*
** Switch to INSTANCE2
*/
select @@VERSION

/*
** Why do you get an error on this statement?
** You have not brought the Encryption Hierarchy back in sync.
*/
RESTORE FILELISTONLY FROM DISK='C:\SQLBACKUP\TESTTDE_enc.bak'
GO

USE master;
GO
CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'INSTANCE2_Use1Strong2Password3Here!';
GO
CREATE CERTIFICATE MyServerCert
    FROM FILE = 'C:\SQLBACKUP\MyServerCert.cer' 
    WITH PRIVATE KEY (FILE = 'C:\SQLBACKUP\MyServerCert.pvk', 
    DECRYPTION BY PASSWORD = 'My1Secure2Password!');
GO

select 
	name,
	pvt_key_encryption_type_desc,
	[subject],
	[start_date],
	[expiry_date],
	pvt_key_last_backup_date
from sys.certificates
where name not like '##%'

GO
/*
No need to create the Database Encryption Key as it is in 
the database already, but needed the Certificate to 
allow unencryption
*/

RESTORE FILELISTONLY FROM DISK='C:\SQLBACKUP\TESTTDE_enc.bak'
GO

RESTORE DATABASE TESTTDE 
FROM DISK='C:\SQLBACKUP\TESTTDE_enc.bak'
WITH MOVE 'TESTTDE' TO 'C:\sqldata\S2\TESTTDE.mdf',
	MOVE 'TESTTDE_Log' TO 'C:\sqldata\S2\TESTTDE_log.ldf'
GO

USE TESTTDE
GO
SELECT *
FROM dbo.TestTable
GO

use master
drop master key

/*
	Just one little warning... Prior to SQL Server 2008 R2 SP2 you 
	could drop the Certificate even if it was protecting the DEK
	Protect your certificates
*/
USE master
GO
DROP CERTIFICATE MyServerCert
GO
/*
	We can still see the data in the database
*/

USE TESTTDE
GO
SELECT *
FROM dbo.TestTable
GO
