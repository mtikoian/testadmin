SET NOCOUNT ON;
GO

EXEC SP_CONFIGURE 'show advanced options' , 1;
GO
RECONFIGURE;
GO
DECLARE @SQLtxt nvarchar(max);
DECLARE @spConfigureOutput1 TABLE 
(NAME VARCHAR(4000));

DECLARE @spConfigureOutput TABLE
	([name] VARCHAR(255)
	,[minimum] INT
	,[maximum] INT
	,[config_value] INT
	,[run_value] INT);
 
INSERT INTO @spConfigureOutput
EXEC SP_CONFIGURE;

INSERT INTO @spConfigureOutput1 

SELECT	'EXEC sp_configure ''' + name + ''', ' + CAST(config_value AS VARCHAR)
FROM	@spConfigureOutput;

--SELECT * FROM @spConfigureOutput1
declare @sql_output varchar (max)
set @sql_output = ''       -- NULL + '' = NULL, so we need to have a seed
select @sql_output =       -- string to avoid losing the first line.
       coalesce (@sql_output + name+ char (10), '')
  from @spConfigureOutput1;

print @sql_output;
--EXEC SP_CONFIGURE 'show advanced options' , 0;
--GO
--RECONFIGURE;
--GO


--SELECT  name, value, minimum, maximum, value_in_use as [Value in use], 
--        description, is_dynamic AS [Dynamic?], is_advanced AS [Advanced?]
--FROM    sys.configurations ORDER BY name ;
