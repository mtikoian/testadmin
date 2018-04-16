USE NetikDP
GO


/*
================================================================================

 Name        : Alter_Table_inf_file_batchid.sql

 Author      : Venu Perala

 Description : This script is to create constraint on inf_file_batchid 
		

--------------------------------------------------------------------------------
*/


IF NOT EXISTS (	SELECT 1 
				FROM sys.indexes 
				WHERE 
					object_id = OBJECT_ID(N'dbo.inf_file_batchid') AND 
					name = N'UQ_inf_file_batchid__Batch_ID'
			  )
BEGIN 
  	ALTER TABLE dbo.inf_file_batchid 
  		ADD  CONSTRAINT UQ_inf_file_batchid__Batch_ID UNIQUE NONCLUSTERED (Batch_ID ASC)
END
GO

---Validation if constraint is created 
IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
      WHERE
        TABLE_SCHEMA = N'dbo' AND
        TABLE_NAME = N'inf_file_batchid' AND
        CONSTRAINT_NAME = N'UQ_inf_file_batchid__Batch_ID')
  BEGIN
    PRINT 'Created constraint UQ_inf_file_batchid__Batch_ID';
  END
ELSE
  BEGIN
    PRINT 'Constraint UQ_inf_file_batchid__Batch_ID was not created!';
    RAISERROR ('Constraint UQ_inf_file_batchid__Batch_ID was not created', 16, 1);
  END;
go