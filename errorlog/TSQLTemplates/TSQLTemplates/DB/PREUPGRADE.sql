/* 
   *******************************************************************************
    ENVIRONMENT:    SQL 2005/2008/2008R2

	NAME:           PREUPGRADE.SQL

    DESCRIPTION:    THIS SCRIPT IS TO HELP WITH UPGRADE SQL 2000/2005/2008/2008R2 DATABASES TO 
                    SQL 2008.  IT REPORTS syntax error that are not compatiable.
                    NOTIFIES YOU OF ANY POTENTIAL ISSUES THAT MAY OCCUR DURING
                    THE UPGRADE OR LIST ITEMS THAT ALSO NEEDS TO BE UPGRADED.  
                    BELOW ARE THE THINGS THAT IT REPORTS
                    
                        * IF INSTANCE IS DEFAULT
                        * COLLATION IS DIFFERENT
                        * NOT SP4
                        * LIST OF SP_CONFIGURE VALUES
                        * ANY CUSTOM EXTENDED PROCS
                        * ANY DATABASE THAT ARE USING FULL TEXT SEARCH
                        * ANY DATABASE SETUP FOR REPLICATION
                        * LIST OF ANY DTS PACKAGES ON SQL
                        * IF USING LOG SHIPPING
                        * ANY LINKED SERVERS 
                        * IF ANY STORED PROCEDURE SET FOR STARTUP
                        * DB OWNER IS NOT SA
                        * DB COMPATIBILITY IS NOT 80
                        * DB THAT DON'T HAVE AUTOGROWTH ON
                        * LIST OF DATABASES AND DATA & LOG LOCATION
                        * LIST OF SQL JOBS ON SQL 
                        
                    
    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------
    VBANDI        11/21/2011 1.0      INITIAL CREATION
   
   *******************************************************************************
   */
--SELECT srvname
--FROM sysservers
--WHERE srvname <> CAST(SERVERPROPERTY('MachineName') AS VARCHAR(128)) + CASE 
--		WHEN CAST(SERVERPROPERTY('InstanceName') AS VARCHAR(128)) IS NULL
--			THEN ''
--		ELSE '\' + CAST(SERVERPROPERTY('InstanceName') AS VARCHAR(128))
--		END



SET NOCOUNT ON;

DECLARE @sql VARCHAR(max)
DECLARE @Text VARCHAR(max)
DECLARE @ProcName VARCHAR(500);
DECLARE @T TABLE (
	ProcName VARCHAR(200)
	,sql VARCHAR(max)
	,ErrorMessage VARCHAR(4000)
	);
DECLARE @Beginobjcount INT;
DECLARE @Endobjcount INT;
DECLARE @Msg NVARCHAR(2048);

SELECT @Beginobjcount = (
		SELECT COUNT(1)
		FROM sys.all_objects a
		WHERE type IN (
				'TT' --TYPE_TABLE
				,'FN' --SQL_SCALAR_FUNCTION
				,'SN' --SYNONYM
				,'IF' --SQL_INLINE_TABLE_VALUED_FUNCTION
				,'V' --VIEW
				--  'IT'	--INTERNAL_TABLE
				,'P' --SQL_STORED_PROCEDURE
				--'X'		--EXTENDED_STORED_PROCEDURE
				,'TF' --SQL_TABLE_VALUED_FUNCTION
				,'TR' --SQL_TRIGGER
				) --
			AND NAME NOT LIKE 'dm_%'
			AND NAME NOT LIKE 'ORMask%'
			AND NAME NOT LIKE 'dt_%'
			AND NAME NOT LIKE 'sys_%'
			AND is_ms_shipped = 0
		);

BEGIN TRY
	SELECT @Msg = 'Beginning object count is ' + CAST(@Beginobjcount AS VARCHAR(20));

	DECLARE c CURSOR
	FOR
	SELECT NAME
		,DEFINITION
	FROM sys.all_objects a
	INNER JOIN sys.sql_modules ON a.object_id = sql_modules.object_id
	WHERE type IN (
			'p' --SQL_STORED_PROCEDURE
			,'tf'
			,'if'
			,'tr' --SQL_TRIGGER
			,'FN' --SQL_SCALAR_FUNCTION
			,'V' --VIEW
			)
		--'TT'	TYPE_TABLE
		--'FN'	SQL_SCALAR_FUNCTION
		--'SN'	SYNONYM
		--'IF'	SQL_INLINE_TABLE_VALUED_FUNCTION
		--'V' 	VIEW
		--'S' 	SYSTEM_TABLE
		--'AF'	AGGREGATE_FUNCTION
		--'IT'	INTERNAL_TABLE
		--'P' 	SQL_STORED_PROCEDURE
		--'X'	EXTENDED_STORED_PROCEDURE
		--'TF'	SQL_TABLE_VALUED_FUNCTION
		--'TR'	SQL_TRIGGER
		AND NAME NOT LIKE 'dm_%'
		AND NAME NOT LIKE 'ORMask%'
		AND NAME NOT LIKE 'dt_%'
		AND NAME NOT LIKE 'sys_%'
		AND is_ms_shipped = 0;
		--AND NAME LIKE '%createtest%';
	OPEN C;

	FETCH NEXT
	FROM c
	INTO @ProcName
		,@Text;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--SET @text = REPLACE(@text, convert(VARCHAR(max), N'CREATE TRI'), convert(VARCHAR(max), N'ALTER TRI')) -- change proc name
		SET @text = REPLACE(@text, @ProcName, @ProcName + 'CreateTest');
			-- change proc name

		--SELECT @text
		BEGIN TRY
			EXEC (@text);-- try to create the proc

			INSERT INTO @T
			VALUES (
				@ProcName
				,@text
				,ERROR_MESSAGE()
				);-- record procs that could be created

			PRINT @ProcName + 'Created ';
		END TRY

		BEGIN CATCH
			INSERT INTO @T
			VALUES (
				@ProcName
				,@text
				,ERROR_MESSAGE()
				);-- record procs that couldn't be created
		END CATCH;

		IF EXISTS (
				SELECT *
				FROM sys.all_objects
				WHERE NAME LIKE '%' + @procname + 'createtest'
					AND type = 'p'
				)
		BEGIN
			SET @sql = 'drop procedure ' + (
					SELECT OBJECT_SCHEMA_NAME(object_id) + '.' + NAME
					FROM sys.all_objects
					WHERE NAME LIKE '%' + @procname + 'createtest'
						AND type = 'p'
					);

			EXEC (@sql);

			PRINT @procname + 'dropped';
			--SELECT @sql
			PRINT '';
		END;

		IF EXISTS (
				SELECT 1
				FROM sys.all_objects
				WHERE NAME LIKE '%' + @procname + 'createtest'
					AND type IN (
						'if'
						,'tf'
						,'fn'
						)
				)
		BEGIN
			SET @sql = 'drop function ' + (
					SELECT OBJECT_SCHEMA_NAME(object_id) + '.' + NAME
					FROM sys.all_objects
					WHERE NAME LIKE '%' + @procname + 'createtest'
						AND type IN (
							'if'
							,'tf'
							,'fn'
							)
					);

			EXEC (@sql);

			PRINT @procname + 'dropped';
			PRINT '';
		END;

		IF EXISTS (
				SELECT 1
				FROM sys.all_objects
				WHERE NAME LIKE '%' + @procname + 'createtest'
					AND type = 'tr'
				)
		BEGIN
			SET @sql = 'drop trigger ' + (
					SELECT OBJECT_SCHEMA_NAME(object_id) + '.' + NAME
					FROM sys.all_objects
					WHERE NAME LIKE '%' + @procname + 'createtest'
						AND type IN ('tr')
					);

			EXEC (@sql);

			--SELECT @sql
			PRINT @procname + 'dropped';
			PRINT '';
		END;

		IF EXISTS (
				SELECT 1
				FROM sys.all_objects
				WHERE NAME LIKE '%' + @procname + 'createtest'
					AND type = 'v'
				)
		BEGIN
			SET @sql = 'drop view ' + (
					SELECT OBJECT_SCHEMA_NAME(object_id) + '.' + NAME
					FROM sys.all_objects
					WHERE NAME LIKE '%' + @procname + 'createtest'
						AND type IN ('v')
					);

			EXEC (@sql);

			--SELECT @sql
			PRINT @procname + 'dropped';
			PRINT '';
		END;

		FETCH NEXT
		FROM c
		INTO @ProcName
			,@Text;
	END;

	CLOSE c;

	DEALLOCATE c;

	SELECT ProcName
		,sql
		,ErrorMessage
	FROM @T
	WHERE errormessage IS NOT NULL
	ORDER BY procname;

	SELECT @Endobjcount = (
			SELECT COUNT(1)
			FROM sys.all_objects a
			WHERE type IN (
					'TT' --TYPE_TABLE
					,'FN' --SQL_SCALAR_FUNCTION
					,'SN' --SYNONYM
					,'IF' --SQL_INLINE_TABLE_VALUED_FUNCTION
					,'V' --VIEW
					--  'IT'	--INTERNAL_TABLE
					,'P' --SQL_STORED_PROCEDURE
					--'X'		--EXTENDED_STORED_PROCEDURE
					,'TF' --SQL_TABLE_VALUED_FUNCTION
					,'TR' --SQL_TRIGGER
					) --
				AND NAME NOT LIKE 'dm_%'
				AND NAME NOT LIKE 'ORMask%'
				AND NAME NOT LIKE 'dt_%'
				AND NAME NOT LIKE 'sys_%'
				AND is_ms_shipped = 0
			);
			select @Beginobjcount, @Endobjcount
	SELECT @Msg = @Msg + ' and object count' + CAST(@Endobjcount AS VARCHAR(20)) + 'is not matchinng';

	IF @Beginobjcount - @Endobjcount <> 0
	BEGIN
		RAISERROR (
				@Msg
				,16
				,1
				);
	END;
END TRY

BEGIN CATCH
	-- Roll back any active or uncommittable transactions
	-- XACT_STATE = 0 means there is no transaction and a commit or rollback operation would generate an error.
	-- XACT_STATE = -1 The transaction is in an uncommittable state
	IF XACT_STATE() <> 0
	BEGIN
		ROLLBACK TRAN;
	END;

	DECLARE @ERRMSG NVARCHAR(2100);
	DECLARE @ERRSEV INT;
	DECLARE @ERRSTATE INT;

	SET @ERRMSG = ERROR_MESSAGE();
	SET @ERRSEV = ERROR_SEVERITY();
	SET @ERRSTATE = ERROR_STATE();

	RAISERROR (
			@ERRMSG
			,@ERRSEV
			,@ERRSTATE
			);
END CATCH;
