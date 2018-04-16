USE NETIKIP
GO
/*      
==================================================================================================      
Name		: POSITION_DG      
Author		: MChawla   - 07/25/2013      
Description : This has been created to drop UDFPositionView view before altering position table.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name  Date  Description      
---------- ---------- --------------------------------------------------------      

========================================================================================================      
*/    

IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.VIEWS
		WHERE TABLE_NAME = 'UDFPositionView'
		)
BEGIN
	DROP VIEW dbo.UDFPositionView;
	PRINT 'VIEW UDFPositionView dropped successfully'
END
GO