/* 
   *******************************************************************************
    ENVIRONMENT:    SQL 2000 & UP

	NAME:           SQLINSTALLDATEINFO

    DESCRIPTION:    THIS SCRIPT WILL LOOK INTO UNINSTALL REGISTRY INFORMATION 
                    TO GET THE SQL INSTALL DATE INFORMATION
                    
    INPUT:          N/A

    OUTPUT:         RETURNS A RESULTSET OF INSTALL DATE INFO
                    
    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------
    AB82086        03/13/2011 1.00     INITIAL CREATION
   *******************************************************************************
*/
USE [master]
GO
SET NOCOUNT ON

DECLARE @Key                varchar(256)
        ,@ProductCode       varchar(50)
        ,@InstallDate       varchar(10)
        ,@SQLVersionMajor   int

-- GRAB SQL MAJOR VERSION NUMBER
SET @SQLVersionMajor = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) - 1)

-- IF SQL VERSION IS 8, NEED TO LOOK AT A DIFFERENT KEY
IF @SQLVersionMajor = 8
    BEGIN
        SET @ProductCode = 'Microsoft SQL Server 2000' + CASE 
                                                            WHEN CAST(ISNULL(SERVERPROPERTY('InstanceName'), '') AS varchar(128)) = ''  THEN  CAST(ISNULL(SERVERPROPERTY('InstanceName'), '') AS varchar(128))
                                                            ELSE ' (' + CAST(ISNULL(SERVERPROPERTY('InstanceName'), '') AS varchar(128))  + ')'
                                                         END

        -- GO IN UNINSTALL INFO TO GRAB INSTALL DATE
        SET @Key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + @ProductCode 

        SET @InstallDate = NULL							    
        EXECUTE master.dbo.xp_regread   'HKEY_LOCAL_MACHINE'
							            ,@Key
							            ,'InstallDate'
							            ,@InstallDate OUTPUT							    

    END
ELSE
    -- FOR 2005 & 2008
    BEGIN
        SET @ProductCode = NULL

        -- GRAB PRODUCT CODE FOR INSTANCE
        SET @Key = 'SOFTWARE\Microsoft\MSSQLServer\Setup\'
        EXECUTE master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE'
							                    ,@Key
							                    ,'ProductCode'
							                    ,@ProductCode OUTPUT

        -- GO IN UNINSTALL INFO TO GRAB INSTALL DATE
        SET @Key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + @ProductCode + '\'

        SET @InstallDate = NULL							    
        EXECUTE master.dbo.xp_regread   'HKEY_LOCAL_MACHINE'
							            ,@Key
							            ,'InstallDate'
							            ,@InstallDate OUTPUT	
							            
    END				    
    							    
SELECT      CAST(ISNULL(SERVERPROPERTY('ServerName'), 'NULL') AS varchar(128))          AS SQLServer
            ,CAST(ISNULL(SERVERPROPERTY('Edition'), 'NULL') AS varchar(128))            AS Edition
            ,CAST(ISNULL(SERVERPROPERTY('ProductVersion'), 'NULL') AS varchar(128))     AS Version
            ,CAST(ISNULL(SERVERPROPERTY('ProductLevel'), 'NULL') AS varchar(128))       AS ProductLevel
            ,CONVERT(char(10), CAST(@InstallDate AS datetime), 101)                     AS InstallDate		    
            ,@ProductCode                                                               AS DBServicesProductCode
            ,'HKEY_LOCAL_MACHINE\' + @Key                                               AS RegistryKey
            
            
