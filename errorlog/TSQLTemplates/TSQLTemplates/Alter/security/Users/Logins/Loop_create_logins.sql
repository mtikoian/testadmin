USE MASTER
GO

SET NOCOUNT ON;

--Declarations
DECLARE @Login_Name SYSNAME;
DECLARE @Login_Password SYSNAME;
DECLARE @Login_Type CHAR(8);
DECLARE @Login_Default_DB SYSNAME;
DECLARE @SQL NVARCHAR(400);
DECLARE @RC INT;
DECLARE @Error_Message NVARCHAR(4000);
DECLARE @Error_Severity TINYINT;
DECLARE @CompatLevel TINYINT;
DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INTEGER;
DECLARE @INFORMATION NVARCHAR(4000);
DECLARE @ErrorState INTEGER;
DECLARE @DATABASENAME NVARCHAR(255);
DECLARE @table_login TABLE (
	id INT identity(1, 1)
	,loginname VARCHAR(250)
	);

--Intializations
SET @ErrorMessage = '';
SET @ErrorSeverity = 0;
SET @ErrorState = 0;
SET @INFORMATION = '';
SET @Login_Default_DB = 'DBA';       --Change Database name
INSERT INTO @table_login			 -- Insert Login Names
VALUES ('sei-domain-1\rmckenna')		    

INSERT INTO @table_login
VALUES ('sei-domain-1\averguldi')

DECLARE GET_logins CURSOR READ_ONLY
FOR
SELECT loginname
FROM @table_login

OPEN GET_logins

FETCH NEXT
FROM GET_logins
INTO @Login_Name

WHILE (@@fetch_status = 0)
BEGIN --begin while loop
	BEGIN TRY
		SET @Login_Type = 'Windows';
		SET @Login_Password = 'null';
		

		-- Begin Validation logic --
		-- Check if a password was provided for a SQL login
		IF (
				@Login_Type = 'SQL'
				AND ISNULL(@Login_Password, '') = ''
				)
		BEGIN
			RAISERROR (
					'You must provide a password for a SQL Server login type.'
					,16
					,1
					);

			RETURN;
		END

		-- Check if the database specified for the default is valid
		IF NOT EXISTS (
				SELECT 1
				FROM sys.databases
				WHERE NAME = @Login_Default_DB
				)
		BEGIN
			RAISERROR (
					'Database name provided for default (%s) does not exist.'
					,16
					,1
					,@Login_Default_DB
					);

			RETURN;
		END

		-- following is changed for the strataweb requirements. commenting the below line. @vkotian 4/2/2012
		--USE @Login_Default_DB;
		-- Check if the login exists
		IF NOT EXISTS (
				SELECT 1
				FROM sys.server_principals
				WHERE NAME = @Login_Name
				)
		BEGIN
			RAISERROR (
					'Login %s does not exist on the server, will create it.'
					,10
					,1
					,@Login_Name
					)
			WITH NOWAIT;

			-- Begin branching for Windows versus SQL login
			IF @Login_Type = 'SQL'
			BEGIN
				SET @SQL = 'CREATE LOGIN ' + QUOTENAME(@Login_Name) + ' WITH PASSWORD = ' + QUOTENAME(@Login_Password, '''') + ', CHECK_EXPIRATION = OFF' + ', DEFAULT_DATABASE = ' + QUOTENAME(@Login_Default_DB)

				EXEC @RC = sp_executesql @SQL;

				SELECT @sql

				IF @RC <> 0
				BEGIN
					RAISERROR (
							'Error creating server level login. Aborting.'
							,16
							,1
							);
				END
			END
			ELSE
			BEGIN
				SET @SQL = 'CREATE LOGIN ' + QUOTENAME(@Login_Name) + ' FROM WINDOWS ' + 'WITH DEFAULT_DATABASE = ' + QUOTENAME(@Login_Default_DB);

				EXEC @RC = sp_executesql @SQL;

				IF @RC <> 0
				BEGIN
					RAISERROR (
							'Error creating server level login. Aborting.'
							,16
							,1
							);
				END
			END

			RAISERROR (
					'Login %s created successfully.'
					,10
					,1
					,@Login_Name
					)
			WITH NOWAIT;
		END
		ELSE
			RAISERROR (
					'Login %s already exists, nothing to do.'
					,10
					,1
					,@Login_Name
					)
			WITH NOWAIT;

		FETCH NEXT
		FROM GET_logins
		INTO @Login_Name;
	END TRY

	BEGIN CATCH
		SELECT @ErrorMessage = 'Failed to create logins for database ' + SPACE(2) + CAST(ERROR_NUMBER() AS NVARCHAR) + SPACE(2) + ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE();

		SELECT @ErrorMessage

		RAISERROR (
				@ErrorMessage
				,-- Message text.
				@ErrorSeverity
				,-- Severity.
				@ErrorState -- State.
				);
			--	FETCH NEXT
			--	FROM GET_logins
			--	INTO @Login_Name;
	END CATCH;
		--CLOSE GET_logins;
		--DEALLOCATE GET_logins;
END
GO


