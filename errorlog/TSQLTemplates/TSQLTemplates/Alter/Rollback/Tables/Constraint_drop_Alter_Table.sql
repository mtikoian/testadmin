USE [NetikDP]
GO


/*
================================================================================

 Name        : Alter_Table_inf_file_batchid.sql

 Author      : Venu Perala

 Description : This script is to drop constraint on inf_file_batchid 
		

--------------------------------------------------------------------------------
*/

IF EXISTS (	SELECT 1 
				FROM sys.indexes 
				WHERE 
					object_id = OBJECT_ID(N'dbo.inf_file_batchid') AND 
					name = N'UQ_inf_file_batchid__Batch_ID'
			  )
BEGIN 
  	ALTER TABLE dbo.inf_file_batchid 
  		DROP  CONSTRAINT UQ_inf_file_batchid__Batch_ID;
  		 PRINT 'Dropped constraint UQ_inf_file_batchid__Batch_ID';
END
GO

