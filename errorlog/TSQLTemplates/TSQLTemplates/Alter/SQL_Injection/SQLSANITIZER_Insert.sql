USE [NetikIP]
GO
DECLARE @Error INT;

BEGIN TRY  

BEGIN TRANSACTION 

------Insert statement

		--SQL Injection
		DELETE FROM SEI_NTK_SQL_SANITIZER_CHAR

		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('--          ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('\           ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             (';           ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('/*          ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('*/          ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('XP_         ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('SELECT      ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('DROP        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('TRUNCATE    ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('INSERT      ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('DELETE      ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('AUX         ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('CLOCK$      ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('COM1        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('COM2        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('COM3        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('COM4        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('COM5        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('COM6        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('COM7        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('COM8        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('CON         ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('CONFIG$     ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('LPT1        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('LPT2        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('LPT3        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('LPT4        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('LPT5        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('LPT6        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('LPT7        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('LPT8        ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('PRN         ')
		INSERT INTO [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]([INJCHAR])    VALUES             ('SELECT*     ')



IF @@TRANCOUNT>0
COMMIT TRANSACTION;

PRINT 'Table Insertions have finished.'
END TRY

BEGIN CATCH 
SET @Error = ERROR_NUMBER() ;
RAISERROR('Error encoutered in Tables ', 16,1) ;
SELECT ERROR_NUMBER() AS ErrorNumber,
	   ERROR_MESSAGE() AS ErrorMessage;   
END CATCH

IF @Error <> 0
BEGIN
IF @@TRANCOUNT <> 0 ROLLBACK TRANSACTION ;
END ;
