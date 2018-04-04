SET NOCOUNT ON

CREATE TABLE #tbl_schema 
(
	Instance_Nm		sysname
	,Database_Nm	sysname
	,Table_Nm		sysname
	,Column_Nm		sysname
	,Data_Type		sysname
	,Length			smallint
	,Prec			smallint
	,Scale			int
	,IsComputed		bit
	,IsNullable		bit
)

DECLARE @cmd nvarchar(4000)
		,@InstanceName varchar(256)
		,@DetailDomainName varchar(128)
				
SET @InstanceName = CAST(SERVERPROPERTY('MachineName') AS varchar(128))

EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
							,'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
							,'Domain'
							,@DetailDomainName OUTPUT


SET @cmd = 'use ?;'
SET @cmd = @cmd + 
           'INSERT INTO #tbl_schema '
SET @cmd = @cmd + 
           'SELECT		''' + @InstanceName + CASE WHEN @DetailDomainName IS NULL THEN '' ELSE '.' + @DetailDomainName END + ''''
SET @cmd = @cmd + '     ,db_name() '
SET @cmd = @cmd + '     ,a.name '
SET @cmd = @cmd + '     ,b.name '
SET @cmd = @cmd + '     ,c.name '
SET @cmd = @cmd + '     ,b.length '
SET @cmd = @cmd + '     ,b.prec '
SET @cmd = @cmd + '     ,b.scale '
SET @cmd = @cmd + '     ,b.iscomputed '
SET @cmd = @cmd + '     ,b.isnullable  '
SET @cmd = @cmd + 
           'FROM        sysobjects a '
SET @cmd = @cmd + 
                            'JOIN syscolumns b ON a.id = b.id '
SET @cmd = @cmd + 
                            'JOIN systypes c on b.xtype = c.xtype where a.xtype = ''U'''

EXECUTE sp_MSforeachdb @command1 = @cmd

SELECT		[Instance_Nm] + CHAR(9) + 
				[Database_Nm] + CHAR(9) +
				[Table_Nm] + CHAR(9) + 
				[Column_Nm] + CHAR(9) + 
				[Data_Type] + CHAR(9) + 
				CAST([Length] AS varchar(10)) + CHAR(9) + 
				CAST([Prec] AS varchar(10)) + CHAR(9) + 
				ISNULL(CAST([Scale] AS varchar(10)) , '') + CHAR(9) + 
				CAST([IsComputed] AS char(1)) + CHAR(9) + 
				CAST([IsNullable] AS char(1))
FROM		#tbl_schema 
WHERE		Database_Nm NOT IN ('master','model','msdb','tempdb','distribution','adventureworks','adventureworksdw','pubs','northwind')

DROP TABLE #tbl_schema 