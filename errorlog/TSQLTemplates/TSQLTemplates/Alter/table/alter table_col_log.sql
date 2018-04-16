/**************************************************************************************
Author:	   Shelly Purcell
Description:	
            Add column to table bcp_frhold_prestage called SEDOL, which will store
            Accountant data.  this column might be populated with alpha numeric values.
Contact:		Shelly Purcell
***************************************************************************************/
USE fund_reporting
GO

/*
   thursday, Nov 15, 20122:19:58 PM
   User: 
   Server: ctcsql2005
   Database: fund_reporting

*/

IF NOT EXISTS ( select 1 from information_schema.columns 
                where table_name = 'bcp_frhold_prestage'and column_name = 'SEDOL') 
   BEGIN
   
      BEGIN TRANSACTION
      
      ALTER TABLE dbo.bcp_frhold_prestage
        ADD SEDOL VARCHAR(7) NULL;
      IF @@ERROR = 0 
         BEGIN
            COMMIT TRANSACTION
            PRINT 'Successfully added Column SEDOL to table bcp_frhold_prestage'
         END
      ELSE 
         BEGIN
            ROLLBACK TRANSACTION
            PRINT 'UNable to add Column SEDOL to table bcp_frhold_prestage'
         END
   END     
ELSE
   PRINT 'Column SEDOL exists in table bcp_frhold_prestage'
   
   