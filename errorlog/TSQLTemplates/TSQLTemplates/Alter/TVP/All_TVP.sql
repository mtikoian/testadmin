
--View all TVP's at server level
SELECT
CAST(
        serverproperty(N'Servername')
       AS sysname) AS [Server_Name],
db_name() AS [Database_Name],
SCHEMA_NAME(tt.schema_id) AS [Schema],
tt.name AS [Name]
FROM
sys.table_types AS tt
INNER JOIN sys.schemas AS stt ON stt.schema_id = tt.schema_id
ORDER BY
[Database_Name] ASC,[Schema] ASC,[Name] ASC

--

SELECT *
		FROM sys.table_types AS tt
		INNER JOIN sys.schemas AS stt ON stt.schema_id = tt.schema_id