
BEGIN TRY


    ----------------------------------------------------------
    -- Drop Role Assignment
    ----------------------------------------------------------
    
    IF EXISTS(SELECT 1
               FROM sys.database_role_members AS drm
               INNER JOIN sys.database_principals AS dp
                   ON drm.role_principal_id = dp.principal_id
               INNER JOIN sys.database_principals AS dp2
                   ON dp2.principal_id = drm.member_principal_id
                       AND dp2.[type] = dp.[type]
               WHERE dp.[type] = 'R'
                 AND dp.[name] = 'prole_ECRX_Application'
                 AND dp2.name = 'urole_RAS_Application')
    BEGIN
        -- drop urole from prole
        exec sys.sp_droprolemember 'prole_ECRX_Application', 'urole_ECRX_Application';

        IF NOT EXISTS( SELECT 1
                       FROM sys.database_role_members AS drm
                       INNER JOIN sys.database_principals AS dp
                           ON drm.role_principal_id = dp.principal_id
                       INNER JOIN sys.database_principals AS dp2
                           ON dp2.principal_id = drm.member_principal_id
                               AND dp2.[type] = dp.[type]
                       WHERE dp.[type] = 'R'
                         AND dp.[name] = 'prole_ECRX_Application'
                         AND dp2.name = 'urole_RAS_Application' )
            BEGIN
                PRINT '<<< Dropped urole to prole >>>';
            END;
        ELSE
            BEGIN
                RAISERROR('Drop of Role to Role assignment Failed, %s <-- %s',16,1,'prole_ECRX_Application','urole_ECRX_Application');
            END;
                    
    END;
    ELSE
    BEGIN
        PRINT 'urole_ECRX_Application to prole_ECRX_Application Role assignment doesn''t exist. No Operation required.';
    END;

    IF EXISTS(SELECT 1
               FROM sys.database_role_members AS drm
               INNER JOIN sys.database_principals AS dp
                   ON drm.role_principal_id = dp.principal_id
               INNER JOIN sys.database_principals AS dp2
                   ON dp2.principal_id = drm.member_principal_id
               WHERE dp.[type] = 'R'
                   AND dp2.[type] = 'U'
                   AND dp.[name] = 'urole_ECRX_Application'
                   AND dp2.name = '$(ECRXUser)')
    BEGIN
        -- drop ECRXUser from urole
        exec sys.sp_droprolemember 'urole_ECRX_Application', N'$(ECRXUser)';

        IF NOt EXISTS( SELECT 1
                       FROM sys.database_role_members AS drm
                       INNER JOIN sys.database_principals AS dp
                           ON drm.role_principal_id = dp.principal_id
                       INNER JOIN sys.database_principals AS dp2
                           ON dp2.principal_id = drm.member_principal_id
                       WHERE dp.[type] = 'R'
                           AND dp2.[type] = 'U'
                           AND dp.[name] = 'urole_ECRX_Application'
                           AND dp2.name = '$(ECRXUser)' )
            BEGIN
                PRINT '<<< Dropped User to urole >>>';
            END;
        ELSE
            BEGIN
                RAISERROR('Drop of User to Role assignment Failed, %s <-- %s',16,1,'urole_ECRX_Application', N'$(ECRXUser)');
            END;
    END;
    ELSE
    BEGIN
        PRINT 'user to urole_ECRX_Application Role assignment doesn''t exist. No Operation required.';
    END;
    
    
    IF EXISTS(SELECT 1
               FROM sys.database_role_members AS drm
               INNER JOIN sys.database_principals AS dp
                   ON drm.role_principal_id = dp.principal_id
               INNER JOIN sys.database_principals AS dp2
                   ON dp2.principal_id = drm.member_principal_id
                       AND dp2.[type] = dp.[type]
               WHERE dp.[type] = 'R'
                   AND dp.[name] = 'db_datareader'
                   AND dp2.name = 'prole_ECRX_Application')
    BEGIN
        -- Drop prole from db_Datareader role 
        exec sys.sp_droprolemember 'db_datareader', 'prole_ECRX_Application';
        
        IF NOT EXISTS( SELECT 1
                       FROM sys.database_role_members AS drm
                       INNER JOIN sys.database_principals AS dp
                           ON drm.role_principal_id = dp.principal_id
                       INNER JOIN sys.database_principals AS dp2
                           ON dp2.principal_id = drm.member_principal_id
                               AND dp2.[type] = dp.[type]
                       WHERE dp.[type] = 'R'
                           AND dp.[name] = 'db_datareader'
                           AND dp2.name = 'prole_ECRX_Application' )
            BEGIN
                PRINT '<<< Dropped urole to prole >>>';
            END;
        ELSE
            BEGIN
                RAISERROR('Drop of Role to Role assignment Failed, %s <-- %s',16,1,'db_datareader','prole_ECRX_Application');
            END;        
    END;
    ELSE
    BEGIN
        PRINT 'prole_ECRX_Application to db_datareader Role assignment doesn''t exist. No Operation required.';
    END;

    ----------------------------------------------------------
    -- create the database roles
    ----------------------------------------------------------
    
    -- Create the user role in the OnDemandDataAccess database
    IF EXISTS( SELECT 1
               FROM sys.database_principals
               WHERE name = N'urole_ECRX_Application'
                 AND type = 'R' )
        BEGIN
            IF EXISTS( SELECT 1
                       FROM sys.database_role_members AS drm
                       INNER JOIN sys.database_principals AS dp
                           ON drm.role_principal_id = dp.principal_id
                       INNER JOIN sys.database_principals AS dp2
                           ON dp2.principal_id = drm.member_principal_id
                       WHERE dp.[type] = 'R'
                           --AND dp2.[type] = 'U'
                           AND dp.[name] = 'urole_ECRX_Application')
                PRINT 'Other users are assigned to the role. Do not drop it now';
            ELSE
            BEGIN
                DROP ROLE urole_ECRX_Application;
                
                --check if created successfully
                IF NOT EXISTS( SELECT 1
                               FROM sys.database_principals
                               WHERE name = N'urole_ECRX_Application'
                                 AND type IN( 'R' ))
                    BEGIN
                        PRINT '<<< Dropped ROLE urole_ECRX_Application >>>';
                    END;
                ELSE
                    BEGIN
                        RAISERROR('Role - %s Drop Failed',16,1,'urole_ECRX_Application');
                    END;
            END;
        END;
    ELSE
        BEGIN
            PRINT 'Role - urole_ECRX_Application doesn''t  exist. No Operation required.';
        END;


    -- Create the permissions role in the OnDemandDataAccess database
    IF EXISTS( SELECT 1
               FROM sys.database_principals
               WHERE name = N'prole_ECRX_Application'
                 AND type = 'R' )
        BEGIN
            IF EXISTS( SELECT 1
                       FROM sys.database_role_members AS drm
                       INNER JOIN sys.database_principals AS dp
                           ON drm.role_principal_id = dp.principal_id
                       INNER JOIN sys.database_principals AS dp2
                           ON dp2.principal_id = drm.member_principal_id
                       WHERE dp.[type] = 'R'
                           --AND dp2.[type] = 'U'
                           AND dp.[name] = 'prole_ECRX_Application')
                PRINT 'Other users are assigned to the role. Do not drop it now';
            ELSE
            BEGIN
        
                DROP ROLE prole_ECRX_Application;

                IF NOT EXISTS( SELECT 1
                               FROM sys.database_principals
                               WHERE name = N'prole_ECRX_Application'
                                 AND type IN( 'R' ))
                    BEGIN
                        PRINT '<<< Dropped ROLE prole_ECRX_Application >>>';
                    END;
                ELSE
                    BEGIN
                        RAISERROR('Role %s Drop Failed',16,1,'prole_ECRX_Application');
                    END;            
            END;
        END;
    ELSE
        BEGIN
            PRINT 'Role - prole_ECRX_Application doesn''t exist. No Operation required.';
        END;
    
    
    --drop the user
    IF EXISTS
           (SELECT 1
             FROM sys.database_principals
             WHERE name = N'$(ECRXUser)' 
             AND type IN ('U'))
    BEGIN
        DROP USER [$(ECRXUser)];
        PRINT '<<< USER $(ECRXUser) Dropped IN the DATABASE >>>';
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


