USE master; 
SET NOCOUNT ON; SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF OBJECT_ID('tempdb..#syscomments_info') IS NOT NULL DROP TABLE  tempdb..#syscomments_info;
CREATE TABLE #syscomments_info (id int identity(1,1), [database] sysname, [object] sysname, max_colid int, xml_text xml );


DECLARE cur CURSOR LOCAL FAST_FORWARD FOR 
    SELECT [name] FROM sys.databases WHERE state_desc = N'ONLINE' ORDER BY name;

OPEN cur;
DECLARE @database sysname, @command VARCHAR(max);

    FETCH NEXT FROM cur INTO @database ;

    WHILE (@@FETCH_STATUS <> -1)
    BEGIN;

    SELECT @command =  'USE [' + @database + ']; INSERT #syscomments_info ( [database], object, max_colid, xml_text )
                                            SELECT ''' + @database + ''' ,  object, max_colid, xml_text
                                            FROM    ( SELECT   
                                                                     OBJECT_NAME(id) AS [object] 
                                                                    ,MAX(colid) AS max_colid 
                                                                    ,xml_text = (SELECT  CONVERT(XML, REPLACE(REPLACE(( SELECT   text AS ''A''
                                                                                                                         FROM     sys.syscomments
                                                                                                                         WHERE    id=c.id
                                                                                                                         ORDER BY colid
                                                                                                                        FOR XML PATH('''') ), ''</A>'', ''''), ''<A>'', '''')) 
                                                                                                )
                                                                FROM      sys.syscomments c
                                                                WHERE     c.id IN ( SELECT    id 
                                                                                                        FROM      sys.syscomments
                                                                                                        WHERE     id > 0
                                                                                                        GROUP BY  id 
                                                                                )
                                                                GROUP BY  Id
                                                            ) a
                                            WHERE   xml_text.value(''(text())[1]'', ''varchar(max)'') LIKE ''%some_value_1%'' 
                                            --AND ( xml_text.value(''(text())[1]'', ''varchar(max)'') LIKE ''%some_value_2%'' OR xml_text.value(''(text())[1]'', ''varchar(max)'') LIKE ''%some_value_3%'' )
                                            ORDER BY max_colid DESC;'
        --PRINT @command
        EXEC (@command);
        
        FETCH NEXT FROM cur INTO @database ;
    END;
CLOSE cur; DEALLOCATE cur;


SELECT * FROM #syscomments_info ORDER BY [database];