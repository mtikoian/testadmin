CREATE DATABASE MSSQLTips
GO

USE MSSQLTips; 
GO 

/* Setup for Testing */    
CREATE SYMMETRIC KEY TestSymmKey 
WITH ALGORITHM = AES_256 
ENCRYPTION BY PASSWORD = 'TestP4ssw0rd!'; 
GO 

CREATE ASYMMETRIC KEY TestAsymmKey 
WITH ALGORITHM = RSA_512 
ENCRYPTION BY PASSWORD = 'TestP4ssw0rd!'; 
GO 

CREATE TABLE dbo.SymmKeyTest ( 
  EncryptedCol VARBINARY(256) 
); 
GO 

CREATE TABLE dbo.AsymmKeyTest ( 
  EncryptedCol VARBINARY(256) 
); 
GO

/* Symmetric Key Test */
/* Symmetric Key Time Difference (ms): 276 */ 
DECLARE @StartTime DATETIME; 
DECLARE @EndTime DATETIME; 
DECLARE @KeyGUID UNIQUEIDENTIFIER; 

SET @KeyGUID = KEY_GUID('TestSymmKey'); 
SET @StartTime = GETDATE(); 

OPEN SYMMETRIC KEY TestSymmKey DECRYPTION BY PASSWORD = 'TestP4ssw0rd!'; 

INSERT INTO dbo.SymmKeyTest (EncryptedCol) 
SELECT TOP 5000 ENCRYPTBYKEY(@KeyGUID, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz') 
FROM master.sys.columns c1 CROSS JOIN master.sys.columns c2; 

SELECT TOP 5000 CONVERT(VARCHAR(52), DECRYPTBYKEY(EncryptedCol)) 
FROM dbo.SymmKeyTest; 

SET @EndTime = GETDATE(); 

PRINT 'Symmetric Key Time Difference (ms): ' + CONVERT(CHAR, DATEDIFF(ms, @StartTime, @EndTime)); 
GO

/* Asymmetric Key Test */
/* Asymmetric Key Time Difference (ms): 1853 */ 
DECLARE @StartTime DATETIME; 
DECLARE @EndTime DATETIME; 
DECLARE @AsymID INT; 

SET @AsymID = ASYMKEY_ID('TestAsymmKey'); 
SET @StartTime = GETDATE(); 

INSERT INTO dbo.AsymmKeyTest (EncryptedCol) 
SELECT TOP 5000 ENCRYPTBYASYMKEY(@AsymID, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz') 
FROM master.sys.columns c1 CROSS JOIN master.sys.columns c2; 

SELECT TOP 5000 CONVERT(CHAR(52), DECRYPTBYASYMKEY(@AsymID, EncryptedCol, N'TestP4ssw0rd!')) 
FROM dbo.AsymmKeyTest; 

SET @EndTime = GETDATE(); 

PRINT 'Asymmetric Key Time Difference (ms): ' + CONVERT(VARCHAR, DATEDIFF(ms, @StartTime, @EndTime)); 
GO