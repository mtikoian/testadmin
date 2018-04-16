DECLARE @attach_output XML, @detach_output XML;

SELECT @attach_output = 
        '<Boaz>       
    <Databases_Attach_Script>       
        <Scripts>       
        </Scripts>       
    </Databases_Attach_Script>       
        </Boaz>'       
        , @detach_output = 
        '<Boaz>       
    <Databases_Detach_Script>       
        <Scripts>       
        </Scripts>       
    </Databases_Detach_Script>       
        </Boaz>';

DECLARE @detachCMD nvarchar(MAX),@attachCMD nvarchar(MAX),@dbname sysname;
DECLARE attchcur CURSOR STATIC READ_ONLY FORWARD_ONLY FOR 
            SELECT   dbs.name
          , 'ALTER DATABASE ' + QUOTENAME(name) + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;' + CHAR(10) 
                    + 'ALTER DATABASE ' + QUOTENAME(name) + ' SET MULTI_USER; ' + CHAR(10) 
           + 'EXEC master.dbo.sp_detach_db @dbname = N''' + name + '''' --AS DetachScript
          , 'CREATE DATABASE ' + QUOTENAME(name) + ' ON' + CHAR(10)
            + REVERSE(STUFF(REVERSE((SELECT   REVERSE(STUFF(REVERSE(CONVERT(NVARCHAR(MAX), (SELECT  '(FILENAME = N''' + physical_name + '''),'
                                                                              + CHAR(10)
                                                                      FROM    sys.master_files
                                                                      WHERE   database_id = dbs.database_id
                                              FOR                     XML PATH('')))), 1, 1, '')))),1,1,''))
                                               + CHAR(10)
            + 'FOR ATTACH;'
   FROM     sys.databases dbs
   WHERE    name IN (name)
   AND dbs.database_id > 4
   ORDER BY dbs.database_id;

OPEN attchcur;
FETCH NEXT FROM attchcur INTO @dbname, @detachCMD, @attachCMD;
WHILE @@FETCH_STATUS = 0
   BEGIN;
        SET @detach_output.modify('insert<Script>"{ sql:variable("@detachCMD") }"</Script> as first into (/Boaz/Databases_Detach_Script/Scripts)[1]'); 
        SET @attach_output.modify('insert<Script>"{ sql:variable("@attachCMD") }"</Script> as first into (/Boaz/Databases_Attach_Script/Scripts)[1]');
      FETCH NEXT FROM attchcur INTO @dbname, @detachCMD, @attachCMD;
   END;
CLOSE attchcur; DEALLOCATE attchcur;

SELECT @detach_output AS '@detach_output',@attach_output AS '@attach_output';