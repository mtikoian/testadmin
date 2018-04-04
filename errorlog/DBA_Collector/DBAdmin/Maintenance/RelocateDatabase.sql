IF OBJECT_ID('tempdb..#RelocateDatabase') IS NULL
	EXEC ('CREATE PROCEDURE #RelocateDatabse AS BEGIN /* Placeholder */ END;');
GO

ALTER procedure #RelocateDatabase
@DBName SYSNAME
AS
BEGIN

	SET CONCAT_NULL_YIELDS_NULL OFF;

	DECLARE @OldPath VARCHAR(256);		SET @OldPath = 'C:\Program Files (x86)\Microsoft Office Servers\12.0\Data\MSSQL.4\MSSQL\DATA\';
	DECLARE @NewPath VARCHAR(256);		SET @NewPath = 'E:\OFFICESERVER\';
	DECLARE @DataPath VARCHAR(256),
			@NewDataPath VARCHAR(256),
			@DataName VARCHAR(256),
			@LogPath VARCHAR(256),
			@NewLogPath VARCHAR(256),
			@LogName VARCHAR(256);
	DECLARE @SQL NVARCHAR(MAX),
			@MoveCmd NVARCHAR(MAX);

	BEGIN TRY
		
		SELECT	@DataPath = physical_name,
				@DataName = name
		FROM	sys.master_files
		WHERE	database_id = DB_ID(@DBName)
				AND type = 0;
				
		SELECT	@LogPath = physical_name,
				@LogName = name
		FROM	sys.master_files
		WHERE	database_id = DB_ID(@DBName)
				AND type = 1;
		
		-- Calc new paths --
		SELECT  @NewDataPath = REPLACE(@DataPath,@OldPath,@NewPath),
				@NewLogPath = REPLACE(@LogPath,@OldPath,@NewPath);

		-- Take database offline --
		--EXEC('ALTER DATABASE ' + QUOTENAME(@DBName) + ' SET OFFLINE WITH ROLLBACK IMMEDIATE;');
		
		-- Move files --
		SELECT	@MoveCmd = 'xcopy ' + QUOTENAME(@DataPath,'''') + ' ' + QUOTENAME(@NewDataPath,'''');
		PRINT	@MoveCmd;
		SELECT	@MoveCmd = 'xcopy ' + QUOTENAME(@LogPath,'''') + ' ' + QUOTENAME(@NewLogPath,'''');
		PRINT	@MoveCmd;
		
		-- Generate ALTER statement --
		SELECT	@SQL = '
		ALTER DATABASE ' + QUOTENAME(@DBName) + ' MODIFY FILE
		(
			NAME = ''' + @DataName + ''',
			FILENAME = ''' + @DataPath + '''
		);
		ALTER DATABASE ' + QUOTENAME(@DBName) + ' MODIFY FILE
		(
			NAME = ''' + @LogName + ''',
			FILENAME = ''' + @LogPath + '''
		);';

		PRINT @SQL;
	END TRY
	BEGIN CATCH
	
		SELECT	ERROR_NUMBER() ErrNumber,
				ERROR_MESSAGE() ErrMessage;
	END CATCH
		
	SET CONCAT_NULL_YIELDS_NULL ON;

END
GO

--EXEC #RelocateDatabase @DBName = 'SharedServices1_DB_677e1d59-463e-45e5-b8af-d684807db188';