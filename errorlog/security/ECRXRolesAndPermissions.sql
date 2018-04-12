/***
================================================================================
 Name        : ECRXRolesAndPermissions.SQL
 Author      : VChaudhary
 Description : This script will create a new role and grant execute permissions to the bissec procedures.
                The ECRX user will then be assigned to the role.
 Date        : 20140523
-------------------------------------------------------------------------------
Rev          :
-------------------------------------------------------------------------------
===============================================================================
***/
BEGIN TRY

    ----------------------------------------------------------
    -- create user in the db if doesn't exist already
    ----------------------------------------------------------
    -- Create the UI user in the BIS database
    IF NOT  EXISTS (SELECT 1 
                    FROM sys.database_principals 
                    WHERE name = N'$(ECRXUser)'
                        AND type IN ('U','S'))
    CREATE USER [$(ECRXUser)] WITH DEFAULT_SCHEMA=dbo;
    
    IF EXISTS
           (SELECT 1
             FROM sys.database_principals
             WHERE name = N'$(ECRXUser)' 
             AND type IN ('U'))
    BEGIN
      PRINT '<<< CREATED USER $(ECRXUser) IN DATABASE >>>';
    END;
        
    ----------------------------------------------------------
    -- create the database roles
    ----------------------------------------------------------
    
    -- Create the user role in the OnDemandDataAccess database
    IF NOT EXISTS( SELECT 1
                   FROM sys.database_principals
                   WHERE name = N'urole_ECRX_Application'
                     AND type = 'R' )
        BEGIN
            CREATE ROLE urole_ECRX_Application AUTHORIZATION dbo;
            
            --check if created successfully
            IF EXISTS( SELECT 1
                       FROM sys.database_principals
                       WHERE name = N'urole_ECRX_Application'
                         AND type IN( 'R' ))
                BEGIN
                    PRINT '<<< CREATED ROLE urole_ECRX_Application >>>';
                END;
            ELSE
                BEGIN
                    RAISERROR('Role - %s creation Failed',16,1,'urole_ECRX_Application');
                END;
        END;
    ELSE
        BEGIN
            PRINT 'Role - urole_ECRX_Application already exists. No Operation required.';
        END;


    -- Create the permissions role in the OnDemandDataAccess database
    IF NOT EXISTS( SELECT 1
                   FROM sys.database_principals
                   WHERE name = N'prole_ECRX_Application'
                     AND type = 'R' )
        BEGIN
            CREATE ROLE prole_ECRX_Application AUTHORIZATION dbo;

            IF EXISTS( SELECT 1
                       FROM sys.database_principals
                       WHERE name = N'prole_ECRX_Application'
                         AND type IN( 'R' ))
                BEGIN
                    PRINT '<<< CREATED ROLE prole_ECRX_Application >>>';
                END;
            ELSE
                BEGIN
                    RAISERROR('Role %s creation Failed',16,1,'prole_ECRX_Application');
                END;            
            
        END;
    ELSE
        BEGIN
            PRINT 'Role - prole_ECRX_Application already exists. No Operation required.';
        END;
    
    

    ----------------------------------------------------------
    -- Role Assignment
    ----------------------------------------------------------
    
    -- Add urole to prole
    EXEC sys.sp_addrolemember 'prole_ECRX_Application' , 'urole_ECRX_Application';

    IF EXISTS( SELECT 1
               FROM sys.database_role_members AS drm
               INNER JOIN sys.database_principals AS dp
                   ON drm.role_principal_id = dp.principal_id
               INNER JOIN sys.database_principals AS dp2
                   ON dp2.principal_id = drm.member_principal_id
                       AND dp2.[type] = dp.[type]
               WHERE dp.[type] = 'R'
                 AND dp.[name] = 'prole_ECRX_Application'
                 AND dp2.name = 'urole_ECRX_Application' )
        BEGIN
            PRINT '<<< ADDED urole_ECRX_Application to prole_ECRX_Application >>>';
        END;
    ELSE
        BEGIN
            RAISERROR('Role to Role assignment Failed, %s <-- %s',16,1,'prole_ECRX_Application','urole_ECRX_Application');
        END;



    -- Add the user specified as a role member -- add ECRXUser to urole
    EXEC sys.sp_addrolemember 'urole_ECRX_Application' , N'$(ECRXUser)';

    IF EXISTS( SELECT 1
               FROM sys.database_role_members AS drm
               INNER JOIN sys.database_principals AS dp
                   ON drm.role_principal_id = dp.principal_id
               INNER JOIN sys.database_principals AS dp2
                   ON dp2.principal_id = drm.member_principal_id
               WHERE dp.[type] = 'R'
                   AND dp2.[type] IN ('U','S')
                   AND dp.[name] = 'urole_ECRX_Application'
                   AND dp2.name = '$(ECRXUser)' )
        BEGIN
            PRINT '<<< ADDED User to urole >>>';
        END;
    ELSE
        BEGIN
            RAISERROR('User to Role assignment Failed, %s <-- %s',16,1,'urole_ECRX_Application', N'$(ECRXUser)');
        END;
        
    ----------------------------------------------------------
    -- Grant Permissions to the PRole
    ----------------------------------------------------------
    

    --Grant permission to BISSec.ORGANIZATION
    IF OBJECT_ID( 'BISSec.ORGANIZATION' , 'U' )IS NOT NULL
        BEGIN
            --Grant permissions
            GRANT SELECT ON OBJECT::BISSec.ORGANIZATION TO prole_ECRX_Application;
            
            --check if succeeded
            IF EXISTS(SELECT 1
                        FROM sys.database_principals dp
                        INNER JOIN sys.database_permissions dp2
                            ON dp.principal_id = dp2.grantee_principal_id
                        INNER JOIN sys.objects o
                            ON o.object_id = dp2.major_id
                        INNER JOIN sys.schemas s 
                            ON s.schema_id = o.schema_id
                        WHERE dp.name = 'prole_ECRX_Application'
                            AND dp.type_desc = 'DATABASE_ROLE'
                            AND dp2.permission_name = 'SELECT'
                            AND dp2.state_desc = 'GRANT'
                            AND s.name = 'BISSec'
                            AND o.name = 'ORGANIZATION')
                BEGIN
                    PRINT 'SELECT Permissions Granted ON BISSec.ORGANIZATION TO prole_ECRX_Application';
                END;
            ELSE
                BEGIN
                    RAISERROR('SELECT Permissions ON BISSec.ORGANIZATION TO prole_ECRX_Application Failed.',16,1);
                END;   
        END;
    ELSE
        BEGIN
             RAISERROR('ERROR: Could Not Find BISSec.ORGANIZATION TABLE',16,1);
        END;
        
    --Grant permission to aga.Exceptions
    IF OBJECT_ID( 'aga.Exceptions' , 'U' )IS NOT NULL
        BEGIN
            --Grant permissions
            GRANT INSERT ON OBJECT::aga.Exceptions TO prole_ECRX_Application;
            
            --check if succeeded
            IF EXISTS(SELECT 1
                        FROM sys.database_principals dp
                        INNER JOIN sys.database_permissions dp2
                            ON dp.principal_id = dp2.grantee_principal_id
                        INNER JOIN sys.objects o
                            ON o.object_id = dp2.major_id
                        INNER JOIN sys.schemas s 
                            ON s.schema_id = o.schema_id
                        WHERE dp.name = 'prole_ECRX_Application'
                            AND dp.type_desc = 'DATABASE_ROLE'
                            AND dp2.permission_name = 'INSERT'
                            AND dp2.state_desc = 'GRANT'
                            AND s.name = 'aga'
                            AND o.name = 'Exceptions')
                BEGIN
                    PRINT 'INSERT Permissions Granted ON aga.Exceptions TO prole_ECRX_Application';
                END;
            ELSE
                BEGIN
                    RAISERROR('INSERT Permissions ON aga.Exceptions TO prole_ECRX_Application Failed.',16,1);
                END;   
        END;
    ELSE
        BEGIN
             RAISERROR('ERROR: Could Not Find aga.Exceptions TABLE',16,1);
        END;     
        
    --Grant permission to aga.Account_Group
    IF OBJECT_ID( 'aga.Account_Group' , 'U' )IS NOT NULL
        BEGIN
            --Grant permissions
            GRANT SELECT ON OBJECT::aga.Account_Group TO prole_ECRX_Application;
            
            --check if succeeded
            IF EXISTS(SELECT 1
                        FROM sys.database_principals dp
                        INNER JOIN sys.database_permissions dp2
                            ON dp.principal_id = dp2.grantee_principal_id
                        INNER JOIN sys.objects o
                            ON o.object_id = dp2.major_id
                        INNER JOIN sys.schemas s 
                            ON s.schema_id = o.schema_id
                        WHERE dp.name = 'prole_ECRX_Application'
                            AND dp.type_desc = 'DATABASE_ROLE'
                            AND dp2.permission_name = 'SELECT'
                            AND dp2.state_desc = 'GRANT'
                            AND s.name = 'aga'
                            AND o.name = 'Account_Group')
                BEGIN
                    PRINT 'SELECT Permissions Granted ON aga.Account_Group TO prole_ECRX_Application';
                END;
            ELSE
                BEGIN
                    RAISERROR('SELECT Permissions ON aga.Account_Group TO prole_ECRX_Application Failed.',16,1);
                END;   
        END;
    ELSE
        BEGIN
             RAISERROR('ERROR: Could Not Find aga.Account_Group TABLE',16,1);
        END;                
        
    --Grant permission to aga.Account_Group
    IF OBJECT_ID( 'aga.Account_Group' , 'U' )IS NOT NULL
        BEGIN
            --Grant permissions
            GRANT UPDATE ON OBJECT::aga.Account_Group TO prole_ECRX_Application;
            
            --check if succeeded
            IF EXISTS(SELECT 1
                        FROM sys.database_principals dp
                        INNER JOIN sys.database_permissions dp2
                            ON dp.principal_id = dp2.grantee_principal_id
                        INNER JOIN sys.objects o
                            ON o.object_id = dp2.major_id
                        INNER JOIN sys.schemas s 
                            ON s.schema_id = o.schema_id
                        WHERE dp.name = 'prole_ECRX_Application'
                            AND dp.type_desc = 'DATABASE_ROLE'
                            AND dp2.permission_name = 'UPDATE'
                            AND dp2.state_desc = 'GRANT'
                            AND s.name = 'aga'
                            AND o.name = 'Account_Group')
                BEGIN
                    PRINT 'UPDATE Permissions Granted ON aga.Account_Group TO prole_ECRX_Application';
                END;
            ELSE
                BEGIN
                    RAISERROR('UPDATE Permissions ON aga.Account_Group TO prole_ECRX_Application Failed.',16,1);
                END;   
        END;
    ELSE
        BEGIN
             RAISERROR('ERROR: Could Not Find aga.Account_Group TABLE',16,1);
        END;                
END TRY

--catch any error        
BEGIN CATCH
    --rollback if there are any uncommitted transactions    	
    IF XACT_STATE( ) <> 0
        BEGIN
            ROLLBACK;
        END;

    -- Error variables
    DECLARE @errmsg nvarchar( 4000 );
    DECLARE @errsev int;
    DECLARE @errstate int;
        
    --set the error variables
    SET @errmsg = ERROR_MESSAGE( );
    SET @errsev = ERROR_SEVERITY( );
    SET @errstate = ERROR_STATE( );
    			            
    --raise the actual error
    RAISERROR( @errmsg , @errsev , @errstate );
END CATCH;


GO


