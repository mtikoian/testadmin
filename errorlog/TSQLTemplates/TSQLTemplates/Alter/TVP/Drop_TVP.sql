IF EXISTS (
		SELECT 1
		FROM sys.table_types AS tt
		INNER JOIN sys.schemas AS stt ON stt.schema_id = tt.schema_id
		WHERE tt.NAME = 'ChangeTransDate'
			AND SCHEMA_NAME(tt.schema_id) = 'dbo'
		)
BEGIN 
     DROP TYPE dbo.ChangeTransDate;
     PRINT 'Type dbo.ChangeTransDate has been dropped.';
END


