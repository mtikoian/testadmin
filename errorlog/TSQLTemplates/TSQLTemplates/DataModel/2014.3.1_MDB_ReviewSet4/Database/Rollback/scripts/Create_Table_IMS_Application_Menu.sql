USE netikip 

go 

SET ansi_nulls ON; 
go 

SET quoted_identifier ON; 
go 

SET ansi_padding ON; 
go 

/* 
 File Name				: Create_Table_IMS_Application_Menu.sql 
 Description			: This table to store application menu items and and it's properties data
 Created By             : vperala 
 Created Date			: 03/11/2014 
 Modification History   : 
 ------------------------------------------------------------------------------ 
 Date    Modified By     Description 
*/ 
PRINT ''; 

PRINT '----------------------------------------'; 

PRINT 'TABLE script for IMS_Application_Menu'; 

PRINT '----------------------------------------'; 

BEGIN try 
    IF EXISTS (SELECT 1 
               FROM   information_schema.Tables 
               WHERE  Table_schema = 'dbo' 
                      AND Table_name = 'IMS_Application_Menu') 
      BEGIN 
          DROP TABLE dbo.IMS_Application_Menu; 

          PRINT 'Table dbo.IMS_Application_Menu has been dropped.'; 
      END; 
	  ELSE
	  BEGIN
		PRINT 'Table dbo.IMS_Application_Menu does not exist.';
	  END;

    
END try 

BEGIN catch 
    DECLARE @error_Message VARCHAR(2100); 
    DECLARE @error_Severity INT; 
    DECLARE @error_State INT; 

    SET @error_Message = Error_message(); 
    SET @error_Severity = Error_severity(); 
    SET @error_State = Error_state(); 

    RAISERROR (@error_Message,@error_Severity,@error_State); 
END catch; 

PRINT ''; 

PRINT 'End of TABLE script for IMS_Application_Menu'; 

PRINT '----------------------------------------'; 