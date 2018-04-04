SET NOCOUNT ON

DECLARE @SQL                varchar(4000)
        ,@SQLVersionMajor   int  
        ,@Database          varchar(128)

CREATE TABLE #RawData
(
    Info        varchar(4000)
)
        
SET @SQLVersionMajor = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) - 1)

IF @SQLVersionMajor = '8'
    BEGIN
        DECLARE CURSOR_DISTRIB CURSOR FAST_FORWARD
        FOR
            SELECT      name
            FROM        sysdatabases
            WHERE       CASE WHEN (category & 16) = 16 THEN 1 ELSE 0 END = 1
    END            
ELSE
    BEGIN
        DECLARE CURSOR_DISTRIB CURSOR FAST_FORWARD
        FOR    
            SELECT      name
            FROM        sys.databases
            WHERE       is_distributor =  1
    END


OPEN CURSOR_DISTRIB

FETCH NEXT FROM CURSOR_DISTRIB
INTO @Database

WHILE @@FETCH_STATUS = 0
BEGIN
        IF @SQLVersionMajor = '8'
            SET @SQL = 'SELECT      E.srvname + ''<1>'' + '
        ELSE
            SET @SQL = 'SELECT      E.name + ''<1>'' + '
        
        SET @SQL = @SQL + '         A.publisher_db + ''<2>'' +
                                    A.publication + ''<3>'' +
                                    B.article + ''<4>'' +
                                    B.destination_object + ''<5>'' + '

        IF @SQLVersionMajor = '8'
            SET @SQL = @SQL + '     D.srvname + ''<6>'' + '
        ELSE
            SET @SQL = @SQL +  '
                                    D.name + ''<6>'' + '
                                     
        SET @SQL = @SQL + '         C.subscriber_db + ''<7>'' +
                                    CASE F.subscription_type
                                        WHEN 0 THEN ''Push''
                                        WHEN 1 THEN ''Pull''
                                        WHEN 2 THEN ''Anonymous''
                                        ELSE ''Unknown''
                                    END + ''<8>'' + '

        IF @SQLVersionMajor = '8'
            SET @SQL = @SQL + '     ''<9><10>'' + '
        ELSE
            SET @SQL = @SQL + '     F.subscriber_login + ''<9>'' +
                                        CASE F.subscriber_security_mode
                                            WHEN 0 THEN ''SQL Authentication''
                                            WHEN 1 THEN ''Windows Authentication''       
                                            ELSE ''Unknown''
                                        END + ''<10>'' + '

        SET @SQL = @SQL + '         F.name
                        FROM        ?.dbo.MSpublications                     A WITH (NOLOCK)
                                        JOIN ?.dbo.MSArticles                B WITH (NOLOCK) ON A.publication_id = B.publication_id 
                                                                                                       AND A.publisher_db = B.publisher_db
                                                                                                       AND A.publication_id = B.publication_id
                                        JOIN ?.dbo.MSsubscriptions           C WITH (NOLOCK) ON B.publisher_id = C.publisher_id
                                                                                                       AND B.publisher_db = C.publisher_db
                                                                                                       AND B.publication_id = C.publication_id
                                                                                                       AND B.article_id = C.article_id '

        IF @SQLVersionMajor = '8'
            SET @SQL = @SQL + '         JOIN master..sysservers                         D WITH (NOLOCK) ON C.subscriber_id  = D.srvid 
                                        JOIN master..sysservers                         E WITH (NOLOCK) ON A.publisher_id   = E.srvid '
        ELSE                     
            SET @SQL = @SQL + '         JOIN master.sys.servers                         D WITH (NOLOCK) ON C.subscriber_id  = D.server_id 
                                        JOIN master.sys.servers                         E WITH (NOLOCK) ON A.publisher_id   = E.server_id  '
                                                             
        SET @SQL = @SQL + '             JOIN ?.dbo.MSdistribution_agents     F WITH (NOLOCK) ON A.publisher_id = F.publisher_id
                                                                                            AND A.publisher_db = F.publisher_db
                                                                                            AND A.publication = F.publication
                                                                                            AND C.subscriber_id  = F.subscriber_id  
                                                                                            AND C.subscriber_db = F.subscriber_db '            

        SET @SQL = REPLACE(@SQL, '?', @Database)

        INSERT INTO #RawData
        EXECUTE (@SQL)

    FETCH NEXT FROM CURSOR_DISTRIB
    INTO @Database
END

CLOSE CURSOR_DISTRIB
DEALLOCATE CURSOR_DISTRIB

SELECT * FROM #RawData

DROP TABLE #RawData