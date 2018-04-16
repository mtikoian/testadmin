/**************************************************************************************
Author:	   Shelly Purcell
Description:	Rollback Script
            drop column to table bcp_frhold_prestage called SEDOL
Contact:	Shelly Purcell
***************************************************************************************/
USE fund_reporting
GO

/*
   thursday, Nov 15, 20122:19:58 PM
   User: 
   Server: ctcsql2005
   Database: fund_reporting

*/

IF EXISTS ( select 1 from information_schema.columns 
                where table_name = 'bcp_frhold_prestage'and column_name = 'SEDOL') 
   BEGIN
   
      BEGIN TRANSACTION
      
      ALTER TABLE dbo.bcp_frhold_prestage
        DROP COLUMN SEDOL ;
      IF @@ERROR = 0 
         BEGIN
            COMMIT TRANSACTION
            PRINT 'Successfully dropped Column SEDOL to table bcp_frhold_prestage'
         END
      ELSE 
         BEGIN
            ROLLBACK TRANSACTION
            PRINT 'UNable to drop Column SEDOL to table bcp_frhold_prestage'
         END
   END     
ELSE
   PRINT 'Column SEDOL does not exists in table bcp_frhold_prestage'
   
   