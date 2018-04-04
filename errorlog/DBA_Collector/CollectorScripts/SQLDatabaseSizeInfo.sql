SET NOCOUNT ON

DECLARE @SQL                varchar(4000)
        ,@SQLVersionMajor   varchar(10)
        ,@Id                int
        ,@DbName            varchar(128)
        ,@CmptLevel         varchar(10)
        ,@Total             int
        
IF OBJECT_ID('tempdb..#FileStats') IS NOT NULL
    DROP TABLE #FileStats

IF OBJECT_ID('tempdb..#DatabaseList') IS NOT NULL
    DROP TABLE #DatabaseList

CREATE TABLE #FileStats
(
	FS_DbName          varchar(128) NULL
	,FS_FileId		    smallint
	,FS_GroupId		    smallint
	,FS_TotalExtents	int
	,FS_UsedExtents	    int
	,FS_LogicalName	    varchar(255)
	,FS_Filename		varchar(255)
	,FS_FileType        varchar(10)
	,FS_FileGroupName   varchar(128)
	,FS_Growth          int
	,FS_GrowthType      varchar(10)
	,FS_MaxSize         int
)

CREATE TABLE #DatabaseList
(
    Id          int IDENTITY(1,1)
    ,Name       varchar(128)
    ,CmptLevel  varchar(10)
)

SET @SQL = 
            '    INSERT INTO #DatabaseList 
                (
                            Name
                            ,CmptLevel
                )
            '

SET @SQLVersionMajor = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) - 1)


IF @SQLVersionMajor = '8'
    BEGIN
        SET @SQL = @SQL + 
                        '
                            SELECT      name
                                        ,cmptlevel
                            FROM        sysdatabases                
                            WHERE       DATABASEPROPERTY(name, ''IsOffline'') = 0
                              AND       DATABASEPROPERTY(name, ''IsInRecovery'') = 0
                              AND       DATABASEPROPERTY(name, ''IsShutDown'') = 0
                              AND       DATABASEPROPERTY(name, ''IsSuspect'') = 0
                              AND       DATABASEPROPERTY(name, ''IsNotRecovered'') = 0
                              AND       DATABASEPROPERTY(name, ''IsInStandBy'')= 0  
                            ORDER BY    name                          
                        '
                        
        EXECUTE (@SQL)
    END                                
ELSE
    BEGIN
        SET @SQL = @SQL + 
                        '
                            SELECT      name 
                                        ,compatibility_level
                            FROM        sys.databases
                            WHERE       state = 0 -- ONLINE
                            ORDER BY    name                     
                        '
                        
        EXECUTE (@SQL)    
    END

SELECT @Total = COUNT(*) FROM #DatabaseList

SET @Id = 1

WHILE (@Id <= @Total)
BEGIN
    SELECT      @Id = ISNULL(Id, 0)
                ,@DbName = Name
                ,@CmptLevel = CmptLevel
    FROM        #DatabaseList
    WHERE       Id = @Id

    SET @SQL = 'USE ' + QUOTENAME(@DbName) +';'
    SET @SQL = @SQL + 
                '
                    INSERT INTO #FileStats
                    (
	                    FS_FileId
	                    ,FS_GroupId
	                    ,FS_TotalExtents
	                    ,FS_UsedExtents
	                    ,FS_LogicalName
	                    ,FS_Filename
                    )
'    
    SET @SQL = @SQL + 'EXECUTE (''DBCC showfilestats WITH NO_INFOMSGS'')'

    EXECUTE (@SQL)

    UPDATE      #FileStats
       SET      FS_DbName = @DbName
    WHERE       FS_DbName IS NULL

    IF @SQLVersionMajor = '8' 
        BEGIN
            SET @SQL = '
            
                            INSERT INTO #FileStats
                            (
	                            FS_DbName
	                            ,FS_FileId
	                            ,FS_GroupId
	                            ,FS_TotalExtents
	                            ,FS_UsedExtents
	                            ,FS_LogicalName
	                            ,FS_Filename
                            )
                            SELECT      ''' + @DbName + '''
                                        ,fileid
                                        ,groupid
                                        ,CEILING(size * 8 / 64)
                                        ,NULL
                                        ,RTRIM(name)
                                        ,RTRIM(filename)
                            FROM        ' + QUOTENAME(@DbName) + '.dbo.sysfiles
                            WHERE       groupid = 0    
                       '                                                
        
            EXECUTE (@SQL)
        
            SET @SQL = '
                            UPDATE      #FileStats
                               SET      FS_FileType = CASE WHEN (B.status & 0x40) > 0 THEN ''LOG'' ELSE ''ROWS'' END
                                        ,FS_FileGroupName =  C.groupname
                                        ,FS_Growth = CASE WHEN (B.status & 0x100000) > 0 THEN B.growth ELSE CEILING(B.growth * 0.0078125) END
                                        ,FS_GrowthType = CASE WHEN (B.status & 0x100000) > 0 THEN ''Percent'' ELSE ''MB'' END
                                        ,FS_MaxSize = CEILING(B.maxsize * 0.0078125)
                            FROM        #FileStats A
                                            JOIN ' + QUOTENAME(@DbName) + '.dbo.sysfiles        B ON A.FS_FileId = B.fileid
                                            LEFT JOIN ' + QUOTENAME(@DbName) + '.dbo.sysfilegroups	C ON B.groupid	= C.groupid
                            WHERE       A.FS_DbName = ''' + @DbName + '''
                       '
            EXECUTE (@SQL)                   
        END        
    ELSE
        BEGIN
            SET @SQL = '
            
                            INSERT INTO #FileStats
                            (
	                            FS_DbName
	                            ,FS_FileId
	                            ,FS_GroupId
	                            ,FS_TotalExtents
	                            ,FS_UsedExtents
	                            ,FS_LogicalName
	                            ,FS_Filename
                            )
                            SELECT      ''' + @DbName + '''
                                        ,file_id
                                        ,data_space_id
                                        ,CEILING((size * 8) / 64)
                                        ,NULL
                                        ,name
                                        ,physical_name
                            FROM        ' + QUOTENAME(@DbName) + '.sys.database_files
                            WHERE       type_desc = ''LOG''
                       '                                                
        
            EXECUTE (@SQL)

            SET @SQL = '
                            UPDATE      #FileStats
                               SET      FS_FileType = B.type_desc
                                        ,FS_FileGroupName =  C.name
                                        ,FS_Growth = CASE WHEN B.is_percent_growth = 1 THEN B.growth ELSE CEILING((B.growth * 0.0078125)) END
                                        ,FS_GrowthType = CASE WHEN B.is_percent_growth = 1 THEN ''Percent'' ELSE ''MB'' END
                                        ,FS_MaxSize = CEILING(B.max_size * 0.0078125)
                            FROM        #FileStats A
                                            JOIN ' + QUOTENAME(@DbName) + '.sys.database_files  B ON A.FS_FileId = B.file_id
                                            LEFT JOIN ' + QUOTENAME(@DbName) + '.sys.filegroups	    C ON B.data_space_id = C.data_space_id
                            WHERE       A.FS_DbName = ''' + @DbName + '''
                       '
            EXECUTE (@SQL)                               
        END
                        
    SET @Id = @Id + 1        
END


SELECT		FS_DbName + '<1>' +
			    FS_FileType + '<2>' +
			    ISNULL(FS_FileGroupName, '') + '<3>' +
			    FS_LogicalName COLLATE DATABASE_DEFAULT + '<4>' +
			    CAST((FS_TotalExtents * 64) / 1024.0 AS varchar(15)) + '<5>' +
			    ISNULL(CAST((FS_UsedExtents * 64) / 1024.0 AS varchar(15)), '') + '<6>' + 
			    ISNULL(CAST(((FS_TotalExtents - FS_UsedExtents) * 64) / 1024.0 AS varchar(15)), '') + '<7>' +
			    CAST(FS_MaxSize AS varchar(15)) + '<8>' +
			    FS_Filename + '<9>' +
			    ISNULL(CAST(FS_Growth AS varchar(15)), '') + '<10>' +
			    FS_GrowthType
FROM		#FileStats 


/*

SELECT		FS_DbName									            AS [Database]
			,FS_FileType											AS [Type]
			,FS_LogicalName											AS [LogicalName]
			,(FS_TotalExtents * 64) / 1024.0						AS [TotalSpace_MB]
			,(FS_UsedExtents * 64) / 1024.0							AS [UsedSpace_MB]
			,((FS_TotalExtents - FS_UsedExtents) * 64) / 1024.0		AS [UnusedSpace_MB]
			,((FS_TotalExtents - FS_UsedExtents)/(FS_TotalExtents * 1.0)) * 100.0		AS [Percent_Unused]
			,FS_MaxSize                                             AS [MaxSize]
			,FS_Filename										    AS [PhysicalName]
			,FS_FileGroupName                                       AS [FileGroup]
			,FS_Growth                                              AS [Growth]
			,FS_GrowthType                                          AS [GrowthType]
FROM		#FileStats 
*/