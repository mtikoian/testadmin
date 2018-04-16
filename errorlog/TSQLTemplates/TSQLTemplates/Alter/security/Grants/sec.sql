--WARNING! ERRORS ENCOUNTERED DURING SQL PARSING!
-- =============================================================================
--
-- Table Batch
-- December  2, 2011     -  2:41:45PM
--
-- =============================================================================
-- VCS
-- ---
-- $Author: $
-- $Date: $
-- $Revision: $
-- =============================================================================
PRINT 'Adding file DBApp_Processing.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Script for database roles *****'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

BEGIN TRY
	PRINT 'Dropping roles and members'
	PRINT ''
	PRINT 'for role dbApp_Processor'

	DECLARE @RoleName SYSNAME

	SET @RoleName = N'dbApp_Processor'

	IF EXISTS (
			SELECT *
			FROM sys.database_principals
			WHERE NAME = @RoleName
				AND type = 'R'
			)
	BEGIN
		PRINT '    Dropping members'

		DECLARE @RoleMemberName SYSNAME

		DECLARE Member_Cursor CURSOR
		FOR
		SELECT [name]
		FROM sys.database_principals
		WHERE principal_id IN (
				SELECT member_principal_id
				FROM sys.database_role_members
				WHERE role_principal_id IN (
						SELECT principal_id
						FROM sys.database_principals
						WHERE [Name] = @RoleName
							AND type = 'R'
						)
				)

		OPEN Member_Cursor;

		FETCH NEXT
		FROM Member_Cursor
		INTO @RoleMemberName

		WHILE @@fetch_status = 0
		BEGIN
			EXEC sp_droprolemember @rolename = @RoleName
				,@membername = @RoleMemberName

			PRINT '    Member ' + @RoleMemberName + ' has been dropped'

			FETCH NEXT
			FROM Member_Cursor
			INTO @RoleMemberName
		END;

		CLOSE Member_Cursor;

		DEALLOCATE Member_Cursor;
	END

	IF EXISTS (
			SELECT *
			FROM sys.database_principals
			WHERE NAME = N'dbApp_Processor'
				AND type = 'R'
			)
		DROP ROLE dbApp_Processor

	PRINT 'Role dbApp_Processor has been dropped'
	PRINT ''

	-- ================================================================================================
	--declare @RoleName sysname
	SET @RoleName = N'dbApp_Operator'

	PRINT 'for role dbApp_Operator'

	IF EXISTS (
			SELECT *
			FROM sys.database_principals
			WHERE NAME = @RoleName
				AND type = 'R'
			)
	BEGIN
		PRINT '    Dropping members'

		--declare @RoleMemberName sysname
		DECLARE Member_Cursor CURSOR
		FOR
		SELECT [name]
		FROM sys.database_principals
		WHERE principal_id IN (
				SELECT member_principal_id
				FROM sys.database_role_members
				WHERE role_principal_id IN (
						SELECT principal_id
						FROM sys.database_principals
						WHERE [name] = @RoleName
							AND type = 'R'
						)
				)

		OPEN Member_Cursor;

		FETCH NEXT
		FROM Member_Cursor
		INTO @RoleMemberName

		WHILE @@fetch_status = 0
		BEGIN
			EXEC sp_droprolemember @rolename = @RoleName
				,@membername = @RoleMemberName

			PRINT '    Member ' + @RoleMemberName + ' has been dropped'

			FETCH NEXT
			FROM Member_Cursor
			INTO @RoleMemberName
		END;

		CLOSE Member_Cursor;

		DEALLOCATE Member_Cursor;
	END

	IF EXISTS (
			SELECT *
			FROM sys.database_principals
			WHERE NAME = N'dbApp_Operator'
				AND type = 'R'
			)
		DROP ROLE dbApp_Operator

	PRINT 'Role dbApp_Operator has been dropped'
	PRINT ''
	-- ================================================================================================
	--declare @RoleName sysname
	PRINT 'for role dbApp_Admin'

	SET @RoleName = N'dbApp_Admin'

	IF EXISTS (
			SELECT *
			FROM sys.database_principals
			WHERE NAME = @RoleName
				AND type = 'R'
			)
	BEGIN
		PRINT '    Dropping members'

		--declare @RoleMemberName sysname
		DECLARE Member_Cursor CURSOR
		FOR
		SELECT [name]
		FROM sys.database_principals
		WHERE principal_id IN (
				SELECT member_principal_id
				FROM sys.database_role_members
				WHERE role_principal_id IN (
						SELECT principal_id
						FROM sys.database_principals
						WHERE [name] = @RoleName
							AND type = 'R'
						)
				)

		OPEN Member_Cursor;

		FETCH NEXT
		FROM Member_Cursor
		INTO @RoleMemberName

		WHILE @@fetch_status = 0
		BEGIN
			EXEC sp_droprolemember @rolename = @RoleName
				,@membername = @RoleMemberName

			PRINT '    Member ' + @RoleMemberName + ' has been dropped'

			FETCH NEXT
			FROM Member_Cursor
			INTO @RoleMemberName
		END;

		CLOSE Member_Cursor;

		DEALLOCATE Member_Cursor;
	END

	IF EXISTS (
			SELECT *
			FROM sys.database_principals
			WHERE NAME = N'dbApp_Admin'
				AND type = 'R'
			)
		DROP ROLE [dbApp_Admin]

	PRINT 'Role dbApp_Operator has been dropped'
	PRINT ''
	-- ================================================================================================
	--declare @RoleName sysname
	PRINT 'for role dbApp_Reporter'

	SET @RoleName = N'dbApp_Reporter'

	IF EXISTS (
			SELECT *
			FROM sys.database_principals
			WHERE NAME = @RoleName
				AND type = 'R'
			)
	BEGIN
		PRINT '    Dropping members'

		--declare @RoleMemberName sysname
		DECLARE Member_Cursor CURSOR
		FOR
		SELECT [name]
		FROM sys.database_principals
		WHERE principal_id IN (
				SELECT member_principal_id
				FROM sys.database_role_members
				WHERE role_principal_id IN (
						SELECT principal_id
						FROM sys.database_principals
						WHERE [name] = @RoleName
							AND type = 'R'
						)
				)

		OPEN Member_Cursor;

		FETCH NEXT
		FROM Member_Cursor
		INTO @RoleMemberName

		WHILE @@fetch_status = 0
		BEGIN
			EXEC sp_droprolemember @rolename = @RoleName
				,@membername = @RoleMemberName

			PRINT '    Member ' + @RoleMemberName + ' has been dropped'

			FETCH NEXT
			FROM Member_Cursor
			INTO @RoleMemberName
		END;

		CLOSE Member_Cursor;

		DEALLOCATE Member_Cursor;
	END

	IF EXISTS (
			SELECT *
			FROM sys.database_principals
			WHERE NAME = N'dbApp_Reporter'
				AND type = 'R'
			)
		DROP ROLE [dbApp_Reporter]

	PRINT 'Role dbApp_Operator has been dropped'
	PRINT ''
	PRINT 'Recreating roles'

	-- ================================================================================================
	CREATE ROLE dbApp_Processor AUTHORIZATION dbo;

	PRINT '		role dbApp_Processor added'

	-- ================================================================================================
	CREATE ROLE dbApp_Admin AUTHORIZATION dbo;

	PRINT '		role dbApp_Admin added'

	-- ================================================================================================
	CREATE ROLE dbApp_Reporter AUTHORIZATION dbo;

	PRINT '		role dbApp_Reporter added'

	-- ================================================================================================
	CREATE ROLE dbApp_Operator AUTHORIZATION dbo;

	PRINT '	role dbApp_Operator added'
	PRINT ''
	PRINT '		Adding members'

	-- ================================================================================================
	EXEC sp_addrolemember @Rolename = 'dbApp_Processor'
		,@MemberName = 'dbApp_Admin';

	PRINT 'Added dbApp_Admin to role dbApp_Processor'

	-- ================================================================================================
	EXEC sp_addrolemember @Rolename = 'dbApp_Operator'
		,@MemberName = 'dbApp_Admin';

	PRINT 'Added dbApp_Admin to role dbApp_Operator'

	-- ================================================================================================
	EXEC sp_addrolemember @Rolename = 'dbApp_Reporter'
		,@MemberName = 'dbApp_Admin';

	PRINT 'Added dbApp_Admin to role dbApp_Reporter'
		-- ================================================================================================
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMEssage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of role processing *****'
PRINT '------------------------------------------------------------'
PRINT ''
-- =============================================================================
PRINT 'Adding file Schema_DBApp.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Script for schema dbApp *****'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

IF EXISTS (
		SELECT *
		FROM sys.schemas
		WHERE NAME = N'dbApp'
		)
	DROP SCHEMA dbApp;
GO

CREATE SCHEMA dbApp AUTHORIZATION db_owner;
GO

-- =============================================================================
PRINT 'Adding file RuleCondition.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Script for UDT dbApp.RuleCondition *****'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

IF EXISTS (
		SELECT *
		FROM sys.types st
		INNER JOIN sys.schemas ss ON st.schema_id = ss.schema_id
		WHERE st.NAME = N'RuleCondition'
			AND ss.NAME = N'dbApp'
		)
	DROP type dbApp.RuleCondition;
GO

CREATE type dbApp.RuleCondition AS TABLE (
	RuleConditionId INT identity(1, 1) NOT NULL PRIMARY KEY CLUSTERED
	,ConditionName VARCHAR(50) NOT NULL UNIQUE NONCLUSTERED
	,ConditionValue VARCHAR(50) NOT NULL
	);
GO

-- =============================================================================
PRINT 'Adding file Numbers.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Table script for dbApp.Numbers *****'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

BEGIN TRY
	-- Pre-reqs
	-- --------------------------------------------------------
	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Numbers'
			)
	BEGIN
		PRINT 'Table dbApp.Numbers exists, dropping'

		DROP TABLE dbApp.Numbers

		PRINT 'Table dbApp.Numbers dropped'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Numbers does not exist, skipping drop'
	END;

	PRINT 'Creating table dbApp.Numbers';

	CREATE TABLE dbApp.Numbers (Number INT PRIMARY KEY CLUSTERED)

	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Numbers'
			)
	BEGIN
		PRINT 'Table dbApp.Numbers was created successfully';
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Numbers was not created'
	END;
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of table script *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO

-- =============================================================================
PRINT 'Adding file Expression_Type.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Table script for dbApp.Expression_Type *****'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

BEGIN TRY
	-- Pre-reqs
	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_Expression_ref_Expression_Type')
				AND parent_object_id = object_id(N'dbApp.Expression')
			)
		ALTER TABLE dbApp.Expression

	DROP CONSTRAINT FK_Expression_ref_Expression_Type

	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Expression_Type'
			)
	BEGIN
		PRINT 'Table dbApp.Expression_Type exists, dropping'

		DROP TABLE dbApp.Expression_Type

		PRINT 'Table dbApp.Expression_Type dropped'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Expression_Type does not exist, skipping drop'
	END

	PRINT 'Creating table dbApp.Expression_Type'

	-- end 1
	CREATE TABLE dbApp.Expression_Type (
		Expression_Type_Id INT identity(1, 1) NOT NULL
		,Expression_Type_Cd VARCHAR(50) NOT NULL
		,Expression_Type_Display_Cd VARCHAR(100) NOT NULL
		,Expression_Type_Dsc VARCHAR(400) NULL
		,Active_Fl TINYINT NOT NULL
		,Sort_Ord TINYINT NULL
		,Add_Dtm DATETIMEOFFSET NOT NULL
		,Add_Usr NVARCHAR(128) NOT NULL
		,Update_Dtm DATETIMEOFFSET NOT NULL
		,Update_Usr NVARCHAR(128) NOT NULL
		)

	PRINT 'Adding constraints to table dbApp.Expression_Type'

	--end 2
	ALTER TABLE dbApp.Expression_Type ADD CONSTRAINT PK_Expression_Type PRIMARY KEY CLUSTERED (Expression_Type_Id)
		,CONSTRAINT AK_Expression_Set_Type_Cd UNIQUE (Expression_Type_Cd)
		,CONSTRAINT AK_Expression_Type_Display_Cd UNIQUE NONCLUSTERED (Expression_Type_Display_Cd)
		,CONSTRAINT DF_Expression_Type_Active_Fl DEFAULT(1)
	FOR Active_Fl
		,CONSTRAINT DF_Expression_Type_Sort_Ord DEFAULT(0)
	FOR Sort_Ord
		,CONSTRAINT DF_Expression_Type_Add_Dtm DEFAULT(sysdatetime())
	FOR Add_Dtm
		,CONSTRAINT DF_Expression_Type_Add_Usr DEFAULT(system_user)
	FOR Add_Usr
		,CONSTRAINT DF_Expression_Type_Update_Dtm DEFAULT(sysdatetime())
	FOR Update_Dtm
		,CONSTRAINT DF_Expression_Type_Update_Usr DEFAULT(system_user)
	FOR Update_Usr
		,CONSTRAINT CK_Expression_Type_Active_Fl CHECK (
			Active_Fl IN (
				0
				,1
				)
			)

	PRINT 'Adding description to extended properties for dbApp.Expression_Type'

	EXEC sys.sp_addextendedproperty @name = N'MS_Dsc'
		,@value = N'The set of allowed values that describe the nature of the expression.'
		,@level0type = N'SCHEMA'
		,@level0name = N'dbApp'
		,@level1type = N'TABLE'
		,@level1name = N'Expression_Type'

	PRINT 'Granting permissions on table dbApp.Expression_Type'

	GRANT INSERT
		,UPDATE
		,DELETE
		,REFERENCES
		ON dbApp.Expression_Type
		TO DBApp_Admin

	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Expression_Type'
			)
	BEGIN
		PRINT 'Table dbApp.Expression_Type created successfully'
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Expression'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from dbAppExpression'

		ALTER TABLE dbApp.Expression
			WITH CHECK ADD CONSTRAINT FK_Expression_ref_Expression_Type FOREIGN KEY (Expression_Type_Id) REFERENCES dbApp.Expression_Type(Expression_Type_Id)

		ALTER TABLE dbApp.Expression CHECK CONSTRAINT FK_Expression_ref_Expression_Type
	END
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of table script *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO

-- =============================================================================
PRINT 'Adding file Operator_Type.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Table script for dbApp.BCP *****'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

BEGIN TRY
	-- Pre-reqs
	-- --------------------------------------------------------
	PRINT 'Dropping FK that refers to dbApp.Operator_Type'

	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_Operator_ref_Operator_Type')
				AND parent_object_id = object_id(N'dbApp.Operator')
			)
		ALTER TABLE dbApp.Operator

	DROP CONSTRAINT FK_Operator_ref_Operator_Type

	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Operator_Type'
			)
	BEGIN
		PRINT 'Table dbApp.Operator_Type exists, dropping'

		DROP TABLE dbApp.Operator_Type

		PRINT 'Table dbApp.Operator_Type dropped'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Operator_Type does not exist, skipping drop'
	END

	PRINT 'Creating table dbApp.Operator_Type'

	-- end 1
	CREATE TABLE dbApp.Operator_Type (
		Operator_Type_Id INT identity(1, 1) NOT NULL
		,Operator_Type_Cd VARCHAR(50) NOT NULL
		,Operator_Type_Display_Cd VARCHAR(100) NOT NULL
		,Operator_Type_Dsc VARCHAR(400) NOT NULL
		,Active_Fl TINYINT NOT NULL
		,Sort_Ord SMALLINT NOT NULL
		,Add_Dtm DATETIMEOFFSET NOT NULL
		,Add_Usr NVARCHAR(128) NOT NULL
		,Update_Dtm DATETIMEOFFSET NOT NULL
		,Update_Usr VARCHAR(50) NOT NULL
		)

	PRINT 'Adding constraints to table dbApp.Operator_Type'

	--end 2
	ALTER TABLE dbApp.Operator_Type ADD CONSTRAINT PK_t_Operator_Type PRIMARY KEY CLUSTERED (Operator_Type_Id)
		,CONSTRAINT AK_t_Operator_Type_Cd UNIQUE NONCLUSTERED (Operator_Type_Cd)
		,CONSTRAINT AK_t_Operator_Type_Operator_Type_Display_Cd UNIQUE NONCLUSTERED (Operator_Type_Display_Cd)
		,CONSTRAINT DF_Operator_Type_Active_Fl DEFAULT(1)
	FOR Active_Fl
		,CONSTRAINT DF_Operator_Type_Sort_Ord DEFAULT(0)
	FOR Sort_Ord
		,CONSTRAINT DF_Operator_Type_Add_Dtm DEFAULT(sysdatetimeoffset())
	FOR Add_Dtm
		,CONSTRAINT DF_Operator_Type_Add_Usr DEFAULT(system_user)
	FOR Add_Usr
		,CONSTRAINT DF_Operator_Type_Update_Dtm DEFAULT(sysdatetimeoffset())
	FOR Update_Dtm
		,CONSTRAINT DF_Operator_Type_Update_Usr DEFAULT(system_user)
	FOR Update_Usr
		,CONSTRAINT CK_Operator_Type_Active_Fl CHECK (
			Active_Fl IN (
				0
				,1
				)
			)

	PRINT 'Adding extended properties for table dbApp.Date_Range_Type';

	EXEC sys.sp_addextendedproperty @name = N'MS_Dsc'
		,@value = N'The set of allowed operator types for use in the rules tables.'
		,@level0type = N'SCHEMA'
		,@level0name = N'dbApp'
		,@level1type = N'TABLE'
		,@level1name = N'Operator_Type'

	PRINT 'Granting permissions on table dbApp.Operator_Type'

	GRANT INSERT
		,UPDATE
		,DELETE
		,REFERENCES
		ON dbApp.Operator_Type
		TO DBApp_Admin

	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Operator_Type'
			)
	BEGIN
		PRINT 'Table dbApp.Operator_Type created successfully'
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Operator'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from dbAppOperator'

		ALTER TABLE dbApp.Operator
			WITH CHECK ADD CONSTRAINT FK_Operator_ref_Operator_Type FOREIGN KEY (Operator_Type_Id) REFERENCES dbApp.Operator_Type(Operator_Type_Id)

		ALTER TABLE dbApp.Operator CHECK CONSTRAINT FK_Operator_ref_Operator_Type
	END
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of table script *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO

-- =============================================================================
PRINT 'Adding file Result_Name.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Table script for dbApp.Result_Nm *****'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

BEGIN TRY
	-- Pre-reqs
	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_Rule_set_Result_ref_Result_Name')
				AND parent_object_id = object_id(N'dbApp.Rule_set_Result')
			)
	BEGIN
		PRINT 'Dropping foreign key from Rule_Set_Result to dbApp.Result_Name'

		ALTER TABLE dbApp.Rule_Set_Result

		DROP CONSTRAINT FK_Rule_set_Result_ref_Result_Name
	END

	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_Rule_Result_ref_Result_Name')
				AND parent_object_id = object_id(N'dbApp.Rule_Result')
			)
	BEGIN
		PRINT 'Dropping foreign key from Rule_Result to dbApp.Result_Name'

		ALTER TABLE dbApp.Rule_Result

		DROP CONSTRAINT FK_Rule_Result_ref_Result_Name
	END

	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Result_Name'
			)
	BEGIN
		PRINT 'Table dbApp.Result_Name exists, dropping'

		DROP TABLE dbApp.Result_Name

		PRINT 'Table dbApp.Result_Name dropped'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Result_Name does not exist, skipping drop'
	END

	PRINT 'Creating table dbApp.Result_Name'

	-- end 1
	CREATE TABLE dbApp.Result_Name (
		Result_Nm_Id INT identity(1, 1) NOT NULL
		,Result_Nm VARCHAR(50) NOT NULL
		,Active_Fl TINYINT NOT NULL
		,Sort_Ord TINYINT NOT NULL
		,Add_Dtm DATETIMEOFFSET NOT NULL
		,Add_Usr NVARCHAR(128) NOT NULL
		,Update_Dtm DATETIMEOFFSET NULL
		,Update_Usr NVARCHAR(128) NULL
		);

	PRINT 'Adding constraints to table dbApp.Result_Name'

	--end 2
	ALTER TABLE dbApp.Result_Name ADD CONSTRAINT PK_Result_Name PRIMARY KEY CLUSTERED (Result_Nm_Id)
		,CONSTRAINT AK_Result_Name UNIQUE NONCLUSTERED (Result_Nm)
		,CONSTRAINT DF_Result_Name_Active_Fl DEFAULT(1)
	FOR Active_Fl
		,CONSTRAINT DF_Result_Name_Sort_Ord DEFAULT(0)
	FOR Sort_Ord
		,CONSTRAINT DF_Result_Name_Add_Dtm DEFAULT(sysdatetimeoffset())
	FOR Add_Dtm
		,CONSTRAINT DF_Result_Name_Add_Usr DEFAULT(system_user)
	FOR Add_Usr
		,CONSTRAINT DF_Result_Name_Update_Dtm DEFAULT(sysdatetimeoffset())
	FOR Update_Dtm
		,CONSTRAINT DF_Result_Name_Update_Usr DEFAULT(system_user)
	FOR Update_Usr
		,CONSTRAINT CK_Result_Name_Active_Fl CHECK (
			Active_Fl IN (
				0
				,1
				)
			)

	PRINT 'Granting permissions on table dbApp.Result_Name'

	GRANT INSERT
		,UPDATE
		,DELETE
		,REFERENCES
		ON dbApp.Result_Name
		TO DBApp_Admin

	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Result_Name'
			)
	BEGIN
		PRINT 'Table dbApp.Result_Name created successfully'
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Result_Set'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from Rule_Result_Set'

		ALTER TABLE dbApp.Rule_Result_Set
			WITH CHECK ADD CONSTRAINT FK_Rule_Result_Set_ref_Result_Name FOREIGN KEY (Result_Nm_Id) REFERENCES dbApp.Result_Name(Result_Nm_Id)

		ALTER TABLE dbApp.Rule_Result_Set CHECK CONSTRAINT FK_Rule_Result_Set_ref_Result_Name
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Result'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from Rule_Result'

		ALTER TABLE dbApp.Rule_Result
			WITH CHECK ADD CONSTRAINT FK_Rule_Result_ref_Result_Name FOREIGN KEY (Result_Nm_Id) REFERENCES dbApp.Result_Name(Result_Nm_Id)

		ALTER TABLE dbApp.Rule_Result CHECK CONSTRAINT FK_Rule_Result_ref_Result_Name
	END
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of table script *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO

-- =============================================================================
PRINT 'Adding file Operator.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Table script for dbApp.Operator *****'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

BEGIN TRY
	-- Pre-reqs
	-- --------------------------------------------------------
	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Operator'
			)
	BEGIN
		PRINT 'Table dbApp.Operator exists, dropping'

		DROP TABLE dbApp.Operator

		PRINT 'Table dbApp.Operator dropped'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Operator does not exist, skipping drop'
	END

	PRINT 'Creating table dbApp.Operator'

	-- end 1
	CREATE TABLE dbApp.Operator (
		Operator_Id INT identity(1, 1) NOT NULL
		,Operator_Cd VARCHAR(50) NOT NULL
		,Operator_Display_Cd VARCHAR(100) NOT NULL
		,Operator_Dsc VARCHAR(100) NOT NULL
		,Operator_Type_Id INT NOT NULL
		,-- FK
		isBinary TINYINT NOT NULL
		,Precedence TINYINT NOT NULL
		,Active_Fl TINYINT NOT NULL
		,Sort_Ord TINYINT NOT NULL
		,Add_Dtm DATETIMEOFFSET NOT NULL
		,Add_Usr NVARCHAR(128) NOT NULL
		,Update_Dtm DATETIMEOFFSET NOT NULL
		,Update_Usr NVARCHAR(128) NOT NULL
		);

	PRINT 'Adding constraints to table dbApp.Operator'

	--end 2
	ALTER TABLE dbApp.Operator ADD CONSTRAINT PK_t_Operator PRIMARY KEY CLUSTERED (Operator_Id)
		,CONSTRAINT AK_Operator_Cd UNIQUE NONCLUSTERED (Operator_Cd)
		,CONSTRAINT AK_Operator_Display_Cd UNIQUE NONCLUSTERED (Operator_Display_Cd)
		,CONSTRAINT DF_Operator_Active_Fl DEFAULT(1)
	FOR Active_Fl
		,CONSTRAINT DF_Operator_Sort_Ord DEFAULT(0)
	FOR Sort_Ord
		,CONSTRAINT DF_Operator_Add_Dtm DEFAULT(sysdatetimeoffset())
	FOR Add_Dtm
		,CONSTRAINT DF_Operator_Add_Usr DEFAULT(system_user)
	FOR Add_Usr
		,CONSTRAINT DF_Operator_Update_Dtm DEFAULT(sysdatetimeoffset())
	FOR Update_Dtm
		,CONSTRAINT DF_Operator_Update_Usr DEFAULT(system_user)
	FOR Update_Usr
		,CONSTRAINT DF_Operator_isBinary DEFAULT(0)
	FOR isBinary
		,CONSTRAINT DF_Operator_Precedence DEFAULT(10)
	FOR Precedence
		,CONSTRAINT CK_Operator_Active_Fl CHECK (
			Active_Fl IN (
				0
				,1
				)
			)

	-- ============================================================================
	PRINT 'Adding foreign key to dbApp.Operator_Type'

	ALTER TABLE dbApp.Operator
		WITH CHECK ADD CONSTRAINT FK_Operator_ref_Operator_Type FOREIGN KEY (Operator_Type_Id) REFERENCES dbApp.Operator_Type(Operator_Type_Id)

	ALTER TABLE dbApp.Operator CHECK CONSTRAINT FK_Operator_ref_Operator_Type

	-- ============================================================================
	-- ------------------------------------------------------------------------
	PRINT 'creating index IX_dbApp_Operator_Operator_Type_Id';

	CREATE INDEX IX_dbApp_Operator_Operator_Type_Id ON dbApp.Operator (Operator_Type_Id)
		WITH FILLFACTOR = 90;

	IF EXISTS (
			SELECT *
			FROM sys.indexes
			WHERE object_id = object_id(N'dbApp.Operator')
				AND NAME = N'IX_dbApp_Operator_Operator_Type_Id'
			)
	BEGIN
		PRINT 'Index created successfully';
	END

	-- ------------------------------------------------------------------------
	PRINT 'Granting permissions on table dbApp.Operator'

	GRANT INSERT
		,UPDATE
		,DELETE
		,REFERENCES
		ON dbApp.Operator
		TO DBApp_Admin

	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Operator'
			)
	BEGIN
		PRINT 'Table dbApp.Operator created successfully'
	END

	PRINT 'End of table script for dbApp.Operator' + (CHAR(13) + CHAR(10))
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of table script *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO

-- =============================================================================
PRINT 'Adding file Rule_Resolution_Type.sql'
-- =============================================================================
PRINT '------------------------------------------------------------';
PRINT '***** Table script for dbApp.Rule_Resolution_Type *****';
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '';

BEGIN TRY
	-- Preqs
	-- -------------------------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_dbRule_ref_Rule_Resolution_Type')
				AND parent_object_id = object_id(N'dbApp.dbRule')
			)
	BEGIN
		PRINT 'Dropping foreign key from dbRule to dbApp.Rule_Resolution_Type'

		ALTER TABLE dbApp.dbRule

		DROP CONSTRAINT FK_dbRule_ref_Rule_Resolution_Type
	END

	-- -------------------------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Resolution_Type'
			)
	BEGIN
		PRINT 'Table dbApp.Rule_Resolution_Type exists, dropping'

		DROP TABLE dbApp.Rule_Resolution_Type

		PRINT 'TabledbApp.Rule_Resolution_Type dropped'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Rule_Resolution_Type does not exist, skipping drop'
	END

	PRINT 'Creating table dbApp.Rule_Resolution_Type'

	CREATE TABLE dbApp.Rule_Resolution_Type (
		Rule_Resolution_Type_Id INT NOT NULL identity(1, 1)
		,Rule_Resolution_Type_Cd VARCHAR(50) NOT NULL
		,Rule_Resolution_Type_Display_Cd VARCHAR(100) NOT NULL
		,Rule_Resolution_Type_Dsc VARCHAR(400) NOT NULL
		,Active_Fl TINYINT NOT NULL
		,Sort_Ord TINYINT NOT NULL
		,Add_Usr SYSNAME NOT NULL
		,Add_Dtm DATETIMEOFFSET NOT NULL
		,Update_Usr SYSNAME NOT NULL
		,Update_Dtm DATETIMEOFFSET NOT NULL
		) ON Data;

	PRINT 'Adding constraints to table dbApp.Rule_Resolution_Type'

	ALTER TABLE dbApp.Rule_Resolution_Type ADD CONSTRAINT PK_Rule_Resolution_Type PRIMARY KEY CLUSTERED (Rule_Resolution_Type_Id) ON Data
		,CONSTRAINT AK_Rule_Resolution_Type_Code UNIQUE NONCLUSTERED (Rule_Resolution_Type_Cd) ON Data
		,CONSTRAINT AK_Rule_Resolution_Type_Display_Code UNIQUE NONCLUSTERED (Rule_Resolution_Type_Display_Cd) ON Data
		,CONSTRAINT DF_Rule_Resolution_Type_Description DEFAULT ''
	FOR Rule_Resolution_Type_Dsc
		,CONSTRAINT DF_Rule_Resolution_Type_Active_Indicator DEFAULT 1
	FOR Active_Fl
		,CONSTRAINT DF_Rule_Resolution_Type_Sort_Order DEFAULT 0
	FOR Sort_Ord
		,CONSTRAINT DF_Rule_Resolution_Type_Add_User DEFAULT system_user
	FOR Add_Usr
		,CONSTRAINT DF_Rule_Resolution_Type_Add_Datetime DEFAULT sysdatetimeoffset()
	FOR Add_Dtm
		,CONSTRAINT DF_Rule_Resolution_Type_Update_Usr DEFAULT system_user
	FOR Update_Usr
		,CONSTRAINT DF_Rule_Resolution_Type_Update_Dtm DEFAULT sysdatetimeoffset()
	FOR Update_Dtm
		,CONSTRAINT CK_Rule_Resolution_Type_Active_Indicator CHECK (
			Active_Fl IN (
				0
				,1
				)
			);

	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Resolution_Type'
			)
	BEGIN
		PRINT 'Table dbApp.Rule_Resolution_Type created successfully.'
	END
	ELSE
	BEGIN
		PRINT 'Table  dbApp.Rule_Resolution_Type does not exist, create failed.'
	END
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMEssage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT 'End of table script';
PRINT '--------------------------------------------------';
-- =============================================================================
PRINT 'Adding file DBRule.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Table script for dbApp.DBRule *****'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '';

BEGIN TRY
	-- Preqs
	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_DBApp_Configuration_ref_DBRule')
				AND parent_object_id = object_id(N'dbApp.DBApp_Configuration')
			)
	BEGIN
		PRINT 'Dropping FK contraint from DBApp_Configuration to DBRule'

		ALTER TABLE dbApp.DBApp_Configuration

		DROP CONSTRAINT FK_DBApp_Configuration_ref_DBRule
	END

	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_Rule_Answer_ref_DBRule')
				AND parent_object_id = object_id(N'dbApp.Rule_Answer')
			)
	BEGIN
		PRINT 'Dropping FK contraint from Rule_Answer to DBRule'

		ALTER TABLE dbApp.Rule_Answer

		DROP CONSTRAINT FK_Rule_Answer_ref_DBRule
	END

	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_Rule_Set_Detail_ref_DBRule')
				AND parent_object_id = object_id(N'dbApp.Rule_Set_Detail')
			)
	BEGIN
		PRINT 'Dropping FK contraint from Rule_Set_Detail to DBRule'

		ALTER TABLE dbApp.Rule_Set_Detail

		DROP CONSTRAINT FK_Rule_Set_Detail_ref_DBRule
	END

	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_DBApp_ref_DBRule')
				AND parent_object_id = object_id(N'dbApp.DBApp')
			)
	BEGIN
		PRINT 'Dropping FK contraint from DBApp to DBRule'

		ALTER TABLE dbApp.DBApp

		DROP CONSTRAINT FK_DBApp_ref_DBRule
	END

	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_Process_Set_ref_DBRule')
				AND parent_object_id = object_id(N'dbApp.Process_Set')
			)
	BEGIN
		PRINT 'Dropping FK contraint from Process_Set to DBRule'

		ALTER TABLE dbApp.Process_Set

		DROP CONSTRAINT FK_Process_Set_ref_DBRule
	END

	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_Process_Set_Detail_ref_DBRule')
				AND parent_object_id = object_id(N'dbApp.Process_Set_Detail')
			)
	BEGIN
		PRINT 'Dropping FK contraint from Process_Set_Detail to DBRule'

		ALTER TABLE dbApp.Process_Set_Detail

		DROP CONSTRAINT FK_Process_Set_Detail_ref_DBRule
	END

	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_Process_ref_DBRule')
				AND parent_object_id = object_id(N'dbApp.Process')
			)
	BEGIN
		PRINT 'Dropping FK contraint from Process to DBRule'

		ALTER TABLE dbApp.Process

		DROP CONSTRAINT FK_Process_ref_DBRule
	END

	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'DBRule'
			)
	BEGIN
		PRINT 'Table dbApp.DBRule exists, dropping'

		DROP TABLE dbApp.DBRule

		PRINT 'Table dbApp.DBRule dropped'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.DBRule does not exist, skipping drop'
	END

	PRINT 'Creating table dbApp.DBRule'

	-- end 1
	CREATE TABLE dbApp.DBRule (
		DBRule_Id INT identity(1, 1) NOT NULL
		,Rule_Nm VARCHAR(100) NOT NULL
		,Ordinal_Value DECIMAL(9, 4) NOT NULL
		,Active_Fl TINYINT NOT NULL
		,Rule_Resolution_Type_Id INT NOT NULL
		,Add_Dtm DATETIMEOFFSET NOT NULL
		,Add_Usr NVARCHAR(128) NOT NULL
		,Update_Dtm DATETIMEOFFSET NULL
		,Update_Usr NVARCHAR(128) NULL
		)

	PRINT 'Adding constraints to table dbApp.DBRule'

	--end 2
	ALTER TABLE dbApp.DBRule ADD CONSTRAINT PK_DBRule PRIMARY KEY CLUSTERED (DBRule_Id)
		,CONSTRAINT AK_DBRule_Rule_Nm UNIQUE NONCLUSTERED (Rule_Nm)
		,CONSTRAINT DF_DBRule_Ordinal_Value DEFAULT(0)
	FOR Ordinal_Value
		,CONSTRAINT DF_DBRule_Active_Fl DEFAULT(1)
	FOR Active_Fl
		,CONSTRAINT DF_DBRule_Add_Dtm DEFAULT(sysdatetimeoffset())
	FOR Add_Dtm
		,CONSTRAINT DF_DBRule_Add_Usr DEFAULT(system_user)
	FOR Add_Usr
		,CONSTRAINT DF_DBRule_Update_Dtm DEFAULT(sysdatetimeoffset())
	FOR Update_Dtm
		,CONSTRAINT DF_DBRule_Update_Usr DEFAULT(system_user)
	FOR Update_Usr
		,CONSTRAINT CK_DBRule_Active_Fl CHECK (
			Active_Fl IN (
				0
				,1
				)
			)

	-- -------------------------------------------------------------------------
	PRINT 'Adding foreign key from DBRule to dbApp.Rule_Resolution_Type'

	ALTER TABLE dbApp.DBRule
		WITH CHECK ADD CONSTRAINT FK_DBRule_ref_Rule_Resolution_Type FOREIGN KEY (Rule_Resolution_Type_Id) REFERENCES dbApp.Rule_Resolution_Type(Rule_Resolution_Type_Id)

	ALTER TABLE dbApp.DBRule CHECK CONSTRAINT FK_DBRule_ref_Rule_Resolution_Type

	-- -------------------------------------------------------------------------
	PRINT 'Granting permissions on table dbApp.DBRule'

	GRANT INSERT
		,UPDATE
		,DELETE
		,REFERENCES
		,SELECT
		ON dbApp.DBRule
		TO DBApp_Admin

	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'DBRule'
			)
	BEGIN
		PRINT 'Table dbApp.DBRule created successfully'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.DBRule does not exist, create failed'
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'DBApp_Configuration'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from DBApp_Configuration'

		ALTER TABLE dbApp.DBApp_Configuration
			WITH CHECK ADD CONSTRAINT FK_DBApp_Configuration_ref_DBRule FOREIGN KEY (DBRule_Id) REFERENCES dbApp.DBRule(DBRule_Id)

		ALTER TABLE dbApp.DBApp_Configuration CHECK CONSTRAINT FK_DBApp_Configuration_ref_DBRule
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Answer'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from Rule_Answer'

		ALTER TABLE dbApp.Rule_Answer
			WITH CHECK ADD CONSTRAINT FK_Rule_Answer_ref_DBRule FOREIGN KEY (DBRule_Id) REFERENCES dbApp.DBRule(DBRule_Id)

		ALTER TABLE dbApp.Rule_Answer CHECK CONSTRAINT FK_Rule_Answer_ref_DBRule
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Result'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from Rule_Result'

		ALTER TABLE dbApp.Rule_Result
			WITH CHECK ADD CONSTRAINT FK_Rule_Result_ref_DBRule FOREIGN KEY (DBRule_Id) REFERENCES DbApp.DBRule(DBRule_Id)

		ALTER TABLE dbApp.Rule_Result CHECK CONSTRAINT FK_Rule_Result_ref_DBRule
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Set_Detail'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from Rule_Set_Detail'

		ALTER TABLE dbApp.Rule_Set_Detail
			WITH CHECK ADD CONSTRAINT FK_Rule_Set_Detail_ref_DBRule FOREIGN KEY (DBRule_Id) REFERENCES dbApp.DBRule(DBRule_Id)

		ALTER TABLE dbApp.Rule_Set_Detail CHECK CONSTRAINT FK_Rule_Set_Detail_ref_DBRule
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'DBApp'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from DBApp'

		ALTER TABLE dbApp.DBApp
			WITH CHECK ADD CONSTRAINT FK_DBApp_ref_DBRule FOREIGN KEY (DBRule_Id) REFERENCES dbApp.DBRule(DBRule_Id)

		ALTER TABLE dbApp.DBApp CHECK CONSTRAINT FK_DBApp_ref_DBRule
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Process_Set'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from Process_Set'

		ALTER TABLE dbApp.Process_Set
			WITH CHECK ADD CONSTRAINT FK_Process_Set_ref_DBRule FOREIGN KEY (DBRule_Id) REFERENCES dbApp.DBRule(DBRule_Id)

		ALTER TABLE dbApp.Process_Set CHECK CONSTRAINT FK_Process_Set_ref_DBRule
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Process_Set_Detail'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from Process_Set_Detail'

		ALTER TABLE dbApp.Process_Set_Detail
			WITH CHECK ADD CONSTRAINT FK_Process_Set_Detail_ref_DBRule FOREIGN KEY (DBRule_Id) REFERENCES dbApp.DBRule(DBRule_Id)

		ALTER TABLE dbApp.Process_Set_Detail CHECK CONSTRAINT FK_Process_Set_Detail_ref_DBRule
	END

	-- recreate the FKs that reference this table.
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Process'
			)
	BEGIN
		PRINT 'Adding a foreign key reference from Process'

		ALTER TABLE dbApp.Process
			WITH CHECK ADD CONSTRAINT FK_Process_ref_DBRule FOREIGN KEY (DBRule_Id) REFERENCES dbApp.DBRule(DBRule_Id)

		ALTER TABLE dbApp.Process CHECK CONSTRAINT FK_Process_ref_DBRule
	END
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of table script *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO

-- =============================================================================
PRINT 'Adding file Expression.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Table script for dbApp.Expression *****'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

BEGIN TRY
	-- Pre-reqs
	-- --------------------------------------------------------
	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Expression'
			)
	BEGIN
		PRINT 'Table dbApp.Expression exists, dropping'

		DROP TABLE dbApp.Expression

		PRINT 'Table dbApp.Expression dropped'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Expression does not exist, skipping drop'
	END

	PRINT 'Creating table dbApp.Expression'

	-- end 1
	CREATE TABLE dbApp.Expression (
		Expression_Id INT identity(1, 1) NOT NULL
		,Expression_Cd VARCHAR(128) NOT NULL
		,Expression_Dsc VARCHAR(400) NULL
		,isCode_Fl TINYINT NOT NULL
		,isProc_Fl TINYINT NOT NULL
		,Expression_Type_Id INT NOT NULL
		,-- FK
		Rule_Cd VARCHAR(6000) NOT NULL
		,Param_Ct TINYINT NOT NULL
		,Response_Fl TINYINT NOT NULL
		,Return_Tp VARCHAR(30) NOT NULL
		,Param VARCHAR(1000) NOT NULL
		,Short_Circut_Fl TINYINT NOT NULL
		,Active_Fl TINYINT NOT NULL
		,Add_Usr NVARCHAR(128) NOT NULL
		,Add_Dtm DATETIMEOFFSET NOT NULL
		,Update_Usr NVARCHAR(128) NOT NULL
		,Update_Dtm DATETIMEOFFSET NOT NULL
		)

	PRINT 'Adding constraints to table dbApp.Expression'

	--end 2
	ALTER TABLE dbApp.Expression ADD CONSTRAINT PK_t_Expression PRIMARY KEY CLUSTERED (Expression_Id)
		,CONSTRAINT AK_Expression_Cd UNIQUE NONCLUSTERED (Expression_Cd)
		,CONSTRAINT DF_Expression_Active_Fl DEFAULT(1)
	FOR Active_Fl
		,CONSTRAINT DF_Expression_Add_Dtm DEFAULT(sysdatetimeoffset())
	FOR Add_Dtm
		,CONSTRAINT DF_Expression_Add_Usr DEFAULT(system_user)
	FOR Add_Usr
		,CONSTRAINT DF_Expression_Update_Dtm DEFAULT(sysdatetimeoffset())
	FOR Update_Dtm
		,CONSTRAINT DF_Expression_Update_Usr DEFAULT(system_user)
	FOR Update_Usr
		,CONSTRAINT DF_Expression_Response_Fl DEFAULT(1)
	FOR Response_Fl
		,CONSTRAINT DF_Expression_Param_Ct DEFAULT(1)
	FOR Param_Ct
		,CONSTRAINT DF_Expression_Return_Type DEFAULT('none')
	FOR Return_Tp
		,CONSTRAINT DF_Expression_Param DEFAULT('none')
	FOR Param
		,CONSTRAINT DF_Expression_Short_Circut_Fl DEFAULT(1)
	FOR Short_Circut_Fl
		,CONSTRAINT CK_Expression_isCode_Fl CHECK (
			isCode_Fl IN (
				0
				,1
				,2
				)
			)
		,CONSTRAINT CK_Expression_isProc_Fl CHECK (
			isProc_Fl IN (
				0
				,1
				)
			)
		,CONSTRAINT CK_Expression_Response_Fl CHECK (
			Response_Fl IN (
				0
				,1
				)
			)
		,CONSTRAINT CK_Expression_Short_Circut_Fl CHECK (
			Short_Circut_Fl IN (
				0
				,1
				)
			)
		,CONSTRAINT CK_Expression_Active_Fl CHECK (
			Active_Fl IN (
				0
				,1
				)
			)

	-- ============================================================================
	PRINT 'Adding foreign key to dbApp.Expression_Type'

	ALTER TABLE dbApp.Expression
		WITH CHECK ADD CONSTRAINT FK_Expression_ref_Expression_Type FOREIGN KEY (Expression_Type_Id) REFERENCES dbApp.Expression_Type(Expression_Type_Id)

	ALTER TABLE dbApp.Expression CHECK CONSTRAINT FK_Expression_ref_Expression_Type

	-- ============================================================================
	-- ------------------------------------------------------------------------
	PRINT 'creating index IX_dbApp_Expression_Expression_Type_Id';

	CREATE INDEX IX_dbApp_Expression_Expression_Type_Id ON dbApp.Expression (Expression_Type_Id)
		WITH FILLFACTOR = 90;

	IF EXISTS (
			SELECT *
			FROM sys.indexes
			WHERE object_id = object_id(N'dbApp.Expression')
				AND NAME = N'IX_dbApp_Expression_Expression_Type_Id'
			)
	BEGIN
		PRINT 'Index created successfully';
	END

	-- ------------------------------------------------------------------------
	PRINT 'Granting permissions on table dbApp.Expression'

	GRANT INSERT
		,UPDATE
		,DELETE
		,REFERENCES
		ON dbApp.Expression
		TO DBApp_Admin

	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Expression'
			)
	BEGIN
		PRINT 'Table dbApp.Expression created successfully'
	END
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of table script *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO

-- =============================================================================
PRINT 'Adding file Rule_Answer.sql'
-- =============================================================================
PRINT '------------------------------------------------------------';
PRINT '***** Table script for dbApp.Rule_Answer *****';
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '';

BEGIN TRY
	-- Pre-reqs
	-- -------------------------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_Rule_Answer_Condition_ref_Rule_Answer')
				AND parent_object_id = object_id(N'dbApp.Rule_Answer_Condition')
			)
	BEGIN
		PRINT 'Dropping foreign key from Rule_Answer_Condition to dbApp.Rule_Answer'

		ALTER TABLE dbApp.Rule_Answer_Condition

		DROP CONSTRAINT FK_Rule_Answer_Condition_ref_Rule_Answer
	END

	-- -------------------------------------------------------------------------
	-- -------------------------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM sys.foreign_keys
			WHERE object_id = object_id(N'dbApp.FK_Rule_Answer_Value_ref_Rule_Answer')
				AND parent_object_id = object_id(N'dbApp.Rule_Answer_Value')
			)
	BEGIN
		PRINT 'Dropping foreign key from Rule_Answer_Value to dbApp.Rule_Answer'

		ALTER TABLE dbApp.Rule_Answer_Value

		DROP CONSTRAINT FK_Rule_Answer_Value_ref_Rule_Answer
	END

	-- -------------------------------------------------------------------------
	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Answer'
			)
	BEGIN
		PRINT 'Table dbApp.Rule_Answer exists, dropping'

		DROP TABLE dbApp.Rule_Answer

		PRINT 'Table dbApp.Rule_Answer dropped'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Rule_Answer does not exist, skipping drop'
	END;

	PRINT 'Creating table dbApp.Rule_Answer';

	-- End 1
	CREATE TABLE dbApp.Rule_Answer (
		Rule_Answer_Id INT identity(1, 1) NOT NULL
		,DBRule_Id INT NOT NULL
		,Answer_Name VARCHAR(100) NOT NULL DEFAULT('')
		,Active_Fl TINYINT NOT NULL DEFAULT(1)
		,Priority_Val TINYINT NOT NULL DEFAULT(0)
		,Truth_Fl BIT NOT NULL
		,Add_Dtm DATETIMEOFFSET NOT NULL
		,Add_Usr SYSNAME NOT NULL
		);

	PRINT 'Adding constraints to table dbApp.Rule_Answer';

	-- End 2
	ALTER TABLE dbApp.Rule_Answer ADD CONSTRAINT PK_Rule_Answer PRIMARY KEY CLUSTERED (Rule_Answer_Id)
		,CONSTRAINT DF_Rule_Answer_Truth_Fl DEFAULT(1)
	FOR Truth_Fl
		,CONSTRAINT DF_Rule_Answer_Add_Dtm DEFAULT(sysdatetimeoffset())
	FOR Add_Dtm
		,CONSTRAINT DF_Rule_Answer_Add_Usr DEFAULT(system_user)
	FOR Add_Usr
		,CONSTRAINT CK_Rule_Answer_Active_Fl CHECK (
			Active_Fl IN (
				0
				,1
				)
			);

	-- ------------------------------------------------------------------------
	PRINT 'Adding foreign key to dbApp.DBRule'

	ALTER TABLE dbApp.Rule_Answer ADD CONSTRAINT FK_Rule_Answer_ref_Rule FOREIGN KEY (DBRule_Id) REFERENCES dbApp.DBRule (DBRule_Id)

	-- ------------------------------------------------------------------------
	PRINT 'Adding index to dbApp.DBRule'

	CREATE INDEX IX_Rule_Answer_Rule_Id ON dbApp.Rule_Answer (DBRule_Id)
		WITH FILLFACTOR = 90;

	PRINT 'Index added';
	-- ------------------------------------------------------------------------
	PRINT 'Granting permissions on table dbApp.Rule_Answer';

	-- End 4
	GRANT INSERT
		,UPDATE
		,DELETE
		,REFERENCES
		ON dbApp.Rule_Answer
		TO DBApp_Admin

	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Answer'
			)
	BEGIN
		PRINT 'Table dbApp.Rule_Answer created successfully';
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Rule_Answer does not exist, create failed.'
	END;
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '***** End of table script *****';
PRINT '------------------------------------------------------------';
PRINT '';
GO

-- =============================================================================
PRINT 'Adding file Rule_Answer_Condition.sql'
-- =============================================================================
PRINT '------------------------------------------------------------';
PRINT '***** Table script for dbApp.Rule_Answer_Condition *****';
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '';

BEGIN TRY
	--if db_name() != 'Test' begin
	--    raiserror('This is not the correct database', 16, 1)
	--end
	-- Preqs
	-- --------------------------------------------------------
	-- --------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Answer_Condition'
			)
	BEGIN
		PRINT 'Table dbApp.Rule_Answer_Condition exists, dropping'

		DROP TABLE dbApp.Rule_Answer_Condition

		PRINT 'TabledbApp.Rule_Answer_Condition dropped'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Rule_Answer_Condition does not exist, skipping drop'
	END

	PRINT 'Creating table dbApp.Rule_Answer_Condition'

	CREATE TABLE dbApp.Rule_Answer_Condition (
		Rule_Answer_Condition_Id INT NOT NULL identity(1, 1)
		,Rule_Answer_Id INT NOT NULL
		,Condition_Nm VARCHAR(100) NOT NULL
		,Condition_Val VARCHAR(100) NOT NULL
		,Active_Fl BIT NOT NULL
		,Add_Usr SYSNAME NOT NULL
		,Add_Dtm DATETIMEOFFSET NOT NULL
		,Update_Usr SYSNAME NOT NULL
		,Update_Dtm DATETIMEOFFSET NOT NULL
		,
		) ON Data;

	PRINT 'Adding constraints to table dbApp.Rule_Answer_Condition'

	ALTER TABLE dbApp.Rule_Answer_Condition ADD CONSTRAINT PK_Rule_Answer_Condition PRIMARY KEY CLUSTERED (Rule_Answer_Condition_Id) ON Data
		,CONSTRAINT DF_Rule_Answer_Condition_Active_Indicator DEFAULT 1
	FOR Active_Fl
		,CONSTRAINT DF_Rule_Answer_Condition_Add_User DEFAULT system_user
	FOR Add_Usr
		,CONSTRAINT DF_Rule_Answer_Condition_Add_Datetime DEFAULT sysdatetimeoffset()
	FOR Add_Dtm
		,CONSTRAINT DF_Rule_Answer_Condition_Update_Usr DEFAULT system_user
	FOR Update_Usr
		,CONSTRAINT DF_Rule_Answer_Condition_Update_Dtm DEFAULT sysdatetimeoffset()
	FOR Update_Dtm;

	-- -------------------------------------------------------------------------
	PRINT 'Adding foreign key from Rule_Answer_Condition to dbApp.Rule_Answer'

	ALTER TABLE dbApp.Rule_Answer_Condition
		WITH CHECK ADD CONSTRAINT FK_Rule_Answer_Condition_ref_Rule_Answer FOREIGN KEY (Rule_Answer_Id) REFERENCES dbApp.Rule_Answer(Rule_Answer_Id)

	ALTER TABLE dbApp.Rule_Answer_Condition CHECK CONSTRAINT FK_Rule_Answer_Condition_ref_Rule_Answer

	-- -------------------------------------------------------------------------
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Answer_Condition'
			)
	BEGIN
		PRINT 'Table dbApp.Rule_Answer_Condition created successfully.'
	END
	ELSE
	BEGIN
		PRINT 'Table  dbApp.Rule_Answer_Condition does not exist, create failed.'
	END
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMEssage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT 'End of table script';
PRINT '--------------------------------------------------';
-- =============================================================================
PRINT 'Adding file Rule_Answer_Value.sql'
-- =============================================================================
PRINT '------------------------------------------------------------';
PRINT '***** Table script for dbApp.Rule_Answer_Value *****';
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '';

BEGIN TRY
	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Answer_Value'
			)
	BEGIN
		PRINT 'Table dbApp.Rule_Answer_Value exists, dropping'

		DROP TABLE dbApp.Rule_Answer_Value

		PRINT 'Table dbApp.Rule_Answer_Value dropped'
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Rule_Answer_Value does not exist, skipping drop'
	END;

	PRINT 'Creating table dbApp.Rule_Answer_Value';

	-- End 1
	CREATE TABLE dbApp.Rule_Answer_Value (
		Rule_Answer_Value_Id INT identity(1, 1) NOT NULL
		,Rule_Answer_Id INT NOT NULL
		,-- fk
		Result_Nm_Id INT NOT NULL
		,-- fk
		Answer_Val VARCHAR(6000) NULL
		,Qualifier VARCHAR(50) NULL
		,Active_Fl BIT NOT NULL
		,Add_Dtm DATETIMEOFFSET NOT NULL
		,Add_Usr VARCHAR(50) NOT NULL
		,Update_Dtm DATETIMEOFFSET NULL
		,Update_Usr VARCHAR(128) NULL
		);

	PRINT 'Adding constraints to table dbApp.Rule_Result';

	-- End 2
	ALTER TABLE dbApp.Rule_Answer_Value ADD CONSTRAINT PK_Rule_Answer_Value PRIMARY KEY CLUSTERED (Rule_Answer_Value_Id)
		WITH FILLFACTOR = 80
			,CONSTRAINT DF_Rule_Answer_Value_Active_Fl DEFAULT(1)
	FOR Active_Fl
		,CONSTRAINT DF_Rule_Answer_Value_Add_Dtm DEFAULT(sysdatetimeoffset())
	FOR Add_Dtm
		,CONSTRAINT DF_Rule_Answer_Value_Add_Usr DEFAULT(system_user)
	FOR Add_Usr
		,CONSTRAINT DF_Rule_Answer_Value_Update_Dtm DEFAULT(sysdatetimeoffset())
	FOR Update_Dtm
		,CONSTRAINT DF_Rule_Answer_Value_Update_Usr DEFAULT(system_user)
	FOR Update_Usr;

	-- ============================================================================
	PRINT 'Adding foreign key to dbApp.Rule_Answer'

	ALTER TABLE dbApp.Rule_Answer_Value
		WITH CHECK ADD CONSTRAINT FK_Rule_Answer_Value_ref_Rule_Answer FOREIGN KEY (Rule_Answer_Id) REFERENCES dbApp.Rule_Answer(Rule_Answer_Id)

	ALTER TABLE dbApp.Rule_Answer_Value CHECK CONSTRAINT FK_Rule_Answer_Value_ref_Rule_Answer

	-- ============================================================================
	PRINT 'Adding foreign key to dbApp.Result_Name'

	ALTER TABLE dbApp.Rule_Answer_Value
		WITH CHECK ADD CONSTRAINT FK_Rule_Answer_Value_ref_Result_Name FOREIGN KEY (Result_Nm_Id) REFERENCES dbApp.Result_Name(Result_Nm_Id)

	ALTER TABLE dbApp.Rule_Answer_Value CHECK CONSTRAINT FK_Rule_Answer_Value_ref_Result_Name

	-- ============================================================================
	-- ------------------------------------------------------------------------
	PRINT 'creating index IX_dbApp_Rule_Result_DBRule_Id';

	CREATE INDEX IX_dbApp_Rule_Answer_Value_DBRule_Id ON dbApp.Rule_Answer_Value (Rule_Answer_Id)
		WITH FILLFACTOR = 90;

	IF EXISTS (
			SELECT *
			FROM sys.indexes
			WHERE object_id = object_id(N'dbApp.Rule_Result')
				AND NAME = N'IX_dbApp_Rule_Result_DBRule_Id'
			)
	BEGIN
		PRINT 'Index created successfully';
	END

	-- ------------------------------------------------------------------------
	-- ------------------------------------------------------------------------
	PRINT 'creating index IX_dbApp_Rule_Result_Result_Nm_Id';

	CREATE INDEX IX_dbApp_Rule_Answer_Value_Result_Nm_Id ON dbApp.Rule_Answer_Value (Result_Nm_Id)
		WITH FILLFACTOR = 90;

	IF EXISTS (
			SELECT *
			FROM sys.indexes
			WHERE object_id = object_id(N'dbApp.Rule_Result')
				AND NAME = N'IX_dbApp_Rule_Result_Result_Nm_Id'
			)
	BEGIN
		PRINT 'Index created successfully';
	END

	-- ------------------------------------------------------------------------
	PRINT 'Granting permissions on table dbApp.Rule_Result';

	-- End 4
	GRANT INSERT
		,UPDATE
		,DELETE
		,REFERENCES
		ON dbApp.Rule_Answer_Value
		TO DBApp_Admin

	IF EXISTS (
			SELECT *
			FROM information_Schema.Tables
			WHERE Table_Schema = N'dbApp'
				AND Table_Name = N'Rule_Answer_Value'
			)
	BEGIN
		PRINT 'Table dbApp.Rule_Answer_Value created successfully';
	END
	ELSE
	BEGIN
		PRINT 'Table dbApp.Rule_Answer_Value does not exist, create failed.'
	END;
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '***** End of table script *****';
PRINT '------------------------------------------------------------';
PRINT '';
GO

-- =============================================================================
PRINT 'Adding file v_dbRule.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for view v_DBRule'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_DBRule'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP VIEW dbApp.v_DBRule

	PRINT 'view dbApp.v_DBRule was dropped'
END
ELSE
BEGIN
	PRINT 'view dbApp.v_DBRule does not exist, drop skipped'
END
GO

CREATE VIEW dbApp.v_DBRule
AS
SELECT DBRule_Id
	,Rule_Nm
	,Ordinal_Value
	,Active_Fl
	,Rule_Resolution_Type_Id
	,cast(Add_Dtm AS DATETIME) AS Add_Dtm
	,datepart(tz, Add_Dtm) AS Add_Ofs
	,Add_Usr
	,cast(Update_Dtm AS DATETIME) AS Update_Dtm
	,datepart(tz, Update_Dtm) AS Update_Ofs
	,Update_Usr
FROM dbApp.DBRule
GO

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_DBRule'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'view dbApp.DBRule was created successfully.'
END
ELSE
BEGIN
	PRINT 'view dbApp.DBRule does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for view dbApp.v_DBRule'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file v_Expression.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for view v_Expression'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Expression'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP VIEW dbApp.v_Expression

	PRINT 'view dbApp.v_Expression was dropped'
END
ELSE
BEGIN
	PRINT 'view dbApp.v_Expression does not exist, drop skipped'
END
GO

CREATE VIEW dbApp.v_Expression
AS
SELECT Expression_Id
	,Expression_Cd
	,Expression_Dsc
	,isCode_Fl
	,isProc_Fl
	,Expression_Type_Id
	,Rule_Cd
	,Param_Ct
	,Response_Fl
	,Return_Tp
	,Param
	,Short_Circut_Fl
	,Active_Fl
	,Add_Usr
	,cast(Add_Dtm AS DATETIME) AS Add_Dtm
	,datepart(tz, Add_Dtm) AS Add_Ofs
	,Update_Usr
	,cast(Update_Dtm AS DATETIME) AS Update_Dtm
	,datepart(tz, Update_Dtm) AS Update_Ofs
FROM dbApp.Expression
GO

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Expression'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'view dbApp.Expression was created successfully.'
END
ELSE
BEGIN
	PRINT 'view dbApp.Expression does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for view dbApp.v_Expression'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file v_Expression_Type.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for view v_Expression_Type'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Expression_Type'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP VIEW dbApp.v_Expression_Type

	PRINT 'view dbApp.v_Expression_Type was dropped'
END
ELSE
BEGIN
	PRINT 'view dbApp.v_Expression_Type does not exist, drop skipped'
END
GO

CREATE VIEW dbApp.v_Expression_Type
AS
SELECT Expression_Type_Id
	,Expression_Type_Cd
	,Expression_Type_Display_Cd
	,Expression_Type_Dsc
	,Active_Fl
	,Sort_Ord
	,Add_Dtm
	,Add_Usr
	,cast(Update_Dtm AS DATETIME) AS Update_Dtm
	,datepart(tz, Update_Dtm) AS Update_Ofs
	,Update_Usr
FROM dbApp.Expression_Type
GO

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Expression_Type'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'view dbApp.Expression_Type was created successfully.'
END
ELSE
BEGIN
	PRINT 'view dbApp.Expression_Type does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for view dbApp.v_Expression_Type'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file v_Operator.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for view v_Operator'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Operator'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP VIEW dbApp.v_Operator

	PRINT 'view dbApp.v_Operator was dropped'
END
ELSE
BEGIN
	PRINT 'view dbApp.v_Operator does not exist, drop skipped'
END
GO

CREATE VIEW dbApp.v_Operator
AS
SELECT Operator_Id
	,Operator_Cd
	,Operator_Display_Cd
	,Operator_Dsc
	,Operator_Type_Id
	,isBinary
	,Precedence
	,Active_Fl
	,Sort_Ord
	,cast(Add_Dtm AS DATETIME) AS Add_Dtm
	,datepart(tz, Add_Dtm) AS Add_Ofs
	,Add_Usr
	,cast(Update_Dtm AS DATETIME) AS Update_Dtm
	,datepart(tz, Update_Dtm) AS Update_Ofs
	,Update_Usr
FROM dbApp.Operator
GO

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Operator'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'view dbApp.Operator was created successfully.'
END
ELSE
BEGIN
	PRINT 'view dbApp.Operator does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for view dbApp.v_Operator'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file v_Operator_Type.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for view v_Operator_Type'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Operator_Type'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP VIEW dbApp.v_Operator_Type

	PRINT 'view dbApp.v_Operator_Type was dropped'
END
ELSE
BEGIN
	PRINT 'view dbApp.v_Operator_Type does not exist, drop skipped'
END
GO

CREATE VIEW dbApp.v_Operator_Type
AS
SELECT Operator_Type_Id
	,Operator_Type_Cd
	,Operator_Type_Display_Cd
	,Operator_Type_Dsc
	,Active_Fl
	,Sort_Ord
	,cast(Add_Dtm AS DATETIME) AS Add_Dtm
	,datepart(tz, Add_Dtm) AS Add_Ofs
	,Add_Usr
	,cast(Update_Dtm AS DATETIME) AS Update_Dtm
	,datepart(tz, Update_Dtm) AS Update_Ofs
	,Update_Usr
FROM dbApp.Operator_Type
GO

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Operator_Type'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'view dbApp.Operator_Type was created successfully.'
END
ELSE
BEGIN
	PRINT 'view dbApp.Operator_Type does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for view dbApp.v_Operator_Type'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file v_Result_Name.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for view v_Result_Name'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Result_Name'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP VIEW dbApp.v_Result_Name

	PRINT 'view dbApp.v_Result_Name was dropped'
END
ELSE
BEGIN
	PRINT 'view dbApp.v_Result_Name does not exist, drop skipped'
END
GO

CREATE VIEW dbApp.v_Result_Name
AS
SELECT Result_Nm_Id
	,Result_Nm
	,Active_Fl
	,Sort_Ord
	,cast(Add_Dtm AS DATETIME) AS Add_Dtm
	,datepart(tz, Add_Dtm) AS Add_Ofs
	,Add_Usr
	,cast(Update_Dtm AS DATETIME) AS Update_Dtm
	,datepart(tz, Update_Dtm) AS Update_Ofs
	,Update_Usr
FROM dbApp.Result_Name
GO

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Result_Name'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'view dbApp.Result_Name was created successfully.'
END
ELSE
BEGIN
	PRINT 'view dbApp.Result_Name does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for view dbApp.v_Result_Name'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file v_Rule_Answer.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for view v_Rule_Answer'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Rule_Answer'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP VIEW dbApp.v_Rule_Answer

	PRINT 'view dbApp.v_Rule_Answer was dropped'
END
ELSE
BEGIN
	PRINT 'view dbApp.v_Rule_Answer does not exist, drop skipped'
END
GO

CREATE VIEW dbApp.v_Rule_Answer
AS
SELECT Rule_Answer_Id
	,DBRule_Id
	,Answer_Name
	,Active_Fl
	,Priority_Val
	,Truth_Fl
	,cast(Add_Dtm AS DATETIME) AS Add_Dtm
	,datepart(tz, Add_Dtm) AS Add_Ofs
	,Add_Usr
FROM dbApp.Rule_Answer
GO

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Rule_Answer'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'view dbApp.v_Rule_Answer was created successfully.'
END
ELSE
BEGIN
	PRINT 'view dbApp.v_Rule_Answer does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for view dbApp.v_Rule_Answer'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file v_Rule_Answer_Value.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for view v_Rule_Answer_Value'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Rule_Answer_Value'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP VIEW dbApp.v_Rule_Answer_Value

	PRINT 'view dbApp.v_Rule_Answer_Value was dropped'
END
ELSE
BEGIN
	PRINT 'view dbApp.v_Rule_Answer_Value does not exist, drop skipped'
END
GO

CREATE VIEW dbApp.v_Rule_Answer_Value
AS
SELECT Rule_Answer_Value_Id
	,Rule_Answer_Id
	,Result_Nm_Id
	,Answer_Val
	,Qualifier
	,Active_Fl
	,cast(Add_Dtm AS DATETIME) AS Add_Dtm
	,datepart(tz, Add_Dtm) AS Add_Ofs
	,Add_Usr
	,cast(Update_Dtm AS DATETIME) AS Update_Dtm
	,datepart(tz, Update_Dtm) AS Update_Ofs
	,Update_Usr
FROM dbApp.Rule_Answer_Value
GO

IF EXISTS (
		SELECT *
		FROM sys.VIEWS v
		INNER JOIN sys.schemas sch ON sch.schema_id = v.schema_id
		WHERE v.NAME = 'v_Rule_Answer_Value'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'view dbApp.v_Rule_Answer_Value was created successfully.'
END
ELSE
BEGIN
	PRINT 'view dbApp.v_Rule_Answer_Value does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for view dbApp.v_Rule_Answer_Value'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file v_Rule_Answer_Condition.sql'
-- =============================================================================
PRINT '------------------------------------------------------------';
PRINT 'View script for dbApp.v_Rule_Answer_Condition';
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '';

BEGIN TRY
	IF EXISTS (
			SELECT *
			FROM sys.VIEWS
			WHERE object_id = object_id(N'dbApp.v_Rule_Answer_Condition')
			)
	BEGIN
		PRINT 'View dbApp.v_Rule_Answer_Condition exists, dropping'

		DROP VIEW dbApp.v_Rule_Answer_Condition

		PRINT 'View dbApp.v_Rule_Answer_Condition dropped'
	END
	ELSE
	BEGIN
		PRINT 'View dbApp.v_Rule_Answer_Condition does not exist, skipping drop'
	END
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMEssage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH
GO

CREATE VIEW dbApp.v_Rule_Answer_Condition
AS
SELECT Rule_Answer_Condition_Id
	,Rule_Answer_Id
	,Condition_Nm
	,Condition_Val
	,Active_Fl
	,Add_Usr
	,cast(Add_Dtm AS DATETIME) AS Add_Dtm
	,datepart(tz, Add_Dtm) AS Add_Ofs
	,Update_Usr
	,cast(Update_Dtm AS DATETIME) AS Update_Dtm
	,datepart(tz, Update_Dtm) AS Update_Ofs
FROM dbApp.Rule_Answer_Condition
GO

BEGIN TRY
	IF EXISTS (
			SELECT *
			FROM sys.VIEWS
			WHERE object_id = object_id(N'dbApp.v_Rule_Answer_Condition')
			)
	BEGIN
		PRINT 'View dbApp.v_Rule_Answer_Condition was created'
	END
	ELSE
	BEGIN
		PRINT 'View dbApp.v_Rule_Answer_Condition was not created'
	END
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMEssage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT 'End of view script';
PRINT '------------------------------------------------------------';
PRINT '';
GO

-- =============================================================================
PRINT 'Adding file v_Rule_Resolution_Type.sql'
-- =============================================================================
PRINT '------------------------------------------------------------';
PRINT 'View script for dbApp.v_Rule_Resolution_Type';
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '';

BEGIN TRY
	IF EXISTS (
			SELECT *
			FROM sys.VIEWS
			WHERE object_id = object_id(N'dbApp.v_Rule_Resolution_Type')
			)
	BEGIN
		PRINT 'View dbApp.v_Rule_Resolution_Type exists, dropping'

		DROP VIEW dbApp.v_Rule_Resolution_Type

		PRINT 'View dbApp.v_Rule_Resolution_Type dropped'
	END
	ELSE
	BEGIN
		PRINT 'View dbApp.v_Rule_Resolution_Type does not exist, skipping drop'
	END
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMEssage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH
GO

CREATE VIEW dbApp.v_Rule_Resolution_Type
AS
SELECT Rule_Resolution_Type_Id
	,Rule_Resolution_Type_Cd
	,Rule_Resolution_Type_Display_Cd
	,Rule_Resolution_Type_Dsc
	,Active_Fl
	,Sort_Ord
	,Add_Usr
	,cast(Add_Dtm AS DATETIME) AS Add_Dtm
	,datepart(tz, Add_Dtm) AS Add_Ofs
	,Update_Usr
	,cast(Update_Dtm AS DATETIME) AS Update_Dtm
	,datepart(tz, Update_Dtm) AS Update_Ofs
FROM Rule_Resolution_Type
GO

BEGIN TRY
	IF EXISTS (
			SELECT *
			FROM sys.VIEWS
			WHERE object_id = object_id(N'dbApp.v_Rule_Resolution_Type')
			)
	BEGIN
		PRINT 'View dbApp.v_Rule_Resolution_Type was created'
	END
	ELSE
	BEGIN
		PRINT 'View dbApp.v_Rule_Resolution_Type was not created'
	END
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMEssage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT 'End of view script';
PRINT '------------------------------------------------------------';
PRINT '';
GO

-- =============================================================================
PRINT 'Adding file Expression_Type_Populate.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT ''
PRINT 'Populate script for dbApp.Expression_Type'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

SET NOCOUNT ON

DECLARE @Rowcount INT

BEGIN TRY
	INSERT INTO dbApp.Expression_Type (
		Expression_Type_Cd
		,Expression_Type_Display_Cd
		,Expression_Type_Dsc
		)
	SELECT 'Boolean'
		,'Boolean'
		,'This is a rule that resolves to true or false'
	
	UNION
	
	SELECT 'Calculation'
		,'CALC'
		,'This rule is a calculation'
	
	UNION
	
	SELECT 'Execution'
		,'Executable Code'
		,'Command rules are used where a series of rules must execute. All rules in the set will execute.'
	
	UNION
	
	SELECT 'Association'
		,'Association'
		,'Simple Value'
	
	UNION
	
	SELECT 'Existance'
		,'Existance'
		,'This Expression Type is used for simple boolean evaluations. A single value is tested and cannot be null and, if numeric, 0, if character, blank.'
	
	UNION
	
	SELECT 'ErrorCheck'
		,'ErrorCheck'
		,'Checks for a non-zero result code which indicates an error.'
	
	UNION
	
	SELECT 'ShortBool'
		,'Short Boolean'
		,'This is a type used for rudimentary boolean evaluations'
	
	UNION
	
	SELECT 'Resolution'
		,'Resolution'
		,'This type drives the resolution of a value and its validation'
	
	UNION
	
	SELECT 'QuerySingleCondition'
		,'QuerySingleCondition'
		,'Expression is joined against a table'
	
	UNION
	
	SELECT 'Query10'
		,'Query10'
		,'Matches against a table with 10 match columns'
	
	UNION
	
	SELECT 'QueryString'
		,'QueryString'
		,'Similar to QuerySingleCondition, this matches on a single value'

	SET @Rowcount = @@rowcount

	PRINT 'Rows added to the dbApp.Expression_Type table :' + cast(@Rowcount AS VARCHAR(10))
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of populate script *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO

-- =============================================================================
PRINT 'Adding file Operator_Type_Populate.sql'

-- =============================================================================
SET NOCOUNT ON

PRINT '------------------------------------------------------------'
PRINT ''
PRINT 'Populate script for dbApp.Operator_Type'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

DECLARE @Rowcount INT

BEGIN TRY
	INSERT INTO dbApp.Operator_Type (
		Operator_Type_Cd
		,Operator_Type_Display_Cd
		,Operator_Type_Dsc
		)
	SELECT 'Arithmetic'
		,'Arithmetic'
		,'Operators used in aritmetic calculations. Return an arithmetic value'
	
	UNION
	
	SELECT 'Logical'
		,'Logical'
		,'Operators used in logical operations. Return true or false'
	
	UNION
	
	SELECT 'Cond'
		,'Conditional'
		,'Operators used in conditional comparisons. Return true or false'
	
	UNION
	
	SELECT 'Character'
		,'Character'
		,'Operators used in string operations. Return a string'
	
	UNION
	
	SELECT 'Set'
		,'Set'
		,'Operators used in set operations. Return a set of data'
	
	UNION
	
	SELECT 'Assignment'
		,'Assignment'
		,'Operators used to assign values, returns nothing'

	SET @Rowcount = @@rowcount

	PRINT 'Rows added to the dbApp.Operator_Type table :' + cast(@Rowcount AS VARCHAR(10))
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '***** End of populate script *****';
PRINT '------------------------------------------------------------';
PRINT '';
GO

-- =============================================================================
PRINT 'Adding file Rule_Resolution_Type_Populate.sq'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT ''
PRINT 'Populate script for dbApp.Rule_Resolution_Type'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

SET NOCOUNT ON

DECLARE @Rowcount INT

BEGIN TRY
	INSERT INTO dbApp.Rule_Resolution_Type (
		Rule_Resolution_Type_Cd
		,Rule_Resolution_Type_Display_Cd
		,Rule_Resolution_Type_Dsc
		)
	VALUES (
		'Condition'
		,'Condition'
		,'A rule that matches conditions to yield an answer'
		)
		,(
		'Boolean'
		,'Boolean'
		,'This is a rule that resolves to true or false'
		)
		,(
		'Calculation'
		,'CALC'
		,'This rule is a calculation'
		)
		,(
		'Execution'
		,'Executable Code'
		,'Command rules are used where a series of rules must execute. All rules in the set will execute.'
		)
		,(
		'Association'
		,'Association'
		,'Simple Value'
		)
		,(
		'Existance'
		,'Existance'
		,'This Expression Type is used for simple boolean evaluations. A single value is tested and cannot be null and, if numeric, 0, if character, blank.'
		)
		,(
		'ErrorCheck'
		,'ErrorCheck'
		,'Checks for a non-zero result code which indicates an error.'
		)
		,(
		'ShortBool'
		,'Short Boolean'
		,'This is a type used for rudimentary boolean evaluations'
		)
		,(
		'Resolution'
		,'Resolution'
		,'This type drives the resolution of a value and its validation'
		)

	SET @Rowcount = @@rowcount

	PRINT 'Rows added to the dbApp.Rule_Resolution_Type table :' + cast(@Rowcount AS VARCHAR(10))
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of populate script *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO

-- =============================================================================
PRINT 'Adding file Operator_Populate.sql'

-- =============================================================================
SET NOCOUNT ON

PRINT '------------------------------------------------------------'
PRINT ''
PRINT 'Populate script for dbApp.Operator'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

BEGIN TRY
	TRUNCATE TABLE dbApp.Operator

	DECLARE @OpType INT
	DECLARE @Rowcount INT = 0
	DECLARE @Total INT = 0

	-- Arithmetic
	-- ************************************************************************************
	SET @Optype = (
			SELECT Operator_Type_id
			FROM dbApp.Operator_Type
			WHERE Operator_Type_Cd = 'Arithmetic'
			)

	-- ************************************************************************************
	INSERT INTO dbApp.Operator (
		Operator_Type_Id
		,Operator_Cd
		,Operator_Display_Cd
		,Operator_Dsc
		,isBinary
		,Precedence
		)
	SELECT @OpType
		,'='
		,'='
		,'Equals'
		,1
		,0
	
	UNION
	
	SELECT @OpType
		,'+'
		,'+'
		,'Addition'
		,1
		,2
	
	UNION
	
	SELECT @OpType
		,'-'
		,'-'
		,'Subtraction'
		,1
		,2
	
	UNION
	
	SELECT @OpType
		,'*'
		,'*'
		,'Multiplication'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'\'
		,'\'
		,'Division'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'%'
		,'%'
		,'Modulus Division'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'**'
		,'**'
		,'Exponentiation'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'++'
		,'++'
		,'Increment'
		,0
		,2
	
	UNION
	
	SELECT @OpType
		,'--'
		,'--'
		,'Decrement'
		,0
		,2

	SET @Rowcount = @@rowcount
	SET @Total += @Rowcount
	-- Logical
	-- ************************************************************************************
	SET @Optype = (
			SELECT Operator_Type_id
			FROM dbApp.Operator_Type
			WHERE Operator_Type_Cd = 'Logical'
			)

	-- ************************************************************************************
	INSERT INTO dbApp.Operator (
		Operator_Type_Id
		,Operator_Cd
		,Operator_Display_Cd
		,Operator_Dsc
		,isBinary
		,Precedence
		)
	SELECT @OpType
		,'&&'
		,'and'
		,'Logical and'
		,1
		,5
	
	UNION
	
	SELECT @OpType
		,'||'
		,'or'
		,'Logical Or'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'!'
		,'not'
		,'Logical negation'
		,0
		,4
	
	UNION
	
	SELECT @OpType
		,'|'
		,'xor'
		,'Exclusive Or'
		,1
		,6

	SET @Rowcount = @@rowcount
	SET @Total += @Rowcount
	-- Conditional
	-- ************************************************************************************
	SET @Optype = (
			SELECT Operator_Type_id
			FROM dbApp.Operator_Type
			WHERE Operator_Type_Cd = 'Cond'
			)

	-- ************************************************************************************
	INSERT INTO dbApp.Operator (
		Operator_Type_Id
		,Operator_Cd
		,Operator_Display_Cd
		,Operator_Dsc
		,isBinary
		,Precedence
		)
	SELECT @OpType
		,'>'
		,'>'
		,'Greater than'
		,1
		,3
	
	UNION
	
	SELECT @OpType
		,'<'
		,'<'
		,'Less than'
		,1
		,3
	
	UNION
	
	SELECT @OpType
		,'>='
		,'>='
		,'Greater than or equal to'
		,1
		,3
	
	UNION
	
	SELECT @OpType
		,'<='
		,'<='
		,'Less than or equal to'
		,1
		,3
	
	UNION
	
	SELECT @OpType
		,'<>'
		,'<>'
		,'Not equal to'
		,1
		,3
	
	UNION
	
	SELECT @OpType
		,'=='
		,'=='
		,'equal to'
		,1
		,3
	
	UNION
	
	SELECT @OpType
		,'!='
		,'!='
		,'not equal to'
		,1
		,3
	
	UNION
	
	SELECT @OpType
		,'!<'
		,'!<'
		,'not Less than'
		,1
		,3
	
	UNION
	
	SELECT @OpType
		,'!>'
		,'!>'
		,'Not greater than'
		,1
		,3
	
	UNION
	
	SELECT @OpType
		,'??'
		,'isnull'
		,'is null'
		,0
		,3
	
	UNION
	
	SELECT @OpType
		,'<*'
		,'<*'
		,'Less than all'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'<?'
		,'<?'
		,'Less than any'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'<#'
		,'<#'
		,'Less than some'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'>*'
		,'>*'
		,'greater than all'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'>?'
		,'>?'
		,'greater than any'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'>#'
		,'>#'
		,'greater than some'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'><'
		,'><'
		,'between'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'!><'
		,'!><'
		,'not between'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'[]'
		,'in'
		,'in'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'![]'
		,'!in'
		,'not in'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'{xs}'
		,'xs'
		,'Exists'
		,1
		,3
	
	UNION
	
	SELECT @OpType
		,'{!xs}'
		,'!xs'
		,'Not Exists'
		,1
		,3
	
	UNION
	
	SELECT @OpType
		,'{like}'
		,'like'
		,'Like'
		,1
		,6
	
	UNION
	
	SELECT @OpType
		,'{!like}'
		,'!like'
		,'Not Like'
		,1
		,6

	SET @Rowcount = @@rowcount
	SET @Total += @Rowcount
	-- Set
	-- ************************************************************************************
	SET @Optype = (
			SELECT Operator_Type_id
			FROM dbApp.Operator_Type
			WHERE Operator_Type_Cd = 'Set'
			)

	-- ************************************************************************************
	INSERT INTO dbApp.Operator (
		Operator_Type_Id
		,Operator_Cd
		,Operator_Display_Cd
		,Operator_Dsc
		,isBinary
		,Precedence
		)
	SELECT @OpType
		,'{ij}'
		,'inner join '
		,'inner join'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'{loj}'
		,'Left outer join'
		,'Left outer join'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'{roj}'
		,'right outer join'
		,'Right outer join'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'{foj}'
		,'full outer join'
		,'full outer join'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'{cj}'
		,'cross join'
		,'cross join'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'{res}'
		,'restriction'
		,'restriction'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'{div}'
		,'divide'
		,'divide'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'{u}'
		,'union'
		,'union'
		,1
		,2
	
	UNION
	
	SELECT @OpType
		,'{ua}'
		,'union all'
		,'union all'
		,1
		,2
	
	UNION
	
	SELECT @OpType
		,'{sub}'
		,'subtraction'
		,'subtraction'
		,1
		,2
	
	UNION
	
	SELECT @OpType
		,'{ins}'
		,'Intersect'
		,'Intersect'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'{prj}'
		,'Project'
		,'Project'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'{dif}'
		,'difference'
		,'Difference'
		,1
		,2
	
	UNION
	
	SELECT @OpType
		,'{prd}'
		,'Product'
		,'Product'
		,1
		,2

	SET @Rowcount = @@rowcount
	SET @Total += @Rowcount
	-- Assignment
	-- ************************************************************************************
	SET @Optype = (
			SELECT Operator_Type_id
			FROM dbApp.Operator_Type
			WHERE Operator_Type_Cd = 'Assignment'
			)

	-- ************************************************************************************
	INSERT INTO dbApp.Operator (
		Operator_Type_Id
		,Operator_Cd
		,Operator_Display_Cd
		,Operator_Dsc
		,isBinary
		,Precedence
		)
	SELECT @OpType
		,'<-'
		,'is set to'
		,'is set to'
		,1
		,7
	
	UNION
	
	SELECT @OpType
		,'??<-'
		,'set null'
		,'Set to a null value'
		,0
		,7
	
	UNION
	
	SELECT @OpType
		,':=:'
		,'Assign all'
		,'Deep Assignment'
		,1
		,7
	
	UNION
	
	SELECT @OpType
		,'<-->'
		,'Clear'
		,'Clear'
		,0
		,7
	
	UNION
	
	SELECT @OpType
		,'+='
		,'+='
		,'value = value + operand'
		,1
		,2
	
	UNION
	
	SELECT @OpType
		,'-='
		,'-='
		,'value = value - operand'
		,1
		,2
	
	UNION
	
	SELECT @OpType
		,'*='
		,'*='
		,'value = value * operand'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'\='
		,'\='
		,'value = value \ operand'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'%='
		,'%='
		,'value = value mod operand'
		,1
		,1
	
	UNION
	
	SELECT @OpType
		,'^='
		,'^='
		,'value = value ^ operand'
		,1
		,1

	SET @Rowcount = @@rowcount
	SET @Total += @Rowcount
	-- more conditional
	-- ************************************************************************************
	SET @Optype = (
			SELECT Operator_Type_id
			FROM dbApp.Operator_Type
			WHERE Operator_Type_Cd = 'Cond'
			)

	-- ************************************************************************************
	INSERT INTO dbApp.Operator (
		Operator_Type_Id
		,Operator_Cd
		,Operator_Display_Cd
		,Operator_Dsc
		,isBinary
		,Precedence
		)
	SELECT @Optype
		,'!??'
		,'not null'
		,'is not null'
		,0
		,3
	
	UNION
	
	SELECT @OpType
		,'=*'
		,'all'
		,'is equal to all'
		,1
		,6
	
	UNION
	
	SELECT @OPType
		,'=?'
		,'any'
		,'is equal to any'
		,1
		,6

	SET @Rowcount = @@rowcount
	SET @Total += @Rowcount
	-- unary Arithmetic
	-- ************************************************************************************
	SET @Optype = (
			SELECT Operator_Type_id
			FROM dbApp.Operator_Type
			WHERE Operator_Type_Cd = 'Arithmetic'
			)

	-- ************************************************************************************
	INSERT INTO dbApp.Operator (
		Operator_Type_Id
		,Operator_Cd
		,Operator_Display_Cd
		,Operator_Dsc
		,isBinary
		,Precedence
		)
	SELECT @OpType
		,':-:'
		,'Negative'
		,'Make Negative'
		,0
		,0
	
	UNION
	
	SELECT @OpType
		,':+:'
		,'Positive'
		,'Make Positive'
		,0
		,0

	SET @Rowcount = @@rowcount
	SET @Total += @Rowcount
	-- String concatenation
	-- ************************************************************************************
	SET @Optype = (
			SELECT Operator_Type_id
			FROM dbApp.Operator_Type
			WHERE Operator_Type_Cd = 'Character'
			)

	-- ************************************************************************************
	INSERT INTO dbApp.Operator (
		Operator_Type_Id
		,Operator_Cd
		,Operator_Display_Cd
		,Operator_Dsc
		,isBinary
		,Precedence
		)
	SELECT @OpType
		,'&+'
		,'Concatenation'
		,'String concatenation'
		,1
		,2
	
	UNION
	
	SELECT @OpType
		,'&-'
		,'Split'
		,'String Split'
		,1
		,2

	SET @Rowcount = @@rowcount
	SET @Total += @Rowcount

	PRINT 'Rows added to the dbApp.Operator table :' + cast(@Total AS VARCHAR(10))
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of populate script *****'
PRINT '------------------------------------------------------------'
PRINT ''
	--set identity_insert Operator off
GO

-- =============================================================================
PRINT 'Adding file Result_Name_Populate.sql'

-- =============================================================================
SET NOCOUNT ON

PRINT '------------------------------------------------------------'
PRINT ''
PRINT 'Populate script for dbApp.Result_Nm'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

DECLARE @Rowcount INT

BEGIN TRY
	SET IDENTITY_INSERT dbApp.Result_Name ON

	INSERT INTO dbApp.Result_Name (
		Result_Nm_Id
		,Result_Nm
		)
	SELECT 1
		,'Command Text'
	
	UNION
	
	SELECT 2
		,'Default Job Status Type'
	
	UNION
	
	SELECT 3
		,'Default Job Type'
	
	UNION
	
	SELECT 4
		,'Default Work Status'
	
	UNION
	
	SELECT 5
		,'ErrorId'
	
	UNION
	
	SELECT 6
		,'ErrorMsg'
	
	UNION
	
	SELECT 7
		,'File Location'
	
	UNION
	
	SELECT 8
		,'File Name'
	
	UNION
	
	SELECT 9
		,'FMT File Location'
	
	UNION
	
	SELECT 10
		,'Server Name'
	
	UNION
	
	SELECT 11
		,'Table Name'
	
	UNION
	
	SELECT 12
		,'TechMsg'
	
	UNION
	
	SELECT 13
		,'Start Date'
	
	UNION
	
	SELECT 14
		,'End Date'
	
	UNION
	
	SELECT 15
		,'WorkFlow'
	
	UNION
	
	SELECT 16
		,'ECR Date Type'
	
	UNION
	
	SELECT 17
		,'InstitutionId'
	
	UNION
	
	SELECT 18
		,'Extract Mode'

	SET @Rowcount = @@rowcount

	PRINT 'Rows added to the dbApp.Result_Name table :' + cast(@Rowcount AS VARCHAR(10))

	SET IDENTITY_INSERT dbApp.Result_Name OFF
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '***** End of populate script *****';
PRINT '------------------------------------------------------------';
PRINT '';
GO

-- =============================================================================
PRINT 'Adding file Expression_Populate.sql'

-- =============================================================================
SET NOCOUNT ON

PRINT '------------------------------------------------------------'
PRINT ''
PRINT 'Populate script for dbApp.Expression'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

DECLARE @Rowcount INT

BEGIN TRY
	DECLARE @Association INT
	DECLARE @Boolean INT
	DECLARE @QuerySingle INT
	DECLARE @Query10 INT

	SET @Association = (
			SELECT Expression_Type_Id
			FROM dbApp.Expression_Type
			WHERE Expression_Type_Cd = 'Association'
			)
	SET @Boolean = (
			SELECT Expression_Type_Id
			FROM dbApp.Expression_Type
			WHERE Expression_Type_Cd = 'Boolean'
			)
	SET @QuerySingle = (
			SELECT Expression_Type_Id
			FROM dbApp.Expression_Type
			WHERE Expression_Type_Cd = 'QuerySingleCondition'
			)
	SET @Query10 = (
			SELECT Expression_Type_Id
			FROM dbApp.Expression_Type
			WHERE Expression_Type_Cd = 'Query10'
			)
	SET IDENTITY_INSERT dbApp.Expression ON

	INSERT INTO dbApp.Expression (
		Expression_Id
		,Expression_Cd
		,Expression_Dsc
		,isCode_Fl
		,isProc_Fl
		,Expression_Type_Id
		,Rule_Cd
		,Param_Ct
		,Response_Fl
		,Return_Tp
		,Param
		,Short_Circut_Fl
		)
	SELECT 1
		,'Empty Expression'
		,'This is a special case expression that does nothing. It is used for simple Association rules where all we want is a rule name and a corresponding value.'
		,0
		,0
		,@Association
		,''
		,1
		,1
		,'none'
		,'none'
		,1
	
	UNION
	
	SELECT 2
		,'SingleValueLookup'
		,'Does a lookup to determine the value associated with the condition passed.'
		,2
		,0
		,@QuerySingle
		,''
		,0
		,0
		,'none'
		,'none'
		,1
	
	UNION
	
	SELECT 3
		,'Query10'
		,'Expression to force the Rule_Answer_10 lookup'
		,2
		,0
		,@Query10
		,''
		,0
		,0
		,'none'
		,'none'
		,1

	SET @Rowcount = @@rowcount

	PRINT 'Rows added to the dbApp.Expression table :' + cast(@Rowcount AS VARCHAR(10))

	SET IDENTITY_INSERT dbApp.Expression OFF
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT '***** End of populate script *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO

-- =============================================================================
PRINT 'Adding file Numbers_Populate.sql'

-- =============================================================================
SET NOCOUNT ON

PRINT '------------------------------------------------------------'
PRINT ''
PRINT 'Populate script for dbApp.Numbers'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

DECLARE @Rowcount INT

BEGIN TRY
	IF EXISTS (
			SELECT *
			FROM dbApp.Numbers
			)
		TRUNCATE TABLE dbApp.Numbers

	-- truncate table dbApp.Numbers
	INSERT INTO dbApp.Numbers
	SELECT TOP 1000000 (
			row_number() OVER (
				ORDER BY ac1.column_id
				)
			) - 1 AS RowNum
	FROM master.sys.all_columns ac1
	CROSS JOIN master.sys.all_columns ac2

	SET @Rowcount = @@rowcount

	PRINT 'Rows added to the dbApp.Numbers table :' + cast(@Rowcount AS VARCHAR(10))
		-- check the data
END TRY

BEGIN CATCH
	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage
		,error_line() AS ErrorLine
		,error_state() AS ErrorState
		,error_severity() AS ErrorSeverity
		,error_procedure() AS ErrorProcedure;
END CATCH;

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '***** End of populate script *****';
PRINT '------------------------------------------------------------';
PRINT '';
GO

-- =============================================================================
PRINT 'Adding file f_BuildCallStack.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT 'Script file for function dbo.f_BuildCallStack'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'f_BuildCallStack'
			AND ROUTINE_TYPE = 'Function'
		)
BEGIN
	PRINT 'Dropping function dbApp.f_BuildCallStack'

	DROP FUNCTION dbApp.f_BuildCallStack
END
ELSE
BEGIN
	PRINT 'Function dbApp.f_BuildCallStack does not exist, skipping drop'
END
GO

PRINT 'Creating function dbApp.f_BuildCallStack';
GO

CREATE FUNCTION dbApp.f_BuildCallStack (
	@i_InValue VARCHAR(1000)
	,-- The existing call stack
	@i_Level INT
	,-- The current nestlevel
	@i_Proc VARCHAR(128) -- The procedure being added to the stack
	)
RETURNS VARCHAR(1000)
AS
--/**
--* $Filename: f_BuildCallStack.sql
--* $Author: Stephen R. McLarnon
--*
--* $Object: dbApp.f_BuildCallStack
--* $ObjectType: Scalar function
--*
--* $Description: This function returns a single value that is the
--* concatenation of the passed call stack, a semi-colon as appropriate, and
--* the name of the calling procedure. If this is the top level call, the
--* first parameter will be null or an empty string.
--* This function is used to build a string representation of the stored
--* procedure call stack.
--*
--* $Param1: @i_InValue - The existing call stack passed.
--* $Param2: @i_Level - The nestlevel of the calling stored procedure.
--* $Param3: @i_Proc - The name of the calling procedure. This value is added
--*                    to the call stack.
--*
--* $OutputType: varchar(1000)
--*
--* $Output1: The stack of proc/function calls as a single string
--*
--* $$Revisions
--*  Ini |    Date     | Description
--* ---------------------------------
--* $End:
--**/
BEGIN
	--/**
	--* $C: Examine the passed stack, if it is null, make it an empty string then
	--* add to it a semicolon as long as we are not the first call. Finally,
	--* add to that, the name of the procedure from which this call was made.
	--**/
	RETURN (
			isnull(@i_InValue, '') + CASE 
				WHEN @i_Level IS NULL
					THEN ''
				WHEN @i_Level = 1
					THEN ''
				ELSE ';' + @i_Proc
				END
			);;
END
GO

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'f_BuildCallStack'
			AND ROUTINE_TYPE = 'Function'
		)
BEGIN
	PRINT 'Function dbApp.f_BuildCallStack was created successfully'
	PRINT 'Add security assignment of execute to DBApp_Processor'

	GRANT EXECUTE
		ON dbApp.f_BuildCallStack
		TO DBApp_Processor;
END
ELSE
BEGIN
	PRINT 'Function dbApp.f_BuildCallStack does not exist, create failed'
END

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT 'End of script file for dbApp.f_BuildCallStack'
PRINT '----------------------------------------------------------------------'
GO

/*
-- Test Code
declare	@In		varchar(1000)
declare	@Out	varchar(1000)

set @In = ('Test1;Test2;Test3')

set @Out = dbApp.f_BuildCallStack (@In, 3, 'TestProc')

select @Out

*/
-- =============================================================================
PRINT 'Adding file f_Daily_Interval_Generate.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT 'Script file for function dbApp.f_Daily_Interval_Generate'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'f_Daily_Interval_Generate'
			AND ROUTINE_TYPE = 'Function'
		)
BEGIN
	PRINT 'Dropping function dbApp.f_Daily_Interval_Generate'

	DROP FUNCTION dbApp.f_Daily_Interval_Generate
END
ELSE
BEGIN
	PRINT 'Function dbApp.f_Daily_Interval_Generate does not exist, skipping drop'
END
GO

PRINT 'Creating function dbApp.f_Daily_Interval_Generate';
GO

CREATE FUNCTION dbApp.f_Daily_Interval_Generate (@i_Interval INT)
RETURNS @IntervalData TABLE (
	-- columns returned by the function
	StartTime INT NOT NULL
	,InvervalValue TIME NOT NULL
	)
AS
--/**
--*
--* $Filename: f_Daily_Interval_Generate.sql
--* $Author: Stephen R. McLarnon Sr.
--*
--* $Object: f_Daily_Interval_Generate
--* $ObjectType: Table-Valued function
--*
--* $Description: This function returns a table of values that are used in
--* interval reporting, specifically in call reporting. The table returned
--* has all intervals for a single day. Daily interval generation makes sense
--* only for those values that are an integral factor of 60. The smallest
--* interval is one minute.
--*
--* $Param1: @i_Inverval - The single input parameter repersents the number of
--* minutes in the interval. The intent here is to use intervals that divide
--* evenly into 60. I have not tested all other cases but it does seem to work
--* with other values.
--*
--* $OutputType: Table
--*
--* $Output1: StartTime - An integer value that is the [hours] and minutes
--* with the righmost 1 or 2 digits as the minutes (always) and, if there is a
--* third/fourth digit, the leftmost 1 or 2 are the hours.
--*
--* $Output2: InvervalValue - An 8 character string representation of the
--* interval in HH:MM:SS format. Please note that in this function, the SS
--* value is always '00'.
--*
--* $Note: This function depends upon the existence of a table of numbers named
--* Numbers where the number column is named number.
--*
--* $$Revisions:
--*  Ini |    Date     | Description
--* ---------------------------------
--* $End:
--**/
BEGIN
	--/**
	--* $c: The code only executes if a positive integer between 1 and 1440
	--* has been passed. 1440 is the number of minutes in a day.
	--* Any other value causes an empty table to be returned.
	--*/
	IF @i_Interval BETWEEN 1
			AND 1440
	BEGIN
		INSERT INTO @IntervalData
		SELECT cast(cast(((Number - 1) * @i_Interval / 60) AS VARCHAR(2)) + left(cast(((Number - 1) * @i_Interval % 60) AS VARCHAR(2)) + '0', 2) AS SMALLINT)
			,cast(stuff(right('00' + cast(((Number - 1) * @i_Interval) / 60 AS VARCHAR(2)), 2) + right('00' + cast(((Number - 1) * @i_Interval) % 60 AS VARCHAR(2)), 2), 3, 0, ':') + ':00' AS TIME)
		FROM Numbers
		WHERE Number <= (60 / @i_Interval) * 24
			AND Number > 0;
	END

	RETURN;
END;
GO

/*
Test

select *
from dbApp.f_Daily_Interval_Generate (30)

*/
GO

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'f_Daily_Interval_Generate'
			AND ROUTINE_TYPE = 'Function'
		)
BEGIN
	PRINT 'Function dbApp.f_Daily_Interval_Generate was created successfully'
	PRINT 'Add security assignment of select to DBApp_Processor'

	GRANT SELECT
		ON dbApp.f_Daily_Interval_Generate
		TO DBApp_Processor;
END
ELSE
BEGIN
	PRINT 'Function dbApp.f_Daily_Interval_Generate does not exist, create failed'
END

PRINT ''
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT 'End of script file for dbApp.f_Daily_Interval_Generate'
PRINT '----------------------------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file f_Daily_Interval_Generate_from_C'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT 'Script file for function dbApp.f_Daily_Interval_Generate_from_CTE'
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36))
PRINT ''

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'f_Daily_Interval_Generate_from_CTE'
			AND ROUTINE_TYPE = 'Function'
		)
BEGIN
	PRINT 'Dropping function dbApp.f_Daily_Interval_Generate_from_CTE'

	DROP FUNCTION dbApp.f_Daily_Interval_Generate_from_CTE
END
ELSE
BEGIN
	PRINT 'Function dbApp.f_Daily_Interval_Generate_from_CTE does not exist, skipping drop'
END
GO

PRINT 'Creating function dbApp.f_Daily_Interval_Generate_from_CTE';
GO

CREATE FUNCTION dbApp.f_Daily_Interval_Generate_from_CTE (@i_Interval INT)
RETURNS @IntervalData TABLE (
	-- columns returned by the function
	StartTime INT NOT NULL
	,InvervalValue TIME NOT NULL
	)
AS
--/**
--*
--* $Filename: f_Daily_Interval_Generate_from_CTE.sql
--* $Author: Stephen R. McLarnon Sr.
--*
--* $Object: f_Daily_Interval_Generate_from_CTE
--* $ObjectType: Table-Valued function
--*
--* $Description: This function returns a table of values that are used in
--* interval reporting, specifically in call reporting. The table returned
--* has all intervals for a single day. Daily interval generation makes sense
--* only for those values that are an integral factor of 60. The smallest
--* interval is one minute.
--*
--* $Param1: @i_Inverval - The single input parameter repersents the number of
--* minutes in the interval. The intent here is to use intervals that divide
--* evenly into 60. I have not tested all other cases but it does seem to work
--* with other values.
--*
--* $OutputType: Table
--*
--* $Output1: StartTime - An integer value that is the [hours] and minutes
--* with the righmost 1 or 2 digits as the minutes (always) and, if there is a
--* third/fourth digit, the leftmost 1 or 2 are the hours.
--*
--* $Output2: InvervalValue - The time of the interval.
--* Please note that in this function, the seconds value is always '00'.
--*
--* $Note: This code wil run only in SQL Server 2005 or higher.
--*
--* $$Revisions:
--*  Ini |    Date     | Description
--* ---------------------------------
--* $End:
--**/
BEGIN
	--/**
	--* $c: The code only executes if a positive integer between 1 and 1440
	--* has been passed. 1440 is the number of minutes in a day.
	--* Any other value causes an empty table to be returned.
	--*/
	IF @i_Interval BETWEEN 1
			AND 1440
	BEGIN
			;

		WITH E1 (
			N) AS (
				SELECT 1
				
				UNION ALL
				
				SELECT 1
				
				UNION ALL
				
				SELECT 1
				
				UNION ALL
				
				SELECT 1
				
				UNION ALL
				
				SELECT 1
				
				UNION ALL
				
				SELECT 1
				
				UNION ALL
				
				SELECT 1
				)
			,-- 7 rows
			E2(N) AS (
					SELECT 1
					FROM E1 a
						,E1 b
					), -- cross join yields 49 rows or E1^2 (7*7)
				E3(N) AS (
						SELECT 1
						FROM E2 a
							,E2 b
						), -- Yields 2401 rows or E2^2 (49*49)
					Numbers(Number) AS (
						SELECT row_number() OVER (
								ORDER BY (
										SELECT NULL
										)
								)
						FROM E3
						) INSERT INTO @IntervalData SELECT cast(cast(((Number - 1) * @i_Interval / 60) AS VARCHAR(2)) + left(cast(((Number - 1) * @i_Interval % 60) AS VARCHAR(2)) + '0', 2) AS SMALLINT),
					-- This is the time as a smallint
					cast(stuff(right('00' + cast(((Number - 1) * @i_Interval) / 60 AS VARCHAR(2)), 2) + right('00' + cast(((Number - 1) * @i_Interval) % 60 AS VARCHAR(2)), 2), 3, 0, ':') + ':00' AS TIME) -- and this is a time value
					FROM Numbers WHERE Number <= (60 / @i_Interval) * 24
					AND Number > 0;END RETURN END GO
					/*
Test

select *
from dbApp.f_Daily_Interval_Generate_from_CTE (-1)

*/
					GO IF 
					EXISTS (
							SELECT *
							FROM information_schema.ROUTINES
							WHERE SPECIFIC_SCHEMA = 'dbApp'
								AND ROUTINE_NAME = 'f_Daily_Interval_Generate_from_CTE'
								AND ROUTINE_TYPE = 'Function'
							)
					BEGIN
					PRINT 'Function dbApp.f_Daily_Interval_Generate_from_CTE was created successfully'
					PRINT 'Add security assignment of select to DBApp_Processor'

					GRANT SELECT
						ON dbApp.f_Daily_Interval_Generate_from_CTE
						TO DBApp_Processor;
				END ELSE BEGIN
					PRINT 'Function dbApp.f_Daily_Interval_Generate_from_CTE does not exist, create failed'
				END PRINT '' PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36)) PRINT 'End of script file for dbApp.f_Daily_Interval_Generate_from_CTE' PRINT '----------------------------------------------------------------------' GO
					-- =============================================================================
					PRINT 'Adding file f_Calendar_One_Month.sql'
					-- =============================================================================
					-- =============================================================================
					PRINT 'Adding file f_DelimitedSplit8.sql'
					-- =============================================================================
					SET NOCOUNT ON GO PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_DelimitedSplit8' PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36)) PRINT '' IF EXISTS (
						SELECT *
						FROM information_schema.ROUTINES
						WHERE SPECIFIC_SCHEMA = 'dbApp'
							AND ROUTINE_NAME = 'f_DelimitedSplit8'
							AND ROUTINE_TYPE = 'Function'
						)
				BEGIN
					PRINT 'Dropping function dbApp.f_DelimitedSplit8'

					DROP FUNCTION dbApp.f_DelimitedSplit8
				END
				ELSE
				BEGIN
					PRINT 'Function dbApp.f_DelimitedSplit8 does not exist, skipping drop'
				END
					GO PRINT 'Creating function dbApp.f_DelimitedSplit8';GO CREATE FUNCTION dbApp.f_DelimitedSplit8
					--===== Created by Jeff Moden (Prototype: Testing Still in Progress)
					(@pString VARCHAR(8000), -- String that is to be split
						@pDelimiter CHAR(1) -- Character terminates an element
					) RETURNS TABLE
					--with SCHEMABINDING
					AS
					--/**
					--*
					--* $Filename: f_DelimitedSplit8.sql
					--* $Author: Jeff Moden
					--*
					--* $Object: f_DelimitedSplit8
					--* $ObjectType: table-valued function
					--*
					--* $Description: This function returns a table of elements that were split
					--* from the original input string. The split is based on a single character
					--* delimiter.
					--*
					--* $Param1: @pString - The string to be split.
					--* $Param2: @pDelimiter - The character that is the element separator.
					--*
					--* $OutputType: table
					--*
					--* $Output1: Item number - This is a ordinal value that is the row order.
					--* $Output2: Item_Value - This is the element that is the result of the split.
					--*
					--* $$Revisions
					--*  Ini |    Date     | Description
					--* ---------------------------------
					--* $End:
					--**/
					/*
This function returns a table of elements that were split from the original
input string.
*/
					RETURN WITH E1(N) AS (
							SELECT 1
							
							UNION ALL
							
							SELECT 1
							
							UNION ALL
							
							SELECT 1
							
							UNION ALL
							
							SELECT 1
							
							UNION ALL
							
							SELECT 1
							
							UNION ALL
							
							SELECT 1
							
							UNION ALL
							
							SELECT 1
							
							UNION ALL
							
							SELECT 1
							
							UNION ALL
							
							SELECT 1
							
							UNION ALL
							
							SELECT 1
							), --10
						E2(N) AS (
								SELECT 1
								FROM E1 a
								CROSS JOIN E1 b
								), --100
							E4(N) AS (
									SELECT 1
									FROM E2 a
									CROSS JOIN E2 b
									), --10,000
								cteTally(N) AS (
										SELECT 0
										
										UNION ALL
										
										SELECT row_number() OVER (
												ORDER BY N)
												FROM E4
												)
										SELECT ItemNumber = row_number() OVER (
												ORDER BY t.N)
													,ItemValue = substring(@pString, t.N  + 1, isnull(nullif(charindex(@pDelimiter, @pString, t.N  + 1), 0), datalength(@pString) + 1) - t.N  - 1)
												FROM cteTally t
												WHERE t.N between 0
													AND datalength(@pString)
													AND (
														substring(@pString, t.N, 1) = @pDelimiter
														OR t.N  = 0
														);GO IF 
													EXISTS (
															SELECT *
															FROM information_schema.ROUTINES
															WHERE SPECIFIC_SCHEMA = 'dbApp'
																AND ROUTINE_NAME = 'f_DelimitedSplit8'
																AND ROUTINE_TYPE = 'Function'
															)
													BEGIN
													PRINT 'Function dbApp.f_DelimitedSplit8 was created successfully'
													PRINT 'Add security assignment of select to DBApp_Processor'

													GRANT SELECT
														ON dbApp.f_DelimitedSplit8
														TO DBApp_Processor;
												END ELSE BEGIN
													PRINT 'Function dbApp.f_DelimitedSplit8 does not exist, create failed'
												END PRINT '' PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36)) PRINT 'End of script file for dbApp.f_DelimitedSplit8' PRINT '----------------------------------------------------------------------' GO
													-- =============================================================================
													PRINT 'Adding file f_DelimitedSplit8K.sql'
													-- =============================================================================
													PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_DelimitedSplit8K' PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36)) PRINT '' IF EXISTS (
														SELECT *
														FROM information_schema.ROUTINES
														WHERE SPECIFIC_SCHEMA = 'dbApp'
															AND ROUTINE_NAME = 'f_DelimitedSplit8K'
															AND ROUTINE_TYPE = 'Function'
														)
												BEGIN
													PRINT 'Dropping function dbApp.f_DelimitedSplit8K'

													DROP FUNCTION dbApp.f_DelimitedSplit8K
												END
												ELSE
												BEGIN
													PRINT 'Function dbApp.f_DelimitedSplit8K does not exist, skipping drop'
												END
													GO PRINT 'Creating function dbApp.f_DelimitedSplit8K';GO CREATE FUNCTION dbApp.f_DelimitedSplit8K(@pString VARCHAR(8000), @pDelimiter CHAR(1))
												RETURNS TABLE
												WITH SCHEMABINDING AS
													--/**
													--*
													--* $Filename: f_DelimitedSplit8K.sql
													--* $Author: Jeff Moden
													--*
													--* $Object: f_DelimitedSplit8K
													--* $ObjectType: table-valued function
													--*
													--* $Description: Yet another approach for taking a single string value
													--* that has a series of characters separated by a delimiter. The function
													--* splits the string using the delimiter character into a table of elements.
													--* The approach here is to create a table of integers that has as many rows
													--* as the string to be split. This guarantees that there will be enough
													--* elements in the table.
													--*
													--* $Param1: @pString - the string to be split.
													--* $Param2: @pDelimiter - the character used as the delimiter.
													--*
													--* $OutputType: table
													--*
													--* $Output1: Item number - This is a ordinal value that is the row order.
													--* $Output2: Item_Value - This is the element that is the result of the split.
													--*
													--* $$Revisions
													--*  Ini |    Date     | Description
													--* ---------------------------------
													--* $End:
													--**/
													RETURN
												WITH E1(N) AS (
															SELECT 1
															
															UNION ALL
															
															SELECT 1
															
															UNION ALL
															
															SELECT 1
															
															UNION ALL
															
															SELECT 1
															
															UNION ALL
															
															SELECT 1
															
															UNION ALL
															
															SELECT 1
															
															UNION ALL
															
															SELECT 1
															
															UNION ALL
															
															SELECT 1
															
															UNION ALL
															
															SELECT 1
															
															UNION ALL
															
															SELECT 1
															), --10E+1 or 10 rows
														E2(N) AS (
																SELECT 1
																FROM E1 a
																	,E1 b -- cross join yields 100 rows
																), E4(N) AS (
																	SELECT 1
																	FROM E2 a
																		,E2 b -- another cross join yields 10,000 rows
																	), cteTally(N) AS (
																		--==== This provides the "zero base" and limits the number of rows right up front
																		-- for both a performance gain and prevention of accidental "overruns"
																		SELECT 0
																		
																		UNION ALL
																		
																		SELECT TOP (datalength(isnull(@pString, 1))) row_number() OVER (
																				ORDER BY (
																						SELECT NULL
																						)
																				)
																		FROM E4
																		), cteStart(N1) AS (
																		--==== This returns N+1 (starting position of each "element" just once for each delimiter)
																		SELECT t.N  + 1
																		FROM cteTally t
																		WHERE substring(@pString, t.N, 1) = @pDelimiter --or t.N = 0
																		)
																	--select count(N1) as N1 from cteStart
																	--select count(N) as N from cteTally
																	SELECT ItemNumber = row_number() OVER (
																		ORDER BY s.N1
																		), Item = substring(@pString, s.N1, isnull(nullif(charindex(@pDelimiter, @pString, s.N1), 0) - s.N1, 8000)) FROM cteStart s;GO GO IF 
																	EXISTS (
																			SELECT *
																			FROM information_schema.ROUTINES
																			WHERE SPECIFIC_SCHEMA = 'dbApp'
																				AND ROUTINE_NAME = 'f_DelimitedSplit8K'
																				AND ROUTINE_TYPE = 'Function'
																			)
																	BEGIN
																	PRINT 'Function dbApp.f_DelimitedSplit8K was created successfully'
																	PRINT 'Add security assignment of select to DBApp_Processor'

																	GRANT SELECT
																		ON dbApp.f_DelimitedSplit8K
																		TO DBApp_Processor;
																END ELSE BEGIN
																	PRINT 'Function dbApp.f_DelimitedSplit8K does not exist, create failed'
																END PRINT '' PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36)) PRINT 'End of script file for dbApp.f_DelimitedSplit8K' PRINT '----------------------------------------------------------------------' GO
																	-- =============================================================================
																	PRINT 'Adding file f_DelimitedSplitby_Numbers.sql'
																	-- =============================================================================
																	SET NOCOUNT ON GO PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_DelimitedSplitby_Numbers' PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36)) PRINT '' IF EXISTS (
																		SELECT *
																		FROM information_schema.ROUTINES
																		WHERE SPECIFIC_SCHEMA = 'dbApp'
																			AND ROUTINE_NAME = 'f_DelimitedSplitby_Numbers'
																			AND ROUTINE_TYPE = 'Function'
																		)
																BEGIN
																	PRINT 'Dropping function dbApp.f_DelimitedSplitby_Numbers'

																	DROP FUNCTION dbApp.f_DelimitedSplitby_Numbers
																END
																ELSE
																BEGIN
																	PRINT 'Function dbApp.f_DelimitedSplitby_Numbers does not exist, skipping drop'
																END
																	GO PRINT 'Creating function dbApp.f_DelimitedSplitby_Numbers';GO CREATE FUNCTION dbApp.f_DelimitedSplitby_Numbers(@pString VARCHAR(8000), @pDelimiter CHAR(1)) RETURNS TABLE AS
																	--/**
																	--*
																	--* $Filename: f_DelimitedSplitby_Numbers.sql
																	--* $Author: Stephen R. McLarnon Sr.
																	--*
																	--* $Object: f_DelimitedSplitby_Numbers
																	--* $ObjectType: table-valued function
																	--*
																	--* $Description:  Yet another approach for taking a single string value
																	--* that has a series of characters separated by a delimiter. The function
																	--* splits the string using the delimiter character into a table of elements.
																	--*
																	--* $Param1: @pString - the string to be split.
																	--* $Param2: @pDelimiter - the character used as the delimiter.
																	--*
																	--* $OutputType: table
																	--*
																	--* $Output1: Item number - This is a ordinal value that is the row order.
																	--* $Output2: Item_Value - This is the element that is the result of the split.
																	--*
																	--* $Note: This function is dependant on a table named Numbers. The numbers
																	--* table is simply utility table that is a set of incrementing integers.
																	--*
																	--* $$Revisions
																	--*  Ini |    Date     | Description
																	--* ---------------------------------
																	--* $End:
																	--**/
																	RETURN SELECT ItemNumber = row_number() OVER (
																		ORDER BY t.Number
																		), ItemValue = substring(@pString, t.Number + 1, isnull(nullif(charindex(@pDelimiter, @pString, t.Number + 1), 0), datalength(@pString) + 1) - t.Number - 1) FROM dbApp.Numbers t WHERE t.Number BETWEEN 0
																		AND datalength(@pString)
																	AND (
																		substring(@pString, t.Number, 1) = @pDelimiter
																		OR t.Number = 0
																		);GO IF 
																	EXISTS (
																			SELECT *
																			FROM information_schema.ROUTINES
																			WHERE SPECIFIC_SCHEMA = 'dbApp'
																				AND ROUTINE_NAME = 'f_DelimitedSplitby_Numbers'
																				AND ROUTINE_TYPE = 'Function'
																			)
																	BEGIN
																	PRINT 'Function dbApp.f_DelimitedSplitby_Numbers was created successfully'
																	PRINT 'Add security assignment of select to DBApp_Processor'

																	GRANT SELECT
																		ON dbApp.f_DelimitedSplitby_Numbers
																		TO DBApp_Processor;
																END ELSE BEGIN
																	PRINT 'Function dbApp.f_DelimitedSplitby_Numbers does not exist, create failed'
																END PRINT '' PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36)) PRINT 'End of script file for dbApp.f_DelimitedSplitby_Numbers' PRINT '----------------------------------------------------------------------' GO
																	-- =============================================================================
																	PRINT 'Adding file f_Replace2Spaces.sql'
																	-- =============================================================================
																	PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_Replace2Spaces' PRINT '' IF EXISTS (
																		SELECT *
																		FROM information_schema.ROUTINES
																		WHERE SPECIFIC_SCHEMA = 'dbApp'
																			AND ROUTINE_NAME = 'f_Replace2Spaces'
																			AND ROUTINE_TYPE = 'Function'
																		)
																BEGIN
																	PRINT 'Dropping function dbApp.f_Replace2Spaces'

																	DROP FUNCTION dbApp.f_Replace2Spaces
																END
																ELSE
																BEGIN
																	PRINT 'Function dbApp.f_Replace2Spaces does not exist, skipping drop'
																END
																	GO PRINT 'Creating function dbApp.f_Replace2Spaces';GO CREATE FUNCTION dbApp.f_Replace2Spaces(@S VARCHAR(8000)) RETURNS VARCHAR(8000) AS
																	--/**
																	--*
																	--* $Filename: f_Replace2Spaces.sql
																	--* $Author: Stephen R. McLarnon Sr.
																	--*
																	--* $Object: f_Replace2Spaces
																	--* $ObjectType: Scalar function
																	--*
																	--* $Description: Takes a single string and replaces all instances of 2
																	--* or more consecutive spaces with a single space.
																	--*
																	--* $Param1: @S - input string
																	--* $Param2:
																	--*
																	--* $OutputType: varchar
																	--*
																	--* $Output1: The resultant string.
																	--*
																	--* $Note:
																	--*
																	--* $$Revisions:
																	--*  Ini |    Date     | Description
																	--* ---------------------------------
																	--* $End
																	--**/
																	/*
This function takes a single string as an argument and removes all instances
of 2 or more contigous spaces.
*/
																	BEGIN
																	RETURN replace(replace(replace(replace(replace(replace(replace(ltrim(rtrim(@s)), '                                 ', ' '), '                 ', ' '), '         ', ' '), '     ', ' '), '   ', ' '), '  ', ' '), '  ', ' ')
																END GO IF EXISTS (
																		SELECT *
																		FROM information_schema.ROUTINES
																		WHERE SPECIFIC_SCHEMA = 'dbApp'
																			AND ROUTINE_NAME = 'f_Replace2Spaces'
																			AND ROUTINE_TYPE = 'Function'
																		)
																BEGIN
																	PRINT 'Function dbApp.f_Replace2Spaces was created successfully'
																	PRINT 'Add security assignment of execute to DBApp_Processor'

																	GRANT EXECUTE
																		ON dbApp.f_Replace2Spaces
																		TO DBApp_Processor;
																END
																ELSE
																BEGIN
																	PRINT 'Function dbApp.f_Replace2Spaces does not exist, create failed'
																END
																	PRINT '' PRINT 'End of script file for dbApp.f_Replace2Spaces' PRINT '----------------------------------------------------------------------' GO
																	-- =============================================================================
																	PRINT 'Adding file f_Split_NameValue_Pair.sql'
																	-- =============================================================================
																	PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_Split_NameValue_Pair' PRINT '' IF EXISTS (
																		SELECT *
																		FROM information_schema.ROUTINES
																		WHERE SPECIFIC_SCHEMA = 'dbApp'
																			AND ROUTINE_NAME = 'f_Split_NameValue_Pair'
																			AND ROUTINE_TYPE = 'Function'
																		)
																BEGIN
																	PRINT 'Dropping function dbApp.f_Split_NameValue_Pair'

																	DROP FUNCTION dbApp.f_Split_NameValue_Pair
																END
																ELSE
																BEGIN
																	PRINT 'Function dbApp.f_Split_NameValue_Pair does not exist, skipping drop'
																END
																	GO PRINT 'Creating function dbApp.f_Split_NameValue_Pair';GO CREATE FUNCTION dbApp.f_Split_NameValue_Pair(@Str VARCHAR(8000), @DInner CHAR(1), @DOuter CHAR(1)) RETURNS TABLE WITH SCHEMABINDING AS
																	--/**
																	--*
																	--* $Filename: f_Split_NameValue_Pair.sql
																	--* $Author: Stephen R. McLarnon Sr.
																	--*
																	--* $Object: f_Split_NameValue_Pair
																	--* $ObjectType: table valued function
																	--*
																	--* $Description: Takes a list of delimited name value pairs and returens them as a table..
																	--*
																	--* $Param1: @Str - The delimited string containing the name-value pairs.
																	--* $Param2: @DOuter - The delimiter that seperates the pairs from each other
																	--* $Param3: @DInner - The value that seperates the name and the value.
																	--*
																	--* $OutputType: table
																	--*
																	--* $Output1: ItemNumber
																	--*
																	--* $Note: This function is simply an extension of the f_DelimitedSplit8K from
																	--* Jeff Moden. In this version, we made what was the final select in the
																	--* original into another CTE and used that as the basis for the final split.
																	--*
																	--* $$Revisions:
																	--*  Ini |    Date     | Description
																	--* ---------------------------------
																	--* $End
																	--**/
																	RETURN
																	--/*
																	--* $c: The first CTE, E1 gets me 10 rows as the basis for building the numbers
																	--* table
																	--*/
																	WITH E1(N) AS (
																			SELECT 1
																			
																			UNION ALL
																			
																			SELECT 1
																			
																			UNION ALL
																			
																			SELECT 1
																			
																			UNION ALL
																			
																			SELECT 1
																			
																			UNION ALL
																			
																			SELECT 1
																			
																			UNION ALL
																			
																			SELECT 1
																			
																			UNION ALL
																			
																			SELECT 1
																			
																			UNION ALL
																			
																			SELECT 1
																			
																			UNION ALL
																			
																			SELECT 1
																			
																			UNION ALL
																			
																			SELECT 1
																			),
																		--/*
																		--* $c: E2 is a self cross join of E1 to get 100 rows
																		--*/
																		E2(N) AS (
																				SELECT 1
																				FROM E1 a
																					,E1 b
																				),
																			--/*
																			--* $c: E4 is a self cross join of E2 to get 10000 rows of numbers
																			--*/
																			E4(N) AS (
																					SELECT 1
																					FROM E2 a
																						,E2 b
																					),
																				--/*
																				--* $c: cteTally provides the "zero base" and limits the number of rows right
																				--* up front for both a performance gain and prevention of accidental "overruns"
																				--*/
																				cteTally(N) AS (
																						SELECT 0
																						
																						UNION ALL
																						
																						SELECT TOP (datalength(isnull(@Str, 1))) row_number() OVER (
																								ORDER BY (
																										SELECT NULL
																										)
																								)
																						FROM E4
																						),
																					--/*
																					--* $c: This returns N + 1 (starting position of each "element" just once
																					--* for each delimiter). At this point we are ready for the split.
																					--*/
																					cteStart(N1) AS (
																						SELECT t.N  + 1
																						FROM cteTally t
																						WHERE (
																								substring(@Str, t.N, 1) = @DOuter
																								OR t.N  = 0
																								)
																						),
																					--/*
																					--* $c: Splits the string by the outer delimiter and puts name:value into a
																					--* table for further splitting.
																					--*/
																					OuterSplit(ItemNumber, ItemValue) AS (
																						SELECT ItemNumber = row_number() OVER (
																								ORDER BY s.N1
																								)
																							,Item = substring(@Str, s.N1, isnull(nullif(charindex(@DOuter, @Str, s.N1), 0) - s.N1, 8000))
																						FROM cteStart s
																						)
																					--/*
																					--* $c: Finally we use string functions to split each row on the inner delimiter.
																					--* This yields the name/value pairs as columns in the return table.
																					--*/
																					SELECT ItemNumber, left(ItemValue, charindex(@DInner, ItemValue) - 1) AS NameData, right(ItemValue, datalength(ItemValue) - charindex(@DInner, ItemValue)) AS ValueData FROM OuterSplit;GO IF 
																					EXISTS (
																							SELECT *
																							FROM information_schema.ROUTINES
																							WHERE SPECIFIC_SCHEMA = 'dbApp'
																								AND ROUTINE_NAME = 'f_Split_NameValue_Pair'
																								AND ROUTINE_TYPE = 'Function'
																							)
																					BEGIN
																					PRINT 'Function dbApp.f_Split_NameValue_Pair was created successfully'
																					PRINT 'Add security assignment of select to DBApp_Processor'

																					GRANT SELECT
																						ON dbApp.f_Split_NameValue_Pair
																						TO DBApp_Processor;
																				END ELSE BEGIN
																					PRINT 'Function dbApp.f_Split_NameValue_Pair does not exist, create failed'
																				END PRINT '' PRINT 'End of script file for dbApp.f_Split_NameValue_Pair' PRINT '----------------------------------------------------------------------' GO
																					/*
-- Test

declare	@Str	varchar(1000)
declare	@DInner char(1)
declare	@DOuter	char(1)

set @Str = 'FName:Steve,LName:McLarnon,DOB:1954-10-09,EyeColor:Hazel,Height:69,Weight:185'
set @DInner = ':'
set @DOuter = ','

select *
from dbApp.f_Split_NameValue_Pair (@Str, @DInner, @DOuter)

*/
																					-- =============================================================================
																					PRINT 'Adding file f_Start_of_Century.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_Start_of_Century' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Start_of_Century'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.f_Start_of_Century'

																					DROP FUNCTION dbApp.f_Start_of_Century
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Century does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.f_Start_of_Century';GO CREATE FUNCTION dbApp.f_Start_of_Century(@Day DATE) RETURNS DATE AS
																					/*
Function: F_START_OF_CENTURY
	Finds start of first day of century at 00:00:00.000
	for input datetime, @DAY.
	Valid for all SQL Server datetimes >= 1800-01-01 00:00:00.000
	Returns null if @DAY < 1800-01-01 00:00:00.000
*/
																					--/**
																					--*
																					--* $Filename: f_Start_of_Century.sql
																					--* $Author: Stephen R. McLarnon Sr.
																					--*
																					--* $Object: f_Start_of_Century
																					--* $ObjectType: Scalar function
																					--*
																					--* $Description: This function returns the first day of the century to which
																					--* the passed parameter belongs. Valid for all SQL Server
																					--* datetimes >= 1800-01-01 00:00:00.000 Returns null if @DAY
																					--* < 1800-01-01 00:00:00.000
																					--*
																					--* $Param1: @Day - date that is the start date.
																					--*
																					--* $OutputType: date
																					--*
																					--* $Output1: Date - the first day of the century for the year passed.
																					--*
																					--* $Note:
																					--*
																					--* $$Revisions:
																					--*  Ini |    Date     | Description
																					--* ---------------------------------
																					--* $End
																					--**/
																					BEGIN
																					DECLARE @Base_Day DATE

																					SET @Base_Day = '18000101'

																					RETURN (
																							CASE 
																								WHEN @Day < @Base_Day
																									THEN NULL
																								ELSE dateadd(yy, (datediff(yy, @Base_Day, @Day) / 100) * 100, @Base_Day)
																								END
																							)
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Start_of_Century'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Century was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.f_Start_of_Century
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Century does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.f_Start_of_Century' PRINT '----------------------------------------------------------------------' GO
																					/*
-- Test
declare	@d	date

set @d = getdate()

select dbApp.f_Start_of_Century (@d)


*/
																					-- =============================================================================
																					PRINT 'Adding file f_Start_of_Decade.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_Start_of_Decade' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Start_of_Decade'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.f_Start_of_Decade'

																					DROP FUNCTION dbApp.f_Start_of_Decade
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Decade does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.f_Start_of_Decade';GO CREATE FUNCTION dbApp.f_Start_of_Decade(@Day DATE) RETURNS DATE AS
																					--/**
																					--*
																					--* $Filename: f_Start_fo_Decade.sql
																					--* $Author: Stephen R. McLarnon Sr.
																					--*
																					--* $Object: f_Start_fo_Decade
																					--* $ObjectType: Scalar function
																					--*
																					--* $Description: Returns the first day of the decade to which the
																					--* passed date belongs..
																					--*
																					--* $Param1: @Day - The date which is the seed date.
																					--* $Param2:
																					--*
																					--* $OutputType: date
																					--*
																					--* $Output1: date
																					--*
																					--* $Note:
																					--*
																					--* $$Revisions:
																					--*  Ini |    Date     | Description
																					--* ---------------------------------
																					--* $End
																					--**/
																					/*
Function: F_START_OF_DECADE
	Finds start of first day of decade at 00:00:00.000
	for input datetime, @DAY.
	Valid for all SQL Server datetimes >= 1760-01-01 00:00:00.000
	Returns null if @DAY < 1760-01-01 00:00:00.000
*/
																					BEGIN
																					DECLARE @Base_Day DATETIME

																					SELECT @Base_Day = '17600101'

																					RETURN (
																							CASE 
																								WHEN @Day >= @Base_Day
																									THEN dateadd(yy, (datediff(yy, @Base_Day, @Day) / 10) * 10, @Base_Day)
																								ELSE NULL
																								END
																							)
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Start_of_Decade'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Decade was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.f_Start_of_Decade
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Decade does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.f_Start_of_Decade' PRINT '----------------------------------------------------------------------' GO
																					/*
-- Test
declare	@d	date

set @d = getdate()

select dbApp.f_Start_of_Decade (@d)

*/
																					-- =============================================================================
																					PRINT 'Adding file f_Start_of_Month.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_Start_of_Month' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Start_of_Month'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.f_Start_of_Month'

																					DROP FUNCTION dbApp.f_Start_of_Month
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Month does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.f_Start_of_Month';GO CREATE FUNCTION dbApp.f_Start_of_Month(@Day DATETIME) RETURNS DATETIME AS
																					--/**
																					--*
																					--* $Filename: f_Start_of_Month.sql
																					--* $Author: Stephen R. McLarnon Sr.
																					--* $Created: 6/30/2011 7:56:01 AM
																					--*
																					--* $Object: f_Start_of_Month
																					--* $ObjectType: Scalar Function
																					--*
																					--* $Description:   Finds start of first day of month at 00:00:00.000
																					--*	                for input datetime, @DAY.
																					--*	                Valid for all SQL Server datetimes.
																					--*
																					--* $Params:
																					--* Name                | Datatype   | Description
																					--* ----------------------------------------------------------------------------
																					--* @Day                 datetime     The day for which we to determine the
																					--*                                   month start date
																					--* $Output
																					--* ----------------------------------------------------------------------------
																					--* First day of month      datetime
																					--*
																					--* $$Revisions:
																					--*  Ini |    Date     | Description
																					--* ---------------------------------
																					--* $End
																					--**/
																					BEGIN
																					RETURN dateadd(mm, datediff(mm, 0, @Day), 0)
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Start_of_Month'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Month was created successfully'
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Month does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.f_Start_of_Month' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file f_Start_of_Quarter.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_Start_of_Quarter' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Start_of_Quarter'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.f_Start_of_Quarter'

																					DROP FUNCTION dbApp.f_Start_of_Quarter
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Quarter does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.f_Start_of_Quarter';GO CREATE FUNCTION dbApp.f_Start_of_Quarter(@Day DATETIME) RETURNS DATETIME AS
																					--/**
																					--*
																					--* $Filename: f_Start_of_Quarter.sql
																					--* $Author: Stephen R. McLarnon Sr.
																					--* $Created: 6/30/2011 8:04:32 AM
																					--*
																					--* $Object: f_Start_of_Quarter
																					--* $ObjectType: Scalar function
																					--*
																					--* $Description:   Finds start of first day of quarter at 00:00:00.000
																					--*	                for input datetime, @DAY.
																					--*	                Valid for all SQL Server datetimes.
																					--*
																					--* $Params:
																					--* Name                | Datatype   | Description
																					--* ----------------------------------------------------------------------------
																					--* @Day
																					--*
																					--* $OutputParams:
																					--* ----------------------------------------------------------------------------
																					--* First day of quarter  datetime
																					--*
																					--* $$Revisions:
																					--*  Ini |    Date     | Description
																					--* ---------------------------------
																					--* $End
																					--**/
																					BEGIN
																					RETURN dateadd(qq, datediff(qq, 0, @Day), 0)
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Start_of_Quarter'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Quarter was created successfully'
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Start_of_Quarter does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.f_Start_of_Quarter' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file f_Start_Of_Year.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_Start_Of_Year' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Start_Of_Year'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.f_Start_Of_Year'

																					DROP FUNCTION dbApp.f_Start_Of_Year
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Start_Of_Year does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.f_Start_Of_Year';GO CREATE FUNCTION dbApp.f_Start_Of_Year(@Day DATETIME) RETURNS DATETIME AS
																					--/**
																					--*
																					--* $Filename: f_Start_Of_Year.sql
																					--* $Author: Stephen R. McLarnon Sr.
																					--*
																					--* $Object: f_Start_Of_Year
																					--* $ObjectType: Scalar function
																					--*
																					--* $Description:   Finds start of first day of year at 00:00:00.000
																					--*	                for input datetime, @DAY.
																					--*	                Valid for all SQL Server datetimes.
																					--*
																					--* $Param1: @Day - The date for which we wish to get the first day of the year.
																					--*
																					--* $OutputType: datetime
																					--*
																					--* $Output1: datetime
																					--*
																					--* $$Revisions:
																					--*  Ini |    Date     | Description
																					--* ---------------------------------
																					--* $End
																					--**/
																					BEGIN
																					RETURN dateadd(yy, datediff(yy, 0, @Day), 0)
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Start_Of_Year'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.f_Start_Of_Year was created successfully'
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Start_Of_Year does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.f_Start_Of_Year' PRINT '----------------------------------------------------------------------' GO
																					/*
-- Test
declare	@d	date

set @d = getdate()

select dbApp.f_Start_Of_Year (@d)

*/
																					-- =============================================================================
																					PRINT 'Adding file f_String_Get_Right_of_Three.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_String_Get_Right_of_Three' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_String_Get_Right_of_Three'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.f_String_Get_Right_of_Three'

																					DROP FUNCTION dbApp.f_String_Get_Right_of_Three
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_String_Get_Right_of_Three does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.f_String_Get_Right_of_Three';GO CREATE FUNCTION dbApp.f_String_Get_Right_of_Three(@i_Str VARCHAR(8000)) RETURNS VARCHAR(8000) AS
																					-- =pod
																					/**

$Filename   : f_String_Get_Right_of_Three.sql
$Author     : Stephen R. McLarnon Sr.
$Created    : 9/13/2011 9:46:50 AM

$Object: dbApp.f_String_Get_Right_of_Three
$ObjectType : Scalar valued function

$Description: Returns the part of a string after the third comma..

$Params:
Name                    | Datatype      | Description
----------------------------------------------------------------------------
@i_Str varchar(8000)    varchar(8000)   The string to be parsed

$Note:

$Revisions:
  Ini |    Date     | Description
---------------------------------
$End
*/
																					-- =cut
																					BEGIN
																					RETURN right(@i_Str, charindex(',', reverse(@i_Str), 1) - 1);
																				END GO GO IF 
																					EXISTS (
																							SELECT *
																							FROM information_schema.ROUTINES
																							WHERE SPECIFIC_SCHEMA = 'dbApp'
																								AND ROUTINE_NAME = 'f_String_Get_Right_of_Three'
																								AND ROUTINE_TYPE = 'Function'
																							)
																					BEGIN
																					PRINT 'Function dbApp.f_String_Get_Right_of_Three was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.f_String_Get_Right_of_Three
																						TO DBApp_Processor;
																				END ELSE BEGIN
																					PRINT 'Function dbApp.f_String_Get_Right_of_Three does not exist, create failed'
																				END PRINT '' PRINT 'End of script file for dbApp.f_String_Get_Right_of_Three' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file f_Work_Get_Next.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_Work_Get_Next' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Work_Get_Next'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.f_Work_Get_Next'

																					DROP FUNCTION dbApp.f_Work_Get_Next
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Work_Get_Next does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.f_Work_Get_Next';GO CREATE FUNCTION dbApp.f_Work_Get_Next(@i_Today DATETIME) RETURNS INT AS
																					--/**
																					--*
																					--* $Filename: f_Work_Get_Next.sql
																					--* $Author: Stephen R. McLarnon Sr.
																					--*
																					--* $Object: f_Work_Get_Next
																					--* $ObjectType: Scalar function
																					--*
																					--* $Description: This function returns the earliest Work_Id (lowest value)
																					--* where the work status is ready and the job status is ready and the
																					--* scheduled start time has passed.
																					--*
																					--* $Param1: @i_Today - current datetime
																					--*
																					--* $OutputType: int
																					--*
																					--* $Output1: @OutValue - the next work Id
																					--*
																					--* $Note:
																					--*
																					--* $$Revisions:
																					--*  Ini |    Date     | Description
																					--* ---------------------------------
																					--* $End
																					--**/
																					/*
This function returns the earliest Work_Id (lowest value) where the work status
is ready and the job status is ready and the scheduled start time has passed.
*/
																					BEGIN
																					DECLARE @OutValue INT

																					SET @OutValue = (
																							SELECT TOP 1 DBWork_Id
																							FROM dbApp.DBWork w
																							INNER JOIN dbApp.Batch b ON b.Batch_Id = w.Batch_Id
																							INNER JOIN dbApp.Batch_Status_Type bst ON bst.Batch_Status_Type_Id = b.Batch_Status_Type_Id
																							INNER JOIN dbApp.Work_Status_Type wst ON wst.Work_Status_Type_Id = w.Work_Status_Type_Id
																							WHERE bst.Batch_Status_Type_Cd = 'Ready'
																								AND wst.Work_Status_Type_Cd = 'Ready'
																								AND w.Scheduled_Run_Dtm < @i_Today
																							ORDER BY w.Scheduled_Run_Dtm
																								,w.DBWork_Id
																							)

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Work_Get_Next'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.f_Work_Get_Next was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.f_Work_Get_Next
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Work_Get_Next does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.f_Work_Get_Next' PRINT '----------------------------------------------------------------------' GO
																					/*
<FuncTest>
declare	@In		varchar(10)
declare	@Out		int
set @In =
set @Out = dbApp.f_Work_Get_Next (@In)
select @Out
</FuncTest>
<Todo>
</Todo>
<Log>

</Log>
*/
																					-- =============================================================================
																					PRINT 'Adding file f_Work_Get_Ready_Count.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_Work_Get_Ready_Count' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Work_Get_Ready_Count'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.f_Work_Get_Ready_Count'

																					DROP FUNCTION dbApp.f_Work_Get_Ready_Count
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Work_Get_Ready_Count does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.f_Work_Get_Ready_Count';GO CREATE FUNCTION dbApp.f_Work_Get_Ready_Count(@i_CurrentDate DATETIME) RETURNS INT AS
																					--/**
																					--*
																					--* $Filename: f_Work_Get_Ready_Count.sql
																					--* $Author: Stephen R. McLarnon Sr.
																					--*
																					--* $Object: f_Work_Get_Ready_Count
																					--* $ObjectType: Scalar function
																					--*
																					--* $Description: Returns the count of work rows where the status is ready,
																					--* and the job status is ready.
																					--*
																					--* $Param1: @i_CurrentDate - The current date and time
																					--* $Param2:
																					--*
																					--* $OutputType: int
																					--*
																					--* $Output1: The number of work items ready to be processed.
																					--*
																					--* $Note:
																					--*
																					--* $$Revisions:
																					--*  Ini |    Date     | Description
																					--* ---------------------------------
																					--* $End
																					--**/
																					/*
Returns the count of work rows where the status is ready, and the
job status is ready.
*/
																					BEGIN
																					-- all declarations should be placed here
																					DECLARE @OutValue INT

																					SELECT @OutValue = count(*)
																					FROM dbApp.DBWork w
																					INNER JOIN dbApp.Batch b ON b.Batch_Id = w.Batch_Id
																					INNER JOIN dbApp.Work_Status_Type wst ON wst.Work_Status_Type_Id = w.Work_Status_Type_Id
																					INNER JOIN dbApp.Batch_Status_Type bst ON bst.Batch_Status_Type_Id = b.Batch_Status_Type_Id
																					WHERE bst.Batch_Status_Type_Cd = 'Ready'
																						AND wst.Work_Status_Type_Cd = 'Ready'

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Work_Get_Ready_Count'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.f_Work_Get_Ready_Count was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.f_Work_Get_Ready_Count
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Work_Get_Ready_Count does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.f_Work_Get_Ready_Count' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file f_Work_Status_Type_Id_Get.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_Work_Status_Type_Id_Get' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Work_Status_Type_Id_Get'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.f_Work_Status_Type_Id_Get'

																					DROP FUNCTION dbApp.f_Work_Status_Type_Id_Get
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Work_Status_Type_Id_Get does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.f_Work_Status_Type_Id_Get';GO CREATE FUNCTION dbApp.f_Work_Status_Type_Id_Get(@i_StatusCode VARCHAR(50)) RETURNS INT AS
																					--/**
																					--*
																					--* $Filename: f_Work_Status_Type_Id_Get.sql
																					--* $Author: Stephen R. McLarnon Sr.
																					--*
																					--* $Object: f_Work_Status_Type_Id_Get
																					--* $ObjectType: Scalar function
																					--*
																					--* $Description: Returns the Work_Status_Type_Id for the work status type
																					--* code passed as the single parameter.
																					--*
																					--* $Param1: @i_StatusCode -  The natural key of the status code in question.
																					--* $Param2:
																					--*
																					--* $OutputType: int
																					--*
																					--* $Output1: The Id of the work status code passed.
																					--*
																					--* $Note:
																					--*
																					--* $$Revisions:
																					--*  Ini |    Date     | Description
																					--* ---------------------------------
																					--* $End
																					--**/
																					/*
Returns the Work_Status_Type_Id for the work status type code passed
as the single parameter.
*/
																					BEGIN
																					DECLARE @OutValue INT

																					SELECT @OutValue = Work_Status_Type_Id
																					FROM dbApp.Work_Status_Type
																					WHERE Work_Status_Type_Cd = @i_StatusCode

																					IF @@Error <> 0
																					BEGIN
																						SET @OutValue = NULL
																					END

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_Work_Status_Type_Id_Get'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.f_Work_Status_Type_Id_Get was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.f_Work_Status_Type_Id_Get
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_Work_Status_Type_Id_Get does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.f_Work_Status_Type_Id_Get' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Compute.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Compute' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Compute'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Compute'

																					DROP FUNCTION dbApp.fn_Compute
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Compute does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Compute';GO CREATE FUNCTION dbApp.fn_Compute(@LParm NUMERIC(16, 6), @RParm NUMERIC(16, 6), @Op CHAR) RETURNS NUMERIC(16, 6) AS
																					/*

*/
																					BEGIN
																					RETURN (
																							CASE @Op
																								WHEN '+'
																									THEN @LParm + @RParm
																								WHEN '-'
																									THEN @LParm - @RParm
																								WHEN '*'
																									THEN @LParm * @RParm
																								WHEN '/'
																									THEN CASE 
																											WHEN @RParm = 0
																												THEN NULL
																											ELSE @LParm / @RParm
																											END
																								WHEN '%'
																									THEN CASE 
																											WHEN @RParm = 0
																												THEN NULL
																											ELSE cast(@LParm AS INT) % cast(@RParm AS INT)
																											END
																								WHEN '^'
																									THEN power(@lParm, cast(@RParm AS INT))
																								ELSE NULL
																								END
																							)
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Compute'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Compute was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Compute
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Compute does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Compute' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_CountStringOccurances.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_CountStringOccurances' PRINT '' IF EXISTS (
																						SELECT *
																						FROM sys.objects
																						WHERE object_id = object_id(N'dbApp.fn_CountStringOccurances')
																							AND type IN (
																								N'FN'
																								,N'IF'
																								,N'TF'
																								,N'FS'
																								,N'FT'
																								)
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_CountStringOccurances';

																					DROP FUNCTION dbApp.fn_CountStringOccurances;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_CountStringOccurances does not exist, skipping drop';
																				END
																					GO PRINT 'Creating function dbApp.fn_CountStringOccurances';GO CREATE FUNCTION dbApp.fn_CountStringOccurances --<FuncParams>
																					(@i_string VARCHAR(8000), @i_separator VARCHAR(4)) RETURNS INT AS BEGIN
																					DECLARE @Occurances INT

																					SET @Occurances = (datalength(replace(@i_string, @i_separator, @i_separator + '#')) - datalength(@i_string))

																					RETURN @Occurances
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_CountStringOccurances'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_CountStringOccurances was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_CountStringOccurances
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_CountStringOccurances does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_CountStringOccurances' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_EmailAddressString_Build.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_EmailAddressString_Build' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_EmailAddressString_Build'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_EmailAddressString_Build'

																					DROP FUNCTION dbApp.fn_EmailAddressString_Build
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_EmailAddressString_Build does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_EmailAddressString_Build';GO CREATE FUNCTION dbApp.fn_EmailAddressString_Build --<FuncParams>
																					(@i_Email_List VARCHAR(128))
																					--</FuncParams>
																					RETURNS VARCHAR(1000) AS BEGIN
																					-- all declarations should be placed here
																					DECLARE @OutValue VARCHAR(1000)

																					SELECT @OutValue = coalesce(@OutValue + CASE 
																								WHEN @OutValue = ''
																									THEN ''
																								ELSE ';'
																								END, '') + ea.Email_Address
																					FROM dbApp.Email_Address ea
																					INNER JOIN dbApp.Email_Group_Member elm ON elm.Email_Address_Id = ea.Email_Address_Id
																					INNER JOIN dbApp.Email_Group el ON el.Email_Group_Id = elm.Email_Group_Id
																					WHERE el.Email_Group_Cd = @i_Email_List
																						AND ea.Active_Fl = 1
																						AND elm.Active_Fl = 1
																					ORDER BY ea.Sort_Ord
																						,ea.eMail_Address_Cd

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_EmailAddressString_Build'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_EmailAddressString_Build was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_EmailAddressString_Build
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_EmailAddressString_Build does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_EmailAddressString_Build' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Get_File_Extension.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Get_File_Extension' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Get_File_Extension'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Get_File_Extension'

																					DROP FUNCTION dbApp.fn_Get_File_Extension
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_File_Extension does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Get_File_Extension';GO CREATE FUNCTION dbApp.fn_Get_File_Extension --<FuncParams>
																					(@i_Filename VARCHAR(255)) RETURNS VARCHAR(50) AS BEGIN
																					RETURN (right(@i_Filename, charindex('.', reverse(@i_Filename)) - 1))
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Get_File_Extension'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_File_Extension was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Get_File_Extension
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_File_Extension does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Get_File_Extension' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Get_File_Name_no_Extension.sq'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Get_File_Name_no_Extension' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Get_File_Name_no_Extension'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Get_File_Name_no_Extension'

																					DROP FUNCTION dbApp.fn_Get_File_Name_no_Extension
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_File_Name_no_Extension does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Get_File_Name_no_Extension';GO CREATE FUNCTION dbApp.fn_Get_File_Name_no_Extension --<FuncParams>
																					(@i_Filename VARCHAR(255)) RETURNS VARCHAR(255) AS BEGIN
																					RETURN (left(@i_Filename, datalength(@i_Filename) - charindex('.', reverse(@i_Filename))))
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Get_File_Name_no_Extension'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_File_Name_no_Extension was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Get_File_Name_no_Extension
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_File_Name_no_Extension does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Get_File_Name_no_Extension' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Get_Filename_from_Full_Path.s'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Get_Filename_from_Full_Path' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Get_Filename_from_Full_Path'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Get_Filename_from_Full_Path'

																					DROP FUNCTION dbApp.fn_Get_Filename_from_Full_Path
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_Filename_from_Full_Path does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Get_Filename_from_Full_Path';GO CREATE FUNCTION dbApp.fn_Get_Filename_from_Full_Path --<FuncParams>
																					(@i_Path VARCHAR(8000)) RETURNS VARCHAR(8000) AS BEGIN
																					RETURN (right(@i_Path, charindex('\', reverse(@i_Path)) - 1))
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Get_Filename_from_Full_Path'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_Filename_from_Full_Path was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Get_Filename_from_Full_Path
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_Filename_from_Full_Path does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Get_Filename_from_Full_Path' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Get_Operator_Precedence.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Get_Operator_Precedence' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Get_Operator_Precedence'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Get_Operator_Precedence'

																					DROP FUNCTION dbApp.fn_Get_Operator_Precedence
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_Operator_Precedence does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Get_Operator_Precedence';GO CREATE FUNCTION dbApp.fn_Get_Operator_Precedence --<FuncParams>
																					(@i_Operator VARCHAR(30)) RETURNS TINYINT AS BEGIN
																					DECLARE @OutValue TINYINT

																					SET @OutValue = NULL

																					SELECT @OutValue = Precedence
																					FROM dbApp.Operator
																					WHERE Operator_Cd = @i_Operator

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Get_Operator_Precedence'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_Operator_Precedence was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Get_Operator_Precedence
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Get_Operator_Precedence does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Get_Operator_Precedence' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Get_Rule_Value_by_Name.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Get_Rule_Value_by_Name' IF EXISTS (
																						SELECT *
																						FROM sys.objects
																						WHERE object_id = object_id(N'dbApp.fn_Get_Rule_Value_by_Name')
																							AND type IN (
																								N'FN'
																								,N'IF'
																								,N'TF'
																								,N'FS'
																								,N'FT'
																								)
																						)
																				BEGIN
																					PRINT '    Dropping function dbApp.fn_Get_Rule_Value_by_Name';

																					DROP FUNCTION dbApp.fn_Get_Rule_Value_by_Name;
																				END
																				ELSE
																				BEGIN
																					PRINT '    Function dbApp.fn_Get_Rule_Value_by_Name does not exist, skipping drop';
																				END
																					GO PRINT '    Creating function dbApp.fn_Get_Rule_Value_by_Name';GO CREATE FUNCTION dbApp.fn_Get_Rule_Value_by_Name --<FuncParams>
																					(@i_RuleName VARCHAR(100)) RETURNS VARCHAR(2500) AS BEGIN
																					-- all declarations should be placed here
																					DECLARE @OutValue VARCHAR(2500)

																					-- all initializations should be placed here
																					SELECT @OutValue = Truth_Value
																					FROM dbApp.t_Rule
																					WHERE Rule_name = @i_RuleName

																					RETURN @OutValue
																				END GO PRINT '    Add security assignment of select to DBApp_Processor' GRANT EXECUTE
																					ON dbApp.fn_Get_Rule_Value_by_Name
																					TO DBApp_Processor;GO PRINT 'End of script file for dbApp.fn_Get_Rule_Value_by_Name' PRINT '------------------------------------------------------------'
																					-- =============================================================================
																					PRINT 'Adding file fn_IsISINValid.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_IsISINValid' PRINT '' IF 
																					EXISTS (
																							SELECT *
																							FROM information_schema.ROUTINES
																							WHERE SPECIFIC_SCHEMA = 'dbApp'
																								AND ROUTINE_NAME = 'fn_IsISINValid'
																								AND ROUTINE_TYPE = 'Function'
																							)
																					BEGIN
																					PRINT 'Dropping function dbApp.fn_IsISINValid'

																					DROP FUNCTION dbApp.fn_IsISINValid
																				END ELSE BEGIN
																					PRINT 'Function dbApp.fn_IsISINValid does not exist, skipping drop'
																				END GO PRINT 'Creating function dbApp.fn_IsISINValid';GO
																					-- ================================================
																					SET ANSI_NULLS ON GO SET QUOTED_IDENTIFIER ON GO
																					-- =============================================
																					-- Author:      Pang Chong Peng
																					-- Create date: 20/7/2010
																					-- Description: CheckSum for ISIN code
																					-- =============================================
																					CREATE FUNCTION dbApp.fn_IsISINValid(@ISINCode AS NVARCHAR(20)) RETURNS BIT AS BEGIN
																					DECLARE @i AS INT;
																					DECLARE @iTotalScore AS INT;
																					DECLARE @s AS INT;
																					DECLARE @sDigit AS VARCHAR(22);/* Edit 101004 csouto: Needs to be 22 characters long so it can validate Isin Codes for 'Lotes Padro' */

																					SELECT @ISINCode = upper(@ISINCode);

																					IF len(@ISINCode) != 12
																						RETURN 0;

																					IF ascii(substring(@ISINCode, 1, 1)) < ascii('A')
																						OR ascii(substring(@ISINCode, 1, 1)) > ascii('Z')
																						RETURN 0;

																					IF ascii(substring(@ISINCode, 2, 1)) < ascii('A')
																						OR ascii(substring(@ISINCode, 2, 1)) > ascii('Z')
																						RETURN 0;

																					IF (isnumeric(substring(@ISINCode, 12, 1)) = 0) -- Check that the checksum is numeric
																						RETURN 0;

																					SELECT @sDigit = '';

																					SELECT @i = 1;

																					WHILE (@i <= 11)
																					BEGIN
																						SELECT @s = ascii(substring(@ISINCode, @i, 1))

																						IF @s >= ascii('0')
																							AND @s <= ascii('9')
																							SELECT @sDigit = @sDigit + substring(@ISINCode, @i, 1);
																						ELSE
																							IF @s >= ascii('A')
																								AND @s <= ascii('Z')
																								SELECT @sDigit = @sDigit + convert(VARCHAR(2), @s - 55);
																							ELSE
																								BREAK;

																						SELECT @i = @i + 1;
																					END

																					SELECT @sDigit = reverse(@sDigit);

																					SELECT @iTotalScore = 0;

																					SELECT @i = 1;

																					WHILE (@i <= len(@sDigit))
																					BEGIN
																						SELECT @iTotalScore = @iTotalScore + convert(INT, substring(@sDigit, @i, 1))

																						IF @i % 2 = 1
																						BEGIN
																							SELECT @iTotalScore = @iTotalScore + convert(INT, substring(@sDigit, @i, 1))

																							IF convert(INT, (substring(@sDigit, @i, 1))) > 4
																							BEGIN
																								SELECT @iTotalScore = @iTotalScore - 9;
																							END
																						END

																						SELECT @i = @i + 1;
																					END

																					IF (10 - (@iTotalScore % 10)) % 10 = convert(INT, (substring(@ISINCode, 12, 1)))
																						RETURN 1;

																					RETURN 0;
																				END GO IF 
																					EXISTS (
																							SELECT *
																							FROM information_schema.ROUTINES
																							WHERE SPECIFIC_SCHEMA = 'dbApp'
																								AND ROUTINE_NAME = 'fn_IsISINValid'
																								AND ROUTINE_TYPE = 'Function'
																							)
																					BEGIN
																					PRINT 'Function dbApp.fn_IsISINValid was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_IsISINValid
																						TO DBApp_Processor;
																				END ELSE BEGIN
																					PRINT 'Function dbApp.fn_IsISINValid does not exist, create failed'
																				END PRINT '' PRINT 'End of script file for dbApp.fn_IsISINValid' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_isLegal_Expr_Character.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_isLegal_Expr_Character' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_isLegal_Expr_Character'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_isLegal_Expr_Character'

																					DROP FUNCTION dbApp.fn_isLegal_Expr_Character
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_isLegal_Expr_Character does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_isLegal_Expr_Character';GO CREATE FUNCTION dbApp.fn_isLegal_Expr_Character --<FuncParams>
																					(@i_TestChar CHAR(1)) RETURNS TINYINT AS BEGIN
																					DECLARE @OutValue TINYINT

																					SET @Outvalue = 0

																					IF (
																							@i_TestChar IN (
																								'@'
																								,'_'
																								,'~'
																								)
																							OR upper(@i_TestChar) BETWEEN 'A'
																								AND 'Z'
																							OR @i_TestChar IN (
																								'1'
																								,'2'
																								,'3'
																								,'4'
																								,'5'
																								,'6'
																								,'7'
																								,'8'
																								,'9'
																								,'0'
																								,'.'
																								,','
																								,'-'
																								,'+'
																								)
																							)
																						SET @Outvalue = 1

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_isLegal_Expr_Character'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_isLegal_Expr_Character was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_isLegal_Expr_Character
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_isLegal_Expr_Character does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_isLegal_Expr_Character' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_isLegal_Oper_Character.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_isLegal_Oper_Character' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_isLegal_Oper_Character'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_isLegal_Oper_Character'

																					DROP FUNCTION dbApp.fn_isLegal_Oper_Character
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_isLegal_Oper_Character does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_isLegal_Oper_Character';GO CREATE FUNCTION dbApp.fn_isLegal_Oper_Character --<FuncParams>
																					(@i_testchar CHAR(1)) RETURNS TINYINT AS BEGIN
																					DECLARE @OutValue TINYINT

																					SET @OutValue = 0

																					IF @i_TestChar IN (
																							'%'
																							,'*'
																							,'+'
																							,'-'
																							,':'
																							,'='
																							,'\'
																							,'<'
																							,'?'
																							,'^'
																							,'&'
																							,'!'
																							,'>'
																							,'['
																							,'{'
																							,'|'
																							,']'
																							,'}'
																							)
																					BEGIN
																						SET @Outvalue = 1
																					END

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_isLegal_Oper_Character'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_isLegal_Oper_Character was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_isLegal_Oper_Character
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_isLegal_Oper_Character does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_isLegal_Oper_Character' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_isNumber.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_isNumber' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_isNumber'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_isNumber'

																					DROP FUNCTION dbApp.fn_isNumber
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_isNumber does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_isNumber';GO CREATE FUNCTION dbApp.fn_isNumber --<FuncParams>
																					(@i_InValue VARCHAR(8000)) RETURNS TINYINT AS BEGIN
																					DECLARE @OutValue TINYINT

																					SET @OutValue = 0

																					IF (isnumeric(replace(@i_Invalue, ',', '-'))) = 1
																						SET @Outvalue = 1

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_isNumber'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_isNumber was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_isNumber
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_isNumber does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_isNumber' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_isNumbers_with_Comma.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_isNumbers_with_Comma' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_isNumbers_with_Comma'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_isNumbers_with_Comma'

																					DROP FUNCTION dbApp.fn_isNumbers_with_Comma
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_isNumbers_with_Comma does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_isNumbers_with_Comma';GO CREATE FUNCTION dbApp.fn_isNumbers_with_Comma --<FuncParams>
																					(@i_InValue VARCHAR(8000))
																					--</FuncParams>
																					RETURNS TINYINT AS BEGIN
																					-- all declarations should be placed here
																					DECLARE @OutValue TINYINT

																					SET @OutValue = 0

																					IF isnumeric(replace(@i_Invalue, ',', '-')) = 0
																						AND isnumeric(replace(@i_Invalue, ',', '0')) = 1
																						SET @Outvalue = 1

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_isNumbers_with_Comma'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_isNumbers_with_Comma was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_isNumbers_with_Comma
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_isNumbers_with_Comma does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_isNumbers_with_Comma' PRINT '----------------------------------------------------------------------' GO
																					/*
declare	@In		varchar(10)
declare	@Out		int
set @In =
set @Out = dbApp.fn_isNumbers_with_Comma (@In)
select @Out
*/
																					-- =============================================================================
																					PRINT 'Adding file fn_Name_Value_Pair_Get_Name.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Name_Value_Pair_Get_Name' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Name_Value_Pair_Get_Name'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Name_Value_Pair_Get_Name'

																					DROP FUNCTION dbApp.fn_Name_Value_Pair_Get_Name
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Name_Value_Pair_Get_Name does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Name_Value_Pair_Get_Name';GO CREATE FUNCTION dbApp.fn_Name_Value_Pair_Get_Name(@i_InputString VARCHAR(1000)) RETURNS VARCHAR(1000) AS BEGIN
																					DECLARE @OutValue VARCHAR(1000)
																					DECLARE @P INT

																					SET @p = charindex('=', @i_InputString, 1)
																					SET @OutValue = left(@i_InputString, @P - 1)

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Name_Value_Pair_Get_Name'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Name_Value_Pair_Get_Name was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Name_Value_Pair_Get_Name
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Name_Value_Pair_Get_Name does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Name_Value_Pair_Get_Name' PRINT '----------------------------------------------------------------------' GO
																					/*

declare		@v		varchar(1000)
set @v = 'CallerIdName=RMH'
select dbApp.fn_Name_Value_Pair_Get_name (@v)

*/
																					-- =============================================================================
																					PRINT 'Adding file fn_Name_Value_Pair_get_Value.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Name_Value_Pair_get_Value' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Name_Value_Pair_get_Value'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Name_Value_Pair_get_Value'

																					DROP FUNCTION dbApp.fn_Name_Value_Pair_get_Value
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Name_Value_Pair_get_Value does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Name_Value_Pair_get_Value';GO CREATE FUNCTION dbApp.fn_Name_Value_Pair_get_Value(@i_InputString VARCHAR(1000)) RETURNS VARCHAR(1000) AS BEGIN
																					DECLARE @OutValue VARCHAR(1000)
																					DECLARE @P INT

																					SET @p = charindex('=', @i_InputString, 1)
																					SET @OutValue = right(@i_InputString, datalength(@i_InputString) - @p)

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Name_Value_Pair_get_Value'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Name_Value_Pair_get_Value was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Name_Value_Pair_get_Value
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Name_Value_Pair_get_Value does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Name_Value_Pair_get_Value' PRINT '----------------------------------------------------------------------' GO
																					/*
<FuncTest>
select fn_Name_Value_Pair_get_Value
</FuncTest>
<Todo>
</Todo>
<Log>
</Log>
*/
																					-- =============================================================================
																					PRINT 'Adding file fn_Numeric_to_Base_n.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Numeric_To_Base_n' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Numeric_To_Base_n'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Numeric_To_Base_n'

																					DROP FUNCTION dbApp.fn_Numeric_To_Base_n
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Numeric_To_Base_n does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Numeric_To_Base_n';GO CREATE FUNCTION dbApp.fn_Numeric_To_Base_n(@Number DECIMAL(32, 0), @Base INT) RETURNS VARCHAR(110) AS
																					/*
Function: F_NUMERIC_TO_BASE_N

	Function F_NUMERIC_TO_BASE_N converts a numeric(32,0) value, @Number,
	to a string of digits in number base @Base,
	where @Base is between 2 and 36.

	Output digits greater than 9 are represented by
	uppercase letters A through Z, where A = 10 through Z = 35.

	If input parameter @Number is negative, the output string
	will have a minus sign in the leftmost position.

	Any non-null numeric(32,0) value for parameter @Number is valid:
	-99999999999999999999999999999999 through
	 99999999999999999999999999999999.

	If input parameters @Number or @Base are null,
	or @Base is not between 2 and 36,
	then the function returns a null value.
*/
																					BEGIN
																					DECLARE @Work_Number NUMERIC(38, 0)
																					DECLARE @Modulus INT
																					DECLARE @Digits VARCHAR(36)
																					DECLARE @Output_String VARCHAR(110)

																					IF @Number IS NULL
																						OR @Base IS NULL
																						OR @Base < 2
																						OR @Base > 36
																					BEGIN
																						RETURN NULL
																					END

																					SET @Digits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
																					SET @Output_String = ''
																					SET @Work_Number = @Number

																					WHILE 1 = 1
																					BEGIN
																						SET @Modulus = convert(INT, abs(@Work_Number - (round(@Work_Number / @Base, 0, 1) * @Base)))
																						SET @Output_String = substring(@Digits, @Modulus + 1, 1) + @Output_String
																						SET @Work_Number = round(@Work_Number / @Base, 0, 1)

																						IF @Work_Number = 0
																							BREAK
																					END -- end while

																					IF @Number < 0
																						SET @Output_String = '-' + @Output_String

																					RETURN @Output_String
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Numeric_To_Base_n'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Numeric_To_Base_n was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Numeric_To_Base_n
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Numeric_To_Base_n does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Numeric_To_Base_n' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Resolve_Substring.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Resolve_Substring' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Resolve_Substring'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Resolve_Substring'

																					DROP FUNCTION dbApp.fn_Resolve_Substring
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Resolve_Substring does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Resolve_Substring';GO CREATE FUNCTION dbApp.fn_Resolve_Substring --<FuncParams>
																					(@i_PList VARCHAR(100)) RETURNS VARCHAR(100) AS BEGIN
																					DECLARE @OutValue VARCHAR(100)
																					DECLARE @Operand VARCHAR(100)
																					DECLARE @P1 INT
																					DECLARE @P2 INT
																					DECLARE @t TABLE (
																						RowId INT identity(1, 1)
																						,Data VARCHAR(100)
																						)

																					-- all initializations should be placed here
																					SET @OutValue = ''

																					INSERT INTO @t
																					SELECT StrVal
																					FROM dbApp.fn_Split(@i_Plist, ',')

																					SELECT @Operand = Data
																					FROM @t
																					WHERE RowId = 1

																					SELECT @P1 = cast(Data AS INT)
																					FROM @t
																					WHERE RowId = 2

																					SELECT @P2 = cast(Data AS INT)
																					FROM @t
																					WHERE RowId = 3

																					SET @OutValue = substring(@Operand, @P1, @P2)

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Resolve_Substring'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Resolve_Substring was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Resolve_Substring
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Resolve_Substring does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Resolve_Substring' PRINT '----------------------------------------------------------------------' GO
																					/*
<FuncTest>
declare		@v		varchar(100)
set @v = 'gefaactc,6,2'

select dbApp.fn_Resolve_Substring (@v)
</FuncTest>
<Todo>
</Todo>
<Log>
</Log>
*/
																					-- =============================================================================
																					PRINT 'Adding file fn_Split.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Split' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Split'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Split'

																					DROP FUNCTION dbApp.fn_Split
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Split does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Split';GO CREATE FUNCTION dbApp.fn_Split(@str_in VARCHAR(8000), @separator CHAR(1)) RETURNS @strtable TABLE (strval VARCHAR(8000)) AS BEGIN
																					DECLARE @Occurances INT
																					DECLARE @Counter INT
																					DECLARE @tmpStr VARCHAR(8000)

																					SET @Counter = 0
																					SET @Occurances = (datalength(replace(@str_in, @separator, @separator + '#')) - datalength(@str_in)) --/ datalength(@separator)
																					SET @tmpStr = @str_in

																					WHILE @Counter < @Occurances
																					BEGIN
																						SET @Counter = @Counter + 1

																						INSERT INTO @strtable
																						VALUES (substring(@tmpStr, 1, charindex(@separator, @tmpStr) - 1))

																						SET @tmpStr = substring(@tmpStr, charindex(@separator, @tmpStr) + 1, 8000)

																						IF datalength(@tmpStr) = 0
																							BREAK
																					END

																					INSERT INTO @strtable
																					VALUES (@tmpStr)

																					RETURN
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Split'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Split was created successfully'
																					PRINT 'Add security assignment of select to DBApp_Processor'

																					GRANT SELECT
																						ON dbApp.fn_Split
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Split does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Split' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Str_BuildCallStack.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Str_BuildCallStack' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Str_BuildCallStack'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Str_BuildCallStack'

																					DROP FUNCTION dbApp.fn_Str_BuildCallStack
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Str_BuildCallStack does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Str_BuildCallStack';GO
																					/*
This function returns a single value that is the concatenation of the passed parameter and
a semi-colon as appropriate. This function is used to build a string representation of the
stored procedure call stack.

*/
																					CREATE FUNCTION dbApp.fn_Str_BuildCallStack --<FuncParams>
																					(@i_InValue VARCHAR(1000), @Level INT, @Proc VARCHAR(128)) RETURNS VARCHAR(1000) AS BEGIN
																					-- all initializations should be placed here
																					RETURN (
																							isnull(@i_InValue, '') + CASE 
																								WHEN @Level IS NULL
																									THEN ''
																								WHEN @Level = 1
																									THEN ''
																								ELSE ';' + @Proc
																								END
																							);;
																				END GO
																					--grant execute on dbApp.fn_Str_BuildCallStack to dbApp_Processor;
																					GO IF 
																					EXISTS (
																							SELECT *
																							FROM INFORMATION_SCHEMA.ROUTINES
																							WHERE SPECIFIC_SCHEMA = N'dbApp'
																								AND SPECIFIC_NAME = N'fn_Str_BuildCallStack'
																								AND ROUTINE_TYPE = N'Function'
																							)
																					BEGIN
																					PRINT 'Function dbApp.fn_Str_BuildCallStack has been created.';
																				END;GO IF 
																					EXISTS (
																							SELECT *
																							FROM information_schema.ROUTINES
																							WHERE SPECIFIC_SCHEMA = 'dbApp'
																								AND ROUTINE_NAME = 'fn_Str_BuildCallStack'
																								AND ROUTINE_TYPE = 'Function'
																							)
																					BEGIN
																					PRINT 'Function dbApp.fn_Str_BuildCallStack was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Str_BuildCallStack
																						TO DBApp_Processor;
																				END ELSE BEGIN
																					PRINT 'Function dbApp.fn_Str_BuildCallStack does not exist, create failed'
																				END PRINT '' PRINT 'End of script file for dbApp.fn_Str_BuildCallStack' PRINT '----------------------------------------------------------------------' GO
																					/*
-- Test Code
declare	@In		varchar(10)
declare	@Out		int

set @In = ('Test1;Test2;Test3')

set @Out = dbApp.f_BuildCallStack (@In)

select @Out


*/
																					-- =============================================================================
																					PRINT 'Adding file fn_String_Get_LeftofComma.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_String_Get_LeftOfComma' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_String_Get_LeftOfComma'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_String_Get_LeftOfComma'

																					DROP FUNCTION dbApp.fn_String_Get_LeftOfComma
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_String_Get_LeftOfComma does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_String_Get_LeftOfComma';GO CREATE FUNCTION dbApp.fn_String_Get_LeftOfComma(@i_Str VARCHAR(8000)) RETURNS VARCHAR(8000) AS BEGIN
																					DECLARE @OutValue VARCHAR(8000)
																					DECLARE @CPos SMALLINT

																					SET @cPos = charindex(',', @i_Str, 1)

																					IF @cPos IS NULL
																						OR @CPos = 0
																						SET @OutValue = @i_Str
																					ELSE
																					BEGIN
																						SET @OutValue = substring(@i_Str, 1, @CPos - 1)
																					END

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_String_Get_LeftOfComma'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_String_Get_LeftOfComma was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_String_Get_LeftOfComma
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_String_Get_LeftOfComma does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_String_Get_LeftOfComma' PRINT '----------------------------------------------------------------------' GO
																					/*
<FuncTest>
declare	@In		varchar(8000)
declare	@Out	varchar(8000)
set @In =
set @Out = dbApp.fn_String_Get_LeftOfComma (@In)
select @Out
</FuncTest>
<Todo>
</Todo>
*/
																					-- =============================================================================
																					PRINT 'Adding file fn_String_Get_MiddleofThree.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_String_Get_MiddleofThree' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_String_Get_MiddleofThree'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_String_Get_MiddleofThree'

																					DROP FUNCTION dbApp.fn_String_Get_MiddleofThree
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_String_Get_MiddleofThree does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_String_Get_MiddleofThree';GO CREATE FUNCTION dbApp.fn_String_Get_MiddleofThree(@i_Str VARCHAR(8000)) RETURNS VARCHAR(8000) AS BEGIN
																					DECLARE @OutValue VARCHAR(8000)
																					DECLARE @CPos1 SMALLINT
																					DECLARE @CPos2 SMALLINT

																					SET @cPos1 = charindex(',', @i_Str, 1)
																					SET @cPos2 = charindex(',', @i_Str, @Cpos1 + 1)

																					IF @cPos2 IS NULL
																						OR @CPos2 = 0
																						SET @OutValue = @i_Str
																					ELSE
																					BEGIN
																						SET @OutValue = substring(@i_Str, @CPos1 + 1, (@CPos2 - @cPos1) - 1)
																					END

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_String_Get_MiddleofThree'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_String_Get_MiddleofThree was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_String_Get_MiddleofThree
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_String_Get_MiddleofThree does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_String_Get_MiddleofThree' PRINT '----------------------------------------------------------------------' GO
																					/*
declare	@In		varchar(8000)
declare	@Out	varchar(8000)
set @In =
set @Out = dbApp.fn_String_Get_MiddleofThree (@In)
select @Out
*/
																					-- =============================================================================
																					PRINT 'Adding file fn_String_Get_RightOfComma.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_String_Get_RightofComma' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_String_Get_RightofComma'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_String_Get_RightofComma'

																					DROP FUNCTION dbApp.fn_String_Get_RightofComma
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_String_Get_RightofComma does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_String_Get_RightofComma';GO CREATE FUNCTION dbApp.fn_String_Get_RightofComma --<FuncParams>
																					(@i_Str VARCHAR(8000))
																					--</FuncParams>
																					RETURNS VARCHAR(8000) AS BEGIN
																					RETURN CASE charindex(',', @i_Str)
																							WHEN 0
																								THEN @i_Str
																							ELSE right(@i_Str, charindex(',', reverse(@i_Str), 1) - 1)
																							END;
																				END GO IF 
																					EXISTS (
																							SELECT *
																							FROM information_schema.ROUTINES
																							WHERE SPECIFIC_SCHEMA = 'dbApp'
																								AND ROUTINE_NAME = 'fn_String_Get_RightofComma'
																								AND ROUTINE_TYPE = 'Function'
																							)
																					BEGIN
																					PRINT 'Function dbApp.fn_String_Get_RightofComma was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_String_Get_RightofComma
																						TO DBApp_Processor;
																				END ELSE BEGIN
																					PRINT 'Function dbApp.fn_String_Get_RightofComma does not exist, create failed'
																				END PRINT '' PRINT 'End of script file for dbApp.fn_String_Get_RightofComma' PRINT '----------------------------------------------------------------------' GO
																					/*
<FuncTest>
declare	@In		varchar(8000)
declare	@Out	varchar(8000)
set @In =
set @Out = dbApp.fn_String_Get_RightofComma (@In)
select @Out
</FuncTest>
<Todo>
</Todo>

*/
																					-- =============================================================================
																					PRINT 'Adding file f_GetErrorInfo.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.f_GetErrorInfo' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'f_GetErrorInfo'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.f_GetErrorInfo'

																					DROP FUNCTION dbApp.f_GetErrorInfo
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.f_GetErrorInfo does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.f_GetErrorInfo';GO CREATE FUNCTION dbApp.f_GetErrorInfo() RETURNS TABLE AS
																					--/**
																					--*
																					--* $Filename: f_GetErrorInfo.sql
																					--* $Author: Stephen R. McLarnon Sr.
																					--*
																					--* $Object: f_GetErrorInfo
																					--* $ObjectType: table valued function
																					--*
																					--* $Description: Returns a table with a single row of error information
																					--*
																					--* $Param1: none
																					--*
																					--* $OutputType: Table
																					--*
																					--* $Output1: Errornumber - The SQL Server error number
																					--* $Output2: ErrorSeverity - The severity level of the error.
																					--* $Output3: ErrorState - The state of the error condition.
																					--* $Output4: ErrorProcedure - This function name.
																					--* $Output5: ErrorLine - The line number in the code where the error occured.
																					--* $Output6: The error message returned.
																					--*
																					--* $Note:
																					--*
																					--* $$Revisions:
																					--*  Ini |    Date     | Description
																					--* ---------------------------------
																					--* $End:
																					--**/
																					RETURN SELECT error_number() AS ErrorNumber, error_severity() AS ErrorSeverity, error_state() AS ErrorState, error_procedure() AS ErrorProcedure, error_line() AS ErrorLine, error_message() AS ErrorMessage;GO IF 
																					EXISTS (
																							SELECT *
																							FROM information_schema.ROUTINES
																							WHERE SPECIFIC_SCHEMA = 'dbApp'
																								AND ROUTINE_NAME = 'f_GetErrorInfo'
																								AND ROUTINE_TYPE = 'Function'
																							)
																					BEGIN
																					PRINT 'Function dbApp.f_GetErrorInfo was created successfully'
																					PRINT 'Add security assignment of select to DBApp_Processor'

																					GRANT SELECT
																						ON dbApp.f_GetErrorInfo
																						TO DBApp_Processor;
																				END ELSE BEGIN
																					PRINT 'Function dbApp.f_GetErrorInfo does not exist, create failed'
																				END PRINT '' PRINT 'End of script file for dbApp.f_GetErrorInfo' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Compute_Boolean.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Compute_Boolean' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Compute_Boolean'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Compute_Boolean'

																					DROP FUNCTION dbApp.fn_Compute_Boolean
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Compute_Boolean does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Compute_Boolean';GO CREATE FUNCTION dbApp.fn_Compute_Boolean --<FuncParams>
																					(@LParm VARCHAR(500) = NULL, @RParm VARCHAR(500) = NULL, @Op VARCHAR(20)) RETURNS NUMERIC(16, 6) AS
																					/*
This function returns a single value that is true or false depending on the
results of the evaluation
*/
																					BEGIN
																					-- all declarations should be placed here
																					DECLARE @OutValue NUMERIC(16, 6)
																					DECLARE @l NUMERIC(16, 6)
																					DECLARE @r NUMERIC(16, 6)
																					DECLARE @nFlag TINYINT
																					DECLARE @rnFlag TINYINT
																					DECLARE @RightMin NUMERIC(16, 6)
																					DECLARE @RightMax NUMERIC(16, 6)
																					DECLARE @rnTable TABLE (rval NUMERIC(16, 6))
																					DECLARE @rtTable TABLE (rVal VARCHAR(500))

																					-- all initializations should be placed here
																					SET @OutValue = 0.000 -- initialize output to false
																					SET @nFlag = 0
																					SET @rnFlag = 0

																					IF isnumeric(@Lparm) = 1
																					BEGIN
																						SET @l = cast(@LParm AS NUMERIC(16, 6))
																						SET @nFlag = 1
																					END

																					IF dbApp.fn_isNumber(@rParm) = 1
																					BEGIN
																						SET @r = cast(@RParm AS NUMERIC(16, 6))
																						SET @rnFlag = 1
																					END
																					ELSE
																					BEGIN -- check for set stuff
																						SET @nFlag = 0
																					END

																					IF @Op = '><'
																						OR @Op = '!><'
																					BEGIN
																						SET @RightMin = cast(dbApp.fn_String_Get_LeftOfComma(@RParm) AS NUMERIC(16, 6))
																						SET @RightMax = cast(dbApp.fn_String_Get_RightOfComma(@RParm) AS NUMERIC(16, 6))
																					END

																					IF @Op IN (
																							'[]'
																							,'![]'
																							,'<*'
																							,'>*'
																							)
																					BEGIN
																						SET @rnFlag = dbApp.fn_isNumbers_with_Comma(@rParm)

																						IF @rnFlag = 1
																							INSERT INTO @rnTable
																							SELECT cast(strval AS NUMERIC(16, 6))
																							FROM dbApp.fn_Split(@RParm, ',')
																						ELSE
																							INSERT INTO @rtTable
																							SELECT *
																							FROM dbApp.fn_Split(@RParm, ',')
																					END

																					--set @Outvalue = @rnFlag
																					--goto OuttaHere
																					--</FuncInit>
																					-- <FuncCode>
																					-- non-null operations
																					IF @nFlag = 0
																					BEGIN
																						SET @OutValue = CASE @Op
																								WHEN '=='
																									THEN -- is equal to
																										CASE 
																											WHEN @LParm = @RParm
																												THEN 1
																											ELSE 0
																											END
																								WHEN '>'
																									THEN -- is greater than
																										CASE 
																											WHEN @LParm > @RParm
																												THEN 1
																											ELSE 0
																											END
																								WHEN '<'
																									THEN -- is less than
																										CASE 
																											WHEN @LParm < @RParm
																												THEN 1
																											ELSE 0
																											END
																								WHEN '>='
																									THEN -- is greater than or equal to
																										CASE 
																											WHEN @LParm >= @RParm
																												THEN 1
																											ELSE 0
																											END
																								WHEN '<='
																									THEN -- is less than or equal to
																										CASE 
																											WHEN @LParm <= @RParm
																												THEN 1
																											ELSE 0
																											END
																								WHEN '<>'
																									THEN -- is not equal to
																										CASE 
																											WHEN @LParm <> @RParm
																												THEN 1
																											ELSE 0
																											END
																								WHEN '!='
																									THEN -- is not equal to
																										CASE 
																											WHEN @LParm <> @RParm
																												THEN 1
																											ELSE 0
																											END
																								WHEN '!??'
																									THEN CASE 
																											WHEN @lParm IS NOT NULL
																												THEN 1
																											ELSE 0
																											END
																								WHEN '??'
																									THEN CASE 
																											WHEN @lParm IS NULL
																												THEN 1
																											ELSE 0
																											END
																								WHEN '[]'
																									THEN -- in set
																										CASE @rnFlag
																											WHEN 1
																												THEN CASE 
																														WHEN @LParm IN (
																																SELECT rVal
																																FROM @Rntable
																																)
																															THEN 1
																														ELSE 0
																														END
																											ELSE CASE 
																													WHEN @LParm IN (
																															SELECT rVal
																															FROM @Rttable
																															)
																														THEN 1
																													ELSE 0
																													END
																											END
																								WHEN '![]'
																									THEN -- not in set
																										CASE @rnFlag
																											WHEN 1
																												THEN CASE 
																														WHEN @LParm NOT IN (
																																SELECT rVal
																																FROM @Rntable
																																)
																															THEN 1
																														ELSE 0
																														END
																											ELSE CASE 
																													WHEN @LParm NOT IN (
																															SELECT rVal
																															FROM @Rttable
																															)
																														THEN 1
																													ELSE 0
																													END
																											END
																								WHEN '><'
																									THEN -- is between
																										CASE 
																											WHEN (@LParm >= @RightMin)
																												AND (@LParm <= @RightMax)
																												THEN 1
																											ELSE 0
																											END
																								WHEN '!><'
																									THEN -- not between
																										CASE 
																											WHEN (@LParm < @RightMin)
																												OR (@LParm > @RightMax)
																												THEN 1
																											ELSE 0
																											END
																								WHEN '<*'
																									THEN -- less than all
																										CASE @rnFlag
																											WHEN 1
																												THEN CASE 
																														WHEN @LParm < (
																																SELECT min(rVal)
																																FROM @Rntable
																																)
																															THEN 1
																														ELSE 0
																														END
																											WHEN 0
																												THEN CASE 
																														WHEN @LParm < (
																																SELECT min(rVal)
																																FROM @Rttable
																																)
																															THEN 1
																														ELSE 0
																														END
																											END
																								WHEN '>*'
																									THEN -- greater than all
																										CASE @rnFlag
																											WHEN 1
																												THEN CASE 
																														WHEN @LParm > (
																																SELECT max(rVal)
																																FROM @Rntable
																																)
																															THEN 1
																														ELSE 0
																														END
																											ELSE CASE 
																													WHEN @LParm > (
																															SELECT max(rVal)
																															FROM @Rttable
																															)
																														THEN 1
																													ELSE 0
																													END
																											END
																								WHEN '&&'
																									THEN CASE 
																											WHEN @L = 1.000
																												AND @R = 1.000
																												THEN 1.000
																											ELSE 0.000
																											END
																								WHEN '||'
																									THEN CASE 
																											WHEN @L = 1.000
																												OR @R = 1.000
																												THEN 1.000
																											ELSE 0.000
																											END
																								WHEN '|'
																									THEN CASE 
																											WHEN @L = 1.000
																												AND @R = 0.000
																												THEN 1.000
																											WHEN @L = 0.000
																												AND @R = 1.000
																												THEN 1.000
																											ELSE 0.000
																											END
																								END
																					END
																					ELSE
																					BEGIN
																						SET @OutValue = CASE @Op
																								WHEN '=='
																									THEN -- is equal to
																										CASE 
																											WHEN @L = @R
																												THEN 1
																											ELSE 0
																											END
																								WHEN '>'
																									THEN -- is greater than
																										CASE 
																											WHEN @L > @R
																												THEN 1
																											ELSE 0
																											END
																								WHEN '<'
																									THEN -- is less than
																										CASE 
																											WHEN @L < @R
																												THEN 1
																											ELSE 0
																											END
																								WHEN '>='
																									THEN -- is greater than or equal to
																										CASE 
																											WHEN @L >= @R
																												THEN 1
																											ELSE 0
																											END
																								WHEN '<='
																									THEN -- is less than or equal to
																										CASE 
																											WHEN @L <= @R
																												THEN 1
																											ELSE 0
																											END
																								WHEN '<>'
																									THEN -- is not equal to
																										CASE 
																											WHEN @L <> @R
																												THEN 1
																											ELSE 0
																											END
																								WHEN '!='
																									THEN -- is not equal to
																										CASE 
																											WHEN @L <> @R
																												THEN 1
																											ELSE 0
																											END
																								WHEN '!??'
																									THEN CASE 
																											WHEN @l IS NOT NULL
																												THEN 1
																											ELSE 0
																											END
																								WHEN '??'
																									THEN CASE 
																											WHEN @l IS NULL
																												THEN 1
																											ELSE 0
																											END
																								WHEN '[]'
																									THEN -- in set
																										CASE @rnFlag
																											WHEN 1
																												THEN CASE 
																														WHEN @LParm IN (
																																SELECT rVal
																																FROM @Rntable
																																)
																															THEN 1
																														ELSE 0
																														END
																											ELSE CASE 
																													WHEN @LParm IN (
																															SELECT rVal
																															FROM @Rttable
																															)
																														THEN 1
																													ELSE 0
																													END
																											END
																								WHEN '![]'
																									THEN -- not in set
																										CASE @rnFlag
																											WHEN 1
																												THEN CASE 
																														WHEN @LParm NOT IN (
																																SELECT rVal
																																FROM @Rntable
																																)
																															THEN 1
																														ELSE 0
																														END
																											ELSE CASE 
																													WHEN @LParm NOT IN (
																															SELECT rVal
																															FROM @Rttable
																															)
																														THEN 1
																													ELSE 0
																													END
																											END
																								WHEN '><'
																									THEN -- is between
																										CASE 
																											WHEN (@LParm >= @RightMin)
																												AND (@LParm <= @RightMax)
																												THEN 1
																											ELSE 0
																											END
																								WHEN '!><'
																									THEN -- not between
																										CASE 
																											WHEN (@LParm < @RightMin)
																												OR (@LParm > @RightMax)
																												THEN 1
																											ELSE 0
																											END
																								WHEN '<*'
																									THEN -- less than all
																										CASE @rnFlag
																											WHEN 1
																												THEN CASE 
																														WHEN @LParm < (
																																SELECT min(rVal)
																																FROM @Rntable
																																)
																															THEN 1
																														ELSE 0
																														END
																											ELSE CASE 
																													WHEN @LParm < (
																															SELECT min(rVal)
																															FROM @Rttable
																															)
																														THEN 1
																													ELSE 0
																													END
																											END
																								WHEN '>*'
																									THEN -- greater than all
																										CASE @rnFlag
																											WHEN 1
																												THEN CASE 
																														WHEN @LParm > (
																																SELECT max(rVal)
																																FROM @RnTable
																																)
																															THEN 1
																														ELSE 0
																														END
																											ELSE CASE 
																													WHEN @LParm > (
																															SELECT max(rVal)
																															FROM @Rttable
																															)
																														THEN 1
																													ELSE 0
																													END
																											END
																								WHEN '&&'
																									THEN CASE 
																											WHEN @L = 1.000
																												AND @R = 1.000
																												THEN 1.000
																											ELSE 0.000
																											END
																								WHEN '||'
																									THEN CASE 
																											WHEN @L = 1.000
																												OR @R = 1.000
																												THEN 1.000
																											ELSE 0.000
																											END
																								WHEN '|'
																									THEN CASE 
																											WHEN @L = 1.000
																												AND @R = 0.000
																												THEN 1.000
																											WHEN @L = 0.000
																												AND @R = 1.000
																												THEN 1.000
																											ELSE 0.000
																											END
																								END
																					END

																					Outtahere:

																					RETURN (@OutValue)
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Compute_Boolean'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Compute_Boolean was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Compute_Boolean
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Compute_Boolean does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Compute_Boolean' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Evaluate.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Evaluate' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Evaluate'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Evaluate'

																					DROP FUNCTION dbApp.fn_Evaluate
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Evaluate does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Evaluate';GO CREATE FUNCTION dbApp.fn_Evaluate(@InExpression VARCHAR(8000), @i_TagDoc VARCHAR(8000)) RETURNS NUMERIC(16, 6)
																					--returns varchar(500)
																					AS BEGIN
																					-- This table holds the operands
																					DECLARE @OperandStack TABLE (
																						GID INT identity(1, 1) NOT NULL
																						,Operand VARCHAR(500)
																						)
																					-- This table holds the expression split into words
																					DECLARE @Xpr TABLE (
																						RowId INT identity(1, 1)
																						,Value VARCHAR(100)
																						,Type CHAR(1)
																						)
																					DECLARE @OperatorStack TABLE (
																						RowId INT identity(1, 1)
																						,Value VARCHAR(20)
																						)
																					DECLARE @Tags TABLE (
																						RowId INT identity(1, 1)
																						,Tag_Name VARCHAR(100)
																						,Tag_Value VARCHAR(1000)
																						)
																					--declare	@Result			numeric(16,6)
																					DECLARE @Result VARCHAR(500)
																					DECLARE @v VARCHAR(8000)
																					-- for processing all expressions
																					DECLARE @ExprLen SMALLINT
																					DECLARE @StrPtr SMALLINT
																					DECLARE @testChar VARCHAR(500)
																					-- for processing words
																					DECLARE @WordPtr SMALLINT
																					DECLARE @WordLen SMALLINT
																					-- for working with OperandStack
																					DECLARE @MaxOperandGID INT
																					-- For working with operators and operands
																					DECLARE @thisOperator VARCHAR(30)
																					DECLARE @thisOperand VARCHAR(500)
																					DECLARE @LeftOperand VARCHAR(500)
																					DECLARE @RightOperand VARCHAR(500)
																					DECLARE @OpCount INT
																					DECLARE @LastOperator VARCHAR(30)
																					DECLARE @WordType CHAR(1)
																					DECLARE @TestOperand VARCHAR(500)
																					-- For evaluating parenthetic subexpressions
																					DECLARE @ParenDepth INT
																					DECLARE @SubExpression VARCHAR(8000)
																					-- for processing functions
																					DECLARE @fPtr INT
																					DECLARE @LastfPtr INT
																					DECLARE @fCall VARCHAR(100)
																					DECLARE @fName VARCHAR(98)
																					DECLARE @fParams VARCHAR(100)
																					DECLARE @NewFword VARCHAR(100)
																					-- for processing tags
																					DECLARE @tPtr INT
																					DECLARE @tName VARCHAR(50)
																					DECLARE @tVal VARCHAR(100)
																					DECLARE @tCount INT
																					-- test variables
																					DECLARE @Rowcount INT
																					DECLARE @NestLevel INT
																					DECLARE @ParenCount INT

																					--
																					SET @v = @InExpression
																					--
																					SET @ParenCount = dbApp.fn_CountStringOccurances(@v, '(')

																					IF @ParenCount = 1
																					BEGIN
																						SET @v = replace(replace(@v, ')', ''), '(', '')
																					END

																					--
																					-- get the tags from the passed in param ======================================
																					INSERT INTO @Tags (
																						Tag_Name
																						,Tag_Value
																						)
																					SELECT NameData
																						,ValueData
																					FROM dbApp.fn_Split_Twice(@i_TagDoc, ',', '=')

																					SET @tCount = @@rowcount
																					SET @tPtr = 1

																					-- This loop replaces each occurance of a tag with the corresponding value
																					WHILE @tPtr <= @tCount
																					BEGIN -- Tag replacement loop
																						SELECT @tName = Tag_Name
																							,@tVal = Tag_Value
																						FROM @Tags
																						WHERE RowId = @tPtr

																						SET @v = replace(@v, @tName, @tVal)
																						SET @tPtr = @tPtr + 1
																					END -- Tag replacement loop

																					--
																					--
																					-- check the expression string and load it into a table
																					INSERT INTO @Xpr (
																						Value
																						,Type
																						)
																					SELECT Data
																						,Type
																					FROM dbApp.fn_Expr_Validate_and_Split(@v)
																					ORDER BY RowId

																					SET @ExprLen = (
																							SELECT count(*)
																							FROM @Xpr
																							)

																					--
																					-- update the Expression table with tag values
																					UPDATE @xpr
																					SET Value = t.Tag_Value
																					FROM @Tags t
																					INNER JOIN @xpr x ON x.Value = t.Tag_Name
																					WHERE x.Type = 'E'

																					SET @Rowcount = @@rowcount

																					--
																					--
																					-- resolve embedded functions
																					IF (
																							SELECT count(*) -- if the count of records
																							FROM @Xpr -- from the expression table
																							WHERE Type = 'F' -- where the data is a fuction call
																							) > 0
																					BEGIN -- is greater than 0, start processing the records
																						SET @fPtr = 0
																						SET @LastFPtr = @fPtr

																						WHILE 1 = 1
																						BEGIN -- fLoop
																							SET @fPtr = (
																									SELECT min(RowId)
																									FROM @Xpr
																									WHERE Type = 'F'
																										AND RowId > @LastFPtr
																									)

																							IF @fPtr IS NULL
																								BREAK
																							ELSE
																							BEGIN
																								-- get the function call string
																								SELECT @fCall = Value
																								FROM @Xpr
																								WHERE RowId = @fPtr

																								-- get the function name and param list
																								SET @fName = substring(@fCall, 1, charindex('(', @fCall, 1) - 1)
																								SET @fParams = replace(replace(right(@fCall, datalength(@fCall) - datalength(@fName)), '(', ''), ')', '')
																								-- using the function name, pass it to the correct function for resolution
																								SET @NewFWord = dbApp.fn_Function_Resolve(@fName, @fParams)

																								UPDATE @Xpr
																								SET Value = @NewFWord
																								WHERE RowId = @fPtr

																								SET @LastFPtr = @fPtr
																							END
																						END -- fLoop
																					END

																					--goto Test_Exit
																					--
																					-- initialize the loop counter to get the first record in the table
																					SET @StrPtr = 1

																					-- Loop thru the @xpr table one row at a time
																					WHILE @StrPtr <= @ExprLen
																					BEGIN
																						SET @Nestlevel = @@nestlevel

																						-- get the next word
																						SELECT @testChar = Value
																							,@WordType = Type
																						FROM @Xpr
																						WHERE RowId = @StrPtr

																						-- if the word is an expression
																						IF @WordType = 'E'
																						BEGIN
																							SET @thisoperand = @testchar

																							INSERT INTO @OperandStack (Operand)
																							VALUES (@thisoperand)
																						END
																								-- if word is an operator
																						ELSE
																							IF @WordType = 'O'
																							BEGIN
																								-- get the current operator count
																								SET @OpCount = (
																										SELECT max(RowId)
																										FROM @OperatorStack
																										)

																								IF @OpCount > 0
																									SET @LastOperator = (
																											SELECT value
																											FROM @OperatorStack
																											WHERE RowId = @OpCount
																											)

																								-- while there are operators on the stack and the one on the stack has
																								-- a higher precedence than the current operator
																								WHILE (
																										@OpCount > 0
																										AND dbApp.fn_Get_Operator_Precedence(@testchar) > dbApp.fn_Get_Operator_Precedence(@LastOperator)
																										)
																								BEGIN
																									-- get the last operator on the stack
																									SET @thisOperator = @LastOperator

																									-- and remove it from the stack
																									DELETE
																									FROM @OperatorStack
																									WHERE RowId = @OpCount

																									-- get the id of the top operand
																									SELECT @MaxOperandGID = max(GID)
																									FROM @OperandStack

																									-- retrieve it and make it the right operand
																									SELECT @RightOperand = Operand
																									FROM @OperandStack
																									WHERE GID = @MaxOperandGID

																									-- then delete if from the operand table
																									DELETE
																									FROM @OperandStack
																									WHERE GID = @MaxOperandGID

																									-- get the highest operand id
																									SELECT @MaxOperandGID = max(GID)
																									FROM @OperandStack

																									-- get that row and make it the left operand
																									SELECT @LeftOperand = Operand
																									FROM @OperandStack
																									WHERE GID = @MaxOperandGID

																									-- delete that row from the operand table
																									DELETE
																									FROM @OperandStack
																									WHERE GID = @MaxOperandGID

																									-- evaluate the operands and add the result to the operand stack
																									INSERT INTO @OperandStack (Operand)
																									VALUES (dbApp.fn_Compute(@LeftOperand, @RightOperand, @thisOperator))

																									SET @Result = isnull(@Result, '') + 'LOP=' + @LeftOperand + ',' + 'ROP=' + @RightOperand + ',' + 'OP=' + @thisoperator + ';'
																								END

																								-- add the current operator to the stack
																								INSERT INTO @OperatorStack
																								SELECT @testchar
																									--set @StrPtr = @StrPtr + 1
																							END
																									--else if ltrim(rtrim(@testChar)) = '(' begin -- Recursive call to this routine
																							ELSE
																								IF @WordType = 'P'
																								BEGIN -- Recursive call to this routine
																									SET @ParenDepth = 1
																									SET @SubExpression = ''

																									-- Eat the LParen
																									--set @StrPtr = @StrPtr + 1
																									WHILE (
																											@StrPtr <= @ExprLen
																											AND @ParenDepth > 0
																											)
																									BEGIN
																										SET @StrPtr = @StrPtr + 1
																										SET @testChar = (
																												SELECT Value
																												FROM @Xpr
																												WHERE RowId = @StrPtr
																												)

																										IF left(@TestChar, 1) = '('
																											SET @ParenDepth = @ParenDepth + 1

																										IF left(@TestChar, 1) = ')'
																											SET @ParenDepth = @ParenDepth - 1

																										IF @ParenDepth > 0
																											SET @SubExpression = isnull(@SubExpression, '') + @TestChar + ' '
																												--set @StrPtr = @StrPtr + 1
																									END

																									INSERT INTO @OperandStack (Operand)
																									SELECT dbApp.fn_Evaluate(@SubExpression, @i_TagDoc)
																								END

																						SET @StrPtr = @StrPtr + 1
																					END

																					-- while there are operators in the operator stack
																					SET @OpCount = (
																							SELECT max(RowId)
																							FROM @OperatorStack
																							)

																					WHILE @OpCount > 0
																					BEGIN
																						-- get the top operator
																						SET @thisOperator = (
																								SELECT value
																								FROM @OperatorStack
																								WHERE RowId = @OpCount
																								)

																						-- test and debug      SET @Result = '<' + @OperatorStack + '>'
																						-- test and debug      SET @Result = @thisOperator
																						DELETE
																						FROM @OperatorStack
																						WHERE RowId = @Opcount

																						-- the next six sql statements get the last 2 operands put into the table
																						SELECT @MaxOperandGID = max(GID)
																						FROM @OperandStack

																						SELECT @RightOperand = Operand
																						FROM @OperandStack
																						WHERE GID = @MaxOperandGID

																						DELETE
																						FROM @OperandStack
																						WHERE GID = @MaxOperandGID

																						SELECT @MaxOperandGID = max(GID)
																						FROM @OperandStack

																						SELECT @LeftOperand = Operand
																						FROM @OperandStack
																						WHERE GID = @MaxOperandGID

																						DELETE
																						FROM @OperandStack
																						WHERE GID = @MaxOperandGID

																						-- then puts it back into the operand table after computing the answer
																						INSERT INTO @OperandStack (Operand)
																						VALUES (dbApp.fn_Compute(@LeftOperand, @RightOperand, @thisOperator))

																						SET @Result = (
																								SELECT Operand
																								FROM @OperandStack
																								WHERE GID = (
																										SELECT max(GID)
																										FROM @OperandStack
																										)
																								)
																						SET @OpCount = (
																								SELECT max(RowId)
																								FROM @OperatorStack
																								)
																					END

																					Test_Exit:

																					--return
																					RETURN (@Result)
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Evaluate'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Evaluate was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Evaluate
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Evaluate does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Evaluate' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Expr_Validate_and_Split.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Expr_Validate_and_Split' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Expr_Validate_and_Split'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Expr_Validate_and_Split'

																					DROP FUNCTION dbApp.fn_Expr_Validate_and_Split
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Expr_Validate_and_Split does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Expr_Validate_and_Split';GO
																					/*
This function returns a table that is the split of an expression. This function
loops thru the supplied expression one character at a time, and determines how to
break the expression into words. It also verifies that there are matched sets of parens
and braces.

*/
																					CREATE FUNCTION dbApp.fn_Expr_Validate_and_Split --<FuncParams>
																					(@i_InExpression VARCHAR(8000)) RETURNS @t TABLE (
																						RowId INT identity(1, 1)
																						,Data VARCHAR(100)
																						,Type CHAR(1)
																						) AS BEGIN
																					-- all declarations should be placed here
																					DECLARE @DataLength INT
																					DECLARE @LoopCtr INT
																					DECLARE @LastChar CHAR(1)
																					DECLARE @LastType CHAR(1) -- '', P (paren), O (Operator), E (Expression)
																					DECLARE @BraceFlag TINYINT
																					DECLARE @TestChar CHAR(1)
																					DECLARE @WorkWord VARCHAR(50)
																					DECLARE @ParenCount SMALLINT
																					DECLARE @BraceCount SMALLINT
																					DECLARE @CloseParen SMALLINT
																					DECLARE @NewWord VARCHAR(50)

																					SET @BraceFlag = 0
																					SET @LastType = ''
																					SET @LoopCtr = 1
																					SET @WorkWord = NULL
																					SET @ParenCount = 0
																					SET @BraceCount = 0
																					SET @DataLength = datalength(@i_InExpression)

																					WHILE @LoopCtr <= @DataLength
																					BEGIN
																						SET @TestChar = NULL
																						SET @TestChar = substring(@i_InExpression, @LoopCtr, 1)

																						-- ===========================================================================
																						IF @TestChar = '('
																						BEGIN
																							IF @LastChar = 'F'
																							BEGIN
																								DELETE
																								FROM @t

																								GOTO Exit_Point
																							END

																							IF @WorkWord IS NULL
																							BEGIN -- we are at the beginning of the expression
																								INSERT INTO @t (
																									Data
																									,Type
																									)
																								SELECT @TestChar
																									,'P'

																								SET @LoopCtr = @LoopCtr + 1
																								SET @LastType = 'P'
																								SET @LastChar = @TestChar
																							END
																							ELSE
																								IF @WorkWord IS NOT NULL
																									AND @WorkWord <> ''
																								BEGIN
																									IF @LastType = 'E'
																									BEGIN -- this must be a function
																										-- get the position of the closing paren
																										SET @CloseParen = charindex(')', @i_InExpression, @LoopCtr)
																										-- get the word
																										SET @NewWord = substring(@i_InExpression, @LoopCtr + 1, @CloseParen - @LoopCtr)
																										-- concatenate the words
																										SET @Workword = @Workword + @TestChar + @NewWord

																										-- add to the database
																										INSERT INTO @t (
																											Data
																											,Type
																											)
																										SELECT @WorkWord
																											,'F'

																										SET @WorkWord = ''
																										SET @LastType = 'F'
																										SET @LoopCtr = @CloseParen + 1
																									END
																									ELSE
																									BEGIN
																										INSERT INTO @t (
																											Data
																											,Type
																											)
																										SELECT @WorkWord
																											,@LastType

																										INSERT INTO @t (
																											Data
																											,type
																											)
																										SELECT @TestChar
																											,'P'

																										SET @LastType = 'P'
																										SET @LastChar = @TestChar
																										SET @LoopCtr = @LoopCtr + 1
																										SET @WorkWord = ''
																									END
																								END
																								ELSE
																									IF @WorkWord = ''
																									BEGIN
																										INSERT INTO @t (
																											Data
																											,type
																											)
																										SELECT @TestChar
																											,'P'

																										SET @LastType = 'P'
																										SET @LastChar = @TestChar
																										SET @LoopCtr = @LoopCtr + 1
																									END

																							SET @ParenCount = @ParenCount + 1

																							CONTINUE
																						END

																						-- ===========================================================================
																						IF @TestChar = ')'
																						BEGIN
																							IF @WorkWord IS NULL
																							BEGIN
																								DELETE
																								FROM @t

																								BREAK
																							END
																							ELSE
																								IF @WorkWord IS NOT NULL
																									AND @WorkWord <> ''
																								BEGIN
																									INSERT INTO @t (
																										Data
																										,Type
																										)
																									SELECT @WorkWord
																										,@LastType

																									INSERT INTO @t (
																										Data
																										,type
																										)
																									SELECT @TestChar
																										,'P'

																									SET @LastType = 'P'
																									SET @LastChar = @TestChar
																									SET @LoopCtr = @LoopCtr + 1
																									SET @WorkWord = ''
																								END
																								ELSE
																									IF @WorkWord = ''
																									BEGIN
																										INSERT INTO @t (
																											Data
																											,type
																											)
																										SELECT @TestChar
																											,'P'

																										SET @LastType = 'P'
																										SET @LastChar = @TestChar
																										SET @LoopCtr = @LoopCtr + 1
																									END

																							SET @ParenCount = @ParenCount - 1

																							CONTINUE
																						END

																						-- ==========================================================================
																						IF @TestChar = ' '
																						BEGIN
																							SET @LoopCtr = @LoopCtr + 1

																							CONTINUE
																						END

																						-- ===========================================================================
																						IF dbApp.fn_isLegal_Expr_Character(@TestChar) = 1
																						BEGIN
																							IF @Testchar = '~'
																							BEGIN
																								SET @TestChar = ' '
																							END

																							IF @LastType = 'F'
																							BEGIN
																								DELETE
																								FROM @t

																								GOTO Exit_Point
																							END

																							IF @WorkWord IS NULL
																							BEGIN
																								SET @WorkWord = @TestChar
																								SET @LoopCtr = @LoopCtr + 1
																								SET @LastChar = @TestChar
																								SET @LastType = 'E'
																							END
																							ELSE
																								IF @WorkWord = ''
																								BEGIN
																									SET @WorkWord = @TestChar
																									SET @LoopCtr = @LoopCtr + 1
																									SET @LastChar = @TestChar
																									SET @LastType = 'E'
																								END
																								ELSE
																									IF @WorkWord <> ''
																									BEGIN
																										IF @LastType = 'E'
																										BEGIN
																											SET @WorkWord = @WorkWord + @TestChar
																											SET @LoopCtr = @LoopCtr + 1
																											SET @LastChar = @TestChar
																										END
																										ELSE
																											IF @LastType <> 'E'
																											BEGIN
																												INSERT INTO @t (
																													Data
																													,Type
																													)
																												SELECT @WorkWord
																													,@LastType

																												SET @WorkWord = @TestChar
																												SET @LastType = 'E'
																												SET @LastChar = @TestChar
																												SET @LoopCtr = @LoopCtr + 1
																											END
																									END

																							CONTINUE
																						END

																						-- ===========================================================================
																						IF dbApp.fn_isLegal_Oper_Character(@TestChar) = 1
																						BEGIN
																							IF @WorkWord IS NULL
																							BEGIN
																								SET @WorkWord = @TestChar
																								SET @LoopCtr = @LoopCtr + 1
																								SET @LastChar = @TestChar
																								SET @LastType = 'O'
																							END
																							ELSE
																								IF @WorkWord = ''
																								BEGIN
																									SET @WorkWord = @TestChar
																									SET @LoopCtr = @LoopCtr + 1
																									SET @LastChar = @TestChar
																									SET @LastType = 'O'
																								END
																								ELSE
																									IF @WorkWord <> ''
																									BEGIN
																										IF @LastType = 'O'
																										BEGIN
																											SET @WorkWord = @WorkWord + @TestChar
																											SET @LoopCtr = @LoopCtr + 1
																											SET @LastChar = @TestChar
																										END
																										ELSE
																											IF @LastType <> 'O'
																											BEGIN
																												INSERT INTO @t (
																													Data
																													,Type
																													)
																												SELECT @WorkWord
																													,@LastType

																												SET @WorkWord = @TestChar
																												SET @LastType = 'O'
																												SET @LastChar = @TestChar
																												SET @LoopCtr = @LoopCtr + 1
																											END
																									END

																							CONTINUE
																						END

																						-- ===========================================================================
																						--delete from @t
																						SET @LoopCtr = @LoopCtr + 1
																					END

																					IF @LastType IN (
																							'O'
																							,'E'
																							)
																					BEGIN
																						INSERT INTO @t (
																							Data
																							,Type
																							)
																						SELECT @Workword
																							,@LastType
																					END

																					-- test for matching parens
																					IF EXISTS (
																							SELECT *
																							FROM @t
																							WHERE Data = ')'
																							)
																					BEGIN
																						IF (
																								SELECT count(*)
																								FROM @t
																								WHERE Data = '('
																								) <> (
																								SELECT count(*)
																								FROM @t
																								WHERE Data = ')'
																								)
																						BEGIN
																							DELETE
																							FROM @t
																						END
																					END

																					-- test for matching braces
																					IF EXISTS (
																							SELECT *
																							FROM @t
																							WHERE left(Data, 1) = '{'
																							)
																					BEGIN
																						IF (
																								SELECT count(*)
																								FROM @t
																								WHERE left(Data, 1) = '{'
																								) <> (
																								SELECT count(*)
																								FROM @t
																								WHERE right(Data, 1) = '}'
																								)
																						BEGIN
																							DELETE
																							FROM @t
																						END
																					END

																					Exit_Point:

																					RETURN
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Expr_Validate_and_Split'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Expr_Validate_and_Split was created successfully'
																					PRINT 'Add security assignment of select to DBApp_Processor'

																					GRANT SELECT
																						ON dbApp.fn_Expr_Validate_and_Split
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Expr_Validate_and_Split does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Expr_Validate_and_Split' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Function_Resolve.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Function_Resolve' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Function_Resolve'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Function_Resolve'

																					DROP FUNCTION dbApp.fn_Function_Resolve
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Function_Resolve does not exist, skipping drop'
																				END
																					GO PRINT 'Creating function dbApp.fn_Function_Resolve';GO CREATE FUNCTION dbApp.fn_Function_Resolve --<FuncParams>
																					(@i_fName VARCHAR(100), @i_fParams VARCHAR(100))
																					--</FuncParams>
																					RETURNS VARCHAR(100) AS BEGIN
																					-- all declarations should be placed here
																					DECLARE @OutValue VARCHAR(100)

																					IF @i_FName = 'substring'
																					BEGIN
																						SET @OutValue = dbApp.fn_Resolve_Substring(@i_fParams)

																						GOTO OuttaHere
																					END

																					OuttaHere:

																					RETURN @OutValue
																				END GO IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Function_Resolve'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Function dbApp.fn_Function_Resolve was created successfully'
																					PRINT 'Add security assignment of execute to DBApp_Processor'

																					GRANT EXECUTE
																						ON dbApp.fn_Function_Resolve
																						TO DBApp_Processor;
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Function_Resolve does not exist, create failed'
																				END
																					PRINT '' PRINT 'End of script file for dbApp.fn_Function_Resolve' PRINT '----------------------------------------------------------------------' GO
																					-- =============================================================================
																					PRINT 'Adding file fn_Split_Twice.sql'
																					-- =============================================================================
																					PRINT '------------------------------------------------------------' PRINT 'Script file for function dbApp.fn_Split_Twice' PRINT '' IF EXISTS (
																						SELECT *
																						FROM information_schema.ROUTINES
																						WHERE SPECIFIC_SCHEMA = 'dbApp'
																							AND ROUTINE_NAME = 'fn_Split_Twice'
																							AND ROUTINE_TYPE = 'Function'
																						)
																				BEGIN
																					PRINT 'Dropping function dbApp.fn_Split_Twice'

																					DROP FUNCTION dbApp.fn_Split_Twice
																				END
																				ELSE
																				BEGIN
																					PRINT 'Function dbApp.fn_Split_Twice does not exist, skipping drop'
																				END
																					GO
																					--</Setup>
																					--<Func>
																					/* <FuncHeader>
Filename	fn_Split_Twice
Project		
Client		
Purpose		

<sqldoc>
  <function> <funcname> dbo.fn_Split_Twice </funcname>
    <funcdesc>	
This function returns a table that represents name-value pairs. The
string passed must be a list of name-value pairs. The separators can be any
character.
    </funcdesc>
  </function>
</sqldoc>

$Id: fn_Split_Twice.sql,v 1.1 2005/08/02 20:36:15 smclarnon Exp $

Revision History
Date		Name			Description		
----------	---------------	---------------------------------
10/09/2003 	S. McLarnon		Initial Version
</FuncHeader>
*/
																					CREATE FUNCTION dbapp.fn_Split_Twice (
																					@str_in VARCHAR(8000)
																					,@separator VARCHAR(4)
																					,@separator2 VARCHAR(4)
																					)
																				RETURNS @strtable TABLE (
																					NameData VARCHAR(1000)
																					,ValueData VARCHAR(1000)
																					)
																				AS
																				BEGIN
																					DECLARE @Occurances INT
																					DECLARE @Counter INT
																					DECLARE @tmpStr VARCHAR(8000)
																					DECLARE @Temp TABLE (
																						RowId INT identity(1, 1)
																						,Value VARCHAR(8000)
																						)

																					SET @Counter = 0
																					SET @Occurances = (datalength(replace(@str_in, @separator, @separator + '#')) - datalength(@str_in)) --/ datalength(@separator)
																					SET @tmpStr = @str_in

																					WHILE @Counter < @Occurances
																					BEGIN
																						SET @Counter = @Counter + 1

																						INSERT INTO @Temp (Value)
																						VALUES (substring(@tmpStr, 1, charindex(@separator, @tmpStr) - 1))

																						SET @tmpStr = substring(@tmpStr, charindex(@separator, @tmpStr) + 1, 8000)

																						IF datalength(@tmpStr) = 0
																							BREAK
																					END

																					INSERT INTO @Temp (Value)
																					SELECT @tmpStr

																					SET @Counter = 1
																					SET @Occurances = (
																							SELECT count(*)
																							FROM @Temp
																							)
																					SET @tmpStr = ''

																					WHILE @Counter <= @Occurances
																					BEGIN
																						SET @tmpStr = (
																								SELECT Value
																								FROM @Temp
																								WHERE RowId = @Counter
																								)

																						INSERT INTO @strtable (
																							NameData
																							,ValueData
																							)
																						SELECT DBApp.fn_Name_Value_Pair_Get_Name(@tmpStr)
																							,DBApp.fn_Name_Value_Pair_get_Value(@tmpStr)

																						SET @Counter = @Counter + 1
																					END

																					RETURN
																				END
																				))))))))
												)
										)))))))
			)
GO

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'fn_Split_Twice'
			AND ROUTINE_TYPE = 'Function'
		)
BEGIN
	PRINT 'Function dbApp.fn_Split_Twice was created successfully'
	PRINT 'Add security assignment of execute to DBApp_Processor'

	GRANT SELECT
		ON dbApp.fn_Split_Twice
		TO DBApp_Processor;
END
ELSE
BEGIN
	PRINT 'Function dbApp.fn_Split_Twice does not exist, create failed'
END

PRINT ''
PRINT 'End of script file for dbApp.fn_Split_Twice'
PRINT '----------------------------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file fn_Evaluate_Boolean.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT 'Script file for function dbApp.fn_Evaluate_Boolean'
PRINT ''

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'fn_Evaluate_Boolean'
			AND ROUTINE_TYPE = 'Function'
		)
BEGIN
	PRINT 'Dropping function dbApp.fn_Evaluate_Boolean'

	DROP FUNCTION dbApp.fn_Evaluate_Boolean
END
ELSE
BEGIN
	PRINT 'Function dbApp.fn_Evaluate_Boolean does not exist, skipping drop'
END
GO

PRINT 'Creating function dbApp.fn_Evaluate_Boolean';
GO

CREATE FUNCTION dbApp.fn_Evaluate_Boolean (
	@InExpression VARCHAR(8000)
	,@i_TagDoc VARCHAR(8000)
	)
	--returns numeric(16,6)
RETURNS VARCHAR(500)
AS
BEGIN
	-- This table holds the operands
	DECLARE @OperandStack TABLE (
		GID INT identity(1, 1) NOT NULL
		,Operand VARCHAR(500)
		)
	-- This table holds the expression split into words
	DECLARE @Xpr TABLE (
		RowId INT identity(1, 1)
		,Value VARCHAR(100)
		,Type CHAR(1)
		)
	DECLARE @OperatorStack TABLE (
		RowId INT identity(1, 1)
		,Value VARCHAR(20)
		)
	DECLARE @Tags TABLE (
		RowId INT identity(1, 1)
		,Tag_Name VARCHAR(100)
		,Tag_Value VARCHAR(1000)
		)
	--declare	@Result			numeric(16,6)
	DECLARE @Result VARCHAR(500)
	DECLARE @v VARCHAR(8000)
	-- for processing all expressions
	DECLARE @ExprLen SMALLINT
	DECLARE @StrPtr SMALLINT
	DECLARE @testChar VARCHAR(500)
	-- for processing words
	DECLARE @WordPtr SMALLINT
	DECLARE @WordLen SMALLINT
	-- for working with OperandStack
	DECLARE @MaxOperandGID INT
	-- For working with operators and operands
	DECLARE @thisOperator VARCHAR(30)
	DECLARE @thisOperand VARCHAR(500)
	DECLARE @LeftOperand VARCHAR(500)
	DECLARE @RightOperand VARCHAR(500)
	DECLARE @OpCount INT
	DECLARE @LastOperator VARCHAR(30)
	DECLARE @WordType CHAR(1)
	DECLARE @TestOperand VARCHAR(500)
	-- For evaluating parenthetic subexpressions
	DECLARE @ParenDepth INT
	DECLARE @SubExpression VARCHAR(8000)
	-- for processing functions
	DECLARE @fPtr INT
	DECLARE @LastfPtr INT
	DECLARE @fCall VARCHAR(100)
	DECLARE @fName VARCHAR(98)
	DECLARE @fParams VARCHAR(100)
	DECLARE @NewFword VARCHAR(100)
	-- for processing tags
	DECLARE @tPtr INT
	DECLARE @tName VARCHAR(50)
	DECLARE @tVal VARCHAR(100)
	DECLARE @tCount INT
	-- test variables
	DECLARE @Rowcount INT
	DECLARE @NestLevel INT
	DECLARE @ParenCount INT

	SET @v = @InExpression
	SET @ParenCount = dbApp.fn_CountStringOccurances(@v, '(')

	IF @ParenCount = 1
	BEGIN
		SET @v = replace(replace(@v, ')', ''), '(', '')
	END

	-- get the tags from the passed in param ======================================
	INSERT INTO @Tags (
		Tag_Name
		,Tag_Value
		)
	SELECT NameData
		,ValueData
	FROM dbApp.fn_Split_Twice(@i_TagDoc, ',', '=')

	SET @tCount = @@rowcount
	SET @tPtr = 1

	-- This loop replaces each occurance of a tag with the corresponding value
	WHILE @tPtr <= @tCount
	BEGIN -- Tag replacement loop
		SELECT @tName = Tag_Name
			,@tVal = Tag_Value
		FROM @Tags
		WHERE RowId = @tPtr

		SET @v = replace(@v, @tName, @tVal)
		SET @tPtr = @tPtr + 1
	END -- Tag replacement loop

	-- check the expression string and load it into a table
	INSERT INTO @Xpr (
		Value
		,Type
		)
	SELECT Data
		,Type
	FROM dbApp.fn_Expr_Validate_and_Split(@v)
	ORDER BY RowId

	SET @ExprLen = (
			SELECT count(*)
			FROM @Xpr
			)

	-- update the Expression table with tag values
	UPDATE @xpr
	SET Value = t.Tag_Value
	FROM @Tags t
	INNER JOIN @xpr x ON x.Value = t.Tag_Name
	WHERE x.Type = 'E'

	SET @Rowcount = @@rowcount

	-- resolve embedded functions
	IF (
			SELECT count(*) -- if the count of records
			FROM @Xpr -- from the expression table
			WHERE Type = 'F' -- where the data is a fuction call
			) > 0
	BEGIN -- is greater than 0, start processing the records
		SET @fPtr = 0
		SET @LastFPtr = @fPtr

		WHILE 1 = 1
		BEGIN -- fLoop
			SET @fPtr = (
					SELECT min(RowId)
					FROM @Xpr
					WHERE Type = 'F'
						AND RowId > @LastFPtr
					)

			IF @fPtr IS NULL
				BREAK
			ELSE
			BEGIN
				-- get the function call string
				SELECT @fCall = Value
				FROM @Xpr
				WHERE RowId = @fPtr

				-- get the function name and param list
				SET @fName = substring(@fCall, 1, charindex('(', @fCall, 1) - 1)
				SET @fParams = replace(replace(right(@fCall, datalength(@fCall) - datalength(@fName)), '(', ''), ')', '')
				-- using the function name, pass it to the correct function for resolution
				SET @NewFWord = dbApp.fn_Function_Resolve(@fName, @fParams)

				UPDATE @Xpr
				SET Value = @NewFWord
				WHERE RowId = @fPtr

				SET @LastFPtr = @fPtr
			END
		END -- fLoop
	END

	--goto Test_Exit
	-- initialize the loop counter to get the first record in the table
	SET @StrPtr = 1

	-- Loop thru the @xpr table one row at a time
	WHILE @StrPtr <= @ExprLen
	BEGIN
		SET @Nestlevel = @@nestlevel

		-- get the next word
		SELECT @testChar = Value
			,@WordType = Type
		FROM @Xpr
		WHERE RowId = @StrPtr

		-- if the word is an expression
		IF @WordType = 'E'
		BEGIN
			SET @thisoperand = @testchar

			INSERT INTO @OperandStack (Operand)
			VALUES (@thisoperand)
		END
				-- if word is an operator
		ELSE
			IF @WordType = 'O'
			BEGIN
				-- get the current operator count
				SET @OpCount = (
						SELECT max(RowId)
						FROM @OperatorStack
						)

				IF @OpCount > 0
					SET @LastOperator = (
							SELECT value
							FROM @OperatorStack
							WHERE RowId = @OpCount
							)

				-- while there are operators on the stack and the one on the stack has
				-- a higher precedence than the current operator
				WHILE (
						@OpCount > 0
						AND dbApp.fn_Get_Operator_Precedence(@testchar) > dbApp.fn_Get_Operator_Precedence(@LastOperator)
						)
				BEGIN
					-- get the last operator on the stack
					SET @thisOperator = @LastOperator

					-- and remove it from the stack
					DELETE
					FROM @OperatorStack
					WHERE RowId = @OpCount

					-- get the id of the top operand
					SELECT @MaxOperandGID = max(GID)
					FROM @OperandStack

					-- retrieve it and make it the right operand
					SELECT @RightOperand = Operand
					FROM @OperandStack
					WHERE GID = @MaxOperandGID

					-- then delete if from the operand table
					DELETE
					FROM @OperandStack
					WHERE GID = @MaxOperandGID

					-- get the highest operand id
					SELECT @MaxOperandGID = max(GID)
					FROM @OperandStack

					-- get that row and make it the left operand
					SELECT @LeftOperand = Operand
					FROM @OperandStack
					WHERE GID = @MaxOperandGID

					-- delete that row from the operand table
					DELETE
					FROM @OperandStack
					WHERE GID = @MaxOperandGID

					-- evaluate the operands and add the result to the operand stack
					INSERT INTO @OperandStack (Operand)
					VALUES (dbApp.fn_Compute_Boolean(@LeftOperand, @RightOperand, @thisOperator))

					SET @Result = isnull(@Result, '') + 'LOP=' + @LeftOperand + ',' + 'ROP=' + @RightOperand + ',' + 'OP=' + @thisoperator + ';'
				END

				-- add the current operator to the stack
				INSERT INTO @OperatorStack
				SELECT @testchar
					--set @StrPtr = @StrPtr + 1
			END
					--else if ltrim(rtrim(@testChar)) = '(' begin -- Recursive call to this routine
			ELSE
				IF @WordType = 'P'
				BEGIN -- Recursive call to this routine
					SET @ParenDepth = 1
					SET @SubExpression = ''

					-- Eat the LParen
					--set @StrPtr = @StrPtr + 1
					WHILE (
							@StrPtr <= @ExprLen
							AND @ParenDepth > 0
							)
					BEGIN
						SET @StrPtr = @StrPtr + 1
						SET @testChar = (
								SELECT Value
								FROM @Xpr
								WHERE RowId = @StrPtr
								)

						IF left(@TestChar, 1) = '('
							SET @ParenDepth = @ParenDepth + 1

						IF left(@TestChar, 1) = ')'
							SET @ParenDepth = @ParenDepth - 1

						IF @ParenDepth > 0
							SET @SubExpression = isnull(@SubExpression, '') + @TestChar + ' '
								--set @StrPtr = @StrPtr + 1
					END

					INSERT INTO @OperandStack (Operand)
					SELECT dbApp.fn_Evaluate_Boolean(@SubExpression, @i_TagDoc)
				END

		SET @StrPtr = @StrPtr + 1
	END

	-- while there are operators in the operator stack
	SET @OpCount = (
			SELECT max(RowId)
			FROM @OperatorStack
			)

	WHILE @OpCount > 0
	BEGIN
		-- get the top operator
		SET @thisOperator = (
				SELECT value
				FROM @OperatorStack
				WHERE RowId = @OpCount
				)

		-- test and debug      SET @Result = '<' + @OperatorStack + '>'
		-- test and debug      SET @Result = @thisOperator
		DELETE
		FROM @OperatorStack
		WHERE RowId = @Opcount

		-- the next six sql statements get the last 2 operands put into the table
		SELECT @MaxOperandGID = max(GID)
		FROM @OperandStack

		SELECT @RightOperand = Operand
		FROM @OperandStack
		WHERE GID = @MaxOperandGID

		DELETE
		FROM @OperandStack
		WHERE GID = @MaxOperandGID

		SELECT @MaxOperandGID = max(GID)
		FROM @OperandStack

		SELECT @LeftOperand = Operand
		FROM @OperandStack
		WHERE GID = @MaxOperandGID

		DELETE
		FROM @OperandStack
		WHERE GID = @MaxOperandGID

		-- then puts it back into the operand table after computing the answer
		INSERT INTO @OperandStack (Operand)
		VALUES (dbApp.fn_Compute_Boolean(@LeftOperand, @RightOperand, @thisOperator))

		SET @Result = (
				SELECT Operand
				FROM @OperandStack
				WHERE GID = (
						SELECT max(GID)
						FROM @OperandStack
						)
				)
		SET @OpCount = (
				SELECT max(RowId)
				FROM @OperatorStack
				)
	END

	Test_Exit:

	--return
	RETURN (@Result)
END
GO

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'fn_Evaluate_Boolean'
			AND ROUTINE_TYPE = 'Function'
		)
BEGIN
	PRINT 'Function dbApp.fn_Evaluate_Boolean was created successfully'
	PRINT 'Add security assignment of execute to DBApp_Processor'

	GRANT EXECUTE
		ON dbApp.fn_Evaluate_Boolean
		TO DBApp_Processor;
END
ELSE
BEGIN
	PRINT 'Function dbApp.fn_Evaluate_Boolean does not exist, create failed'
END

PRINT ''
PRINT 'End of script file for dbApp.fn_Evaluate_Boolean'
PRINT '----------------------------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file p_AssociationRuleGetValue.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Procedure script for dbApp.p_AssociationRuleGetValue *****'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT ''

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'p_AssociationRuleGetValue'
			AND ROUTINE_TYPE = 'Procedure'
		)
BEGIN
	PRINT 'Dropping procedure dbApp.p_AssociationRuleGetValue'

	DROP PROCEDURE dbApp.p_AssociationRuleGetValue
END
ELSE
BEGIN
	PRINT 'Procedure dbApp.p_AssociationRuleGetValue does not exist, skipping drop'
END
GO

PRINT 'Creating procedure dbApp.p_AssociationRuleGetValue';
GO

CREATE PROCEDURE dbApp.p_AssociationRuleGetValue --<ProcParams>
	@i_RuleName VARCHAR(100)
	,@o_Value VARCHAR(2500) = NULL OUTPUT
	,@o_Success TINYINT = NULL OUTPUT
	,@Errorcode INT = NULL OUTPUT
	,@ErrorMessage VARCHAR(400) = NULL OUTPUT
	,@TechMsg VARCHAR(400) = NULL OUTPUT
	,@CallStack VARCHAR(1000) = ''
AS
DECLARE @CodeSection VARCHAR(128)

SET @CodeSection = 'ProcDDL'

-- Standard variables
DECLARE @Error INT
DECLARE @ECode INT
DECLARE @TMsg VARCHAR(7500)
DECLARE @retcode INT
DECLARE @Rowcount INT
DECLARE @ProcName VARCHAR(50)
DECLARE @Result INT
DECLARE @NestLevel INT
DECLARE @trancount INT
DECLARE @cStack VARCHAR(1000)
-- error variables
DECLARE @EState INT
DECLARE @ESeverity INT
DECLARE @ELine INT
DECLARE @EProcedure SYSNAME
DECLARE @BusinessError BIT
DECLARE @eMsg VARCHAR(400)
DECLARE @XactState INT
-- mail variables
DECLARE @SendMail TINYINT
DECLARE @Handle VARBINARY(20)
DECLARE @RuleName VARCHAR(100)
DECLARE @Value VARCHAR(2500)
DECLARE @Success TINYINT

--</ProcDDL>
--<ProcInit>
--execute as user = 'dbApp'
SET @CodeSection = 'ProcInit'
SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET @ProcName = 'p_AssociationRuleGetValue'
SET @NestLevel = @@nestlevel
SET @Error = 0
SET @retcode = 0
SET @Result = 0
SET @rowcount = 0
SET @trancount = @@trancount
SET @Errorcode = 0
SET @ErrorMessage = ''
SET @CallStack = dbApp.fn_Str_BuildCallStack(@CallStack, @NestLevel, @Procname)
SET @cStack = ''
SET @Success = 1
--</ProcInit>
-- <Paramcheck>
SET @Codesection = 'Paramcheck'
--</Paramcheck>
-- <ProcCode>
SET @CodeSection = 'ProcCode'

BEGIN TRY
	SELECT @Value = rav.Answer_Val
	FROM dbApp.dbRule r
	INNER JOIN dbapp.Rule_Answer ra ON ra.DBRule_Id = r.DBRule_Id
	INNER JOIN DBApp.Rule_Answer_Value rav ON rav.Rule_Answer_Id = ra.Rule_Answer_Id
	WHERE Rule_Nm = @i_RuleName

	IF @Value IS NULL
	BEGIN
		SET @Error = 7000001
		SET @ErrorMessage = 'There is no value for a rule named "' + @i_RuleName + '"'
		SET @TechMsg = @ErrorMessage
		SET @Success = 0
	END
END TRY

BEGIN CATCH
	IF @Result = 0
	BEGIN
		SELECT @Error = ErrorNumber
			,@Eseverity = ErrorSeverity
			,@EState = ErrorState
			,@Eprocedure = ErrorProcedure
			,@Eline = ErrorLine
			,@EMSG = ErrorMessage
		FROM dbApp.f_GetErrorInfo()

		IF @BusinessError = 1
		BEGIN
			SET @Error = @Error + @ErrorCode
			SET @BusinessError = 0
		END
	END

	GOTO Error_Exit
END CATCH

--</ProcCode>
--<ProcExit>
Normal_Exit:

SET @o_Value = @Value
SET @o_Success = @Success

RETURN (@Retcode)

--</ProcExit>
--<ProcErrorHandler>
Error_Exit:

SET @o_Success = @Success

IF @Result < 0
BEGIN -- we failed at a lower level, just exit
	SET @ErrorCode = @ECode
	SET @ErrorMessage = @EMsg
	SET @TechMsg = @TMsg
	SET @retcode = @Result
END
ELSE
	IF (
			@Result = 0
			AND @Error > 0
			)
	BEGIN
		SET @ErrorCode = @Error
		SET @retcode = 0 - isnull(@ErrorCode, 1010101)
	END
	ELSE
		IF (
				@Result = 0
				AND @ErrorCode > 0
				)
		BEGIN
			SET @Error = @ErrorCode
			SET @ECode = @Error
			SET @retcode = 0 - @ErrorCode
		END
		ELSE
			IF @ErrorCode IS NULL
			BEGIN
				SET @ErrorCode = 1010101
				SET @ECode = @Errorcode
				SET @retcode = 0 - @ErrorCode
			END

SET @TechMsg = isnull(@TechMsg, '') + ', ' + convert(VARCHAR(25), getdate(), 121) + ', ' + isnull(@Procname, 'NullProc') + ', ' + isnull(@Codesection, 'NullCodeSection') + ', ' + cast(@ErrorCode AS VARCHAR(10))

IF @ErrorCode > 0
BEGIN
	SELECT @Handle = NULL --sql_handle from master..sysprocesses where spid = @@spid

	EXECUTE dbApp.p_Error_Log --<ProcParams>
		@i_Doc = NULL
		,@i_Error = @ErrorCode
		,-- 2
		@i_SessionId = NULL
		,-- 3
		@i_Caller = @Procname
		,-- 4
		@i_CodeSection = @CodeSection
		,-- 5
		@i_Handle = NULL
		,-- 7
		@i_ErrorMessage = @TechMsg
		,-- 8
		@i_Job_Id = 0
		,@i_CallStack = @CallStack
		,@i_Severity = @ESeverity
		,@i_Line_Number = @ELine
		,@i_AppName = NULL

	-- smtp mail
	IF @SendMail = 1
	BEGIN
		EXEC dbApp.p_SendErrorEmail @TechMsg
	END
END

NoMail:

RETURN (@retcode)
GO

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'p_AssociationRuleGetValue'
			AND ROUTINE_TYPE = 'Procedure'
		)
BEGIN
	PRINT 'Function dbApp.p_AssociationRuleGetValue was created successfully'
	PRINT 'Add security assignment of execute to DBApp_Processor'

	GRANT EXECUTE
		ON dbApp.p_AssociationRuleGetValue
		TO DBApp_Processor;
END
ELSE
BEGIN
	PRINT 'Function dbApp.p_AssociationRuleGetValue does not exist, create failed'
END

PRINT ''
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '***** End of Procedure script for dbApp.p_AssociationRuleGetValue *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO


GO

/*
<ProcTest>
declare		@ECode		int
declare		@EMessage	varchar(400)
declare		@TMsg		varchar(400)
declare		@Result		int
declare		@R			varchar(100)
declare		@V			varchar(2500)
declare		@Success	tinyint

set @r = ''


execute @Result =  p_AssociationRuleGetValue
	@i_RuleName			= @r,
	@o_Value			= @v output,
	@o_Success			= @Success output,
	@Errorcode			= @ECode  output,
	@ErrorMessage		= @EMessage  output,
	@TechMsg			= @TMsg output,
	@CallStack			= null



select		@Success
			@ECode as ECode,
			@EMessage as Message,
			@Result as ResultCode

select @v

*/
-- =============================================================================
PRINT 'Adding file p_Rule_Controller.sql'
-- =============================================================================
PRINT '------------------------------------------------------------'
PRINT '***** Procedure script for dbApp.p_Rule_Controller *****'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT ''

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'p_Rule_Controller'
			AND ROUTINE_TYPE = 'Procedure'
		)
BEGIN
	PRINT 'Dropping procedure dbApp.p_Rule_Controller'

	DROP PROCEDURE dbApp.p_Rule_Controller
END
ELSE
BEGIN
	PRINT 'Procedure dbApp.p_Rule_Controller does not exist, skipping drop'
END
GO

PRINT 'Creating procedure dbApp.p_Rule_Controller';
GO

CREATE PROCEDURE dbApp.p_Rule_Controller --<ProcParams>
	@i_RuleCondition dbApp.RuleCondition readonly
	,-- Table valued parameter of conditions
	@i_RuleName VARCHAR(100) = ''
	,@i_TagDoc VARCHAR(8000) = ''
	,@i_InValue VARCHAR(1000) = ''
	,@i_EValue INT = 0
	,@o_OutValue VARCHAR(2500) = '' OUTPUT
	,@o_SuccessFlag TINYINT = 1 OUTPUT
	,@Errorcode INT = 0 OUTPUT
	,@ErrorMessage VARCHAR(400) = '' OUTPUT
	,@TechMsg VARCHAR(7500) = '' OUTPUT
	--</ProcParams>
AS
/*

Date		Name			Description
----------	---------------	---------------------------------
*/
-- all declarations should be placed here
DECLARE @CodeSection VARCHAR(128)

SET @CodeSection = 'ProcDDL'

DECLARE @Debug TINYINT = 0
DECLARE @Error INT = 0
DECLARE @Retcode INT = 0
DECLARE @ErrorMsg VARCHAR(255) = ''
DECLARE @Rowcount INT = 0
DECLARE @ProcName VARCHAR(50) = object_name(@@procid)
DECLARE @Result INT = 0
DECLARE @NestLevel INT = @@nestlevel
DECLARE @Ctr TINYINT = 0
DECLARE @Min TINYINT = 0
DECLARE @Max TINYINT = 0
DECLARE @Doc VARCHAR(8000) = ''
DECLARE @iDoc XML
DECLARE @RowId INT = 0
DECLARE @RuleId INT = 0
DECLARE @TruthValue VARCHAR(2500) = ''
DECLARE @isProc TINYINT = 0
DECLARE @isCode TINYINT = 0
DECLARE @RuleCode VARCHAR(6000) = ''
DECLARE @OutValue VARCHAR(2500) = ''
DECLARE @RuleName VARCHAR(50) = ''
DECLARE @RuleType VARCHAR(50) = ''
DECLARE @RuleSetType VARCHAR(50) = ''
DECLARE @TruthResultType VARCHAR(50) = ''
DECLARE @FalseResultType VARCHAR(50) = ''
DECLARE @FalseValue VARCHAR(2500) = ''
DECLARE @CrLf CHAR(2) = CHAR(13) + CHAR(10)
DECLARE @Success TINYINT = 0
-- error variables
DECLARE @EState INT = 0
DECLARE @ESeverity INT = 0
DECLARE @ELine INT = 0
DECLARE @EProcedure SYSNAME = ''
DECLARE @BusinessError TINYINT = 0
DECLARE @XactState INT = 0
DECLARE @EMsg VARCHAR(400) = ''
DECLARE @TMsg VARCHAR(7500) = ''
DECLARE @Query NVARCHAR(4000) = ''
DECLARE @Param NVARCHAR(4000) = ''
DECLARE @PList NVARCHAR(4000) = ''
DECLARE @ReturnValue VARCHAR(500) = ''
DECLARE @P2 TINYINT = 0
DECLARE @LoopCtr TINYINT = 0
DECLARE @RuleValues TABLE (
	Rule_Id INT
	,Result_Type VARCHAR(50)
	,ValueName VARCHAR(50)
	,Value VARCHAR(1000)
	,Qualifier VARCHAR(50)
	)
DECLARE @Tags TABLE (
	Tag_Name VARCHAR(100)
	,Tag_Value VARCHAR(1000)
	)
DECLARE @RuleCondition TABLE (
	RowId INT PRIMARY KEY CLUSTERED
	,CondName VARCHAR(50)
	,CondValue VARCHAR(50)
	)

SET @CodeSection = 'ProcInit'
SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
-- ============================================================================
-- Load the rules
SET @Codesection = 'Load local tables'

-- ***test***
--print 'start of the rule controller now'
--print @i_tagDoc
--print 'End Start'
-- ***test***
--select count(*) from @i_RuleCondition
BEGIN TRY
	INSERT INTO @RuleCondition
	SELECT RuleConditionId
		,ConditionName
		,ConditionValue
	FROM @i_RuleCondition

	--select  RowId,
	--        CondName,
	--        CondValue
	--from @RuleCondition
	SELECT @RuleId = r1.DBRule_Id
		,@isProc = 0
		,--r.isProc_Fl,
		@isCode = 0
		,--r.isCode_Fl,
		@RuleType = rrt.Rule_Resolution_Type_Cd
		,@RuleCode = ''
		,--r.Rule_Cd,
		@Param = '' -- r.Param
	FROM dbApp.DBRule r1
	INNER JOIN dbapp.Rule_Resolution_Type rrt ON rrt.Rule_Resolution_Type_Id = r1.Rule_Resolution_Type_Id
	WHERE r1.Rule_Nm = @i_RuleName
		AND r1.Active_Fl = 1

	IF @RuleId IS NULL
	BEGIN
		SET @ErrorCode = '999999'
		SET @ErrorMessage = 'No matching rule was found'
		SET @TechMsg = @ErrorMessage + @CrLf + @ProcName + ', ' + @CodeSection + @CrLf + @i_RuleName

		RAISERROR (
				@TechMsg
				,16
				,1
				)
	END

	INSERT INTO @RuleValues (
		Rule_Id
		,ValueName
		,Value
		,Qualifier
		)
	SELECT ra.DBRule_Id
		,rrn.Result_Nm
		,rr.Answer_Val
		,rr.Qualifier
	FROM dbApp.Rule_Answer_Value rr
	INNER JOIN dbApp.Rule_Answer ra ON ra.Rule_Answer_Id = rr.Rule_Answer_Id
	INNER JOIN dbApp.Result_Name rrn ON rrn.Result_Nm_Id = rr.Result_Nm_Id
	WHERE ra.DBRule_Id = @RuleId

	SET @Query = @RuleCode
	-- get the tags
	SET @CodeSection = 'populate the tags'

	-- ***test***
	--print @i_TagDoc
	--print @RuleType
	-- ***test***
	IF @i_TagDoc IS NOT NULL
		AND @RuleType IN ('Boolean')
	BEGIN
		SET @iDoc = cast(@i_TagDoc AS XML)

		-- resolve the operands, this is specific to the database implementation
		-- and will not run in SQL Server 2000
		INSERT INTO @Tags (
			Tag_Name
			,Tag_Value
			)
		SELECT result.value('(/Ts/T/N)[1]', 'varchar(100)') AS Tag_Name
			,result.value('(/Ts/T/V) [1]', 'varchar(1000)') AS Tag_Value
		FROM (
			SELECT t.c.query('.') AS result
			FROM @iDoc.nodes('/Ts') t(c)
			) x

		-- ***test***
		--print @@rowcount
		--select Tag_Name from @Tags
		-- ***test***
		-- create the tagstring
		SET @CodeSection = 'Build tagstring'

		-- This code builds a name=value... string from the @Tags table
		--set @Doc = @i_TagDoc
		SELECT @Doc = coalesce(@Doc + CASE 
					WHEN @Doc = ''
						THEN ''
					ELSE ','
					END, '') + Tag_Name + '=' + Tag_Value
		FROM @Tags
	END

	-- ***test***
	--print 'Test the doc creation'
	--print @Doc
	--print 'End Test'
	-- ***test***
	-- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	-- Process the rule
	SET @Codesection = 'Process the rules'

	-- ***test***
	--print @RuleType
	-- ***test***
	-- Since T-SQL has no real if.. else.. elsif.. elsif.. end structure, I am
	-- going to use a fake loop to short-circuit evaluation. There can be
	-- only one iteration of this loop, if the code falls all the way thru,
	-- there will be a break at the bottom. If somehow, we get past that,
	-- it will terminate since we are at the max count after one iteration
	WHILE @LoopCtr < 1
	BEGIN
		SET @LoopCtr += 1 -- Increment the counter so we can't go round again

		IF @RuleType = 'Condition'
		BEGIN
			-- Call the condition code, This code will return a result set
			EXEC @Result = dbApp.p_Rule_Condition_Resolve @i_RuleCondition
				,@i_RuleName

			BREAK
		END

		--if @Ruletype = 'Existance' begin
		--	if @Param = 'C' begin
		--		if @i_InValue is null or rtrim(ltrim(@i_InValue)) = '' begin
		--			set @o_SuccessFlag = 0
		--			select @ErrorCode = Value from @RuleValues where ValueName = 'ErrorId'
		--			select @ErrorMessage = Value from @RuleValues where ValueName = 'ErrorMsg'
		--			select @TechMsg = Value from @RuleValues where ValueName = 'TechMsg'
		--			set @TechMsg = @TechMsg + @CrLf + @ProcName + ', Character Existance check for - ' + @i_RuleName
		--		end
		--		else begin
		--			set @o_SuccessFlag = 1
		--		end
		--	end else if @Param = 'N' begin
		--		if (isnumeric(@i_InValue) = 0 and @i_InValue is not null) begin
		--			set @ErrorCode = 999999
		--			set @ErrorMessage = 'Bad parameter passed to the rules engine, p_Rule_Controller, @RuleType = Existance'
		--			set @TechMsg = 'A non-numeric parameter was passed in a situation where a valid numeric was expected'
		--			set @TechMsg = @TechMsg + @CrLf + @ProcName + ', numeric Existance check for ' + @i_RuleName
		--			set @o_SuccessFlag = 0
		--			--raiserror(@ErrorMessage, 11, 1)
		--		end
		--		else if @i_InValue is null or cast(@i_InValue as decimal(16,6)) <= 0 begin
		--			set @o_SuccessFlag = 0
		--			select @ErrorCode = Value from @RuleValues where ValueName = 'ErrorId'
		--			select @ErrorMessage = Value from @RuleValues where ValueName = 'ErrorMsg'
		--			select @TechMsg = Value from @RuleValues where ValueName = 'TechMsg'
		--			set @TechMsg = @TechMsg + @CrLf + @ProcName + ', Existance check null or zero ' + @i_RuleName
		--		end else begin
		--			set @o_SuccessFlag = 1
		--		end
		--	end
		--	goto Normal_Exit
		--end
		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		--if @RuleType = 'Boolean' begin -- if we are using a rule where the expression table already exists, this is deprecated code and may be removed.
		--	if @isCode = 0 begin	-- This indicates that we have decomposed the expression
		--		--execute @Result = dbApp.p_Rule_Evaluate_Boolean @RuleId, @Doc, @ReturnValue output
		--		if @ReturnValue = 1 begin
		--			set @o_OutValue = @TruthValue
		--			set @Success = 1
		--			if @TruthResultType = 'MVAL' begin
		--				select 	Rule_Id,
		--						ValueName,
		--						Value,
		--						Qualifier
		--				from @RuleValues
		--				where Rule_Id = @RuleId
		--				  and Result_Type <> 'F'
		--			end
		--		end
		--	end
		--	else if @isCode = 2 begin		-- if the rule is a structured rule
		--		set @Query = @Rulecode
		--		-- ***test***
		--		--print @Query
		--		--print @Doc
		--		-- ***test***
		--		set @ReturnValue = dbApp.fn_Evaluate_Boolean (@Query,@Doc) -- call the evaluator
		--		-- ***test***
		--		--print 'Return Val is ' + isnull(@ReturnValue,'')
		--		-- ***test***
		--		if isnumeric(@ReturnValue) = 1 begin
		--			if cast(cast(@ReturnValue as decimal(16,8)) as tinyint) > 0 begin
		--				set @Success = 1
		--				set @o_OutValue = @TruthValue
		--				--print @TruthValue
		--				if @TruthResultType = 'MVAL' begin
		--					select 	Rule_Id,
		--							ValueName,
		--							Value,
		--							Qualifier
		--					from @RuleValues
		--					where Rule_Id = @RuleId
		--					  and Result_Type <> 'F'
		--				end
		--			end else begin
		--				set @o_OutValue = @FalseValue
		--				set @Success = 1
		--				if @FalseResultType = 'MVAL' begin
		--					select 	Rule_Id,
		--							ValueName,
		--							Value,
		--							Qualifier
		--					from @RuleValues
		--					where Rule_Id = @RuleId
		--					  and Result_Type <> 'T'
		--				end
		--			end
		--			--end
		--		end else begin
		--			set @o_OutValue = @FalseValue
		--			set @Success = 1
		--			if @FalseResultType = 'MVAL' begin
		--				select 	Rule_Id,
		--						ValueName,
		--						Value,
		--						Qualifier
		--				from @RuleValues
		--				where Rule_Id = @RuleId
		--				  and Result_Type <> 'T'
		--			end
		--		end
		--	end
		--end
		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		--
		IF @Ruletype = 'Errorcheck'
		BEGIN
			IF @i_InValue <> 0
			BEGIN
				SET @o_SuccessFlag = 0

				SELECT @ErrorCode = Value
				FROM @RuleValues
				WHERE ValueName = 'ErrorId'

				SELECT @ErrorMessage = Value
				FROM @RuleValues
				WHERE ValueName = 'ErrorMsg'

				SELECT @TechMsg = Value
				FROM @RuleValues
				WHERE ValueName = 'TechMsg'

				SET @TechMsg = @TechMsg + @CrLf + @ProcName + ', Errorcheck ' + @CodeSection + @CrLf + @i_RuleName
			END
			ELSE
			BEGIN
				SET @o_SuccessFlag = 1
			END

			BREAK
		END

		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		--
		IF @RuleType = 'Association'
		BEGIN
			IF @TruthResultType = 'nul'
			BEGIN
				SET @Errorcode = '199999'
				SET @ErrorMessage = 'There is no result type associated with this rule, ' + @i_RuleName
				SET @TechMsg = @ErrorMessage
				SET @o_SuccessFlag = 0

				BREAK
			END

			IF @TruthResultType = 'VAL'
			BEGIN
				SET @o_OutValue = dbApp.fn_Get_Rule_Value_by_Name(@i_RuleName)

				IF @o_OutValue IS NULL
				BEGIN
					SET @ErrorCode = '199999'
					SET @ErrorMessage = 'Unable to get the rule value'
					SET @TechMsg = 'The rule passed, ' + @i_RuleName + ', has no associated value'
					SET @TechMsg = @TechMsg + @CrLf + @ProcName + ', Association check for ' + @i_RuleName
					SET @o_Successflag = 0
				END
				ELSE
				BEGIN
					SET @o_SuccessFlag = 1
				END

				BREAK
			END

			IF @TruthResultType = 'MVAL'
			BEGIN
				IF (
						SELECT count(*)
						FROM @RuleValues
						) = 0
				BEGIN
					SET @ErrorCode = 999999
					SET @ErrorMessage = 'There are no values associated with this rule'
					SET @TechMsg = 'The rule passed, ' + @i_RuleName + ', has no associated value'
					SET @TechMsg = @TechMsg + @CrLf + @ProcName + ', Association check for ' + @i_RuleName
					SET @o_Successflag = 0
				END
				ELSE
				BEGIN
					SELECT Rule_Id
						,ValueName
						,Value
						,Qualifier
					FROM @RuleValues
					WHERE Rule_Id = @RuleId
						AND Result_Type <> 'F'

					SET @o_SuccessFlag = 1
				END

				BREAK
			END
		END

		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		-- ShortBool
		--if @RuleType = 'ShortBool' begin
		--	--print 'Shorbool'
		--	set @ReturnValue = dbApp.fn_Evaluate_Boolean (@RuleCode,@i_TagDoc) -- call the evaluator
		--	if isnumeric(@ReturnValue) = 1 begin
		--		if cast(cast(@ReturnValue as decimal(16,8)) as tinyint) > 0 begin
		--			set @o_OutValue = @TruthValue
		--			set @o_SuccessFlag = 1
		--			if @TruthResultType = 'MVAL' begin
		--				select 	Rule_Id,
		--						ValueName,
		--						Value,
		--						Qualifier
		--				from @RuleValues
		--				where Rule_Id = @RuleId
		--				  and Result_Type <> 'F'
		--			end
		--		end else begin
		--				set @o_SuccessFlag = 0
		--				set @o_OutValue = @FalseValue
		--			if @FalseResultType = 'EVAL' begin
		--				set @o_SuccessFlag = 0
		--				select @ErrorCode = Value from @RuleValues where ValueName = 'ErrorId'
		--				select @ErrorMessage = Value from @RuleValues where ValueName = 'ErrorMsg'
		--				select @TechMsg = Value from @RuleValues where ValueName = 'TechMsg'
		--				set @TechMsg = @TechMsg + @CrLf + @ProcName + ', ShortBool check for ' + @i_RuleName
		--			end
		--		end
		--	end --else begin
		--	goto Normal_Exit
		--end
		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		-- Resolution
		IF @RuleType = 'Resolution'
		BEGIN
			-- ***test***
			--print 'Testing Resolution'
			--print @Query
			--print @Param
			-- ***test***
			IF @isProc = 0
			BEGIN -- this is for non-proc calls
				EXEC @Result = master.dbo.sp_ExecuteSql @Query
					,@Param
					,@P1 = @Outvalue OUTPUT

				IF (@Result <> 0)
				BEGIN
					SET @Error = 99999
					SET @ErrorMessage = 'Evaluation error in p_Rule_Controller'
					SET @TechMsg = 'SQL Error evaluating the dynamic sql'
					SET @TechMsg = @TechMsg + @CrLf + @ProcName + ', Resolution check for ' + @i_RuleName

					RAISERROR (
							@ErrorMessage
							,11
							,1
							)
				END

				IF @OutValue IS NOT NULL
				BEGIN
					SET @Success = 1
					SET @ReturnValue = 1
					SET @o_OutValue = @OutValue
				END -- ReturnValue = 1
			END
			ELSE
				IF @isProc = 1
				BEGIN -- if the rule is a proc or function call
					EXECUTE @ReturnValue = @Query @i_InValue

					IF cast(@ReturnValue AS TINYINT) = 0
						AND @FalseResultType = 'EVAL'
					BEGIN
						SELECT @ErrorCode = Value
						FROM @RuleValues
						WHERE ValueName = 'ErrorId'

						SELECT @ErrorMessage = Value
						FROM @RuleValues
						WHERE ValueName = 'ErrorMsg'

						SELECT @TechMsg = Value
						FROM @RuleValues
						WHERE ValueName = 'TechMsg'

						SET @TechMsg = @TechMsg + @CrLf + @ProcName + ', Resolution check for ' + @i_RuleName
					END
				END

			SET @o_SuccessFlag = @ReturnValue

			BREAK
		END

		-- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		BREAK -- there cannot be a second iteration
	END -- while loop
END TRY

BEGIN CATCH
	PRINT 'Errors occurred'

	IF @Result = 0
	BEGIN
		SELECT @Error = ErrorNumber
			,@ESeverity = ErrorSeverity
			,@EState = ErrorState
			,@EProcedure = ErrorProcedure
			,@ELine = ErrorLine
			,@EMSg = ErrorMessage
		FROM dbApp.f_GetErrorInfo()
	END
END CATCH

-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
IF @Error <> 0
	OR @Errorcode <> 0
BEGIN
	Error_Exit:

	PRINT 'Error!!!'

	SET @Retcode = 0 - isnull(@ErrorCode, 9999)
	SET @TechMsg = 'Error in procedure ' + isnull(@Eprocedure, 'NullProc') + ', ' + convert(VARCHAR(25), getdate(), 121) + @CrLf + 'Error Code    : ' + isnull(cast(@ErrorCode AS VARCHAR), 'Unknown') + @CrLf + 'Error State   : ' + isnull(cast(@EState AS VARCHAR), 'Unknown') + @CrLf + 'Error Severity: ' + isnull(cast(@ESeverity AS VARCHAR), 'Unknown') + @CrLf + 'Error Line    : ' + isnull(cast(@ELine AS VARCHAR), 'Unknown') + @CrLf + 'Error Message : ' + isnull(@TechMsg, 'No Error Message') + @CrLf + 'Sql Server Msg: ' + isnull(@EMSG, 'n/a') + @CrLf

	PRINT @TechMsg
END

RETURN (@Retcode)
GO

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'p_Rule_Controller'
			AND ROUTINE_TYPE = 'Procedure'
		)
BEGIN
	PRINT 'Function dbApp.p_Rule_Controller was created successfully'
	PRINT 'Add security assignment of execute to DBApp_Processor'

	GRANT EXECUTE
		ON dbApp.p_Rule_Controller
		TO DBApp_Processor;
END
ELSE
BEGIN
	PRINT 'Function dbApp.p_Rule_Controller does not exist, create failed'
END

PRINT ''
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '***** End of Procedure script for dbApp.p_Rule_Controller *****'
PRINT '------------------------------------------------------------'
PRINT ''
GO

/* Test
declare		@SqlECode	int
declare		@ECode		int
declare		@EMessage	varchar(400)
declare		@Result		int
declare		@Doc		varchar(8000)
declare		@Rules		varchar(1000)
declare		@Tags		varchar(1000)
declare		@Out		varchar(2500)

create table #RuleValues	(
	Value_Name		varchar(50),
	Value			varchar(1000)
)

-- set the following variables
set @Doc =
set @Rules =
set @Tags =

insert into #RuleValues
execute @Result =  p_Rule_Controller
	@i_Doc					= @Doc,
	@i_RuleName				= @Rules,
	@i_TagDoc				= @Tags,
	@o_OutValue				= @Out output,
	@i_Debug				= 0,
	@i_CallStack			= '',
	--  Standard error handling output parameters
	@SQLErrorCode			= @SqlECode  output,
	@Errorcode				= @ECode  output,
	@ErrorMessage			= @EMessage  output

select	@Out as OutputValue
		@SqlECode as SQLErrorCode,
		@ECode as ECode,
		@EMessage as Message,
		@Result as ResultCode

select * from #RuleValues

drop table #RuleValues

*/
-- =============================================================================
PRINT 'Adding file p_Rule_Engine.sql'
-- =============================================================================
PRINT '------------------------------------------------------------';
PRINT 'Script file for procedure dbApp.p_Rule_Engine';
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '';

--<ProcSetup>
IF (
		SELECT objectProperty(object_id('dbApp.p_Rule_Engine'), 'IsProcedure')
		) = 1
	DROP PROCEDURE dbApp.p_Rule_Engine
GO

CREATE PROCEDURE dbApp.p_Rule_Engine @i_RuleCondition
AS
dbApp.RuleCondition readonly
	,-- Table valued parameter of conditions
	@i_RuleSetName VARCHAR(100) = NULL
	,-- Name of the rule or set
	@i_TagDoc VARCHAR(8000) = NULL
	,-- xml doc of known values
	@i_InValue VARCHAR(1000) = NULL
	,-- value to be evaluated
	@i_EValue INT = NULL
	,-- Error code passed in
	@o_OutValue VARCHAR(2500) = NULL OUTPUT
	,-- output param  to return
	@o_SuccessFlag TINYINT = 1 OUTPUT
	,-- indicates success or failure
	@Errorcode INT = NULL OUTPUT
	,@ErrorMessage VARCHAR(400) = NULL OUTPUT
	,@TechMsg VARCHAR(7500) = NULL OUTPUT AS

-- =pod
/**

Filename: p_Rule_Engine.sql
Author  : Stephen R. McLarnon Sr.
Created : 11/18/2011 7:34:09 AM

Object  : p_Rule_Engine
ObjectType: Stored procedure

Description: The top level evaluation code for resolving rules in the database.
            The calling application executes this procedure passing in up to
            5 input params. The code below, evaluates the params and takes the
            appropriate action.

Params:
Name               | Datatype      | Description
----------------------------------------------------------------------------
@i_RuleCondition	table	        set(s) of conditions passed in.
@i_RuleSetName		varchar(100)	Name of the rule or set
@i_TagDoc			varchar(8000)	xml doc of known values
@i_InValue			varchar(1000)	value to be evaluated
@i_EValue			int				Error code passed in

OutputParams:
----------------------------------------------------------------------------
@o_OutValue			varchar(2500)	output param  to return
@o_SuccessFlag		tinyint			indicates success or failure
@Errorcode			int				,
@ErrorMessage		varchar(400)	= null  output,
@TechMsg			varchar(7500)	= null output

ResultSet:
----------------------------------------------------------------------------
As this is a controller procedure, there are a number of results sets that
might be returned depending on conditions. There can be, however only one
result set returned if at all.

Revisions:
  Ini |    Date     | Description
---------------------------------

End
**/
-- =cut
/*

This procedure is the top level rules procedure

*/
-- all declarations should be placed here
DECLARE @CodeSection VARCHAR(128)

SET @CodeSection = 'ProcDDL'

-- Standard variables
DECLARE @Error INT = 0
DECLARE @Retcode INT = 0
DECLARE @ErrorMsg VARCHAR(255) = ''
DECLARE @Rowcount INT = 0
DECLARE @ProcName VARCHAR(50) = object_name(@@procid)
DECLARE @Result INT = 0
DECLARE @NestLevel INT = @@nestlevel
-- param variables
DECLARE @Doc VARCHAR(8000) = ''
DECLARE @RuleSetName VARCHAR(100) = ''
DECLARE @TagDoc VARCHAR(8000) = ''
DECLARE @InValue VARCHAR(1000) = ''
DECLARE @OutValue VARCHAR(2500) = ''
DECLARE @eValue INT = 0
DECLARE @Success TINYINT = 0
DECLARE @ECode INT = 0
DECLARE @EMsg VARCHAR(400) = ''
DECLARE @tMsg VARCHAR(400) = ''
-- Rule Variables
DECLARE @RuleName VARCHAR(100) = ''
DECLARE @isSet TINYINT = 0
DECLARE @RuleSetType VARCHAR(50) = ''
DECLARE @RuleType VARCHAR(50) = ''
DECLARE @ResultType VARCHAR(50) = ''
-- misc
DECLARE @LoopCtr TINYINT = 0
DECLARE @Ruletable TABLE (
	RuleName VARCHAR(128)
	,isSet TINYINT
	)

SET QUOTED_IDENTIFIER ON
SET @CodeSection = 'ProcInit'

BEGIN TRY
	-- Since T-SQL has no real if.. else.. elsif.. elsif.. end structure, I am
	-- going to use a fake loop to short-circuit evaluation. There can be
	-- only one iteration of this loop, if the code falls all the way thru,
	-- there will be a break at the bottom. If somehow, we get past that,
	-- it will terminate since we are at the max count after one iteration
	WHILE @LoopCtr < 1
	BEGIN
		SET @LoopCtr += 1 -- Increment the counter so we can't go round again
			-- Init from params
		SET @RuleSetName = @i_RuleSetName
		SET @TagDoc = @i_TagDoc
		SET @InValue = @i_InValue
		SET @eValue = @i_EValue

		-- only the rule name is necessary, all other parameters are optional.
		IF @RuleSetName IS NULL
		BEGIN
			SET @Error = 999999
			SET @ErrorMessage = 'No rule name was supplied'
			SET @TechMsg = 'A rule name was not supplied to the p_Rule_Engine proc'
			SET @Success = 0

			RAISERROR (
					@TechMsg
					,16
					,1
					)
		END

		SET @CodeSection = 'ProcCode'

		-- ***test***
		--print 'start of Rule Engine'
		--print @i_Doc
		--print @i_TagDoc
		--print 'End Start'
		-- ***test***
		-- check to see if this is error resolution
		-- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		IF @i_eValue <> 0
		BEGIN
			SELECT @ECode = error
				,@EMsg = description
				,@TMsg = description
				,@Success = 0
			FROM master..sysmessages
			WHERE error = @i_EValue

			BREAK
		END

		IF @i_RuleSetName = 'Error check'
		BEGIN
			SET @Success = 1

			BREAK
		END

		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- if we are not handling an error, get the rule and figure out what to do.
		-- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		-- This gets the correct rule and determines if it is a set or not
		INSERT INTO @RuleTable -- start of union query
		SELECT Rule_Nm
			,--
			0 AS isSet --
		FROM dbApp.DBRule
		WHERE Rule_Nm = @i_RuleSetName --
			--

		SELECT @Rowcount = count(*)
		FROM @RuleTable
		WHERE RuleName = @i_RuleSetName

		IF (@Rowcount = 0)
		BEGIN -- if no rows
			SET @Error = 999998 -- throw an error and exit
			SET @ErrorMessage = 'No maching rule'
			SET @TechMsg = 'No rule was found for the name passed, ' + @i_RuleSetName
			SET @Success = 0

			RAISERROR (
					@ErrorMessage
					,16
					,1
					)
		END
		ELSE
			IF @Rowcount = 1
			BEGIN -- if one row
				SELECT @RuleName = Rulename
					,-- set the variables
					@isSet = isSet
				FROM @Ruletable
			END

		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		-- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		-- rule set processing
		IF @isSet = 0
		BEGIN
			-- Check the rule type, we are looking for association rules.
			SELECT @RuleType = rrt.Rule_Resolution_Type_Cd
			FROM dbApp.DBRule r1
			INNER JOIN DBApp.Rule_Resolution_Type rrt ON rrt.Rule_Resolution_Type_Id = r1.Rule_Resolution_Type_Id
			WHERE r1.Rule_Nm = @i_RuleSetName

			-- This is a shortcut that I added for the convenience of Association lookups.
			IF @RuleType = 'Association'
				AND @ResultType = 'VAL'
			BEGIN
				EXECUTE @Result = dbApp.p_AssociationRuleGetValue @i_RulesetName
					,@OutValue OUTPUT
					,@Success OUTPUT
					,@ECode OUTPUT
					,@eMsg OUTPUT
					,@tMsg OUTPUT

				IF (@Result <> 0)
				BEGIN
					SET @Error = @Result
					SET @ErrorMessage = 'Error executing p_AssociationRuleGetValue'
					SET @TechMsg = @ErrorMessage

					RAISERROR (
							@ErrorMessage
							,16
							,1
							)
				END

				BREAK
			END

			EXECUTE @Result = dbApp.p_Rule_Controller @i_RuleCondition
				,@RuleSetName
				,@TagDoc
				,@InValue
				,@eValue
				,@OutValue OUTPUT
				,@Success OUTPUT
				,@ECode OUTPUT
				,@eMsg OUTPUT
				,@tMsg OUTPUT

			IF (@Result <> 0)
			BEGIN
				SET @Error = @Result
				SET @ErrorMessage = 'Error executing p_Rule_Controller'
				SET @TechMsg = @ErrorMessage

				RAISERROR (
						@ErrorMessage
						,16
						,1
						)
			END
		END

		BREAK -- this will always break the loop on the first iteration
	END -- while
END TRY

BEGIN CATCH
	PRINT 'Errors'
END CATCH

-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
IF @Error = 0
BEGIN
	Normal_Exit:

	SET @o_SuccessFlag = @Success
	SET @o_OutValue = @Outvalue
	SET @ErrorCode = @ECode
	SET @ErrorMessage = @eMsg
	SET @TechMsg = @tMsg
END
ELSE
BEGIN
	Error_Exit:

	SET @ErrorCode = @Error
	SET @Retcode = 0 - isnull(@ErrorCode, 9999)
	SET @o_SuccessFlag = @Success
	SET @o_OutValue = @Outvalue
END

RETURN (@Retcode)
GO

IF EXISTS (
		SELECT *
		FROM information_schema.ROUTINES
		WHERE SPECIFIC_SCHEMA = 'dbApp'
			AND ROUTINE_NAME = 'p_Rule_Engine'
			AND ROUTINE_TYPE = 'Procedure'
		)
BEGIN
	PRINT 'Procedure dbApp.p_Rule_Engine was created successfully'
	PRINT 'Add security assignment of execute to DBApp_Processor'

	GRANT EXECUTE
		ON dbApp.p_Rule_Engine
		TO DBApp_Processor;
END
ELSE
BEGIN
	PRINT 'Procedure dbApp.p_Rule_Engine does not exist, create failed'
END

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT 'End of script file for dbApp.p_Rule_Engine'
PRINT '----------------------------------------------------------------------'
GO

/*
<ProcTest> ////////////////////////////////////////////////////////////////////
declare		@SqlECode	int
declare		@ECode		int
declare		@EMessage	varchar(400)
declare		@Result		int
declare		@Doc		varchar(8000)
declare		@RName		varchar(100)
declare		@TagDoc		varchar(8000)
declare		@In			varchar(1000)
declare		@E			int
declare		@Out		varchar(2500)
declare		@SFlag		tinyint
declare		@TMsg		varchar(400)

set @Doc =
set @RName =
set @TagDoc =

execute @Result =  p_Rule_Engine 	--<ProcParams>
	@i_Doc					= @Doc,			-- generic idoc
	@i_RuleSetName			= @RName,		-- Name of the rule or set
	@i_TagDoc				= @TagDoc, 		-- xml doc of known values
	@i_InValue				= @In,			-- value to be evaluated
	@i_EValue				= @E, 			-- Error code passed in
	@o_OutValue				= @Out output,	-- output param  to return
	@o_SuccessFlag			= @SFlag output,-- indicates success or failure
	@Errorcode				= @ECode  output,
	@ErrorMessage			= @EMessage  output,
	@TechMsg				= @TMsg	output

select  @Out as Outputval,
		@SFlag as SuccessFlag,
		@ECode as ECode,
		@EMessage as Message,
		@Result as ResultCode

</ProcTest> \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
<Todo>
</Todo>
*/
-- =============================================================================
PRINT 'Adding file tr_v_dbRuleIU.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for trigger tr_v_dbRuleIU'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_dbRuleIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP TRIGGER dbApp.tr_v_dbRuleIU

	PRINT 'trigger dbApp.tr_v_dbRuleIU was dropped'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_dbRuleIU does not exist, drop skipped'
END
GO

CREATE TRIGGER dbApp.tr_v_dbRuleIU ON dbApp.v_dbRule
INSTEAD OF INSERT
	,UPDATE
AS
	;

WITH RowData (
	DBRule_Id
	,Rule_Nm
	,Ordinal_Value
	,Active_Fl
	,Rule_Resolution_Type_Id
	,Update_Dtm
	,Update_Ofs
	,Update_Usr
	)
AS (
	SELECT DBRule_Id
		,Rule_Nm
		,Ordinal_Value
		,Active_Fl
		,Rule_Resolution_Type_Id
		,Update_Dtm
		,Update_Ofs
		,Update_Usr
	FROM inserted
	)
MERGE INTO dbApp.dbRule AS tgt
USING Rowdata AS src
	ON tgt.dbRule_Id = src.dbRule_Id
WHEN NOT MATCHED BY target
	THEN
		INSERT (
			Rule_Nm
			,Ordinal_Value
			,Active_Fl
			,Rule_Resolution_Type_Id
			,Update_Dtm
			,Update_Usr
			)
		VALUES (
			Rule_Nm
			,Ordinal_Value
			,Active_Fl
			,Rule_Resolution_Type_Id
			,sysdatetimeoffset()
			,Update_Usr
			)
WHEN MATCHED
	THEN
		UPDATE
		SET Rule_Nm = src.Rule_Nm
			,Ordinal_Value = src.Ordinal_Value
			,Active_Fl = src.Active_Fl
			,Rule_Resolution_Type_Id = src.Rule_Resolution_Type_Id
			,Update_Dtm = sysdatetimeoffset()
			,Update_Usr = src.Update_Usr;
GO

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_dbRuleIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'trigger dbApp.tr_v_dbRuleIU was created successfully.'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_dbRuleIU does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for trigger dbApp.tr_v_dbRule'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file tr_v_Expression_TypeIU.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for trigger tr_v_Expression_TypeIU'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_Expression_TypeIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP TRIGGER dbApp.tr_v_Expression_TypeIU

	PRINT 'trigger dbApp.tr_v_Expression_TypeIU was dropped'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_Expression_TypeIU does not exist, drop skipped'
END
GO

CREATE TRIGGER dbApp.tr_v_Expression_TypeIU ON dbApp.v_Expression_Type
INSTEAD OF INSERT
	,UPDATE
AS
	;

WITH RowData (
	Expression_Type_Id
	,Expression_Type_Cd
	,Expression_Type_Display_Cd
	,Expression_Type_Dsc
	,Active_Fl
	,Sort_Ord
	,Update_Dtm
	,Update_Ofs
	,Update_Usr
	)
AS (
	SELECT Expression_Type_Id
		,Expression_Type_Cd
		,Expression_Type_Display_Cd
		,Expression_Type_Dsc
		,Active_Fl
		,Sort_Ord
		,Update_Dtm
		,Update_Ofs
		,Update_Usr
	FROM inserted
	)
MERGE INTO dbApp.Expression_Type AS tgt
USING Rowdata AS src
	ON tgt.Expression_Type_Id = src.Expression_Type_Id
WHEN NOT MATCHED BY target
	THEN
		INSERT (
			Expression_Type_Cd
			,Expression_Type_Display_Cd
			,Expression_Type_Dsc
			,Active_Fl
			,Sort_Ord
			,Update_Dtm
			,Update_Usr
			)
		VALUES (
			Expression_Type_Cd
			,Expression_Type_Display_Cd
			,Expression_Type_Dsc
			,Active_Fl
			,Sort_Ord
			,sysdatetimeoffset()
			,Update_Usr
			)
WHEN MATCHED
	THEN
		UPDATE
		SET Expression_Type_Cd = src.Expression_Type_Cd
			,Expression_Type_Display_Cd = src.Expression_Type_Display_Cd
			,Expression_Type_Dsc = src.Expression_Type_Dsc
			,Active_Fl = src.Active_Fl
			,Sort_Ord = src.Sort_Ord
			,Update_Dtm = sysdatetimeoffset()
			,Update_Usr = src.Update_Usr;
GO

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_Expression_TypeIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'trigger dbApp.tr_v_Expression_TypeIU was created successfully.'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_Expression_TypeIU does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for trigger dbApp.tr_v_Expression_Type'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file tr_v_ExpressionIU.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for trigger tr_v_ExpressionIU'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_ExpressionIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP TRIGGER dbApp.tr_v_ExpressionIU

	PRINT 'trigger dbApp.tr_v_ExpressionIU was dropped'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_ExpressionIU does not exist, drop skipped'
END
GO

CREATE TRIGGER dbApp.tr_v_ExpressionIU ON dbApp.v_Expression
INSTEAD OF INSERT
	,UPDATE
AS
	;

WITH RowData (
	Expression_Id
	,Expression_Cd
	,Expression_Dsc
	,isCode_Fl
	,isProc_Fl
	,Expression_Type_Id
	,Rule_Cd
	,Param_Ct
	,Response_Fl
	,Return_Tp
	,Param
	,Short_Circut_Fl
	,Active_Fl
	,Update_Usr
	,Update_Dtm
	,Update_Ofs
	)
AS (
	SELECT Expression_Id
		,Expression_Cd
		,Expression_Dsc
		,isCode_Fl
		,isProc_Fl
		,Expression_Type_Id
		,Rule_Cd
		,Param_Ct
		,Response_Fl
		,Return_Tp
		,Param
		,Short_Circut_Fl
		,Active_Fl
		,Update_Usr
		,Update_Dtm
		,Update_Ofs
	FROM inserted
	)
MERGE INTO dbApp.Expression AS tgt
USING Rowdata AS src
	ON tgt.Expression_Id = src.Expression_Id
WHEN NOT MATCHED BY target
	THEN
		INSERT (
			Expression_Cd
			,Expression_Dsc
			,isCode_Fl
			,isProc_Fl
			,Expression_Type_Id
			,Rule_Cd
			,Param_Ct
			,Response_Fl
			,Return_Tp
			,Param
			,Short_Circut_Fl
			,Active_Fl
			,Update_Usr
			,Update_Dtm
			)
		VALUES (
			Expression_Cd
			,Expression_Dsc
			,isCode_Fl
			,isProc_Fl
			,Expression_Type_Id
			,Rule_Cd
			,Param_Ct
			,Response_Fl
			,Return_Tp
			,Param
			,Short_Circut_Fl
			,Active_Fl
			,Update_Usr
			,sysdatetimeoffset()
			)
WHEN MATCHED
	THEN
		UPDATE
		SET Expression_Cd = src.Expression_Cd
			,Expression_Dsc = src.Expression_Dsc
			,isCode_Fl = src.isCode_Fl
			,isProc_Fl = src.isProc_Fl
			,Expression_Type_Id = src.Expression_Type_Id
			,Rule_Cd = src.Rule_Cd
			,Param_Ct = src.Param_Ct
			,Response_Fl = src.Response_Fl
			,Return_Tp = src.Return_Tp
			,Param = src.Param
			,Short_Circut_Fl = src.Short_Circut_Fl
			,Active_Fl = src.Active_Fl
			,Update_Usr = src.Update_Usr
			,Update_Dtm = sysdatetimeoffset();
GO

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_ExpressionIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'trigger dbApp.tr_v_ExpressionIU was created successfully.'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_ExpressionIU does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for trigger dbApp.tr_v_Expression'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file tr_v_Operator_TypeIU.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for trigger tr_v_Operator_TypeIU'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_Operator_TypeIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP TRIGGER dbApp.tr_v_Operator_TypeIU

	PRINT 'trigger dbApp.tr_v_Operator_TypeIU was dropped'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_Operator_TypeIU does not exist, drop skipped'
END
GO

CREATE TRIGGER dbApp.tr_v_Operator_TypeIU ON dbApp.v_Operator_Type
INSTEAD OF INSERT
	,UPDATE
AS
	;

WITH RowData (
	Operator_Type_Id
	,Operator_Type_Cd
	,Operator_Type_Display_Cd
	,Operator_Type_Dsc
	,Active_Fl
	,Sort_Ord
	,Update_Dtm
	,Update_Ofs
	,Update_Usr
	)
AS (
	SELECT Operator_Type_Id
		,Operator_Type_Cd
		,Operator_Type_Display_Cd
		,Operator_Type_Dsc
		,Active_Fl
		,Sort_Ord
		,Update_Dtm
		,Update_Ofs
		,Update_Usr
	FROM inserted
	)
MERGE INTO dbApp.Operator_Type AS tgt
USING Rowdata AS src
	ON tgt.Operator_Type_Id = src.Operator_Type_Id
WHEN NOT MATCHED BY target
	THEN
		INSERT (
			Operator_Type_Cd
			,Operator_Type_Display_Cd
			,Operator_Type_Dsc
			,Active_Fl
			,Sort_Ord
			,Update_Dtm
			,Update_Usr
			)
		VALUES (
			Operator_Type_Cd
			,Operator_Type_Display_Cd
			,Operator_Type_Dsc
			,Active_Fl
			,Sort_Ord
			,sysdatetimeoffset()
			,Update_Usr
			)
WHEN MATCHED
	THEN
		UPDATE
		SET Operator_Type_Cd = src.Operator_Type_Cd
			,Operator_Type_Display_Cd = src.Operator_Type_Display_Cd
			,Operator_Type_Dsc = src.Operator_Type_Dsc
			,Active_Fl = src.Active_Fl
			,Sort_Ord = src.Sort_Ord
			,Update_Dtm = sysdatetimeoffset()
			,Update_Usr = src.Update_Usr;
GO

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_Operator_TypeIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'trigger dbApp.tr_v_Operator_TypeIU was created successfully.'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_Operator_TypeIU does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for trigger dbApp.tr_v_Operator_Type'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file tr_v_OperatorIU.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for trigger tr_v_OperatorIU'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_OperatorIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP TRIGGER dbApp.tr_v_OperatorIU

	PRINT 'trigger dbApp.tr_v_OperatorIU was dropped'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_OperatorIU does not exist, drop skipped'
END
GO

CREATE TRIGGER dbApp.tr_v_OperatorIU ON dbApp.v_Operator
INSTEAD OF INSERT
	,UPDATE
AS
	;

WITH RowData (
	Operator_Id
	,Operator_Cd
	,Operator_Display_Cd
	,Operator_Dsc
	,Operator_Type_Id
	,isBinary
	,Precedence
	,Active_Fl
	,Sort_Ord
	,Update_Dtm
	,Update_Ofs
	,Update_Usr
	)
AS (
	SELECT Operator_Id
		,Operator_Cd
		,Operator_Display_Cd
		,Operator_Dsc
		,Operator_Type_Id
		,isBinary
		,Precedence
		,Active_Fl
		,Sort_Ord
		,Update_Dtm
		,Update_Ofs
		,Update_Usr
	FROM inserted
	)
MERGE INTO dbApp.Operator AS tgt
USING Rowdata AS src
	ON tgt.Operator_Id = src.Operator_Id
WHEN NOT MATCHED BY target
	THEN
		INSERT (
			Operator_Cd
			,Operator_Display_Cd
			,Operator_Dsc
			,Operator_Type_Id
			,isBinary
			,Precedence
			,Active_Fl
			,Sort_Ord
			,Update_Dtm
			,Update_Usr
			)
		VALUES (
			Operator_Cd
			,Operator_Display_Cd
			,Operator_Dsc
			,Operator_Type_Id
			,isBinary
			,Precedence
			,Active_Fl
			,Sort_Ord
			,sysdatetimeoffset()
			,Update_Usr
			)
WHEN MATCHED
	THEN
		UPDATE
		SET Operator_Cd = src.Operator_Cd
			,Operator_Display_Cd = src.Operator_Display_Cd
			,Operator_Dsc = src.Operator_Dsc
			,Operator_Type_Id = src.Operator_Type_Id
			,isBinary = src.isBinary
			,Precedence = src.Precedence
			,Active_Fl = src.Active_Fl
			,Sort_Ord = src.Sort_Ord
			,Update_Dtm = sysdatetimeoffset()
			,Update_Usr = src.Update_Usr;
GO

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_OperatorIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'trigger dbApp.tr_v_OperatorIU was created successfully.'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_OperatorIU does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for trigger dbApp.tr_v_Operator'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file tr_v_Result_NameIU.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for trigger tr_v_Result_NameIU'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_Result_NameIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP TRIGGER dbApp.tr_v_Result_NameIU

	PRINT 'trigger dbApp.tr_v_Result_NameIU was dropped'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_Result_NameIU does not exist, drop skipped'
END
GO

CREATE TRIGGER dbApp.tr_v_Result_NameIU ON dbApp.v_Result_Name
INSTEAD OF INSERT
	,UPDATE
AS
	;

WITH RowData (
	Result_Nm_Id
	,Result_Nm
	,Active_Fl
	,Sort_Ord
	,Update_Dtm
	,Update_Ofs
	,Update_Usr
	)
AS (
	SELECT Result_Nm_Id
		,Result_Nm
		,Active_Fl
		,Sort_Ord
		,Update_Dtm
		,Update_Ofs
		,Update_Usr
	FROM inserted
	)
MERGE INTO dbApp.Result_Name AS tgt
USING Rowdata AS src
	ON tgt.Result_Nm_Id = src.Result_Nm_Id
WHEN NOT MATCHED BY target
	THEN
		INSERT (
			Result_Nm
			,Active_Fl
			,Sort_Ord
			,Update_Dtm
			,Update_Usr
			)
		VALUES (
			Result_Nm
			,Active_Fl
			,Sort_Ord
			,sysdatetime()
			,Update_Usr
			)
WHEN MATCHED
	THEN
		UPDATE
		SET Result_Nm = src.Result_Nm
			,Active_Fl = src.Active_Fl
			,Sort_Ord = src.Sort_Ord
			,Update_Dtm = sysdatetime()
			,Update_Usr = src.Update_Usr;
GO

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_Result_NameIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'trigger dbApp.tr_v_Result_NameIU was created successfully.'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_Result_NameIU does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for trigger dbApp.tr_v_Result_Name'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file tr_v_Rule_AnswerIU.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for trigger tr_v_Rule_AnswerIU'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_Rule_AnswerIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP TRIGGER dbApp.tr_v_Rule_AnswerIU

	PRINT 'trigger dbApp.tr_v_Rule_AnswerIU was dropped'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_Rule_AnswerIU does not exist, drop skipped'
END
GO

CREATE TRIGGER dbApp.tr_v_Rule_AnswerIU ON dbApp.v_Rule_Answer
INSTEAD OF INSERT
	,UPDATE
AS
	;

WITH RowData (
	Rule_Answer_Id
	,DBRule_Id
	,Answer_Name
	,Active_Fl
	,Priority_Val
	,Truth_Fl
	)
AS (
	SELECT Rule_Answer_Id
		,DBRule_Id
		,Answer_Name
		,Active_Fl
		,Priority_Val
		,Truth_Fl
	FROM inserted
	)
MERGE INTO dbApp.Rule_Answer AS tgt
USING Rowdata AS src
	ON tgt.Rule_Answer_Id = src.Rule_Answer_Id
WHEN NOT MATCHED BY target
	THEN
		INSERT (
			DBRule_Id
			,Answer_Name
			,Active_Fl
			,Priority_Val
			,Truth_Fl
			)
		VALUES (
			DBRule_Id
			,Answer_Name
			,Active_Fl
			,Priority_Val
			,Truth_Fl
			)
WHEN MATCHED
	THEN
		UPDATE
		SET DBRule_Id = src.DBRule_Id
			,Answer_Name = src.Answer_Name
			,Active_Fl = src.Active_Fl
			,Priority_Val = src.Priority_Val
			,Truth_Fl = src.Truth_Fl;
GO

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_Rule_AnswerIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'trigger dbApp.tr_v_Rule_AnswerIU was created successfully.'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_Rule_AnswerIU does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for trigger dbApp.tr_v_Rule_AnswerIU'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file tr_v_Rule_Answer_ConditionIU.sql'
-- =============================================================================
PRINT '------------------------------------------------------------';
PRINT 'Trigger script for dbApp.tr_v_Rule_Answer_ConditionIU';
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '';
GO

IF EXISTS (
		SELECT *
		FROM sys.triggers
		WHERE NAME = N'tr_v_Rule_Answer_ConditionIU'
		)
BEGIN
	PRINT 'Trigger dbApp.tr_v_Rule_Answer_ConditionIU exists, dropping'

	DROP TRIGGER dbApp.tr_v_Rule_Answer_ConditionIU

	PRINT 'Trigger dbApp.tr_v_Rule_Answer_ConditionIU dropped'
END
ELSE
BEGIN
	PRINT 'Trigger dbApp.tr_v_Rule_Answer_ConditionIU does not exist, skipping drop'
END

PRINT 'Creating Trigger dbApp.tr_v_Rule_Answer_ConditionIU'
GO

CREATE TRIGGER dbApp.tr_v_Rule_Answer_ConditionIU ON dbApp.v_Rule_Answer_Condition
INSTEAD OF INSERT
	,UPDATE
AS
-- Code goes here
	;

WITH RowData (
	Rule_Answer_Condition_Id
	,Rule_Answer_Id
	,Condition_Nm
	,Condition_Val
	,Active_Fl
	,Add_Dtm
	,Add_Ofs
	,Add_Usr
	,Update_Usr
	,Udate_Dtm
	,Update_Ofs
	)
AS (
	SELECT Rule_Answer_Condition_Id
		,Rule_Answer_Id
		,Condition_Nm
		,Condition_Val
		,Active_Fl
		,cast(Add_Dtm AS DATETIME) AS Add_Dtm
		,datepart(tz, Add_Dtm) AS Add_Ofs
		,Add_Usr
		,Update_Usr
		,cast(Update_Dtm AS DATETIME) AS Update_Dtm
		,datepart(tz, Update_Dtm) AS Update_Ofs
	FROM inserted
	)
MERGE INTO dbApp.Rule_Answer_Condition AS tgt
USING RowData AS src
	ON tgt.Rule_Answer_Condition_Id = src.Rule_Answer_Condition_Id
WHEN NOT MATCHED BY target
	THEN
		INSERT (
			Rule_Answer_Id
			,Condition_Nm
			,Condition_Val
			,Active_Fl
			)
		VALUES (
			Rule_Answer_Id
			,Condition_Nm
			,Condition_Val
			,Active_Fl
			)
WHEN MATCHED
	THEN
		UPDATE
		SET Rule_Answer_Id = src.Rule_Answer_Id
			,Condition_Nm = src.Condition_Nm
			,Condition_Val = src.Condition_Val
			,Active_Fl = src.Active_Fl
			,Update_Usr = system_user
			,Update_Dtm = sysdatetimeoffset();
GO

IF EXISTS (
		SELECT *
		FROM sys.triggers
		WHERE NAME = N'tr_v_Rule_Answer_ConditionIU'
		)
BEGIN
	PRINT 'Trigger dbApp.tr_v_Rule_Answer_ConditionIU exists, Create was successful'
END
ELSE
BEGIN
	PRINT 'Trigger dbApp.tr_v_Rule_Answer_ConditionIU does not exist, create failed'
END

PRINT ''
GO

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT 'End of trigger script';
PRINT '------------------------------------------------------------';
PRINT '';
GO

-- =============================================================================
PRINT 'Adding file tr_v_Rule_Answer_ValueIU.sql'
-- =============================================================================
PRINT '--------------------------------------------------'
PRINT 'Start of creation script for trigger tr_v_Rule_Answer_ValueIU'
PRINT 'Start time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_Rule_Answer_ValueIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	DROP TRIGGER dbApp.tr_v_Rule_Answer_ValueIU

	PRINT 'trigger dbApp.tr_v_Rule_Answer_ValueIU was dropped'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_Rule_Answer_ValueIU does not exist, drop skipped'
END
GO

CREATE TRIGGER dbApp.tr_v_Rule_Answer_ValueIU ON dbApp.v_Rule_Answer_Value
INSTEAD OF INSERT
	,UPDATE
AS
	;

WITH RowData (
	Rule_Answer_Value_Id
	,Rule_Answer_Id
	,Result_Nm_Id
	,Answer_Val
	,Qualifier
	,Active_Fl
	,Update_Dtm
	,Update_OFs
	,Update_Usr
	)
AS (
	SELECT Rule_Answer_Value_Id
		,Rule_Answer_Id
		,Result_Nm_Id
		,Answer_Val
		,Qualifier
		,Active_Fl
		,Update_Dtm
		,Update_Ofs
		,Update_Usr
	FROM inserted
	)
MERGE INTO dbApp.Rule_Answer_Value AS tgt
USING Rowdata AS src
	ON tgt.Rule_Answer_Value_Id = src.Rule_Answer_Value_Id
WHEN NOT MATCHED BY target
	THEN
		INSERT (
			Rule_Answer_Id
			,Result_Nm_Id
			,Answer_Val
			,Qualifier
			,Active_Fl
			)
		VALUES (
			Rule_Answer_Id
			,Result_Nm_Id
			,Answer_Val
			,Qualifier
			,Active_Fl
			)
WHEN MATCHED
	THEN
		UPDATE
		SET Rule_Answer_Id = src.Rule_Answer_Id
			,Result_Nm_Id = src.Result_Nm_Id
			,Answer_Val = src.Answer_Val
			,Qualifier = src.Qualifier
			,Active_Fl = src.Active_Fl
			,Update_Dtm = sysdatetimeoffset()
			,Update_Usr = system_user;
GO

IF EXISTS (
		SELECT *
		FROM sys.triggers tr
		INNER JOIN sys.Objects o ON o.Object_Id = tr.Parent_Id
		INNER JOIN sys.schemas sch ON sch.schema_id = o.schema_id
		WHERE tr.NAME = 'tr_v_Rule_Answer_ValueIU'
			AND sch.NAME = 'dbApp'
		)
BEGIN
	PRINT 'trigger dbApp.tr_v_Rule_Answer_ValueIU was created successfully.'
END
ELSE
BEGIN
	PRINT 'trigger dbApp.tr_v_Rule_Answer_ValueIU does not exist, create failed.'
END

PRINT '--------------------------------------------------'
PRINT 'End of creation script for trigger dbApp.tr_v_Rule_Answer_ValueIU'
PRINT 'End time is: ' + cast(sysdatetime() AS VARCHAR(36))
PRINT '--------------------------------------------------'
GO

-- =============================================================================
PRINT 'Adding file tr_v_Rule_Resolution_TypeIU.sql'
-- =============================================================================
PRINT '------------------------------------------------------------';
PRINT 'Trigger script for dbApp.tr_v_Rule_Resolution_TypeIU';
PRINT 'Start time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT '';

IF EXISTS (
		SELECT *
		FROM sys.triggers
		WHERE NAME = N'tr_v_Rule_Resolution_TypeIU'
		)
BEGIN
	PRINT 'Trigger dbApp.tr_v_Rule_Resolution_TypeIU exists, dropping'

	DROP TRIGGER dbApp.tr_v_Rule_Resolution_TypeIU

	PRINT 'Trigger dbApp.tr_v_Rule_Resolution_TypeIU dropped'
END
ELSE
BEGIN
	PRINT 'Trigger dbApp.tr_v_Rule_Resolution_TypeIU does not exist, skipping drop'
END

PRINT 'Creating Trigger dbApp.tr_v_Rule_Resolution_TypeIU'
GO

CREATE TRIGGER dbApp.tr_v_Rule_Resolution_TypeIU ON dbApp.v_Rule_Resolution_Type
INSTEAD OF INSERT
	,UPDATE
AS
-- Code goes here
	;

WITH RowData (
	Rule_Resolution_Type_Id
	,Rule_Resolution_Type_Cd
	,Rule_Resolution_Type_Display_Cd
	,Rule_Resolution_Type_Dsc
	,Active_Fl
	,Sort_Ord
	,Update_Usr
	,Update_Dtm
	)
AS (
	SELECT Rule_Resolution_Type_Id
		,Rule_Resolution_Type_Cd
		,Rule_Resolution_Type_Display_Cd
		,Rule_Resolution_Type_Dsc
		,Active_Fl
		,Sort_Ord
		,Update_Usr
		,Update_Dtm
	FROM inserted
	)
MERGE INTO dbApp.Rule_Resolution_Type AS tgt
USING RowData AS src
	ON tgt.Rule_Resolution_Type_Id = src.Rule_Resolution_Type_Id
WHEN NOT MATCHED BY target
	THEN
		INSERT (
			Rule_Resolution_Type_Cd
			,Rule_Resolution_Type_Display_Cd
			,Rule_Resolution_Type_Dsc
			,Active_Fl
			,Sort_Ord
			)
		VALUES (
			Rule_Resolution_Type_Cd
			,Rule_Resolution_Type_Display_Cd
			,Rule_Resolution_Type_Dsc
			,Active_Fl
			,Sort_Ord
			)
WHEN MATCHED
	THEN
		UPDATE
		SET Rule_Resolution_Type_Cd = src.Rule_Resolution_Type_Cd
			,Rule_Resolution_Type_Display_Cd = src.Rule_Resolution_Type_Display_Cd
			,Rule_Resolution_Type_Dsc = src.Rule_Resolution_Type_Dsc
			,Active_Fl = src.Active_Fl
			,Sort_Ord = src.Sort_Ord
			,Update_Usr = system_user
			,Update_Dtm = sysdatetimeoffset();
GO

IF EXISTS (
		SELECT *
		FROM sys.triggers
		WHERE NAME = N'tr_v_Rule_Resolution_TypeIU'
		)
BEGIN
	PRINT 'Trigger dbApp.tr_v_Rule_Resolution_TypeIU exists, Create was successful'
END
ELSE
BEGIN
	PRINT 'Trigger dbApp.tr_v_Rule_Resolution_TypeIU does not exist, create failed'
END

PRINT ''
GO

PRINT '';
PRINT 'End time is: ' + cast(sysdatetimeoffset() AS VARCHAR(36));
PRINT 'End of trigger script';
PRINT '------------------------------------------------------------';
PRINT '';
GO


